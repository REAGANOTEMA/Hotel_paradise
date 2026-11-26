<?php
declare(strict_types=1);

require_once __DIR__.'/../app/enterprise.php';

if(!hp_enterprise_ready(['hp_guest_preferences','hp_loyalty_accounts','hp_loyalty_transactions','hp_guest_followups'])){
  page_head('Guest Relations','guest_relations');
  echo '<div class="panel"><h2>Upgrade required</h2><p class="hint">Run database/sql/patches/2026-11-25_enterprise_expansion.sql to enable preferences, loyalty and follow-ups.</p></div>';
  page_foot(); exit;
}

function gr_guest_name(int $guestId): string{
  return (string)(val('SELECT full_name FROM guests WHERE id=?',[$guestId])?:'Guest #'.$guestId);
}

$act=$_GET['act']??'';
$guestId=(int)($_GET['view']??$_POST['guest_id']??0);
$me=current_user();
$uid=(int)($me['id']??0);

if($_SERVER['REQUEST_METHOD']==='POST' && $act){
  switch($act){
   case 'preference':
    $type=$_POST['preference_type']??'other';
    $value=trim((string)($_POST['preference_value']??''));
    $notes=trim((string)($_POST['notes']??''));
    $types=['room'=>'Room','bed'=>'Bed','floor'=>'Floor','diet'=>'Diet','celebration'=>'Celebration','communication'=>'Communication','other'=>'Other'];
    if($guestId<1||$value===''||!isset($types[$type])){ flash('Choose a guest, preference type and value.','bad'); go('guest_relations',['view'=>$guestId]); }
    q('INSERT INTO hp_guest_preferences(hotel_id,guest_id,preference_type,preference_value,notes,created_by,created_at) VALUES(1,?,?,?,?,?,NOW())',[$guestId,$type,$value,$notes,$uid]);
    audit('guest_preference','guest',$guestId,['type'=>$type,'value'=>$value]);
    flash('Guest preference saved.');
    go('guest_relations',['view'=>$guestId]);
    break;

   case 'preference_update':
    $pid=(int)($_POST['preference_id']??0);
    $value=trim((string)($_POST['preference_value']??''));
    $notes=trim((string)($_POST['notes']??''));
    if($pid<1||$value===''){ flash('Enter the updated preference.','bad'); go('guest_relations',['view'=>$guestId]); }
    q('UPDATE hp_guest_preferences SET preference_value=?,notes=? WHERE id=?',[$value,$notes,$pid]);
    audit('guest_preference_update','guest_preference',$pid,null,['value'=>$value]);
    flash('Preference updated.');
    go('guest_relations',['view'=>$guestId]);
    break;

   case 'enroll':
    $tier=$_POST['tier']??'silver';
    if($guestId<1||!in_array($tier,['silver','gold','platinum'],true)){ flash('Choose a guest and a valid tier.','bad'); go('guest_relations',['view'=>$guestId]); }
    if(row('SELECT id FROM hp_loyalty_accounts WHERE guest_id=?',[$guestId])){ flash('This guest already has a loyalty account.','bad'); go('guest_relations',['view'=>$guestId]); }
    q('INSERT INTO hp_loyalty_accounts(hotel_id,guest_id,tier,points,lifetime_stays,joined_at,created_at) VALUES(1,?,?,?,0,CURDATE(),NOW())',[$guestId,$tier]);
    $aid=(int)db()->lastInsertId();
    q('INSERT INTO hp_loyalty_transactions(hotel_id,guest_id,points,reason,created_by,created_at) VALUES(1,?,0,\'Loyalty account opened\',?,NOW())',[$guestId,$uid]);
    audit('loyalty_enroll','guest',$guestId,['tier'=>$tier]);
    notify_console('gr-loyalty-'.$aid,'booking','Loyalty account opened',gr_guest_name($guestId).' enrolled at '.ucfirst($tier),['guest_id'=>$guestId],['marketing','receptionist','director'],'guest',$guestId);
    flash('Loyalty account opened.');
    go('guest_relations',['view'=>$guestId]);
    break;

   case 'award':
    $points=(int)($_POST['points']??0);
    $reason=trim((string)($_POST['reason']??''));
    if($guestId<1||$points<1||$reason===''){ flash('Enter a positive number of points and a reason.','bad'); go('guest_relations',['view'=>$guestId]); }
    $a=row('SELECT * FROM hp_loyalty_accounts WHERE guest_id=?',[$guestId]);
    if(!$a){ flash('Enrol this guest before awarding points.','bad'); go('guest_relations',['view'=>$guestId]); }
    q('UPDATE hp_loyalty_accounts SET points=points+? WHERE id=?',[$points,(int)$a['id']]);
    q('INSERT INTO hp_loyalty_transactions(hotel_id,guest_id,points,reason,created_by,created_at) VALUES(1,?,?,?,?,NOW())',[$guestId,$points,$reason,$uid]);
    audit('loyalty_award','guest',$guestId,null,['points'=>$points,'reason'=>$reason]);
    flash($points.' points awarded.');
    go('guest_relations',['view'=>$guestId]);
    break;

   case 'redeem':
    $points=(int)($_POST['points']??0);
    $value=hp_money_input($_POST['ugx_value']??0);
    $reason=trim((string)($_POST['reason']??''));
    $a=row('SELECT * FROM hp_loyalty_accounts WHERE guest_id=?',[$guestId]);
    if(!$a||$points<1||$value<=0||$reason===''){ flash('Enter points, UGX value and a reason.','bad'); go('guest_relations',['view'=>$guestId]); }
    if($points>(int)$a['points']){ flash('This guest does not have enough points.','bad'); go('guest_relations',['view'=>$guestId]); }
    $auth=hp_front_authorized($_POST['authorization_id']??0);
    if($auth===null){
      $created=hp_sensitive_request('discount','guest',$guestId,$value,$reason.' ('.$points.' points)');
      flash($created?'Redemption sent for authorization.':'The authorization queue is not installed.');
      go('guest_relations',['view'=>$guestId]);
    }
    q('UPDATE hp_loyalty_accounts SET points=points-? WHERE id=?',[$points,(int)$a['id']]);
    q('INSERT INTO hp_loyalty_transactions(hotel_id,guest_id,points,reason,created_by,created_at) VALUES(1,?,-?,?,?,NOW())',[$guestId,$points,$reason.' authorized (auth #'.$auth.')',$uid]);
    audit('loyalty_redeem','guest',$guestId,null,['points'=>$points,'value'=>$value,'authorization_id'=>$auth]);
    flash($points.' points redeemed for '.money($value).'.');
    go('guest_relations',['view'=>$guestId]);
    break;

   case 'followup':
    $channel=$_POST['channel']??'call';
    $subject=trim((string)($_POST['subject']??''));
    $notes=trim((string)($_POST['notes']??''));
    $due=hp_date_input($_POST['due_date']??'');
    $assigned=(int)($_POST['assigned_to']??0);
    $channels=['call'=>'Call','email'=>'Email','whatsapp'=>'WhatsApp','visit'=>'Visit'];
    if($guestId<1||$subject===''||!isset($channels[$channel])){ flash('Choose a guest, channel and subject.','bad'); go('guest_relations',['view'=>$guestId]); }
    q('INSERT INTO hp_guest_followups(hotel_id,guest_id,channel,subject,notes,status,due_date,assigned_to,created_by,created_at) VALUES(1,?,?,?,?,\'open\',?,?,?,NOW())',[$guestId,$channel,$subject,$notes,$due!==''?$due:null,$assigned>0?$assigned:null,$uid]);
    audit('followup_created','guest',$guestId,['subject'=>$subject]);
    notify_console('gr-followup-'.(int)db()->lastInsertId(),'incident','Guest follow-up due',gr_guest_name($guestId).' · '.$subject,['guest_id'=>$guestId],['receptionist','marketing','director'],'guest',$guestId);
    flash('Follow-up recorded.');
    go('guest_relations',['view'=>$guestId]);
    break;

   case 'followup_done':
    $fid=(int)($_POST['followup_id']??0);
    $f=row('SELECT * FROM hp_guest_followups WHERE id=? AND status=\'open\'',[$fid]);
    if(!$f){ flash('Follow-up not found or already complete.','bad'); go('guest_relations',['view'=>$guestId]); }
    q("UPDATE hp_guest_followups SET status='done',completed_at=NOW() WHERE id=?",[$fid]);
    audit('followup_done','followup',$fid);
    flash('Follow-up completed.');
    go('guest_relations',['view'=>$guestId]);
    break;
  }
}

