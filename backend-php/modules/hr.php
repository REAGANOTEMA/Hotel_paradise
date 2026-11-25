<?php
declare(strict_types=1);

require_once __DIR__.'/../app/enterprise.php';

if(!hp_enterprise_ready(['hp_staff_schedules','hp_payroll_runs','hp_payroll_lines','hp_training_records','hp_disciplinary_records','hp_staff_documents','hp_sensitive_actions'])){
  page_head('Human Resource','hr');
  echo '<div class="panel"><h2>Upgrade required</h2><p class="hint">Run database/sql/patches/2026-11-25_enterprise_expansion.sql to enable rosters, payroll and staff records.</p></div>';
  page_foot(); exit;
}

function hr_staff(): array{
  return rows("SELECT u.id,u.name,u.email,GROUP_CONCAT(ro.name ORDER BY ro.name SEPARATOR ', ') role_names FROM users u LEFT JOIN user_roles ur ON ur.user_id=u.id LEFT JOIN roles ro ON ro.id=ur.role_id WHERE u.status='active' AND u.deleted_at IS NULL GROUP BY u.id ORDER BY u.name");
}

function hr_payroll_totals(int $runId): array{
  return [
    'gross'=>(float)val('SELECT COALESCE(SUM(gross),0) FROM hp_payroll_lines WHERE run_id=?',[$runId]),
    'deductions'=>(float)val('SELECT COALESCE(SUM(deductions),0) FROM hp_payroll_lines WHERE run_id=?',[$runId]),
    'net'=>(float)val('SELECT COALESCE(SUM(net),0) FROM hp_payroll_lines WHERE run_id=?',[$runId]),
    'people'=>(int)val('SELECT COUNT(*) FROM hp_payroll_lines WHERE run_id=?',[$runId])
  ];
}

$act=$_GET['act']??'';
$runId=(int)($_GET['view']??$_POST['run_id']??0);
$me=current_user();
$uid=(int)($me['id']??0);

