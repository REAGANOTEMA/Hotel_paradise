<?php
declare(strict_types=1);
$u=current_user();
require_once __DIR__.'/../app/finance.php';
require_once __DIR__.'/../app/finance_ui.php';
require_once __DIR__.'/../app/international.php';
$act=$_GET['act']??'';

if(($_GET['export']??'')==='csv'){
 $d1=trim((string)($_GET['from']??''))?:date('Y-m-d');
 $d2=trim((string)($_GET['to']??''))?:date('Y-m-d');
 if($d2<$d1){ $tmp=$d1; $d1=$d2; $d2=$tmp; }
 $export=finance_payment_rows(['from'=>$d1.' 00:00:00','to_excl'=>date('Y-m-d',strtotime($d2.' +1 day')).' 00:00:00','currency'=>(string)($_GET['currency']??''),'settlement'=>(string)($_GET['settlement']??''),'limit'=>5000]);
 $out=[];
 foreach($export as $p){
  $charged=(float)($p['charged_amount']??$p['amount']??0);
  $fee=(float)($p['gateway_fee']??0);
  $out[]=[$p['id'],$p['created_at'],$p['source'],$p['order_number']??$p['invoice_number']??$p['booking_number']??'',$p['method'],$p['status'],$p['amount'],$p['charged_currency']??$p['currency']??'UGX',$charged,$p['fx_rate']??'',$p['order_tracking_id']??'',$p['confirmation_code']??'',$p['settlement_status']??'not_settled',$p['settlement_reference']??'',$fee,round($charged-$fee,2),$p['provider_reference']??'',$p['payer_phone']??'',$p['recorded_by']??''];
 }
 finance_csv_download('finance-payments-'.$d1.'_'.$d2.'.csv',['Payment','Time','Source','Reference','Method','Status','Base amount UGX','Charged currency','Charged amount','FX rate','Order tracking id','Confirmation code','Settlement status','Settlement reference','Gateway fee','Net','Provider reference','Payer phone','Recorded by'],$out);
}

