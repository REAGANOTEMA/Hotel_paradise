<?php
declare(strict_types=1);

/*
 * The kitchen's own screen.
 *
 * It carries food, never money: what is on the pass, what is on its way, and
 * what has just come in. The receipt here is a docket, and it prints itself the
 * moment an order lands, so the printer is what tells the kitchen rather than
 * somebody walking over to look at a monitor.
 */

$act=$_GET['act']??'';
$u=current_user();

/**
 * What this screen has not drawn yet. The page polls it and reloads when an
 * order turns up that it has never seen, which is what puts the new docket on
 * the printer - the reload draws it, and the drawing prints it.
 */
if($act==='feed'){
 header('Content-Type: application/json; charset=utf-8');
 $ids=rows("SELECT o.id FROM orders o WHERE o.status IN('pending','accepted','preparing','ready') ORDER BY o.id DESC LIMIT 80");
 echo json_encode(['ids'=>array_map(static fn(array $r): int=>(int)$r['id'],$ids)]);
 exit;
}

if($_SERVER['REQUEST_METHOD']==='POST'){
 $map=['accept'=>'accepted','start'=>'preparing','ready'=>'ready','serve'=>'served'];
 $to=$map[$_POST['do']??'']??'';
 if($to===''){
  flash('That is not something the kitchen can do to an order.','bad');
  go('kitchen');
 }
 $oid=(int)($_POST['oid']??0);
 $r=row('SELECT id,order_number,status FROM orders WHERE id=?',[$oid]);
 if(!$r){ flash('That order is no longer open.','bad'); go('kitchen'); }
 if($to==='served' && !in_array($r['status'],['ready','preparing','accepted'],true)){
  flash('Order '.$r['order_number'].' cannot be marked served from '.$r['status'].'.','bad');
  go('kitchen');
 }
 q('UPDATE orders SET status=? WHERE id=?',[$to,$oid]);
 audit('order_status','order',$oid,['status'=>$r['status']],['status'=>$to]);
 if($to==='ready'){
  notify_console('kitchen-ready:'.$oid,'order','Order '.$r['order_number'].' is ready',
   'The kitchen has plated it. It is waiting on the pass to be collected and served.',
   ['order_id'=>$oid],['director','general_manager','cashier'],'order',$oid);
 }
 flash('Order '.$r['order_number'].' is now '.$to.'.');
 go('kitchen');
}

/* ------------------------------------------------------------------ the board */