if($_SERVER['REQUEST_METHOD']==='POST' && $act){
  switch($act){
   case 'schedule':
    $userId=(int)($_POST['user_id']??0);
    $date=hp_date_input($_POST['shift_date']??'');
    $start=trim((string)($_POST['start_time']??''));
    $end=trim((string)($_POST['end_time']??''));
    $outlet=trim((string)($_POST['outlet']??'Front Desk'));
    if($userId<1||$date===''||!preg_match('/^\d{2}:\d{2}$/',$start)||!preg_match('/^\d{2}:\d{2}$/',$end)||$start>=$end){ flash('Choose a colleague, date and a valid time range.','bad'); go('hr',['act'=>'rota']); }
    q('INSERT INTO hp_staff_schedules(hotel_id,user_id,shift_date,start_time,end_time,outlet,status,created_by,created_at) VALUES(1,?,?,?,?,?,\'scheduled\',?,NOW())',[$userId,$date,$start,$end,$outlet,$uid]);
    audit('rota_created','user',$userId,null,['date'=>$date,'start'=>$start,'end'=>$end]);
    notify_console('hr-rota-'.(int)db()->lastInsertId(),'incident','New shift scheduled',$date.' '.$start.'-'.$end.' · '.$outlet,['user_id'=>$userId],['human_resource','director','general_manager'],'user',$userId);
    flash('Shift added to the roster.');
    go('hr',['act'=>'rota']);
    break;

   case 'clock':
    $sid=(int)($_POST['schedule_id']??0);
    $s=row('SELECT * FROM hp_staff_schedules WHERE id=?',[$sid]);
    if(!$s){ flash('Shift not found.','bad'); go('hr',['act'=>'rota']); }
    if($s['status']==='scheduled') q("UPDATE hp_staff_schedules SET status='clocked_in',clocked_in_at=NOW() WHERE id=?",[$sid]);
    elseif($s['status']==='clocked_in'){
      if($s['user_id']!=$uid&&!has_role('director')&&!has_role('general_manager')&&!has_role('human_resource')){ flash('You cannot clock out another colleague.','bad'); go('hr',['act'=>'rota']); }
      q("UPDATE hp_staff_schedules SET status='clocked_out',clocked_out_at=NOW() WHERE id=?",[$sid]);
    }else{ flash('That shift is already closed.','bad'); go('hr',['act'=>'rota']); }
    audit('rota_clock','rota',$sid,['status'=>$s['status']]);
    flash($s['status']==='scheduled'?'Clocked in.':'Clocked out.');
    go('hr',['act'=>'rota']);
    break;

   case 'rota_cancel':
    $sid=(int)($_POST['schedule_id']??0);
    $s=row('SELECT * FROM hp_staff_schedules WHERE id=? AND status=\'scheduled\'',[$sid]);
    if(!$s){ flash('Only scheduled shifts can be cancelled.','bad'); go('hr',['act'=>'rota']); }
    q("UPDATE hp_staff_schedules SET status='cancelled' WHERE id=?",[$sid]);
    audit('rota_cancel','rota',$sid);
    flash('Shift cancelled.');
    go('hr',['act'=>'rota']);
    break;

   case 'run':
    $from=hp_date_input($_POST['period_start']??'');
    $to=hp_date_input($_POST['period_end']??'');
    $rate=hp_money_input($_POST['hourly_rate']??0);
    if($from===''||$to===''||$from>$to){ flash('Enter a valid payroll period.','bad'); go('hr',['act'=>'payroll']); }
    q('INSERT INTO hp_payroll_runs(hotel_id,period_start,period_end,status,created_by,created_at) VALUES(1,?,?,\'draft\',?,NOW())',[$from,$to,$uid]);
    $newId=(int)db()->lastInsertId();
    $worked=rows("SELECT user_id,COUNT(DISTINCT shift_date) days,SUM(TIME_TO_SEC(TIMEDIFF(end_time,start_time)))/3600 hours FROM hp_staff_schedules WHERE shift_date>=? AND shift_date<=? AND status='clocked_out' GROUP BY user_id",[$from,$to]);
    foreach($worked as $w){
      $hours=round((float)$w['hours'],2);
      $gross=round($hours*$rate,2);
      q('INSERT INTO hp_payroll_lines(run_id,user_id,days_worked,hours_worked,hourly_rate,gross,deductions,net) VALUES(?,?,?,?,?,?,0,?)',[$newId,(int)$w['user_id'],(int)$w['days'],$hours,$rate,$gross,$gross]);
    }
    audit('payroll_run','payroll_run',$newId,['from'=>$from,'to'=>$to,'rate'=>$rate]);
    flash('Draft payroll created with '.count($worked).' staff line(s).');
    go('hr',['view'=>$newId]);
    break;

   case 'line':
    $lineId=(int)($_POST['line_id']??0);
    $rate=hp_money_input($_POST['hourly_rate']??0);
    $ded=hp_money_input($_POST['deductions']??0);
    $line=row('SELECT l.*,r.status run_status FROM hp_payroll_lines l JOIN hp_payroll_runs r ON r.id=l.run_id WHERE l.id=?',[$lineId]);
    if(!$line||$line['run_status']!=='draft'){ flash('Only draft payroll lines can be edited.','bad'); go('hr',['view'=>$runId]); }
    $hours=(float)$line['hours_worked'];
    $gross=round($hours*$rate,2);
    $net=round(max(0,$gross-$ded),2);
    q('UPDATE hp_payroll_lines SET hourly_rate=?,gross=?,deductions=?,net=? WHERE id=?',[$rate,$gross,$ded,$net,$lineId]);
    audit('payroll_line','payroll_line',$lineId,['gross'=>(float)$line['gross']],['gross'=>$gross,'deductions'=>$ded,'net'=>$net]);
    flash('Payroll line recalculated.');
    go('hr',['view'=>$runId]);
    break;

   case 'payroll_approve':
    $run=row('SELECT * FROM hp_payroll_runs WHERE id=? AND status=\'draft\'',[$runId]);
    if(!$run){ flash('Only draft payroll can be approved.','bad'); go('hr',['view'=>$runId]); }
    $totals=hr_payroll_totals($runId);
    if($totals['people']<1){ flash('Generate payroll lines before approving.','bad'); go('hr',['view'=>$runId]); }
    $reason=trim((string)($_POST['reason']??'Payroll approval requested'));
    $auth=hp_front_authorized($_POST['authorization_id']??0);
    if($auth===null){
      $created=hp_sensitive_request('payroll_approval','payroll_run',$runId,$totals['net'],$reason);
      flash($created?'Payroll sent for authorization.':'The authorization queue is not installed.');
      go('hr',['view'=>$runId]);
    }
    q("UPDATE hp_payroll_runs SET status='approved',approved_by=?,approved_at=NOW(),authorization_id=? WHERE id=?",[$uid,$auth,$runId]);
    audit('payroll_approved','payroll_run',$runId,['status'=>'draft'],['status'=>'approved','authorization_id'=>$auth]);
    notify_console('hr-payroll-'.$runId,'payment','Payroll approved',money($totals['net']).' for '.$totals['people'].' staff member(s)',['run_id'=>$runId],['director','general_manager','accountant'],'payroll_run',$runId);
    flash('Payroll approved.');
    go('hr',['view'=>$runId]);
    break;

   case 'payroll_paid':
    $run=row('SELECT * FROM hp_payroll_runs WHERE id=? AND status=\'approved\'',[$runId]);
    if(!$run){ flash('Approve payroll before marking it paid.','bad'); go('hr',['view'=>$runId]); }
    if(!has_role('director')&&!has_role('general_manager')&&!has_role('human_resource')&&!has_role('accountant')){ flash('You cannot mark payroll paid.','bad'); go('hr',['view'=>$runId]); }
    q("UPDATE hp_payroll_runs SET status='paid' WHERE id=?",[$runId]);
    audit('payroll_paid','payroll_run',$runId);
    flash('Payroll marked as paid.');
    go('hr',['view'=>$runId]);
    break;

   case 'training':
    $userId=(int)($_POST['user_id']??0);
    $title=trim((string)($_POST['title']??''));
    $provider=trim((string)($_POST['provider']??''));
    $completed=hp_date_input($_POST['completed_on']??'');
    $expiry=hp_date_input($_POST['expiry_date']??'');
    $status=$_POST['status']??'planned';
    $statuses=['planned','completed','certified'];
    if($userId<1||$title===''||!in_array($status,$statuses,true)){ flash('Choose a colleague, title and status.','bad'); go('hr',['act'=>'training']); }
    q('INSERT INTO hp_training_records(hotel_id,user_id,title,provider,completed_on,expiry_date,status,score,notes,created_by,created_at) VALUES(1,?,?,?,?,?,?,NULL,NULL,?,NOW())',[$userId,$title,$provider!==''?$provider:null,$completed!==''?$completed:null,$expiry!==''?$expiry:null,$status,$uid]);
    audit('training_created','user',$userId,['title'=>$title]);
    flash('Training record saved.');
    go('hr',['act'=>'training']);
    break;

   case 'training_update':
    $recordId=(int)($_POST['record_id']??0);
    $status=$_POST['status']??'completed';
    $score=trim((string)($_POST['score']??''));
    if(!in_array($status,['planned','completed','certified'],true)){ flash('Invalid training status.','bad'); go('hr',['act'=>'training']); }
    q('UPDATE hp_training_records SET status=?,score=? WHERE id=?',[$status,$score!==''?$score:null,$recordId]);
    audit('training_update','training',$recordId,null,['status'=>$status]);
    flash('Training record updated.');
    go('hr',['act'=>'training']);
    break;

   case 'discipline':
    $userId=(int)($_POST['user_id']??0);
    $date=hp_date_input($_POST['incident_date']??'');
    $category=trim((string)($_POST['category']??''));
    $severity=$_POST['severity']??'warning';
    $desc=trim((string)($_POST['description']??''));
    $action=trim((string)($_POST['action_taken']??''));
    $sevs=['warning','suspension','termination','other'];
    if($userId<1||$date===''||$category===''||$desc===''||$action===''||!in_array($severity,$sevs,true)){ flash('Complete every disciplinary field.','bad'); go('hr',['act'=>'discipline']); }
    $auth=hp_front_authorized($_POST['authorization_id']??0);
    if($auth===null){
      $created=hp_sensitive_request('disciplinary_action','user',$userId,0,$category.': '.$desc);
      flash($created?'Disciplinary action sent for authorization.':'The authorization queue is not installed.');
      go('hr',['act'=>'discipline']);
    }
    q('INSERT INTO hp_disciplinary_records(hotel_id,user_id,incident_date,category,severity,description,action_taken,authorization_id,recorded_by,created_at) VALUES(1,?,?,?,?,?,?,?,?,NOW())',[$userId,$date,$category,$severity,$desc,$action,$auth,$uid]);
    audit('disciplinary_created','user',$userId,['severity'=>$severity]);
    notify_console('hr-discipline-'.(int)db()->lastInsertId(),'incident','Disciplinary record filed',$category.' · '.$severity,['user_id'=>$userId],['director','general_manager','human_resource'],'user',$userId);
    flash('Disciplinary record filed.');
    go('hr',['act'=>'discipline']);
    break;

   case 'document':
    $userId=(int)($_POST['user_id']??0);
    $type=trim((string)($_POST['document_type']??''));
    $number=trim((string)($_POST['document_number']??''));
    $path=trim((string)($_POST['file_path']??''));
    $expiry=hp_date_input($_POST['expires_on']??'');
    if($userId<1||$type===''){ flash('Choose a colleague and document type.','bad'); go('hr',['act'=>'documents']); }
    q('INSERT INTO hp_staff_documents(hotel_id,user_id,document_type,document_number,file_path,expires_on,created_by,created_at) VALUES(1,?,?,?,?,?,?,NOW())',[$userId,$type,$number!==''?$number:null,$path!==''?$path:null,$expiry!==''?$expiry:null,$uid]);
    audit('staff_document','user',$userId,['type'=>$type]);
    flash('Staff document recorded.');
    go('hr',['act'=>'documents']);
    break;
  }
}