if($_SERVER['REQUEST_METHOD']==='POST'){
 // Payment state is money. Reception and kitchen accounts must never be able
 // to confirm, reverse, receipt or settle a payment by crafting a form post.
 $need=$act==='reverse'||$act==='settle'?'manage':'cash';
 if(!finance_role_can($need)){ flash('Your account cannot change payment records.','bad'); go('finance'); }
 if($act==='reverse'){
  $pid=(int)($_GET['pid']??$_POST['pid']??0); $reason=trim($_POST['reason']??'');
  $p=row('SELECT * FROM payments WHERE id=?',[$pid]);
  if(!$p||!$reason){ flash('Select a valid payment and give a reason.','bad'); go('finance'); }
  q('INSERT INTO voids(hotel_id,ref_type,ref_id,reason,amount,user_id,approved_by,created_at) VALUES(1,\'payment\',?,?,?,?,?,NOW())',[$pid,$reason,$p['amount'],$u['id'],$u['id']]);
  if($p['reservation_id']){ q('UPDATE reservations SET paid=GREATEST(paid-?,0) WHERE id=?',[$p['amount'],$p['reservation_id']]); }
   q('UPDATE payments SET status=\'reversed\' WHERE id=?',[$pid]);
   // An invoice whose payment is voided is no longer settled either. Recompute
   // from the lines and the money that is still successful, so it reopens.
   if($p['invoice_id']){
    require_once __DIR__.'/../app/invoices.php';
    if(function_exists('invoice_recompute')) invoice_recompute((int)$p['invoice_id']);
   }
   // An order whose payment is voided is no longer settled: its status is read
   // back from what actually remains, so it does not stay flagged as paid.
   if($p['order_id']){
    $got=(float)val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE order_id=? AND status='successful'",[(int)$p['order_id']]);
    $odue=(float)val('SELECT total FROM orders WHERE id=?',[(int)$p['order_id']]);
    if($odue>0){ q('UPDATE orders SET status=? WHERE id=?',[$got+0.001>=$odue?'paid':'partially_paid',(int)$p['order_id']]); }
   }
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
  $pid=(int)($_GET['pid']??$_POST['pid']??0);
  $p=row('SELECT * FROM payments WHERE id=?',[$pid]);
  if(!$p||strtolower(trim((string)$p['status']))!=='pending'){ flash('That payment is not awaiting confirmation.','bad'); go('finance'); }
   q('UPDATE payments SET status=\'successful\' WHERE id=?',[$pid]);
   // The booking's own paid figure moves with the confirmation, so the front desk
   // balance and the outstanding report count the money the guest settled online.
   if($p['reservation_id']){ q('UPDATE reservations SET paid=paid+? WHERE id=?',[(float)$p['amount'],(int)$p['reservation_id']]); }
   if($p['invoice_id']){
    require_once __DIR__.'/../app/invoices.php';
    if(function_exists('invoice_recompute')) invoice_recompute((int)$p['invoice_id']);
   }
  audit('confirm_payment','payment',$pid,['status'=>$p['status']],['status'=>'successful']);
  notify_console('confirm-payment:'.$pid,'payment','Payment '.money($p['amount']).' confirmed',
   'Confirmed as received and receipted.',
   ['payment_id'=>$pid],['director','general_manager','accountant','cashier'],'payment',$pid);
  require_once __DIR__.'/../app/receipts.php';
  $receipt=receipts_after_payment($pid);
  if($receipt===null){
   $sentNote=' The receipt could not be prepared. Check the payment and try resending it.';
  }elseif($receipt['email_sent']??false){
   $sentNote=' The receipt was emailed to '.$receipt['email_to'].'.';
  }elseif(($receipt['email_to']??'')===''){
   $sentNote=' No email address was on file, so nothing was emailed.';
  }else{
   $sentNote=' The receipt could not be emailed: '.($receipt['email_error']??'unknown error').' Resend it from the payments list once the mail settings are fixed.';
  }
  $sentNote.=($receipt!==null?' '.receipts_copy_note($receipt):'');
  flash('Payment #'.$pid.' confirmed as received.'.trim($sentNote), ($receipt!==null&&(($receipt['email_sent']??false)||($receipt['email_to']??'')===''))?'ok':'bad');
  go('finance',['receipt'=>$pid]);
 }
 if($act==='settle'){
  if(!finance_column_exists('payments','settlement_status')){ flash('The settlement fields are not installed yet. Apply the international payments patch first.','bad'); go('finance'); }
  $pid=(int)($_GET['pid']??$_POST['pid']??0);
  $reference=trim((string)($_POST['reference']??''));
  $fee=trim((string)($_POST['fee']??''));
  $p=row('SELECT * FROM payments WHERE id=?',[$pid]);
  if(!$p||strtolower(trim((string)$p['status']))!=='successful'){ flash('Only a successful payment can be recorded as settled.','bad'); go('finance'); }
  if($reference===''){ flash('Enter the bank or gateway settlement reference.','bad'); go('finance'); }
  if($fee!==''&&!is_numeric($fee)){ flash('The gateway fee must be a number.','bad'); go('finance'); }
  $set=['settlement_status=?','settlement_reference=?']; $args=['settled',$reference];
  if(finance_column_exists('payments','gateway_fee')){ $set[]='gateway_fee=?'; $args[]=max(0.0,(float)$fee); }
  $args[]=$pid;
  q('UPDATE payments SET '.implode(',',$set).' WHERE id=?',$args);
  audit('settle_payment','payment',$pid,['reference'=>$reference,'fee'=>$fee],['settlement_status'=>'settled']);
  notify_console('settle-payment:'.$pid,'payment','Payment #'.$pid.' settled',
   'Settlement reference '.$reference.' recorded with a fee of '.$fee.'.',
   ['payment_id'=>$pid],['director','general_manager','accountant','auditor'],'payment',$pid);
  flash('Settlement recorded for payment #'.$pid.'.');
  go('finance');
 }
 if($act==='resend'){
  /* A receipt is emailed once, but a failed attempt is never a dead end. This
     retries the guest copy and any staff copy that has not gone yet, using the
     same checks and the same delivery log as the original send. */
  $pid=(int)($_GET['pid']??$_POST['pid']??0);
  require_once __DIR__.'/../app/receipts.php';
  $ctx=receipts_context($pid);
  if($ctx===null){ flash('Only a payment recorded as successful can be receipted.','bad'); go('finance'); }
  $send=receipts_send_email($ctx);
  $staff=receipts_send_staff_copies($ctx);
  if($send['skipped']) $note='The guest copy had already been emailed to '.$send['to'].'.';
  elseif($send['sent']) $note='The guest receipt was emailed to '.$send['to'].'.';
  else $note='The guest receipt could not be emailed'.($send['to']!==''?' to '.$send['to']:'').': '.($send['error']??'unknown error').'.';
  if($staff['sent']>0) $note.=' '.$staff['sent'].' hotel copy/copies sent.';
  if($staff['failed']>0) $note.=' '.$staff['failed'].' hotel copy/copies failed.';
  flash($note, ($send['sent']||$send['skipped'])&&$staff['failed']===0?'ok':'bad');
  go('finance');
 }
}

