<?php
declare(strict_types=1);
require __DIR__.'/app/bootstrap.php';
header('Content-Type: application/json; charset=utf-8');

// A public endpoint must never answer with a PHP error page. The website reads
// this as JSON, so an uncaught error would show up as a broken menu rather than
// as the fault it is. Log the detail, return a shape the site can read.
set_exception_handler(function(Throwable $e){
 error_log('[hotel api] '.$e->getMessage().' @ '.$e->getFile().':'.$e->getLine());
 if(!headers_sent()) header('Content-Type: application/json; charset=utf-8');
 http_response_code(500);
 echo json_encode(['ok'=>false,'error'=>'The service is temporarily unavailable. Please call +256 759 504 928.'],JSON_UNESCAPED_UNICODE);
 exit;
});

$out=function(array $data, int $code=200): void{ http_response_code($code); echo json_encode($data,JSON_UNESCAPED_UNICODE); exit; };

/**
 * Tells the console that something real happened. A booking, an order or a
 * payment must never fail because a phone could not be reached, so this wraps
 * the notification in its own guard: the worst a broken notification can do is
 * leave a line in the error log, never an error on a guest's screen.
 */
function api_notify(string $eventKey,string $category,string $title,string $body,array $data=[],array $roles=[]): void{
 try{
  require_once __DIR__.'/app/notify.php';
  notify_dispatch($eventKey,$category,$title,$body,$data,$roles);
 }catch(Throwable $e){
  error_log('[hotel api] notify '.$eventKey.' skipped: '.$e->getMessage());
 }
}

/**
 * The service charge the hotel carries inside every price it publishes.
 *
 * A room rate and a dish price on the site already include it, so the amount a
 * guest reads is the amount a guest owes. What is owed is still shown apart as
 * a line of its own on the receipt, which is what the 3.5% is written into
 * here: the subtotal stays the hotel's figure, the charge sits beside it, and
 * the two of them add to the total. Nothing is charged twice.
 */
const SERVICE_RATE=0.035;

/** What the hotel's 3.5% comes to on top of an amount that excludes it. */
function service_charge(float $amount): float{
 return round($amount*SERVICE_RATE,2);
}

/**
 * Whether a website payment settles itself.
 *
 * Pesapal is not connected yet, so without this a submitted payment would sit
 * as pending until a cashier confirmed it by hand - and the guest would never
 * see a receipt. While this is on, a submitted payment is treated as received
 * the moment it is made, the receipt is produced, and the reference settles.
 * Turn it off the day the real gateway is live.
 */
const PAYMENT_DEMO_SETTLE = true;

/**
 * Some installations were built before the menu tables grew their optional
 * columns. Selecting a column that is not there is a fatal error, which used to
 * take the whole menu down, so a column is only ever asked for once we have
 * confirmed the table really has it.
 */
function table_columns(string $table): array{
 static $cache=[];
 if(isset($cache[$table])) return $cache[$table];
 $have=[];
 try{
  foreach(rows('SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?',[$table]) as $r){
   $have[strtolower((string)$r['COLUMN_NAME'])]=true;
  }
 }catch(Throwable $e){ $have=[]; }
 return $cache[$table]=$have;
}

/** Keeps only the columns this database actually has, in the order given. */
function existing_columns(string $table, array $wanted): array{
 $have=table_columns($table);
 return array_values(array_filter($wanted,fn($c)=>isset($have[strtolower($c)])));
}

/**
 * A stand-in for a column that may not exist, so the shape never changes.
 * The prefix is for queries that join two tables holding the same column name,
 * where an unqualified column is rejected as ambiguous.
 */
function nullable_column(string $table, string $col, string $as, string $prefix=''): string{
  if(!isset(table_columns($table)[strtolower($col)])) return "'' AS $as";
  return ($prefix!==''?$prefix.'.':'').$col." AS $as";
}

/**
 * The fee the hotel adds to every website booking. It is read from the hotel
 * record rather than sent by the browser, so a guest cannot set it, remove it
 * or change it by editing a request. A database that predates the column has
 * no fee to charge and books for the room rate alone.
 */
function booking_withdrawal_fee(): array{
  $fee=0.0; $label='Withdrawal fee';
  $have=table_columns('hotels');
  if(isset($have['booking_withdrawal_fee'])){
   $h=row('SELECT booking_withdrawal_fee, booking_withdrawal_fee_label FROM hotels WHERE id=1');
   if($h){
    $fee=(float)$h['booking_withdrawal_fee'];
    $label=trim((string)$h['booking_withdrawal_fee_label'])!==''?(string)$h['booking_withdrawal_fee_label']:$label;
   }
  }
  return ['label'=>$label,'amount'=>round(max(0.0,$fee),2)];
}


$act=$_GET['act']??'';
$method=$_SERVER['REQUEST_METHOD'];
$read=['rooms','menu','health','checkout'];
if($method!=='GET'&&$method!=='POST'){ $out(['ok'=>false,'error'=>'Method not allowed'],405); }
if($method==='GET'){
 if(!in_array($act,$read)){ $out(['ok'=>false,'error'=>'Method not allowed for this request'],405); }
 $body=$_GET;
}else{
 $body=json_decode(file_get_contents('php://input'),true)?:$_POST;
}

if($act==='health'){
  // Answers which databases the site is actually talking to, so a connection
  // problem can be seen in a browser instead of guessed at. It never reports a
  // host name, a user password, or anything else that should stay private.
  $report=[];
  foreach(['hotel'=>fn()=>db(),'website'=>fn()=>web_db()] as $which=>$open){
    try{
     $pdo=$open();
     $n=(int)$pdo->query('SELECT 1')->fetchColumn();
     $report[$which]=[
      'connected'=>$n===1,
      'database'=>db_label($pdo),
      'menu_items'=>$which==='hotel'?menu_item_count($pdo):null
     ];
    }catch(Throwable $e){
     $report[$which]=['connected'=>false,'database'=>null,'error'=>$e->getMessage()];
    }
  }
  $out(['ok'=>(bool)($report['hotel']['connected']??false),'where'=>$report]);
}

/** How many dishes the website is serving, used only by the health check. */
function menu_item_count(PDO $pdo): ?int{
  try{
   $where=existing_columns('menu_items',['published'])?'published=1':'active=1';
   return (int)$pdo->query('SELECT COUNT(*) FROM menu_items WHERE '.$where)->fetchColumn();
  }catch(Throwable $e){ return null; }
}

