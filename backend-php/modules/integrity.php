<?php
declare(strict_types=1);

/*
 * Integrity and Control.
 *
 * The director's own desk for the two things the front desk can do quietly:
 * let a guest in without ever writing the stay down, and write the stay down at
 * a price that never reaches the safe. This module finds both by comparing what
 * the house says is happening against what the system can prove, and it does it
 * only from records the system already holds.
 *
 * Nothing here watches people or listens to rooms. It reads the same tables the
 * reservations desk writes, and it holds every finding against the one thing a
 * person cannot argue with: the room is marked occupied and no booking explains
 * why, or the rate on the booking is below the room type's published rate.
 *
 * A finding is a question, not a verdict. The desk is given the chance to answer
 * it: a flag is open until a director marks it reviewed, or cleared when the
 * reason is innocent. Every action is written to the audit trail, so the record
 * of the review is as durable as the finding itself.
 *
 * The list is exportable as CSV for the accountant, printable as a report for a
 * file, and shareable as a short message to the director's WhatsApp. A flagship
 * quality bar means the same here as everywhere: if a table an installation has
 * not yet created is missing, the page simply shows less rather than failing.
 */

$act=$_GET['act']??'';
$u=current_user();
$uid=(int)($u['id']??0);

/* ==================================================================
   THE TABLE THE FINDINGS LIVE IN

   Created on first use so an installation that predates this feature
   begins working the moment a director opens the page. The unique
   flag_key is what keeps a scan from turning one problem into fifty
   rows: a repeated finding refreshes the row it already has.
   ================================================================== */

