<?php
declare(strict_types=1);

require_once __DIR__.'/../app/enterprise.php';

if(!hp_enterprise_ready(['hp_sensitive_actions','audit_logs','login_attempts','lost_property'])){
  page_head('Security','security');
  echo '<div class="panel"><h2>Upgrade required</h2><p class="hint">Run database/sql/patches/2026-11-25_enterprise_expansion.sql to enable the authorization queue.</p></div>';
  page_foot(); exit;
}

function se_csv(array $rows): void{
  header('Content-Type: text/csv; charset=utf-8');
  header('Content-Disposition: attachment; filename="hotel-audit-'.date('Y-m-d').'.csv"');
  $out=fopen('php://output','w');
  foreach($rows as $r){
    $line=[];
    foreach($r as $v) $line[]='"'.str_replace('"','""',(string)$v).'"';
    fwrite($out,implode(',',$line)."\n");
  }
  fclose($out); exit;
}

$act=$_GET['act']??'';
$me=current_user();
$uid=(int)($me['id']??0);

if($act==='export'){
  $logs=rows('SELECT l.created_at,u.name actor,l.action,l.entity_type,l.entity_id,l.ip_address FROM audit_logs l LEFT JOIN users u ON u.id=l.user_id ORDER BY l.id DESC LIMIT 2000');
  $out=[['Time','Actor','Action','Entity','Entity ID','IP']];
  foreach($logs as $l) $out[]=$l;
  se_csv($out);
}

if($_SERVER['REQUEST_METHOD']==='POST' && $act){
  switch($act){
   case 'decide':
    if(!has_role('director')&&!has_role('general_manager')){ flash('Only the Director or General Manager can decide authorizations.','bad'); go('security'); }
    $id=(int)($_POST['action_id']??0);
    $status=$_POST['decision']??'';
    $note=trim((string)($_POST['note']??''));
    if($id<1||!in_array($status,['approved','rejected'],true)){ flash('Choose an authorization and a decision.','bad'); go('security'); }
    $ok=hp_sensitive_decide($id,$status,$note);
    flash($ok?'Authorization '.$status.'.':'That request can no longer be decided.');
    go('security');
    break;

   case 'lost':
    $desc=trim((string)($_POST['description']??''));
    $roomId=(int)($_POST['room_id']??0);
    $guestId=(int)($_POST['guest_id']??0);
    if($desc===''){ flash('Describe the found item.','bad'); go('security',['act'=>'lost']); }
    q('INSERT INTO lost_property(property_id,room_id,guest_id,found_by,description,found_at,status) VALUES(1,?,?,?,?,NOW(),\'stored\')',[$roomId>0?$roomId:null,$guestId>0?$guestId:null,$uid,$desc]);
    $lostId=(int)db()->lastInsertId();
    audit('lost_property','lost_property',$lostId,['description'=>$desc]);
    notify_console('se-lost-'.$lostId,'incident','Lost property logged',$desc,['lost_property_id'=>$lostId],['receptionist','housekeeping','director'],'lost_property',$lostId);
    flash('Lost property recorded.');
    go('security',['act'=>'lost']);
    break;

   case 'lost_return':
    $id=(int)($_POST['lost_id']??0);
    $released=trim((string)($_POST['released_to']??''));
    $item=row('SELECT * FROM lost_property WHERE id=? AND status=\'stored\'',[$id]);
    if(!$item||$released===''){ flash('Enter who received the item.','bad'); go('security',['act'=>'lost']); }
    q("UPDATE lost_property SET status='returned',released_to=?,released_at=NOW() WHERE id=?",[$released,$id]);
    audit('lost_returned','lost_property',$id,['status'=>'stored'],['status'=>'returned','released_to'=>$released]);
    flash('Item marked as returned.');
    go('security',['act'=>'lost']);
    break;
  }
}

