<?php
declare(strict_types=1);

/**
 * Stock requisitions, the "inventory request" the departments raise.
 *
 * A department asks the store for what it needs. The request lands with the
 * store manager at once, and the Director is alerted with the full list and the
 * money it comes to, so the decision can be made from the one screen she reads.
 * Nothing here touches the database directly except through the shared helpers,
 * and every ring goes through notify_console, so the bell on every device stays
 * the single story of what happened.
 */

/** The people who own the store and receive every inventory request. */
function stock_request_manager_roles(): array
{
 return ['storekeeper','inventory_manager'];
}

/** The people who decide a request: the Director owns the whole flow. */
function stock_request_decision_roles(): array
{
 return ['director','general_manager','super_admin'];
}

/** The department a console page speaks for, by the department's own code. */
function stock_request_page_department(string $page): ?string
{
 $map=[
  'restaurant'=>'RT',
  'bar'=>'BB',
  'kitchen'=>'KC',
 ];
 return $map[$page]??null;
}

/** The department a member speaks for, from the role they carry. */
function stock_request_role_department(): ?string
{
 $map=[
  'waiter'=>'RT',
  'bar_staff'=>'BB',
  'kitchen'=>'KC',
  'housekeeping'=>'HK',
  'maintenance'=>'MT',
  'receptionist'=>'FD',
  'cashier'=>'CS',
  'accountant'=>'AC',
  'auditor'=>'AU',
  'events_manager'=>'EV',
  'marketing'=>'AD',
  'human_resource'=>'HR',
  'procurement'=>'PR',
  'storekeeper'=>'ST',
  'inventory_manager'=>'INV',
  'director'=>'MG',
  'general_manager'=>'MG',
 ];
 foreach(roles_of() as $role){
  if(isset($map[$role])) return $map[$role];
 }
 return null;
}

/** The department row for a code, or null when the code is not installed. */
function stock_request_department_by_code(string $code): ?array
{
 $r=row('SELECT * FROM departments WHERE code=? AND active=1', [$code]);
 if($r) return $r;
 return row('SELECT * FROM departments WHERE UPPER(REPLACE(name," ",""))=? AND active=1', [strtoupper($code)]);
}

/**
 * The stock categories a department may ask for. The names are the catalogue's
 * own, so the mapping survives a fresh install where the ids differ.
 */
function stock_request_department_categories(string $code): array
{
 $map=[
  'RT'=>['Beverages','Kitchen'],
  'BB'=>['Beverages'],
  'KC'=>['Kitchen'],
  'HK'=>['Housekeeping Supplies'],
  'MT'=>['Maintenance'],
  'FD'=>['Stationery'],
  'LD'=>['Housekeeping Supplies','Stationery'],
  'EV'=>['Beverages','Kitchen','Stationery'],
  'RSV'=>['Beverages','Kitchen'],
  'RS'=>['Beverages','Kitchen'],
  'POOL'=>['Housekeeping Supplies','Maintenance'],
  'SPA'=>['Housekeeping Supplies','Maintenance'],
  'FN'=>['Stationery'],
  'CS'=>['Stationery'],
  'AC'=>['Stationery'],
  'AU'=>['Stationery'],
  'HR'=>['Stationery'],
  'IT'=>['Stationery'],
  'MG'=>['Stationery'],
  'AD'=>['Stationery'],
  'TR'=>['Maintenance'],
  'ST'=>[],
  'INV'=>[],
  'PR'=>[],
 ];
 return $map[$code]??[];
}

