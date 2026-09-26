<?php
declare(strict_types=1);
$u=current_user();

if($_SERVER['REQUEST_METHOD']==='POST'){
 $act=$_GET['act']??'';
 switch($act){
  case 'item':
   $id=(int)($_POST['id']??0); $name=trim($_POST['name']); if(!$name){ flash('Item name required.','bad'); go('inventory'); }
   $code=trim($_POST['code']??''); $cat=(int)($_POST['category_id']??0)?:null;
   $unit=trim($_POST['unit'])?:'each'; $reorder=(float)($_POST['reorder_level']??0);
   if($id){ q('UPDATE inventory_items SET name=?,code=?,category_id=?,unit=?,reorder_level=? WHERE id=?',[$name,$code,$cat,$unit,$reorder,$id]); audit('update','inventory_item',$id); flash('Item updated.'); }
   else{
    if(!$code) $code='NVG-'.strtoupper(substr(md5((string)time()),0,6));
    q('INSERT INTO inventory_items(hotel_id,category_id,code,name,unit,reorder_level,active) VALUES(1,?,?,?,?,?,1)',[$cat,$code,$name,$unit,$reorder]);
    $iid=(int)db()->lastInsertId();
    q('INSERT INTO stock_levels(hotel_id,item_id,location,quantity) VALUES(1,?,?,0)',[$iid,$_POST['location']??'Main Store']);
    audit('create','inventory_item',$iid);
    flash('Item added.');
   }
   go('inventory');
   break;
  case 'move':
   $iid=(int)($_POST['item_id']??0); $type=$_POST['type']??''; $qty=abs((float)($_POST['qty']??0)); $loc=trim($_POST['location']??'')?:'Main Store'; $note=trim($_POST['note']??'');
   $loc = $_POST['loc']??$loc;
   if(!$iid||$qty<=0){ flash('Select an item and quantity.','bad'); go('inventory'); }
   $sign=1;
   if(in_array($type,['issue','waste','transfer_out'])) $sign=-1;
   if($type==='count_adjust'){
    $cur=(float)val('SELECT quantity FROM stock_levels WHERE item_id=? AND location=?',[$iid,$loc]);
    $delta=$qty-$cur;
    q('INSERT INTO stock_movements(hotel_id,item_id,location,type,quantity,note,user_id,created_at) VALUES(1,?,?,?,?,?,NOW())',[$iid,$loc,$type,$delta,'Count adjusted to '.$qty.' '.$note,$u['id']]);
    q('UPDATE stock_levels SET quantity=? WHERE item_id=? AND location=?',[$qty,$iid,$loc]);
    audit('stock_count_adjust','inventory_item',$iid,['location'=>$loc,'new'=>$qty]);
    flash('Stock level set to '.$qty.' at '.$loc.'.');
    go('inventory');
   }
   if($type==='transfer_in'){ $dst=trim($_POST['dst']??''); $add=row('SELECT id FROM stock_levels WHERE item_id=? AND location=?',[$iid,$dst]); if(!$add) { q('INSERT INTO stock_levels(hotel_id,item_id,location,quantity) VALUES(1,?,?,0)',[$iid,substr($dst,0,60)]); }
     q('INSERT INTO stock_movements(hotel_id,item_id,location,type,quantity,note,user_id,created_at) VALUES(1,?,?,?,?,?,NOW())',[$iid,$loc,'transfer_out',-$qty,$note,$u['id']]);
     q('INSERT INTO stock_movements(hotel_id,item_id,location,type,quantity,note,user_id,created_at) VALUES(1,?,?,?,?,?,NOW())',[$iid,$dst,'transfer_in',$qty,$note,$u['id']]);
     q('UPDATE stock_levels SET quantity=quantity-? WHERE item_id=? AND location=?',[$qty,$iid,$loc]);
     q('UPDATE stock_levels SET quantity=quantity+? WHERE item_id=? AND location=?',[$qty,$iid,$dst]);
     audit('transfer','inventory_item',$iid,['from'=>$loc,'to'=>$dst,'qty'=>$qty]);
     flash('Transferred '.$qty.' from '.$loc.' to '.$dst.'.'); go('inventory');
   }
   q('INSERT INTO stock_movements(hotel_id,item_id,location,type,quantity,note,user_id,created_at) VALUES(1,?,?,?,?,?,NOW())',[$iid,$loc,$type,$sign*$qty,$note,$u['id']]);
   q('UPDATE stock_levels SET quantity=quantity+? WHERE item_id=? AND location=?',[$sign*$qty,$iid,$loc]);
   audit('stock_movement','inventory_item',$iid,['type'=>$type,'qty'=>$sign*$qty,'location'=>$loc]);
   flash(ucfirst(str_replace('_',' ',$type)).' of '.$qty.' recorded at '.$loc.'.');
   go('inventory');
   break;
 }
}

$cats=rows('SELECT * FROM inventory_categories ORDER BY name');
$items=rows("SELECT i.*,c.name cat,(SELECT COALESCE(SUM(quantity),0) FROM stock_levels sl WHERE sl.item_id=i.id) total_at, i.reorder_level reorder FROM inventory_items i LEFT JOIN inventory_categories c ON c.id=i.category_id ORDER BY i.name");
$levels=rows('SELECT sl.*,i.name,i.code,i.unit,i.reorder_level FROM stock_levels sl JOIN inventory_items i ON i.id=sl.item_id ORDER BY i.name,sl.location');
$movs=rows('SELECT m.*,i.name FROM stock_movements m JOIN inventory_items i ON i.id=m.item_id ORDER BY m.id DESC LIMIT 25');

