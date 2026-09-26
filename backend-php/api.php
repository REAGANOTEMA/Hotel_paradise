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

/** A stand-in for a column that may not exist, so the shape never changes. */
function nullable_column(string $table, string $col, string $as): string{
 return isset(table_columns($table)[strtolower($col)]) ? "$col AS $as" : "'' AS $as";
}

$act=$_GET['act']??'';
$method=$_SERVER['REQUEST_METHOD'];
$read=['rooms','menu'];
if($method!=='GET'&&$method!=='POST'){ $out(['ok'=>false,'error'=>'Method not allowed'],405); }
if($method==='GET'){
 if(!in_array($act,$read)){ $out(['ok'=>false,'error'=>'Method not allowed for this request'],405); }
 $body=$_GET;
}else{
 $body=json_decode(file_get_contents('php://input'),true)?:$_POST;
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
 $rate=(float)$rt['base_rate']; $total=$rate*$nights;
 q('INSERT INTO reservations(hotel_id,guest_id,booking_number,source,check_in,check_out,adults,children,status,room_rate,nights,subtotal,paid,total,created_at) VALUES(1,?,?,\'website\',?,?,?,?,\'pending\',?,?,?,0,?,NOW())',
   [$gid,$num,$cin.' 14:00:00',$cout.' 11:00:00',$adults,$children,$rate,$nights,$total,$total]);
 $rid=(int)db()->lastInsertId();
 q('INSERT INTO reservation_rooms(reservation_id,room_type_id,room_id,quantity,nightly_rate) VALUES(?,?,NULL,1,?)',[$rid,$rt['id'],$rate]);
 $out(['ok'=>true,'booking_number'=>$num,'room_type'=>$rt['name'],'nights'=>$nights,'total'=>$total,'message'=>'Your request has been received. Our front desk will confirm availability on the number you provided.']);
}

if($act==='rooms'){
 $rt=rows('SELECT id,name,base_rate FROM room_types WHERE active=1 ORDER BY id');
 $out(['ok'=>true,'rooms'=>array_map(fn($r)=>['id'=>(int)$r['id'],'name'=>$r['name'],'price'=>(float)$r['base_rate'],'rate'=>'UGX '.number_format((float)$r['base_rate'])],$rt)]);
}

if($act==='menu'){
  // Ask for the optional columns only where they exist, and stand in a blank
  // string where they do not, so the response shape is always the same.
  $catCols=existing_columns('menu_categories',['id','outlet','name','eyebrow','blurb','image','sort_order']);
  $catOrder=in_array('sort_order',$catCols,true)?'sort_order,id':'id';
  $cats=rows('SELECT '.implode(',',array_map(fn($c)=>nullable_column('menu_categories',$c,$c),$catCols)).' FROM menu_categories ORDER BY '.$catOrder);
  $itemCols=existing_columns('menu_items',['image','group_name','sort_order']);
  $itemOrder=in_array('sort_order',$itemCols,true)?'mi.sort_order,':'';
  $items=rows('SELECT mi.id,mi.name,mi.description,mi.price,mc.id cid,mc.outlet,mc.name cat'
    .','.nullable_column('menu_items','image','image')
    .','.nullable_column('menu_items','group_name','group_name')
    .' FROM menu_items mi JOIN menu_categories mc ON mc.id=mi.category_id'
    .' WHERE mi.active=1 ORDER BY mc.'.$catOrder.','.$itemOrder.'mi.id');
  $by=[];
  foreach($cats as $c){ $by[$c['id']]=['cid'=>(int)$c['id'],'outlet'=>ucfirst($c['outlet']),'name'=>$c['name'],'eyebrow'=>$c['eyebrow']??'','blurb'=>$c['blurb']??'','image'=>$c['image']??'','items'=>[]]; }
  foreach($items as $i){
   $price=$i['price']===null?null:(float)$i['price'];
   $by[$i['cid']]['items'][]=['id'=>(int)$i['id'],'name'=>$i['name'],'desc'=>$i['description']??'','group'=>$i['group_name']??'','image'=>$i['image']??'','price'=>$price,'rate'=>$price===null?'Price on request':'UGX '.number_format($price)];
  }
  $out(['ok'=>true,'categories'=>array_values($by)]);
}

if($act==='order'){
 $name=trim($body['name']??''); $phone=trim($body['phone']??'');
 $lines=$body['items']??[];
 if(!is_array($lines)||count($lines)===0){ $out(['ok'=>false,'error'=>'Your order is empty. Add at least one dish first.'],422); }
 if($name===''||$phone===''){ $out(['ok'=>false,'error'=>'Please provide your name and phone number so we can confirm your order.'],422); }
 $rows=[];
 foreach($lines as $ln){
  $qty=(int)($ln['qty']??1);
  if($qty<1){ continue; }
  $mi=row('SELECT id,price FROM menu_items WHERE id=? AND active=1',[(int)($ln['id']??0)]);
  if(!$mi){ $out(['ok'=>false,'error'=>'One of the dishes is no longer available. Please refresh the menu.'],422); }
  if($mi['price']===null){ $out(['ok'=>false,'error'=>'That dish is priced on request. Please call +256 759 504 928 and the team will price it for you.'],422); }
  $rows[]=['id'=>(int)$mi['id'],'qty'=>$qty,'price'=>(float)$mi['price']];
 }
 if(count($rows)===0){ $out(['ok'=>false,'error'=>'Your order is empty. Add at least one dish first.'],422); }
 $sub=array_sum(array_map(fn($r)=>$r['qty']*$r['price'],$rows));
 $num=next_number('ORD','orders','order_number');
 q('INSERT INTO orders(hotel_id,user_id,shift_id,order_number,outlet,order_type,status,subtotal,tax,total,created_at) VALUES(1,1,NULL,?,\'restaurant\',\'takeaway\',\'pending\',?,0,?,NOW())',[$num,$sub,$sub]);
 $oid=(int)db()->lastInsertId();
 foreach($rows as $r){ q('INSERT INTO order_items(order_id,menu_item_id,quantity,unit_price,total,notes) VALUES(?,?,?,?,?,?)',[$oid,$r['id'],$r['qty'],$r['price'],$r['qty']*$r['price'],'Web takeaway order from '.$name.', '.$phone]); }
 audit('web_order','order',$oid,['order_number'=>$num,'subtotal'=>$sub]);
 $out(['ok'=>true,'order_number'=>$num,'total'=>$sub,'message'=>'Please keep your phone nearby. We will call '.$phone.' to confirm collection and payment.']);
}

$out(['ok'=>false,'error'=>'Unknown request'],404);