function integrity_ready(): bool
{
 static $ready=null;
 if($ready!==null) return $ready;
 try{
  q("CREATE TABLE IF NOT EXISTS integrity_flags (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
    flag_key VARCHAR(190) NOT NULL,
    flag_type VARCHAR(60) NOT NULL,
    severity ENUM('high','medium','low') NOT NULL DEFAULT 'medium',
    ref_type VARCHAR(40) NOT NULL DEFAULT '',
    ref_id BIGINT UNSIGNED DEFAULT NULL,
    room_id BIGINT UNSIGNED DEFAULT NULL,
    reservation_id BIGINT UNSIGNED DEFAULT NULL,
    staff_id BIGINT UNSIGNED DEFAULT NULL,
    staff_name VARCHAR(190) DEFAULT NULL,
    guest_name VARCHAR(190) DEFAULT NULL,
    amount DECIMAL(14,2) DEFAULT NULL,
    expected DECIMAL(14,2) DEFAULT NULL,
    detail VARCHAR(500) NOT NULL DEFAULT '',
    status ENUM('open','reviewed','cleared') NOT NULL DEFAULT 'open',
    resolved_by BIGINT UNSIGNED DEFAULT NULL,
    resolved_at DATETIME DEFAULT NULL,
    seen_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (id),
    UNIQUE KEY uq_integrity_flag_key (flag_key),
    KEY idx_integrity_status (status),
    KEY idx_integrity_severity (severity),
    KEY idx_integrity_type (flag_type)
   ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
  return $ready=true;
 }catch(\Throwable $e){
  error_log('[integrity] findings table unavailable: '.$e->getMessage());
  return $ready=false;
 }
}

/** A finding, always the same shape so display, storage and export agree. */
function integrity_flag(string $type,string $severity,string $key,string $detail,array $o=[]): array
{
 return array_merge([
  'flag_key'=>$key,
  'flag_type'=>$type,
  'severity'=>$severity,
  'ref_type'=>'',
  'ref_id'=>null,
  'room_id'=>null,
  'reservation_id'=>null,
  'staff_id'=>null,
  'staff_name'=>null,
  'guest_name'=>null,
  'amount'=>null,
  'expected'=>null,
  'detail'=>$detail,
 ],$o);
}

/** The name of whoever last did a thing to a record, from the audit trail. */
function integrity_actor_for_reservation(int $rid): array
{
 try{
  $a=row("SELECT al.user_id AS uid,u.name FROM audit_logs al LEFT JOIN users u ON u.id=al.user_id
   WHERE al.entity_type='reservation' AND al.entity_id=? AND al.action IN('create','reservation_status')
   ORDER BY al.id ASC LIMIT 1",[$rid]);
  if($a) return ['id'=>$a['uid']!==null?(int)$a['uid']:null,'name'=>(string)($a['name']??'')];
 }catch(\Throwable $e){}
 return ['id'=>null,'name'=>''];
}

/** The name of whoever last marked a room occupied, wherever that is written. */
function integrity_actor_for_room(int $roomId): array
{
 try{
  $h=row("SELECT h.changed_by AS uid,u.name FROM room_status_history h LEFT JOIN users u ON u.id=h.changed_by
   WHERE h.room_id=? AND h.new_status='occupied' ORDER BY h.id DESC LIMIT 1",[$roomId]);
  if($h&&$h['uid']!==null) return ['id'=>(int)$h['uid'],'name'=>(string)($h['name']??'')];
 }catch(\Throwable $e){}
 try{
  $a=row("SELECT al.user_id AS uid,u.name FROM audit_logs al LEFT JOIN users u ON u.id=al.user_id
   WHERE al.action='alloc_room' AND al.entity_type='room' AND al.entity_id=? ORDER BY al.id DESC LIMIT 1",[$roomId]);
  if($a&&$a['uid']!==null) return ['id'=>(int)$a['uid'],'name'=>(string)($a['name']??'')];
 }catch(\Throwable $e){}
 return ['id'=>null,'name'=>''];
}

/**
 * The scan itself: every question the house can raise, computed from the
 * books. Returns a flat list of findings, worst first. Each block is wrapped
 * so one missing table narrows the scan rather than stopping it.
 */
function integrity_scan(): array
{
 $out=[];
 $since=date('Y-m-d H:i:s',strtotime('-7 days'));

 // -- a room the house believes is occupied, with no checked-in booking ----
 try{
  $rooms=rows("SELECT r.id AS room_id,r.room_number,rt.name AS room_type,
    (SELECT v.booking_number FROM reservation_rooms rr JOIN reservations v ON v.id=rr.reservation_id
      WHERE rr.room_id=r.id AND v.status='checked_in' ORDER BY v.id DESC LIMIT 1) AS any_booking
   FROM rooms r LEFT JOIN room_types rt ON rt.id=r.room_type_id
   WHERE r.status='occupied'
     AND NOT EXISTS (
      SELECT 1 FROM reservation_rooms rr JOIN reservations v ON v.id=rr.reservation_id
      WHERE rr.room_id=r.id AND v.status='checked_in')");
  foreach($rooms as $rm){
   $a=integrity_actor_for_room((int)$rm['room_id']);
   $out[]=integrity_flag('ghost_room','high','ghost:room:'.(int)$rm['room_id'],
    'Room '.$rm['room_number'].' is marked occupied but no checked-in booking is attached to it.',
    ['room_id'=>(int)$rm['room_id'],'ref_type'=>'room','ref_id'=>(int)$rm['room_id'],
     'staff_id'=>$a['id'],'staff_name'=>$a['name']!==''?$a['name']:null]);
  }
 }catch(\Throwable $e){ error_log('[integrity] ghost scan: '.$e->getMessage()); }

 // -- a booking priced below the room type's published rate -----------------
 try{
  $under=rows("SELECT rr.id AS rr_id,rr.nightly_rate,rt.base_rate,rt.name AS room_type,rt.id AS room_type_id,
    v.id AS reservation_id,v.booking_number,v.status AS rstatus,g.full_name
   FROM reservation_rooms rr
   JOIN room_types rt ON rt.id=rr.room_type_id
   JOIN reservations v ON v.id=rr.reservation_id
   LEFT JOIN guests g ON g.id=v.guest_id
   WHERE v.status NOT IN('cancelled','no_show') AND rr.nightly_rate < rt.base_rate - 0.001
   ORDER BY (rt.base_rate-rr.nightly_rate) DESC");
  foreach($under as $r){
   $rate=(float)$r['nightly_rate']; $base=(float)$r['base_rate'];
   $pct=$base>0?round(($base-$rate)/$base*100,1):0;
   $a=integrity_actor_for_reservation((int)$r['reservation_id']);
   $sev=($pct>=10||$rate<=0)?'high':($pct>=3?'medium':'low');
   $out[]=integrity_flag('undercharge',$sev,'underrate:rr:'.(int)$r['rr_id'],
    'Booking '.$r['booking_number'].' ('.$r['room_type'].') priced at '.money($rate).'/night, '.$pct.'% below the published '.money($base).'.',
    ['ref_type'=>'reservation','ref_id'=>(int)$r['reservation_id'],'reservation_id'=>(int)$r['reservation_id'],
     'guest_name'=>(string)($r['full_name']??''),'amount'=>$rate,'expected'=>$base,
     'staff_id'=>$a['id'],'staff_name'=>$a['name']!==''?$a['name']:null]);
  }
 }catch(\Throwable $e){ error_log('[integrity] undercharge scan: '.$e->getMessage()); }

 // -- a booking priced above the published rate (guest overcharged) ---------
 try{
  $over=rows("SELECT rr.id AS rr_id,rr.nightly_rate,rt.base_rate,rt.name AS room_type,
    v.id AS reservation_id,v.booking_number,g.full_name
   FROM reservation_rooms rr
   JOIN room_types rt ON rt.id=rr.room_type_id
   JOIN reservations v ON v.id=rr.reservation_id
   LEFT JOIN guests g ON g.id=v.guest_id
   WHERE v.status NOT IN('cancelled','no_show') AND rr.nightly_rate > rt.base_rate + 0.001
   ORDER BY (rr.nightly_rate-rt.base_rate) DESC");
  foreach($over as $r){
   $rate=(float)$r['nightly_rate']; $base=(float)$r['base_rate'];
   $a=integrity_actor_for_reservation((int)$r['reservation_id']);
   $out[]=integrity_flag('overcharge','low','overrate:rr:'.(int)$r['rr_id'],
    'Booking '.$r['booking_number'].' ('.$r['room_type'].') priced at '.money($rate).'/night, above the published '.money($base).'.',
    ['ref_type'=>'reservation','ref_id'=>(int)$r['reservation_id'],'reservation_id'=>(int)$r['reservation_id'],
     'guest_name'=>(string)($r['full_name']??''),'amount'=>$rate,'expected'=>$base,
     'staff_id'=>$a['id'],'staff_name'=>$a['name']!==''?$a['name']:null]);
  }
 }catch(\Throwable $e){ error_log('[integrity] overcharge scan: '.$e->getMessage()); }

 // -- one room handed to more than one checked-in booking -------------------
 try{
  $dup=rows("SELECT rr.room_id,r.room_number,COUNT(DISTINCT v.id) AS c
   FROM reservation_rooms rr
   JOIN reservations v ON v.id=rr.reservation_id
   JOIN rooms r ON r.id=rr.room_id
   WHERE v.status='checked_in' AND rr.room_id IS NOT NULL
   GROUP BY rr.room_id,r.room_number HAVING c>1");
  foreach($dup as $d){
   $out[]=integrity_flag('double_book','high','doublebook:room:'.(int)$d['room_id'],
    'Room '.$d['room_number'].' is attached to '.(int)$d['c'].' checked-in bookings at once.',
    ['room_id'=>(int)$d['room_id'],'ref_type'=>'room','ref_id'=>(int)$d['room_id']]);
  }
 }catch(\Throwable $e){ error_log('[integrity] double-book scan: '.$e->getMessage()); }

 // -- discounts given, per member of staff, this week -----------------------
 try{
  $disc=rows("SELECT o.user_id,u.name,COUNT(*) AS c,COALESCE(SUM(o.discount),0) AS total
   FROM orders o LEFT JOIN users u ON u.id=o.user_id
   WHERE o.discount>0 AND o.created_at>=? GROUP BY o.user_id,u.name ORDER BY total DESC",[$since]);
  foreach($disc as $d){
   $who=(string)($d['name']??'Website / unknown');
   $out[]=integrity_flag('discount','low','discount:user:'.((int)($d['user_id']??0)).':'.substr($since,0,10),
    (int)$d['c'].' discount(s) given, totalling '.money((float)$d['total']).'.',
    ['staff_id'=>$d['user_id']!==null?(int)$d['user_id']:null,'staff_name'=>$who,'amount'=>(float)$d['total']]);
  }
 }catch(\Throwable $e){ error_log('[integrity] discount scan: '.$e->getMessage()); }

 // -- payments reversed by a member of staff, this week ---------------------
 try{
  $rev=rows("SELECT al.user_id,u.name,COUNT(*) AS c
   FROM audit_logs al LEFT JOIN users u ON u.id=al.user_id
   WHERE al.action='reverse_payment' AND al.created_at>=? GROUP BY al.user_id,u.name ORDER BY c DESC",[$since]);
  foreach($rev as $d){
   $out[]=integrity_flag('reversal','medium','reversal:user:'.((int)($d['user_id']??0)).':'.substr($since,0,10),
    (int)$d['c'].' payment reversal(s) recorded this week.',
    ['staff_id'=>$d['user_id']!==null?(int)$d['user_id']:null,'staff_name'=>$d['name']!==null?(string)$d['name']:'Unknown']);
  }
 }catch(\Throwable $e){ error_log('[integrity] reversal scan: '.$e->getMessage()); }

 // Worst first, and within a rank the biggest money first.
 $rank=['high'=>0,'medium'=>1,'low'=>2];
 usort($out,static function(array $a,array $b) use($rank): int{
  $r=($rank[$a['severity']]??3)<=>($rank[$b['severity']]??3);
  if($r!==0) return $r;
  return ((float)($b['expected']??$b['amount']??0))<=>((float)($a['expected']??$a['amount']??0));
 });
 return $out;
}

/** Writes the scan down, refreshing findings it already has. */
function integrity_store(array $findings): int
{
 if(!integrity_ready()) return 0;
 $n=0;
 foreach($findings as $f){
  try{
   q("INSERT INTO integrity_flags
     (hotel_id,flag_key,flag_type,severity,ref_type,ref_id,room_id,reservation_id,staff_id,staff_name,guest_name,amount,expected,detail,status,seen_at,created_at)
     VALUES(1,?,?,?,?,?,?,?,?,?,?,?,?,?,'open',NOW(),NOW())
     ON DUPLICATE KEY UPDATE severity=VALUES(severity),staff_id=VALUES(staff_id),staff_name=VALUES(staff_name),
      guest_name=VALUES(guest_name),amount=VALUES(amount),expected=VALUES(expected),detail=VALUES(detail),
      seen_at=NOW(),updated_at=NOW()",
    [$f['flag_key'],$f['flag_type'],$f['severity'],$f['ref_type'],$f['ref_id'],$f['room_id'],$f['reservation_id'],
     $f['staff_id'],$f['staff_name'],$f['guest_name'],$f['amount'],$f['expected'],$f['detail']]);
   $n++;
  }catch(\Throwable $e){ error_log('[integrity] could not store flag '.$f['flag_key'].': '.$e->getMessage()); }
 }
 return $n;
}

/** Sends the director one notice when a scan finds something serious. */
function integrity_notify(array $findings): void
{
 $high=array_values(array_filter($findings,static fn(array $f): bool=>$f['severity']==='high'));
 if(!$high) return;
 try{
  $lead=$high[0];
  notify_console('integrity-scan:'.date('Y-m-d').':'.count($high),'incident',
   count($high).' integrity flag(s) need attention',
   $lead['detail'],
   ['page'=>'integrity'],['director','general_manager','auditor'],'integrity',null);
 }catch(\Throwable $e){ error_log('[integrity] notify skipped: '.$e->getMessage()); }
}

/* ==================================================================
   WHAT THE DIRECTOR CAN DO WITH A FINDING
   ================================================================== */

if($_SERVER['REQUEST_METHOD']==='POST' && $act){
 if(!integrity_ready()){ flash('The findings table is not available.','bad'); go('integrity'); }

 if($act==='scan'){
  $scan=integrity_scan();
  $found=integrity_store($scan);
  integrity_notify($scan);
  audit('integrity_scan','integrity',null,['flags'=>$found]);
  flash($found.' finding(s) recorded from the latest scan.');
  go('integrity');
 }

 if($act==='review' || $act==='clear'){
  $fid=(int)($_POST['fid']??0);
  $f=row('SELECT * FROM integrity_flags WHERE id=? AND hotel_id=1',[$fid]);
  if(!$f){ flash('Finding not found.','bad'); go('integrity'); }
  $to=$act==='clear'?'cleared':'reviewed';
  $reason=trim($_POST['reason']??'');
  q('UPDATE integrity_flags SET status=?,resolved_by=?,resolved_at=NOW() WHERE id=?',[$to,$uid,$fid]);
  audit('integrity_'.$act,'integrity_flag',$fid,['status'=>$f['status'],'reason'=>$reason],['status'=>$to]);
  flash('Finding marked '.$to.($reason!==''?' - '.$reason:'').'.');
  go('integrity');
 }

 if($act==='reopen'){
  $fid=(int)($_POST['fid']??0);
  q('UPDATE integrity_flags SET status=\'open\',resolved_by=NULL,resolved_at=NULL WHERE id=? AND hotel_id=1',[$fid]);
  audit('integrity_reopen','integrity_flag',$fid);
  flash('Finding reopened.');
  go('integrity');
 }

 if($act==='delete'){
  $fid=(int)($_POST['fid']??0);
  $f=row('SELECT flag_key FROM integrity_flags WHERE id=? AND hotel_id=1',[$fid]);
  if($f){ q('DELETE FROM integrity_flags WHERE id=?',[$fid]); audit('integrity_delete','integrity_flag',$fid,['flag_key'=>$f['flag_key']]); flash('Finding deleted.'); }
  go('integrity');
 }

 if($act==='delete_cleared'){
  $n=(int)val("SELECT COUNT(*) FROM integrity_flags WHERE hotel_id=1 AND status='cleared'");
  q("DELETE FROM integrity_flags WHERE hotel_id=1 AND status='cleared'");
  audit('integrity_purge','integrity',null,['cleared'=>$n]);
  flash($n.' cleared finding(s) removed.');
  go('integrity');
 }
}

/* ==================================================================
   THE SCREEN
   ================================================================== */

$live=integrity_scan();
// Every visit by a director writes the current state down, so the record of
// what was true on this date survives even if nobody presses a button.
if(integrity_ready()) integrity_store($live);

$stored=[];
if(integrity_ready()){
 try{ $stored=rows("SELECT f.*,u.name AS resolved_name FROM integrity_flags f LEFT JOIN users u ON u.id=f.resolved_by
  WHERE f.hotel_id=1 ORDER BY FIELD(f.status,'open','reviewed','cleared'),FIELD(f.severity,'high','medium','low'),f.id DESC LIMIT 400"); }
 catch(\Throwable $e){ $stored=[]; }
}
$openCount=0;$highCount=0;$clearedCount=0;
foreach($stored as $f){ if($f['status']==='open'){$openCount++; if($f['severity']==='high')$highCount++;} if($f['status']==='cleared')$clearedCount++; }

// A quiet headline figure: rooms the house says are occupied vs rooms the books
// can explain.
$occRooms=(int)val("SELECT COUNT(*) FROM rooms WHERE status='occupied'");
$ghostRooms=count(array_filter($live,static fn(array $f): bool=>$f['flag_type']==='ghost_room'));
$underAmt=0.0;
foreach($live as $f){ if($f['flag_type']==='undercharge') $underAmt=max($underAmt,((float)$f['expected']-(float)$f['amount'])); }

page_head('Integrity and Control','integrity','What the house says, against what the books can prove');

/* A printable report, on the same paper every other console uses. Opened with
   ?print=1, so the button is a link and the browser prints it by itself. */
if((int)($_GET['print']??0)===1){
 $ls=[];
 foreach($live as $f){
  $ls[]=['name'=>strtoupper(str_replace('_',' ',$f['flag_type'])).' · '.$f['severity'],
   'qty'=>'','note'=>($f['staff_name']?'By '.$f['staff_name'].' · ':'').$f['detail'],
   'amount'=>($f['amount']!==null?money($f['amount']):null)];
 }
 if(!$ls) $ls[]=['name'=>'No findings','qty'=>'','note'=>'The books and the house agree.','amount'=>null];
 receipt_template('integrity-'.date('Ymd'),receipt_sheet([
  'kind'=>'INTEGRITY REPORT',
  'number'=>date('d M Y'),
  'meta'=>['Prepared for'=>($u['name']??'Director'),'Findings'=>count($live),'High'=>count(array_filter($live,static fn(array $f): bool=>$f['severity']==='high'))],
  'lines'=>$ls,
  'totals'=>[['Rooms occupied',(string)$occRooms],['Unexplained',(string)$ghostRooms,'big'],['Worst undercharge',money($underAmt)]],
  'foot'=>'Confidential · generated '.date('d M Y H:i'),
 ]),true);
 receipt_print('integrity');
 page_foot();
 return;
}

/* ---- the WhatsApp message, short enough to read on a phone ---- */
$waText="Hotel Paradise - Integrity summary (".date('d M Y').")\n"
 ."Open flags: ".$openCount." (high: ".$highCount.")\n"
 ."Rooms occupied: ".$occRooms.", unexplained: ".$ghostRooms."\n"
 ."Worst undercharge: ".money($underAmt)."\nOpen the Integrity and Control desk for the detail.";
$waDigits='';
try{
 $dirPhone=val("SELECT u.phone FROM users u JOIN user_roles ur ON ur.user_id=u.id JOIN roles ro ON ro.id=ur.role_id WHERE ro.name='director' LIMIT 1");
 $waDigits=preg_replace('/\D/','',(string)$dirPhone);
}catch(\Throwable $e){}
$waHref='https://wa.me/'.($waDigits!==''?$waDigits:'?').'?text='.rawurlencode($waText);

echo '<div class="kpis">';
kpi_card('Open findings',(string)$openCount,$highCount.' rated high',$openCount?'red':'green');
kpi_card('Unexplained rooms',(string)$ghostRooms,'Occupied rooms with no booking',$ghostRooms?'red':'green');
kpi_card('Rooms occupied',(string)$occRooms,'Per the house','blue');
kpi_card('Worst undercharge',money($underAmt),'Below published rate','gold');
kpi_card('Cleared',(string)$clearedCount,'Reviewed and explained','navy');
echo '</div>';

echo '<div class="panel"><div class="toolbar" style="margin-bottom:14px">';
echo '<div><h2>Integrity and Control</h2><p class="hint" style="margin:0">Live questions raised from the books. Nothing here is a verdict - each is answered by a director and the answer is kept.</p></div>';
echo '<div class="bar">';
form_open('integrity','scan');
echo '<button class="btn sm">Run scan and record</button>';
form_close();
echo '<a class="btnGhost sm" href="'.BASE.'/index.php?page=integrity&amp;print=1" target="_blank">Print report</a>';
echo '<a class="btnGhost sm" href="'.BASE.'/download.php?type=integrity">Download CSV</a>';
echo '<a class="btnGhost sm" href="'.e($waHref).'" target="_blank" rel="noopener">Share to WhatsApp</a>';
echo '</div></div>';

/* ---- the live list: exactly what the books say right now ---- */
echo '<h3 style="margin:6px 0 10px">Live findings</h3>';
if(!$live){
 echo '<p class="emptyLine">Nothing is out of place. The rooms the house calls occupied are all explained by a checked-in booking, and every rate written this week matches its room type.</p>';
}else{
 echo '<table class="tbl"><thead><tr><th>Severity</th><th>What</th><th>When</th><th>By</th><th class="num">Rate</th><th class="num">Expected</th></tr></thead><tbody>';
 foreach($live as $f){
  echo '<tr><td>'.badge(strtoupper($f['severity']),$f['severity']==='high'?'red':($f['severity']==='medium'?'warn':'grey')).'</td>';
  echo '<td><b>'.e(str_replace('_',' ',$f['flag_type'])).'</b><br><small>'.e($f['detail']).'</small></td>';
  echo '<td>'.($f['guest_name']!==''&&$f['guest_name']!==null?e($f['guest_name']):'&mdash;').'</td>';
  echo '<td>'.($f['staff_name']!==''&&$f['staff_name']!==null?e($f['staff_name']):'Not recorded').'</td>';
  echo '<td class="num">'.($f['amount']!==null?money($f['amount']):'&mdash;').'</td>';
  echo '<td class="num">'.($f['expected']!==null?money($f['expected']):'&mdash;').'</td></tr>';
 }
 echo '</tbody></table>';
}
echo '</div>';

/* ---- the stored record: what was found, and what was done about it ---- */
echo '<div class="panel"><div class="toolbar" style="margin-bottom:14px">';
echo '<div><h2>Record and review</h2><p class="hint" style="margin:0">Every finding the desk has recorded, with who answered it and how.</p></div>';
if($clearedCount){
 form_open('integrity','delete_cleared');
 echo '<button class="btnGhost sm" onclick="return confirm(\'Remove all cleared findings? This cannot be undone.\')">Remove cleared ('.$clearedCount.')</button>';
 form_close();
}
echo '</div>';

if(!$stored){
 echo '<p class="emptyLine">Nothing recorded yet. Run a scan to keep a dated record.</p>';
}else{
 echo '<table class="tbl"><thead><tr><th>#</th><th>Found</th><th>Severity</th><th>What</th><th>By</th><th>Status</th><th>Action</th></tr></thead><tbody>';
 foreach($stored as $f){
  $sev=$f['severity']==='high'?'red':($f['severity']==='medium'?'warn':'grey');
  echo '<tr><td>'.(int)$f['id'].'</td><td>'.fmtdt($f['seen_at']).'</td><td>'.badge(strtoupper($f['severity']),$sev).'</td>';
  echo '<td><b>'.e(str_replace('_',' ',$f['flag_type'])).'</b><br><small>'.e($f['detail']).'</small></td>';
  echo '<td>'.($f['staff_name']!==''&&$f['staff_name']!==null?e($f['staff_name']):'&mdash;').'</td>';
  echo '<td>'.status_badge($f['status']).($f['resolved_name']?'<br><small>by '.e($f['resolved_name']).'</small>':'').'</td><td>';
  if($f['status']==='open'){
   form_open('integrity','review',['fid'=>$f['id']]);
   echo '<button class="btn sm">Mark reviewed</button>';
   form_close();
   form_open('integrity','clear',['fid'=>$f['id']]);
   echo '<input name="reason" placeholder="Reason (optional)" style="width:150px;padding:6px;border:1px solid var(--line);border-radius:6px;margin:4px 0"><button class="btnGhost sm">Clear</button>';
   form_close();
  }else{
   form_open('integrity','reopen',['fid'=>$f['id']]);
   echo '<button class="btnGhost sm">Reopen</button>';
   form_close();
  }
  form_open('integrity','delete',['fid'=>$f['id']]);
  echo '<button class="btnGhost sm" onclick="return confirm(\'Delete this finding?\')" style="color:#c62828">Delete</button>';
  form_close();
  echo '</td></tr>';
 }
 echo '</tbody></table>';
}
echo '</div>';

page_foot();