$pending=rows('SELECT a.*,u.name requester FROM hp_sensitive_actions a LEFT JOIN users u ON u.id=a.requested_by WHERE a.status=\'pending\' ORDER BY a.id DESC LIMIT 100');
$decided=rows('SELECT a.*,u.name requester,v.name approver FROM hp_sensitive_actions a LEFT JOIN users u ON u.id=a.requested_by LEFT JOIN users v ON v.id=a.authorized_by WHERE a.status<>\'pending\' ORDER BY a.decided_at DESC LIMIT 100');
$logs=rows('SELECT l.*,u.name actor FROM audit_logs l LEFT JOIN users u ON u.id=l.user_id ORDER BY l.id DESC LIMIT 200');
$failed=rows("SELECT a.*,u.name user_name FROM login_attempts a LEFT JOIN users u ON u.id=a.user_id WHERE a.successful=0 ORDER BY a.id DESC LIMIT 100");
$lost=rows('SELECT p.*,u.name found_name,r.room_number FROM lost_property p LEFT JOIN users u ON u.id=p.found_by LEFT JOIN rooms r ON r.id=p.room_id ORDER BY p.id DESC LIMIT 100');
$rooms=rows('SELECT id,room_number FROM rooms WHERE deleted_at IS NULL ORDER BY room_number');
$guests=rows('SELECT id,full_name FROM guests WHERE deleted_at IS NULL ORDER BY full_name LIMIT 300');
$pendingCount=(int)val("SELECT COUNT(*) FROM hp_sensitive_actions WHERE status='pending'");
$failedCount=(int)val('SELECT COUNT(*) FROM login_attempts WHERE successful=0');
$storedCount=(int)val("SELECT COUNT(*) FROM lost_property WHERE status='stored'");
$decidedToday=(int)val("SELECT COUNT(*) FROM hp_sensitive_actions WHERE status<>'pending' AND DATE(decided_at)=CURDATE()");

page_head('Security','security','Authorizations, audit trail and security events');
echo '<div class="kpis">';
kpi_card('Pending approvals',(string)$pendingCount,'Sensitive actions','warn');
kpi_card('Decided today',(string)$decidedToday,'Approved or rejected','ok');
kpi_card('Failed logins',(string)$failedCount,'All recorded attempts','red');
kpi_card('Lost property held',(string)$storedCount,'Items still stored','warn');
echo '</div>';
echo '<div class="toolbar"><a class="btn" href="'.BASE.'/index.php?page=security">Authorizations</a><a class="btnGhost sm" href="'.BASE.'/index.php?page=security&act=lost">Lost property</a><a class="btnGhost sm" href="'.BASE.'/index.php?page=security&act=audit">Audit trail</a><a class="btnGhost sm" href="'.BASE.'/index.php?page=security&act=export">Export CSV</a></div>';

