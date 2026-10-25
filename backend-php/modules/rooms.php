<?php
declare(strict_types=1);

if($_SERVER['REQUEST_METHOD']==='POST'){
 $act=$_GET['act']??'';
 if($act==='status'){
  $room=(int)($_POST['room_id']??0); $st=$_POST['status']??'';
  $allowed=['available','dirty','cleaning','inspected','maintenance','out_of_service'];
  if($room&&in_array($st,$allowed)){
   $old=row('SELECT status FROM rooms WHERE id=?',[$room]);
   q('UPDATE rooms SET status=? WHERE id=?',[$st,$room]);
   audit('room_status','room',$room,$old,['status'=>$st]);
   if($st==='maintenance'||$st==='out_of_service'){
    $rn=(string)val('SELECT room_number FROM rooms WHERE id=?',[$room]);
    notify_console('room-'.$st.':'.$room,'incident','Room '.$rn.' '.str_replace('_',' ',$st),
     'The room has been taken out of the sellable count (was '.str_replace('_',' ',(string)($old['status']??'')).').',
     ['room_id'=>$room],['director','general_manager','receptionist'],'room',$room);
   }
   flash('Room status updated to '.str_replace('_',' ',$st).'.');
  }
  go('rooms');
 }
if($act==='rate'){
   $t=(int)($_POST['type_id']??0); $rate=(float)($_POST['rate']??0); $active=isset($_POST['active'])?1:0;
   if($t&&$rate>0){
    $old=row('SELECT base_rate,active FROM room_types WHERE id=?',[$t]);
    q('UPDATE room_types SET base_rate=?,active=?,name=?,description=? WHERE id=?',[$rate,$active,trim($_POST['name']??''),trim($_POST['description']??''),$t]);
    audit('room_rate','room_type',$t,$old,['base_rate'=>$rate,'active'=>$active]);
    flash('Room type updated.');
   }
   go('rooms');
  }
}

$flt=$_GET['st']??'';
$types_all=rows('SELECT * FROM room_types WHERE deleted_at IS NULL ORDER BY base_rate DESC');
$whereAll=$flt?'WHERE status=? AND deleted_at IS NULL':'WHERE deleted_at IS NULL';
  $all=rows("SELECT * FROM rooms $whereAll".($flt?' ORDER BY status,room_number':' ORDER BY room_number'),$flt?[$flt]:[]);
$editRt=(int)($_GET['editrt']??0); $ert=$editRt?row('SELECT * FROM room_types WHERE id=?',[$editRt]):null;
$floors=rows('SELECT DISTINCT floor FROM rooms WHERE deleted_at IS NULL ORDER BY floor');
// One grouped count and one name lookup, instead of one query per room type
// and one per room rendered.
$typeCounts=[];
foreach(rows('SELECT room_type_id,COUNT(*) c FROM rooms GROUP BY room_type_id') as $tc) $typeCounts[(int)$tc['room_type_id']]=(int)$tc['c'];
$typeNames=[];
foreach($types_all as $rt) $typeNames[(int)$rt['id']]=$rt['name'];

page_head('Rooms','rooms','Room status board and tariffs');

echo '<div class="panel"><h2>Room types and tariffs</h2><p class="hint">Nightly rates in Uganda Shillings, matching the published tariff.</p>';
echo '<table class="tbl"><thead><tr><th>Room type</th><th class="num">Rate per night</th><th class="num">Rooms</th><th>Active</th><th>Update rate</th></tr></thead><tbody>';
foreach($types_all as $t){
 $cnt=$typeCounts[(int)$t['id']]??0;
 echo '<tr><td><b>'.e($t['name']).'</b></td><td class="num">'.money($t['base_rate']).'</td><td class="num">'.(int)$cnt.'</td><td>'.($t['active']?badge('Active','ok'):badge('Hidden','grey')).'</td>';
  echo '<td>'; form_open('rooms','rate',['type_id'=>$t['id']]);
  echo '<div style="display:flex;gap:6px;align-items:center;flex-wrap:wrap"><input name="rate" type="number" value="'.(int)$t['base_rate'].'" style="width:110px;padding:7px 8px;border:1px solid var(--line);border-radius:8px">';
  echo '<label style="display:flex;align-items:center;gap:4px;font-size:11.5px"><input type="checkbox" name="active"'.($t['active']?' checked':'').'> Active</label>';
  echo '<button class="btn sm">Save</button></div>'; form_close(); echo ' '.trash_button('room_types',(int)$t['id'],'rooms').'</td></tr>';
}
  echo '</tbody></table></div>';