if($act==='booking'){
 $name=trim($body['name']??''); $phone=trim($body['phone']??''); $email=trim($body['email']??'');
 $cin=$body['check_in']??''; $cout=$body['check_out']??''; $type=$body['room_type']??''; $adults=(int)($body['adults']??1); $children=(int)($body['children']??0);
 if($name===''||$cin===''||$cout===''){ $out(['ok'=>false,'error'=>'Please provide your name and check in and check out dates.'],422); }
 if($cout<=$cin){ $out(['ok'=>false,'error'=>'Check out must be after check in.'],422); }
 $rt=row('SELECT * FROM room_types WHERE name=? AND active=1',[$type]);
 if(!$rt){ $rt=row('SELECT * FROM room_types WHERE active=1 ORDER BY base_rate LIMIT 1',[]); }
 if(!$rt){ $out(['ok'=>false,'error'=>'No rooms currently available for booking.'],422); }
 $nights=max(1,(int)ceil((strtotime($cout)-strtotime($cin))/86400));
 $gid=null;
 if($email!==''){ $gid=(int)val('SELECT id FROM guests WHERE email=?',[$email]); }
 if(!$gid&&$phone!==''){ $gid=(int)val('SELECT id FROM guests WHERE phone=?',[$phone]); }
 if(!$gid){
  q('INSERT INTO guests(hotel_id,full_name,phone,email,created_at) VALUES(1,?,?,?,NOW())',[$name,$phone,$email]);
  $gid=(int)db()->lastInsertId();
 }
 $num=next_number('HPN','reservations','booking_number');
 $rate=(float)$rt['base_rate']; $subtotal=round($rate*$nights,2);
 // The rate the guest was shown already carries the hotel's 3.5%, so it is
 // added on here as a line of its own rather than a second mark up: the
 // subtotal is the published rate, the charge sits beside it, and together
 // they are what is owed. A database with nowhere to hold the line has no
 // charge to add, and books for the room rate alone.
 $hasTax=(bool)existing_columns('reservations',['tax']);
 $service=$hasTax?service_charge((float)$subtotal):0.0;
 $fee=booking_withdrawal_fee(); $feeAmount=$fee['amount']; $total=round($subtotal+$service+$feeAmount,2);
 $hasFee=(bool)existing_columns('reservations',['withdrawal_fee']);
 // The column list and the placeholders are both built from this one array, so
 // a column can never end up paired with the wrong value. The statement this
 // replaces listed fifteen columns against fourteen values and put the literal
 // 'website' in booking_number, which shifted every later value one column
 // left and made every website booking fail with a 500.
 $ins=['hotel_id'=>1,'guest_id'=>$gid,'booking_number'=>$num,'source'=>'website',
  'check_in'=>$cin.' 14:00:00','check_out'=>$cout.' 11:00:00',
  'adults'=>$adults,'children'=>$children,'status'=>'pending',
  'room_rate'=>$rate,'nights'=>$nights,'subtotal'=>$subtotal,'paid'=>0,'total'=>$total];
 if($hasTax) $ins['tax']=$service;
 if($hasFee) $ins['withdrawal_fee']=$feeAmount;
 $insCols=array_keys($ins);
 q('INSERT INTO reservations('.implode(',',$insCols).',created_at)'
   .' VALUES('.implode(',',array_fill(0,count($insCols),'?')).',NOW())',array_values($ins));
 $rid=(int)db()->lastInsertId();
 q('INSERT INTO reservation_rooms(reservation_id,room_type_id,room_id,quantity,nightly_rate) VALUES(?,?,NULL,1,?)',[$rid,$rt['id'],$rate]);
 api_notify('booking:'.$num,'booking','New website booking '.$num,
  $name.' asked for '.$rt['name'].' for '.$nights.' night'.($nights===1?'':'s').', '.$cin.' to '.$cout.'. Total '.money($total).'.',
  ['booking_number'=>$num,'room_type'=>$rt['name'],'nights'=>$nights,'check_in'=>$cin,'check_out'=>$cout,'total'=>$total,'guest'=>$name,'phone'=>$phone]);
 $out(['ok'=>true,'booking_number'=>$num,'room_type'=>$rt['name'],'nights'=>$nights,
  'subtotal'=>$subtotal,'service_charge'=>$service,'withdrawal_fee'=>$feeAmount,'withdrawal_fee_label'=>$fee['label'],'total'=>$total,
  'message'=>'Your request has been received. Our front desk will confirm availability on the number you provided.']);
}

if($act==='rooms'){
 $rt=rows('SELECT id,name,base_rate FROM room_types WHERE active=1 ORDER BY id');
 $out(['ok'=>true,'booking_fee'=>booking_withdrawal_fee(),
  'rooms'=>array_map(fn($r)=>['id'=>(int)$r['id'],'name'=>$r['name'],'price'=>(float)$r['base_rate'],'rate'=>'UGX '.number_format((float)$r['base_rate'])],$rt)]);
}

if($act==='menu'){
  // Ask for the optional columns only where they exist, and stand in a blank
  // string where they do not, so the response shape is always the same.
  $catCols=existing_columns('menu_categories',['id','outlet','name','eyebrow','blurb','image','sort_order']);
  // Every column in the order by is qualified with the table it belongs to. The
  // dish query joins two tables that both have an id and a sort_order, and an
  // unqualified name there is ambiguous, which the database rejects outright.
  $catOrder=in_array('sort_order',$catCols,true)?'c.sort_order,c.id':'c.id';
  $mcOrder=in_array('sort_order',$catCols,true)?'mc.sort_order,mc.id':'mc.id';

  // "Published" is the question the website asks. "Active" is a different
  // question that the till asks, and the answer is not always the same: a dish
  // can be on the website, sold in the restaurant, or neither, and the two must
  // not be forced to agree. A database from before the split has no published
  // column, so it falls back to selling whatever is active.
  $published=existing_columns('menu_items',['published']);
  $itemWhere=$published?'mi.published=1':'mi.active=1';
  $catWhere=$published?'c.published=1':'1=1';

  $cats=rows('SELECT '.implode(',',array_map(fn($c)=>nullable_column('menu_categories',$c,$c),$catCols))
    .' FROM menu_categories c WHERE '.$catWhere.' ORDER BY '.$catOrder);
  $itemCols=existing_columns('menu_items',['image','group_name','sort_order']);
  $itemOrder=in_array('sort_order',$itemCols,true)?'mi.sort_order,':'';
  $items=rows('SELECT mi.id,mi.name,mi.description,mi.price,mc.id cid,mc.outlet,mc.name cat'
    .','.nullable_column('menu_items','image','image','mi')
    .','.nullable_column('menu_items','group_name','group_name','mi')
    .' FROM menu_items mi JOIN menu_categories mc ON mc.id=mi.category_id'
    .' WHERE '.$itemWhere.' ORDER BY '.$mcOrder.','.$itemOrder.'mi.id');
  $by=[];
  foreach($cats as $c){ $by[$c['id']]=['cid'=>(int)$c['id'],'outlet'=>ucfirst($c['outlet']),'name'=>$c['name'],'eyebrow'=>$c['eyebrow']??'','blurb'=>$c['blurb']??'','image'=>$c['image']??'','items'=>[]]; }
  foreach($items as $i){
   $price=$i['price']===null?null:(float)$i['price'];
   $by[$i['cid']]['items'][]=['id'=>(int)$i['id'],'name'=>$i['name'],'desc'=>$i['description']??'','group'=>$i['group_name']??'','image'=>$i['image']??'','price'=>$price,'rate'=>$price===null?'Price on request':'UGX '.number_format($price)];
  }
  // A section the guest can open but not order from is worse than no section at
  // all, so anything that ended up empty is dropped from the response.
  $out(['ok'=>true,'categories'=>array_values(array_filter($by,fn($c)=>$c['items']!==[]))]);
}

