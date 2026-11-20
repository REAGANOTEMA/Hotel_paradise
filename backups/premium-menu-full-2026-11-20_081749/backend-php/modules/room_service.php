<?php
declare(strict_types=1);

require_once __DIR__.'/../app/kds.php';

$act=(string)($_GET['act']??'');
$u=current_user();
$uid=(int)($u['id']??0);

if($act==='feed'){
 header('Content-Type: application/json; charset=utf-8');
 $items=kds_items(['outlet'=>'room_service','status'=>['queued','accepted','preparing','ready','served']]);
 $orders=kds_group($items);
 $out=[];
 foreach($orders as $o){
  $out[]=['id'=>$o['id'],'number'=>$o['number'],'room'=>$o['table'],'customer'=>$o['customer'],'phone'=>$o['phone'],'address'=>$o['address'],'notes'=>$o['notes'],'created_at'=>$o['created_at'],'status'=>$o['status'],'items'=>$o['items']];
 }
 echo json_encode(['sig'=>md5(json_encode($out,JSON_UNESCAPED_UNICODE)),'orders'=>$out,'at'=>date('H:i:s')],JSON_UNESCAPED_UNICODE);
 exit;
}

if($_SERVER['REQUEST_METHOD']==='POST'){
 $action=(string)($_POST['action']??'');
 $oid=(int)($_POST['oid']??0);
 if($action==='dispatch') $r=kds_dispatch_room($oid,(string)($_POST['runner']??''),(string)($_POST['eta']??''),$uid);
 elseif($action==='deliver') $r=kds_bump_order($oid,$uid);
 elseif($action==='recall') $r=kds_recall_order($oid,$uid);
 else $r=['ok'=>false];
 header('Content-Type: application/json; charset=utf-8');
 echo json_encode($r,JSON_UNESCAPED_UNICODE);
 exit;
}

$items=kds_items(['outlet'=>'room_service','status'=>['queued','accepted','preparing','ready','served']]);
$orders=kds_group($items);
$open=count(array_filter($orders,static fn(array $o):bool=>!in_array($o['status'],['served','cancelled'],true)));
$ready=count(array_filter($orders,static fn(array $o):bool=>in_array($o['status'],['ready','preparing'],true)));
$done=count(array_filter($orders,static fn(array $o):bool=>$o['status']==='served'));
$staff=rows("SELECT id,name FROM users WHERE status='active' ORDER BY name LIMIT 100");

page_head('Room Service','room_service','in-room dining dispatch');
echo '<div class="kpis">';
kpi_card('Open orders',(string)$open,'Live in-room orders',$open?'gold':'navy');
kpi_card('In production',(string)$ready,'Kitchen or on the way',$ready?'blue':'navy');
kpi_card('Delivered today',(string)$done,'Completed and closed');
echo '</div>';

echo '<div class="panel"><h2>Room service dispatch</h2><p class="hint">Every in-room order, its runner and its promised time live here. Dispatch and delivery are written to the order itself.</p>';
echo '<div id="rsList" class="rs-list">';
$token=(string)(csrf_token());
echo '<script id="rsToken" type="application/json">'.json_encode(['token'=>$token],JSON_HEX_TAG|JSON_HEX_AMP).'<\/script>';
echo '</div></div>';

