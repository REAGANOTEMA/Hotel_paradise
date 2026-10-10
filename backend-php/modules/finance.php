<?php
declare(strict_types=1);
$u=current_user();

if($_SERVER['REQUEST_METHOD']==='POST'){
 $act=$_GET['act']??'';
 if($act==='reverse'){
  $pid=(int)($_POST['pid']??0); $reason=trim($_POST['reason']??'');
  $p=row('SELECT * FROM payments WHERE id=?',[$pid]);
  if(!$p||!$reason){ flash('Select a valid payment and give a reason.','bad'); go('finance'); }
  q('INSERT INTO voids(hotel_id,ref_type,ref_id,reason,amount,user_id,approved_by,created_at) VALUES(1,\'payment\',?,?,?,?,?,NOW())',[$pid,$reason,$p['amount'],$u['id'],$u['id']]);
  if($p['reservation_id']){ q('UPDATE reservations SET paid=GREATEST(paid-?,0) WHERE id=?',[$p['amount'],$p['reservation_id']]); }
   q('UPDATE payments SET status=\'reversed\' WHERE id=?',[$pid]);
   audit('reverse_payment','payment',$pid,['amount'=>$p['amount'],'reason'=>$reason]);
   notify_console('void-payment:'.$pid,'incident','Payment #'.$pid.' reversed',
    money($p['amount']).' voided. Reason: '.$reason.'.',
    ['payment_id'=>$pid],['director','general_manager','accountant'],'payment',$pid);
   flash('Payment '.$pid.' reversed and voided on record.');
  go('finance');
 }
 if($act==='confirm'){
  // A guest's online request lands here as pending until the money is actually
  // seen. This is the moment the front desk says it has - and the only moment
  // the guest's receipt is emailed and the hotel's copy is printed.
  $pid=(int)($_POST['pid']??0);
  $p=row('SELECT * FROM payments WHERE id=?',[$pid]);
  if(!$p||strtolower(trim((string)$p['status']))!=='pending'){ flash('That payment is not awaiting confirmation.','bad'); go('finance'); }
  q('UPDATE payments SET status=\'successful\' WHERE id=?',[$pid]);
  audit('confirm_payment','payment',$pid,['status'=>$p['status']],['status'=>'successful']);
  notify_console('confirm-payment:'.$pid,'payment','Payment '.money($p['amount']).' confirmed',
   'Confirmed as received and receipted.',
   ['payment_id'=>$pid],['director','general_manager','accountant','cashier'],'payment',$pid);
  require_once __DIR__.'/../app/receipts.php';
  $receipt=receipts_after_payment($pid);
  $sentNote=($receipt['email_sent']??false)
   ?' The receipt was emailed to '.$receipt['email_to'].'.'
   :(($receipt!==null&&($receipt['email_to']??'')==='')?' No email address was on file, so nothing was emailed.':'');
   flash('Payment #'.$pid.' confirmed as received.'.$sentNote.receipts_copy_note($receipt));
   go('finance',['receipt'=>$pid]);
 }
}

$from=(int)strtotime(trim($_GET['from']?:''));
$d1=trim($_GET['from']?:date('Y-m-d'));
$d2=trim($_GET['to']?:date('Y-m-d'));
if($d2<$d1){ $tmp=$d1; $d1=$d2; $d2=$tmp; }
$payments=rows("SELECT p.*,u.name usr,CASE WHEN p.invoice_id IS NOT NULL THEN 'invoice' WHEN p.order_id IS NOT NULL THEN 'order' WHEN p.reservation_id IS NOT NULL THEN 'reservation' ELSE 'other' END src FROM payments p LEFT JOIN users u ON u.id=p.user_id WHERE DATE(p.created_at) BETWEEN ? AND ? ORDER BY p.id DESC",[$d1,$d2]);

$k=[
 'today'=>val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND DATE(created_at)=?",[today()]),
 'week'=>val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=?",[date('Y-m-d',strtotime('monday this week'))]),
 'month'=>val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=?",[date('Y-m-01')]),
 'outstanding'=>val('SELECT COALESCE(SUM(total-paid),0) FROM reservations WHERE status IN(\'confirmed\',\'checked_in\') AND total>paid'),
 'discount'=>val('SELECT COALESCE(SUM(discount),0) FROM orders WHERE DATE(created_at)=?',[today()]),
 'voids'=>val("SELECT COALESCE(SUM(amount),0) FROM voids WHERE DATE(created_at)=?",[today()])
];

page_head('Finance','finance','Payments, revenue tracking and controls');
echo '<div class="kpis">';
kpi_card('Revenue today',money($k['today']),'Successful payments','ok');
kpi_card('This week',money($k['week']),'From Monday','blue');
kpi_card('This month',money($k['month']),'From 1st');
kpi_card('Outstanding balances',money($k['outstanding']),'Confirmed and in house','gold');
kpi_card('Discounts today',money($k['discount']),'Given on orders','warn');
kpi_card('Voids today',money($k['voids']),'Flagged for review','red');
echo '</div>';

