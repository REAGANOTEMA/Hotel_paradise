<?php
declare(strict_types=1);

if($_SERVER['REQUEST_METHOD']==='POST'){
 $act=$_GET['act']??'';
 switch($act){
  case 'save':
   $id=(int)($_POST['id']??0);
   $name=trim($_POST['name']??''); $email=trim($_POST['email']??''); $phone=trim($_POST['phone']??''); $role=$_POST['role']??'receptionist';
   if(!$name||!$email){ flash('Name and email are required.','bad'); go('users'); }
   if($id){ q('UPDATE users SET name=?,email=?,phone=?,updated_at=NOW() WHERE id=?',[$name,$email,$phone,$id]); $uid=$id; }
   else{
    $pass=$_POST['password']??'Paradise2026';
    q('INSERT INTO users(hotel_id,name,email,phone,password_hash,status,created_at) VALUES(1,?,?,?,?,\'active\',NOW())',[$name,$email,$phone,password_hash($pass,PASSWORD_DEFAULT)]);
    $uid=(int)db()->lastInsertId();
   }
   q('DELETE FROM user_roles WHERE user_id=?',[$uid]);
   $rid=val('SELECT id FROM roles WHERE name=?',[$role]);
   if($rid) q('INSERT INTO user_roles(user_id,role_id) VALUES(?,?)',[$uid,$rid]);
   audit('save_user','user',$uid,['role'=>$role]);
   flash(($id?'Updated':'Added').' user account with the '.$role.' role.');
   go('users');
   break;
  case 'status':
   $id=(int)($_POST['id']??0); $nst=$_POST['nst']??'';
   if($id===(int)(current_user()['id']??0)){ flash('You cannot change your own account status.','bad'); go('users'); }
   q('UPDATE users SET status=? WHERE id=?',[$nst,$id]);
   audit(($nst==='suspended'?'suspend':'activate'),'user',$id);
   flash('User '.$nst.'.');
   go('users');
   break;
  case 'pass':
   $id=(int)($_POST['id']??0); $np=trim($_POST['password']??'');
   if(strlen($np)<8){ flash('Password must be at least 8 characters.','bad'); go('users'); }
   q('UPDATE users SET password_hash=? WHERE id=?',[password_hash($np,PASSWORD_DEFAULT),$id]);
   audit('reset_password','user',$id);
   flash('Password reset.');
   go('users');
   break;
 }
}

$list=rows('SELECT u.*,GROUP_CONCAT(r.name) roles FROM users u LEFT JOIN user_roles ur ON ur.user_id=u.id LEFT JOIN roles r ON r.id=ur.role_id GROUP BY u.id ORDER BY u.name');
$roles=rows('SELECT * FROM roles ORDER BY id');
$edit=(int)($_GET['edit']??0); $eu=null; if($edit) $eu=row('SELECT u.*,GROUP_CONCAT(r.name) roles FROM users u LEFT JOIN user_roles ur ON ur.user_id=u.id LEFT JOIN roles r ON r.id=ur.role_id WHERE u.id=? GROUP BY u.id',[$edit]);

page_head('Team and users','users','Staff accounts, roles and access');
echo '<div class="twoCol"><div>';
echo '<div class="panel"><h2>Staff accounts</h2><p class="hint">Role based access keeps financial and operational duties separated.</p>';
echo '<table class="tbl"><thead><tr><th>Name</th><th>Email</th><th>Role</th><th>Status</th><th></th></tr></thead><tbody>';
foreach($list as $u){
 echo '<tr><td><b>'.e($u['name']).'</b></td><td>'.e($u['email']).'</td><td>'.e(implode(', ',array_map('role_label',explode(',',(string)$u['roles'])))).'</td><td>'.($u['status']==='active'?badge('Active','ok'):badge('Suspended','bad')).'</td><td style="white-space:nowrap">';
 echo '<a class="btn sm" href="'.BASE.'/index.php?page=users&edit='.(int)$u['id'].'">Edit</a> ';
 if($u['status']==='active'){ form_open('users','status',['id'=>$u['id']]); echo '<input type="hidden" name="nst" value="suspended"><button class="btn sm danger" onclick="return confirm(\'Suspend this account?\')">Suspend</button>'; form_close(); }
 else { form_open('users','status',['id'=>$u['id']]); echo '<input type="hidden" name="nst" value="active"><button class="btn sm tick">Activate</button>'; form_close(); }
 echo '</td></tr>';
}
echo '</tbody></table></div></div>';

echo '<div>';
$id=$edit?(int)$eu['id']:0; $curRole=$edit?(explode(',',(string)$eu['roles'])[0]):'receptionist';
echo '<div class="panel"><h2>'.($edit?'Edit staff account':'Add staff account').'</h2><p class="hint">New accounts start with the active status and the password you set.</p>';
form_open('users','save');
echo '<input type="hidden" name="id" value="'.$id.'">';
echo '<div class="field"><label>Full name</label><input name="name" value="'.e($eu['name']??'').'" required></div>';
echo '<div class="field"><label>Email</label><input name="email" type="email" value="'.e($eu['email']??'').'" required></div>';
echo '<div class="field"><label>Phone</label><input name="phone" value="'.e($eu['phone']??'').'"></div>';
echo '<div class="field"><label>Role</label><select name="role">'; foreach($roles as $r){ if($r['name']==='super_admin') continue; echo '<option value="'.e($r['name']).'"'.checked($curRole,$r['name']).'>'.e(role_label($r['name'])).'</option>'; } echo '</select></div>';
if(!$edit){ echo '<div class="field"><label>Initial password</label><input name="password" value="Paradise2026"></div>'; }
echo '<button class="btn">Save user</button>'; form_close();
if($edit){
 echo '<div style="margin-top:18px;border-top:1px solid var(--line);padding-top:16px"><h3 style="font-size:14px;margin-bottom:10px">Reset password</h3>';
 form_open('users','pass'); echo '<input type="hidden" name="id" value="'.(int)$id.'">';
 echo '<div class="field"><label>New password</label><input type="text" name="password" placeholder="At least 8 characters"></div><button class="btnGhost sm">Reset password</button>'; form_close(); echo '</div>'; }
echo '</div></div></div>';
page_foot();