if($act==='order'){
  require_once __DIR__.'/app/menu_extras.php';
  $name=trim((string)($body['name']??''));
  $phone=trim((string)($body['phone']??''));
  $email=trim((string)($body['email']??''));
  $address=trim((string)($body['address']??''));
  $cnotes=trim((string)($body['notes']??''));
  $lines=$body['items']??[];
  if(!is_array($lines)||count($lines)===0){ $out(['ok'=>false,'error'=>'Your order is empty. Add at least one dish first.'],422); }
  if($name===''||$phone===''){ $out(['ok'=>false,'error'=>'Please provide your name and phone number so we can confirm your order.'],422); }
  if($address===''){ $out(['ok'=>false,'error'=>'Please add the address the order is to be delivered to.'],422); }
  $rows=[];
  foreach($lines as $ln){
    $qty=(int)($ln['qty']??1);
    if($qty<1){ continue; }
    // A guest may only order a dish the website is currently offering. The
    // check is on the database row, never on what the browser sent, so a price
    // or a dish that has since been withdrawn cannot be forced through.
    $orderable=existing_columns('menu_items',['published'])?'active=1 AND published=1':'active=1';
    $mi=row('SELECT id,name,price FROM menu_items WHERE id=? AND '.$orderable,[(int)($ln['id']??0)]);
    if(!$mi){ $out(['ok'=>false,'error'=>'One of the dishes is no longer available. Please refresh the menu.'],422); }
    if($mi['price']===null){ $out(['ok'=>false,'error'=>'That dish is priced on request. Please call +256 759 504 928 and the team will price it for you.'],422); }

    // The companion and the salads are priced here, from the keys the guest
    // was shown. An amount sent by the browser is never believed, and a key
    // that is not on the list is simply dropped.
    $comp=menu_extra((string)($ln['companion']??''),MENU_COMPANIONS);
    $sides=[];
    foreach((array)($ln['salads']??[]) as $sk){
      $s=menu_extra((string)$sk,MENU_SALADS);
      if($s){ $sides[]=$s; }
    }
    $compAdd=$comp?menu_extra_add((string)$mi['name'],$comp):0;
    $sidesAdd=0;
    foreach($sides as $s){ $sidesAdd+=menu_extra_add((string)$mi['name'],$s); }
    $unit=(float)$mi['price']+$compAdd+$sidesAdd;

    $notes=[];
    if($comp){ $notes[]='Companion: '.$comp['name']; }
    if($sides){ $notes[]='Also: '.implode(', ',array_column($sides,'name')); }
    $note='Web takeaway order from '.$name.', '.$phone.($notes?' — '.implode('. ',$notes).'.':'');

    $rows[]=['id'=>(int)$mi['id'],'qty'=>$qty,'price'=>$unit,'base'=>(float)$mi['price'],'note'=>$note];
  }
  if(count($rows)===0){ $out(['ok'=>false,'error'=>'Your order is empty. Add at least one dish first.'],422); }
  // The prices the guest read already carry the hotel's 3.5%, so the charge is
  // written apart as the tax line and added once. The total the browser is
  // pointed at for payment is this figure, never the raw sum of the dishes.
  $sub=round((float)array_sum(array_map(fn($r)=>$r['qty']*$r['price'],$rows)),2);
  $service=$sub>0?service_charge($sub):0.0;
  $total=round($sub+$service,2);
  $num=next_number('ORD','orders','order_number');
  // The guest's contact details are written as real columns wherever the
  // database has them, so the kitchen, the front desk and the director's
  // console can read them directly instead of parsing a note. A database that
  // has not yet run the upgrade still takes the order exactly as before: the
  // name and number stay in the line notes, and the extra fields are skipped.
  $detail=['customer_name'=>$name,'customer_phone'=>$phone,'customer_email'=>$email,'delivery_address'=>$address,'delivery_notes'=>$cnotes];
  $cust=[];
  foreach(existing_columns('orders',array_keys($detail)) as $c){ $cust[$c]=$detail[$c]; }
  $cols=['hotel_id','user_id','shift_id','order_number','outlet','order_type','status','subtotal','tax','total'];
  $vals=[1,1,null,$num,'restaurant','takeaway','pending',$sub,$service,$total];
  foreach($cust as $c=>$v){ $cols[]=$c; $vals[]=$v; }
  q('INSERT INTO orders('.implode(',',$cols).',created_at) VALUES('.implode(',',array_fill(0,count($vals),'?')).',NOW())',$vals);
  $oid=(int)db()->lastInsertId();
  foreach($rows as $r){ q('INSERT INTO order_items(order_id,menu_item_id,quantity,unit_price,total,notes) VALUES(?,?,?,?,?,?)',[$oid,$r['id'],$r['qty'],$r['price'],$r['qty']*$r['price'],$r['note']]); }
 audit('web_order','order',$oid,['order_number'=>$num,'subtotal'=>$sub,'service_charge'=>$service,'total'=>$total,'customer'=>$name,'phone'=>$phone,'address'=>$address]);
 api_notify('order:'.$num,'order','New website order '.$num,
  $name.' placed a takeaway order, '.count($rows).' item'.(count($rows)===1?'':'s').', total '.money($total).'.',
  ['order_number'=>$num,'items'=>count($rows),'total'=>$total,'guest'=>$name,'phone'=>$phone,'address'=>$address],
  ['director','general_manager','cashier','kitchen']);
 $out(['ok'=>true,'order_number'=>$num,'subtotal'=>$sub,'service_charge'=>$service,'total'=>$total,'message'=>'Please keep your phone nearby. We will call '.$phone.' to confirm your order and its delivery address.']);
}