$staff=hr_staff();
$rota=rows('SELECT s.*,u.name staff_name FROM hp_staff_schedules s JOIN users u ON u.id=s.user_id ORDER BY s.shift_date DESC,s.start_time DESC LIMIT 100');
$runs=rows('SELECT r.*,u.name created_name FROM hp_payroll_runs r LEFT JOIN users u ON u.id=r.created_by ORDER BY r.id DESC LIMIT 50');
$training=rows('SELECT t.*,u.name staff_name FROM hp_training_records t JOIN users u ON u.id=t.user_id ORDER BY t.id DESC LIMIT 80');
$discipline=rows('SELECT d.*,u.name staff_name FROM hp_disciplinary_records d JOIN users u ON u.id=d.user_id ORDER BY d.id DESC LIMIT 80');
$documents=rows('SELECT d.*,u.name staff_name FROM hp_staff_documents d JOIN users u ON u.id=d.user_id ORDER BY d.id DESC LIMIT 80');
$expiring=(int)val('SELECT COUNT(*) FROM hp_staff_documents WHERE expires_on IS NOT NULL AND expires_on<=DATE_ADD(CURDATE(),INTERVAL 30 DAY)');
$expiringTraining=(int)val("SELECT COUNT(*) FROM hp_training_records WHERE expiry_date IS NOT NULL AND expiry_date<=DATE_ADD(CURDATE(),INTERVAL 30 DAY) AND status<>'planned'");
$clocked=(int)val("SELECT COUNT(*) FROM hp_staff_schedules WHERE shift_date=CURDATE() AND status='clocked_in'");