$guests=rows('SELECT id,full_name,phone,email FROM guests WHERE deleted_at IS NULL ORDER BY full_name LIMIT 300');
$users=rows("SELECT id,name FROM users WHERE status='active' ORDER BY name");
$prefs=$guestId?rows('SELECT * FROM hp_guest_preferences WHERE guest_id=? ORDER BY preference_type,id',[$guestId]):[];
$loyalty=$guestId?row('SELECT * FROM hp_loyalty_accounts WHERE guest_id=?',[$guestId]):null;
$points=rows('SELECT * FROM hp_loyalty_transactions WHERE guest_id=? ORDER BY id DESC LIMIT 40',[$guestId]);
$followups=rows('SELECT f.*,u.name assigned_name FROM hp_guest_followups f LEFT JOIN users u ON u.id=f.assigned_to WHERE f.status=\'open\' ORDER BY f.due_date IS NULL,f.due_date LIMIT 100');
$allFollowups=$guestId?rows('SELECT f.*,u.name assigned_name FROM hp_guest_followups f LEFT JOIN users u ON u.id=f.assigned_to WHERE f.guest_id=? ORDER BY f.id DESC LIMIT 40',[$guestId]):[];
$guestStays=$guestId?rows("SELECT booking_number,check_in,check_out,status,total FROM reservations WHERE guest_id=? AND deleted_at IS NULL ORDER BY check_in DESC LIMIT 20",[$guestId]):[];
$messages=$guestId?rows('SELECT * FROM guest_messages WHERE email IN (SELECT email FROM guests WHERE id=?) OR phone IN (SELECT phone FROM guests WHERE id=?) ORDER BY id DESC LIMIT 20',[$guestId,$guestId]):[];
$openFollow=(int)val("SELECT COUNT(*) FROM hp_guest_followups WHERE status='open'");
$loyaltyCount=(int)val('SELECT COUNT(*) FROM hp_loyalty_accounts');
$prefCount=(int)val('SELECT COUNT(*) FROM hp_guest_preferences');
$overdue=(int)val("SELECT COUNT(*) FROM hp_guest_followups WHERE status='open' AND due_date IS NOT NULL AND due_date<CURDATE()");

