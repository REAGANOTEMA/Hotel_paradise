<?php
declare(strict_types=1);

require_once __DIR__.'/../app/enterprise.php';

if(!hp_enterprise_ready(['hp_maintenance_costs','hp_preventive_schedules','maintenance_tickets','maintenance_assets'])){
  page_head('Maintenance','maintenance');
  echo '<div class="panel"><h2>Upgrade required</h2><p class="hint">Run database/sql/patches/2026-11-25_enterprise_expansion.sql to enable cost capture and preventive schedules.</p></div>';
  page_foot(); exit;
}

function mt_next_due(string $freq,string $from): string{
  $formats=['daily'=>'+1 day','weekly'=>'+1 week','monthly'=>'+1 month','quarterly'=>'+3 months','annually'=>'+1 year'];
  $mod=$formats[$freq]??'+1 month';
  return date('Y-m-d',strtotime($from.' '.$mod));
}

function mt_room_release(int $roomId): bool{
  $open=(int)val("SELECT COUNT(*) FROM maintenance_tickets WHERE room_id=? AND status NOT IN('resolved','closed')",[$roomId]);
  if($open>0) return false;
  q("UPDATE rooms SET status='dirty' WHERE id=? AND status='maintenance'",[$roomId]);
  return true;
}

$act=$_GET['act']??'';
$tid=(int)($_GET['id']??$_POST['ticket_id']??0);
$me=current_user();
$uid=(int)($me['id']??0);

