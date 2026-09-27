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
$read=['rooms','menu','health'];
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
 $fee=booking_withdrawal_fee(); $feeAmount=$fee['amount']; $total=round($subtotal+$feeAmount,2);
 $hasFee=(bool)existing_columns('reservations',['withdrawal_fee']);
 q('INSERT INTO reservations(hotel_id,guest_id,booking_number,source,check_in,check_out,adults,children,status,room_rate,nights,subtotal,paid,total'.($hasFee?',withdrawal_fee':'').',created_at) VALUES(1,?,?,\'website\',?,?,?,?,\'pending\',?,?,?,0,?'.($hasFee?',':'').',NOW())',
  [$gid,$num,$cin.' 14:00:00',$cout.' 11:00:00',$adults,$children,$rate,$nights,$subtotal,$total,$feeAmount]);
 $rid=(int)db()->lastInsertId();
 q('INSERT INTO reservation_rooms(reservation_id,room_type_id,room_id,quantity,nightly_rate) VALUES(?,?,NULL,1,?)',[$rid,$rt['id'],$rate]);
 $out(['ok'=>true,'booking_number'=>$num,'room_type'=>$rt['name'],'nights'=>$nights,
  'subtotal'=>$subtotal,'withdrawal_fee'=>$feeAmount,'withdrawal_fee_label'=>$fee['label'],'total'=>$total,
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
  $name=trim($body['name']??''); $phone=trim($body['phone']??'');
  $lines=$body['items']??[];
  if(!is_array($lines)||count($lines)===0){ $out(['ok'=>false,'error'=>'Your order is empty. Add at least one dish first.'],422); }
  if($name===''||$phone===''){ $out(['ok'=>false,'error'=>'Please provide your name and phone number so we can confirm your order.'],422); }
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
  $sub=array_sum(array_map(fn($r)=>$r['qty']*$r['price'],$rows));
  $num=next_number('ORD','orders','order_number');
  q('INSERT INTO orders(hotel_id,user_id,shift_id,order_number,outlet,order_type,status,subtotal,tax,total,created_at) VALUES(1,1,NULL,?,\'restaurant\',\'takeaway\',\'pending\',?,0,?,NOW())',[$num,$sub,$sub]);
  $oid=(int)db()->lastInsertId();
  foreach($rows as $r){ q('INSERT INTO order_items(order_id,menu_item_id,quantity,unit_price,total,notes) VALUES(?,?,?,?,?,?)',[$oid,$r['id'],$r['qty'],$r['price'],$r['qty']*$r['price'],$r['note']]); }
  audit('web_order','order',$oid,['order_number'=>$num,'subtotal'=>$sub]);
  $out(['ok'=>true,'order_number'=>$num,'total'=>$sub,'message'=>'Please keep your phone nearby. We will call '.$phone.' to confirm collection and payment.']);
}

$out(['ok'=>false,'error'=>'Unknown request'],404);