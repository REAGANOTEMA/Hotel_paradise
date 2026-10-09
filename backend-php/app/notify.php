<?php
declare(strict_types=1);

/**
 * Notifications, the hotel's own. One place to turn a real business event - a
 * booking placed, an order sent to the kitchen, a payment recorded - into
 *
 *   1. an in-app notification a signed-in member reads in the console, and
 *   2. a push message queued for each phone or browser that member subscribed.
 *
 * Three rules shape everything here:
 *
 *   The books always win. Every call is wrapped so that a notification can
 *   never fail a booking, an order or a payment. If the notification tables are
 *   missing, this file says so and reports nothing else gone wrong.
 *
 *   One event, one notification. notification_events has a UNIQUE event_key,
 *   so a booking submitted twice (a double tap, a retry) never rings twice.
 *
 *   Honest delivery. A row is "accepted" only when the push service answered
 *   2xx. Otherwise it stays queued with a stated reason until its attempt
 *   budget runs out, and it never claims to have reached a phone it did not.
 *
 * The crypto and the network call live in app/webpush.php; this file is the
 * hotel logic around it.
 */

require_once __DIR__.'/webpush.php';

/** The alert category a business event belongs to, and its preference column. */
const NOTIFY_CATEGORIES = [
 'booking'       => 'booking_alerts',
 'order'         => 'order_alerts',
 'payment'       => 'payment_alerts',
 'communication' => 'communication_alerts',
 'incident'      => 'incident_alerts',
];

/** The roles each category rings by default, so callers need not repeat it. */
const NOTIFY_DEFAULT_ROLES = [
 'booking'       => ['director','general_manager','receptionist'],
 'order'         => ['director','general_manager','cashier','kitchen'],
 'payment'       => ['director','general_manager','accountant','cashier'],
 'communication' => ['director','general_manager'],
 'incident'      => ['director','general_manager'],
];

function notify_table(string $t): bool
{
 try{ return (int)val('SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?',[$t])>0; }
 catch(\Throwable $e){ return false; }
}

/** Whether the upgrade migration has been run. Cached per request. */
function notify_ready(): bool
{
 static $r=null;
 if($r!==null) return $r;
 return $r=(notify_table('notification_events') && notify_table('notification_deliveries')
  && notify_table('notifications') && notify_table('notification_devices')
  && notify_table('notification_preferences'));
}

/** Active members holding any of the named roles. */
function notify_recipients(array $roles): array
{
 if($roles===[]) return [];
 $ph=implode(',',array_fill(0,count($roles),'?'));
 return rows('SELECT DISTINCT u.id,u.name,u.email FROM users u'
  .' JOIN user_roles ur ON ur.user_id=u.id JOIN roles r ON r.id=ur.role_id'
  .' WHERE r.name IN ('.$ph.") AND u.status='active' ORDER BY u.id",$roles);
}

/** True when a member has the category switched on. A missing row means on. */
function notify_pref(int $userId,string $category): bool
{
 $col=NOTIFY_CATEGORIES[$category]??null;
 if($col===null) return true;
 try{
  $r=row('SELECT '.$col.' AS on_ FROM notification_preferences WHERE user_id=?',[$userId]);
  return $r===null?true:((int)$r['on_']===1);
 }catch(\Throwable $e){ return true; }
}

/**
 * Raises one business event. Safe to call from the public API: it never throws.
 *
 * @return array{ok:bool,duplicate:bool,notifications:int,queued:int,error:?string}
 */