page_head('Inventory','inventory','Stores, stock levels and movements');

echo '<div class="kpis">';
kpi_card('Stock items',(string)($items?count($items):0),'Active catalogue');
$low=val('SELECT COUNT(*) FROM stock_levels sl JOIN inventory_items i ON i.id=sl.item_id WHERE sl.quantity<=i.reorder_level');
kpi_card('Low stock',(string)$low,'At or below reorder level','red');
kpi_card('Locations',(string)val('SELECT COUNT(DISTINCT location) FROM stock_levels'),'Storage points','blue');
echo '</div>';

echo '<div class="twoCol"><div>';
echo '<div class="panel"><h2>Stock levels</h2><p class="hint">Current quantities on hand by storage location.</p>';
echo '<table class="tbl"><thead><tr><th>Item</th><th>Code</th><th>Location</th><th class="num">Qty</th><th class="num">Reorder</th><th></th></tr></thead><tbody>';
foreach($levels as $s){
 $low2=$s['quantity']<=$s['reorder_level'];
 echo '<tr><td><b>'.e($s['name']).'</b><br><small style="color:var(--muted)">'.e($s['unit']).'</small></td><td>'.e($s['code']).'</td><td>'.e($s['location']).'</td><td class="num">'.num($s['quantity']).'</td><td class="num">'.num($s['reorder_level']).'</td><td>'.($low2?badge('Low stock','bad'):'').'</td></tr>';
}
if(!count($levels)) echo '<tr><td colspan="6" style="text-align:center;color:var(--muted)">No stock recorded.</td></tr>';
echo '</tbody></table></div>';

echo '<div class="panel"><h2>Recent stock movements</h2><p class="hint">The last 25 transactions.</p>';
echo '<table class="tbl"><thead><tr><th>Date</th><th>Item</th><th>Type</th><th>Location</th><th class="num">Qty</th></tr></thead><tbody>';
foreach($movs as $m){ $q=(float)$m['quantity']; echo '<tr><td>'.fmtdt($m['created_at']).'</td><td>'.e($m['name']).'</td><td>'.badge(str_replace('_',' ',$m['type'])).'</td><td>'.e($m['location']).'</td><td class="num" style="color:'.($q<0?'#c62828':'#2e7d32').'">'.($q<0?'-':'').num(abs($q)).'</td></tr>'; }
echo '</tbody></table></div></div>';

echo '<div>';
echo '<div class="panel"><h2>Record stock movement</h2><p class="hint">Issues, wastage, transfers and count adjustments.</p>';
form_open('inventory','move');
echo '<div class="field"><label>Item</label><select name="item_id">'; foreach($items as $i) echo '<option value="'.(int)$i['id'].'">'.e($i['name']).' ('.num($i['total_at']).' on hand)</option>'; echo '</select></div>';
echo '<div class="field"><label>Type</label><select name="type" id="mtype"><option value="issue">Issue to a department</option><option value="waste">Wastage or damage</option><option value="transfer_in">Transfer in</option><option value="transfer_out">Transfer out</option><option value="count_adjust">Set stock level (count adjustment)</option></select></div>';
echo '<div class="field"><label>Quantity</label><input type="number" name="qty" min="0.5" step="0.5" required></div>';
echo '<div class="field"><label>Location</label><select name="loc">'; foreach(rows('SELECT DISTINCT location FROM stock_levels') as $l) echo '<option>'.e($l['location']).'</option>'; echo '<option>Main Store</option><option>Bar</option><option>Kitchen</option></select></div>';
echo '<div class="field" id="dstWrap" hidden><label>Destination location</label><select name="dst"><option>Bar</option><option>Kitchen</option><option>Main Store</option></select></div>';
echo '<div class="field"><label>Note</label><input name="note" placeholder="Optional reference"></div>';
echo '<button class="btn">Record movement</button>'; form_close();
echo '<script>var t=document.getElementById("mtype");t.addEventListener("change",function(){document.getElementById("dstWrap").hidden=t.value!=="transfer_in";});</script>';
echo '</div>';

echo '<div class="panel"><h2>Add item</h2><p class="hint">Register a new stock item.</p>';
form_open('inventory','item');
echo '<div class="field"><label>Name</label><input name="name" required></div>';
echo '<div class="field"><label>Code</label><input name="code" placeholder="Auto if left blank"></div>';
echo '<div class="field"><label>Category</label><select name="category_id">'; foreach($cats as $c) echo '<option value="'.(int)$c['id'].'">'.e($c['name']).'</option>'; echo '</select></div>';
echo '<div class="field"><label>Unit</label><input name="unit" value="each"></div>';
echo '<div class="field"><label>Reorder level</label><input type="number" name="reorder_level" value="0" min="0" step="0.5"></div>';
echo '<div class="field"><label>Starting location</label><select name="location"><option>Main Store</option><option>Bar</option><option>Kitchen</option></select></div>';
echo '<button class="btn">Add item</button>'; form_close();
echo '</div></div></div>';
page_foot();