if($_SERVER['REQUEST_METHOD']==='POST' && $act){
  switch($act){
   case 'ticket':
    $roomId=(int)($_POST['room_id']??0);
    $assetId=(int)($_POST['asset_id']??0);
    $title=trim((string)($_POST['title']??''));
    $desc=trim((string)($_POST['description']??''));
    $priority=$_POST['priority']??'normal';
    $prios=['low'=>'Low','normal'=>'Normal','high'=>'High','urgent'=>'Urgent'];
    if($title===''||$desc===''||!isset($prios[$priority])||($roomId<1&&$assetId<1)){ flash('Give a title, description, priority and either a room or asset.','bad'); go('maintenance'); }
    q('INSERT INTO maintenance_tickets(property_id,department_id,room_id,asset_id,reported_by,assigned_to,title,description,priority,status) VALUES(1,NULL,?,?,?,NULL,?,?,?, \'open\')',[$roomId>0?$roomId:null,$assetId>0?$assetId:null,$uid,$title,$desc,$priority]);
    $newId=(int)db()->lastInsertId();
    if($roomId>0) q("UPDATE rooms SET status='maintenance' WHERE id=? AND status<>'occupied'",[$roomId]);
    audit('maintenance_ticket','maintenance_ticket',$newId,['title'=>$title]);
    notify_console('mt-ticket-'.$newId,'incident','Maintenance ticket: '.$title,$desc,['ticket_id'=>$newId,'room_id'=>$roomId,'asset_id'=>$assetId],['maintenance','director','general_manager'],'maintenance_ticket',$newId);
    flash('Maintenance ticket recorded.');
    go('maintenance',['view'=>$newId]);
    break;

   case 'assign':
    $t=row('SELECT * FROM maintenance_tickets WHERE id=? AND status IN(\'open\',\'assigned\',\'in_progress\',\'waiting_parts\')',[$tid]);
    $assigned=(int)($_POST['assigned_to']??0);
    if(!$t||$assigned<1){ flash('Choose a ticket and an engineer.','bad'); go('maintenance',['view'=>$tid]); }
    q("UPDATE maintenance_tickets SET assigned_to=?,status='assigned' WHERE id=?",[$assigned,$tid]);
    audit('maintenance_assign','maintenance_ticket',$tid,['status'=>$t['status']],['assigned_to'=>$assigned]);
    notify_console('mt-assign-'.$tid,'incident','Maintenance ticket assigned',(string)$t['title'],['ticket_id'=>$tid],['maintenance','director'],'maintenance_ticket',$tid);
    flash('Ticket assigned.');
    go('maintenance',['view'=>$tid]);
    break;

   case 'status':
    $status=$_POST['next_status']??'';
    $allowed=['in_progress','waiting_parts','resolved','closed'];
    if(!in_array($status,$allowed,true)){ flash('That status change is not allowed.','bad'); go('maintenance',['view'=>$tid]); }
    $t=row('SELECT * FROM maintenance_tickets WHERE id=? AND status NOT IN(\'closed\')',[$tid]);
    if(!$t){ flash('Ticket not found or already closed.','bad'); go('maintenance',['view'=>$tid]); }
    if($status==='closed'&&!has_role('director')&&!has_role('general_manager')&&!has_role('maintenance')){ flash('Only maintenance or management can close a ticket.','bad'); go('maintenance',['view'=>$tid]); }
    if($status==='closed'&&$t['status']!=='resolved'){ flash('Resolve the ticket before closing it.','bad'); go('maintenance',['view'=>$tid]); }
    $when=in_array($status,['resolved','closed'],true)?',resolved_at=NOW()':'';
    q("UPDATE maintenance_tickets SET assigned_to=COALESCE(assigned_to,?),status=?$when WHERE id=?",[$uid,$status,$tid]);
    $released=false;
    if($status==='closed'&&$t['room_id']) $released=mt_room_release((int)$t['room_id']);
    audit('maintenance_status','maintenance_ticket',$tid,['status'=>$t['status']],['status'=>$status]);
    notify_console('mt-status-'.$tid,'incident','Maintenance '.str_replace('_',' ',$status),(string)$t['title'].($released?' · room sent to housekeeping':''),['ticket_id'=>$tid],['maintenance','housekeeping','director','general_manager'],'maintenance_ticket',$tid);
    flash('Ticket marked '.str_replace('_',' ',$status).'.');
    go('maintenance',['view'=>$tid]);
    break;

   case 'cost':
    $t=row('SELECT * FROM maintenance_tickets WHERE id=?',[$tid]);
    $amount=hp_money_input($_POST['amount']??0);
    $desc=trim((string)($_POST['description']??''));
    if(!$t||$amount<=0||$desc===''){ flash('Enter a cost amount and description.','bad'); go('maintenance',['view'=>$tid]); }
    q('INSERT INTO hp_maintenance_costs(hotel_id,ticket_id,amount,description,recorded_by,created_at) VALUES(1,?,?,?,?,NOW())',[$tid,$amount,$desc,$uid]);
    audit('maintenance_cost','maintenance_ticket',$tid,null,['amount'=>$amount,'description'=>$desc]);
    notify_console('mt-cost-'.$tid,'payment','Maintenance cost recorded',money($amount).' · '.$desc,['ticket_id'=>$tid],['accountant','director','general_manager'],'maintenance_ticket',$tid);
    flash('Cost of '.money($amount).' recorded.');
    go('maintenance',['view'=>$tid]);
    break;

   case 'asset':
    $name=trim((string)($_POST['name']??''));
    $code=trim((string)($_POST['asset_code']??''));
    $location=trim((string)($_POST['location']??''));
    if($name===''){ flash('Enter the asset name.','bad'); go('maintenance',['act'=>'assets']); }
    q('INSERT INTO maintenance_assets(property_id,name,asset_code,location,status,purchase_date,warranty_end) VALUES(1,?,?,?,\'active\',NULL,NULL)',[$name,$code!==''?$code:null,$location!==''?$location:null]);
    audit('asset_created','asset',(int)db()->lastInsertId(),['name'=>$name]);
    flash('Asset registered.');
    go('maintenance',['act'=>'assets']);
    break;

   case 'schedule':
    $title=trim((string)($_POST['title']??''));
    $freq=$_POST['frequency']??'monthly';
    $due=hp_date_input($_POST['next_due']??'');
    $assetId=(int)($_POST['asset_id']??0);
    $freqs=['daily','weekly','monthly','quarterly','annually'];
    if($title===''||$due===''||!in_array($freq,$freqs,true)){ flash('Enter a title, frequency and due date.','bad'); go('maintenance',['act'=>'preventive']); }
    q('INSERT INTO hp_preventive_schedules(hotel_id,asset_id,title,frequency,next_due,active,created_by,created_at) VALUES(1,?,?,?,?,1,?,NOW())',[$assetId>0?$assetId:null,$title,$freq,$due,$uid]);
    audit('preventive_schedule','schedule',(int)db()->lastInsertId(),['title'=>$title]);
    notify_console('mt-schedule-'.(int)db()->lastInsertId(),'incident','Preventive schedule created',$title.' due '.$due,['title'=>$title],['maintenance','director'],null,null);
    flash('Preventive schedule created.');
    go('maintenance',['act'=>'preventive']);
    break;

   case 'preventive_done':
    $sid=(int)($_POST['schedule_id']??0);
    $s=row('SELECT * FROM hp_preventive_schedules WHERE id=? AND active=1',[$sid]);
    if(!$s){ flash('Schedule not found.','bad'); go('maintenance',['act'=>'preventive']); }
    $done=hp_date_input($_POST['done_on']??today())?:today();
    q('UPDATE hp_preventive_schedules SET last_done=?,next_due=? WHERE id=?',[$done,mt_next_due((string)$s['frequency'],$done),$sid]);
    audit('preventive_done','schedule',$sid,['next_due'=>$s['next_due']],['last_done'=>$done]);
    flash('Preventive task closed and the next due date set.');
    go('maintenance',['act'=>'preventive']);
    break;

   case 'preventive_toggle':
    $sid=(int)($_POST['schedule_id']??0);
    $s=row('SELECT * FROM hp_preventive_schedules WHERE id=?',[$sid]);
    if(!$s){ flash('Schedule not found.','bad'); go('maintenance',['act'=>'preventive']); }
    q('UPDATE hp_preventive_schedules SET active=? WHERE id=?',[$s['active']?0:1,$sid]);
    audit('preventive_toggle','schedule',$sid,['active'=>$s['active']],['active'=>$s['active']?0:1]);
    flash($s['active']?'Schedule paused.':'Schedule activated.');
    go('maintenance',['act'=>'preventive']);
    break;
  }
}