/**
 * Records the website guest's intent to pay after a booking or an order.
 *
 * Pesapal is the merchant of record, and its keys are not live yet. Until they
 * are, a payment lands here as pending with the method the guest chose, and the
 * front desk confirms it. The moment the gateway is switched on, this same
 * checkout url and the callback marks the row
 * successful - which is why the docket amount is read from the server first and
 * never trusted from the browser, and method is forced onto an allowlist.
 */
if($act==='payment'){
  $src=trim((string)($body['source']??'')); $ref=trim((string)($body['reference']??''));
  $name=trim((string)($body['name']??'')); $phone=trim((string)($body['phone']??''));
  // The address the guest typed at checkout, so the receipt that follows a
  // confirmed payment has somewhere to go even when the booking or the order
  // was placed without one. It is only ever written onto a record that has no
  // address of its own, so a guest can never overwrite the hotel's own record.
  $email=filter_var(trim((string)($body['email']??'')),FILTER_VALIDATE_EMAIL)?:'';
  $method=strtolower(trim((string)($body['method']??'')));
  if(!in_array($method,['pesapal','mtn_momo','airtel_money','card'],true)){
    $out(['ok'=>false,'error'=>'Please choose a payment method.'],422);
  }
  if($name===''||$phone===''){
    $out(['ok'=>false,'error'=>'Please provide your name and phone number for the receipt.'],422);
  }
  $label=$src==='booking'?'booking':($src==='order'?'order':'');
  if($label===''||$ref===''){ $out(['ok'=>false,'error'=>'Nothing to pay. Please start again from the rooms or the menu.'],422); }

  $rid=null; $oid=null; $expected=0.0; $atDesk=0.0;
  if($src==='booking'){
    $r=row('SELECT id,total,'.nullable_column('reservations','paid','paid').' FROM reservations WHERE booking_number=?',[$ref]);
    if(!$r){ $out(['ok'=>false,'error'=>'We could not find that booking reference. Please call +256 759 504 928.'],404); }
    $rid=(int)$r['id']; $expected=(float)$r['total']; $atDesk=(float)($r['paid']??0);
  }else{
    $o=row('SELECT id,total FROM orders WHERE order_number=?',[$ref]);
    if(!$o){ $out(['ok'=>false,'error'=>'We could not find that order reference. Please call +256 759 504 928.'],404); }
    $oid=(int)$o['id']; $expected=(float)$o['total'];
  }
  // Keep the address on the record it belongs to, but never overwrite a real
  // one: the receipt is built from the booking or the order, so the address has
  // to live there. A database without the order column simply keeps the guests
  // copy as it was.
  if($email!==''){
    try{
      if($oid!==null&&existing_columns('orders',['customer_email'])!==[]){
        q('UPDATE orders SET customer_email=? WHERE id=? AND (customer_email IS NULL OR customer_email=\'\')',[$email,$oid]);
      }
      if($rid!==null){
        q('UPDATE guests g JOIN reservations r ON r.guest_id=g.id SET g.email=? WHERE r.id=? AND (g.email IS NULL OR g.email=\'\')',[$email,$rid]);
      }
    }catch(Throwable $e){
      error_log('[hotel api] could not attach payment email: '.$e->getMessage());
    }
  }
  // What is still owed, not what the reference started at. A booking settled at
  // the front desk and a payment that has already gone through both reduce the
  // figure, so a reference opened twice cannot be charged twice. Only a payment
  // that actually succeeded counts: a request still waiting with the front desk
  // leaves the amount exactly where it was.
  $already=$atDesk+(float)val('SELECT COALESCE(SUM(amount),0) FROM payments WHERE status=\'successful\' AND '
    .($oid!==null?'order_id=?':'reservation_id=?'),[$oid!==null?$oid:$rid]);
  $expected=round(max(0.0,$expected-$already),2);
  if($expected<=0){ $out(['ok'=>false,'error'=>'There is nothing left to pay on this reference. If you think this is wrong, please call +256 759 504 928.'],422); }

  // The signed in guest's id rides along with the payment, so a receipt can be
  // found again from the account. An anonymous payment is still a valid payment.
  $custId=null;
  $cTok=trim((string)($body['token']??''));
  if($cTok!=='' && table_columns('customer_tokens')!==[]){
    $ct=row('SELECT customer_id,expires_at FROM customer_tokens WHERE token_hash=? AND purpose=\'session\'',[hash('sha256',$cTok)]);
    if($ct&&strtotime((string)$ct['expires_at'])>=time()){ $custId=(int)$ct['customer_id']; }
  }

  $payRef=next_number('PAY','payments','provider_reference');
  $paymentCols=existing_columns('payments',['id','hotel_id','user_id','customer_id','invoice_id','order_id','reservation_id','amount','method','provider','provider_reference','status','created_at']);
  $ins=['hotel_id'=>1,'user_id'=>null,'customer_id'=>$custId,'invoice_id'=>null,'order_id'=>$oid,'reservation_id'=>$rid,
    'amount'=>$expected,'method'=>$method,'provider'=>'pesapal','provider_reference'=>$payRef,'status'=>'pending'];
  $ins=array_intersect_key($ins,array_flip($paymentCols));
  $insCols=array_keys($ins);
  q('INSERT INTO payments('.implode(',',$insCols).',created_at)'
    .' VALUES('.implode(',',array_fill(0,count($insCols),'?')).',NOW())',array_values($ins));
  $pid=(int)db()->lastInsertId();
 audit('web_payment','payments',$pid,['provider_reference'=>$payRef,'source'=>$src,'reference'=>$ref,'method'=>$method,'amount'=>$expected,'status'=>'pending']);
 api_notify('payment:'.$payRef,'payment','Payment request '.$payRef,
  $name.' started a '.strtoupper($method).' payment of '.money($expected).' for the '.$label.' '.$ref.'.',
  ['reference'=>$payRef,'source'=>$label,'amount'=>$expected,'method'=>$method,'guest'=>$name,'phone'=>$phone]);
 // No gateway is connected yet, so a payment settles here the moment it is
 // made: the row is marked successful, the receipt is produced, and the
 // reference reads as paid. The guest's own page then prints that receipt.
 if(PAYMENT_DEMO_SETTLE){
  q('UPDATE payments SET status=\'successful\' WHERE id=?',[$pid]);
  require_once __DIR__.'/app/receipts.php';
  $rcpt=receipts_after_payment($pid);
  audit('web_payment_settled','payments',$pid,['provider_reference'=>$payRef,'source'=>$src,'reference'=>$ref,'method'=>$method,'amount'=>$expected,'status'=>'successful']);
  $out(['ok'=>true,'reference'=>$payRef,'amount'=>$expected,'method'=>$method,'gateway'=>'demo','online'=>true,'status'=>'successful','paid'=>true,
    'receipt_sent'=>(bool)($rcpt['email_sent']??false),
    'message'=>'Payment received. Your receipt is ready'.(($rcpt['email_sent']??false)?' and a copy has been emailed to you':'').'.']);
 }
 $out(['ok'=>true,'reference'=>$payRef,'amount'=>$expected,'method'=>$method,'gateway'=>'pesapal','online'=>false,'status'=>'pending','paid'=>false,
    'message'=>'The front desk has your payment request. Pesapal online payment goes live soon - until then nothing is charged here and your '.$label.' is confirmed on '.$phone.'.']);
}

