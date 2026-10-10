<?php
declare(strict_types=1);

/*
 * Food and beverage: the floor, the bills and the money taken for them.
 *
 * The kitchen screen is about food and knows nothing about prices. This one is
 * the other half: what each outlet is carrying, who each order is for, what has
 * been paid against it, and the receipt. The receipt prints itself the moment a
 * payment is recorded - that is the only time this page starts printing on its
 * own, because that is the moment a guest needs one.
 */

$act=$_GET['act']??'';
$u=current_user();

/** Orders the list has not drawn. A new one reloads the page to draw it. */
if($act==='feed'){
 header('Content-Type: application/json; charset=utf-8');
 $ids=rows('SELECT o.id FROM orders o WHERE DATE(o.created_at)=CURDATE() ORDER BY o.id DESC LIMIT 100');
 echo json_encode(['ids'=>array_map(static fn(array $r): int=>(int)$r['id'],$ids)]);
 exit;
}

if($_SERVER['REQUEST_METHOD']==='POST'){
 switch($act){
  case 'settle':
   $oid=(int)($_POST['oid']??0);
   $r=row('SELECT * FROM orders WHERE id=?',[$oid]);
   if(!$r){ flash('That order is no longer open.','bad'); go('fnb'); }
   $discount=max(0.0,(float)($_POST['discount']??0));
   $method=$_POST['method']??'cash';
   $due=max(0.0,(float)$r['total']-$discount);
   $paidNow=max(0.0,(float)($_POST['amount']??$due));
   if($paidNow<=0){ flash('Enter the amount collected.','bad'); go('fnb',['view'=>$oid]); }
   q('INSERT INTO payments(hotel_id,user_id,order_id,amount,method,status,created_at) VALUES(1,?,?,?,?,\'successful\',NOW())',
     [$u['id'],$oid,$paidNow,$method]);
   $payId=(int)db()->lastInsertId();
   audit('payment','order',$oid,['amount'=>$paidNow,'method'=>$method]);
   if($discount>0) q('UPDATE orders SET discount=?,total=? WHERE id=?',[$discount,$due,$oid]);
   $got=(float)val('SELECT COALESCE(SUM(amount),0) FROM payments WHERE order_id=? AND status=\'successful\'',[$oid]);
   q('UPDATE orders SET status=? WHERE id=?',[$got+0.001>=$due?'paid':'partially_paid',$oid]);
   notify_console('desk-fnb-payment:'.$payId,'payment','F&B payment '.money($paidNow),
    'Received by '.str_replace('_',' ',(string)$method).' for order '.$r['order_number'].'.',
    ['order_id'=>$oid,'payment_id'=>$payId],['director','general_manager','accountant','cashier'],'payment',$payId);
   // The money is in, so the guest's copy goes to their email at once. The bill
   // below prints itself as the hotel's copy. Neither happens on a request that
   // was not paid, because this call only ever sees a settled payment.
   require_once __DIR__.'/../app/receipts.php';
   $receipt=receipts_after_payment($payId);
   $sentNote=($receipt['email_sent']??false)
    ?' The receipt was emailed to '.$receipt['email_to'].'.'
    :(($receipt!==null&&($receipt['email_to']??'')==='')?' No email address was on file, so nothing was emailed.':'');
   flash('Payment of '.money($paidNow).' recorded for order '.$r['order_number'].'.'.$sentNote.receipts_copy_note($receipt));
   go('fnb',['view'=>$oid,'printed'=>1]);
   break;
  case 'status':
   $oid=(int)($_POST['oid']??0); $nst=$_POST['nst']??'';
   $r=row('SELECT status,order_number FROM orders WHERE id=?',[$oid]);
   if(!$r){ flash('That order is no longer open.','bad'); go('fnb'); }
   if(in_array($nst,['accepted','preparing','ready','served','cancelled'],true)){
    q('UPDATE orders SET status=? WHERE id=?',[$nst,$oid]);
    audit('order_status','order',$oid,['status'=>$r['status']],['status'=>$nst]);
    if($nst==='cancelled'){
     notify_console('desk-fnb-cancel:'.$oid,'incident','Order '.$r['order_number'].' cancelled',
      'Cancelled from Food and Beverage (was '.str_replace('_',' ',(string)$r['status']).').',
      ['order_id'=>$oid],['director','general_manager','cashier'],'order',$oid);
    }
    flash('Order '.$r['order_number'].' updated to '.$nst.'.');
   }
   go('fnb',['view'=>$oid]);
   break;
  case 'print':
   go('fnb',['view'=>(int)($_POST['oid']??0),'printed'=>1]);
   break;
 }
}