$statuses=['open','assigned','in_progress','waiting_parts','resolved','closed'];
$filter=in_array($_GET['status']??'',$statuses,true)?$_GET['status']:'';
$where=$filter!==''?'WHERE t.status=?':'WHERE t.status<>\'closed\'';
$params=$filter!==''?[$filter]:[];
$tickets=rows("SELECT t.*,r.room_number,a.name asset_name,u.name assigned_name FROM maintenance_tickets t LEFT JOIN rooms r ON r.id=t.room_id LEFT JOIN maintenance_assets a ON a.id=t.asset_id LEFT JOIN users u ON u.id=t.assigned_to $where ORDER BY FIELD(t.priority,'urgent','high','normal','low'),t.id DESC LIMIT 100",$params);
$rooms=rows("SELECT r.id,r.room_number,r.status,rt.name rtype FROM rooms r JOIN room_types rt ON rt.id=r.room_type_id WHERE r.deleted_at IS NULL ORDER BY r.room_number");
$assets=rows('SELECT * FROM maintenance_assets ORDER BY name');
$users=rows("SELECT DISTINCT u.id,u.name FROM users u LEFT JOIN user_roles ur ON ur.user_id=u.id LEFT JOIN roles ro ON ro.id=ur.role_id WHERE u.status='active' AND (ro.name='maintenance' OR ro.name IS NULL) ORDER BY u.name");
$schedules=rows('SELECT s.*,a.name asset_name FROM hp_preventive_schedules s LEFT JOIN maintenance_assets a ON a.id=s.asset_id ORDER BY s.next_due LIMIT 100');
$counts=[];
foreach($statuses as $s) $counts[$s]=(int)val('SELECT COUNT(*) FROM maintenance_tickets WHERE status=?',[$s]);
$dueCount=(int)val('SELECT COUNT(*) FROM hp_preventive_schedules WHERE active=1 AND next_due<=CURDATE()');
$openCost=(float)val('SELECT COALESCE(SUM(c.amount),0) FROM hp_maintenance_costs c JOIN maintenance_tickets t ON t.id=c.ticket_id WHERE t.status<>\'closed\'');

page_head('Maintenance','maintenance','Tickets, preventive schedules and asset costs');
echo '<div class="kpis">';
kpi_card('Open tickets',(string)($counts['open']+$counts['assigned']+$counts['in_progress']+$counts['waiting_parts']),'Across the property','warn');
kpi_card('Preventive due',(string)$dueCount,'Schedules overdue or due today','warn');
kpi_card('Resolved awaiting close',(string)$counts['resolved'],'Ready to close');
kpi_card('Open ticket cost',money($openCost),'Recorded against active jobs');
echo '</div>';
echo '<div class="toolbar"><a class="btn" href="'.BASE.'/index.php?page=maintenance">Tickets</a><a class="btnGhost sm" href="'.BASE.'/index.php?page=maintenance&act=preventive">Preventive schedules</a><a class="btnGhost sm" href="'.BASE.'/index.php?page=maintenance&act=assets">Assets</a></div>';

