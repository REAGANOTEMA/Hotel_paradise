<?php
declare(strict_types=1);

/*
 * The director's page: the house seen whole.
 *
 * Comprehensive tracking and oversight for CEO/Director. Includes all
 * operations, financials, audits, voice recordings, and real-time monitoring.
 * Voice recordings are strictly restricted to Director-level access only.
 */

$act=$_GET['act']??'';
$u=current_user();

// Voice recorder - only accessible to director and super_admin
$canRecord = has_role('director') || has_role('super_admin');

// Handle voice recording uploads
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $act === 'record' && $canRecord) {
  if (isset($_FILES['audio']) && $_FILES['audio']['error'] === UPLOAD_ERR_OK) {
    $uploadDir = __DIR__ . '/../storage/recordings/';
    if (!is_dir($uploadDir)) {
      mkdir($uploadDir, 0775, true);
    }
    $ext = pathinfo($_FILES['audio']['name'], PATHINFO_EXTENSION);
    if ($ext === '' || !in_array($ext, ['webm', 'mp3', 'wav', 'ogg', 'm4a'])) {
      $ext = 'webm';
    }
    $filename = 'rec_' . date('Ymd_His') . '_' . uniqid() . '.' . $ext;
    $filepath = $uploadDir . $filename;
    if (move_uploaded_file($_FILES['audio']['tmp_name'], $filepath)) {
      $notes = trim($_POST['notes'] ?? '');
      q('INSERT INTO voice_recordings(hotel_id,user_id,filename,original_name,filesize,mime_type,notes,created_at) VALUES(1,?,?,?,?,?,?,NOW())', [
        $u['id'],
        $filename,
        $_FILES['audio']['name'],
        $_FILES['audio']['size'],
        $_FILES['audio']['type'],
        $notes
      ]);
      $rid = (int)db()->lastInsertId();
      audit('record_voice', 'voice_recording', $rid, null, ['filename' => $filename]);
      flash('Voice recording saved securely. Only directors can access this.');
      go('overview');
    } else {
      flash('Failed to save recording.', 'bad');
    }
  } else {
    flash('Recording upload failed.', 'bad');
  }
}

// Delete recording (director only)
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $act === 'delrec' && $canRecord) {
  $rid = (int)($_POST['rid'] ?? 0);
  $rec = row('SELECT * FROM voice_recordings WHERE id=? AND hotel_id=1', [$rid]);
  if ($rec) {
    $uploadDir = __DIR__ . '/../storage/recordings/';
    $filepath = $uploadDir . $rec['filename'];
    if (file_exists($filepath)) {
      @unlink($filepath);
    }
    q('DELETE FROM voice_recordings WHERE id=?', [$rid]);
    audit('delete_voice_recording', 'voice_recording', $rid);
    flash('Recording deleted.');
  }
  go('overview');
}

if($_SERVER['REQUEST_METHOD']==='POST'){
 if(($act??'')==='print'){ go('overview',['order'=>(int)($_POST['oid']??0)]); }
 go('overview');
}

$t=today();
$monthStart=date('Y-m-01');
$yesterday = date('Y-m-d', strtotime('-1 day'));
// Days and the year as half-open ranges so the date columns can use their
// indexes. DATE(created_at)=? and YEAR(created_at)=? force a full scan.
$day0=$t.' 00:00:00';
$day1=date('Y-m-d',strtotime($t.' +1 day')).' 00:00:00';
$yday0=$yesterday.' 00:00:00';
$yday1=$day0;
$year0=date('Y').'-01-01 00:00:00';
$year1=(date('Y')+1).'-01-01 00:00:00';

