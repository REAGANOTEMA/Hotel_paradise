<?php
declare(strict_types=1);

require_once __DIR__.'/../app/kds.php';
require_once __DIR__.'/../app/receipts.php';

$act=(string)($_GET['act']??'');
$u=current_user();
$uid=(int)($u['id']??0);

if($act==='feed'){
 kds_ensure_schema();
 header('Content-Type: application/json; charset=utf-8');
 $station=(int)($_GET['station']??0);
 $outlet=(string)($_GET['outlet']??'');
 $view=(string)($_GET['view']??'live');
 $f=['status'=>$view==='all'?['queued','accepted','preparing','ready','served']:['queued','accepted','preparing','ready']];
 if($station>0) $f['station']=$station;
 if(in_array($outlet,['restaurant','bar','room_service'],true)) $f['outlet']=$outlet;
 if($view==='all') $f['today']=true;
 $items=kds_items($f);
 $data=[
  'stats'=>kds_stats(),
  'stations'=>kds_stations(),
  'orders'=>kds_group($items),
  'prints'=>kds_print_queue(),
  'payments'=>kds_payments(),
  'ids'=>array_values(array_unique(array_map(static fn(array $i): int=>(int)$i['order_id'],array_filter($items,static fn(array $i):bool=>in_array((string)$i['kds_status'],['queued','accepted'],true))))),
  'at'=>date('H:i:s')
 ];
 $data['sig']=md5(json_encode([$data['stats'],$data['orders'],$data['prints'],$station,$outlet,$view],JSON_UNESCAPED_UNICODE));
 echo json_encode($data,JSON_UNESCAPED_UNICODE);
 exit;
}

if($act==='ticket'){
 kds_ensure_schema();
 $oid=(int)($_GET['oid']??0);
 $o=row('SELECT * FROM orders WHERE id=?',[$oid]);
 if(!$o){ http_response_code(404); echo 'Order not found'; exit; }
 $items=kds_items(['status'=>['queued','accepted','preparing','ready','served']]);
 $mine=array_values(array_filter($items,static fn(array $i):bool=>(int)$i['order_id']===$oid));
 $rows=[];
 foreach($mine as $i){
  $rows[]=['name'=>(string)($i['name']??'Item removed'),'qty'=>'x'.rtrim(rtrim(number_format((float)$i['quantity'],2,'.',''),'0'),'.'),'note'=>trim((string)($i['item_notes']??'')).( (string)($i['station_name']??'')!==''?' ['.(string)$i['station_name'].']':'')];
 }
 q("UPDATE kds_print_queue SET status='printed',printed_at=NOW(),attempts=attempts+1 WHERE order_id=? AND status='queued'",[$oid]);
 header('Content-Type: text/html; charset=utf-8');
 echo '<!doctype html><html><head><meta charset="utf-8"><title>KOT '.$o['order_number'].'</title><style>'
  .'@page{size:80mm auto;margin:0}body{font:12px/1.4 monospace;color:#111;margin:8mm 4mm;width:72mm}'
  .'h1{font-size:16px;margin:0 0 4px;text-align:center;letter-spacing:1px}h2{font-size:12px;margin:8px 0 3px;text-transform:uppercase}'
  .'dl{margin:4px 0}dt{float:left;width:32%;font-weight:700}dd{margin:0 0 2px 34%}.rule{border-top:1px dashed #666;margin:8px 0}'
  .'table{width:100%;border-collapse:collapse}td{padding:3px 0;vertical-align:top}td.q{width:28px;font-weight:700}'
  .'.foot{margin-top:10px;text-align:center;font-size:10px}@media screen{body{width:80mm;background:#fff;box-shadow:0 0 12px #0002;margin:20px auto}}'
  .'</style></head><body><h1>HOTEL PARADISE</h1><h2>Kitchen Order Ticket</h2><dl>'
  .'<dt>Order</dt><dd>'.e((string)$o['order_number']).'</dd>'
  .'<dt>Outlet</dt><dd>'.e(ucfirst((string)$o['outlet'])).' / '.e(str_replace('_',' ',(string)$o['order_type'])).'</dd>';
 if((string)$o['table_name']!=='') echo '<dt>Table / room</dt><dd>'.e((string)$o['table_name']).'</dd>';
 if((string)$o['customer_name']!=='') echo '<dt>Guest</dt><dd>'.e((string)$o['customer_name']).'</dd>';
 echo '<dt>Placed</dt><dd>'.e(fmtdt($o['created_at'])).'</dd></dl><div class="rule"></div><table>';
 foreach($rows as $r){
  echo '<tr><td class="q">'.e($r['qty']).'</td><td><b>'.e($r['name']).'</b>'.($r['note']!==''?'<br><small>'.e($r['note']).'</small>':'').'</td></tr>';
 }
 echo '</table><div class="rule"></div><div class="foot">Printed from the kitchen display &middot; '.e(date('j M Y H:i')).'</div>'
  .'<script>window.addEventListener("load",function(){window.print()})<\/script></body></html>';
 exit;
}

