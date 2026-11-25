<?php
declare(strict_types=1);

require_once __DIR__.'/../app/enterprise.php';

if(!hp_enterprise_ready(['hp_cleaning_checklists','hp_linen_stock','hp_linen_movements','housekeeping_tasks'])){
  page_head('Housekeeping','housekeeping');
  echo '<div class="panel"><h2>Upgrade required</h2><p class="hint">Run database/sql/patches/2026-11-25_enterprise_expansion.sql to enable checklists and linen control.</p></div>';
  page_foot(); exit;
}

function hk_items(): array{
  return ['Bed linen changed','Bathroom cleaned and sanitised','Floor vacuumed and mopped','Dusting and surfaces wiped','Towels and amenities replaced','Rubbish removed','Windows and mirrors cleaned','Final room inspection'];
}

function hk_stock_adjust(string $item,string $location,int $qty): bool{
  if($item===''||$location==='') return false;
  q('INSERT INTO hp_linen_stock(hotel_id,item_name,location,quantity,reorder_level) VALUES(1,?,?,?,0) ON DUPLICATE KEY UPDATE quantity=quantity+VALUES(quantity)',[$item,$location,$qty]);
  return true;
}

function hk_task_checklist(int $taskId,int $roomId): void{
  foreach(hk_items() as $item) q('INSERT INTO hp_cleaning_checklists(hotel_id,task_id,room_id,item_name,created_at) VALUES(1,?,?,?,NOW())',[$taskId,$roomId,$item]);
}

$act=$_GET['act']??'';
$tid=(int)($_GET['id']??$_POST['task_id']??0);
$me=current_user();
$uid=(int)($me['id']??0);

