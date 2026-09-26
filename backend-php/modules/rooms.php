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
   flash('Room status updated to '.str_replace('_',' ',$st).'.');
  }
  go('rooms');
 }
 if($act==='rate'){
  $t=(int)($_POST['type_id']??0); $rate=(float)($_POST['rate']??0); $active=isset($_POST['active'])?1:0;
  if($t&&$rate>0){
   $old=row('SELECT base_rate,active FROM room_types WHERE id=?',[$t]);
   q('UPDATE room_types SET base_rate=?,active=? WHERE id=?',[$rate,$active,$t]);
   audit('room_rate','room_type',$t,$old,['base_rate'=>$rate,'active'=>$active]);
   flash('Room type rate updated.');
  }
  go('rooms');
 }
}

$flt=$_GET['st']??'';
$types_all=rows('SELECT * FROM room_types ORDER BY base_rate DESC');
$whereAll=$flt?'AND status=?':'';
$all=rows("SELECT * FROM rooms $whereAll".($whereAll?' ORDER BY status,room_number':''),$flt?[$flt]:[]);
$floors=rows('SELECT DISTINCT floor FROM rooms ORDER BY floor');

page_head('Rooms','rooms','Room status board and tariffs');

echo '<div class="panel"><h2>Room types and tariffs</h2><p class="hint">Nightly rates in Uganda Shillings, matching the published tariff.</p>';
echo '<table class="tbl"><thead><tr><th>Room type</th><th class="num">Rate per night</th><th class="num">Rooms</th><th>Active</th><th>Update rate</th></tr></thead><tbody>';
foreach($types_all as $t){
 $cnt=val('SELECT COUNT(*) FROM rooms WHERE room_type_id=?',[$t['id']]);
 echo '<tr><td><b>'.e($t['name']).'</b></td><td class="num">'.money($t['base_rate']).'</td><td class="num">'.(int)$cnt.'</td><td>'.($t['active']?badge('Active','ok'):badge('Hidden','grey')).'</td>';
 echo '<td>'; form_open('rooms','rate',['type_id'=>$t['id']]);
 echo '<div style="display:flex;gap:6px"><input name="rate" type="number" value="'.(int)$t['base_rate'].'" style="width:130px;padding:7px 10px;border:1px solid var(--line);border-radius:8px">';
 echo '<label style="display:flex;align-items:center;gap:4px;font-size:12px"><input type="checkbox" name="active"'.($t['active']?' checked':'').'> Active</label>';
 echo '<button class="btn sm">Save</button></div>'; form_close(); echo '</td></tr>';
}
echo '</tbody></table></div>';

echo '<div class="panel"><h2>Room status board</h2><p class="hint">69 rooms across 3 floors. Click a room to change its status.</p>';
echo '<div class="rfilter">';
foreach([''=>'All','available'=>'Available','reserved'=>'Reserved','occupied'=>'Occupied','dirty'=>'Dirty','cleaning'=>'Cleaning','inspected'=>'Inspected','maintenance'=>'Maintenance'] as $k=>$v){
 echo '<a href="'.BASE.'/index.php?page=rooms'.($k?'&st='.$k:'').'"><button class="'.($flt===$k?'on':'').'">'.$v.'</button></a>';
}
echo '</div>';
foreach($floors as $f){
 echo '<h3 style="margin:22px 0 12px">'.e($f['floor']).'</h3><div class="roomGrid">';
 foreach($all as $r) if($r['floor']===$f['floor']){
  $tname=val('SELECT name FROM room_types WHERE id=?',[$r['room_type_id']]);
  echo '<div class="room '.e($r['status']).'"><div class="rno">'.e($r['room_number']).'</div><div class="rtype">'.e($tname).'</div>';
  echo '<form method="post" action="'.BASE.'/index.php?page=rooms&amp;act=status" style="margin-top:10px">';
  echo '<input type="hidden" name="room_id" value="'.(int)$r['id'].'">';
  echo '<select name="status" onchange="this.form.submit()" style="width:100%;padding:6px 8px;border:1px solid var(--line);border-radius:8px;font-size:11.5px">';
  foreach(['available'=>'Available','dirty'=>'Dirty','cleaning'=>'Cleaning','inspected'=>'Inspected','maintenance'=>'Maintenance','out_of_service'=>'Out of service'] as $k2=>$v2)
   echo '<option value="'.$k2.'"'.checked($r['status'],$k2).'>'.$v2.'</option>';
  echo '</select></form></div>';
 }
 echo '</div>';
}
echo '</div>';
page_foot();