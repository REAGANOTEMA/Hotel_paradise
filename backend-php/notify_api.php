<?php
declare(strict_types=1);

/**
 * The console's small JSON door for notifications.
 *
 * The public website talks to api.php; this is its counterpart for a signed-in
 * member of staff. Everything here needs a live console session - there is no
 * anonymous way in. It is deliberately small: feed the bell, save a device's
 * push subscription, mark things read, save category preferences, and send one
 * test notification.
 */

require __DIR__.'/app/bootstrap.php';
require __DIR__.'/app/notify.php';

header('Content-Type: application/json; charset=utf-8');

$out=function(array $data,int $code=200): void{ http_response_code($code); echo json_encode($data,JSON_UNESCAPED_UNICODE); exit; };

$u=current_user();
if(!$u){ $out(['ok'=>false,'error'=>'Not signed in'],401); }
$uid=(int)$u['id'];

$method=$_SERVER['REQUEST_METHOD'];
$act=(string)($_GET['act']??'');
$body=[];
if($method==='POST'){
 $raw=file_get_contents('php://input');
 $decoded=json_decode($raw,true);
 if(is_array($decoded)) $body=$decoded; else $body=$_POST;
}

if(!notify_ready()){
 $out(['ok'=>false,'error'=>'Notifications are not installed yet. Run database/sql/patches/2026_notifications_push.sql.','installed'=>false],503);
}

/* ---- the bell: unread count and the latest few ---------------------------- */
if($act==='feed'){
 // Send any queued push while somebody is here watching, so a phone rings
 // without a separate worker. A failure here is never fatal to the feed.
 $delivery=null;
 try{ $delivery=notify_process_queue(20); }catch(\Throwable $e){ error_log('[hotel notify] feed send: '.$e->getMessage()); }
 $vapid=\WebPush\vapid();
 $out([
  'ok'=>true,
  'installed'=>true,
  'configured'=>\WebPush\configured(),
  'vapid_public'=>$vapid['public']??'',
  'unread'=>notify_unread($uid),
  'items'=>array_map(fn($n)=>[
   'id'=>(int)$n['id'],'type'=>(string)$n['type'],'title'=>(string)$n['title'],
   'body'=>(string)$n['body'],'read'=>(bool)$n['read_at'],'when'=>fmtdt($n['created_at'])
  ],notify_list($uid,10)),
  'delivery'=>$delivery,
 ]);
}

/* ---- a device stores its push subscription here --------------------------- */
if($act==='subscribe'){
 if($method!=='POST') $out(['ok'=>false,'error'=>'POST required'],405);
 $endpoint=trim((string)($body['endpoint']??''));
 $p256dh=trim((string)($body['p256dh']??''));
 $auth=trim((string)($body['auth']??''));
 if($endpoint===''||strlen($endpoint)>500){ $out(['ok'=>false,'error'=>'Missing push endpoint'],422); }
 if($p256dh===''||$auth===''){ $out(['ok'=>false,'error'=>'Missing push keys'],422); }
 $ua=substr((string)($_SERVER['HTTP_USER_AGENT']??''),0,255);
 try{
  // One row per endpoint: a re-subscribe refreshes the keys and switches it
  // back on rather than piling up duplicate devices.
  q("INSERT INTO notification_devices(user_id,platform,push_token,p256dh,auth,user_agent,active,last_seen_at,created_at)"
    ." VALUES(?, 'web', ?, ?, ?, ?, 1, NOW(), NOW())"
    .' ON DUPLICATE KEY UPDATE user_id=VALUES(user_id),p256dh=VALUES(p256dh),auth=VALUES(auth),'
    .'user_agent=VALUES(user_agent),active=1,last_seen_at=NOW()',
   [$uid,$endpoint,$p256dh,$auth,$ua]);
 }catch(\Throwable $e){
  error_log('[hotel notify] subscribe: '.$e->getMessage());
  $out(['ok'=>false,'error'=>'Could not save this device'],500);
 }
 $out(['ok'=>true,'message'=>'This device will now receive notifications.']);
}

/* ---- switch push off for one device --------------------------------------- */
if($act==='unsubscribe'){
 if($method!=='POST') $out(['ok'=>false,'error'=>'POST required'],405);
 $endpoint=trim((string)($body['endpoint']??''));
 if($endpoint!==''){ try{ q('UPDATE notification_devices SET active=0 WHERE user_id=? AND push_token=?',[$uid,$endpoint]); }catch(\Throwable $e){} }
 $out(['ok'=>true]);
}

/* ---- forget a device from the settings list ------------------------------- */
if($act==='device_remove'){
 if($method!=='POST') $out(['ok'=>false,'error'=>'POST required'],405);
 $id=(int)($body['id']??0);
 if($id>0){ try{ q('UPDATE notification_devices SET active=0 WHERE id=? AND user_id=?',[$id,$uid]); }catch(\Throwable $e){} }
 $out(['ok'=>true]);
}

/* ---- read state ----------------------------------------------------------- */
if($act==='read'){
 if($method!=='POST') $out(['ok'=>false,'error'=>'POST required'],405);
 $id=(int)($body['id']??0);
 if($id>0){ q('UPDATE notifications SET read_at=NOW() WHERE id=? AND user_id=? AND read_at IS NULL',[$id,$uid]); }
 $out(['ok'=>true,'unread'=>notify_unread($uid)]);
}
if($act==='read_all'){
 if($method!=='POST') $out(['ok'=>false,'error'=>'POST required'],405);
 q('UPDATE notifications SET read_at=NOW() WHERE user_id=? AND read_at IS NULL',[$uid]);
 $out(['ok'=>true,'unread'=>0]);
}

/* ---- category preferences ------------------------------------------------- */
if($act==='prefs'){
 if($method!=='POST') $out(['ok'=>false,'error'=>'POST required'],405);
 $cols=array_values(NOTIFY_CATEGORIES);
 $vals=[]; foreach($cols as $c){ $vals[]=((int)($body[$c]??0)===1)?1:0; }
 try{
  q('INSERT INTO notification_preferences(user_id,'.implode(',',$cols).',updated_at) VALUES(?,'.rtrim(str_repeat('?,',count($cols)),',').',NOW())'
    .' ON DUPLICATE KEY UPDATE '.implode(',',array_map(fn($c)=>$c.'=VALUES('.$c.')',$cols)).',updated_at=NOW()',
   array_merge([$uid],$vals));
 }catch(\Throwable $e){ $out(['ok'=>false,'error'=>'Could not save preferences'],500); }
 $out(['ok'=>true,'message'=>'Preferences saved.']);
}

/* ---- one test notification to me ------------------------------------------ */
if($act==='test'){
 if($method!=='POST') $out(['ok'=>false,'error'=>'POST required'],405);
 $delivery=notify_send_test($uid);
 $out(['ok'=>true,'delivery'=>$delivery,
  'message'=>$delivery['configured']
   ? 'A test was queued. If a device is subscribed it should ring within a moment.'
   : 'The test was saved to your notifications. Push delivery needs VAPID keys (run tools/make-vapid-keys.php).']);
}

$out(['ok'=>false,'error'=>'Unknown request'],404);