if($act==='lost'){
  echo '<div class="panel"><h2>Log found property</h2>'; form_open('security','lost');
  echo '<div class="formGrid"><div class="field"><label>Room (optional)</label><select name="room_id"><option value="">No room</option>'; foreach($rooms as $r) echo '<option value="'.(int)$r['id'].'">'.e($r['room_number']).'</option>'; echo '</select></div>';
  echo '<div class="field"><label>Guest (optional)</label><select name="guest_id"><option value="">Unknown</option>'; foreach($guests as $g) echo '<option value="'.(int)$g['id'].'">'.e($g['full_name']).'</option>'; echo '</select></div></div>';
  area('Description','description','','What was found and where?','',3).'<button class="btn">Record item</button>'; form_close(); echo '</div>';
  echo '<div class="panel"><h2>Lost property register</h2><table class="tbl"><thead><tr><th>Item</th><th>Found by</th><th>Found at</th><th>Status</th><th>Released to</th><th></th></tr></thead><tbody>';
  foreach($lost as $l) echo '<tr><td>'.nl2br(e($l['description'])).'<br><small>'.e($l['room_number']??'').'</small></td><td>'.e($l['found_name']??'').'</td><td>'.fmtdt($l['found_at']).'</td><td>'.status_badge($l['status']).'</td><td>'.e($l['released_to']??'').'</td><td>';
  if($l['status']==='stored'){ form_open('security','lost_return'); echo '<input type="hidden" name="lost_id" value="'.(int)$l['id'].'">'.field('Released to','released_to','','text','Guest name and ID',true).'<button class="btn sm">Release</button>'; form_close(); }
  echo '</td></tr>';
  if(!$lost) echo '<tr><td colspan="6" style="text-align:center;color:var(--muted)">No lost property recorded.</td></tr>';
  echo '</tbody></table></div>';
}elseif($act==='audit'){
  echo '<div class="panel"><h2>Audit trail</h2><p class="hint">The latest console actions. Export downloads up to 2,000 entries.</p><table class="tbl"><thead><tr><th>Time</th><th>Actor</th><th>Action</th><th>Entity</th><th>IP</th></tr></thead><tbody>';
  foreach($logs as $l) echo '<tr><td>'.fmtdt($l['created_at']).'</td><td>'.e($l['actor']??'System').'</td><td>'.e(str_replace('_',' ',$l['action'])).'</td><td>'.e(($l['entity_type']??'').' '.($l['entity_id']??'')).'</td><td>'.e($l['ip_address']??'').'</td></tr>';
  if(!$logs) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No audit entries.</td></tr>';
  echo '</tbody></table></div>';
  echo '<div class="panel"><h2>Failed sign-ins</h2><table class="tbl"><thead><tr><th>Time</th><th>Identifier</th><th>User</th><th>Reason</th><th>IP</th></tr></thead><tbody>';
  foreach($failed as $f) echo '<tr><td>'.fmtdt($f['attempted_at']).'</td><td>'.e($f['identifier']??'').'</td><td>'.e($f['user_name']??'').'</td><td>'.e($f['failure_reason']??'').'</td><td>'.e($f['ip_address']??'').'</td></tr>';
  if(!$failed) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No failed sign-ins recorded.</td></tr>';
  echo '</tbody></table></div>';
}else{
  echo '<div class="panel"><h2>Awaiting authorization</h2><p class="hint">Approvals are recorded here; the requesting module applies the action after approval is selected there.</p><table class="tbl"><thead><tr><th>Action</th><th>Entity</th><th class="num">Amount</th><th>Reason</th><th>Requested by</th><th></th></tr></thead><tbody>';
  foreach($pending as $a) echo '<tr><td>'.e(str_replace('_',' ',$a['action_type'])).'</td><td>'.e($a['entity_type'].' #'.$a['entity_id']).'</td><td class="num">'.money($a['amount']).'</td><td>'.e($a['reason']).'</td><td>'.e($a['requester']??'').'</td><td>';
  if(has_role('director')||has_role('general_manager')){
    form_open('security','decide'); echo '<input type="hidden" name="action_id" value="'.(int)$a['id'].'">'.field('Note','note','','text','Decision note');
    echo '<button class="btn sm" name="decision" value="approved">Approve</button> <button class="btnGhost sm" name="decision" value="rejected">Reject</button>'; form_close();
  }else echo badge('View only','grey');
  echo '</td></tr>';
  if(!$pending) echo '<tr><td colspan="6" style="text-align:center;color:var(--muted)">Nothing awaiting authorization.</td></tr>';
  echo '</tbody></table></div>';
  echo '<div class="panel"><h2>Recent decisions</h2><table class="tbl"><thead><tr><th>Action</th><th>Entity</th><th>Decision</th><th>Approver</th><th>Time</th></tr></thead><tbody>';
  foreach($decided as $a) echo '<tr><td>'.e(str_replace('_',' ',$a['action_type'])).'</td><td>'.e($a['entity_type'].' #'.$a['entity_id']).'</td><td>'.status_badge($a['status']).'</td><td>'.e($a['approver']??'').'</td><td>'.fmtdt($a['decided_at']).'</td></tr>';
  if(!$decided) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No decisions recorded.</td></tr>';
  echo '</tbody></table></div>';
}
receipt_print('security');
page_foot();