if($_SERVER['REQUEST_METHOD']==='POST' && $act){
  switch($act){
   case 'create':
    $roomId=(int)($_POST['room_id']??0);
    $assigned=(int)($_POST['assigned_to']??0);
    $type=$_POST['task_type']??'cleaning';
    $priority=$_POST['priority']??'normal';
    $notes=trim((string)($_POST['notes']??''));
    $types=['cleaning'=>'Cleaning','inspection'=>'Inspection','turn_down'=>'Turn down','deep_clean'=>'Deep clean','other'=>'Other'];
    $prios=['low'=>'Low','normal'=>'Normal','high'=>'High','urgent'=>'Urgent'];
    if($roomId<1||!isset($types[$type])||!isset($prios[$priority])){ flash('Choose a room, task type and priority.','bad'); go('housekeeping'); }
    q('INSERT INTO housekeeping_tasks(property_id,room_id,assigned_to,task_type,priority,status,notes,created_at) VALUES(1,?,?,?,?,?,?,NOW())',[$roomId,$assigned>0?$assigned:null,$type,$priority,$assigned>0?'assigned':'pending',$notes]);
    $newId=(int)db()->lastInsertId();
    hk_task_checklist($newId,$roomId);
    q("UPDATE rooms SET status='cleaning' WHERE id=? AND status='dirty'",[$roomId]);
    audit('housekeeping_task','housekeeping_task',$newId,['room_id'=>$roomId]);
    notify_console('hk-task-'.$newId,'incident',ucfirst($types[$type]).' task raised','Room '.(string)val('SELECT room_number FROM rooms WHERE id=?',[$roomId]).' · '.$prios[$priority].' priority',['task_id'=>$newId,'room_id'=>$roomId],['housekeeping','director','general_manager'],'housekeeping_task',$newId);
    flash('Housekeeping task created with a checklist.');
    go('housekeeping',['view'=>$newId]);
    break;

   case 'assign':
    $t=row('SELECT * FROM housekeeping_tasks WHERE id=? AND status IN(\'pending\',\'assigned\',\'in_progress\')',[$tid]);
    $assigned=(int)($_POST['assigned_to']??0);
    if(!$t||$assigned<1){ flash('Choose a task and an assigned colleague.','bad'); go('housekeeping',['view'=>$tid]); }
    q("UPDATE housekeeping_tasks SET assigned_to=?,status='assigned' WHERE id=?",[$assigned,$tid]);
    audit('housekeeping_assign','housekeeping_task',$tid,['status'=>$t['status']],['assigned_to'=>$assigned]);
    notify_console('hk-assign-'.$tid,'incident','Housekeeping task assigned',ucfirst((string)$t['task_type']).' task assigned to '.(string)val('SELECT name FROM users WHERE id=?',[$assigned]),['task_id'=>$tid],['housekeeping','director'],'housekeeping_task',$tid);
    flash('Task assigned.');
    go('housekeeping',['view'=>$tid]);
    break;

   case 'start':
    $t=row('SELECT * FROM housekeeping_tasks WHERE id=? AND status IN(\'pending\',\'assigned\')',[$tid]);
    if(!$t){ flash('That task cannot be started.','bad'); go('housekeeping',['view'=>$tid]); }
    q("UPDATE housekeeping_tasks SET assigned_to=COALESCE(assigned_to,?),status='in_progress' WHERE id=?",[$uid,$tid]);
    audit('housekeeping_start','housekeeping_task',$tid,['status'=>$t['status']],['status'=>'in_progress']);
    flash('Task marked as in progress.');
    go('housekeeping',['view'=>$tid]);
    break;

   case 'check':
    $cid=(int)($_POST['checklist_id']??0);
    $c=row('SELECT c.*,t.assigned_to FROM hp_cleaning_checklists c JOIN housekeeping_tasks t ON t.id=c.task_id WHERE c.id=? AND t.id=?',[$cid,$tid]);
    if(!$c){ flash('Checklist item not found.','bad'); go('housekeeping',['view'=>$tid]); }
    q('UPDATE hp_cleaning_checklists SET checked=?,checked_by=?,checked_at=NOW() WHERE id=?',[$c['checked']?0:1,$uid,$cid]);
    flash($c['checked']?'Checklist item reopened.':'Checklist item ticked.');
    go('housekeeping',['view'=>$tid]);
    break;

   case 'complete':
    $t=row('SELECT * FROM housekeeping_tasks WHERE id=? AND status=\'in_progress\'',[$tid]);
    if(!$t){ flash('Start the task before completing it.','bad'); go('housekeeping',['view'=>$tid]); }
    $open=(int)val('SELECT COUNT(*) FROM hp_cleaning_checklists WHERE task_id=? AND checked=0',[$tid]);
    if($open>0){ flash('Tick all '.$open.' remaining checklist item(s) first.','bad'); go('housekeeping',['view'=>$tid]); }
    q("UPDATE housekeeping_tasks SET status='completed',completed_at=NOW() WHERE id=?",[$tid]);
    if($t['room_id']) q("UPDATE rooms SET status='inspected' WHERE id=? AND status='cleaning'",[(int)$t['room_id']]);
    audit('housekeeping_complete','housekeeping_task',$tid);
    notify_console('hk-complete-'.$tid,'incident','Housekeeping task completed','Room '.(string)val('SELECT room_number FROM rooms WHERE id=?',[(int)$t['room_id']]).' is awaiting inspection.',['task_id'=>$tid],['housekeeping','director','general_manager','receptionist'],'housekeeping_task',$tid);
    flash('Task completed and room sent for inspection.');
    go('housekeeping',['view'=>$tid]);
    break;

   case 'verify':
    if(!has_role('director')&&!has_role('general_manager')&&!has_role('housekeeping')){ flash('Only a supervisor can verify cleaning.','bad'); go('housekeeping',['view'=>$tid]); }
    $t=row('SELECT * FROM housekeeping_tasks WHERE id=? AND status=\'completed\'',[$tid]);
    if(!$t){ flash('Only completed tasks can be verified.','bad'); go('housekeeping',['view'=>$tid]); }
    q("UPDATE housekeeping_tasks SET status='verified',verified_by=? WHERE id=?",[$uid,$tid]);
    audit('housekeeping_verify','housekeeping_task',$tid);
    flash('Cleaning verified.');
    go('housekeeping',['view'=>$tid]);
    break;

   case 'release':
    if(!has_role('director')&&!has_role('general_manager')&&!has_role('receptionist')){ flash('Only front office or management can release a room.','bad'); go('housekeeping',['view'=>$tid]); }
    $t=row('SELECT * FROM housekeeping_tasks WHERE id=? AND status IN(\'verified\',\'completed\')',[$tid]);
    if(!$t||!$t['room_id']){ flash('No verified room to release.','bad'); go('housekeeping',['view'=>$tid]); }
    q("UPDATE rooms SET status='available' WHERE id=? AND status IN('inspected','cleaning')",[(int)$t['room_id']]);
    q("UPDATE housekeeping_tasks SET status='verified',verified_by=COALESCE(verified_by,?) WHERE id=?",[$uid,$tid]);
    audit('room_release','room',(int)$t['room_id']);
    notify_console('hk-release-'.$tid,'booking','Room released to available','Room '.(string)val('SELECT room_number FROM rooms WHERE id=?',[(int)$t['room_id']]).' is ready for sale.',['task_id'=>$tid,'room_id'=>(int)$t['room_id']],['receptionist','director','general_manager'],'room',(int)$t['room_id']);
    flash('Room released to available.');
    go('housekeeping',['view'=>$tid]);
    break;

   case 'cancel_task':
    $t=row('SELECT * FROM housekeeping_tasks WHERE id=? AND status IN(\'pending\',\'assigned\',\'in_progress\')',[$tid]);
    if(!$t){ flash('That task is already closed.','bad'); go('housekeeping',['view'=>$tid]); }
    q("UPDATE housekeeping_tasks SET status='cancelled' WHERE id=?",[$tid]);
    if($t['room_id']) q("UPDATE rooms SET status='dirty' WHERE id=? AND status='cleaning'",[(int)$t['room_id']]);
    audit('housekeeping_cancel','housekeeping_task',$tid);
    flash('Task cancelled.');
    go('housekeeping',['view'=>$tid]);
    break;

   case 'stock':
    $item=trim((string)($_POST['item_name']??''));
    $location=trim((string)($_POST['location']??'Linen Store'));
    $qty=max(0,(int)($_POST['quantity']??0));
    $reorder=max(0,(int)($_POST['reorder_level']??0));
    if($item===''||$location===''){ flash('Enter the item name and location.','bad'); go('housekeeping',['act'=>'linen']); }
    q('INSERT INTO hp_linen_stock(hotel_id,item_name,location,quantity,reorder_level) VALUES(1,?,?,?,?) ON DUPLICATE KEY UPDATE reorder_level=VALUES(reorder_level),quantity=quantity+VALUES(quantity)',[$item,$location,$qty,$reorder]);
    if($qty>0) q('INSERT INTO hp_linen_movements(hotel_id,item_name,location,movement_type,quantity,user_id,notes,created_at) VALUES(1,?,?,\'returned\',?,?,?,NOW())',[$item,$location,$qty,$uid,'Opening stock']);
    audit('linen_stock','linen',$item,null,['quantity'=>$qty]);
    flash('Linen item saved.');
    go('housekeeping',['act'=>'linen']);
    break;

   case 'movement':
    $item=trim((string)($_POST['item_name']??''));
    $location=trim((string)($_POST['location']??'Linen Store'));
    $type=$_POST['movement_type']??'issued';
    $qty=(int)($_POST['quantity']??0);
    $roomId=(int)($_POST['room_id']??0);
    $note=trim((string)($_POST['notes']??''));
    $types=['issued'=>-1,'returned'=>1,'laundry_sent'=>-1,'laundry_received'=>1,'wasted'=>-1];
    if($item===''||!isset($types[$type])||$qty<1){ flash('Choose an item, movement type and quantity above zero.','bad'); go('housekeeping',['act'=>'linen']); }
    $stock=row('SELECT * FROM hp_linen_stock WHERE item_name=? AND location=?',[$item,$location]);
    if(!$stock){ flash('That linen item is not registered in this location.','bad'); go('housekeeping',['act'=>'linen']); }
    $delta=$types[$type]*$qty;
    if((int)$stock['quantity']+$delta<0){ flash('Not enough stock available for this movement.','bad'); go('housekeeping',['act'=>'linen']); }
    db()->beginTransaction();
    try{
      q('UPDATE hp_linen_stock SET quantity=quantity+? WHERE id=?',[$delta,(int)$stock['id']]);
      q('INSERT INTO hp_linen_movements(hotel_id,item_name,location,movement_type,quantity,room_id,user_id,notes,created_at) VALUES(1,?,?,?,?,?,?,?,NOW())',[$item,$location,$type,$qty,$roomId>0?$roomId:null,$uid,$note]);
      db()->commit();
    }catch(Throwable $e){ db()->rollBack(); flash('The linen movement could not be saved.','bad'); go('housekeeping',['act'=>'linen']); }
    audit('linen_movement','linen',$item,['quantity'=>(int)$stock['quantity']],['quantity'=>(int)$stock['quantity']+$delta,'movement'=>$type]);
    flash('Linen movement recorded.');
    go('housekeeping',['act'=>'linen']);
    break;
  }
}

