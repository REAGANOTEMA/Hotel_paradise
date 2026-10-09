<?php
declare(strict_types=1);

/**
 * Notifications, in the console.
 *
 * One screen with three jobs: show a member what has happened, let them put
 * this phone on the list that gets rung, and let them choose which kinds of
 * news are worth ringing about. Everything that changes state does so through
 * notify_api.php, so the same rules hold whether the page is used or the API.
 */

require_once __DIR__.'/../app/notify.php';

$u=current_user();
$uid=(int)($u['id']??0);

$installed=notify_ready();
$vapid=\WebPush\vapid();
$pushConfigured=$installed && \WebPush\configured();

/* A no-JavaScript fallback for the two things people expect a form to do. */
if($_SERVER['REQUEST_METHOD']==='POST' && $installed){
 $act=(string)($_GET['act']??'');
 if($act==='prefs'){
  $cols=array_values(NOTIFY_CATEGORIES);
  $vals=[]; foreach($cols as $c){ $vals[]=isset($_POST[$c])?1:0; }
  q('INSERT INTO notification_preferences(user_id,'.implode(',',$cols).',updated_at) VALUES(?,'.rtrim(str_repeat('?,',count($cols)),',').',NOW())'
    .' ON DUPLICATE KEY UPDATE '.implode(',',array_map(fn($c)=>$c.'='.$c,$cols)).',updated_at=NOW()',array_merge([$uid],$vals));
  flash('Your notification preferences were saved.');
  go('notifications');
 }
 if($act==='read_all'){
  q('UPDATE notifications SET read_at=NOW() WHERE user_id=? AND read_at IS NULL',[$uid]);
  flash('All notifications marked as read.');
  go('notifications');
 }
}

$unread=$installed?notify_unread($uid):0;
$items=$installed?notify_list($uid,40):[];
$devices=$installed?notify_devices($uid):[];
$devicesActive=count(array_filter($devices,fn($d)=>(int)$d['active']===1));

$prefs=[];
foreach(NOTIFY_CATEGORIES as $cat=>$col){
 $prefs[$cat]=true;
 if($installed){
  $r=row('SELECT '.$col.' AS on_ FROM notification_preferences WHERE user_id=?',[$uid]);
  if($r!==null) $prefs[$cat]=((int)$r['on_']===1);
 }
}
$catLabel=['booking'=>'Bookings','order'=>'Restaurant orders','payment'=>'Payments','communication'=>'Messages','incident'=>'Incidents'];

page_head('Notifications','notifications','What has happened, and the phones that hear about it');

if(!$installed){
 echo '<div class="panel"><h2>Notifications are not switched on yet</h2>';
 echo '<p class="hint">The notification tables are not in the database. This is safe to fix: the migration only adds tables and one column, and it leaves every existing record exactly as it is.</p>';
 echo '<p class="hint">Run this once, then reload:</p>';
 echo '<pre style="background:#0f172a;color:#e2e8f0;padding:12px 14px;border-radius:6px;overflow:auto">C:\\xampp\\mysql\\bin\\mysql.exe -u root hotelpardise_system &lt; database\\sql\\patches\\2026_notifications_push.sql</pre>';
 echo '<p class="hint">Push delivery and the in-app list are the same system, so once this runs, both work.</p></div>';
 page_foot();
 exit;
}

/* ---- the numbers ---- */
echo '<div class="kpis">';
 kpi_card('Unread',$unread>0?(string)$unread:'0',$unread>0?'Waiting for you':'All read',$unread>0?'gold':'ok');
 kpi_card('Devices on this account',(string)$devicesActive,$devicesActive===1?'one phone or browser':'phones and browsers','navy');
 kpi_card('Push delivery',$pushConfigured?'Ready':'Not configured',$pushConfigured?'VAPID keys in place':'run tools/make-vapid-keys.php',$pushConfigured?'ok':'warn');
echo '</div>';

echo '<div class="twoCol">';