$d1=trim((string)($_GET['from']??''))?:date('Y-m-d');
$d2=trim((string)($_GET['to']??''))?:date('Y-m-d');
if($d2<$d1){ $tmp=$d1; $d1=$d2; $d2=$tmp; }
$d2x=date('Y-m-d',strtotime($d2.' +1 day'));
$tom=date('Y-m-d',strtotime('+1 day'));
$payments=finance_payment_rows(['from'=>$d1,'to_excl'=>$d2x,'currency'=>(string)($_GET['currency']??''),'settlement'=>(string)($_GET['settlement']??''),'limit'=>500]);
$settlement=finance_settlement_totals($payments);

$k=[
 'today'=>val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=? AND created_at<?",[today(),$tom]),
 'week'=>val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=?",[date('Y-m-d',strtotime('monday this week'))]),
 'month'=>val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=?",[date('Y-m-01')]),
 'outstanding'=>val('SELECT COALESCE(SUM(total-paid),0) FROM reservations WHERE status IN(\'confirmed\',\'checked_in\') AND total>paid'),
 'discount'=>val('SELECT COALESCE(SUM(discount),0) FROM orders WHERE created_at>=? AND created_at<?',[today(),$tom]),
 'voids'=>val("SELECT COALESCE(SUM(amount),0) FROM voids WHERE created_at>=? AND created_at<?",[today(),$tom])
];

page_head('Finance','finance','Payments, revenue tracking and controls');
echo '<div class="toolbar"><a class="btnGhost" href="'.e(finance_page_link('cashier')).'">Cashier workspace</a><a class="btnGhost" href="'.e(finance_page_link('accountant')).'">Accountant workspace</a><a class="btnGhost" href="'.e(finance_page_link('auditor')).'">Auditor workspace</a></div>';
echo '<div class="kpis">';
kpi_card('Revenue today',money($k['today']),'Successful payments','ok');
kpi_card('This week',money($k['week']),'From Monday','blue');
kpi_card('This month',money($k['month']),'From 1st');
kpi_card('Outstanding balances',money($k['outstanding']),'Confirmed and in house','gold');
kpi_card('Discounts today',money($k['discount']),'Given on orders','warn');
kpi_card('Voids today',money($k['voids']),'Flagged for review','red');
echo '</div>';