page_head('Human Resource','hr','Rosters, attendance, payroll and staff records');
echo '<div class="kpis">';
kpi_card('Clocked in now',(string)$clocked,'On shift today','ok');
kpi_card('Draft payroll',(string)(int)val("SELECT COUNT(*) FROM hp_payroll_runs WHERE status='draft'"),'Awaiting review','warn');
kpi_card('Documents expiring',(string)$expiring,'Within 30 days','warn');
kpi_card('Certificates expiring',(string)$expiringTraining,'Within 30 days','warn');
echo '</div>';
echo '<div class="toolbar">';
foreach(['rota'=>'Roster','payroll'=>'Payroll','training'=>'Training','discipline'=>'Discipline','documents'=>'Documents'] as $k=>$v) echo '<a class="btnGhost sm'.(($act?:'rota')===$k?' active':'').'" href="'.BASE.'/index.php?page=hr&act='.$k.'">'.e($v).'</a>';
echo '</div>';

if($act==='training'){
  echo '<div class="panel"><h2>Add training record</h2>'; form_open('hr','training');
  echo '<div class="formGrid"><div class="field"><label>Colleague</label><select name="user_id" required><option value="">Choose colleague...</option>'; foreach($staff as $s) echo '<option value="'.(int)$s['id'].'">'.e($s['name']).'</option>'; echo '</select></div>';
  echo field('Title','title','e.g. Food hygiene','text','',true).field('Provider','provider','').field('Completed on','completed_on','','date').field('Expiry date','expiry_date','','date');
  echo '<div class="field"><label>Status</label><select name="status">'; foreach(['planned'=>'Planned','completed'=>'Completed','certified'=>'Certified'] as $k=>$v) echo '<option value="'.e($k).'">'.e($v).'</option>'; echo '</select></div></div><button class="btn">Save training</button>'; form_close(); echo '</div>';
  echo '<div class="panel"><h2>Training register</h2><table class="tbl"><thead><tr><th>Colleague</th><th>Title</th><th>Status</th><th>Expiry</th><th></th></tr></thead><tbody>';
  foreach($training as $t) echo '<tr><td>'.e($t['staff_name']).'</td><td>'.e($t['title']).'</td><td>'.status_badge($t['status']).'</td><td>'.($t['expiry_date']&&$t['expiry_date']<=date('Y-m-d',strtotime('+30 days'))?badge($t['expiry_date'],'bad'):e($t['expiry_date']??'')).'</td><td>';
  form_open('hr','training_update'); echo '<input type="hidden" name="record_id" value="'.(int)$t['id'].'"><div class="field"><select name="status">'; foreach(['planned'=>'Planned','completed'=>'Completed','certified'=>'Certified'] as $k=>$v) echo '<option value="'.e($k).'"'.($t['status']===$k?' selected':'').'>'.e($v).'</option>'; echo '</select></div>'.field('Score','score',(string)($t['score']??'')).'<button class="btnGhost sm">Update</button>'; form_close();
  echo '</td></tr>';
  if(!$training) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No training records.</td></tr>';
  echo '</tbody></table></div>';
}elseif($act==='discipline'){
  echo '<div class="panel"><h2>File a disciplinary record</h2>'; form_open('hr','discipline');
  echo '<div class="formGrid"><div class="field"><label>Colleague</label><select name="user_id" required><option value="">Choose colleague...</option>'; foreach($staff as $s) echo '<option value="'.(int)$s['id'].'">'.e($s['name']).'</option>'; echo '</select></div>';
  echo field('Incident date','incident_date',today(),'date','',true).field('Category','category','e.g. lateness','text','',true);
  echo '<div class="field"><label>Severity</label><select name="severity">'; foreach(['warning'=>'Warning','suspension'=>'Suspension','termination'=>'Termination','other'=>'Other'] as $k=>$v) echo '<option value="'.e($k).'">'.e($v).'</option>'; echo '</select></div></div>';
  area('Description','description','','What happened?','',3).area('Action taken','action_taken','','What action is proposed?','',3);
  echo '<div class="field"><label>Authorization (after approval)</label><select name="authorization_id"><option value="">Request approval first</option>';
  foreach(rows("SELECT a.id,a.action_type,a.reason,u.name requester FROM hp_sensitive_actions a LEFT JOIN users u ON u.id=a.requested_by WHERE a.action_type='disciplinary_action' AND a.status='approved' ORDER BY a.id DESC LIMIT 20") as $a) echo '<option value="'.(int)$a['id'].'">#'.(int)$a['id'].' · '.e($a['requester']??'').' · '.e($a['reason']).'</option>';
  echo '</select></div><button class="btn">File record</button>'; form_close(); echo '</div>';
  echo '<div class="panel"><h2>Disciplinary register</h2><table class="tbl"><thead><tr><th>Colleague</th><th>Date</th><th>Category</th><th>Severity</th><th></th></tr></thead><tbody>';
  foreach($discipline as $d) echo '<tr><td>'.e($d['staff_name']).'</td><td>'.e($d['incident_date']).'</td><td>'.e($d['category']).'</td><td>'.status_badge($d['severity']).'</td><td><details><summary>View</summary><p>'.nl2br(e($d['description'])).'</p><p><b>Action:</b> '.nl2br(e($d['action_taken'])).'</p></details></td></tr>';
  if(!$discipline) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No disciplinary records.</td></tr>';
  echo '</tbody></table></div>';
}elseif($act==='documents'){
  echo '<div class="panel"><h2>Record a staff document</h2>'; form_open('hr','document');
  echo '<div class="formGrid"><div class="field"><label>Colleague</label><select name="user_id" required><option value="">Choose colleague...</option>'; foreach($staff as $s) echo '<option value="'.(int)$s['id'].'">'.e($s['name']).'</option>'; echo '</select></div>';
  echo field('Document type','document_type','e.g. National ID','text','',true).field('Document number','document_number','').field('File path or URL','file_path','','text','Path inside storage or a link').field('Expires on','expires_on','','date').'</div><button class="btn">Save document</button>'; form_close(); echo '</div>';
  echo '<div class="panel"><h2>Staff documents</h2><table class="tbl"><thead><tr><th>Colleague</th><th>Type</th><th>Number</th><th>Expires</th><th>File</th></tr></thead><tbody>';
  foreach($documents as $d) echo '<tr><td>'.e($d['staff_name']).'</td><td>'.e($d['document_type']).'</td><td>'.e($d['document_number']??'').'</td><td>'.($d['expires_on']&&$d['expires_on']<=date('Y-m-d',strtotime('+30 days'))?badge($d['expires_on'],'bad'):e($d['expires_on']??'')).'</td><td>'.($d['file_path']?e($d['file_path']):'—').'</td></tr>';
  if(!$documents) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No staff documents recorded.</td></tr>';
  echo '</tbody></table></div>';
}elseif($act==='payroll'){
  if($runId){
    $run=row('SELECT r.*,u.name created_name FROM hp_payroll_runs r LEFT JOIN users u ON u.id=r.created_by WHERE r.id=?',[$runId]);
    if($run){
      $totals=hr_payroll_totals($runId);
      $lines=rows('SELECT l.*,u.name staff_name FROM hp_payroll_lines l JOIN users u ON u.id=l.user_id WHERE l.run_id=? ORDER BY u.name',[$runId]);
      $auths=rows("SELECT * FROM hp_sensitive_actions WHERE entity_type='payroll_run' AND entity_id=? ORDER BY id DESC LIMIT 10",[$runId]);
      echo '<div class="panel"><h2>Payroll '.e($run['period_start']).' to '.e($run['period_end']).'</h2><p class="hint">'.status_badge($run['status']).' · '.$totals['people'].' staff · Gross '.money($totals['gross']).' · Deductions '.money($totals['deductions']).' · Net '.money($totals['net']).'</p>';
      echo '<table class="tbl"><thead><tr><th>Colleague</th><th class="num">Days</th><th class="num">Hours</th><th class="num">Rate</th><th class="num">Gross</th><th class="num">Deductions</th><th class="num">Net</th><th></th></tr></thead><tbody>';
      foreach($lines as $l) echo '<tr><td>'.e($l['staff_name']).'</td><td class="num">'.e($l['days_worked']).'</td><td class="num">'.e($l['hours_worked']).'</td><td class="num">'.money($l['hourly_rate']).'</td><td class="num">'.money($l['gross']).'</td><td class="num">'.money($l['deductions']).'</td><td class="num">'.money($l['net']).'</td><td>';
      if($run['status']==='draft'){ form_open('hr','line',['view'=>$runId]); echo '<input type="hidden" name="line_id" value="'.(int)$l['id'].'">'.field('Rate','hourly_rate',(string)$l['hourly_rate'],'number','',true).field('Deductions','deductions',(string)$l['deductions'],'number','',true).'<button class="btnGhost sm">Recalculate</button>'; form_close(); }
      echo '</td></tr>';
      if(!$lines) echo '<tr><td colspan="8" style="text-align:center;color:var(--muted)">No lines. Clock out shifts in the roster before generating payroll.</td></tr>';
      echo '</tbody></table>';
      if($run['status']==='draft'){
        form_open('hr','payroll_approve',['view'=>$runId]); echo field('Approval reason','reason','Payroll approval requested','text','',true);
        echo '<div class="field"><label>Authorization (after approval)</label><select name="authorization_id"><option value="">Request approval first</option>'; foreach($auths as $a) echo '<option value="'.(int)$a['id'].'">#'.(int)$a['id'].' · '.e($a['status']).' · '.e($a['reason']).'</option>'; echo '</select></div><button class="btn">Request or apply approval</button>'; form_close();
      }
      if($run['status']==='approved'){ form_open('hr','payroll_paid',['view'=>$runId]); echo '<button class="btn">Mark as paid</button>'; form_close(); }
      echo '</div>';
    }
  }
  echo '<div class="panel"><h2>Generate a draft payroll run</h2>'; form_open('hr','run');
  echo '<div class="formGrid">'.field('Period start','period_start',date('Y-m-01'),'date','',true).field('Period end','period_end',date('Y-m-t'),'date','',true).field('Default hourly rate','hourly_rate','','number','Used for clocked-out shifts',true).'</div><button class="btn">Generate payroll</button>'; form_close(); echo '</div>';
  echo '<div class="panel"><h2>Payroll runs</h2><table class="tbl"><thead><tr><th>Period</th><th>Status</th><th class="num">Net</th><th>Created by</th><th></th></tr></thead><tbody>';
  foreach($runs as $r){ $tot=hr_payroll_totals((int)$r['id']); echo '<tr><td>'.e($r['period_start']).' to '.e($r['period_end']).'</td><td>'.status_badge($r['status']).'</td><td class="num">'.money($tot['net']).'</td><td>'.e($r['created_name']??'').'</td><td><a class="btn sm" href="'.BASE.'/index.php?page=hr&act=payroll&view='.(int)$r['id'].'">Open</a></td></tr>'; }
  if(!$runs) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No payroll runs yet.</td></tr>';
  echo '</tbody></table></div>';
}else{
  echo '<div class="panel"><h2>Add a shift</h2>'; form_open('hr','schedule');
  echo '<div class="formGrid"><div class="field"><label>Colleague</label><select name="user_id" required><option value="">Choose colleague...</option>'; foreach($staff as $s) echo '<option value="'.(int)$s['id'].'">'.e($s['name'].' ('.($s['role_names']??'staff').')').'</option>'; echo '</select></div>';
  echo field('Date','shift_date',today(),'date','',true).field('Start','start_time','08:00','time','',true).field('End','end_time','16:00','time','',true).field('Outlet','outlet','Front Desk','text','',true).'</div><button class="btn">Add to roster</button>'; form_close(); echo '</div>';
  echo '<div class="panel"><h2>Roster and attendance</h2><table class="tbl"><thead><tr><th>Date</th><th>Colleague</th><th>Shift</th><th>Outlet</th><th>Status</th><th></th></tr></thead><tbody>';
  foreach($rota as $s) echo '<tr><td>'.e($s['shift_date']).'</td><td>'.e($s['staff_name']).'</td><td>'.e($s['start_time']).' - '.e($s['end_time']).'</td><td>'.e($s['outlet']).'</td><td>'.status_badge($s['status']).'</td><td>';
  if($s['status']==='scheduled'||$s['status']==='clocked_in'){ form_open('hr','clock'); echo '<input type="hidden" name="schedule_id" value="'.(int)$s['id'].'"><button class="btn sm">'.($s['status']==='scheduled'?'Clock in':'Clock out').'</button>'; form_close(); }
  if($s['status']==='scheduled'){ form_open('hr','rota_cancel'); echo '<input type="hidden" name="schedule_id" value="'.(int)$s['id'].'"><button class="btnGhost sm">Cancel</button>'; form_close(); }
  echo '</td></tr>';
  if(!$rota) echo '<tr><td colspan="6" style="text-align:center;color:var(--muted)">No shifts scheduled.</td></tr>';
  echo '</tbody></table></div>';
}
receipt_print('hr');
page_foot();