/** The item rows a department may requisition, with what is on hand. */
function stock_request_catalog(string $code): array
{
 $wanted=stock_request_department_categories($code);
 $ids=[];
 if($wanted){
  $names=array_map(static fn(string $n): string=>strtolower($n),$wanted);
  foreach(rows('SELECT id,name FROM inventory_categories WHERE active=1 AND deleted_at IS NULL') as $c){
   if(in_array(strtolower((string)$c['name']),$names,true)) $ids[]=(int)$c['id'];
  }
 }
 $sql='SELECT i.*,c.name cat,'
  .'COALESCE((SELECT SUM(sl.quantity) FROM stock_levels sl WHERE sl.item_id=i.id),0) on_hand'
  .' FROM inventory_items i LEFT JOIN inventory_categories c ON c.id=i.category_id'
  .' WHERE i.active=1 AND i.deleted_at IS NULL';
 $args=[];
 if($ids){
  $sql.=' AND i.category_id IN('.implode(',',array_fill(0,count($ids),'?')).')';
  $args=$ids;
 }
 $sql.=' ORDER BY (COALESCE((SELECT SUM(sl.quantity) FROM stock_levels sl WHERE sl.item_id=i.id),0)<=i.reorder_level) DESC,i.name';
 $items=rows($sql,$args);
 if($ids && !$items){
  $items=rows('SELECT i.*,c.name cat,'
   .'COALESCE((SELECT SUM(sl.quantity) FROM stock_levels sl WHERE sl.item_id=i.id),0) on_hand'
   .' FROM inventory_items i LEFT JOIN inventory_categories c ON c.id=i.category_id'
   .' WHERE i.active=1 AND i.deleted_at IS NULL ORDER BY i.name');
 }
 return $items;
}

/** The ids a department is allowed to put on a requisition. */
function stock_request_allowed_item_ids(string $code): array
{
 return array_map(static fn(array $i): int=>(int)$i['id'], stock_request_catalog($code));
}

/**
 * Raises a requisition. The department may only ask for the items mapped to it;
 * the cost is read from the catalogue rather than trusted from the form.
 *
 * @return array{ok:bool,error:?string,id:int,number:string}
 */
function stock_request_create(int $deptId, array $posted, string $note, int $by): array
{
 $dept=$deptId?row('SELECT * FROM departments WHERE id=? AND active=1',[$deptId]):null;
 if(!$dept) return ['ok'=>false,'error'=>'department-required','id'=>0,'number'=>''];
 $allowed=stock_request_allowed_item_ids((string)$dept['code']);
 $allowed=array_fill_keys($allowed,true);
 $costs=[]; foreach(rows('SELECT id,unit_cost FROM inventory_items WHERE active=1 AND deleted_at IS NULL') as $it) $costs[(int)$it['id']]=(float)$it['unit_cost'];
 $clean=[];
 foreach($posted as $iid=>$line){
  if($iid===''||!is_array($line)) continue;
  $id=(int)$iid; $qty=(float)($line['qty']??0);
  if($qty<=0 || !isset($allowed[$id])) continue;
  $clean[$id]=[$qty,(float)($costs[$id]??0)];
 }
 if(!$clean) return ['ok'=>false,'error'=>'items-required','id'=>0,'number'=>''];
 $note=trim($note);
 $num=next_number('REQ','purchase_requisitions','number');
 $pdo=db();
 $pdo->beginTransaction();
 try{
  q('INSERT INTO purchase_requisitions(hotel_id,number,department_id,requested_by,status,note,created_at) VALUES(1,?,?,?,\'pending\',?,NOW())',[$num,$deptId,$by,$note]);
  $rid=(int)$pdo->lastInsertId();
  foreach($clean as $iid=>$d){
   q('INSERT INTO purchase_requisition_items(requisition_id,item_id,requested_qty,est_cost) VALUES(?,?,?,?)',[$rid,$iid,$d[0],$d[1]]);
  }
  $pdo->commit();
 }catch(Throwable $e){
  if($pdo->inTransaction()) $pdo->rollBack();
  error_log('[hotel stock] could not raise requisition: '.$e->getMessage());
  return ['ok'=>false,'error'=>'could-not-save','id'=>0,'number'=>''];
 }
 audit('create','requisition',$rid,['number'=>$num,'department'=>$dept['name']]);
 $list=stock_request_item_list($rid);
 $total=stock_request_total($rid);
 notify_console('req:'.$rid,'incident','Stock request '.$num.' awaiting approval',
  $dept['name'].' needs: '.$list.'. Total '.money($total).'.'.($note!==''?' - '.$note:''),
  ['requisition_id'=>$rid,'number'=>$num,'amount'=>$total,'department_id'=>$deptId],
  array_merge(stock_request_decision_roles(),stock_request_manager_roles()),'requisition',$rid);
 return ['ok'=>true,'error'=>null,'id'=>$rid,'number'=>$num];
}

