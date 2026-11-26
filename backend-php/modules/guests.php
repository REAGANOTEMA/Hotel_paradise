<?php
declare(strict_types=1);

$act=$_GET['act']??'';

if($_SERVER['REQUEST_METHOD']==='POST'){
  if($act==='save'){
   $id=(int)($_POST['id']??0);
   $name=mb_substr(trim((string)($_POST['full_name']??'')),0,190);
   $data=[
    mb_substr(trim((string)($_POST['phone']??'')),0,50),
    mb_substr(trim((string)($_POST['email']??'')),0,190),
    mb_substr(trim((string)($_POST['nationality']??'')),0,100),
    mb_substr(trim((string)($_POST['id_type']??'')),0,50),
    mb_substr(trim((string)($_POST['id_number']??'')),0,100)
   ];
   if($id){
    if($name==='') $name=guest_name('',$id);
    q('UPDATE guests SET full_name=?,phone=?,email=?,nationality=?,id_type=?,id_number=?,updated_at=NOW() WHERE id=?',array_merge([$name],$data,[$id]));
    audit('update','guest',$id);
    flash('Guest updated.');
   }else{
    q('INSERT INTO guests(hotel_id,full_name,phone,email,nationality,id_type,id_number,created_at) VALUES(1,?,?,?,?,?,?,NOW())',array_merge([$name],$data));
    $newId=(int)db()->lastInsertId();
    if($name===''){
     q('UPDATE guests SET full_name=? WHERE id=?',['Guest #'.$newId,$newId]);
    }
    audit('create','guest',$newId);
    flash('Guest added.');
   }
   go('guests');
  }
}

$qtext=trim($_GET['q']??'');
$list=rows("SELECT g.*, COALESCE(s.stays,0) stays FROM guests g LEFT JOIN (SELECT guest_id, COUNT(*) stays FROM reservations GROUP BY guest_id) s ON s.guest_id=g.id WHERE g.deleted_at IS NULL AND (?='' OR g.full_name LIKE ? OR g.phone LIKE ? OR g.email LIKE ? OR g.id_number LIKE ? OR CAST(g.id AS CHAR) LIKE ?) ORDER BY CASE WHEN g.full_name='' THEN 1 ELSE 0 END,g.full_name,g.id",[$qtext,$qtext===''?'%x%':'%'.$qtext.'%',$qtext===''?'%x%':'%'.$qtext.'%',$qtext===''?'%x%':'%'.$qtext.'%',$qtext===''?'%x%':'%'.$qtext.'%',$qtext===''?'%x%':'%'.$qtext.'%']);

$edit=$_GET['edit']??0; $eg=null;
if($edit) $eg=row('SELECT * FROM guests WHERE id=?',[$edit]);

page_head('Guests','guests','Guest registry and stay history');
echo '<div class="toolbar"><a class="btn" href="'.BASE.'/index.php?page=guests&act=save">+ Add guest</a>';
echo '<form method="get" style="display:flex;gap:6px;margin-left:auto"><input type="hidden" name="page" value="guests"><input name="q" value="'.e($qtext).'" placeholder="Search name, phone or email..." style="padding:9px 12px;border:1px solid var(--line);border-radius:9px"><button class="btn sm">Search</button></form></div>';

echo '<div class="twoCol"><div>';
echo '<div class="panel"><h2>Guest registry</h2><p class="hint">Every guest who has stayed or booked.</p>';
echo '<table class="tbl"><thead><tr><th>Name</th><th>Phone</th><th>Nationality</th><th class="num">Stays</th><th></th></tr></thead><tbody>';
 foreach($list as $g){
     echo '<tr><td><b>'.e(guest_name($g['full_name'],$g['id'])).'</b><br><small>'.e($g['email']??'').'</small></td><td>'.e($g['phone']??'-').'</td><td>'.e($g['nationality']??'-').'</td><td class="num">'.(int)$g['stays'].'</td><td><a class="btn sm" href="'.BASE.'/index.php?page=guests&edit='.(int)$g['id'].'">Edit</a> '.trash_button('guests',(int)$g['id'],'guests').'</td></tr>';
 }
if(!count($list)) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No guests found.</td></tr>';
echo '</tbody></table></div></div>';

echo '<div>';
$id=$edit?(int)$eg['id']:0; $name=$edit?$eg['full_name']:'';
echo '<div class="panel"><h2>'.($edit?'Edit guest':'Add guest').'</h2><p class="hint">'.($edit?'Update contact and identification details below.':'Register a new guest on the guest registry.').'</p>';
form_open('guests','save',[]);
echo '<input type="hidden" name="id" value="'.$id.'">';
echo '<div class="field"><label>Full name (optional)</label><input name="full_name" value="'.e($name).'" placeholder="Leave blank for an unnamed walk-in"></div>';
echo '<div class="field"><label>Phone</label><input name="phone" value="'.e($eg['phone']??'').'"></div>';
echo '<div class="field"><label>Email</label><input name="email" value="'.e($eg['email']??'').'"></div>';
echo '<div class="field"><label>Nationality</label><input name="nationality" value="'.e($eg['nationality']??'').'"></div>';
echo '<div class="field"><label>ID type</label><input name="id_type" value="'.e($eg['id_type']??'').'" placeholder="National ID or Passport"></div>';
echo '<div class="field"><label>ID number</label><input name="id_number" value="'.e($eg['id_number']??'').'"></div>';
echo '<button class="btn">Save guest</button>';
form_close();
echo '</div></div></div>';
page_foot();