$k=[
 'today'=>(float)val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=? AND created_at<?",[$day0,$day1]),
 'yesterday'=>(float)val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=? AND created_at<?",[$yday0,$yday1]),
 'month'=>(float)val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=?",[$monthStart.' 00:00:00']),
 'year'=>(float)val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=? AND created_at<?",[$year0,$year1]),
 'orders'=>(int)val('SELECT COUNT(*) FROM orders WHERE created_at>=? AND created_at<?',[$day0,$day1]),
 'orders_yesterday'=>(int)val('SELECT COUNT(*) FROM orders WHERE created_at>=? AND created_at<?',[$yday0,$yday1]),
 'billed'=>(float)val('SELECT COALESCE(SUM(total),0) FROM orders WHERE created_at>=? AND created_at<?',[$day0,$day1]),
 'billed_month'=>(float)val('SELECT COALESCE(SUM(total),0) FROM orders WHERE created_at>=?',[$monthStart.' 00:00:00']),
 'inhouse'=>(int)val("SELECT COUNT(*) FROM rooms WHERE status='occupied'"),
 'rooms'=>(int)val('SELECT COUNT(*) FROM rooms',[]),
 'available'=>(int)val("SELECT COUNT(*) FROM rooms WHERE status='available'"),
 'cleaning'=>(int)val("SELECT COUNT(*) FROM rooms WHERE status='cleaning'"),
 'maintenance'=>(int)val("SELECT COUNT(*) FROM rooms WHERE status='maintenance'"),
 'owed'=>(int)val("SELECT COUNT(*) FROM orders WHERE created_at>=? AND created_at<? AND status IN('pending','accepted','preparing','ready','partially_paid')",[$day0,$day1]),
 'owed_all'=>(int)val("SELECT COUNT(*) FROM orders WHERE status IN('pending','accepted','preparing','ready','partially_paid')",[]),
 'arrivals'=>(int)val("SELECT COUNT(*) FROM reservations WHERE status IN('pending','confirmed') AND check_in>=? AND check_in<?",[$day0,$day1]),
 'departures'=>(int)val("SELECT COUNT(*) FROM reservations WHERE status IN('checked_in','confirmed') AND check_out>=? AND check_out<?",[$day0,$day1]),
 'confirmed'=>(int)val("SELECT COUNT(*) FROM reservations WHERE status='confirmed'",[]),
 'checked_in'=>(int)val("SELECT COUNT(*) FROM reservations WHERE status='checked_in'",[]),
 'expenses_today'=>(float)val("SELECT COALESCE(SUM(amount),0) FROM expenses WHERE created_at>=? AND created_at<?",[$day0,$day1]),
 'expenses_month'=>(float)val("SELECT COALESCE(SUM(amount),0) FROM expenses WHERE created_at>=?",[$monthStart.' 00:00:00']),
 'purchases_month'=>(float)val("SELECT COALESCE(SUM(poi.total),0) FROM purchase_order_items poi INNER JOIN purchase_orders po ON po.id=poi.order_id WHERE po.status IN ('sent','partially_received','received') AND po.created_at>=?",[$monthStart.' 00:00:00']),
 'voids_today'=>(float)val("SELECT COALESCE(SUM(amount),0) FROM voids WHERE created_at>=? AND created_at<?",[$day0,$day1]),
 'unpaid_reservations'=>(float)val("SELECT COALESCE(SUM(total-paid),0) FROM reservations WHERE total>paid AND status IN('confirmed','checked_in','pending')",[]),
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
kpi_card('Revenue today',money($k['today']),'vs ' . money($k['yesterday']) . ' yesterday',$k['today']?'green':'navy');
kpi_card('Revenue this month',money($k['month']),'Since '.$monthStart,'blue');
kpi_card('Revenue this year',money($k['year']),'YTD');
kpi_card('Orders today',(string)$k['orders'],'vs '.$k['orders_yesterday'].' yesterday',($k['orders']>=$k['orders_yesterday'])?'blue':'navy');
kpi_card('In house',(string)$k['inhouse'].' / '.$k['rooms'],'Avail: '.$k['available'].', Clean: '.$k['cleaning'],$k['inhouse']?'gold':'navy');
kpi_card('Occupancy',round($k['rooms']>0?($k['inhouse']/$k['rooms']*100):0,1).'%','Maintenance: '.$k['maintenance']);
kpi_card('Arrivals today',(string)$k['arrivals'],'Expected check-ins',$k['arrivals']?'green':'navy');
kpi_card('Departures today',(string)$k['departures'],'Expected check-outs',$k['departures']?'blue':'navy');
kpi_card('Pending/Active orders',(string)$k['owed_all'],money($k['billed_month']).' billed this month',$k['owed_all']?'gold':'navy');
kpi_card('Unpaid balances',money($k['unpaid_reservations']),'Reservations/orders outstanding',$k['unpaid_reservations']>0?'red':'green');
kpi_card('Expenses this month',money($k['expenses_month']),'+ Purch: '.money($k['purchases_month']));
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
 $d=order_delivery($order);
 if($d['email']) echo '<div class="field" style="margin:0"><label>Email</label><div>'.e($d['email']).'</div></div>';
 if($d['address']) echo '<div class="field" style="margin:0"><label>Deliver to</label><div>'.e($d['address']).'</div></div>';
 if($d['notes']) echo '<div class="field" style="margin:0"><label>Note from guest</label><div>'.e($d['notes']).'</div></div>';
 echo '<div class="field" style="margin:0"><label>Total</label><div><b>'.money($order['total']).'</b> &middot; paid '.money($order['paid']).'</div></div>';
 echo '</div>';

 echo '<div class="twoCol"><div>';
 echo '<h3>What was ordered</h3><table class="tbl"><thead><tr><th>Dish</th><th class="num">Qty</th><th class="num">Unit</th><th class="num">Amount</th></tr></thead><tbody>';
 foreach($order['lines'] as $l){
  $note=prep_note($l['notes']??null);
  echo '<tr><td><b>'.e($l['name']??'Item removed').'</b>'.($note?'<br><small>'.e($note).'</small>':'').'</td>';
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
 if(!count($order['payments'])) echo '<p class="emptyLine">Nothing has been taken against this order yet.</p>';
 else{
  echo '<div class="miniList">';
  foreach($order['payments'] as $p){
   echo '<div class="li"><span>'.e(ucfirst((string)$p['method'])).'<br><small>'.fmtdt($p['created_at']).' &middot; '.e($p['who']??'Website').'</small></span>';
   echo '<b>'.money($p['amount']).'<br><small>'.e($p['status']).'</small></b></div>';
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
 if(!count($who['stays']??[])) echo '<p class="emptyLine">No stays on record.</p>';
 else{
  echo '<table class="tbl"><thead><tr><th>Booking</th><th>Arrive</th><th>Depart</th><th class="num">Total</th><th class="num">Paid</th><th>Status</th></tr></thead><tbody>';
  foreach($who['stays'] as $s){
   echo '<tr><td><b>'.e($s['booking_number']).'</b></td><td>'.fmtdate($s['check_in']).'</td><td>'.fmtdate($s['check_out']).'</td>';
   echo '<td class="num">'.money($s['total']).'</td><td class="num">'.money($s['paid']).'</td><td>'.status_badge($s['status']).'</td></tr>';
  }
  echo '</tbody></table>';
 }
 echo '<h3>Orders</h3>';
 if(!count($who['orders']??[])) echo '<p class="emptyLine">No orders on record.</p>';
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
 if(!count($who['payments']??[])) echo '<p class="emptyLine">Nothing has been taken from this guest yet.</p>';
 else{
  echo '<div class="miniList">';
  foreach($who['payments'] as $p){
   echo '<div class="li"><span>'.e(ucfirst((string)$p['method'])).'<br><small>'.fmtdt($p['created_at']??$p['created_at']).'</small></span><b>'.money($p['amount']).'</b></div>';
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
 echo '<div class="li"><span><b><a href="'.BASE.'/index.php?page=overview&amp;customer='.(int)$c['id'].'">'.e($c['full_name']).'</a></b><br><small>'.e($c['phone']??'').' &middot; '.e($c['email']??'').'</small></span>';
 echo '<b><a class="btnGhost sm" href="'.BASE.'/index.php?page=overview&amp;customer='.(int)$c['id'].'">Open</a></b></div>';
}
echo '</div>';
echo '<h3>Hotel guests</h3><div class="miniList">';
foreach($recentGuests as $g){
 echo '<div class="li"><span><b><a href="'.BASE.'/index.php?page=overview&amp;guest='.(int)$g['id'].'">'.e($g['full_name']).'</a></b><br><small>'.e($g['phone']??'').' &middot; '.e($g['email']??'').'</small></span>';
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
echo '<div class="li"><span>Kitchen screen<br><small>Dockets, printed as orders land</small></span><b><a class="btnGhost sm" href="'.BASE.'/index.php?page=kitchen">Open</a></b></div>';
echo '<div class="li"><span>Food and beverage<br><small>Bills, outlets and payments</small></span><b><a class="btnGhost sm" href="'.BASE.'/index.php?page=fnb">Open</a></b></div>';
echo '<div class="li"><span>Reports<br><small>The ledger behind these numbers</small></span><b><a class="btnGhost sm" href="'.BASE.'/index.php?page=reports">Open</a></b></div>';
echo '</div></div></div></div>';

// Daily comprehensive summary
echo '<div class="panel" style="margin-top:20px">';
echo '<h2>Today\'s Comprehensive Summary</h2>';
echo '<p class="hint">Real-time snapshot of all operations for ' . date('l, j F Y') . '</p>';
echo '<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:16px;margin-top:16px">';
echo '<div style="background:#f8f9fa;padding:14px;border-radius:8px;border:1px solid var(--line)">';
echo '<h3 style="margin:0 0 10px;font-size:14px;color:var(--navy)">Financials</h3>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Cash Received:</span><strong>' . money($k['today']) . '</strong></div>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Expenses:</span><strong>' . money($k['expenses_today']) . '</strong></div>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Voids/Reversals:</span><strong>' . money($k['voids_today']) . '</strong></div>';
echo '</div>';
echo '<div style="background:#f8f9fa;padding:14px;border-radius:8px;border:1px solid var(--line)">';
echo '<h3 style="margin:0 0 10px;font-size:14px;color:var(--navy)">Orders & F&B</h3>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Orders Placed:</span><strong>' . $k['orders'] . '</strong></div>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Billed:</span><strong>' . money($k['billed']) . '</strong></div>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Pending Settlement:</span><strong>' . $k['owed'] . '</strong></div>';
echo '</div>';
echo '<div style="background:#f8f9fa;padding:14px;border-radius:8px;border:1px solid var(--line)">';
echo '<h3 style="margin:0 0 10px;font-size:14px;color:var(--navy)">Rooms & Guests</h3>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Arrivals:</span><strong>' . $k['arrivals'] . '</strong></div>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Departures:</span><strong>' . $k['departures'] . '</strong></div>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Confirmed Bookings:</span><strong>' . $k['confirmed'] . '</strong></div>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Checked In:</span><strong>' . $k['checked_in'] . '</strong></div>';
echo '</div>';
echo '<div style="background:#f8f9fa;padding:14px;border-radius:8px;border:1px solid var(--line)">';
echo '<h3 style="margin:0 0 10px;font-size:14px;color:var(--navy)">Housekeeping</h3>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Occupied:</span><strong>' . $k['inhouse'] . '</strong></div>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Available:</span><strong>' . $k['available'] . '</strong></div>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Cleaning:</span><strong>' . $k['cleaning'] . '</strong></div>';
echo '<div style="display:flex;justify-content:space-between;margin:4px 0;font-size:13px"><span>Maintenance:</span><strong>' . $k['maintenance'] . '</strong></div>';
echo '</div>';
echo '</div>';
echo '</div>';

// Voice recorder section - Director only
if ($canRecord) {
  echo '<div class="panel" style="margin-top:20px">';
  echo '<h2>Voice Recorder - Secure (Director Only)</h2>';
  echo '<p class="hint">Confidential voice recordings for management oversight. These recordings are encrypted at rest and accessible only to directors. Front desk personnel cannot access these recordings.</p>';
  
  echo '<div style="display:flex;gap:20px;flex-wrap:wrap;align-items:flex-start">';
  echo '<div style="flex:1;min-width:300px">';
  echo '<h3 style="margin-bottom:12px;font-size:16px">New Recording</h3>';
  form_open('overview', 'record');
  echo '<div style="background:#f8f9fa;border:1px solid var(--line);border-radius:12px;padding:20px;margin-bottom:16px">';
  echo '<div style="display:flex;gap:12px;align-items:center;margin-bottom:16px;flex-wrap:wrap">';
  echo '<button type="button" id="startRec" class="btn" style="background:#2e7d32">Start Recording</button>';
  echo '<button type="button" id="stopRec" class="btn danger" disabled>Stop Recording</button>';
  echo '<span id="recStatus" style="color:var(--muted);font-size:13px">Ready</span>';
  echo '</div>';
  echo '<audio id="audioPlayback" controls style="width:100%;display:none;margin-bottom:12px"></audio>';
  echo '<div class="field"><label>Notes / Reference</label><textarea name="notes" rows="3" placeholder="e.g. Meeting with supplier, incident report, staff discussion..."></textarea></div>';
  echo '<input type="file" id="audioFile" name="audio" accept="audio/*" style="display:none" required>';
  echo '<button type="submit" id="saveRec" class="btn" disabled>Save Recording</button>';
  echo '</div>';
  form_close();
  echo '</div>';
  
  echo '<div style="flex:1;min-width:300px;max-width:100%">';
  echo '<h3 style="margin-bottom:12px;font-size:16px">Recorded Files</h3>';
  $recordings = rows('SELECT vr.*,u.name recorded_by FROM voice_recordings vr LEFT JOIN users u ON u.id=vr.user_id WHERE vr.hotel_id=1 ORDER BY vr.created_at DESC LIMIT 50');
  if (empty($recordings)) {
    echo '<p style="color:var(--muted);padding:20px;background:#f8f9fa;border-radius:8px">No recordings yet.</p>';
  } else {
    echo '<div style="max-height:400px;overflow-y:auto;border:1px solid var(--line);border-radius:8px">';
    foreach ($recordings as $r) {
      $size = formatBytes($r['filesize']);
      echo '<div style="padding:14px;border-bottom:1px solid var(--line);background:#fff">';
      echo '<div style="display:flex;justify-content:space-between;align-items:flex-start;gap:12px;margin-bottom:8px">';
      echo '<div>';
      echo '<div style="font-weight:600;color:var(--navy);margin-bottom:2px">' . e($r['original_name']) . '</div>';
      echo '<div style="font-size:12px;color:var(--muted)">' . fmtdt($r['created_at']) . ' • by ' . e($r['recorded_by'] ?? '-') . ' • ' . $size . '</div>';
      echo '</div>';
      form_open('overview', 'delrec');
      echo '<input type="hidden" name="rid" value="' . (int)$r['id'] . '">';
      echo '<button class="btn sm danger" onclick="return confirm(\'Delete this recording? This cannot be undone.\')">Delete</button>';
      form_close();
      echo '</div>';
      if ($r['notes']) {
        echo '<div style="font-size:13px;color:var(--navy);margin-bottom:8px;padding:8px;background:#f8f9fa;border-radius:4px">' . nl2br(e($r['notes'])) . '</div>';
      }
      echo '<audio controls style="width:100%"><source src="' . BASE . '/download.php?type=recording&id=' . (int)$r['id'] . '" type="' . e($r['mime_type'] ?: 'audio/webm') . '">Your browser does not support audio playback.</audio>';
      echo '</div>';
    }
    echo '</div>';
  }
  echo '</div>';
  echo '</div>';
  echo '</div>';
  
  // Voice recorder JavaScript
  echo <<<HTML
<script>
(function(){
  let mediaRecorder = null;
  let chunks = [];
  const startBtn = document.getElementById('startRec');
  const stopBtn = document.getElementById('stopRec');
  const saveBtn = document.getElementById('saveRec');
  const recStatus = document.getElementById('recStatus');
  const audioPlayback = document.getElementById('audioPlayback');
  const audioFile = document.getElementById('audioFile');
  
  if (startBtn && navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
    startBtn.addEventListener('click', async () => {
      try {
        const stream = await navigator.mediaDevices.getUserMedia({audio: true});
        mediaRecorder = new MediaRecorder(stream);
        chunks = [];
        mediaRecorder.ondataavailable = (e) => { if (e.data.size > 0) chunks.push(e.data); };
        mediaRecorder.onstop = () => {
          const blob = new Blob(chunks, {type: 'audio/webm'});
          const url = URL.createObjectURL(blob);
          audioPlayback.src = url;
          audioPlayback.style.display = 'block';
          const file = new File([blob], 'recording_' + Date.now() + '.webm', {type: 'audio/webm'});
          const dt = new DataTransfer();
          dt.items.add(file);
          audioFile.files = dt.files;
          saveBtn.disabled = false;
          stream.getTracks().forEach(t => t.stop());
        };
        mediaRecorder.start();
        startBtn.disabled = true;
        stopBtn.disabled = false;
        recStatus.textContent = 'Recording... (only director can access)';
        recStatus.style.color = '#c62828';
        recStatus.style.fontWeight = '600';
      } catch (err) {
        alert('Microphone access denied or not available. ' + err.message);
      }
    });
  } else if (startBtn) {
    startBtn.disabled = true;
    recStatus.textContent = 'Voice recording requires microphone access';
  }
  
  if (stopBtn) {
    stopBtn.addEventListener('click', () => {
      if (mediaRecorder && mediaRecorder.state !== 'inactive') {
        mediaRecorder.stop();
        startBtn.disabled = false;
        stopBtn.disabled = true;
        recStatus.textContent = 'Recording stopped - ready to save';
        recStatus.style.color = 'var(--muted)';
        recStatus.style.fontWeight = 'normal';
      }
    });
  }
})();
</script>
HTML;
}

function formatBytes($bytes, $decimals = 2) {
  if ($bytes == 0) return '0 Bytes';
  $k = 1024;
  $dm = $decimals < 0 ? 0 : $decimals;
  $sizes = ['Bytes', 'KB', 'MB', 'GB'];
  $i = floor(log($bytes, $k));
  return round($bytes / pow($k, $i), $dm) . ' ' . $sizes[$i];
}

receipt_print('overview');
page_foot();