$pending=rows("SELECT p.*,o.order_number,o.customer_name,o.customer_email,r.booking_number,g.full_name AS guest_name,g.email AS guest_email
 FROM payments p
 LEFT JOIN orders o ON o.id=p.order_id
 LEFT JOIN reservations r ON r.id=p.reservation_id
 LEFT JOIN guests g ON g.id=r.guest_id
 WHERE p.status='pending' ORDER BY p.id DESC");
if($pending){
 echo '<div class="panel" style="border-left:4px solid var(--warn,#e0a800)"><h2>Awaiting confirmation</h2>'
  .'<p class="hint">Online payment requests the guest has sent and the hotel has not yet confirmed as received. '
  .'Confirming records the money, emails the guest their receipt and prints the hotel copy. Nothing is emailed or printed before you confirm.</p>';
 echo '<table class="tbl"><thead><tr><th>#</th><th>Requested</th><th>Guest</th><th>Against</th><th class="num">Amount</th><th>Method</th><th>Action</th></tr></thead><tbody>';
 foreach($pending as $p){
  $guest=trim((string)($p['guest_name']??''))?:trim((string)($p['customer_name']??''));
  $email=trim((string)($p['guest_email']??''))?:trim((string)($p['customer_email']??''));
  $against=$p['order_number']?:($p['booking_number']?:'-');
  echo '<tr><td>'.e($p['id']).'</td><td>'.fmtdt($p['created_at']).'</td>'
   .'<td>'.e($guest?:'-').($email!==''?'<br><span style="color:#7b8798;font-size:12px">'.e($email).'</span>':'').'</td>'
   .'<td>'.e($against).'</td><td class="num">'.money($p['amount']).'</td><td>'.e(str_replace('_',' ',$p['method'])).'</td><td>';
  form_open('finance','confirm',['pid'=>$p['id']]);
  echo '<button class="btn sm tick" onclick="return confirm(\'Confirm this payment was received? The guest will be emailed a receipt and the hotel copy will print.\')">Confirm received</button>';
  form_close();
  echo '</td></tr>';
 }
 echo '</tbody></table></div>';
}

echo '<div class="panel"><h2>Payments and reconciliation</h2><p class="hint">Cash up, monitor unusual activity and reverse erroneous payments with a recorded reason.</p>';
echo '<form method="get" style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:16px"><input type="hidden" name="page" value="finance">';
echo '<label>From <input type="date" name="from" value="'.e($d1).'" style="padding:8px;border:1px solid var(--line);border-radius:8px"></label>';
echo '<label>To <input type="date" name="to" value="'.e($d2).'" style="padding:8px;border:1px solid var(--line);border-radius:8px"></label>';
echo '<button class="btn sm">Filter</button></form>';
 echo '<table class="tbl"><thead><tr><th>#</th><th>Date</th><th>Recorded by</th><th>Source</th><th class="num">Amount</th><th>Method</th><th>Status</th><th>Action</th></tr></thead><tbody>';
 foreach($payments as $p){
  echo '<tr><td>'.e($p['id']).'</td><td>'.fmtdt($p['created_at']).'</td><td>'.e($p['usr']??'-').'</td><td>'.e(ucfirst($p['src'])).'</td><td class="num">'.money($p['amount']).'</td><td>'.e(str_replace('_',' ',$p['method'])).'</td><td>'.status_badge($p['status']).'</td><td>';
  if($p['status']==='pending'){ form_open('finance','confirm',['pid'=>$p['id']]); echo '<button class="btn sm tick" onclick="return confirm(\'Confirm this payment was received? The guest will be emailed a receipt and the hotel copy will print.\')">Confirm received</button>'; form_close(); }
  if($p['status']==='successful'){ echo '<details style="font-size:12px"><summary style="cursor:pointer;color:#c62828">Reverse</summary><div style="margin-top:6px">'; form_open('finance','reverse',['pid'=>$p['id']]); echo '<input name="reason" placeholder="Reason for reversal" style="width:100%;padding:7px;border:1px solid var(--line);border-radius:8px"><button class="btn sm danger" style="margin-top:6px">Confirm reversal</button>'; form_close(); echo '</div></details>'; }
  echo '</td></tr>';
 }
 echo '</tbody></table></div>';
 // A payment confirmed above comes back with its id. The hotel copy is drawn
 // fresh so the browser prints it by itself; the guest's copy has already gone
 // by email. Any other visit to this page prints nothing.
 require_once __DIR__.'/../app/receipts.php';
 $receiptPrint=(int)($_GET['receipt']??0);
 if($receiptPrint>0) receipts_hotel_template($receiptPrint,true);
 receipt_print('finance');
 page_foot();