$statuses=['pending','assigned','in_progress','completed','verified','cancelled'];
$filter=in_array($_GET['status']??'',$statuses,true)?$_GET['status']:'';
$where=$filter!==''?'WHERE t.status=?':'WHERE t.status<>\'cancelled\'';
$params=$filter!==''?[$filter]:[];
$tasks=rows("SELECT t.*,r.room_number,u.name assigned_name,rt.name rtype FROM housekeeping_tasks t LEFT JOIN rooms r ON r.id=t.room_id LEFT JOIN room_types rt ON rt.id=r.room_type_id LEFT JOIN users u ON u.id=t.assigned_to $where ORDER BY FIELD(t.priority,'urgent','high','normal','low'),t.id DESC LIMIT 100",$params);
$rooms=rows("SELECT r.id,r.room_number,r.status,rt.name rtype FROM rooms r JOIN room_types rt ON rt.id=r.room_type_id WHERE r.deleted_at IS NULL ORDER BY r.room_number");
$users=rows("SELECT DISTINCT u.id,u.name FROM users u LEFT JOIN user_roles ur ON ur.user_id=u.id LEFT JOIN roles ro ON ro.id=ur.role_id WHERE u.status='active' AND (ro.name='housekeeping' OR ro.name IS NULL) ORDER BY u.name");
$linen=rows('SELECT * FROM hp_linen_stock ORDER BY item_name,location');
$movements=rows('SELECT m.*,u.name actor,r.room_number FROM hp_linen_movements m LEFT JOIN users u ON u.id=m.user_id LEFT JOIN rooms r ON r.id=m.room_id ORDER BY m.id DESC LIMIT 60');
$counts=[];
foreach($statuses as $s) $counts[$s]=(int)val('SELECT COUNT(*) FROM housekeeping_tasks WHERE status=?',[$s]);
$roomStatus=[];
foreach(rows("SELECT status,COUNT(*) c FROM rooms WHERE deleted_at IS NULL GROUP BY status") as $x) $roomStatus[$x['status']]=(int)$x['c'];

