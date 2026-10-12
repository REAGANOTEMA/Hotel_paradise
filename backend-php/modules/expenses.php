<?php
declare(strict_types=1);
$u=current_user();

if($_SERVER['REQUEST_METHOD']==='POST'){
 $act=$_GET['act']??'';
 switch($act){
  case 'create':
   $dept=(int)($_POST['department_id']??0);
   $amount=abs((float)($_POST['amount']??0));
   $desc=trim($_POST['description']??'');
   $cat=trim($_POST['category']??'General');
   if(!$dept||!$desc||$amount<=0){ flash('Complete the department, description and amount.','bad'); go('expenses'); }
   $num=next_number('EXP','expenses','number');
   q('INSERT INTO expenses(hotel_id,number,department_id,requested_by,category,description,amount,status,references_txt,created_at) VALUES(1,?,?,?,?,?,?,\'pending\',?,NOW())',[$num,$dept,$u['id'],$cat,$desc,$amount,trim($_POST['references_txt'])]);
   $eid=(int)db()->lastInsertId();
   audit('create','expense',$eid,['number'=>$num]);
   $dname=(string)val('SELECT name FROM departments WHERE id=?',[$dept]);
   notify_console('expense:'.$eid,'incident','Expense '.$num.' awaiting approval',
    $dname.' · '.$cat.' · '.money($amount).' — '.$desc,
    ['expense_id'=>$eid,'number'=>$num],['director','general_manager','accountant'],'expense',$eid);
   flash('Expense '.$num.' submitted for approval.');
   go('expenses');
   break;
  case 'status':
   $id=(int)($_POST['id']??0); $nst=$_POST['nst']??'';
   $r=row('SELECT * FROM expenses WHERE id=?',[$id]); if(!$r) break;
   if(in_array($nst,['approved','rejected'])){
     q('UPDATE expenses SET status=?,approved_by=?,approved_at=NOW() WHERE id=?',[$nst,$u['id'],$id]);
     audit('expense_'.$nst,'expense',$id,['status'=>$r['status']]);
     notify_console('expense-'.$nst.':'.$id,'communication','Expense '.$r['number'].' '.$nst,
      money($r['amount']).' for '.$r['description'].'.',
      ['expense_id'=>$id],['director','general_manager','accountant'],'expense',$id);
     flash('Expense '.$r['number'].' '.$nst.'.');
   }
   go('expenses');
   break;
  case 'pay':
   $id=(int)($_POST['id']??0);
   $r=row('SELECT * FROM expenses WHERE id=? AND status=\'approved\'',[$id]);
   if(!$r){ flash('Only approved expenses can be paid.','bad'); go('expenses'); }
   q('UPDATE expenses SET status=\'paid\',paid_at=NOW(),payment_method=? WHERE id=?',[$_POST['method']??'cash',$id]);
   audit('expense_paid','expense',$id,['method'=>$_POST['method']??'cash']);
   notify_console('expense-paid:'.$id,'payment','Expense '.$r['number'].' paid',
    money($r['amount']).' paid by '.str_replace('_',' ',(string)($_POST['method']??'cash')).' — '.$r['description'].'.',
    ['expense_id'=>$id],['director','general_manager','accountant'],'expense',$id);
   flash('Expense '.$r['number'].' marked as paid.');
   go('expenses');
   break;
  case 'edit':
   $id=(int)($_POST['id']??0);
   $dept=(int)($_POST['department_id']??0);
   $amount=abs((float)($_POST['amount']??0));
   $desc=trim($_POST['description']??'');
   $cat=trim($_POST['category']??'General');
   if(!$id||!$dept||!$desc||$amount<=0){ flash('Complete the department, description and amount.','bad'); go('expenses'); }
   $cur=row('SELECT status FROM expenses WHERE id=?',[$id]);
   if($cur && $cur['status']==='paid'){ flash('An expense that has been paid cannot be edited.','warn'); go('expenses'); }
   q('UPDATE expenses SET department_id=?,category=?,description=?,amount=?,references_txt=? WHERE id=?',[$dept,$cat,$desc,$amount,trim($_POST['references_txt']??''),$id]);
   audit('update','expense',$id);
   flash('Expense updated.');
   go('expenses');
   break;
 }
}

$flt=$_GET['st']??'';
$where=$flt?'AND e.status=?':'';
$list=rows("SELECT e.*,d.name dept,u.name reqby FROM expenses e JOIN departments d ON d.id=e.department_id JOIN users u ON u.id=e.requested_by WHERE e.deleted_at IS NULL $where ORDER BY e.id DESC LIMIT 100",$flt?[$flt]:[]);
$depts=rows('SELECT * FROM departments ORDER BY name');
$eeId=(int)($_GET['edit']??0); $ee=$eeId?row('SELECT * FROM expenses WHERE id=?',[$eeId]):null;

