<?php
declare(strict_types=1);

require_once __DIR__.'/notify.php';

function kds_ensure_schema(): void{
 static $done=false;
 if($done) return;
 try{
  q("CREATE TABLE IF NOT EXISTS kitchen_stations(
   id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
   hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
   code VARCHAR(20) NOT NULL,
   name VARCHAR(120) NOT NULL,
   color VARCHAR(20) NOT NULL DEFAULT '#0B5D78',
   printer_key VARCHAR(80) NULL,
   sort_order INT NOT NULL DEFAULT 0,
   active TINYINT(1) NOT NULL DEFAULT 1,
   PRIMARY KEY(id), UNIQUE KEY uniq_kds_station_code(hotel_id,code)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
  q("CREATE TABLE IF NOT EXISTS kitchen_order_items(
   id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
   order_item_id BIGINT UNSIGNED NOT NULL,
   station_id BIGINT UNSIGNED NULL,
   status ENUM('queued','accepted','preparing','ready','served','cancelled') NOT NULL DEFAULT 'queued',
   course VARCHAR(40) NULL,
   priority ENUM('normal','rush','vip') NOT NULL DEFAULT 'normal',
   note VARCHAR(500) NULL,
   accepted_at DATETIME NULL,
   started_at DATETIME NULL,
   ready_at DATETIME NULL,
   served_at DATETIME NULL,
   served_by BIGINT UNSIGNED NULL,
   started_by BIGINT UNSIGNED NULL,
   ready_by BIGINT UNSIGNED NULL,
   recall_count INT NOT NULL DEFAULT 0,
   fire_at DATETIME NULL,
   created_at DATETIME NULL,
   updated_at DATETIME NULL,
   PRIMARY KEY(id), UNIQUE KEY uniq_kds_item(order_item_id), KEY idx_kds_status(status), KEY idx_kds_station(station_id)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
  q("CREATE TABLE IF NOT EXISTS kds_print_queue(
   id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
   hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
   ticket_key VARCHAR(120) NOT NULL,
   kind VARCHAR(40) NOT NULL,
   order_id BIGINT UNSIGNED NULL,
   station_id BIGINT UNSIGNED NULL,
   target VARCHAR(120) NULL,
   payload LONGTEXT NULL,
   status ENUM('queued','printed','failed') NOT NULL DEFAULT 'queued',
   attempts INT NOT NULL DEFAULT 0,
   last_error VARCHAR(500) NULL,
   created_at DATETIME NULL,
   printed_at DATETIME NULL,
   PRIMARY KEY(id), UNIQUE KEY uniq_kds_ticket(hotel_id,ticket_key), KEY idx_kds_print_status(status)
  ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
  $have=[];
  foreach(rows("SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items'") as $r) $have[strtolower((string)$r['COLUMN_NAME'])]=true;
  foreach(['course'=>'VARCHAR(40) NULL','priority'=>"ENUM('normal','rush','vip') NOT NULL DEFAULT 'normal'",'note'=>'VARCHAR(500) NULL','accepted_at'=>'DATETIME NULL','ready_at'=>'DATETIME NULL','served_at'=>'DATETIME NULL','served_by'=>'BIGINT UNSIGNED NULL','started_by'=>'BIGINT UNSIGNED NULL','ready_by'=>'BIGINT UNSIGNED NULL','recall_count'=>'INT NOT NULL DEFAULT 0','fire_at'=>'DATETIME NULL','created_at'=>'DATETIME NULL','updated_at'=>'DATETIME NULL'] as $c=>$def){
   if(!isset($have[strtolower($c)])) q('ALTER TABLE kitchen_order_items ADD COLUMN `'.$c.'` '.$def);
  }
  $oave=[];
  foreach(rows("SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='orders'") as $r) $oave[strtolower((string)$r['COLUMN_NAME'])]=true;
  foreach(['kds_runner'=>'VARCHAR(80) NULL','kds_eta'=>'DATETIME NULL','kds_dispatched_at'=>'DATETIME NULL'] as $c=>$def){
   if(!isset($oave[strtolower($c)])) q('ALTER TABLE orders ADD COLUMN `'.$c.'` '.$def);
  }
  $shave=[];
  foreach(rows("SELECT COLUMN_NAME FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_stations'") as $r) $shave[strtolower((string)$r['COLUMN_NAME'])]=true;
  foreach(['hotel_id'=>'BIGINT UNSIGNED NOT NULL DEFAULT 1','code'=>"VARCHAR(20) NOT NULL DEFAULT 'HOT'",'color'=>"VARCHAR(20) NOT NULL DEFAULT '#0B5D78'",'printer_key'=>'VARCHAR(80) NULL','sort_order'=>'INT NOT NULL DEFAULT 0'] as $c=>$def){
   if(!isset($shave[strtolower($c)])) q('ALTER TABLE kitchen_stations ADD COLUMN `'.$c.'` '.$def);
  }
  q('UPDATE kitchen_stations SET hotel_id=1 WHERE hotel_id IS NULL OR hotel_id=0');
  if((int)val('SELECT COUNT(*) FROM kitchen_stations')===0){
   foreach([['HOT','Hot Kitchen','#c62828',0],['COLD','Cold Kitchen','#0B5D78',1],['BAR','Bar & Drinks','#7b1fa2',2],['PASTRY','Pastry & Desserts','#b26a00',3],['ROOM','Room Service','#2e7d32',4]] as $s){
    q('INSERT INTO kitchen_stations(property_id,hotel_id,code,name,color,sort_order,active) VALUES(1,1,?,?,?,?,1)',$s);
   }
  }
  $done=true;
 }catch(\Throwable $e){ error_log('[kds] schema: '.$e->getMessage()); }
}

function kds_stations(): array{
 kds_ensure_schema();
 try{ return rows('SELECT * FROM kitchen_stations WHERE active=1 ORDER BY sort_order,id'); }catch(\Throwable $e){ return []; }
}

function kds_station_map(): array{
 $m=[];
 foreach(kds_stations() as $s) $m[(int)$s['id']]=$s;
 return $m;
}

function kds_infer_station(array $item,array $stations): int{
 $name=strtolower(trim((string)($item['item_name']??$item['name']??$item['custom_name']??'')));
 $cat=strtolower(trim((string)($item['category_name']??'')));
 $outlet=strtolower(trim((string)($item['outlet']??'')));
 $hay=$name.' '.$cat;
 $codes=[];
 foreach($stations as $s) $codes[strtoupper((string)$s['code'])]=(int)$s['id'];
 if($outlet==='bar'||preg_match('/\b(cocktail|beer|wine|juice|soda|drink|water|coffee|tea|mocha|smoothie|cola|fanta|spirits?)\b/',$hay)) return $codes['BAR']??0;
 if(preg_match('/\b(cake|dessert|pastry|pudding|ice ?cream|brownie|tart|pie)\b/',$hay)) return $codes['PASTRY']??0;
 if(preg_match('/\b(salad|sandwich|cold|starter|appetiser|appetizer|sushi|ceviche)\b/',$hay)) return $codes['COLD']??0;
 if($outlet==='room_service') return $codes['ROOM']??($codes['HOT']??0);
 return $codes['HOT']??0;
}

function kds_sync_order(int $orderId): void{
 if($orderId<=0) return;
 kds_ensure_schema();
 try{
  $o=row('SELECT * FROM orders WHERE id=?',[$orderId]);
  if(!$o) return;
  $stations=kds_stations();
  $items=rows('SELECT oi.*,mi.name item_name,mc.name category_name FROM order_items oi LEFT JOIN menu_items mi ON mi.id=oi.menu_item_id LEFT JOIN menu_categories mc ON mc.id=mi.category_id WHERE oi.order_id=? ORDER BY oi.id',[$orderId]);
  foreach($items as $it){
   $iid=(int)$it['id'];
   $has=val('SELECT id FROM kitchen_order_items WHERE order_item_id=?',[$iid]);
   $sid=kds_infer_station(array_merge($it,['outlet'=>(string)$o['outlet']]),$stations);
   if($has===null){
    q('INSERT INTO kitchen_order_items(order_item_id,station_id,status,priority,note,created_at,updated_at) VALUES(?,?,\'queued\',?,?,NOW(),NOW())',
     [$iid,$sid,kds_priority((string)$o['status'],(string)($it['notes']??'')),substr((string)($it['notes']??''),0,500)]);
    kds_print_queue_add($orderId,$sid,$it);
    $sname=(string)($stations[$sid]['name']??'Kitchen');
    $scode=strtoupper((string)($stations[$sid]['code']??'HOT'));
    $roles=$scode==='BAR'?['bar_staff','waiter','kitchen','general_manager']:($scode==='ROOM'?['waiter','receptionist','kitchen','general_manager']:['kitchen','general_manager']);
    notify_console('kds-new:'.$orderId.':'.$iid,'order','New KOT '.(string)$o['order_number'],
     (string)($it['item_name']??$it['custom_name']??'Item').' · '.number_format((float)$it['quantity'],0).' · '.$sname,
     ['order_id'=>$orderId,'station'=>$sname,'item'=>(string)($it['item_name']??$it['custom_name']??'')],$roles,'order',$orderId);
   }elseif($sid>0){
    q('UPDATE kitchen_order_items SET station_id=? WHERE id=? AND (station_id IS NULL OR station_id=0)',[$sid,(int)$has]);
   }
  }
 }catch(\Throwable $e){ error_log('[kds] sync order '.$orderId.': '.$e->getMessage()); }
}

function kds_priority(string $orderStatus,string $note): string{
 $n=strtolower($note);
 if(strpos($n,'vip')!==false) return 'vip';
 if(strpos($n,'rush')!==false||strpos($n,'urgent')!==false) return 'rush';
 return $orderStatus==='pending'?'normal':'normal';
}

function kds_print_queue_add(int $orderId,int $stationId,array $item): void{
 try{
  $key='ORD'.$orderId.':'.(int)($item['id']??0).':1';
  q('INSERT IGNORE INTO kds_print_queue(hotel_id,ticket_key,kind,order_id,station_id,target,payload,status,created_at) VALUES(1,?,\'kot\',?,?,NULL,?,\'queued\',NOW())',
   [$key,$orderId,$stationId>0?$stationId:null,json_encode(['item'=>(string)($item['item_name']??$item['custom_name']??''),'qty'=>(float)($item['quantity']??0),'note'=>(string)($item['notes']??'')],JSON_UNESCAPED_UNICODE)]);
 }catch(\Throwable $e){ error_log('[kds] print queue: '.$e->getMessage()); }
}

function kds_print_queue(): array{
 kds_ensure_schema();
 try{ return rows('SELECT p.*,o.order_number,s.name station_name FROM kds_print_queue p LEFT JOIN orders o ON o.id=p.order_id LEFT JOIN kitchen_stations s ON s.id=p.station_id WHERE p.status<>\'printed\' ORDER BY p.id DESC LIMIT 100'); }catch(\Throwable $e){ return []; }
}

function kds_mark_printed(int $id): void{
 try{ q("UPDATE kds_print_queue SET status='printed',printed_at=NOW(),attempts=attempts+1 WHERE id=?",[$id]); }catch(\Throwable $e){}
}

function kds_items(array $f=[]): array{
 kds_ensure_schema();
 $where=["o.deleted_at IS NULL","o.status NOT IN('cancelled','paid','partially_paid')"];
 $args=[];
 $statuses=$f['status']??['queued','accepted','preparing','ready','served'];
 if(is_array($statuses)&&$statuses!==[]){ $where[]='ki.status IN('.implode(',',array_fill(0,count($statuses),'?')).')'; array_push($args,...$statuses); }
 if(!empty($f['station'])&&(int)$f['station']>0){ $where[]='ki.station_id=?'; $args[]=(int)$f['station']; }
 if(!empty($f['outlet'])&&in_array((string)$f['outlet'],['restaurant','bar','room_service'],true)){ $where[]='o.outlet=?'; $args[]=(string)$f['outlet']; }
 if(!empty($f['query'])){ $where[]='(o.order_number LIKE ? OR o.customer_name LIKE ? OR o.table_name LIKE ?)'; $like='%'.$f['query'].'%'; array_push($args,$like,$like,$like); }
 if(!empty($f['today'])) $where[]='DATE(o.created_at)=CURDATE()';
 $sql='SELECT o.id order_id,o.order_number,o.outlet,o.order_type,o.table_name,o.customer_name,o.customer_phone,o.delivery_address,o.delivery_notes,o.status order_status,o.created_at,'
  ."oi.id item_id,oi.quantity,oi.notes item_notes,".hp_order_item_name_sql().","
  .'ki.id kds_id,ki.status kds_status,ki.priority,ki.course,ki.started_at,ki.ready_at,ki.served_at,ki.recall_count,ki.fire_at,'
  .'s.id station_id,s.name station_name,s.code station_code,s.color station_color '
  .'FROM kitchen_order_items ki JOIN order_items oi ON oi.id=ki.order_item_id JOIN orders o ON o.id=oi.order_id '
  .'LEFT JOIN menu_items mi ON mi.id=oi.menu_item_id LEFT JOIN kitchen_stations s ON s.id=ki.station_id '
  .'WHERE '.implode(' AND ',$where).' ORDER BY FIELD(ki.status,\'rush\',\'queued\',\'accepted\',\'preparing\',\'ready\',\'served\'),o.id ASC,ki.id ASC LIMIT 300';
 try{ return rows($sql,$args); }catch(\Throwable $e){ error_log('[kds] items: '.$e->getMessage()); return []; }
}

function kds_group(array $items): array{
 $orders=[];
 foreach($items as $it){
  $id=(int)$it['order_id'];
  if(!isset($orders[$id])) $orders[$id]=['id'=>$id,'number'=>(string)$it['order_number'],'outlet'=>(string)$it['outlet'],'type'=>(string)$it['order_type'],'table'=>(string)($it['table_name']??''),'customer'=>(string)($it['customer_name']??''),'phone'=>(string)($it['customer_phone']??''),'address'=>(string)($it['delivery_address']??''),'notes'=>(string)($it['delivery_notes']??''),'created_at'=>(string)$it['created_at'],'status'=>(string)$it['order_status'],'items'=>[]];
  $orders[$id]['items'][]=$it;
 }
 return array_values($orders);
}

function kds_set_status(int $kdsId,string $status,int $userId): array{
 kds_ensure_schema();
 $allowed=['queued','accepted','preparing','ready','served','cancelled'];
 if(!in_array($status,$allowed,true)) return ['ok'=>false,'error'=>'Unknown kitchen status.'];
 $r=row('SELECT ki.*,o.order_number,o.id order_id FROM kitchen_order_items ki JOIN order_items oi ON oi.id=ki.order_item_id JOIN orders o ON o.id=oi.order_id WHERE ki.id=?',[$kdsId]);
 if(!$r) return ['ok'=>false,'error'=>'That ticket has gone.'];
 $old=(string)$r['status'];
 $set=['status'=>$status,'updated_at'=>date('Y-m-d H:i:s')];
 if($status==='preparing'&&$old==='queued'){ $set['accepted_at']=date('Y-m-d H:i:s'); }
 if($status==='preparing'){ $set['started_at']=date('Y-m-d H:i:s'); $set['started_by']=$userId; }
 if($status==='ready'){ $set['ready_at']=date('Y-m-d H:i:s'); $set['ready_by']=$userId; }
 if($status==='served'){ $set['served_at']=date('Y-m-d H:i:s'); $set['served_by']=$userId; }
 $cols=[]; $args=[];
 foreach($set as $c=>$v){ $cols[]='`'.$c.'`=?'; $args[]=$v; }
 $args[]=$kdsId;
 try{ q('UPDATE kitchen_order_items SET '.implode(',',$cols).' WHERE id=?',$args); }catch(\Throwable $e){ return ['ok'=>false,'error'=>$e->getMessage()]; }
 audit('kds_item_status','order_item',$kdsId,['status'=>$old],['status'=>$status]);
 kds_rollup((int)$r['order_id'],$userId);
 if($status==='ready'){
  notify_console('kds-ready:'.$kdsId,'order','Order '.$r['order_number'].' is plated',
   'A kitchen item is ready on the pass.',['order_id'=>(int)$r['order_id'],'kds_id'=>$kdsId],['director','general_manager','cashier','waiter'],'order',(int)$r['order_id']);
 }
 if($status==='cancelled'){
  notify_console('kds-cancel:'.$kdsId,'incident','Order '.$r['order_number'].' item cancelled',
   'A kitchen ticket was cancelled from the display.',['order_id'=>(int)$r['order_id'],'kds_id'=>$kdsId],['director','general_manager','cashier'],'order',(int)$r['order_id']);
 }
 return ['ok'=>true,'from'=>$old,'to'=>$status];
}

function kds_rollup(int $orderId,int $userId): void{
 try{
  $items=rows('SELECT status FROM kitchen_order_items ki JOIN order_items oi ON oi.id=ki.order_item_id WHERE oi.order_id=?',[$orderId]);
  $s=array_map(static fn(array $r): string=>(string)$r['status'],$items);
  $to='preparing';
  if($s!==[]&&count(array_unique($s))===1){
   $only=$s[0];
   $to=$only==='queued'?'pending':($only==='accepted'?'accepted':($only==='preparing'?'preparing':($only==='ready'?'ready':($only==='served'?'served':$only))));
  }elseif(in_array('ready',$s,true)) $to='ready';
  elseif(in_array('preparing',$s,true)||in_array('accepted',$s,true)) $to='preparing';
  $o=row('SELECT id,status,order_number FROM orders WHERE id=?',[$orderId]);
  if($o&&(string)$o['status']!==$to&&!in_array((string)$o['status'],['paid','partially_paid','cancelled'],true)){
   q('UPDATE orders SET status=? WHERE id=?',[$to,$orderId]);
   audit('kds_order_status','order',$orderId,['status'=>(string)$o['status']],['status'=>$to]);
  }
 }catch(\Throwable $e){ error_log('[kds] rollup: '.$e->getMessage()); }
}

function kds_set_priority(int $kdsId,string $priority,int $userId): array{
 $priority=in_array($priority,['normal','rush','vip'],true)?$priority:'normal';
 $r=row('SELECT id,priority FROM kitchen_order_items WHERE id=?',[$kdsId]);
 if(!$r) return ['ok'=>false,'error'=>'That ticket has gone.'];
 q('UPDATE kitchen_order_items SET priority=?,updated_at=NOW() WHERE id=?',[$priority,$kdsId]);
 audit('kds_priority','order_item',$kdsId,['priority'=>(string)$r['priority']],['priority'=>$priority]);
 return ['ok'=>true,'priority'=>$priority];
}

function kds_set_order_status(int $orderId,string $status,int $userId): array{
 kds_ensure_schema();
 $map=['accepted'=>'accepted','preparing'=>'preparing','ready'=>'ready','served'=>'served','cancelled'=>'cancelled'];
 if(!isset($map[$status])) return ['ok'=>false,'error'=>'Unknown status.'];
 kds_sync_order($orderId);
 $ids=rows('SELECT ki.id FROM kitchen_order_items ki JOIN order_items oi ON oi.id=ki.order_item_id WHERE oi.order_id=? AND ki.status<>?',[$orderId,$map[$status]]);
 foreach($ids as $r) kds_set_status((int)$r['id'],$map[$status],$userId);
 return ['ok'=>true,'count'=>count($ids)];
}

function kds_bump_order(int $orderId,int $userId): array{
 kds_ensure_schema();
 $ids=rows("SELECT ki.id FROM kitchen_order_items ki JOIN order_items oi ON oi.id=ki.order_item_id WHERE oi.order_id=? AND ki.status<>'served'",[$orderId]);
 foreach($ids as $r) kds_set_status((int)$r['id'],'served',$userId);
 audit('kds_bump','order',$orderId,[],['by'=>$userId]);
 $o=row('SELECT order_number FROM orders WHERE id=?',[$orderId]);
 if($o) notify_console('kds-bump:'.$orderId,'order','Order '.$o['order_number'].' served',
  'The kitchen display bumped the whole order to served.',['order_id'=>$orderId],['director','general_manager','cashier','waiter'],'order',$orderId);
 return ['ok'=>true,'count'=>count($ids)];
}

function kds_recall_order(int $orderId,int $userId): array{
 kds_ensure_schema();
 $ids=rows("SELECT ki.id FROM kitchen_order_items ki JOIN order_items oi ON oi.id=ki.order_item_id WHERE oi.order_id=? AND ki.status='served'",[$orderId]);
 foreach($ids as $r){
  q("UPDATE kitchen_order_items SET status='ready',served_at=NULL,served_by=NULL,recall_count=recall_count+1,updated_at=NOW() WHERE id=?",[(int)$r['id']]);
 }
 kds_rollup($orderId,$userId);
 audit('kds_recall','order',$orderId,[],['by'=>$userId,'count'=>count($ids)]);
 $o=row('SELECT order_number FROM orders WHERE id=?',[$orderId]);
 if($o&&count($ids)>0) notify_console('kds-recall:'.$orderId.'-'.time(),'order','Order '.$o['order_number'].' recalled',
  'A served order was recalled to the pass by the kitchen display.',['order_id'=>$orderId],['director','general_manager','waiter'],'order',$orderId);
 return ['ok'=>true,'count'=>count($ids)];
}

function kds_dispatch_room(int $orderId,string $runner,string $eta,int $userId): array{
 kds_ensure_schema();
 $o=row('SELECT id,order_number,outlet,status FROM orders WHERE id=?',[$orderId]);
 if(!$o||(string)$o['outlet']!=='room_service') return ['ok'=>false,'error'=>'That room service order no longer exists.'];
 $when=$eta!==''?date('Y-m-d H:i:s',strtotime($eta)):date('Y-m-d H:i:s',strtotime('+25 minutes'));
 try{
  q('UPDATE orders SET kds_runner=?,kds_eta=?,kds_dispatched_at=NOW() WHERE id=?',[substr($runner,0,80),$when,$orderId]);
  kds_set_status((int)(val('SELECT ki.id FROM kitchen_order_items ki JOIN order_items oi ON oi.id=ki.order_item_id WHERE oi.order_id=? AND ki.status=\'queued\' ORDER BY ki.id LIMIT 1',[$orderId])??0),'accepted',$userId);
 }catch(\Throwable $e){ return ['ok'=>false,'error'=>$e->getMessage()]; }
 audit('kds_room_dispatch','order',$orderId,['status'=>(string)$o['status']],['runner'=>$runner,'eta'=>$when]);
 notify_console('kds-room:'.$orderId,'order','Room service order '.$o['order_number'].' dispatched',
  'Runner '.($runner!==''?$runner:'unassigned').' has the order for '.date('H:i',strtotime($when)).'.',
  ['order_id'=>$orderId],['director','general_manager','receptionist','waiter'],'order',$orderId);
 return ['ok'=>true,'eta'=>$when];
}

function kds_payments(): array{
 $m=[];
 try{
  foreach(rows("SELECT id,order_id,amount,method,created_at FROM payments WHERE status='successful' AND order_id IS NOT NULL AND created_at>=NOW() - INTERVAL 6 HOUR ORDER BY id DESC LIMIT 80") as $p){
   $m[(int)$p['order_id']][]=(int)$p['id'];
  }
 }catch(\Throwable $e){}
 return $m;
}

function kds_stats(): array{
 kds_ensure_schema();
 try{
  return [
   'queued'=>(int)val("SELECT COUNT(*) FROM kitchen_order_items WHERE status='queued'"),
   'accepted'=>(int)val("SELECT COUNT(*) FROM kitchen_order_items WHERE status='accepted'"),
   'cooking'=>(int)val("SELECT COUNT(*) FROM kitchen_order_items WHERE status='preparing'"),
   'ready'=>(int)val("SELECT COUNT(*) FROM kitchen_order_items WHERE status='ready'"),
   'late'=>(int)val("SELECT COUNT(*) FROM kitchen_order_items WHERE status<>'served' AND created_at < NOW() - INTERVAL 15 MINUTE"),
   'served'=>(int)val("SELECT COUNT(*) FROM kitchen_order_items WHERE status='served' AND DATE(served_at)=CURDATE()")
  ];
 }catch(\Throwable $e){ return ['queued'=>0,'accepted'=>0,'cooking'=>0,'ready'=>0,'late'=>0,'served'=>0]; }
}