page_head('Guest Relations','guest_relations','Guest preferences, loyalty and follow-up');
echo '<div class="kpis">';
kpi_card('Open follow-ups',(string)$openFollow,'Across all guests','warn');
kpi_card('Overdue',(string)$overdue,'Past the due date','red');
kpi_card('Loyalty members',(string)$loyaltyCount,'Enrolled guests');
kpi_card('Preferences',(string)$prefCount,'Recorded details');
echo '</div>';

echo '<div class="panel"><h2>Choose a guest</h2>'; form_open('guest_relations','');
echo '<div class="formGrid"><div class="field"><label>Guest</label><select name="guest_id" onchange="this.form.submit()"><option value="">Select guest...</option>';
foreach($guests as $g) echo '<option value="'.(int)$g['id'].'"'.($guestId===(int)$g['id']?' selected':'').'>'.e(guest_name($g['full_name'],$g['id']).($g['phone']?' · '.$g['phone']:'')).'</option>';
echo '</select></div></div>'; form_close(); echo '</div>';

if($guestId){
  echo '<div class="panel"><h2>'.e(gr_guest_name($guestId)).'</h2><p class="hint">Loyalty: '.($loyalty?e(ucfirst($loyalty['tier'])).' · '.(int)$loyalty['points'].' points · '.(int)$loyalty['lifetime_stays'].' stays':'Not enrolled').'</p>';
  echo '<div class="twoCol"><div><h3>Preferences</h3><table class="tbl"><thead><tr><th>Type</th><th>Value</th><th></th></tr></thead><tbody>';
  foreach($prefs as $p) echo '<tr><td>'.e(ucfirst($p['preference_type'])).'</td><td>'.e($p['preference_value']).'<br><small>'.e($p['notes']??'').'</small></td><td>';
  form_open('guest_relations','preference_update',['view'=>$guestId]); echo '<input type="hidden" name="preference_id" value="'.(int)$p['id'].'">'.field('New value','preference_value',(string)$p['preference_value']).field('Notes','notes',(string)($p['notes']??'')).'<button class="btnGhost sm">Update</button>'; form_close();
  echo '</td></tr>';
  if(!$prefs) echo '<tr><td colspan="3" style="text-align:center;color:var(--muted)">No preferences recorded.</td></tr>';
  echo '</tbody></table>';
  echo '<h3 style="margin-top:16px">Add preference</h3>'; form_open('guest_relations','preference',['view'=>$guestId]);
  echo '<div class="formGrid"><div class="field"><label>Type</label><select name="preference_type">'; foreach(['room'=>'Room','bed'=>'Bed','floor'=>'Floor','diet'=>'Diet','celebration'=>'Celebration','communication'=>'Communication','other'=>'Other'] as $k=>$v) echo '<option value="'.e($k).'">'.e($v).'</option>'; echo '</select></div>'.field('Value','preference_value','','text','',true).'</div>'.area('Notes','notes','','Optional detail','',2).'<button class="btn">Save preference</button>'; form_close();
  echo '</div><div><h3>Loyalty</h3>';
  if(!$loyalty){ form_open('guest_relations','enroll',['view'=>$guestId]); echo '<div class="field"><label>Tier</label><select name="tier">'; foreach(['silver'=>'Silver','gold'=>'Gold','platinum'=>'Platinum'] as $k=>$v) echo '<option value="'.e($k).'">'.e($v).'</option>'; echo '</select></div><button class="btn">Enrol guest</button>'; form_close(); }
  else{
    echo '<table class="tbl"><thead><tr><th>Date</th><th>Points</th><th>Reason</th></tr></thead><tbody>';
    foreach($points as $p) echo '<tr><td>'.e($p['created_at']).'</td><td class="num">'.e($p['points']).'</td><td>'.e($p['reason']).'</td></tr>';
    if(!$points) echo '<tr><td colspan="3" style="text-align:center;color:var(--muted)">No points activity.</td></tr>';
    echo '</tbody></table>';
    form_open('guest_relations','award',['view'=>$guestId]); echo field('Points','points','1','number','',true).field('Reason','reason','','text','',true).'<button class="btn sm">Award points</button>'; form_close();
    form_open('guest_relations','redeem',['view'=>$guestId]); echo field('Points','points','','number','',true).field('UGX value','ugx_value','','number','',true).field('Reason','reason','','text','',true);
    echo '<div class="field"><label>Authorization (after approval)</label><select name="authorization_id"><option value="">Request approval first</option>';
    foreach(rows("SELECT * FROM hp_sensitive_actions WHERE action_type='discount' AND entity_type='guest' AND entity_id=? ORDER BY id DESC LIMIT 10",[$guestId]) as $a) echo '<option value="'.(int)$a['id'].'">#'.(int)$a['id'].' · '.e($a['status']).'</option>';
    echo '</select></div><button class="btnGhost sm">Redeem points</button>'; form_close();
  }
  echo '</div></div>';
  echo '<div class="twoCol" style="margin-top:18px"><div><h3>Stay history</h3><table class="tbl"><thead><tr><th>Booking</th><th>Check in</th><th>Check out</th><th>Status</th></tr></thead><tbody>';
  foreach($guestStays as $s) echo '<tr><td>'.e($s['booking_number']).'</td><td>'.e($s['check_in']).'</td><td>'.e($s['check_out']).'</td><td>'.status_badge($s['status']).'</td></tr>';
  if(!$guestStays) echo '<tr><td colspan="4" style="text-align:center;color:var(--muted)">No stays found.</td></tr>';
  echo '</tbody></table></div><div><h3>Guest messages</h3><table class="tbl"><thead><tr><th>Reference</th><th>Subject</th><th>Department</th></tr></thead><tbody>';
  foreach($messages as $m) echo '<tr><td>'.e($m['reference']??'').'</td><td>'.e($m['subject']??$m['kind']??'').'</td><td>'.e($m['department']??'').'</td></tr>';
  if(!$messages) echo '<tr><td colspan="3" style="text-align:center;color:var(--muted)">No matching messages.</td></tr>';
  echo '</tbody></table></div></div></div>';
}