if($act==='assets'){
  echo '<div class="panel"><h2>Register an asset</h2>'; form_open('maintenance','asset');
  echo '<div class="formGrid">'.field('Asset name','name','e.g. Boiler pump','text','',true).field('Asset code','asset_code','e.g. ENG-014').field('Location','location','e.g. Laundry plant').'</div><button class="btn">Register asset</button>'; form_close(); echo '</div>';
  echo '<div class="panel"><h2>Asset register</h2><table class="tbl"><thead><tr><th>Asset</th><th>Code</th><th>Location</th><th>Status</th></tr></thead><tbody>';
  foreach($assets as $a) echo '<tr><td>'.e($a['name']).'</td><td>'.e($a['asset_code']??'').'</td><td>'.e($a['location']??'').'</td><td>'.status_badge($a['status']).'</td></tr>';
  if(!$assets) echo '<tr><td colspan="4" style="text-align:center;color:var(--muted)">No assets registered.</td></tr>';
  echo '</tbody></table></div>';
}elseif($act==='preventive'){
  echo '<div class="twoCol"><div class="panel"><h2>New preventive schedule</h2>'; form_open('maintenance','schedule');
  echo '<div class="formGrid">'.field('Title','title','e.g. AC filter service','text','',true);
  echo '<div class="field"><label>Asset</label><select name="asset_id"><option value="">No specific asset</option>'; foreach($assets as $a) echo '<option value="'.(int)$a['id'].'">'.e($a['name']).'</option>'; echo '</select></div>';
  echo '<div class="field"><label>Frequency</label><select name="frequency">'; foreach(['daily'=>'Daily','weekly'=>'Weekly','monthly'=>'Monthly','quarterly'=>'Quarterly','annually'=>'Annually'] as $k=>$v) echo '<option value="'.e($k).'"'.($k==='monthly'?' selected':'').'>'.e($v).'</option>'; echo '</select></div>';
  echo field('Next due','next_due',today(),'date','',true).'</div><button class="btn">Create schedule</button>'; form_close(); echo '</div>';
  echo '<div class="panel"><h2>Preventive schedule</h2><table class="tbl"><thead><tr><th>Title</th><th>Asset</th><th>Frequency</th><th>Next due</th><th></th></tr></thead><tbody>';
  foreach($schedules as $s) echo '<tr><td>'.e($s['title']).'</td><td>'.e($s['asset_name']??'General').'</td><td>'.e($s['frequency']).'</td><td>'.($s['active']&&$s['next_due']<=today()?badge($s['next_due'],'bad'):e($s['next_due'])).'</td><td>';
  form_open('maintenance','preventive_done'); echo '<input type="hidden" name="schedule_id" value="'.(int)$s['id'].'"><input type="hidden" name="done_on" value="'.today().'"><button class="btn sm">Done</button>'; form_close();
  form_open('maintenance','preventive_toggle'); echo '<input type="hidden" name="schedule_id" value="'.(int)$s['id'].'"><button class="btnGhost sm">'.($s['active']?'Pause':'Activate').'</button>'; form_close();
  echo '</td></tr>';
  if(!$schedules) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No preventive schedules.</td></tr>';
  echo '</tbody></table></div></div>';
}else{
  echo '<div class="panel"><h2>Raise a maintenance ticket</h2>'; form_open('maintenance','ticket');
  echo '<div class="formGrid"><div class="field"><label>Room</label><select name="room_id"><option value="">No room</option>'; foreach($rooms as $r) echo '<option value="'.(int)$r['id'].'">'.e($r['room_number'].' · '.$r['rtype'].' · '.$r['status']).'</option>'; echo '</select></div>';
  echo '<div class="field"><label>Asset</label><select name="asset_id"><option value="">No asset</option>'; foreach($assets as $a) echo '<option value="'.(int)$a['id'].'">'.e($a['name']).'</option>'; echo '</select></div>';
  echo field('Title','title','','text','Short fault description',true);
  echo '<div class="field"><label>Priority</label><select name="priority">'; foreach(['low'=>'Low','normal'=>'Normal','high'=>'High','urgent'=>'Urgent'] as $k=>$v) echo '<option value="'.e($k).'"'.($k==='normal'?' selected':'').'>'.e($v).'</option>'; echo '</select></div></div>';
  area('Description','description','','What is faulty and where is it?','',3).'<button class="btn">Raise ticket</button>'; form_close(); echo '</div>';

  echo '<div class="toolbar">';
  foreach($statuses as $s) echo '<a class="btnGhost sm'.($filter===$s?' active':'').'" href="'.BASE.'/index.php?page=maintenance'.($s!==''?'&status='.$s:'').'">'.e(ucfirst(str_replace('_',' ',$s))).' ('.$counts[$s].')</a>';
  echo '</div>';
  echo '<div class="panel"><h2>Ticket register</h2><table class="tbl"><thead><tr><th>Title</th><th>Location</th><th>Assigned</th><th>Priority</th><th>Status</th><th></th></tr></thead><tbody>';
  foreach($tickets as $t) echo '<tr><td>'.e($t['title']).'</td><td>'.e($t['room_number']??$t['asset_name']??'General').'</td><td>'.e($t['assigned_name']??'Unassigned').'</td><td>'.status_badge($t['priority']).'</td><td>'.status_badge($t['status']).'</td><td><a class="btn sm" href="'.BASE.'/index.php?page=maintenance&view='.(int)$t['id'].'">Open</a></td></tr>';
  if(!$tickets) echo '<tr><td colspan="6" style="text-align:center;color:var(--muted)">No tickets in this view.</td></tr>';
  echo '</tbody></table></div>';

  if($tid){
    $t=row('SELECT t.*,r.room_number,a.name asset_name,u.name assigned_name FROM maintenance_tickets t LEFT JOIN rooms r ON r.id=t.room_id LEFT JOIN maintenance_assets a ON a.id=t.asset_id LEFT JOIN users u ON u.id=t.assigned_to WHERE t.id=?',[$tid]);
    if($t){
      $costs=rows('SELECT c.*,u.name actor FROM hp_maintenance_costs c LEFT JOIN users u ON u.id=c.recorded_by WHERE c.ticket_id=? ORDER BY c.id DESC',[$tid]);
      $total=(float)val('SELECT COALESCE(SUM(amount),0) FROM hp_maintenance_costs WHERE ticket_id=?',[$tid]);
      echo '<div class="panel"><h2>Ticket #'.(int)$tid.' · '.e($t['title']).'</h2><p class="hint">'.status_badge($t['status']).' · '.e($t['room_number']??$t['asset_name']??'General').' · '.status_badge($t['priority']).' · Assigned to '.e($t['assigned_name']??'nobody').'</p>';
      echo '<p>'.nl2br(e($t['description'])).'</p><p><b>Total cost:</b> '.money($total).'</p>';
      echo '<div class="formGrid"><div><h3>Assign engineer</h3>'; form_open('maintenance','assign',['view'=>$tid]);
      echo '<div class="field"><label>Engineer</label><select name="assigned_to">'; foreach($users as $u) echo '<option value="'.(int)$u['id'].'"'.((int)$t['assigned_to']===(int)$u['id']?' selected':'').'>'.e($u['name']).'</option>'; echo '</select></div><button class="btnGhost sm">Assign</button>'; form_close(); echo '</div>';
      echo '<div><h3>Advance status</h3>'; form_open('maintenance','status',['view'=>$tid]);
      echo '<div class="field"><label>Next status</label><select name="next_status">'; foreach($allowedStatuses=['in_progress'=>'In progress','waiting_parts'=>'Waiting parts','resolved'=>'Resolved','closed'=>'Closed'] as $k=>$v) echo '<option value="'.e($k).'">'.e($v).'</option>'; echo '</select></div><button class="btn sm">Update</button>'; form_close(); echo '</div>';
      echo '<div><h3>Record cost</h3>'; form_open('maintenance','cost',['view'=>$tid]);
      echo field('Amount','amount','','number','',true).field('Description','description','','text','e.g. replacement part',true).'<button class="btnGhost sm">Add cost</button>'; form_close(); echo '</div></div>';
      echo '<h3 style="margin-top:16px">Costs</h3><table class="tbl"><thead><tr><th>Description</th><th class="num">Amount</th><th>By</th></tr></thead><tbody>';
      foreach($costs as $c) echo '<tr><td>'.e($c['description']).'</td><td class="num">'.money($c['amount']).'</td><td>'.e($c['actor']??'').'</td></tr>';
      if(!$costs) echo '<tr><td colspan="3" style="text-align:center;color:var(--muted)">No costs recorded.</td></tr>';
      echo '</tbody></table></div>';
    }
  }
}
receipt_print('maintenance');
page_foot();
