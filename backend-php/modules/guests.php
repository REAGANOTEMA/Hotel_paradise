<?php
declare(strict_types=1);

$act=$_GET['act']??'';

if($_SERVER['REQUEST_METHOD']==='POST'){
 if($act==='save'){
  $id=(int)($_POST['id']??0);
  $name=trim($_POST['full_name']); if(!$name){ flash('Guest name is required.','bad'); go('guests'); }
  $data=[trim($_POST['phone']),trim($_POST['email']),trim($_POST['nationality']),trim($_POST['id_type']),trim($_POST['id_number'])];
  if($id){
   q('UPDATE guests SET phone=?,email=?,nationality=?,id_type=?,id_number=?,updated_at=NOW() WHERE id=?',array_merge($data,[$id]));
   audit('update','guest',$id);
   flash('Guest updated.');
  }else{
   q('INSERT INTO guests(hotel_id,full_name,phone,email,nationality,id_type,id_number,created_at) VALUES(1,?,?,?,?,?,?,NOW())',array_merge([$name],$data));
   audit('create','guest',(int)db()->lastInsertId());
   flash('Guest added.');
  }
  go('guests');
 }
 if($act==='delete'){ flash('Guests are kept on record for audit purposes.','warn'); go('guests'); }
}

$qtext=trim($_GET['q']??'');
$list=rows("SELECT g.*, (SELECT COUNT(*) FROM reservations r WHERE r.guest_id=g.id) stays FROM guests g WHERE ?='' OR g.full_name LIKE ? OR g.phone LIKE ? OR g.email LIKE ? ORDER BY g.full_name",[$qtext,$qtext===''?'%x%':'%'.$qtext.'%',$qtext===''?'%x%':'%'.$qtext.'%',$qtext===''?'%x%':'%'.$qtext.'%']);

$edit=$_GET['edit']??0; $eg=null;
if($edit) $eg=row('SELECT * FROM guests WHERE id=?',[$edit]);

page_head('Guests','guests','Guest registry and stay history');
echo '<div class="toolbar"><a class="btn" href="'.BASE.'/index.php?page=guests&act=save">+ Add guest</a>';
echo '<form method="get" style="display:flex;gap:6px;margin-left:auto"><input type="hidden" name="page" value="guests"><input name="q" value="'.e($qtext).'" placeholder="Search name, phone or email..." style="padding:9px 12px;border:1px solid var(--line);border-radius:9px"><button class="btn sm">Search</button></form></div>';

echo '<div class="twoCol"><div>';
echo '<div class="panel"><h2>Guest registry</h2><p class="hint">Every guest who has stayed or booked.</p>';
echo '<table class="tbl"><thead><tr><th>Name</th><th>Phone</th><th>Nationality</th><th class="num">Stays</th><th></th></tr></thead><tbody>';
foreach($list as $g){
 echo '<tr><td><b>'.e($g['full_name']).'</b><br><small style="color:var(--muted)">'.e($g['email']??'').'</small></td><td>'.e($g['phone']??'-').'</td><td>'.e($g['nationality']??'-').'</td><td class="num">'.(int)$g['stays'].'</td><td><a class="btn sm" href="'.BASE.'/index.php?page=guests&edit='.(int)$g['id'].'">Edit</a></td></tr>';
}
if(!count($list)) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No guests found.</td></tr>';
echo '</tbody></table></div></div>';

echo '<div>';
$id=$edit?(int)$eg['id']:0; $name=$edit?$eg['full_name']:'';
echo '<div class="panel"><h2>'.($edit?'Edit guest':'Add guest').'</h2><p class="hint">'.($edit?'Update contact and identification details below.':'Register a new guest on the guest registry.').'</p>';
form_open('guests','save',[]);
echo '<input type="hidden" name="id" value="'.$id.'">';
echo '<div class="field"><label>Full name</label><input name="full_name" value="'.e($name).'" required></div>';
echo '<div class="field"><label>Phone</label><input name="phone" value="'.e($eg['phone']??'').'"></div>';
echo '<div class="field"><label>Email</label><input name="email" value="'.e($eg['email']??'').'"></div>';
echo '<div class="field"><label>Nationality</label><input name="nationality" value="'.e($eg['nationality']??'').'"></div>';
echo '<div class="field"><label>ID type</label><input name="id_type" value="'.e($eg['id_type']??'').'" placeholder="National ID or Passport"></div>';
echo '<div class="field"><label>ID number</label><input name="id_number" value="'.e($eg['id_number']??'').'"></div>';
echo '<button class="btn">Save guest</button>';
form_close();
echo '</div></div></div>';
page_foot();