function notify_dispatch(string $eventKey,string $category,string $title,string $body,
 array $data=[],array $roles=[],?int $excludeUserId=null,string $eventType='',?string $entityType=null,?int $entityId=null): array
{
 $fail=fn(string $m)=>['ok'=>false,'duplicate'=>false,'notifications'=>0,'queued'=>0,'error'=>$m];
 if(!notify_ready()) return $fail('notifications-not-installed');
 if($eventKey==='') return $fail('missing-event-key');
 if($roles===[]) $roles=NOTIFY_DEFAULT_ROLES[$category]??['director','general_manager'];

 try{
  // One event, one notification. Checking first keeps a retry from ringing
  // twice, and the UNIQUE key is the backstop if two requests race.
  if(val('SELECT id FROM notification_events WHERE event_key=?',[$eventKey])!==null){
   return ['ok'=>true,'duplicate'=>true,'notifications'=>0,'queued'=>0,'error'=>null];
  }
  q('INSERT INTO notification_events(event_key,event_type,entity_type,entity_id,created_at) VALUES(?,?,?,?,NOW())',
   [$eventKey,$eventType!==''?$eventType:$category,$entityType,$entityId]);
 }catch(\Throwable $e){
  return ['ok'=>true,'duplicate'=>true,'notifications'=>0,'queued'=>0,'error'=>null];
 }

 $made=0; $queued=0;
 try{
  foreach(notify_recipients($roles) as $u){
   $uid=(int)$u['id'];
   if($excludeUserId!==null && $uid===$excludeUserId) continue;
   if(!notify_pref($uid,$category)) continue;
   try{
    q('INSERT INTO notifications(user_id,type,title,body,data,created_at) VALUES(?,?,?,?,?,NOW())',
     [$uid,$category,$title,$body,$data===[]?null:json_encode($data,JSON_UNESCAPED_UNICODE)]);
    $nid=(int)db()->lastInsertId(); $made++;
    $queued+=notify_queue_for_user($nid,$uid);
   }catch(\Throwable $e){ error_log('[hotel notify] row for user '.$uid.' failed: '.$e->getMessage()); }
  }
 }catch(\Throwable $e){
  error_log('[hotel notify] dispatch '.$eventKey.' failed: '.$e->getMessage());
  return ['ok'=>false,'duplicate'=>false,'notifications'=>$made,'queued'=>$queued,'error'=>$e->getMessage()];
 }
 return ['ok'=>true,'duplicate'=>false,'notifications'=>$made,'queued'=>$queued,'error'=>null];
}

/**
 * Raises an event from a console action. The same guarantees as
 * notify_dispatch - the books always win, and this never throws - plus one rule
 * that only makes sense behind a sign-in: the member who performed the action
 * is not rung for it, so nobody is notified of the booking they just took or
 * the payment they just entered. Give it an event key unique to the action; the
 * UNIQUE key on notification_events then makes a double submit ring once.
 */
function notify_console(string $eventKey,string $category,string $title,string $body,
 array $data=[],array $roles=[],?string $entityType=null,?int $entityId=null): void
{
 try{
  $me=current_user();
  notify_dispatch($eventKey,$category,$title,$body,$data,$roles,$me['id']??null,'',$entityType,$entityId);
 }catch(\Throwable $e){
  error_log('[hotel notify] console '.$eventKey.' skipped: '.$e->getMessage());
 }
}

/** Queues one in-app notification for every push-capable device a member has. */
function notify_queue_for_user(int $notificationId,int $userId): int
{
 try{
  $devices=rows("SELECT id,push_token,p256dh,auth FROM notification_devices WHERE user_id=? AND active=1 AND platform='web'",[$userId]);
 }catch(\Throwable $e){ return 0; }
 $n=0;
 foreach($devices as $d){
  if(!is_string($d['p256dh'])||$d['p256dh']===''||!is_string($d['auth'])||$d['auth']==='') continue;
  try{
   // The UNIQUE (notification_id, device_id) keeps this to one row per device
   // even if a device subscribes again between the load and the insert.
   $st=q('INSERT IGNORE INTO notification_deliveries(notification_id,user_id,device_id,channel,status,created_at)'
     ." VALUES(?,?,?,'web_push','queued',NOW())",[$notificationId,$userId,(int)$d['id']]);
   if($st->rowCount()>0) $n++;
  }catch(\Throwable $e){ error_log('[hotel notify] queue device '.$d['id'].' failed: '.$e->getMessage()); }
 }
 return $n;
}

/**
 * Sends the queued push messages, a small batch at a time. Called by the
 * console's notifications page (and by the tools script), never inline with a
 * guest's booking.
 */