/* ------------------------------------------------------------------ the data */

$today=today();
$only=$_GET['outlet']??'';
$where='DATE(o.created_at)=?';
$p=[$today];
if($only!==''){ $where.=' AND o.outlet=?'; $p[]=$only; }

$orders=rows("SELECT o.*,(SELECT oi.notes FROM order_items oi WHERE oi.order_id=o.id AND oi.notes<>'' ORDER BY oi.id LIMIT 1) any_notes,
 (SELECT COALESCE(SUM(p.amount),0) FROM payments p WHERE p.order_id=o.id AND p.status='successful') paid
 FROM orders o WHERE $where ORDER BY o.id DESC LIMIT 60",$p);

$lines=[];
$ids=array_map(static fn(array $r): int=>(int)$r['id'],$orders);
if($ids){
 foreach(rows('SELECT oi.order_id,oi.quantity,oi.unit_price,oi.total,oi.notes,mi.name FROM order_items oi LEFT JOIN menu_items mi ON mi.id=oi.menu_item_id WHERE oi.order_id IN('.implode(',',array_map('intval',$ids)).') ORDER BY oi.id',[]) as $l){
  $lines[(int)$l['order_id']][]=$l;
 }
}

$k=[
 'orders'=>count($orders),
 'sales'=>array_sum(array_map(static fn(array $o): float=>(float)$o['total'],$orders)),
 'taken'=>array_sum(array_map(static fn(array $o): float=>(float)$o['paid'],$orders)),
 'owed'=>count(array_filter($orders,static fn(array $o): bool=>(float)$o['paid']+0.001<(float)$o['total'])),
];

$orderByNumber=[];
foreach($orders as $o) $orderByNumber[(int)$o['id']]=$o;
$viewId=(int)($_GET['view']??0);
$view=$orderByNumber[$viewId]??null;
$justPrinted=isset($_GET['printed']);

/* ------------------------------------------------------------------ the paper */

/**
 * One bill. $withMoney is false for the kitchen-facing copy: the same sheet
 * with the money taken off, which is what a docket needs and a guest does not.
 */
$sheet=function(array $o) use ($lines): string{
 $ls=[];
 foreach($lines[(int)$o['id']]??[] as $l){
  $note=prep_note($l['notes']??null);
  $ls[]=['name'=>(string)($l['name']??'Item removed'),
   'qty'=>rtrim(rtrim(number_format((float)$l['quantity'],2,'.',''),'0'),'.'),
   'note'=>$note,
   'amount'=>money($l['total'])];
 }
 $g=order_customer($o['any_notes']??null);
 $paid=(float)$o['paid'];
 $t=[['Subtotal',money($o['subtotal'])]];
 if((float)$o['tax']>0) $t[]=['Service charge (3.5%)',money($o['tax'])];
 if((float)$o['discount']>0) $t[]=['Discount','-'.money($o['discount'])];
 $t[]=['Total',money($o['total']),'big'];
 if($paid>0){ $t[]=['Paid',money($paid)]; if($paid+0.001<(float)$o['total']) $t[]=['Balance due',money((float)$o['total']-$paid),'big']; }
 $m=[];
 $m['Outlet']=ucfirst((string)$o['outlet']);
 $m['Service']=$o['order_type']==='room'?'Room service':ucfirst((string)$o['order_type']);
 if($o['table_name']) $m['Table or room']=(string)$o['table_name'];
 $m['Opened']=fmtdt($o['created_at']);
 if($g){ $m['Guest']=$g['name']; $m['Phone']=$g['phone']; }
 return receipt_sheet([
  'kind'=>'RECEIPT',
  'number'=>(string)$o['order_number'],
  'meta'=>$m,
  'lines'=>$ls,
  'totals'=>$t,
  'foot'=>'Status: '.str_replace('_',' ',(string)$o['status']).' &middot; settle at the front desk or on mobile money'
 ]);
};

foreach($orders as $o){
 $fresh=$justPrinted && (int)$o['id']===$viewId;
 receipt_template($o['id'],$sheet($o),$fresh);
}

/* ------------------------------------------------------------------ the screen */

page_head('Food and Beverage','fnb',$only?ucfirst(str_replace('_',' ',$only)).' · today':date('l, j F Y'));

echo '<div class="kpis">';
kpi_card('Orders today',(string)$k['orders'],'Across all outlets');
kpi_card('Sales today',money($k['sales']),'Billed, before payment');
kpi_card('Collected today',money($k['taken']),'Payments recorded',$k['taken']?'green':'navy');
kpi_card('Still to settle',(string)$k['owed'],'Orders not paid in full',$k['owed']?'gold':'navy');
echo '</div>';

echo '<div class="toolbar"><div class="bar">';
echo '<a class="'.($only===''?'btn sm':'btnGhost sm').'" href="'.BASE.'/index.php?page=fnb">All outlets</a>';
foreach(['restaurant','bar','room_service','front_desk'] as $o){
 echo '<a class="'.($only===$o?'btn sm':'btnGhost sm').'" href="'.BASE.'/index.php?page=fnb&amp;outlet='.e($o).'">'.e(ucfirst(str_replace('_',' ',$o))).'</a>';
}
echo '</div><button class="btn sm" type="button" onclick="location.reload()">Refresh</button></div>';

if($view){
 echo '<div class="panel"><div class="toolbar" style="margin-bottom:14px">';
 echo '<div><h2>Order '.e($view['order_number']).'</h2><p class="hint" style="margin:0">'.fmtdt($view['created_at']).' &middot; '.e(ucfirst((string)$view['outlet'])).' &middot; '.status_badge($view['status']).'</p></div>';
 echo '<div class="bar">';
 echo '<button class="btn sm" type="button" onclick="printReceipt('.(int)$view['id'].')">Print receipt</button>';
 echo '<a class="btnGhost sm" href="'.BASE.'/index.php?page=fnb">Close</a>';
 echo '</div></div>';

 $g=order_customer($view['any_notes']??null);
 echo '<div class="res-meta" style="margin-bottom:16px">';
 echo '<div class="field" style="margin:0"><label>Guest</label><div>'.e($g['name']??'Counter order').'</div></div>';
 if($g) echo '<div class="field" style="margin:0"><label>Phone</label><div>'.e($g['phone']).'</div></div>';
 $d=order_delivery($view);
 if($d['email']) echo '<div class="field" style="margin:0"><label>Email</label><div>'.e($d['email']).'</div></div>';
 if($d['address']) echo '<div class="field" style="margin:0"><label>Deliver to</label><div>'.e($d['address']).'</div></div>';
 echo '<div class="field" style="margin:0"><label>Service</label><div>'.e($view['order_type']==='room'?'Room service':ucfirst((string)$view['order_type'])).($view['table_name']?' &middot; '.e((string)$view['table_name']):'').'</div></div>';
 echo '<div class="field" style="margin:0"><label>Paid</label><div><b>'.money($view['paid']).' of '.money($view['total']).'</b></div></div>';
 echo '</div>';
 if($d['notes']) echo '<p class="hint" style="margin:-6px 0 14px">Note from guest: '.e($d['notes']).'</p>';

 echo '<table class="tbl"><thead><tr><th>Dish</th><th class="num">Qty</th><th class="num">Unit</th><th class="num">Amount</th></tr></thead><tbody>';
 foreach($lines[(int)$view['id']]??[] as $l){
  $note=prep_note($l['notes']??null);
  echo '<tr><td><b>'.e($l['name']??'Item removed').'</b>'.($note?'<br><small>'.e($note).'</small>':'').'</td>';
  echo '<td class="num">'.rtrim(rtrim(number_format((float)$l['quantity'],2,'.',''),'0'),'.').'</td>';
  echo '<td class="num">'.money($l['unit_price']).'</td><td class="num">'.money($l['total']).'</td></tr>';
 }
 echo '</tbody></table>';

 echo '<div class="totals" style="max-width:340px;margin-left:auto">';
 echo '<div class="tt"><span>Subtotal</span><b>'.money($view['subtotal']).'</b></div>';
 if((float)$view['tax']>0) echo '<div class="tt" style="font-size:13px;font-weight:600"><span>Service charge (3.5%)</span><b>'.money($view['tax']).'</b></div>';
 if((float)$view['discount']>0) echo '<div class="tt" style="font-size:13px;font-weight:600"><span>Discount</span><b>-'.money($view['discount']).'</b></div>';
 echo '<div class="tt" style="font-size:18px"><span>Total</span><b>'.money($view['total']).'</b></div>';
 if((float)$view['paid']>0) echo '<div class="tt" style="font-size:13px;color:#2e7d32"><span>Paid</span><b>'.money($view['paid']).'</b></div>';
 echo '</div>';

 $due=max(0.0,(float)$view['total']-(float)$view['paid']);
 if($due>0.001){
  echo '<h3 style="margin-top:20px">Take a payment</h3>';
  form_open('fnb','settle',['oid'=>$view['id']]);
  echo '<div class="formRow">';
  echo '<div class="field"><label>Amount collected</label><input type="number" name="amount" value="'.(int)round($due).'" step="100" min="0"></div>';
  echo '<div class="field"><label>Discount</label><input type="number" name="discount" value="0" step="100" min="0"></div>';
  echo '<div class="field"><label>Method</label><select name="method">';
  foreach(payment_methods() as $mk=>$mv) echo '<option value="'.e($mk).'">'.e($mv).'</option>';
  echo '</select></div></div>';
  echo '<button class="btn tick">Record payment and print</button>';
  echo '<p class="hint" style="margin:10px 0 0">The receipt prints by itself as soon as it is recorded.</p>';
  form_close();
 }
 echo '</div>';
}

echo '<div class="panel"><h2>Today\'s orders</h2><p class="hint">Every order placed today, newest first. Open one to see it in full or take a payment.</p>';
if(!count($orders)){
 echo '<p class="emptyLine">No orders have been placed today yet.</p>';
}else{
 echo '<table class="tbl"><thead><tr><th>Order</th><th>Time</th><th>Guest</th><th>Dishes</th><th>Outlet</th><th class="num">Total</th><th class="num">Paid</th><th>Status</th><th></th></tr></thead><tbody>';
 foreach($orders as $o){
  $oid=(int)$o['id'];
  $g=order_customer($o['any_notes']??null);
  $names=[];
  foreach($lines[$oid]??[] as $l) $names[]=(string)($l['name']??'');
  $paid=(float)$o['paid'];
  echo '<tr><td><b><a href="'.BASE.'/index.php?page=fnb&amp;view='.$oid.'">'.e($o['order_number']).'</a></b></td>';
  echo '<td>'.date('H:i',strtotime((string)$o['created_at'])).'</td>';
  echo '<td>'.e($g['name']??'Counter').'<br><small>'.e($g['phone']??'').'</small></td>';
  echo '<td>'.e(implode(', ',array_slice($names,0,2))).(count($names)>2?' &hellip; ('.count($names).')':'').'</td>';
  echo '<td>'.e(ucfirst((string)$o['outlet'])).'</td>';
  echo '<td class="num">'.money($o['total']).'</td>';
  echo '<td class="num" style="'.($paid+0.001>=(float)$o['total']?'color:#2e7d32':($paid>0?'color:#b26a00':'color:#c62828')).'">'.money($paid).'</td>';
  echo '<td>'.status_badge($o['status']).'</td>';
  echo '<td><div style="display:flex;gap:6px"><button class="btn sm" type="button" onclick="printReceipt('.$oid.')">Print</button>';
  echo '<a class="btnGhost sm" href="'.BASE.'/index.php?page=fnb&amp;view='.$oid.'">Open</a></div></td></tr>';
 }
 echo '</tbody></table>';
}
echo '</div>';

receipt_print('fnb',BASE.'/index.php?page=fnb'.($only?'&outlet='.rawurlencode($only):'').'&act=feed');
page_foot();