/**
 * What a reference is actually worth, read back from the database.
 *
 * The rooms page and the menu page both hand the guest a checkout url with a
 * reference and an amount in it, and until now the checkout page believed that
 * amount. A reference outlives the page that made it: it is pasted into an
 * email, opened again from the account, or retyped by hand, and the number on
 * the till has to be the hotel's, not the url's. This reads the reservation or
 * the order back with its lines, its dates and anything already paid against
 * it, so what the guest reviews and what the payment records are the same
 * figure. Nothing here identifies the guest: no name and no phone number, so
 * a reference cannot be used to read who made it.
 */
if($act==='checkout'){
  $src=trim((string)($body['src']??$body['source']??''));
  $ref=trim((string)($body['ref']??$body['reference']??''));
  if($ref===''||!in_array($src,['booking','order'],true)){
    $out(['ok'=>false,'error'=>'We could not read that reference. Please start again from the rooms or the menu.'],422);
  }

  // Every payment ever taken against this reference, newest first.
  $payCols=existing_columns('payments',['provider_reference','method','amount','status','created_at']);
  $paymentsFor=function(?int $oid,?int $rid) use($payCols): array{
    $where=[]; $args=[];
    if($oid){ $where[]='order_id=?'; $args[]=$oid; }
    if($rid){ $where[]='reservation_id=?'; $args[]=$rid; }
    if($where===[]) return [];
    $got=rows('SELECT '.implode(',',$payCols).' FROM payments WHERE '.implode(' OR ',$where).' ORDER BY id DESC LIMIT 20',$args);
    return array_map(fn($p)=>[
      'reference'=>(string)($p['provider_reference']??''),
      'method'=>(string)($p['method']??''),
      'amount'=>(float)($p['amount']??0),
      'status'=>(string)($p['status']??''),
      'when'=>substr((string)($p['created_at']??''),0,16)
    ],$got);
  };
  /** What has really settled: only a successful payment reduces what is due. */
  $settled=function(array $payments): float{
    return round(array_sum(array_map(fn($p)=>$p['status']==='successful'?(float)$p['amount']:0.0,$payments)),2);
  };

  if($src==='booking'){
    $r=row('SELECT * FROM reservations WHERE booking_number=?',[$ref]);
    if(!$r){ $out(['ok'=>false,'error'=>'We could not find that booking reference. Please call +256 759 504 928.'],404); }
    $rid=(int)$r['id'];
    $payments=$paymentsFor(null,$rid);
    $total=(float)$r['total'];
    // The front desk records a cash payment against the reservation itself, so
    // the guest is never asked twice for the same night.
    $recorded=existing_columns('reservations',['paid'])?(float)($r['paid']??0):0.0;
    $paid=max($settled($payments),$recorded);
    $rooms=rows('SELECT COALESCE(rt.name,\'Room\') AS name, COALESCE(SUM(rr.quantity),1) AS qty'
      .' FROM reservation_rooms rr LEFT JOIN room_types rt ON rt.id=rr.room_type_id'
      .' WHERE rr.reservation_id=? GROUP BY COALESCE(rt.name,\'Room\') ORDER BY MIN(rr.id)',[$rid]);
    // A family room booked twice reads as one line, not as the same words
    // repeated down the receipt.
    $roomType=implode(' + ',array_map(fn($x)=>(int)$x['qty']>1
      ? trim((string)$x['name']).' × '.(int)$x['qty']
      : trim((string)$x['name']),$rooms));
    $haveFee=existing_columns('reservations',['withdrawal_fee']);
    $out(['ok'=>true,'source'=>'booking','reference'=>(string)$r['booking_number'],'status'=>(string)$r['status'],
      'total'=>$total,'paid'=>round($paid,2),'due'=>round(max(0.0,$total-$paid),2),
      'booking'=>[
        'room_type'=>$roomType,
        'check_in'=>substr((string)$r['check_in'],0,10),
        'check_in_time'=>substr((string)$r['check_in'],11,5),
        'check_out'=>substr((string)$r['check_out'],0,10),
        'check_out_time'=>substr((string)$r['check_out'],11,5),
        'nights'=>(int)$r['nights'],
        'adults'=>(int)($r['adults']??1),
        'children'=>(int)($r['children']??0),
        'subtotal'=>(float)$r['subtotal'],
        'tax'=>(float)$r['tax'],
        'withdrawal_fee'=>$haveFee?(float)($r['withdrawal_fee']??0):null,
        'fee_label'=>booking_withdrawal_fee()['label']
      ],
      'payments'=>$payments]);
  }

  $o=row('SELECT * FROM orders WHERE order_number=?',[$ref]);
  if(!$o){ $out(['ok'=>false,'error'=>'We could not find that order reference. Please call +256 759 504 928.'],404); }
  $oid=(int)$o['id'];
  $payments=$paymentsFor($oid,null);
  $total=(float)$o['total'];
  $lines=rows('SELECT oi.quantity,oi.unit_price,oi.total,oi.notes,mi.name'
    .', '.nullable_column('menu_items','image','image','mi')
    .' FROM order_items oi'
    .' LEFT JOIN menu_items mi ON mi.id=oi.menu_item_id WHERE oi.order_id=? ORDER BY oi.id',[$oid]);
  $items=array_map(function(array $l): array{
    $note=trim((string)($l['notes']??''));
    // The note opens with the guest's name and phone number. The extras after
    // it are worth showing - the companion and the salads were charged for -
    // so the first sentence goes and the rest stays.
    $note=preg_replace('/^Web takeaway order from[^.]*\.\s*/','',$note)??'';
    return ['name'=>(string)($l['name']??'Dish'),'qty'=>(int)$l['quantity'],
      'unit'=>(float)$l['unit_price'],'total'=>(float)$l['total'],
      'image'=>(string)($l['image']??''),'note'=>$note];
  },$lines);
  $paid=$settled($payments);
  $out(['ok'=>true,'source'=>'order','reference'=>(string)$o['order_number'],'status'=>(string)$o['status'],
    'total'=>$total,'paid'=>$paid,'due'=>round(max(0.0,$total-$paid),2),
    'order'=>[
      'outlet'=>(string)$o['outlet'],
      'kind'=>(string)$o['order_type'],
      'table'=>(string)($o['table_name']??''),
      'placed'=>substr((string)($o['created_at']??''),0,16),
      'subtotal'=>(float)$o['subtotal'],
      'tax'=>(float)$o['tax'],
      'items'=>$items
    ],
    'payments'=>$payments]);
}