/**
 * Handles the requisition forms drawn on a department's own dashboard. The
 * page, not a hidden field, decides which department the member speaks for.
 */
function stock_request_handle_widget(string $page, array $user): void
{
 $act=$_GET['act']??'';
 if($act==='req'){
  $code=stock_request_page_department($page) ?: stock_request_role_department();
  $dept=$code?stock_request_department_by_code($code):null;
  if(!$dept){
   flash('This dashboard is not linked to a department. Ask the store to set one up.','bad');
   go($page);
  }
  $res=stock_request_create((int)$dept['id'],(array)($_POST['items']??[]),(string)($_POST['note']??''),(int)$user['id']);
  if(!$res['ok']){
   $msg=$res['error']==='items-required'?'Choose at least one item and quantity.':'The stock request could not be sent. Please try again.';
   flash($msg,'bad');
  }else{
   flash('Stock request '.$res['number'].' sent to the store and the Director.');
  }
  go($page);
 }
 if($act==='reqstatus'){
  if(!(has_role('director')||has_role('general_manager')||has_role('super_admin'))){
   flash('Only the Director or General Manager may decide a stock request.','bad');
   go($page);
  }
  $rid=(int)($_POST['id']??0);
  $r=$rid?row('SELECT * FROM purchase_requisitions WHERE id=?',[$rid]):null;
  if(!$r){ flash('That request no longer exists.','bad'); go($page); }
  $res=stock_request_decide($rid,(string)($_POST['nst']??''),(string)($_POST['reason']??''),(int)$user['id']);
  if(!$res['ok']){
   flash($res['error']==='reason-required'?'A reason is required when turning down a request.':'That request could not be updated.','bad');
  }else{
   flash('Stock request '.$r['number'].' '.(string)($_POST['nst']??'').'.');
  }
  go($page);
 }
}

/** The department's own request form and the requests it has already raised. */
function stock_request_department_panel(array $dept, string $page, string $title=''): void
{
 $code=(string)$dept['code'];
 $items=stock_request_catalog($code);
 $recent=rows('SELECT pr.*,u.name reqby,'
  .'(SELECT COALESCE(SUM(requested_qty*est_cost),0) FROM purchase_requisition_items ri WHERE ri.requisition_id=pr.id) amount'
  .' FROM purchase_requisitions pr JOIN users u ON u.id=pr.requested_by'
  .' WHERE pr.department_id=? AND pr.deleted_at IS NULL ORDER BY pr.id DESC LIMIT 6',[(int)$dept['id']]);
 echo '<div class="panel" style="border-left:4px solid var(--gold)"><h2>'.e($title!==''?$title:$dept['name'].' stock requests').'</h2>';
 echo '<p class="hint">Ask the store for the '.e(strtolower((string)$dept['name'])).' items below. The request goes to the storekeeper and the Director together, with the full list and the money it comes to.</p>';
 if(!$items){
  echo '<p class="emptyLine">No stock items are catalogued for this department yet. Ask the store to add them.</p>';
 }else{
  form_open($page,'req');
  echo '<input type="hidden" name="department_id" value="'.(int)$dept['id'].'">';
  echo '<div class="tableScroll"><table class="tbl"><thead><tr><th>Item</th><th>Category</th><th class="num">On hand</th><th class="num">Unit cost</th><th>Quantity</th></tr></thead><tbody>';
  foreach($items as $i){
   $low=(float)$i['on_hand']<=(float)$i['reorder_level'];
   echo '<tr><td><b>'.e($i['name']).'</b><br><small>'.e($i['unit']).'</small></td><td>'.e($i['cat']??'-').'</td>';
   echo '<td class="num"'.($low?' style="color:#c62828;font-weight:700"':'').'>'.num($i['on_hand']).'</td>';
   echo '<td class="num">'.money($i['unit_cost']).'</td>';
   echo '<td><input type="number" name="items['.(int)$i['id'].'][qty]" min="0" step="0.5" placeholder="0" style="width:92px;padding:7px;border:1px solid var(--line);border-radius:8px"></td></tr>';
  }
  echo '</tbody></table></div>';
  echo '<div class="field" style="margin-top:12px"><label>Note for the store</label><input name="note" placeholder="Optional: what it is for or when it is needed"></div>';
  echo '<button class="btn" type="submit">Send request to the store</button>';
  form_close();
 }
 if($recent){
  echo '<h3 style="margin:20px 0 8px;font-size:14px;color:var(--navy)">Recent requests from '.e($dept['name']).'</h3>';
  echo '<div class="tableScroll"><table class="tbl"><thead><tr><th>Number</th><th>Items</th><th class="num">Amount</th><th>Status</th></tr></thead><tbody>';
  foreach($recent as $r){
   echo '<tr><td><b>'.e($r['number']).'</b><br><small>'.e($r['reqby']).' &middot; '.fmtdt($r['created_at']).'</small></td>';
   echo '<td>'.e(stock_request_item_list((int)$r['id'])?:'-').'</td><td class="num"><b>'.money($r['amount']).'</b></td>';
   echo '<td>'.status_badge($r['status']).($r['status']==='rejected'&&trim((string)($r['decision_reason']??''))!==''?'<br><small>'.e($r['decision_reason']).'</small>':'').'</td></tr>';
  }
  echo '</tbody></table></div>';
 }
 echo '</div>';
}