$pending=rows("SELECT p.*,o.order_number,o.customer_name,o.customer_email,r.booking_number,g.id AS guest_id,g.full_name AS guest_name,g.email AS guest_email
 FROM payments p
 LEFT JOIN orders o ON o.id=p.order_id
 LEFT JOIN reservations r ON r.id=p.reservation_id
 LEFT JOIN guests g ON g.id=r.guest_id
 WHERE p.status='pending' ORDER BY p.id DESC");
if($pending){
 echo '<div class="panel" style="border-left:4px solid var(--warn,#e0a800)"><h2>Awaiting confirmation</h2>'
  .'<p class="hint">Online payment requests the guest has sent and the hotel has not yet confirmed as received. '
  .'Confirming records the money, emails the guest their receipt and prints the hotel copy. Nothing is emailed or printed before you confirm.</p>';
  echo '<table class="tbl"><thead><tr><th>#</th><th>Requested</th><th>Guest</th><th>Against</th><th class="num">Hotel price</th><th class="num">Charged</th><th>Method</th><th>Action</th></tr></thead><tbody>';
 foreach($pending as $p){
   $guest=guest_name($p['guest_name']??'',(int)($p['guest_id']??0));
   if(trim((string)($p['guest_name']??''))==='' && trim((string)($p['customer_name']??''))!=='') $guest=trim((string)$p['customer_name']);
  $email=trim((string)($p['guest_email']??''))?:trim((string)($p['customer_email']??''));
  $against=$p['order_number']?:($p['booking_number']?:'-');
  echo '<tr><td>'.e($p['id']).'</td><td>'.fmtdt($p['created_at']).'</td>'
   .'<td>'.e($guest?:'-').($email!==''?'<br><span style="color:#7b8798;font-size:12px">'.e($email).'</span>':'').'</td>'
   .'<td>'.e($against).'</td><td class="num">'.money($p['amount']).'</td>'
   .'<td class="num">'.e(strtoupper((string)($p['charged_currency']??$p['currency']??'UGX'))).' '.number_format((float)($p['charged_amount']??$p['amount']??0),2).'</td>'
   .'<td>'.e(str_replace('_',' ',$p['method'])).'</td><td>';
  form_open('finance','confirm',['pid'=>$p['id']]);
  echo '<button class="btn sm tick" onclick="return confirm(\'Confirm this payment was received? The guest will be emailed a receipt and the hotel copy will print.\')">Confirm received</button>';
  form_close();
  echo '</td></tr>';
 }
 echo '</tbody></table></div>';
}

echo '<div class="panel"><div class="panelHead"><div><h2>Payments and reconciliation</h2><p class="hint">Cash up, monitor unusual activity and reverse erroneous payments with a recorded reason.</p></div><div class="finTools">'.finance_ui_export_buttons('finance',['from'=>$d1,'to'=>$d2]).'</div></div>';
$selCurrency=strtoupper(trim((string)($_GET['currency']??'')));
$selSettlement=trim((string)($_GET['settlement']??''));
$currencies=function_exists('intl_currencies')?intl_currencies():['UGX','USD','EUR','GBP','KES','TZS'];
echo '<form method="get" style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:16px"><input type="hidden" name="page" value="finance">';
echo '<label>From <input type="date" name="from" value="'.e($d1).'" style="padding:8px;border:1px solid var(--line);border-radius:8px"></label>';
echo '<label>To <input type="date" name="to" value="'.e($d2).'" style="padding:8px;border:1px solid var(--line);border-radius:8px"></label>';
echo '<label>Currency <select name="currency" style="padding:8px;border:1px solid var(--line);border-radius:8px"><option value="">All</option>';
foreach($currencies as $c) echo '<option value="'.e($c).'"'.($selCurrency===$c?' selected':'').'>'.e($c).'</option>';
echo '</select></label>';
echo '<label>Settlement <select name="settlement" style="padding:8px;border:1px solid var(--line);border-radius:8px"><option value="">All</option>';
foreach(['awaiting_settlement'=>'Awaiting settlement','settled'=>'Settled','not_settled'=>'Not settled','mismatch'=>'Verification mismatch','not_applicable'=>'Not applicable'] as $k2=>$label2) echo '<option value="'.e($k2).'"'.($selSettlement===$k2?' selected':'').'>'.e($label2).'</option>';
echo '</select></label>';
echo '<button class="btn sm">Filter</button></form>';

 echo '<div class="panel" style="border-left:4px solid var(--blue,#3579c4);margin-bottom:16px"><h2>Gateway settlement ledger</h2>'
  .'<p class="hint">A verified payment is not the same as money in the bank. Gross charged amounts, gateway fees and expected net payouts are kept next to the hotel&rsquo;s own price so reconciliation is one page.</p>';
 echo '<table class="tbl"><thead><tr><th>Currency</th><th class="num">Payments</th><th class="num">Gross charged</th><th class="num">Awaiting settlement</th><th class="num">Settled gross</th><th class="num">Gateway fees</th><th class="num">Expected net</th></tr></thead><tbody>';
 if(!$settlement['currency']) echo '<tr><td colspan="7" class="hint" style="text-align:center">No payments in this period.</td></tr>';
 foreach($settlement['currency'] as $cur=>$t){
  echo '<tr><td>'.e($cur).'</td><td class="num">'.e((string)$t['count']).'</td><td class="num">'.number_format($t['gross'],2).'</td>'
   .'<td class="num">'.number_format($t['awaiting'],2).'</td>'
   .'<td class="num">'.number_format($t['settled'],2).'</td>'
   .'<td class="num">'.number_format($t['fees'],2).'</td><td class="num"><b>'.number_format($t['net'],2).'</b></td></tr>';
 }
 echo '<tr><td colspan="3"><b>All currencies</b> (hotel price '.money($k['today']).' today)</td><td class="num"><b>'.$settlement['awaiting_count'].'</b> / '.number_format($settlement['awaiting'],2).'</td><td class="num"><b>'.$settlement['settled_count'].'</b> / '.number_format($settlement['settled'],2).'</td><td class="num">'.number_format($settlement['fees'],2).'</td><td class="num"><b>'.number_format($settlement['net'],2).'</b></td></tr>';
 echo '</tbody></table></div>';

 echo '<table class="tbl"><thead><tr><th>#</th><th>Date</th><th>Recorded by</th><th>Source</th><th class="num">Hotel price</th><th class="num">Charged</th><th>FX</th><th>Method</th><th>Status</th><th>Settlement</th><th>Action</th></tr></thead><tbody>';
  foreach($payments as $p){
   $cur=strtoupper((string)($p['charged_currency']??$p['currency']??'UGX'));
   $charged=(float)($p['charged_amount']??$p['amount']??0);
   $rate=(float)($p['fx_rate']??1);
   $st=(string)($p['settlement_status']??'not_settled');
   echo '<tr><td>'.e($p['id']).'</td><td>'.fmtdt($p['created_at']).'</td><td>'.e($p['recorded_by']??'-').'</td><td>'.e(ucfirst((string)($p['source']??'other'))).'</td>'
    .'<td class="num">'.money($p['amount']).'</td><td class="num">'.e($cur).' '.number_format($charged,2).'</td>'
    .'<td>'.($rate==1?'&mdash;':e(number_format($rate,6)).' <span style="color:#7b8798;font-size:11px">'.$cur.'</span>').'</td>'
    .'<td>'.e(str_replace('_',' ',(string)$p['method'])).'</td><td>'.status_badge($p['status']).'</td>'
    .'<td>'.e(str_replace('_',' ',$st)).(!empty($p['settlement_reference'])?'<br><span style="color:#7b8798;font-size:11px">'.e($p['settlement_reference']).'</span>':'').'</td><td>';
   if($p['status']==='pending'){ form_open('finance','confirm',['pid'=>$p['id']]); echo '<button class="btn sm tick" onclick="return confirm(\'Confirm this payment was received? The guest will be emailed a receipt and the hotel copy will print.\')">Confirm received</button>'; form_close(); }
   if($p['status']==='successful'){
    if($st==='awaiting_settlement'){
     echo '<details style="font-size:12px"><summary style="cursor:pointer;color:#3579c4">Record settlement</summary><div style="margin-top:6px">';
     form_open('finance','settle',['pid'=>$p['id']]);
     echo '<input name="reference" placeholder="Bank / gateway reference" style="width:100%;padding:7px;border:1px solid var(--line);border-radius:8px">';
     echo '<input name="fee" placeholder="Gateway fee in '.$cur.'" style="width:100%;padding:7px;border:1px solid var(--line);border-radius:8px;margin-top:5px">';
     echo '<button class="btn sm" style="margin-top:6px">Save settlement</button>'; form_close(); echo '</div></details>';
    }
    echo '<details style="font-size:12px"><summary style="cursor:pointer;color:#c62828">Reverse</summary><div style="margin-top:6px">'; form_open('finance','reverse',['pid'=>$p['id']]); echo '<input name="reason" placeholder="Reason for reversal" style="width:100%;padding:7px;border:1px solid var(--line);border-radius:8px"><button class="btn sm danger" style="margin-top:6px">Confirm reversal</button>'; form_close(); echo '</div></details>';
    form_open('finance','resend',['pid'=>$p['id']]); echo '<button class="btnGhost sm" style="margin-top:6px">Resend receipt</button>'; form_close();
   }
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