if($_SERVER['REQUEST_METHOD']==='POST'){
 $action=(string)($_POST['action']??'');
 $kdsId=(int)($_POST['id']??0);
 $orderId=(int)($_POST['oid']??0);
 $r=['ok'=>false];
 if($action==='status') $r=kds_set_status($kdsId,(string)($_POST['status']??''),$uid);
 elseif($action==='priority') $r=kds_set_priority($kdsId,(string)($_POST['priority']??'normal'),$uid);
 elseif($action==='bump'&&$orderId>0) $r=kds_bump_order($orderId,$uid);
 elseif($action==='recall'&&$orderId>0) $r=kds_recall_order($orderId,$uid);
 elseif($action==='printed'&&(int)($_POST['pid']??0)>0){ kds_mark_printed((int)$_POST['pid']); $r=['ok'=>true]; }
 elseif($action==='sync'&&$orderId>0){ kds_sync_order($orderId); $r=['ok'=>true]; }
 header('Content-Type: application/json; charset=utf-8');
 echo json_encode($r,JSON_UNESCAPED_UNICODE);
 exit;
}

$stations=kds_stations();
$stats=kds_stats();
$initialItems=kds_items(['status'=>['queued','accepted','preparing','ready']]);
$initial=[
 'stats'=>$stats,
 'stations'=>$stations,
 'orders'=>kds_group($initialItems),
 'prints'=>kds_print_queue(),
 'payments'=>kds_payments(),
 'ids'=>array_values(array_unique(array_map(static fn(array $i): int=>(int)$i['order_id'],array_filter($initialItems,static fn(array $i):bool=>in_array((string)$i['kds_status'],['queued','accepted'],true)))))
];

page_head('Kitchen Display','kds','live production board');

echo '<div class="kpis">';
kpi_card('New tickets',(string)$stats['queued'],'Waiting to be accepted',$stats['queued']?'bad':'navy');
kpi_card('Accepted',(string)$stats['accepted'],'Queued on a station',$stats['accepted']?'gold':'navy');
kpi_card('Preparing',(string)$stats['cooking'],'On the line',$stats['cooking']?'blue':'navy');
kpi_card('Ready',(string)$stats['ready'],'On the pass',$stats['ready']?'green':'navy');
echo '</div>';

echo '<div class="kds-shell"><div class="kds-top">';
echo '<div class="bar"><span class="kds-live" id="kdsLive"><i></i> Live</span>';
echo '<select id="kdsStation" class="kds-select"><option value="0">All stations</option>';
foreach($stations as $s) echo '<option value="'.(int)$s['id'].'">'.e((string)$s['name']).'</option>';
echo '</select>';
echo '<select id="kdsOutlet" class="kds-select"><option value="">All outlets</option><option value="restaurant">Restaurant</option><option value="bar">Bar</option><option value="room_service">Room service</option></select>';
echo '<select id="kdsView" class="kds-select"><option value="live">Live tickets</option><option value="all">All day</option></select>';
echo '<input id="kdsSearch" class="kds-search" type="search" placeholder="Order, guest or table">';
echo '<button class="btn sm" type="button" id="kdsSound">Sound: off</button>';
echo '<button class="btn sm" type="button" id="kdsRefresh">Refresh</button>';
echo '</div><div class="bar"><span class="hint" id="kdsClock">'.e(date('H:i:s')).'</span>';
if(in_array('director',roles_of(),true)||in_array('general_manager',roles_of(),true)||in_array('super_admin',roles_of(),true)){
 echo '<span class="badge gold" id="kdsLate">'.$stats['late'].' late</span>';
}
echo '</div></div>';