/** The store's inbox and the Director's decision queue, with every line shown. */
function stock_request_oversight_panel(string $page, string $title='Department stock requests'): void
{
 $canDecide=(bool)array_intersect(roles_of(),stock_request_decision_roles());
 $canStore=(bool)array_intersect(roles_of(),stock_request_manager_roles());
 if(!$canDecide && !$canStore) return;
 $reqs=rows('SELECT pr.*,d.name dept,u.name reqby,'
  .'(SELECT COALESCE(SUM(requested_qty*est_cost),0) FROM purchase_requisition_items ri WHERE ri.requisition_id=pr.id) amount'
  .' FROM purchase_requisitions pr JOIN departments d ON d.id=pr.department_id JOIN users u ON u.id=pr.requested_by'
  .' WHERE pr.deleted_at IS NULL ORDER BY (pr.status=\'pending\') DESC,pr.id DESC LIMIT 12');
 $pending=0; foreach($reqs as $r){ if($r['status']==='pending') $pending++; }
 echo '<div class="panel" style="border-left:4px solid var(--gold)"><h2>'.e($title).($pending?' '.badge($pending.' pending','warn'):'').'</h2>';
 echo '<p class="hint">Every department request, with the exact items and the amount. The store sees what is needed; the Director approves or turns it down.</p>';
 if(!$reqs){
  echo '<p class="emptyLine">No department stock requests yet.</p></div>';
  return;
 }
 echo '<div class="tableScroll"><table class="tbl"><thead><tr><th>Number</th><th>Department</th><th>Items</th><th class="num">Amount</th><th>Status</th>'.($canDecide?'<th>Decision</th>':'').'</tr></thead><tbody>';
 foreach($reqs as $r){
  echo '<tr><td><b>'.e($r['number']).'</b><br><small>'.e($r['reqby']).' &middot; '.fmtdt($r['created_at']).'</small></td>';
  echo '<td>'.e($r['dept']).'</td><td>'.e(stock_request_item_list((int)$r['id'])?:'-').'</td>';
  echo '<td class="num"><b>'.money($r['amount']).'</b></td><td>'.status_badge($r['status']);
  if($r['status']==='rejected'&&trim((string)($r['decision_reason']??''))!=='') echo '<br><small>'.e($r['decision_reason']).'</small>';
  echo '</td>';
  if($canDecide){
   echo '<td style="white-space:nowrap">';
   if($r['status']==='pending'){
    form_open($page,'reqstatus',['id'=>(int)$r['id']]);
    echo '<input type="hidden" name="nst" value="approved"><button class="btn sm tick">Approve</button></form>';
    form_open($page,'reqstatus',['id'=>(int)$r['id']]);
    echo '<input type="hidden" name="nst" value="rejected"><input name="reason" placeholder="Reason (required)" style="margin-top:6px;width:160px;padding:7px;border:1px solid var(--line);border-radius:8px"><button class="btn sm danger" style="margin-top:6px">Reject</button></form>';
   }else{
    echo '-';
   }
   echo '</td>';
  }
  echo '</tr>';
 }
 echo '</tbody></table></div>';
 if(page_allowed('purchases')){
  echo '<div style="margin-top:12px"><a class="btnGhost sm" href="'.BASE.'/index.php?page=purchases">Open the store and purchasing desk</a></div>';
 }
 echo '</div>';
}