function notify_process_queue(int $limit=40): array
{
 $out=['sent'=>0,'failed'=>0,'retried'=>0,'skipped'=>0,'configured'=>\WebPush\configured()];
 if(!notify_ready()) return $out;
 $vapid=\WebPush\vapid();
 $pending=rows("SELECT d.id,d.attempts,d.notification_id,n.title,n.body,n.data,"
  .'dev.id device_id,dev.push_token,dev.p256dh,dev.auth'
  .' FROM notification_deliveries d'
  .' JOIN notifications n ON n.id=d.notification_id'
  .' LEFT JOIN notification_devices dev ON dev.id=d.device_id'
  ." WHERE d.status='queued' AND d.channel='web_push' ORDER BY d.id LIMIT ".(int)$limit);

 foreach($pending as $p){
  $did=(int)$p['id'];
  if($vapid===null){ $out['skipped']++; continue; }
  if(!is_string($p['push_token'])||$p['push_token']===''||!is_string($p['p256dh'])||$p['p256dh']===''||!is_string($p['auth'])||$p['auth']===''){
   q("UPDATE notification_deliveries SET status='failed',attempts=attempts+1,last_error=?,updated_at=NOW() WHERE id=?",
    ['Device is missing its push key material', $did]);
   $out['failed']++; continue;
  }
  $data=null;
  if(is_string($p['data'])&&$p['data']!==''){ $decoded=json_decode($p['data'],true); if(is_array($decoded)) $data=$decoded; }
  $payload=['title'=>(string)$p['title'],'body'=>(string)$p['body'],'data'=>$data?:new \stdClass(),
   // A tag replaces an earlier notification instead of stacking one per event.
   'tag'=>'hpn-'.(int)$p['notification_id']];
  $res=\WebPush\send((string)$p['push_token'],(string)$p['p256dh'],(string)$p['auth'],$payload,$vapid);
  $attempts=(int)$p['attempts']+1;
  if($res['ok']){
   q("UPDATE notification_deliveries SET status='accepted',attempts=?,provider_message_id=NULL,last_error=NULL,updated_at=NOW() WHERE id=?",[$attempts,$did]);
   $out['sent']++;
  }elseif(!empty($res['gone'])){
   q("UPDATE notification_deliveries SET status='failed',attempts=?,last_error=?,updated_at=NOW() WHERE id=?",[$attempts,(string)$res['error'],$did]);
   if($p['device_id']!==null){ q('UPDATE notification_devices SET active=0 WHERE id=?',[(int)$p['device_id']]); }
   $out['failed']++;
  }else{
   $status=$attempts>=5?'failed':'queued';
   q('UPDATE notification_deliveries SET status=?,attempts=?,last_error=?,updated_at=NOW() WHERE id=?',
    [$status,$attempts,(string)$res['error'],$did]);
   $status==='failed'?$out['failed']++:$out['retried']++;
  }
 }
 return $out;
}

/** How many unread notifications a member has, for the header bell. */
function notify_unread(int $userId): int
{
 try{ return (int)val('SELECT COUNT(*) FROM notifications WHERE user_id=? AND read_at IS NULL',[$userId]); }
 catch(\Throwable $e){ return 0; }
}

/** The latest notifications for a member, newest first. */
function notify_list(int $userId,int $limit=30): array
{
 try{
  return rows('SELECT id,type,title,body,data,read_at,created_at FROM notifications'
   .' WHERE user_id=? ORDER BY id DESC LIMIT '.(int)$limit,[$userId]);
 }catch(\Throwable $e){ return []; }
}

/** The devices a member has subscribed, for the settings page. */
function notify_devices(int $userId): array
{
 try{
  return rows('SELECT id,platform,user_agent,active,last_seen_at,created_at FROM notification_devices WHERE user_id=? ORDER BY id DESC',[$userId]);
 }catch(\Throwable $e){ return []; }
}

/** A notification a member sends to themselves, to prove the path end to end. */
function notify_send_test(int $userId): array
{
 if(!notify_ready()) return ['sent'=>0,'failed'=>0,'retried'=>0,'skipped'=>0,'configured'=>false];
 try{
  q('INSERT INTO notifications(user_id,type,title,body,data,created_at) VALUES(?,?,?,?,?,NOW())',
   [$userId,'test','Test notification','A test from the Hotel Paradise console. If you can read this on your phone, notifications are working.',null]);
  $nid=(int)db()->lastInsertId();
  notify_queue_for_user($nid,$userId);
 }catch(\Throwable $e){ error_log('[hotel notify] test failed: '.$e->getMessage()); }
 return notify_process_queue(10);
}