echo '<script id="rsInitial" type="application/json">'.json_encode(['orders'=>$orders,'staff'=>$staff],JSON_UNESCAPED_UNICODE|JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT).'<\/script>';
echo '<style>
.rs-list{display:flex;flex-direction:column;gap:10px}
.rs-card{border:1px solid var(--line);border-left:5px solid #2e7d32;border-radius:12px;padding:12px;background:#fff}
.rs-card.wait{border-left-color:#c62828}.rs-card.cook{border-left-color:#0B5D78}
.rs-head{display:flex;justify-content:space-between;gap:8px;flex-wrap:wrap;align-items:center}
.rs-head b{font-family:\'Playfair Display\',serif;color:var(--navy);font-size:16px}
.rs-meta{font-size:12px;color:var(--muted);margin:4px 0 8px}
.rs-items{font-size:13px;color:var(--navy);margin:0 0 9px;padding-left:18px}
.rs-actions{display:flex;gap:6px;flex-wrap:wrap;align-items:center}
.rs-actions select,.rs-actions input{height:32px;border:1px solid var(--line);border-radius:7px;padding:0 8px;font-size:12px;background:#fff;color:var(--navy)}
.rs-btn{border:1px solid #0f285033;background:#fff;border-radius:7px;padding:6px 10px;font-size:12px;font-weight:700;color:#0f2850;cursor:pointer}
.rs-btn.go{background:#0B5D78;color:#fff;border-color:#0B5D78}.rs-btn.ok{background:#2e7d32;color:#fff;border-color:#2e7d32}
</style>';

echo <<<'JS'
<script>
(function(){
 var init=JSON.parse(document.getElementById("rsInitial").textContent);
 var token=JSON.parse(document.getElementById("rsToken").textContent).token;
 var box=document.getElementById("rsList");
 function esc(s){return String(s==null?"":s).replace(/[&<>"']/g,function(c){return {"&":"&amp;","<":"&lt;",">":"&gt;","\"":"&quot;","'":"&#39;"}[c]})}
 function render(orders){
  box.innerHTML=orders.map(function(o){
   var names=o.items.map(function(i){return "&times;"+Number(i.quantity)+" "+esc(i.name)});
   var opts=init.staff.map(function(s){return "<option value=\""+esc(s.name)+"\">"+esc(s.name)+"</option>"}).join("");
   var cls=o.status==="ready"||o.status==="preparing"?"cook":(o.status==="pending"?"wait":"");
   return "<article class=\"rs-card "+cls+"\"><div class=\"rs-head\"><b>"+esc(o.number)+"</b><span class=\"badge "+cls+"\">"+esc(o.status)+"</span></div>"
    +"<div class=\"rs-meta\">Room "+esc(o.room||"—")+" &middot; "+esc(o.customer||"Guest")+(o.phone?" &middot; "+esc(o.phone):"")+" &middot; placed "+esc(o.created_at)+"</div>"
    +(o.notes?"<div class=\"rs-meta\">Note: "+esc(o.notes)+"</div>":"")
    +"<ul class=\"rs-items\">"+names.map(function(n){return "<li>"+n+"</li>"}).join("")+"</ul>"
    +"<div class=\"rs-actions\"><select data-runner><option value=\"\">Unassigned runner</option>"+opts+"</select>"
    +"<input type=\"time\" data-eta><button class=\"rs-btn go\" data-do=\"dispatch\" data-id=\""+o.id+"\">Dispatch</button>"
    +"<button class=\"rs-btn ok\" data-do=\"deliver\" data-id=\""+o.id+"\">Delivered</button>"
    +"<button class=\"rs-btn\" data-do=\"recall\" data-id=\""+o.id+"\">Recall</button>"
    +"<button class=\"rs-btn\" data-do=\"ticket\" data-id=\""+o.id+"\">KOT</button></div></article>";
  }).join("")||"<div class=\"kds-empty\">No in-room orders right now.</div>";
 }
 function post(body){var p=new URLSearchParams(body);p.set("_csrf",token);fetch("index.php?page=room_service",{method:"POST",headers:{"Content-Type":"application/x-www-form-urlencoded"},body:p.toString()}).then(function(r){return r.json()}).then(function(r){if(r.ok)load()})}
 function load(){fetch("index.php?page=room_service&act=feed",{cache:"no-store"}).then(function(r){return r.json()}).then(function(d){render(d.orders)})}
 document.addEventListener("click",function(e){
  var b=e.target.closest("[data-do]");if(!b)return;
  var card=b.closest(".rs-card"),id=b.getAttribute("data-id"),doit=b.getAttribute("data-do");
  if(doit==="ticket"){window.open("index.php?page=kds&act=ticket&oid="+id,"_blank","width=420,height=700");return}
  if(doit==="dispatch"){
   var t=card.querySelector("[data-eta]").value||"";
   post({action:"dispatch",oid:id,runner:card.querySelector("[data-runner]").value,eta:t});
  }else post({action:doit==="deliver"?"deliver":"recall",oid:id});
 });
 render(init.orders);load();setInterval(load,6000);
})();
<\/script>
JS;

page_foot();