page_head('Expenses','expenses','Departmental expenditure and approvals');
echo '<div class="kpis">';
kpi_card('Pending',(string)val("SELECT COUNT(*) FROM expenses WHERE status='pending' AND deleted_at IS NULL"),'Awaiting approval','gold');
kpi_card('Approved unpaid',(string)val("SELECT COUNT(*) FROM expenses WHERE status='approved' AND deleted_at IS NULL"),'Ready to pay','blue');
kpi_card('Paid this month',money(val("SELECT COALESCE(SUM(amount),0) FROM expenses WHERE status='paid' AND deleted_at IS NULL AND paid_at>=?",[date('Y-m-01')])),'Settled expenditure','ok');
echo '</div>';

echo '<div class="toolbar"><a class="btn" href="'.BASE.'/index.php?page=expenses&act=create">+ New expense request</a></div>';
echo '<div class="rfilter">';
foreach([''=>'All','pending'=>'Pending','approved'=>'Approved','rejected'=>'Rejected','paid'=>'Paid'] as $k=>$v) echo '<a href="'.BASE.'/index.php?page=expenses'.($k?'&st='.$k:'').'"><button class="'.($flt===$k?'on':'').'">'.$v.'</button></a>';
echo '</div>';

echo '<div class="twoCol"><div>';
echo '<div class="panel"><h2>Expenses</h2><p class="hint">Every request, its approval path and payment state.</p>';
echo '<table class="tbl"><thead><tr><th>Number</th><th>Department</th><th>Category</th><th>Description</th><th class="num">Amount</th><th>Status</th><th></th></tr></thead><tbody>';
foreach($list as $e){
 echo '<tr><td><b>'.e($e['number']).'</b><br><small>'.e($e['reqby']).'</small></td><td>'.e($e['dept']).'</td><td>'.e($e['category']).'</td><td>'.e($e['description']).'</td><td class="num">'.money($e['amount']).'</td><td>'.status_badge($e['status']).'</td><td style="white-space:nowrap">';
 if($e['status']==='pending'){ form_open('expenses','status',['id'=>$e['id']]); echo '<input type="hidden" name="nst" value="approved"><button class="btn sm tick">Approve</button>'; form_close(); form_open('expenses','status',['id'=>$e['id']]); echo '<input type="hidden" name="nst" value="rejected"><button class="btn sm danger">Reject</button>'; form_close(); }
 if($e['status']==='approved'){ form_open('expenses','pay',['id'=>$e['id']]); echo '<select name="method" style="padding:6px;border:1px solid var(--line);border-radius:8px">'; foreach(payment_methods() as $k=>$v2) echo '<option value="'.e($k).'">'.e($v2).'</option>'; echo '</select> <button class="btn sm blue">Mark paid</button>'; form_close(); }
  if($e['status']!=='paid') echo '<a class="btn sm" href="'.BASE.'/index.php?page=expenses&edit='.(int)$e['id'].'#create">Edit</a> '.trash_button('expenses',(int)$e['id'],'expenses');
  echo '</td></tr>';
}
if(!count($list)) echo '<tr><td colspan="7" style="text-align:center;color:var(--muted)">No expenses found.</td></tr>';
echo '</tbody></table></div></div>';

echo '<div>';
echo '<div class="panel" id="create"><h2>'.($ee?'Edit expense request':'New expense request').'</h2><p class="hint">'.($ee?'Update the details of this request.':'Approval and payment follow as per policy.').'</p>';
form_open('expenses',$ee?'edit':'create');
if($ee) echo '<input type="hidden" name="id" value="'.(int)$ee['id'].'">';
echo '<div class="field"><label>Department</label><select name="department_id">'; foreach($depts as $d) echo '<option value="'.(int)$d['id'].'"'.($ee&&(int)$ee['department_id']===(int)$d['id']?' selected':'').'>'.e($d['name']).'</option>'; echo '</select></div>';
echo '<div class="field"><label>Category</label><input name="category" value="'.e($ee['category']??'General').'" list="expcat"><datalist id="expcat"><option>Food</option><option>Beverages</option><option>Stationery</option><option>Maintenance</option><option>Cleaning</option><option>Transport</option><option>Utilities</option><option>Marketing</option></datalist></div>';
echo '<div class="field"><label>Amount (UGX)</label><input type="number" name="amount" value="'.($ee?(float)$ee['amount']:'').'" min="0" step="100" required></div>';
echo '<div class="field"><label>Description</label><textarea name="description" rows="3" placeholder="What the money is for and any supporting detail">'.e($ee['description']??'').'</textarea></div>';
echo '<div class="field"><label>Reference or evidence</label><input name="references_txt" value="'.e($ee['references_txt']??'').'" placeholder="e.g. receipt number, supplier"></div>';
echo '<button class="btn">'.($ee?'Save changes':'Submit for approval').'</button>';
if($ee) echo ' <a class="btnGhost sm" href="'.BASE.'/index.php?page=expenses">Cancel</a>';
form_close();
echo '</div></div></div>';
page_foot();