echo '<div class="kds-board" id="kdsBoard"></div>';

echo '<div class="kds-queue panel" id="kdsQueue"><h2>Print queue <span class="badge grey" id="kdsQueueCount">'.count($initial['prints']).'</span></h2>';
echo '<p class="hint">KOT tickets are queued here and printed with the browser print dialog. Mark a ticket printed only when paper has actually come out.</p>';
echo '<div id="kdsQueueList"></div></div>';

if(in_array('director',roles_of(),true)||in_array('general_manager',roles_of(),true)||in_array('super_admin',roles_of(),true)){
 $history=rows("SELECT a.action,a.old_values,a.new_values,a.created_at,u.name actor FROM audit_logs a LEFT JOIN users u ON u.id=a.user_id WHERE a.action LIKE 'kds_%' ORDER BY a.id DESC LIMIT 25");
 echo '<div class="panel"><h2>Supervisor history</h2><p class="hint">Every KDS action, who took it and when. This is the same audit trail the Director sees.</p>';
 if($history){
  echo '<table class="tbl"><thead><tr><th>When</th><th>Action</th><th>By</th><th>Detail</th></tr></thead><tbody>';
  foreach($history as $h){
   echo '<tr><td>'.e(fmtdt($h['created_at'])).'</td><td>'.e(str_replace('_',' ',(string)$h['action'])).'</td><td>'.e((string)($h['actor']?:'System')).'</td><td>'
    .e(substr((string)($h['new_values']??''),0,140)).'</td></tr>';
  }
  echo '</tbody></table>';
 }else echo '<p class="hint">No KDS actions recorded yet.</p>';
 echo '</div>';
}
echo '</div>';

echo '<script id="kdsInitial" type="application/json">'.json_encode($initial,JSON_UNESCAPED_UNICODE|JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT).'<\/script>';