$active=rows("SELECT o.*,(SELECT oi.notes FROM order_items oi WHERE oi.order_id=o.id AND oi.notes<>'' ORDER BY oi.id LIMIT 1) any_notes
 FROM orders o WHERE o.status IN('pending','accepted','preparing','ready') ORDER BY o.id ASC");
$done=rows("SELECT o.* FROM orders o WHERE o.status IN('served','cancelled') AND DATE(o.created_at)=CURDATE() ORDER BY o.id DESC LIMIT 12");

$lines=[];
$ids=array_map(static fn(array $r): int=>(int)$r['id'],array_merge($active,$done));
if($ids){
 foreach(rows('SELECT oi.order_id,oi.quantity,oi.notes,mi.name FROM order_items oi LEFT JOIN menu_items mi ON mi.id=oi.menu_item_id WHERE oi.order_id IN('.implode(',',array_map('intval',$ids)).') ORDER BY oi.id',[]) as $l){
  $lines[(int)$l['order_id']][]=$l;
 }
}

$waiting=count(array_filter($active,static fn(array $o): bool=>$o['status']==='pending'||$o['status']==='accepted'));
$cooking=count(array_filter($active,static fn(array $o): bool=>$o['status']==='preparing'));
$ready=count(array_filter($active,static fn(array $o): bool=>$o['status']==='ready'));
$served=(int)val("SELECT COUNT(*) FROM orders WHERE status='served' AND DATE(created_at)=CURDATE()",[]);

page_head('Kitchen','kitchen',date('l, j F Y').' · the pass');

echo '<div class="kpis">';
kpi_card('On the pass',(string)$waiting,'Waiting or accepted',$waiting?'gold':'navy');
kpi_card('Cooking',(string)$cooking,'In preparation',$cooking?'blue':'navy');
kpi_card('Ready',(string)$ready,'Waiting to be collected',$ready?'green':'navy');
kpi_card('Served today',(string)$served,'Finished and away');
echo '</div>';

/* ------------------------------------------------------------------ the receipts */

$ticket=function(array $o) use ($lines): string{
 $m=[];
 $m['Outlet']=ucfirst((string)$o['outlet']);
 $m['Service']=$o['order_type']==='room'?'Room service':ucfirst((string)$o['order_type']);
 if($o['table_name']) $m['Table or room']=(string)$o['table_name'];
 $m['Placed']=fmtdt($o['created_at']);
 $g=order_customer($o['any_notes']??null);
 if($g){ $m['Guest']=$g['name']; $m['Phone']=$g['phone']; }
 $d=order_delivery($o);
 if($d['email']) $m['Email']=$d['email'];
 if($d['address']) $m['Deliver to']=$d['address'];
 if($d['notes']) $m['Note']=$d['notes'];
 $ls=[];
 foreach($lines[(int)$o['id']]??[] as $l){
  $ls[]=['name'=>(string)($l['name']??'Item removed'),'qty'=>'x'.rtrim(rtrim(number_format((float)$l['quantity'],2,'.',''),'0'),'.'),
   'note'=>prep_note($l['notes']??null)];
 }
 return receipt_sheet([
  'kind'=>'KITCHEN DOCKET',
  'number'=>(string)$o['order_number'],
  'meta'=>$m,
  'lines'=>$ls,
  'foot'=>'Status: '.str_replace('_',' ',(string)$o['status']).' &middot; printed by the kitchen screen'
 ]);
};

$fresh=static fn(array $o): bool=>strtotime((string)$o['created_at'])>=time()-90;

foreach($active as $o){ receipt_template($o['id'],$ticket($o),$fresh($o)); }
foreach($done as $o){ receipt_template($o['id'],$ticket($o),false); }

/* ------------------------------------------------------------------ the screen */

echo '<div class="toolbar"><div class="bar"><span class="badge" style="background:#0f28501a;color:#0f2850;border:1px solid #0f285055">Kitchen display</span></div>';
echo '<button class="btn sm" type="button" onclick="location.reload()">Refresh</button></div>';

if(!$active){
 echo '<div class="panel"><h2>The pass is clear</h2><p class="hint">Nothing is waiting. A new order prints a docket by itself the moment it is sent.</p></div>';
}

echo '<div class="board">';
foreach($active as $o){
 $oid=(int)$o['id'];
 $tone=($o['status']==='ready'?'ready':($o['status']==='preparing'?'cook':($o['status']==='pending'?'new':'wait')));
 $mins=max(0,(int)floor((time()-strtotime((string)$o['created_at']))/60));
 echo '<article class="docket docket_'.$tone.'">';
 echo '<header><b>'.e($o['order_number']).'</b>'.status_badge($o['status']).'</header>';
 echo '<p class="docketMeta">'.e(ucfirst((string)$o['outlet'])).' &middot; '.e($o['order_type']==='room'?'Room service':ucfirst((string)$o['order_type']));
 if($o['table_name']) echo ' &middot; '.e((string)$o['table_name']);
 echo ' &middot; <b>'.$mins.' min</b></p>';
 $d=order_delivery($o);
 if($d['address']) echo '<p class="docketAddr">Deliver to: '.e($d['address']).'</p>';
 echo '<ul class="docketItems">';
 foreach($lines[$oid]??[] as $l){
  $qty=(float)$l['quantity'];
  $q=abs($qty-floor($qty))<0.001?(string)(int)$qty:(string)$qty;
  echo '<li><b>x'.$q.'</b> '.e((string)($l['name']??'Item removed'));
  $p=prep_note($l['notes']??null);
  if($p) echo '<em>'.e($p).'</em>';
  echo '</li>';
 }
 echo '</ul>';
 echo '<footer>';
 echo '<button class="btn sm" type="button" onclick="printReceipt('.$oid.')">Print docket</button>';
 if($o['status']==='pending') echo '<form method="post" action="'.BASE.'/index.php?page=kitchen"><input type="hidden" name="oid" value="'.$oid.'"><input type="hidden" name="do" value="accept"><button class="btn sm blue">Accept</button></form>';
 if($o['status']==='accepted') echo '<form method="post" action="'.BASE.'/index.php?page=kitchen"><input type="hidden" name="oid" value="'.$oid.'"><input type="hidden" name="do" value="start"><button class="btn sm blue">Start cooking</button></form>';
 if($o['status']==='preparing') echo '<form method="post" action="'.BASE.'/index.php?page=kitchen"><input type="hidden" name="oid" value="'.$oid.'"><input type="hidden" name="do" value="ready"><button class="btn sm tick">Ready</button></form>';
 if($o['status']==='ready') echo '<form method="post" action="'.BASE.'/index.php?page=kitchen"><input type="hidden" name="oid" value="'.$oid.'"><input type="hidden" name="do" value="serve"><button class="btn sm tick">Served</button></form>';
 echo '</footer></article>';
}
echo '</div>';

if($done){
 echo '<div class="panel" style="margin-top:22px"><h2>Finished today</h2><p class="hint">Served and cancelled orders, most recent first.</p>';
 echo '<table class="tbl"><thead><tr><th>Order</th><th>Sent</th><th>Items</th><th>Status</th><th></th></tr></thead><tbody>';
 foreach($done as $o){
  echo '<tr><td><b>'.e($o['order_number']).'</b></td><td>'.fmtdt($o['created_at']).'</td><td>';
  $names=[];
  foreach($lines[(int)$o['id']]??[] as $l) $names[]=(string)($l['name']??'');
  echo e(implode(', ',array_slice($names,0,3))).(count($names)>3?' &hellip;':'');
  echo '</td><td>'.status_badge($o['status']).'</td>';
  echo '<td><button class="btn sm" type="button" onclick="printReceipt('.(int)$o['id'].')">Print docket</button></td></tr>';
 }
 echo '</tbody></table></div>';
}

echo '<style>
.board{display:grid;grid-template-columns:repeat(auto-fill,minmax(270px,1fr));gap:16px}
.docket{background:#fff;border:1px solid var(--line);border-top:4px solid #0f2850;border-radius:14px;padding:14px 15px;box-shadow:0 10px 26px #071A3310;display:flex;flex-direction:column}
.docket_new{border-top-color:#c62828}
.docket_wait{border-top-color:#b26a00}
.docket_cook{border-top-color:#0B5D78}
.docket_ready{border-top-color:#2e7d32}
.docket header{display:flex;justify-content:space-between;align-items:center;gap:8px}
.docket header b{font-family:\'Playfair Display\',serif;font-size:16px;color:var(--navy)}
.docketMeta{margin:6px 0 2px;font-size:12px;color:var(--muted)}
.docketMeta b{color:var(--navy)}
.docketAddr{margin:2px 0 0;font-size:12px;font-weight:600;color:var(--navy);background:var(--goldSoft);border-left:3px solid var(--gold);padding:5px 8px;border-radius:6px;overflow-wrap:anywhere}
.docketItems{list-style:none;margin:8px 0 0;padding:0;flex:1}
.docketItems li{padding:6px 0;border-bottom:1px dashed #eeeae0;font-size:13.5px;color:var(--navy)}
.docketItems li b{display:inline-block;min-width:34px;color:var(--gold)}
.docketItems li em{display:block;font-style:normal;font-size:11.5px;color:var(--muted);padding-left:34px}
.docket footer{display:flex;gap:7px;flex-wrap:wrap;margin-top:12px}
.docket footer form{display:inline}
@media(max-width:720px){.board{grid-template-columns:1fr}}
</style>';

receipt_print('kitchen',BASE.'/index.php?page=kitchen&act=feed');
page_foot();