/* ---- this device ---- */
echo '<div class="panel"><h2>This device</h2>';
echo '<p class="hint">Turn on notifications and this phone or browser is rung whenever something below happens. Nothing is shared with anyone outside the hotel: the browser is handed the message directly by the push service.</p>';
if(!$pushConfigured){
 echo '<div class="flash warn"><span class="noteIco">!</span><span>Push delivery is not configured on this server yet. The in-app list still works. To switch push on, run <b>php tools/make-vapid-keys.php</b> once.</span></div>';
}
echo '<div id="pushState" class="notifyState" aria-live="polite">Checking this device…</div>';
echo '<div class="row" style="display:flex;gap:10px;flex-wrap:wrap;margin-top:10px">';
echo '<button type="button" class="btn" id="enablePush">Enable notifications on this device</button>';
echo '<button type="button" class="btnGhost" id="sendTest">Send a test</button>';
echo '</div>';
echo '<p class="hint" style="margin-top:12px">If this device is already subscribed, enabling again simply refreshes it.</p>';
echo '</div>';

/* ---- which news, and the device list ---- */
echo '<div>';
 echo '<div class="panel"><h2>What to notify me about</h2>';
 echo '<p class="hint">A switch off means the event still appears in the list, but no phone is rung for it.</p>';
 echo '<form method="post" action="'.BASE.'/index.php?page=notifications&act=prefs">';
 foreach(NOTIFY_CATEGORIES as $cat=>$col){
  echo '<label class="toggleRow"><span>'.e($catLabel[$cat]??ucfirst($cat)).'</span>';
  echo '<input type="checkbox" name="'.e($col).'"'.($prefs[$cat]?' checked':'').'><span class="switch" aria-hidden="true"></span></label>';
 }
 echo '<button class="btn" style="margin-top:12px">Save preferences</button>';
 echo '</form></div>';

 echo '<div class="panel"><h2>Devices that can be rung</h2>';
 if($devices===[]){
  empty_state('No devices yet','Enable notifications on a phone and it will appear here.');
 }else{
  echo '<div class="tableScroll"><table class="tbl"><thead><tr><th>Device</th><th>Added</th><th>Last seen</th><th>Status</th></tr></thead><tbody>';
  foreach($devices as $d){
   $active=(int)$d['active']===1;
   echo '<tr><td>'.e(substr((string)($d['user_agent']??''),0,60)?:'Web browser').'</td>';
   echo '<td>'.e(fmtdt($d['created_at'])).'</td>';
   echo '<td>'.e(fmtdt($d['last_seen_at'])).'</td>';
   echo '<td>'.($active?badge('active','ok'):badge('off','grey')).'</td></tr>';
  }
  echo '</tbody></table></div>';
 }
 echo '</div>';
echo '</div>';
echo '</div>';

/* ---- the list ---- */
echo '<div class="panel"><div class="panelHead"><h2>Notifications</h2>';
if($unread>0){
 echo '<form method="post" action="'.BASE.'/index.php?page=notifications&act=read_all"><button class="btnGhost sm">Mark all read</button></form>';
}
echo '</div>';
if($items===[]){
 empty_state('Nothing yet','Bookings, orders and payments raised on the website will show up here.');
}else{
 echo '<ul class="notifyList" id="notifyList">';
 foreach($items as $n){
  $isRead=$n['read_at']!==null;
  echo '<li class="'.($isRead?'':'unread').'" data-id="'.(int)$n['id'].'">';
  echo '<span class="nIco">'.svg_icon($n['type']==='payment'?'coins':($n['type']==='order'?'pot':($n['type']==='booking'?'calendar':'bell'))).'</span>';
  echo '<div class="nBody"><b>'.e($n['title']).'</b><p>'.e($n['body']).'</p><small>'.e(fmtdt($n['created_at'])).'</small></div>';
  if(!$isRead) echo '<button type="button" class="nRead linkish" data-id="'.(int)$n['id'].'">Mark read</button>';
  echo '</li>';
 }
 echo '</ul>';
}
echo '</div>';

