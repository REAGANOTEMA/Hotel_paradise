<?php
declare(strict_types=1);

if($_SERVER['REQUEST_METHOD']==='POST'){
 $act=$_GET['act']??'';
 if($act==='save'){
  $id=(int)($_POST['id']??0); $name=trim($_POST['name']??''); if(!$name){ flash('Supplier name required.','bad'); go('suppliers'); }
  $d=[trim($_POST['contact_person']??''),trim($_POST['phone']??''),trim($_POST['email']??''),trim($_POST['address']??''),trim($_POST['tax_id']??''),isset($_POST['active'])?1:0];
  if($id){ q('UPDATE suppliers SET contact_person=?,phone=?,email=?,address=?,tax_id=?,active=? WHERE id=?',array_merge($d,[$id])); audit('update','supplier',$id); flash('Supplier updated.'); }
  else{ q('INSERT INTO suppliers(hotel_id,name,contact_person,phone,email,address,tax_id,active,created_at) VALUES(1,?,?,?,?,?,?,?,NOW())',array_merge([$name],$d)); audit('create','supplier',(int)db()->lastInsertId()); flash('Supplier added.'); }
  go('suppliers');
 }
}

$list=rows('SELECT s.*,(SELECT COUNT(*) FROM purchase_orders po WHERE po.supplier_id=s.id) orders FROM suppliers s ORDER BY s.name');
$edit=(int)($_GET['edit']??0); $es=null; if($edit) $es=row('SELECT * FROM suppliers WHERE id=?',[$edit]);

page_head('Suppliers','suppliers','Approved vendors and purchasing partners');
echo '<div class="toolbar"><a class="btn" href="'.BASE.'/index.php?page=suppliers&act=save">+ Add supplier</a></div>';
echo '<div class="twoCol"><div>';
echo '<div class="panel"><h2>Supplier registry</h2><p class="hint">Vendors the hotel procures from.</p>';
echo '<table class="tbl"><thead><tr><th>Supplier</th><th>Contact</th><th>Phone</th><th class="num">Orders</th><th></th></tr></thead><tbody>';
foreach($list as $s){ echo '<tr><td><b>'.e($s['name']).'</b><br><small style="color:var(--muted)">'.e($s['tax_id']??'').'</small></td><td>'.e($s['contact_person']??'-').'</td><td>'.e($s['phone']??'-').'</td><td class="num">'.(int)$s['orders'].'</td><td>'.($s['active']?badge('Active','ok'):badge('Inactive','grey')).' <a class="btn sm" href="'.BASE.'/index.php?page=suppliers&edit='.(int)$s['id'].'">Edit</a></td></tr>'; }
if(!count($list)) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No suppliers yet.</td></tr>';
echo '</tbody></table></div></div>';

echo '<div>';
$id=$edit?(int)$es['id']:0;
echo '<div class="panel"><h2>'.($edit?'Edit supplier':'Add supplier').'</h2><p class="hint">'.($edit?'Update this vendor record.':'Register a new vendor.').'</p>';
form_open('suppliers','save');
echo '<input type="hidden" name="id" value="'.$id.'">';
echo '<div class="field"><label>Supplier name</label><input name="name" value="'.e($es['name']??'').'" required></div>';
echo '<div class="field"><label>Contact person</label><input name="contact_person" value="'.e($es['contact_person']??'').'"></div>';
echo '<div class="field"><label>Phone</label><input name="phone" value="'.e($es['phone']??'').'"></div>';
echo '<div class="field"><label>Email</label><input name="email" value="'.e($es['email']??'').'"></div>';
echo '<div class="field"><label>Address</label><input name="address" value="'.e($es['address']??'').'"></div>';
echo '<div class="field"><label>Tax ID</label><input name="tax_id" value="'.e($es['tax_id']??'').'"></div>';
echo '<label style="font-size:13px"><input type="checkbox" name="active"'.($edit&&$es['active']?' checked':' checked').'> Active supplier</label>';
echo '<div style="margin-top:14px"><button class="btn">Save supplier</button></div>';
form_close();
echo '</div></div></div>';
page_foot();