echo '<style>
.kds-shell{display:flex;flex-direction:column;gap:12px}
.kds-top{display:flex;justify-content:space-between;gap:10px;flex-wrap:wrap;align-items:center}
.kds-live{font-size:12px;font-weight:700;color:#2e7d32;display:inline-flex;align-items:center;gap:6px}
.kds-live i{width:8px;height:8px;border-radius:50%;background:#2e7d32;box-shadow:0 0 0 4px #2e7d3222;display:inline-block}
.kds-live.off{color:#999}.kds-live.off i{background:#999;box-shadow:none}
.kds-select,.kds-search{height:34px;border:1px solid var(--line);border-radius:8px;background:#fff;color:var(--navy);padding:0 9px;font-size:12.5px}
.kds-search{min-width:190px}
.kds-board{display:grid;grid-template-columns:repeat(4,minmax(240px,1fr));gap:12px;align-items:start}
.kds-lane{background:#f4f2ec;border:1px solid var(--line);border-radius:14px;padding:10px;min-height:180px}
.kds-lane h3{margin:0 0 9px;font-size:12px;text-transform:uppercase;letter-spacing:.08em;color:var(--muted);display:flex;justify-content:space-between}
.kds-card{background:#fff;border:1px solid var(--line);border-left:5px solid #0f2850;border-radius:11px;padding:11px;margin-bottom:9px;box-shadow:0 8px 18px #071A330d}
.kds-card.new{border-left-color:#c62828}.kds-card.prep{border-left-color:#0B5D78}.kds-card.ready{border-left-color:#2e7d32}.kds-card.done{border-left-color:#999}
.kds-card.rush{border-left-width:8px}
.kds-head{display:flex;justify-content:space-between;align-items:center;gap:6px}
.kds-head b{font-family:\'Playfair Display\',serif;color:var(--navy);font-size:15px}
.kds-meta{font-size:11.5px;color:var(--muted);margin:4px 0 8px;display:flex;flex-wrap:wrap;gap:4px 8px}
.kds-meta span{background:#f6f4ee;border-radius:5px;padding:2px 6px}
.kds-meta .age.warn{background:#fff3cd;color:#8a5a00}.kds-meta .age.late{background:#ffd9d9;color:#a41414;font-weight:700}
.kds-item{border-top:1px dashed #e7e3d8;padding:7px 0;display:flex;justify-content:space-between;gap:7px;align-items:flex-start}
.kds-item:first-of-type{border-top:0}
.kds-item .nm{font-size:13px;color:var(--navy);font-weight:600}
.kds-item .sub{font-size:11px;color:var(--muted);margin-top:2px;overflow-wrap:anywhere}
.kds-item .acts{display:flex;gap:4px;flex-shrink:0}
.kds-btn{border:1px solid #0f285033;background:#fff;border-radius:7px;padding:5px 8px;font-size:11px;font-weight:700;color:#0f2850;cursor:pointer}
.kds-btn:hover{background:#0f2850;color:#fff}.kds-btn.go{background:#0B5D78;color:#fff;border-color:#0B5D78}.kds-btn.ok{background:#2e7d32;color:#fff;border-color:#2e7d32}
.kds-foot{display:flex;gap:5px;margin-top:9px;flex-wrap:wrap}
.kds-empty{font-size:12px;color:var(--muted);padding:12px 4px}
.kds-queue h2{font-size:15px;margin:0 0 4px}.kds-qrow{display:flex;justify-content:space-between;align-items:center;gap:8px;padding:7px 0;border-bottom:1px dashed var(--line);font-size:12px}
@media(max-width:1100px){.kds-board{grid-template-columns:repeat(2,minmax(230px,1fr))}}
@media(max-width:620px){.kds-board{grid-template-columns:1fr}.kds-search{min-width:0;width:100%}}
</style>';

echo <<<'JS'
<script>
(function(){
 var initial=JSON.parse(document.getElementById("kdsInitial").textContent);
 var board=document.getElementById("kdsBoard"), qlist=document.getElementById("kdsQueueList");
 var station=document.getElementById("kdsStation"), outlet=document.getElementById("kdsOutlet");
 var view=document.getElementById("kdsView"), search=document.getElementById("kdsSearch");
 var live=document.getElementById("kdsLive"), clock=document.getElementById("kdsClock");
 var token=(document.querySelector("input[name=_csrf]")||{}).value||'';
 var sound=false, sig=initial.sig||"", lastQueued=(initial.stats||{}).queued||0, audio=null;
 var lanes=[["new",["queued","accepted"],"New tickets"],["prep",["preparing"],"On the line"],["ready",["ready"],"On the pass"],["done",["served"],"Served"]];
 function esc(s){return String(s==null?"":s).replace(/[&<>"']/g,function(c){return {"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#39;"}[c]})}
 function age(t){var m=Math.floor((Date.now()-new Date(t.replace(" ","T")))/60000);return isNaN(m)?0:m}
 function beep(){if(!sound)return;try{audio=audio||new (window.AudioContext||window.webkitAudioContext)();var o=audio.createOscillator(),g=audio.createGain();o.frequency.value=880;g.gain.value=.08;o.connect(g);g.connect(audio.destination);o.start();o.stop(audio.currentTime+.12)}catch(e){}}
 function render(data){
  var groups=data.orders||[];
  board.innerHTML=lanes.map(function(l){
   var cards=[];
   groups.forEach(function(o){
    var its=o.items.filter(function(i){return l[1].indexOf(i.kds_status)>=0});
    if(!its.length)return;
    var a=Math.max.apply(null,its.map(function(i){return age(i.created_at||o.created_at)}));
    var cls=a>=15?"late":(a>=8?"warn":"");
    var items=its.map(function(i){
     var next=i.kds_status==="queued"?["accepted","Accept"]:(i.kds_status==="accepted"?["preparing","Start"]:(i.kds_status==="preparing"?["ready","Ready"]:(i.kds_status==="ready"?["served","Served"]:null)));
     var st=i.station_name?esc(i.station_name)+" &middot; ":"";
     var rush=i.priority!=="normal"?'<span class="badge bad">'+esc(i.priority)+'</span> ':'';
     var btn=next?'<button class="kds-btn '+(next[0]==="served"?"ok":"go")+'" data-act="status" data-id="'+i.kds_id+'" data-status="'+next[0]+'">'+next[1]+'</button>':'';
     btn+='<button class="kds-btn" data-act="priority" data-id="'+i.kds_id+'" data-priority="'+(i.priority==="normal"?"rush":"normal")+'">'+(i.priority==="normal"?"Rush":"Undo")+'</button>';
     return '<div class="kds-item"><div><div class="nm">'+rush+esc(i.name)+' <b>&times;'+Number(i.quantity)+'</b></div><div class="sub">'+st+esc(i.item_notes||"")+(i.recall_count?' &middot; recalled x'+i.recall_count:'')+'</div></div><div class="acts">'+btn+'</div></div>';
    }).join("");
    var badge=i=>(i==="queued"?"New":i==="ready"?"Ready":i==="preparing"?"Cooking":i);
    var heads=Object.keys(its.reduce(function(a,i){a[i.kds_status]=1;return a},{})).map(badge).join(" / ");
    cards.push('<article class="kds-card '+l[0]+(its.some(function(i){return i.priority!=="normal"})?" rush":"")+'"><div class="kds-head"><b>'+esc(o.number)+'</b><span class="badge '+l[0]+'">'+esc(heads)+'</span></div>'
     +'<div class="kds-meta"><span>'+esc(o.outlet==="room_service"?"Room service":o.outlet)+'</span><span>'+esc(o.type)+'</span>'
     +(o.table?'<span>'+esc(o.table)+'</span>':'')+(o.customer?'<span>'+esc(o.customer)+'</span>':'')
     +'<span class="age '+cls+'">'+a+' min</span></div>'+items
     +'<div class="kds-foot"><button class="kds-btn" data-act="ticket" data-oid="'+o.id+'">KOT</button>'
     +((data.payments&&data.payments[o.id]&&data.payments[o.id].length)?'<button class="kds-btn" data-act="receipt" data-pid="pay-'+data.payments[o.id][0]+'">Receipt</button>':'')
     +(l[0]!=="done"?'<button class="kds-btn ok" data-act="bump" data-oid="'+o.id+'">Bump all</button>':'<button class="kds-btn" data-act="recall" data-oid="'+o.id+'">Recall</button>')+'</div></article>');
   });
   return '<section class="kds-lane"><h3><span>'+l[2]+'</span><span>'+cards.length+'</span></h3>'+(cards.join("")||'<div class="kds-empty">Nothing here</div>')+'</section>';
  }).join("");
  qlist.innerHTML=(data.prints||[]).map(function(p){return '<div class="kds-qrow"><span>'+esc(p.order_number||"Order")+(p.station_name?' &middot; '+esc(p.station_name):'')+' &middot; <b>'+esc(p.status)+'</b></span><span><button class="kds-btn" data-act="ticket" data-oid="'+p.order_id+'">Print</button> '+(p.status==="queued"?'<button class="kds-btn" data-act="printed" data-pid="'+p.id+'">Mark printed</button>':'')+'</span></div>'}).join("")||'<div class="kds-empty">No tickets waiting to print</div>';
  var q=document.getElementById("kdsQueueCount");if(q)q.textContent=(data.prints||[]).length;
  var late=document.getElementById("kdsLate");if(late)late.textContent=((data.stats||{}).late||0)+" late";
  if(((data.stats||{}).queued||0)>lastQueued)beep();
  lastQueued=(data.stats||{}).queued||0;
  sig=data.sig||sig;
 }
 function load(){
  var p=new URLSearchParams({act:"feed",station:station.value,outlet:outlet.value,view:view.value,q:search.value});
  fetch("index.php?page=kds&"+p.toString(),{cache:"no-store"}).then(function(r){return r.json()}).then(function(d){
   clock.textContent=d.at;live.className="kds-live";
   if(d.sig!==sig)render(d);
  }).catch(function(){live.className="kds-live off"});
 }
 function post(body){
  var p=new URLSearchParams(body);p.set("_csrf",token);
  fetch("index.php?page=kds",{method:"POST",headers:{"Content-Type":"application/x-www-form-urlencoded"},body:p.toString()}).then(function(r){return r.json()}).then(function(r){if(r.ok)load()}).catch(function(){});
 }
 document.addEventListener("click",function(e){
  var b=e.target.closest("[data-act]");if(!b)return;
  var a=b.getAttribute("data-act"),oid=b.getAttribute("data-oid");
  if(a==="ticket"){window.open("index.php?page=kds&act=ticket&oid="+oid,"_blank","width=420,height=700");return}
  if(a==="receipt"){if(window.printReceipt)window.printReceipt(b.getAttribute("data-pid"));return}
  if(a==="status")post({action:"status",id:b.getAttribute("data-id"),status:b.getAttribute("data-status")});
  if(a==="priority")post({action:"priority",id:b.getAttribute("data-id"),priority:b.getAttribute("data-priority")});
  if(a==="bump")post({action:"bump",oid:oid});
  if(a==="recall")post({action:"recall",oid:oid});
  if(a==="printed")post({action:"printed",pid:b.getAttribute("data-pid")});
 });
 document.getElementById("kdsRefresh").addEventListener("click",load);
 document.getElementById("kdsSound").addEventListener("click",function(){sound=!sound;this.textContent="Sound: "+(sound?"on":"off");if(sound)beep()});
 [station,outlet,view].forEach(function(el){el.addEventListener("change",function(){sig="" ;load()})});
 var t;search.addEventListener("input",function(){clearTimeout(t);t=setTimeout(function(){sig="";load()},250)});
 window.addEventListener("afterprint",function(){
  var waiting=(initial.prints||[]).filter(function(p){return p.status==="queued"});
  waiting.forEach(function(p){post({action:"printed",pid:p.id})});
 });
 render(initial);load();setInterval(load,4000);
})();
<\/script>
JS;

$ticketGroups=[];
foreach($initialItems as $i){
 $oid=(int)$i['order_id'];
 if(!isset($ticketGroups[$oid])) $ticketGroups[$oid]=['order'=>null,'lines'=>[]];
 $ticketGroups[$oid]['lines'][]=$i;
}
foreach($ticketGroups as $oid=>$g){
 $o=row('SELECT * FROM orders WHERE id=?',[$oid]);
 if(!$o) continue;
 $lines=[];
 foreach($g['lines'] as $i){
  $lines[]=['name'=>(string)($i['name']??'Item removed'),'qty'=>'x'.rtrim(rtrim(number_format((float)$i['quantity'],2,'.',''),'0'),'.'),
   'note'=>trim(trim((string)($i['item_notes']??'')).' '.((string)($i['station_name']??'')!==''?'['.(string)$i['station_name'].']':'')),
   'amount'=>null];
 }
 $meta=['Outlet'=>ucfirst((string)$o['outlet']),'Service'=>(string)$o['order_type']==='room'?'Room service':ucfirst(str_replace('_',' ',(string)$o['order_type'])),'Placed'=>fmtdt($o['created_at'])];
 if((string)$o['table_name']!=='') $meta['Table / room']=(string)$o['table_name'];
 if((string)$o['customer_name']!=='') $meta['Guest']=(string)$o['customer_name'];
 if((string)$o['customer_phone']!=='') $meta['Phone']=(string)$o['customer_phone'];
 if((string)$o['delivery_address']!=='') $meta['Deliver to']=(string)$o['delivery_address'];
 receipt_template('kot-'.$oid,receipt_sheet(['kind'=>'KITCHEN ORDER TICKET','number'=>(string)$o['order_number'],'meta'=>$meta,'lines'=>$lines,'foot'=>'Live kitchen display']),strtotime((string)$o['created_at'])>=time()-90);
}
foreach(kds_payments() as $oid=>$pids){
 foreach($pids as $pid){ if(function_exists('receipts_hotel_template')) receipts_hotel_template((int)$pid,false); }
}
receipt_print('kds',BASE.'/index.php?page=kds&act=feed');

$reqDept=stock_request_department_by_code('KC');
if($reqDept) stock_request_department_panel($reqDept,'kitchen','Kitchen stock request');

page_foot();