/**
 * Customer accounts.
 *
 * The guest signs up with an email address and a password, is then asked for a
 * mobile number, or arrives through Google and is asked for a mobile number
 * because Google does not hand one over. Either way the answer to that second
 * question is what the hotel confirms a booking or a payment on, so nothing is
 * usable until it has been given.
 *
 * The browser keeps an opaque token, never the password and never a session id:
 * only its sha256 is stored, so a dump of the table is not a set of logins.
 */
if($act==='account'){

  $action=trim((string)($body['action']??''));

  /** The account tables, which only exist once the upgrade SQL has been run. */
  $ready=(table_columns('customers')!==[] && table_columns('customer_tokens')!==[]);
  if(!$ready && $action!=='config'){
    error_log('[hotel api] customers table missing - database/sql/upgrade/hotelpardise_upgrade.sql has not been run');
    $out(['ok'=>false,'error'=>'Accounts are not available yet on this installation. Please call +256 759 504 928 and the front desk will take your booking.'],503);
  }

  $ip=(string)($_SERVER['REMOTE_ADDR']??'0.0.0.0');
  $normPhone=function(string $p): string{ return preg_replace('/[^\d+]/','',$p)??''; };
  $validPhone=function(string $p) use ($normPhone): bool{ return (bool)preg_match('/^(\+?256|0)7\d{8}$/',$normPhone($p)); };

  $googleClientId=function(): string{
    $v=getenv('HP_GOOGLE_CLIENT_ID');
    if(is_string($v)&&$v!=='') return $v;
    // Read straight from config.php: it is the file the site already trusts with
    // its secrets, and it is not in git.
    $file=__DIR__.'/config.php';
    if(is_readable($file)){
      $c=require $file;
      if(is_array($c)&&isset($c['google_client_id'])&&is_string($c['google_client_id'])) return trim($c['google_client_id']);
    }
    return '';
  };

  $public=function(array $c): array{
    return ['id'=>(int)$c['id'],'name'=>(string)$c['full_name'],'email'=>(string)$c['email'],
      'phone'=>(string)$c['phone'],'google'=>(bool)($c['google_sub']??false)];
  };

  $issue=function(int $cid,string $purpose='session',int $days=30): string{
    $tok=bin2hex(random_bytes(32));
    q('INSERT INTO customer_tokens(customer_id,token_hash,purpose,expires_at) VALUES(?,?,?,DATE_ADD(NOW(), INTERVAL ? DAY))',
      [$cid,hash('sha256',$tok),$purpose,$days]);
    return $tok;
  };

  $fromToken=function(string $tok,string $purpose): ?array{
    if($tok==='') return null;
    $t=row('SELECT * FROM customer_tokens WHERE token_hash=?',[hash('sha256',$tok)]);
    if(!$t) return null;
    if(strtotime((string)$t['expires_at'])<time()) return null;
    if($t['purpose']!==$purpose) return null;
    $c=row('SELECT * FROM customers WHERE id=?',[(int)$t['customer_id']]);
    if(!$c||$c['status']==='closed') return null;
    q('UPDATE customer_tokens SET last_seen_at=NOW() WHERE id=?',[(int)$t['id']]);
    return $c;
  };

  /** Eight wrong passwords in fifteen minutes for one address is enough. */
  $blocked=function(string $email): bool{
    $r=row('SELECT attempts,window_at FROM customer_signin_attempts WHERE ip_address=? AND email=? ORDER BY id DESC LIMIT 1',
      [(string)($_SERVER['REMOTE_ADDR']??''),$email]);
    if(!$r) return false;
    if(strtotime((string)$r['window_at'])<time()-900) return false;
    return (int)$r['attempts']>=8;
  };
  $failed=function(string $email): void{
    $ip=(string)($_SERVER['REMOTE_ADDR']??'');
    $r=row('SELECT id,attempts,window_at FROM customer_signin_attempts WHERE ip_address=? AND email=? ORDER BY id DESC LIMIT 1',[$ip,$email]);
    if($r&&strtotime((string)$r['window_at'])>=time()-900){
      q('UPDATE customer_signin_attempts SET attempts=attempts+1,window_at=NOW() WHERE id=?',[(int)$r['id']]);
    }else{
      q('INSERT INTO customer_signin_attempts(ip_address,email,attempts,window_at) VALUES(?,?,1,NOW())',[$ip,$email]);
    }
  };
  $succeeded=function(string $email): void{
    q('DELETE FROM customer_signin_attempts WHERE ip_address=? AND email=?',
      [(string)($_SERVER['REMOTE_ADDR']??''),$email]);
  };

  /** Asks Google whether this identity token really is who it says it is. */
  $googleVerify=function(string $jwt) use ($googleClientId): ?array{
    $cid=$googleClientId();
    if($cid===''||$jwt==='') return null;
    $ctx=stream_context_create(['http'=>['timeout'=>6,'ignore_errors'=>true,'header'=>"Accept: application/json\r\n"]]);
    $raw=@file_get_contents('https://oauth2.googleapis.com/tokeninfo?id_token='.urlencode($jwt),false,$ctx);
    if($raw===false) return null;
    $d=json_decode($raw,true);
    if(!is_array($d)) return null;
    if(($d['aud']??'')!==$cid) return null;
    if(!in_array($d['iss']??'',['accounts.google.com','https://accounts.google.com'],true)) return null;
    if(isset($d['exp'])&&(int)$d['exp']<time()) return null;
    if(($d['email_verified']??'')!=='true'&&($d['email_verified']??true)!==true) return null;
    if(!isset($d['sub'])||!isset($d['email'])) return null;
    return $d;
  };

  // ---- what the page needs to draw itself
  if($action==='config'){
    $out(['ok'=>true,'google_client_id'=>$googleClientId()]);
  }

  // ---- step one: email, name and password
  if($action==='signup'){
    $name=trim((string)($body['name']??''));
    $email=strtolower(trim((string)($body['email']??'')));
    $pass=(string)($body['password']??'');
    if($name===''||mb_strlen($name)<2){ $out(['ok'=>false,'error'=>'Please enter your full name.'],422); }
    if(!filter_var($email,FILTER_VALIDATE_EMAIL)){ $out(['ok'=>false,'error'=>'Please enter a valid email address, for example you@email.com.'],422); }
    if(strlen($pass)<8){ $out(['ok'=>false,'error'=>'Please choose a password of at least 8 characters.'],422); }

    $existing=row('SELECT * FROM customers WHERE email=?',[$email]);
    if($existing&&$existing['status']!=='pending_phone'){
      $out(['ok'=>false,'error'=>'An account already uses that email address. Please sign in instead.'],409);
    }
    if($existing){
      q('UPDATE customers SET full_name=?,password_hash=?,google_sub=NULL,updated_at=NOW() WHERE id=?',
        [$name,password_hash($pass,PASSWORD_DEFAULT),(int)$existing['id']]);
      $cid=(int)$existing['id'];
    }else{
      q('INSERT INTO customers(hotel_id,full_name,email,password_hash,status,created_at) VALUES(1,?,?,?,\'pending_phone\',NOW())',
        [$name,$email,password_hash($pass,PASSWORD_DEFAULT)]);
      $cid=(int)db()->lastInsertId();
    }
    $reg=$issue($cid,'register',1);
    $out(['ok'=>true,'step'=>'phone','register_token'=>$reg,'name'=>$name,'email'=>$email,
      'message'=>'Your email is set. Now add the mobile number the hotel should confirm your booking and payment on.']);
  }

  // ---- step two: the mobile number, for either way in
  if($action==='phone'){
    $tok=trim((string)($body['register_token']??$body['token']??''));
    $phone=$normPhone(trim((string)($body['phone']??'')));
    if(!$validPhone($phone)){
      $out(['ok'=>false,'error'=>'Please enter a Ugandan mobile number, for example 0759 504 928 or +256 759 504 928.'],422);
    }
    $c=$fromToken($tok,'register');
    if(!$c){ $out(['ok'=>false,'error'=>'That sign up has expired. Please start again.'],410); }
    q('UPDATE customers SET phone=?,status=\'active\',last_login_at=NOW(),updated_at=NOW() WHERE id=?',[$phone,(int)$c['id']]);
    q('DELETE FROM customer_tokens WHERE customer_id=? AND purpose=\'register\'',[(int)$c['id']]);
    $c=row('SELECT * FROM customers WHERE id=?',[(int)$c['id']]);
    $out(['ok'=>true,'token'=>$issue((int)$c['id']),'customer'=>$public($c),
      'message'=>'Your account is ready. Welcome, '.trim((string)$c['full_name']).'.']);
  }

  // ---- password sign in
  if($action==='signin'){
    $email=strtolower(trim((string)($body['email']??'')));
    $pass=(string)($body['password']??'');
    if(!filter_var($email,FILTER_VALIDATE_EMAIL)){ $out(['ok'=>false,'error'=>'Please enter a valid email address.'],422); }
    if($blocked($email)){ $out(['ok'=>false,'error'=>'Too many attempts on this address. Please wait a few minutes, or call +256 759 504 928.'],429); }
    $c=row('SELECT * FROM customers WHERE email=?',[$email]);
    // One sentence for every way this can fail, and none of them says which half
    // was wrong: an address with no account is told to create one, an address
    // that arrived through Google is told how to sign in, and a wrong password
    // is a wrong password.
    if(!$c||$c['status']==='closed'){ $failed($email); $out(['ok'=>false,'error'=>'No account uses that email address yet. Please create one below.'],401); }
    if(($c['google_sub']??'')!==''&&($c['password_hash']??'')===''){ $failed($email); $out(['ok'=>false,'error'=>'That account was created with Google. Please use Continue with Google.'],401); }
    if(!password_verify($pass,(string)$c['password_hash'])){ $failed($email); $out(['ok'=>false,'error'=>'That password is not correct. Please try again.'],401); }
    $succeeded($email);
    if(trim((string)$c['phone'])===''){
      q('UPDATE customers SET last_login_at=NOW() WHERE id=?',[(int)$c['id']]);
      $out(['ok'=>true,'step'=>'phone','register_token'=>$issue((int)$c['id'],'register',1),
        'name'=>(string)$c['full_name'],'email'=>(string)$c['email'],
        'message'=>'One more thing: add the mobile number the hotel should confirm your booking and payment on.']);
    }
    q('UPDATE customers SET last_login_at=NOW() WHERE id=?',[(int)$c['id']]);
    $out(['ok'=>true,'token'=>$issue((int)$c['id']),'customer'=>$public($c)]);
  }

  // ---- Google sign in
  if($action==='google'){
    if($googleClientId()===''){
      $out(['ok'=>false,'error'=>'Sign in with Google is not switched on for this website yet. Please sign in with your email address instead.'],501);
    }
    $cred=trim((string)($body['credential']??''));
    $g=$googleVerify($cred);
    if(!$g){ $out(['ok'=>false,'error'=>'Google could not confirm that sign in. Please try again, or sign in with your email address.'],401); }
    $sub=(string)$g['sub']; $email=strtolower((string)$g['email']);
    $name=trim((string)($g['name']??''));
    $c=row('SELECT * FROM customers WHERE google_sub=?',[$sub]);
    if(!$c){ $c=row('SELECT * FROM customers WHERE email=?',[$email]); }
    if(!$c){
      if($name===''){ $name=explode('@',$email)[0]; }
      q('INSERT INTO customers(hotel_id,full_name,email,google_sub,status,created_at) VALUES(1,?,?,?,\'pending_phone\',NOW())',
        [$name,$email,$sub]);
      $cid=(int)db()->lastInsertId();
    }else{
      $cid=(int)$c['id'];
      if(($c['google_sub']??'')!==$sub){ q('UPDATE customers SET google_sub=?,updated_at=NOW() WHERE id=?',[$sub,$cid]); }
      if($c['status']==='closed'){ $out(['ok'=>false,'error'=>'That account has been closed. Please call +256 759 504 928.'],403); }
    }
    $c=row('SELECT * FROM customers WHERE id=?',[$cid]);
    q('UPDATE customers SET last_login_at=NOW() WHERE id=?',[$cid]);
    if(trim((string)$c['phone'])===''){
      $out(['ok'=>true,'step'=>'phone','register_token'=>$issue($cid,'register',1),
        'name'=>(string)$c['full_name'],'email'=>(string)$c['email'],
        'message'=>'Google knows your email, but not your mobile number. Please add the number the hotel should confirm your booking and payment on.']);
    }
    $out(['ok'=>true,'token'=>$issue($cid),'customer'=>$public($c)]);
  }

  // ---- who am I
  if($action==='me'){
    $c=$fromToken(trim((string)($body['token']??'')),'session');
    if(!$c){ $out(['ok'=>false,'error'=>'Not signed in.'],401); }
    $out(['ok'=>true,'customer'=>$public($c)]);
  }

  // ---- sign out
  if($action==='logout'){
    $tok=trim((string)($body['token']??''));
    if($tok!==''){ q('DELETE FROM customer_tokens WHERE token_hash=?',[hash('sha256',$tok)]); }
    $out(['ok'=>true]);
  }

  $out(['ok'=>false,'error'=>'Unknown account request'],400);
}