/** The dashboard's own request card and, for the store or Director, the inbox. */
function stock_request_dashboard_panel(string $page): void
{
 $code=stock_request_role_department();
 $dept=$code?stock_request_department_by_code($code):null;
 $oversight=array_merge(stock_request_manager_roles(),stock_request_decision_roles());
 if($dept && !array_intersect(roles_of(),$oversight)) stock_request_department_panel($dept,$page,'Your department stock request');
 stock_request_oversight_panel($page);
}

/** The line items of a requisition, with the figures the Director is shown. */
function stock_request_lines(int $rid): array
{
 try{
  return rows(
   'SELECT ri.*,i.name item_name,i.unit,i.code,(ri.requested_qty*ri.est_cost) line_total'
   .' FROM purchase_requisition_items ri JOIN inventory_items i ON i.id=ri.item_id'
   .' WHERE ri.requisition_id=? ORDER BY i.name', [$rid]);
 }catch(Throwable $e){
  error_log('[hotel stock] could not read requisition '.$rid.': '.$e->getMessage());
  return [];
 }
}

/** What a requisition comes to, in shillings, from the figures frozen on its lines. */
function stock_request_total(int $rid): float
{
 try{
  return (float)val('SELECT COALESCE(SUM(requested_qty*est_cost),0) FROM purchase_requisition_items WHERE requisition_id=?', [$rid]);
 }catch(Throwable $e){
  error_log('[hotel stock] could not total requisition '.$rid.': '.$e->getMessage());
  return 0.0;
 }
}

/** One line a person can read: "12 kg of Beef". */
function stock_request_item_list(int $rid): string
{
 $parts=[];
 foreach(stock_request_lines($rid) as $l){
  $parts[]=num($l['requested_qty']).' '.$l['unit'].' '.$l['item_name'];
 }
 return implode(', ', $parts);
}

/** A member's name, for the words the Director reads. */
function stock_request_user_name(?int $id): string
{
 if(!$id) return 'the system';
 return (string)(val('SELECT name FROM users WHERE id=?', [$id]) ?: 'a team member');
}

/**
 * The Director approves or turns a request down. A refusal must carry a reason:
 * the reason is written on the request and is the first thing the department
 * and the store read, so a "no" is never silent.
 *
 * @return array{ok:bool,error:?string}
 */
function stock_request_decide(int $rid, string $status, string $reason, int $by): array
{
 if(!in_array($status,['approved','rejected'],true)) return ['ok'=>false,'error'=>'bad-status'];
 $r=row('SELECT * FROM purchase_requisitions WHERE id=?', [$rid]);
 if(!$r) return ['ok'=>false,'error'=>'not-found'];
 $reason=trim($reason);
 if($status==='rejected' && $reason==='') return ['ok'=>false,'error'=>'reason-required'];

 q('UPDATE purchase_requisitions SET status=?,approved_by=?,approved_at=NOW(),decision_reason=? WHERE id=?',
  [$status,$by,$reason!==''?$reason:null,$rid]);
 audit('requisition_'.$status,'requisition',$rid,['status'=>$r['status'],'reason'=>$reason]);

 $total=stock_request_total($rid);
 $who=stock_request_user_name($by);
 if($status==='approved'){
  $body='Approved by '.$who.'. The list comes to '.money($total).'. The store can now issue the stock or raise a purchase order.';
 }else{
  $body='Turned down by '.$who.' — '.$reason.'. Amount requested was '.money($total).'.';
 }

 notify_console('req-'.$status.':'.$rid,'communication','Stock request '.$r['number'].' '.$status,$body,
  ['requisition_id'=>$rid,'number'=>$r['number'],'amount'=>$total,'status'=>$status],
  array_merge(['director','general_manager'],stock_request_manager_roles()),'requisition',$rid);
 return ['ok'=>true,'error'=>null];
}
