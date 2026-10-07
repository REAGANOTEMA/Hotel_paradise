<?php
declare(strict_types=1);

/*
 * The director's page: the house seen whole.
 *
 * Two detail views sit on top of it, and both print. The order view is one
 * order from every side - the food, the money taken against it, who placed it.
 * The customer view is one person from every side - what they have stayed in,
 * what they have ordered, what they have paid. The receipt prints itself when
 * either view is opened, once per device, and the buttons reprint it on demand.
 */

$act=$_GET['act']??'';
$u=current_user();

if($_SERVER['REQUEST_METHOD']==='POST'){
 if(($act??'')==='print'){ go('overview',['order'=>(int)($_POST['oid']??0)]); }
 go('overview');
}

$t=today();
$monthStart=date('Y-m-01');

$k=[
 'today'=>(float)val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND DATE(created_at)=?",[$t]),
 'month'=>(float)val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=?",[$monthStart.' 00:00:00']),
 'orders'=>(int)val('SELECT COUNT(*) FROM orders WHERE DATE(created_at)=?',[$t]),
 'billed'=>(float)val('SELECT COALESCE(SUM(total),0) FROM orders WHERE DATE(created_at)=?',[$t]),
 'inhouse'=>(int)val("SELECT COUNT(*) FROM rooms WHERE status='occupied'"),
 'rooms'=>(int)val('SELECT COUNT(*) FROM rooms',[]),
 'owed'=>(int)val("SELECT COUNT(*) FROM orders WHERE DATE(created_at)=? AND status IN('pending','accepted','preparing','ready','partially_paid')",[$t]),
 'arrivals'=>(int)val("SELECT COUNT(*) FROM reservations WHERE status IN('pending','confirmed') AND DATE(check_in)=?",[$t]),
];