echo '<div class="panel"><h2>Follow-up queue</h2>'; form_open('guest_relations','followup',['view'=>$guestId]);
echo '<div class="formGrid"><div class="field"><label>Guest</label><select name="guest_id" required><option value="">Choose guest...</option>'; foreach($guests as $g) echo '<option value="'.(int)$g['id'].'"'.($guestId===(int)$g['id']?' selected':'').'>'.e(guest_name($g['full_name'],$g['id'])).'</option>'; echo '</select></div>';
echo '<div class="field"><label>Channel</label><select name="channel">'; foreach(['call'=>'Call','email'=>'Email','whatsapp'=>'WhatsApp','visit'=>'Visit'] as $k=>$v) echo '<option value="'.e($k).'">'.e($v).'</option>'; echo '</select></div>';
echo field('Subject','subject','','text','',true).field('Due date','due_date','','date');
echo '<div class="field"><label>Assigned to</label><select name="assigned_to"><option value="">Unassigned</option>'; foreach($users as $u) echo '<option value="'.(int)$u['id'].'">'.e($u['name']).'</option>'; echo '</select></div></div>'.area('Notes','notes','','What should be said or checked?','',2).'<button class="btn">Record follow-up</button>'; form_close();
echo '<table class="tbl" style="margin-top:16px"><thead><tr><th>Guest</th><th>Subject</th><th>Channel</th><th>Due</th><th>Assigned</th><th></th></tr></thead><tbody>';
foreach($followups as $f) echo '<tr><td>'.e($f['guest_id']?'Guest #'.$f['guest_id']:'').'</td><td>'.e($f['subject']).'</td><td>'.e($f['channel']).'</td><td>'.($f['due_date']&&$f['due_date']<today()?badge($f['due_date'],'bad'):e($f['due_date']??'')).'</td><td>'.e($f['assigned_name']??'Unassigned').'</td><td>';
form_open('guest_relations','followup_done',['view'=>$f['guest_id']]); echo '<input type="hidden" name="followup_id" value="'.(int)$f['id'].'"><button class="btn sm">Complete</button>'; form_close();
echo '</td></tr>';
if(!$followups) echo '<tr><td colspan="6" style="text-align:center;color:var(--muted)">No open follow-ups.</td></tr>';
echo '</tbody></table></div>';

if($guestId&&$allFollowups){
  echo '<div class="panel"><h2>Follow-up history for '.e(gr_guest_name($guestId)).'</h2><table class="tbl"><thead><tr><th>Subject</th><th>Status</th><th>Completed</th></tr></thead><tbody>';
  foreach($allFollowups as $f) echo '<tr><td>'.e($f['subject']).'</td><td>'.status_badge($f['status']).'</td><td>'.e($f['completed_at']??'').'</td></tr>';
  echo '</tbody></table></div>';
}
receipt_print('guest_relations');
page_foot();