if($ert){
 echo '<div class="panel" id="edrt"><h2>Edit room type</h2><p class="hint">Update the room type name, description, rate and visibility.</p>';
 form_open('rooms','rate',['type_id'=>$ert['id']]);
 echo '<div class="field"><label>Name</label><input name="name" value="'.e($ert['name']).'" required></div>';
 echo '<div class="field"><label>Description</label><textarea name="description" rows="2">'.e($ert['description']??'').'</textarea></div>';
 echo '<div class="field"><label>Rate per night</label><input type="number" name="rate" step="1000" min="1000" value="'.(int)$ert['base_rate'].'" required></div>';
 echo '<label style="font-size:13px"><input type="checkbox" name="active"'.($ert['active']?' checked':'').'> Active</label>';
 echo '<div style="margin-top:14px"><button class="btn">Save changes</button> <a class="btnGhost sm" href="'.BASE.'/index.php?page=rooms">Cancel</a></div>';
 form_close(); echo '</div>';
}

echo '<div class="panel"><h2>Room status board</h2><p class="hint">'.(int)val('SELECT COUNT(*) FROM rooms WHERE deleted_at IS NULL').' rooms across '.count($floors).' floors. Click a room to change its status.</p>';
echo '<div class="rfilter">';
foreach([''=>'All','available'=>'Available','reserved'=>'Reserved','occupied'=>'Occupied','dirty'=>'Dirty','cleaning'=>'Cleaning','inspected'=>'Inspected','maintenance'=>'Maintenance'] as $k=>$v){
 echo '<a href="'.BASE.'/index.php?page=rooms'.($k?'&st='.$k:'').'"><button class="'.($flt===$k?'on':'').'">'.$v.'</button></a>';
}
echo '</div>';
foreach($floors as $f){
 echo '<h3 style="margin:22px 0 12px">'.e($f['floor']).'</h3><div class="roomGrid">';
  foreach($all as $r) if($r['floor']===$f['floor']){
   $tname=$typeNames[(int)$r['room_type_id']]??'';
   echo '<div class="room '.e($r['status']).'"><div class="rno">'.e($r['room_number']).'</div><div class="rtype">'.e($tname).'</div>';
   echo '<form method="post" action="'.BASE.'/index.php?page=rooms&amp;act=status" style="margin-top:10px">';
   echo '<input type="hidden" name="room_id" value="'.(int)$r['id'].'">';
   echo '<select name="status" onchange="this.form.submit()" style="width:100%;padding:6px 8px;border:1px solid var(--line);border-radius:8px;font-size:11.5px">';
   foreach(['available'=>'Available','dirty'=>'Dirty','cleaning'=>'Cleaning','inspected'=>'Inspected','maintenance'=>'Maintenance','out_of_service'=>'Out of service'] as $k2=>$v2)
    echo '<option value="'.$k2.'"'.checked($r['status'],$k2).'>'.$v2.'</option>';
   echo '</select></form>';
   echo '<div style="margin-top:8px;text-align:right">'; echo trash_button('rooms',(int)$r['id'],'rooms'); echo '</div>';
   echo '</div>';
  }
 echo '</div>';
}
echo '</div>';
page_foot();