page_head('Housekeeping','housekeeping','Room readiness, checklists and linen control');
echo '<div class="kpis">';
kpi_card('Dirty rooms',(string)($roomStatus['dirty']??0),'Awaiting cleaning','warn');
kpi_card('In progress',(string)$counts['in_progress'],'Rooms being cleaned');
kpi_card('Awaiting inspection',(string)$counts['completed'],'Ready for check','warn');
kpi_card('Verified today',(string)$counts['verified'],'Ready for front office','ok');
echo '</div>';
echo '<div class="toolbar"><a class="btn" href="'.BASE.'/index.php?page=housekeeping">Tasks</a><a class="btnGhost sm" href="'.BASE.'/index.php?page=housekeeping&act=linen">Linen store</a></div>';

if($act==='linen'){
  echo '<div class="twoCol"><div class="panel"><h2>Register or top up linen</h2>'; form_open('housekeeping','stock');
  echo '<div class="formGrid">'.field('Item','item_name','e.g. King sheet','text','',true).field('Location','location','Linen Store','text','',true).field('Quantity','quantity','0','number','',true).field('Reorder level','reorder_level','5','number').'</div><button class="btn">Save linen item</button>'; form_close();
  echo '<h2 style="margin-top:18px">Linen stock</h2><table class="tbl"><thead><tr><th>Item</th><th>Location</th><th class="num">On hand</th><th class="num">Reorder at</th></tr></thead><tbody>';
  foreach($linen as $l) echo '<tr><td>'.e($l['item_name']).'</td><td>'.e($l['location']).'</td><td class="num">'.((int)$l['quantity']<(int)$l['reorder_level']?badge((string)$l['quantity'],'bad'):e($l['quantity'])).'</td><td class="num">'.e($l['reorder_level']).'</td></tr>';
  if(!$linen) echo '<tr><td colspan="4" style="text-align:center;color:var(--muted)">No linen registered yet.</td></tr>';
  echo '</tbody></table></div>';
  echo '<div><div class="panel"><h2>Record a movement</h2>'; form_open('housekeeping','movement');
  echo '<div class="formGrid"><div class="field"><label>Item</label><select name="item_name" required><option value="">Choose item...</option>';
  foreach($linen as $l) echo '<option value="'.e($l['item_name']).'" data-loc="'.e($l['location']).'">'.e($l['item_name'].' · '.$l['location']).'</option>';
  echo '</select></div>'.field('Location','location','Linen Store','text','',true);
  echo '<div class="field"><label>Movement</label><select name="movement_type">'; foreach(['issued'=>'Issued to room','returned'=>'Returned','laundry_sent'=>'Sent to laundry','laundry_received'=>'Received from laundry','wasted'=>'Wasted'] as $k=>$v) echo '<option value="'.e($k).'">'.e($v).'</option>'; echo '</select></div>';
  echo field('Quantity','quantity','1','number','',true);
  echo '<div class="field"><label>Room (optional)</label><select name="room_id"><option value="">None</option>'; foreach($rooms as $r) echo '<option value="'.(int)$r['id'].'">'.e($r['room_number']).'</option>'; echo '</select></div></div>';
  area('Notes','notes','','Where did it go or come from?','',2).'<button class="btn">Record movement</button>'; form_close(); echo '</div>';
  echo '<div class="panel"><h2>Recent linen movements</h2><table class="tbl"><thead><tr><th>Item</th><th>Type</th><th class="num">Qty</th><th>By</th></tr></thead><tbody>';
  foreach($movements as $m) echo '<tr><td>'.e($m['item_name']).'</td><td>'.e(str_replace('_',' ',$m['movement_type'])).'</td><td class="num">'.e($m['quantity']).'</td><td>'.e($m['actor']??'').'</td></tr>';
  if(!$movements) echo '<tr><td colspan="4" style="text-align:center;color:var(--muted)">No movements recorded.</td></tr>';
  echo '</tbody></table></div></div></div>';
}else{
  echo '<div class="panel"><h2>Create a task</h2>'; form_open('housekeeping','create');
  echo '<div class="formGrid"><div class="field"><label>Room</label><select name="room_id" required><option value="">Choose room...</option>';
  foreach($rooms as $r) echo '<option value="'.(int)$r['id'].'">'.e($r['room_number'].' · '.$r['rtype'].' · '.$r['status']).'</option>';
  echo '</select></div><div class="field"><label>Assign to</label><select name="assigned_to"><option value="">Unassigned</option>';
  foreach($users as $u) echo '<option value="'.(int)$u['id'].'">'.e($u['name']).'</option>';
  echo '</select></div><div class="field"><label>Task</label><select name="task_type">'; foreach(['cleaning'=>'Cleaning','inspection'=>'Inspection','turn_down'=>'Turn down','deep_clean'=>'Deep clean','other'=>'Other'] as $k=>$v) echo '<option value="'.e($k).'">'.e($v).'</option>'; echo '</select></div>';
  echo '<div class="field"><label>Priority</label><select name="priority">'; foreach(['low'=>'Low','normal'=>'Normal','high'=>'High','urgent'=>'Urgent'] as $k=>$v) echo '<option value="'.e($k).'"'.($k==='normal'?' selected':'').'>'.e($v).'</option>'; echo '</select></div></div>';
  area('Notes','notes','','Anything the room attendant must know','',2).'<button class="btn">Create task</button>'; form_close(); echo '</div>';

  echo '<div class="toolbar">';
  foreach($statuses as $s) echo '<a class="btnGhost sm'.($filter===$s?' active':'').'" href="'.BASE.'/index.php?page=housekeeping'.($s!==''?'&status='.$s:'').'">'.e(ucfirst(str_replace('_',' ',$s))).' ('.$counts[$s].')</a>';
  echo '</div>';

  echo '<div class="panel"><h2>Task register</h2><table class="tbl"><thead><tr><th>Room</th><th>Task</th><th>Assigned</th><th>Priority</th><th>Status</th><th></th></tr></thead><tbody>';
  foreach($tasks as $t) echo '<tr><td><b>'.e($t['room_number']??'Room removed').'</b></td><td>'.e(str_replace('_',' ',ucfirst($t['task_type']))).'</td><td>'.e($t['assigned_name']??'Unassigned').'</td><td>'.status_badge($t['priority']).'</td><td>'.status_badge($t['status']).'</td><td><a class="btn sm" href="'.BASE.'/index.php?page=housekeeping&view='.(int)$t['id'].'">Open</a></td></tr>';
  if(!$tasks) echo '<tr><td colspan="6" style="text-align:center;color:var(--muted)">No tasks in this view.</td></tr>';
  echo '</tbody></table></div>';

  if($tid){
    $t=row('SELECT t.*,r.room_number,rt.name rtype,u.name assigned_name FROM housekeeping_tasks t LEFT JOIN rooms r ON r.id=t.room_id LEFT JOIN room_types rt ON rt.id=r.room_type_id LEFT JOIN users u ON u.id=t.assigned_to WHERE t.id=?',[$tid]);
    if($t){
      $checks=rows('SELECT * FROM hp_cleaning_checklists WHERE task_id=? ORDER BY id',[$tid]);
      $done=(int)val('SELECT COUNT(*) FROM hp_cleaning_checklists WHERE task_id=? AND checked=1',[$tid]);
      echo '<div class="panel"><h2>Task #'.(int)$tid.' · '.e($t['room_number']??'Room').'</h2><p class="hint">'.status_badge($t['status']).' · '.e($t['rtype']??'').' · Assigned to '.e($t['assigned_name']??'nobody').'</p>';
      if($t['notes']) echo '<p>'.nl2br(e($t['notes'])).'</p>';
      echo '<p><b>Checklist:</b> '.$done.' of '.count($checks).' complete</p>';
      echo '<table class="tbl"><thead><tr><th>Item</th><th>Checked</th><th></th></tr></thead><tbody>';
      foreach($checks as $c) echo '<tr><td>'.e($c['item_name']).'</td><td>'.($c['checked']?badge('Done','ok'):badge('Open','warn')).'</td><td>';
      if($t['status']==='in_progress'){ form_open('housekeeping','check',['view'=>$tid]); echo '<input type="hidden" name="checklist_id" value="'.(int)$c['id'].'"><button class="btnGhost sm">'.($c['checked']?'Reopen':'Tick').'</button>'; form_close(); }
      echo '</td></tr>';
      if(!$checks) echo '<tr><td colspan="3" style="text-align:center;color:var(--muted)">No checklist rows.</td></tr>';
      echo '</tbody></table>';
      echo '<div class="toolbar" style="margin-top:14px">';
      if(in_array($t['status'],['pending','assigned','in_progress'],true)){
        form_open('housekeeping','assign',['view'=>$tid]); echo '<div class="field"><label>Reassign</label><select name="assigned_to">'; foreach($users as $u) echo '<option value="'.(int)$u['id'].'"'.((int)$t['assigned_to']===(int)$u['id']?' selected':'').'>'.e($u['name']).'</option>'; echo '</select></div><button class="btnGhost sm">Assign</button>'; form_close();
        if($t['status']!=='in_progress'){ form_open('housekeeping','start',['view'=>$tid]); echo '<button class="btn sm">Start task</button>'; form_close(); }
        form_open('housekeeping','cancel_task',['view'=>$tid]); echo '<button class="btnGhost sm">Cancel task</button>'; form_close();
      }
      if($t['status']==='in_progress'){ form_open('housekeeping','complete',['view'=>$tid]); echo '<button class="btn sm">Complete task</button>'; form_close(); }
      if($t['status']==='completed'){ form_open('housekeeping','verify',['view'=>$tid]); echo '<button class="btn sm">Verify cleaning</button>'; form_close(); }
      if(in_array($t['status'],['completed','verified'],true)){ form_open('housekeeping','release',['view'=>$tid]); echo '<button class="btnGhost sm">Release room</button>'; form_close(); }
      echo '</div></div>';
    }
  }
}
receipt_print('housekeeping');
page_foot();