/**
 * The website lets a guest ask about an event or a facility. Those rows live
 * in tables that arrived with the site - but a database installed in the field
 * may not have run that step yet. Rather than reject a wedding enquiry with a
 * 500, every write is guarded by a self-healing create: the first real enquiry
 * on an old install makes the table, and every one after finds it waiting.
 */
function ensure_events_tables(): void{
 db()->exec('CREATE TABLE IF NOT EXISTS event_requests(
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  request_number VARCHAR(24) NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  phone VARCHAR(40) NOT NULL,
  email VARCHAR(160) NULL,
  event_type VARCHAR(80) NOT NULL,
  event_date DATE NULL,
  guests INT UNSIGNED NULL,
  venue VARCHAR(80) NULL,
  message TEXT NULL,
  status VARCHAR(20) NOT NULL DEFAULT \'new\',
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY(id),
  UNIQUE KEY uq_event_number(request_number)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
 db()->exec('CREATE TABLE IF NOT EXISTS facility_enquiries(
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  enquiry_number VARCHAR(24) NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  phone VARCHAR(40) NOT NULL,
  email VARCHAR(160) NULL,
  facility VARCHAR(80) NULL,
  preferred_date DATE NULL,
  guests INT UNSIGNED NULL,
  message TEXT NULL,
  status VARCHAR(20) NOT NULL DEFAULT \'new\',
  created_at DATETIME NOT NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY(id),
  UNIQUE KEY uq_enquiry_number(enquiry_number)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
}

/** A date sent by the browser is only ever the shape the site's own field
 *  produces; anything else is dropped, never stored. */
function clean_date(string $d): string{ return preg_match('/^\d{4}-\d{2}-\d{2}$/',$d)==1?$d:''; }

/**
 * A "Plan an event" enquiry from the website. Name and a phone number are the
 * whole contract - everything else is optional because a good events team
 * closes a lead over the phone, not on a form. The team is the one to notice:
 * the row goes straight to the console and the phones of the events, marketing
 * and management roles ring with it.
 */
if($act==='event'){
  ensure_events_tables();
  $name=trim((string)($body['name']??''));
  $phone=trim((string)($body['phone']??''));
  $email=trim((string)($body['email']??''));
  $eve=trim((string)($body['event_type']??''));
  $date=clean_date((string)($body['event_date']??''));
  $guests=(int)($body['guests']??0);
  $venue=trim((string)($body['venue']??''));
  $message=trim((string)($body['message']??''));
  if($name===''||$phone===''){ $out(['ok'=>false,'error'=>'Please provide your name and phone number so our events team can reach you.'],422); }
  $num=next_number('EVT','event_requests','request_number');
  q('INSERT INTO event_requests(hotel_id,request_number,full_name,phone,email,event_type,event_date,guests,venue,message,status,created_at) VALUES(1,?,?,?,?,?,?,?,?,?,\'new\',NOW())',
    [$num,$name,$phone,$email!==''?$email:null,$eve,$date!==''?$date:null,$guests>0?$guests:null,$venue!==''?$venue:null,$message!==''?$message:null]);
  $eid=(int)db()->lastInsertId();
  audit('web_event','event_requests',$eid,['request_number'=>$num,'event_type'=>$eve,'event_date'=>$date,'guests'=>$guests,'venue'=>$venue,'phone'=>$phone]);
  api_notify('event:'.$num,'communication','New event enquiry '.$num,
    $name.' wants to plan '.($eve!==''?mb_strtolower($eve):'an event').' ('.$num.').'.($guests>0?' '.$guests.' guests.':'').($date!==''?(' '.$date.'.'):'').' Please call '.$phone.'.',
    ['request_number'=>$num,'event_type'=>$eve,'event_date'=>$date,'guests'=>$guests,'venue'=>$venue,'name'=>$name,'phone'=>$phone],
    ['director','general_manager','events_manager','marketing']);
  $out(['ok'=>true,'reference'=>$num,
    'message'=>'Thank you, '.$name.'. Our events team will call '.$phone.' and walk you through dates, venues and a menu.']);
}

/**
 * A facilities enquiry from the website, written against the same contract as
 * an event: name and phone, everything else a friendly front desk can earn
 * over a call. Comfort and garden questions are a front desk lead, so it rings
 * there first and is echoed to management so nothing is missed.
 */
if($act==='facility'){
  ensure_events_tables();
  $name=trim((string)($body['name']??''));
  $phone=trim((string)($body['phone']??''));
  $email=trim((string)($body['email']??''));
  $fac=trim((string)($body['facility']??''));
  $date=clean_date((string)($body['date']??''));
  $guests=(int)($body['guests']??0);
  $message=trim((string)($body['message']??''));
  if($name===''||$phone===''){ $out(['ok'=>false,'error'=>'Please provide your name and phone number so the front desk can answer.'],422); }
  $num=next_number('FAQ','facility_enquiries','enquiry_number');
  q('INSERT INTO facility_enquiries(hotel_id,enquiry_number,full_name,phone,email,facility,preferred_date,guests,message,status,created_at) VALUES(1,?,?,?,?,?,?,?,?,\'new\',NOW())',
    [$num,$name,$phone,$email!==''?$email:null,$fac!==''?$fac:null,$date!==''?$date:null,$guests>0?$guests:null,$message!==''?$message:null]);
  $fid=(int)db()->lastInsertId();
  audit('web_enquiry','facility_enquiries',$fid,['enquiry_number'=>$num,'facility'=>$fac,'preferred_date'=>$date,'guests'=>$guests,'phone'=>$phone]);
  api_notify('facility:'.$num,'communication','New facility enquiry '.$num,
    $name.' asked about '.($fac!==''?$fac:'the hotel facilities').' ('.$num.').'.($date!==''?(' '.$date.'.'):'').($guests>0?(' '.$guests.' people.'):'').' Please call '.$phone.'.',
    ['enquiry_number'=>$num,'facility'=>$fac,'preferred_date'=>$date,'guests'=>$guests,'name'=>$name,'phone'=>$phone],
    ['director','general_manager','receptionist','marketing']);
  $out(['ok'=>true,'reference'=>$num,
    'message'=>'Thank you, '.$name.'. The front desk will call '.$phone.' to confirm your visit.']);
}

$out(['ok'=>false,'error'=>'Unknown request'],404);