$base=json_encode(BASE);
$vapidJs=json_encode($vapid['public']??'');
$canPush=$pushConfigured?'true':'false';
echo <<<HTML
<script>
(function(){
 var BASE={$base}, VAPID={$vapidJs}, CAN_PUSH={$canPush};
 var state=document.getElementById('pushState');
 function setState(t,cls){ if(state){ state.textContent=t; state.className='notifyState'+(cls?' '+cls:''); } }

 function urlB64(b){
  var pad='='.repeat((4-b.length%4)%4);
  var s=(b+pad).replace(/-/g,'+').replace(/_/g,'/');
  var raw=atob(s), arr=new Uint8Array(raw.length);
  for(var i=0;i<raw.length;i++) arr[i]=raw.charCodeAt(i);
  return arr;
 }
 function api(act,payload){
  return fetch(BASE+'/notify_api.php?act='+act,{
   method:'POST',credentials:'same-origin',
   headers:{'Content-Type':'application/json'},
   body:JSON.stringify(payload||{})
  }).then(function(r){ return r.json(); });
 }

 if(!('serviceWorker' in navigator) || !('PushManager' in window)){
  setState('This browser cannot receive push notifications. The list below still works.','warn');
 }else{
  navigator.serviceWorker.register(BASE+'/sw.js',{scope:BASE+'/'}).catch(function(){});
  navigator.serviceWorker.ready.then(function(reg){
   return reg.pushManager.getSubscription();
  }).then(function(sub){
   if(sub) setState('This device is subscribed and will be rung.','ok');
   else setState('Not enabled on this device yet.','');
  }).catch(function(){});
 }

 var enable=document.getElementById('enablePush');
 if(enable) enable.addEventListener('click',function(){
  if(!('serviceWorker' in navigator) || !('PushManager' in window)){ setState('This browser cannot receive push notifications.','warn'); return; }
  if(!CAN_PUSH){ setState('Push is not configured on the server yet.','warn'); return; }
  setState('Asking the browser…','');
  navigator.serviceWorker.ready.then(function(reg){
   return Notification.requestPermission().then(function(p){
    if(p!=='granted'){ setState('Permission was not given. The list below still works.','warn'); return null; }
    return reg.pushManager.subscribe({userVisibleOnly:true,applicationServerKey:urlB64(VAPID)});
   }).then(function(sub){
    if(!sub) return;
    var j=sub.toJSON();
    return api('subscribe',{endpoint:j.endpoint,p256dh:j.keys.p256dh,auth:j.keys.auth}).then(function(r){
     setState(r.ok?'This device is subscribed and will be rung.':'Could not save this device: '+(r.error||''),r.ok?'ok':'warn');
    });
   });
  }).catch(function(e){ setState('Could not enable notifications: '+e.message,'warn'); });
 });

 var test=document.getElementById('sendTest');
 if(test) test.addEventListener('click',function(){
  setState('Sending a test…','');
  api('test',{}).then(function(r){
   setState(r.message||'Test queued.',r.ok?'ok':'warn');
  }).catch(function(){ setState('Could not send the test.','warn'); });
 });

 document.querySelectorAll('.nRead').forEach(function(b){
  b.addEventListener('click',function(){
   api('read',{id:parseInt(b.getAttribute('data-id'),10)}).then(function(){
    var li=b.closest('li'); if(li){ li.classList.remove('unread'); b.remove(); }
   });
  });
 });

 /* The bell in the header uses the same feed, so the count here stays honest. */
 var box=document.getElementById('notifyList');
 if(box) box.addEventListener('click',function(e){
  var li=e.target.closest('li'); if(!li) return;
  var id=parseInt(li.getAttribute('data-id'),10);
  if(id && li.classList.contains('unread')){
   api('read',{id:id}).then(function(){ li.classList.remove('unread'); var b=li.querySelector('.nRead'); if(b) b.remove(); });
  }
 });
})();
</script>
HTML;

page_foot();