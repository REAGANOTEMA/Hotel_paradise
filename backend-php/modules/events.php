<?php
declare(strict_types=1);

/**
 * Events & Enquiries.
 *
 * The website's "Plan an event" and "Facilities" pages post their forms
 * straight into two tables (backend-php/api.php act=event and act=facility).
 * This module is where the events team and the front desk pick those leads up:
 * everything the guest sent, newest first, and one status to move it along.
 *
 * Those tables arrive with the site, and api.php makes them on the first real
 * enquiry anyway. The console makes them too, from the same definitions, so
 * opening this page on an older database is never an error.
 */

if(!function_exists('ensure_events_tables')){
 function ensure_events_tables(): void{
  q('CREATE TABLE IF NOT EXISTS event_requests(
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
  q('CREATE TABLE IF NOT EXISTS facility_enquiries(
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
}

$u=current_user();
ensure_events_tables();

/** The two kinds of lead, and who owns the follow up of each. */
$KINDS=[
 'event'=>['table'=>'event_requests','label'=>'Event enquiry','num'=>'request_number',
   'roles'=>['director','general_manager','events_manager','marketing']],
 'enquiry'=>['table'=>'facility_enquiries','label'=>'Facility enquiry','num'=>'enquiry_number',
   'roles'=>['director','general_manager','receptionist','marketing']],
];
$STATUSES=[
 'new'=>['label'=>'New','tone'=>'gold'],
 'contacted'=>['label'=>'Contacted','tone'=>'blue'],
 'confirmed'=>['label'=>'Confirmed','tone'=>'ok'],
 'closed'=>['label'=>'Closed','tone'=>'grey'],
 'lost'=>['label'=>'Lost','tone'=>'bad'],
];

if($_SERVER['REQUEST_METHOD']==='POST'){
 $act=$_GET['act']??'';
 if($act==='status'){
  $id=(int)($_POST['id']??0);
  $kind=(string)($_POST['kind']??'');
  $nst=(string)($_POST['nst']??'');
  if(!isset($KINDS[$kind])||!isset($STATUSES[$nst])){ flash('Nothing to change.','bad'); go('events'); }
  $K=$KINDS[$kind];
  $r=row('SELECT * FROM '.$K['table'].' WHERE id=?',[$id]);
  if(!$r){ flash('That enquiry no longer exists.','bad'); go('events'); }
  q('UPDATE '.$K['table'].' SET status=?,updated_at=NOW() WHERE id=?',[$nst,$id]);
  audit('events_'.$nst,$K['table'],$id,['status'=>$r['status']]);
  notify_console($kind.'-'.$nst.':'.$id,'communication',
   $K['label'].' '.$r[$K['num']].' marked '.$STATUSES[$nst]['label'],
   $r['full_name'].' — '.(string)($u['name']??'staff').' set it to '.$STATUSES[$nst]['label'].'. Phone '.$r['phone'].'.',
   [$K['num']=>$r[$K['num']],'status'=>$nst,'name'=>$r['full_name'],'phone'=>$r['phone']],
   $K['roles'],$K['table'],$id);
  flash($K['label'].' '.$r[$K['num']].' marked '.$STATUSES[$nst]['label'].'.');
 }
 go('events');
}

/** A badge for one of this module's own statuses, coloured like the rest. */
function ev_status(string $status): string{
 $tones=['new'=>'gold','contacted'=>'blue','confirmed'=>'ok','closed'=>'grey','lost'=>'bad'];
 return badge(str_replace('_',' ',$status),$tones[$status]??'grey');
}

$kf=(string)($_GET['kind']??'');
$sf=(string)($_GET['st']??'');
if(!isset($KINDS[$kf])) $kf='';
if(!isset($STATUSES[$sf])) $sf='';
$where=$sf!==''?' WHERE status=?':'';
$params=$sf!==''?[$sf]:[];

$events=($kf==='enquiry')?[]:rows('SELECT * FROM event_requests'.$where.' ORDER BY id DESC LIMIT 100',$params);
$enquiries=($kf==='event')?[]:rows('SELECT * FROM facility_enquiries'.$where.' ORDER BY id DESC LIMIT 100',$params);

/** One small form per row: pick a status, record it, notify the team. */
function events_status_form(string $kind,int $id,string $cur,array $statuses): void{
 form_open('events','status',['kind'=>$kind,'id'=>$id]);
 echo '<select name="nst" aria-label="Set status" style="padding:6px 8px;border:1px solid var(--line);border-radius:8px">';
 foreach($statuses as $k=>$s) echo '<option value="'.e($k).'"'.checked($cur,$k).'>'.e($s['label']).'</option>';
 echo '</select> <button class="btn sm blue">Update</button>';
 form_close();
}

page_head('Events & Enquiries','events','Website enquiries for events, conferences and facilities');

echo '<div class="kpis">';
kpi_card('New event enquiries',(string)val("SELECT COUNT(*) FROM event_requests WHERE status='new'"),'Awaiting a call back','gold');
kpi_card('New facility enquiries',(string)val("SELECT COUNT(*) FROM facility_enquiries WHERE status='new'"),'Front desk to answer','blue');
kpi_card('Confirmed events',(string)val("SELECT COUNT(*) FROM event_requests WHERE status='confirmed'"),'Won and on the calendar','ok');
kpi_card('Asked about this month',(string)val('SELECT COUNT(*) FROM event_requests WHERE created_at>=?',[date('Y-m-01')]),'Event enquiries in '.date('M Y'),'navy');
echo '</div>';

echo '<div class="rfilter">';
foreach([''=>'All','event'=>'Events','enquiry'=>'Facilities'] as $k=>$v){
 echo '<a href="'.BASE.'/index.php?page=events'.($k?'&kind='.$k:'').($sf?'&st='.$sf:'').'"><button class="'.($kf===$k?'on':'').'">'.e($v).'</button></a>';
}
echo '</div>';
echo '<div class="rfilter">';
foreach([''=>'All statuses']+array_map(static fn($s)=>$s['label'],$STATUSES) as $k=>$v){
 echo '<a href="'.BASE.'/index.php?page=events'.($kf?'&kind='.$kf:'').($k?'&st='.$k:'').'"><button class="'.($sf===$k?'on':'').'">'.e($v).'</button></a>';
}
echo '</div>';

if($kf!=='enquiry'){
 echo '<div class="panel"><h2>Event enquiries</h2><p class="hint">Weddings, conferences and functions sent from the website\'s "Plan an event" page.</p>';
 echo '<table class="tbl"><thead><tr><th>Reference</th><th>Guest</th><th>Event</th><th>When</th><th>Guests</th><th>Status</th><th></th></tr></thead><tbody>';
 foreach($events as $r){
  echo '<tr>';
  echo '<td><b>'.e($r['request_number']).'</b><br><small>'.e(fmtdt($r['created_at'])).'</small></td>';
  echo '<td>'.e($r['full_name']).'<br><small>'.e($r['phone']).($r['email']?' · '.e($r['email']):'').'</small></td>';
  echo '<td>'.e($r['event_type']?:'—').($r['venue']?'<br><small>'.e($r['venue']).'</small>':'').($r['message']?'<br><small title="'.e($r['message']).'">'.e(mb_substr($r['message'],0,80)).(mb_strlen($r['message'])>80?'…':'').'</small>':'').'</td>';
  echo '<td>'.e(fmtdate($r['event_date']) ?: '—').'</td>';
  echo '<td class="num">'.($r['guests']!==null?(int)$r['guests']:'—').'</td>';
  echo '<td>'.badge($STATUSES[$r['status']]['label']??str_replace('_',' ',$r['status']),$STATUSES[$r['status']]['tone']??'grey').'</td>';
  echo '<td style="white-space:nowrap">'; events_status_form('event',(int)$r['id'],(string)$r['status'],$STATUSES); echo '</td>';
  echo '</tr>';
 }
 if(!count($events)) echo '<tr><td colspan="7" style="text-align:center;color:var(--muted)">No event enquiries' . ($sf!==''?' with this status':'') . ' yet.</td></tr>';
 echo '</tbody></table></div>';
}

if($kf!=='event'){
 echo '<div class="panel"><h2>Facility enquiries</h2><p class="hint">Comfort, pool, gym and dining questions sent from the website\'s "Facilities" page.</p>';
 echo '<table class="tbl"><thead><tr><th>Reference</th><th>Guest</th><th>Facility</th><th>Preferred date</th><th>People</th><th>Status</th><th></th></tr></thead><tbody>';
 foreach($enquiries as $r){
  echo '<tr>';
  echo '<td><b>'.e($r['enquiry_number']).'</b><br><small>'.e(fmtdt($r['created_at'])).'</small></td>';
  echo '<td>'.e($r['full_name']).'<br><small>'.e($r['phone']).($r['email']?' · '.e($r['email']):'').'</small></td>';
  echo '<td>'.e($r['facility']?:'—').($r['message']?'<br><small title="'.e($r['message']).'">'.e(mb_substr($r['message'],0,80)).(mb_strlen($r['message'])>80?'…':'').'</small>':'').'</td>';
  echo '<td>'.e(fmtdate($r['preferred_date']) ?: '—').'</td>';
  echo '<td class="num">'.($r['guests']!==null?(int)$r['guests']:'—').'</td>';
  echo '<td>'.badge($STATUSES[$r['status']]['label']??str_replace('_',' ',$r['status']),$STATUSES[$r['status']]['tone']??'grey').'</td>';
  echo '<td style="white-space:nowrap">'; events_status_form('enquiry',(int)$r['id'],(string)$r['status'],$STATUSES); echo '</td>';
  echo '</tr>';
 }
 if(!count($enquiries)) echo '<tr><td colspan="7" style="text-align:center;color:var(--muted)">No facility enquiries' . ($sf!==''?' with this status':'') . ' yet.</td></tr>';
 echo '</tbody></table></div>';
}

page_foot();