/** Everything on one order: the lines, the money, the guest, the takings. */
function order_full(int $id): ?array{
 $o=row("SELECT o.*,(SELECT oi.notes FROM order_items oi WHERE oi.order_id=o.id AND oi.notes<>'' ORDER BY oi.id LIMIT 1) any_notes,
  (SELECT COALESCE(SUM(p.amount),0) FROM payments p WHERE p.order_id=o.id AND p.status='successful') paid,
  u.name taken_by
  FROM orders o LEFT JOIN users u ON u.id=o.user_id WHERE o.id=?",[$id]);
 if(!$o) return null;
 $o['lines']=rows('SELECT oi.quantity,oi.unit_price,oi.total,oi.notes,mi.name FROM order_items oi LEFT JOIN menu_items mi ON mi.id=oi.menu_item_id WHERE oi.order_id=? ORDER BY oi.id',[$id]);
 $o['payments']=rows("SELECT p.amount,p.method,p.status,p.created_at,u.name who FROM payments p LEFT JOIN users u ON u.id=p.user_id WHERE p.order_id=? ORDER BY p.id",[$id]);
 return $o;
}

/** The digits a phone match is made on, so 0772 514 889 finds +256 772514889. */
function phone_key(?string $p): string{
 $d=preg_replace('/\D/','',(string)$p);
 return strlen($d)>9?substr($d,-9):$d;
}

$order=null;$viewOrder=(int)($_GET['order']??0);
if($viewOrder) $order=order_full($viewOrder);

$customer=null;$viewCustomer=(int)($_GET['customer']??0);
$guest=null;$viewGuest=(int)($_GET['guest']??0);
if($viewCustomer){
 $customer=row('SELECT * FROM customers WHERE id=?',[$viewCustomer]);
 if($customer){
  $key=phone_key($customer['phone']);
  $customer['orders']=rows("SELECT o.id,o.order_number,o.outlet,o.status,o.total,o.created_at,
    (SELECT COALESCE(SUM(p.amount),0) FROM payments p WHERE p.order_id=o.id AND p.status='successful') paid,
    (SELECT oi.notes FROM order_items oi WHERE oi.order_id=o.id AND oi.notes<>'' ORDER BY oi.id LIMIT 1) any_notes
    FROM orders o WHERE o.id IN(SELECT order_id FROM payments WHERE customer_id=?)
    OR (SELECT oi.notes FROM order_items oi WHERE oi.order_id=o.id ORDER BY oi.id LIMIT 1) LIKE ?
    ORDER BY o.id DESC LIMIT 25",[$customer['id'],'%'.$key.'%']);
  $customer['payments']=rows('SELECT amount,method,status,created_at,provider_reference FROM payments WHERE customer_id=? ORDER BY id DESC LIMIT 25',[$customer['id']]);
  $customer['stays']=rows("SELECT r.id,r.booking_number,r.check_in,r.check_out,r.status,r.total,
    (SELECT COALESCE(SUM(p.amount),0) FROM payments p WHERE p.reservation_id=r.id AND p.status='successful') paid
    FROM reservations r JOIN guests g ON g.id=r.guest_id
    WHERE REPLACE(REPLACE(REPLACE(g.phone,'+',''),' ',''),'-','') LIKE ? ORDER BY r.id DESC LIMIT 25",['%'.$key.'%']);
 }
}
if($viewGuest){
 $guest=row('SELECT * FROM guests WHERE id=?',[$viewGuest]);
 if($guest){
  $key=phone_key($guest['phone']);
  $guest['stays']=rows("SELECT r.id,r.booking_number,r.check_in,r.check_out,r.status,r.total,
    (SELECT COALESCE(SUM(p.amount),0) FROM payments p WHERE p.reservation_id=r.id AND p.status='successful') paid
    FROM reservations r WHERE r.guest_id=? ORDER BY r.id DESC LIMIT 25",[$guest['id']]);
  $guest['orders']=rows("SELECT o.id,o.order_number,o.outlet,o.status,o.total,o.created_at,
    (SELECT COALESCE(SUM(p.amount),0) FROM payments p WHERE p.order_id=o.id AND p.status='successful') paid,
    (SELECT oi.notes FROM order_items oi WHERE oi.order_id=o.id AND oi.notes<>'' ORDER BY oi.id LIMIT 1) any_notes
    FROM orders o WHERE (SELECT oi.notes FROM order_items oi WHERE oi.order_id=o.id ORDER BY oi.id LIMIT 1) LIKE ?
    ORDER BY o.id DESC LIMIT 25",['%'.$key.'%']);
  $guest['payments']=rows("SELECT p.amount,p.method,p.status,p.created_at FROM payments p WHERE p.customer_id IN (SELECT id FROM customers WHERE phone LIKE ?) ORDER BY p.id DESC LIMIT 25",['%'.$key.'%']);
 }
}

$orders=rows("SELECT o.id,o.order_number,o.outlet,o.order_type,o.status,o.total,o.created_at,
 (SELECT COALESCE(SUM(p.amount),0) FROM payments p WHERE p.order_id=o.id AND p.status='successful') paid,
 (SELECT oi.notes FROM order_items oi WHERE oi.order_id=o.id AND oi.notes<>'' ORDER BY oi.id LIMIT 1) any_notes
 FROM orders o ORDER BY o.id DESC LIMIT 20");

$recentCustomers=rows('SELECT id,full_name,phone,email,created_at FROM customers ORDER BY id DESC LIMIT 12');
$recentGuests=rows('SELECT id,full_name,phone,email,created_at FROM guests ORDER BY id DESC LIMIT 12');

/* ------------------------------------------------------------------ the paper */

if($order){
 $g=order_customer($order['any_notes']??null);
 $ls=[];
 foreach($order['lines'] as $l){
  $ls[]=['name'=>(string)($l['name']??'Item removed'),
   'qty'=>rtrim(rtrim(number_format((float)$l['quantity'],2,'.',''),'0'),'.'),
   'note'=>prep_note($l['notes']??null),
   'amount'=>money($l['total'])];
 }
 $t=[['Subtotal',money($order['subtotal'])]];
 if((float)$order['tax']>0) $t[]=['Service charge (3.5%)',money($order['tax'])];
 if((float)$order['discount']>0) $t[]=['Discount','-'.money($order['discount'])];
 $t[]=['Total',money($order['total']),'big'];
 if((float)$order['paid']>0){
  $t[]=['Paid',money($order['paid'])];
  if((float)$order['paid']+0.001<(float)$order['total']) $t[]=['Balance due',money((float)$order['total']-(float)$order['paid']),'big'];
 }
 receipt_template('order-'.$order['id'],receipt_sheet([
  'kind'=>'ORDER RECEIPT',
  'number'=>(string)$order['order_number'],
  'meta'=>[
   'Outlet'=>ucfirst((string)$order['outlet']),
   'Service'=>$order['order_type']==='room'?'Room service':ucfirst((string)$order['order_type']),
   'Table or room'=>(string)$order['table_name'],
   'Opened'=>fmtdt($order['created_at']),
   'Guest'=>$g['name']??'Counter order',
   'Phone'=>$g['phone']??'',
   'Taken by'=>(string)($order['taken_by']??''),
  ],
  'lines'=>$ls,
  'totals'=>$t,
  'foot'=>'Status: '.str_replace('_',' ',(string)$order['status'])
 ]),true);
}

$who=$customer?:$guest;
if($who){
 $name=(string)$who['full_name'];
 $stays=$who['stays']??[];
 $myOrders=$who['orders']??[];
 $pays=$who['payments']??[];
 $billed=array_sum(array_map(static fn(array $r): float=>(float)$r['total'],array_merge($stays,$myOrders)));
 $taken=array_sum(array_map(static fn(array $r): float=>(float)($r['paid']??0),array_merge($stays,$myOrders)));
 $ls=[];
 foreach($stays as $s){
  $ls[]=['name'=>'Stay '.$s['booking_number'],'qty'=>'','note'=>fmtdate($s['check_in']).' to '.fmtdate($s['check_out']).' · '.str_replace('_',' ',$s['status']),'amount'=>money($s['total'])];
 }
 foreach($myOrders as $o){
  $c=order_customer($o['any_notes']??null);
  $ls[]=['name'=>'Order '.$o['order_number'],'qty'=>'','note'=>fmtdate($o['created_at']).' · '.ucfirst((string)$o['outlet']).($c?' · '.$c['name']:''),'amount'=>money($o['total'])];
 }
 if(!$ls) $ls[]=['name'=>'Nothing booked or ordered yet','qty'=>'','note'=>'','amount'=>null];
 receipt_template('who-'.($customer?'c':'g').$who['id'],receipt_sheet([
  'kind'=>'GUEST STATEMENT',
  'number'=>$name,
  'meta'=>[
   'Phone'=>(string)($who['phone']??''),
   'Email'=>(string)($who['email']??''),
   'Guest since'=>fmtdate($who['created_at']??null),
   'Stays'=>count($stays),
   'Orders'=>count($myOrders),
  ],
  'lines'=>$ls,
  'totals'=>[['Billed',money($billed)],['Paid',money($taken)],['Balance',money(max(0,$billed-$taken)),'big']],
  'foot'=>'Statement as at '.date('d M Y H:i')
 ]),true);
}

/* ------------------------------------------------------------------ the screen */

page_head('CEO / Director','overview',date('l, j F Y'));

echo '<div class="kpis">';
kpi_card('Revenue today',money($k['today']),'Payments taken',$k['today']?'green':'navy');
kpi_card('Revenue this month',money($k['month']),'Since '.$monthStart);
kpi_card('Orders today',(string)$k['orders'],money($k['billed']).' billed');
kpi_card('Still to settle',(string)$k['owed'],'Orders not paid in full',$k['owed']?'gold':'navy');
kpi_card('In house',(string)$k['inhouse'],'Of '.$k['rooms'].' rooms');
kpi_card('Arrivals today',(string)$k['arrivals'],'Expected check ins');
echo '</div>';

/* --------------------------------------------------------------- order view */

if($order){
 $g=order_customer($order['any_notes']??null);
 echo '<div class="panel"><div class="toolbar" style="margin-bottom:14px">';
 echo '<div><h2>Order '.e($order['order_number']).'</h2><p class="hint" style="margin:0">'.fmtdt($order['created_at']).' &middot; '.e(ucfirst((string)$order['outlet'])).' &middot; '.status_badge($order['status']).'</p></div>';
 echo '<div class="bar"><button class="btn sm" type="button" onclick="printReceipt(\'order-'.(int)$order['id'].'\')">Print receipt</button>';
 echo '<a class="btnGhost sm" href="'.BASE.'/index.php?page=overview">Close</a></div></div>';

 echo '<div class="res-meta" style="margin-bottom:16px">';
 echo '<div class="field" style="margin:0"><label>Guest</label><div>'.e($g['name']??'Counter order').'</div></div>';
 if($g) echo '<div class="field" style="margin:0"><label>Phone</label><div><a href="'.BASE.'/index.php?page=overview&amp;customer='.(int)(val('SELECT id FROM customers WHERE phone LIKE ?',['%'.phone_key($g['phone']).'%'])?:0).'">'.e($g['phone']).'</a></div></div>';
 echo '<div class="field" style="margin:0"><label>Taken by</label><div>'.e($order['taken_by']??'Website').'</div></div>';
 echo '<div class="field" style="margin:0"><label>Total</label><div><b>'.money($order['total']).'</b> &middot; paid '.money($order['paid']).'</div></div>';
 echo '</div>';

 echo '<div class="twoCol"><div>';
 echo '<h3>What was ordered</h3><table class="tbl"><thead><tr><th>Dish</th><th class="num">Qty</th><th class="num">Unit</th><th class="num">Amount</th></tr></thead><tbody>';
 foreach($order['lines'] as $l){
  $note=prep_note($l['notes']??null);
  echo '<tr><td><b>'.e($l['name']??'Item removed').'</b>'.($note?'<br><small style="color:var(--muted)">'.e($note).'</small>':'').'</td>';
  echo '<td class="num">'.rtrim(rtrim(number_format((float)$l['quantity'],2,'.',''),'0'),'.').'</td><td class="num">'.money($l['unit_price']).'</td><td class="num">'.money($l['total']).'</td></tr>';
 }
 echo '</tbody></table>';
 echo '<div class="totals" style="max-width:320px;margin-left:auto">';
 echo '<div class="tt"><span>Subtotal</span><b>'.money($order['subtotal']).'</b></div>';
 if((float)$order['tax']>0) echo '<div class="tt" style="font-size:13px;font-weight:600"><span>Service charge (3.5%)</span><b>'.money($order['tax']).'</b></div>';
 echo '<div class="tt" style="font-size:18px"><span>Total</span><b>'.money($order['total']).'</b></div>';
 echo '<div class="tt" style="font-size:13px;color:#2e7d32"><span>Paid</span><b>'.money($order['paid']).'</b></div>';
 echo '</div></div>';

 echo '<div>';
 echo '<h3>Payments against it</h3>';
 if(!count($order['payments'])) echo '<p style="color:var(--muted)">Nothing has been taken against this order yet.</p>';
 else{
  echo '<div class="miniList">';
  foreach($order['payments'] as $p){
   echo '<div class="li"><span>'.e(ucfirst((string)$p['method'])).'<br><small style="color:var(--muted)">'.fmtdt($p['created_at']).' &middot; '.e($p['who']??'Website').'</small></span>';
   echo '<b>'.money($p['amount']).'<br><small style="color:var(--muted)">'.e($p['status']).'</small></b></div>';
  }
  echo '</div>';
 }
 echo '<h3>Keep it</h3><p class="hint">The receipt prints by itself when this view is opened, and the button prints it again as often as needed.</p>';
 echo '</div></div></div>';
}

/* ------------------------------------------------------------- customer view */

if($who){
 $isC=($customer!==null);
 echo '<div class="panel"><div class="toolbar" style="margin-bottom:14px">';
 echo '<div><h2>'.e($who['full_name']).'</h2><p class="hint" style="margin:0">'.($isC?'Website customer':'Hotel guest').' &middot; guest since '.fmtdate($who['created_at']).'</p></div>';
 echo '<div class="bar"><button class="btn sm" type="button" onclick="printReceipt(\'who-'.($isC?'c':'g').(int)$who['id'].'\')">Print statement</button>';
 echo '<a class="btnGhost sm" href="'.BASE.'/index.php?page=overview">Close</a></div></div>';

 echo '<div class="res-meta" style="margin-bottom:16px">';
 echo '<div class="field" style="margin:0"><label>Phone</label><div>'.e($who['phone']??'Not given').'</div></div>';
 echo '<div class="field" style="margin:0"><label>Email</label><div>'.e($who['email']??'Not given').'</div></div>';
 echo '<div class="field" style="margin:0"><label>Stays</label><div>'.count($who['stays']??[]).'</div></div>';
 echo '<div class="field" style="margin:0"><label>Orders</label><div>'.count($who['orders']??[]).'</div></div>';
 echo '</div>';

 echo '<div class="twoCol"><div>';
 echo '<h3>Stays</h3>';
 if(!count($who['stays']??[])) echo '<p style="color:var(--muted)">No stays on record.</p>';
 else{
  echo '<table class="tbl"><thead><tr><th>Booking</th><th>Arrive</th><th>Depart</th><th class="num">Total</th><th class="num">Paid</th><th>Status</th></tr></thead><tbody>';
  foreach($who['stays'] as $s){
   echo '<tr><td><b>'.e($s['booking_number']).'</b></td><td>'.fmtdate($s['check_in']).'</td><td>'.fmtdate($s['check_out']).'</td>';
   echo '<td class="num">'.money($s['total']).'</td><td class="num">'.money($s['paid']).'</td><td>'.status_badge($s['status']).'</td></tr>';
  }
  echo '</tbody></table>';
 }
 echo '<h3>Orders</h3>';
 if(!count($who['orders']??[])) echo '<p style="color:var(--muted)">No orders on record.</p>';
 else{
  echo '<table class="tbl"><thead><tr><th>Order</th><th>Date</th><th>Outlet</th><th class="num">Total</th><th class="num">Paid</th><th></th></tr></thead><tbody>';
  foreach($who['orders'] as $o){
   echo '<tr><td><b><a href="'.BASE.'/index.php?page=overview&amp;order='.(int)$o['id'].'">'.e($o['order_number']).'</a></b></td>';
   echo '<td>'.fmtdate($o['created_at']).'</td><td>'.e(ucfirst((string)$o['outlet'])).'</td>';
   echo '<td class="num">'.money($o['total']).'</td><td class="num">'.money($o['paid']).'</td>';
   echo '<td><a class="btnGhost sm" href="'.BASE.'/index.php?page=overview&amp;order='.(int)$o['id'].'">Open</a></td></tr>';
  }
  echo '</tbody></table>';
 }
 echo '</div><div>';
 echo '<h3>Payments</h3>';
 if(!count($who['payments']??[])) echo '<p style="color:var(--muted)">Nothing has been taken from this guest yet.</p>';
 else{
  echo '<div class="miniList">';
  foreach($who['payments'] as $p){
   echo '<div class="li"><span>'.e(ucfirst((string)$p['method'])).'<br><small style="color:var(--muted)">'.fmtdt($p['created_at']??$p['created_at']).'</small></span><b>'.money($p['amount']).'</b></div>';
  }
  echo '</div>';
 }
 echo '</div></div></div>';
}

/* ------------------------------------------------------------------ the lists */

echo '<div class="dashGrid"><div>';
echo '<div class="panel"><h2>Latest orders</h2><p class="hint">Every order the system holds, newest first. Open one for its full detail and receipt.</p>';
echo '<table class="tbl"><thead><tr><th>Order</th><th>Placed</th><th>Guest</th><th>Outlet</th><th class="num">Total</th><th class="num">Paid</th><th>Status</th></tr></thead><tbody>';
foreach($orders as $o){
 $g=order_customer($o['any_notes']??null);
 echo '<tr><td><b><a href="'.BASE.'/index.php?page=overview&amp;order='.(int)$o['id'].'">'.e($o['order_number']).'</a></b></td>';
 echo '<td>'.fmtdt($o['created_at']).'</td><td>'.e($g['name']??'Counter').'</td><td>'.e(ucfirst((string)$o['outlet'])).'</td>';
 echo '<td class="num">'.money($o['total']).'</td><td class="num">'.money($o['paid']).'</td><td>'.status_badge($o['status']).'</td></tr>';
}
echo '</tbody></table></div>';

echo '<div class="panel"><h2>Customer detail</h2><p class="hint">Website accounts and guests of the house. Open either for stays, orders and payments, with a printable statement.</p>';
echo '<h3>Website customers</h3><div class="miniList">';
foreach($recentCustomers as $c){
 echo '<div class="li"><span><b><a href="'.BASE.'/index.php?page=overview&amp;customer='.(int)$c['id'].'">'.e($c['full_name']).'</a></b><br><small style="color:var(--muted)">'.e($c['phone']??'').' &middot; '.e($c['email']??'').'</small></span>';
 echo '<b><a class="btnGhost sm" href="'.BASE.'/index.php?page=overview&amp;customer='.(int)$c['id'].'">Open</a></b></div>';
}
echo '</div>';
echo '<h3>Hotel guests</h3><div class="miniList">';
foreach($recentGuests as $g){
 echo '<div class="li"><span><b><a href="'.BASE.'/index.php?page=overview&amp;guest='.(int)$g['id'].'">'.e($g['full_name']).'</a></b><br><small style="color:var(--muted)">'.e($g['phone']??'').' &middot; '.e($g['email']??'').'</small></span>';
 echo '<b><a class="btnGhost sm" href="'.BASE.'/index.php?page=overview&amp;guest='.(int)$g['id'].'">Open</a></b></div>';
}
echo '</div></div></div>';

echo '<div>';
echo '<div class="panel"><h2>Money today</h2><p class="hint">What the house has taken, and what it is still owed.</p>';
echo '<div class="miniList">';
echo '<div class="li"><span>Payments taken</span><b>'.money($k['today']).'</b></div>';
echo '<div class="li"><span>Orders billed</span><b>'.money($k['billed']).'</b></div>';
echo '<div class="li"><span>Orders not settled</span><b>'.(int)$k['owed'].'</b></div>';
echo '<div class="li"><span>Rooms in house</span><b>'.(int)$k['inhouse'].' of '.(int)$k['rooms'].'</b></div>';
echo '</div></div>';

echo '<div class="panel"><h2>On the boards</h2><p class="hint">Where the detail lives.</p><div class="miniList">';
echo '<div class="li"><span>Kitchen screen<br><small style="color:var(--muted)">Dockets, printed as orders land</small></span><b><a class="btnGhost sm" href="'.BASE.'/index.php?page=kitchen">Open</a></b></div>';
echo '<div class="li"><span>Food and beverage<br><small style="color:var(--muted)">Bills, outlets and payments</small></span><b><a class="btnGhost sm" href="'.BASE.'/index.php?page=fnb">Open</a></b></div>';
echo '<div class="li"><span>Reports<br><small style="color:var(--muted)">The ledger behind these numbers</small></span><b><a class="btnGhost sm" href="'.BASE.'/index.php?page=reports">Open</a></b></div>';
echo '</div></div></div></div>';

receipt_print('overview');
page_foot();
