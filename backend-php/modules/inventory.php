<?php
declare(strict_types=1);
$u=current_user();
require_once __DIR__.'/../app/stock_requests.php';

/** After a stock move, ring once a day for each item that has fallen to or
 *  below its reorder level. The event key carries the date, so a busy day
 *  raises one alert per item rather than one per movement. */
$lowStockAlert=function(int $iid,string $loc): void{
 $r=row('SELECT i.name,i.unit,i.reorder_level,COALESCE(SUM(sl.quantity),0) qty FROM inventory_items i LEFT JOIN stock_levels sl ON sl.item_id=i.id WHERE i.id=? GROUP BY i.id',[$iid]);
 if(!$r||(float)$r['qty']>(float)$r['reorder_level']) return;
 notify_console('lowstock:'.$iid.':'.date('Y-m-d'),'incident','Low stock: '.$r['name'],
  'Down to '.num($r['qty']).' '.$r['unit'].' (reorder at '.num($r['reorder_level']).') after a movement at '.$loc.'.',
  ['item_id'=>$iid],['director','general_manager','storekeeper','accountant'],'inventory_item',$iid);
};

if($_SERVER['REQUEST_METHOD']==='POST'){
 $act=$_GET['act']??'';
 switch($act){
  case 'item':
   $id=(int)($_POST['id']??0); $name=trim($_POST['name']); if(!$name){ flash('Item name required.','bad'); go('inventory'); }
   $code=trim($_POST['code']??''); $cat=(int)($_POST['category_id']??0)?:null;
   $unit=trim($_POST['unit'])?:'each'; $reorder=(float)($_POST['reorder_level']??0); $cost=(float)($_POST['unit_cost']??0);
   if($id){ q('UPDATE inventory_items SET name=?,code=?,category_id=?,unit=?,reorder_level=?,unit_cost=? WHERE id=?',[$name,$code,$cat,$unit,$reorder,$cost,$id]); audit('update','inventory_item',$id); flash('Item updated.'); }
   else{
    if(!$code) $code='NVG-'.strtoupper(substr(md5((string)time()),0,6));
    q('INSERT INTO inventory_items(hotel_id,category_id,code,name,unit,reorder_level,unit_cost,active) VALUES(1,?,?,?,?,?,?,1)',[$cat,$code,$name,$unit,$reorder,$cost]);
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
    $lowStockAlert($iid,$loc);
    flash('Stock level set to '.$qty.' at '.$loc.'.');
    go('inventory');
   }
   if($type==='transfer_in'){ $dst=trim($_POST['dst']??''); $add=row('SELECT id FROM stock_levels WHERE item_id=? AND location=?',[$iid,$dst]); if(!$add) { q('INSERT INTO stock_levels(hotel_id,item_id,location,quantity) VALUES(1,?,?,0)',[$iid,substr($dst,0,60)]); }
     q('INSERT INTO stock_movements(hotel_id,item_id,location,type,quantity,note,user_id,created_at) VALUES(1,?,?,?,?,?,NOW())',[$iid,$loc,'transfer_out',-$qty,$note,$u['id']]);
     q('INSERT INTO stock_movements(hotel_id,item_id,location,type,quantity,note,user_id,created_at) VALUES(1,?,?,?,?,?,NOW())',[$iid,$dst,'transfer_in',$qty,$note,$u['id']]);
     q('UPDATE stock_levels SET quantity=quantity-? WHERE item_id=? AND location=?',[$qty,$iid,$loc]);
     q('UPDATE stock_levels SET quantity=quantity+? WHERE item_id=? AND location=?',[$qty,$iid,$dst]);
     audit('transfer','inventory_item',$iid,['from'=>$loc,'to'=>$dst,'qty'=>$qty]);
     $lowStockAlert($iid,$loc);
     flash('Transferred '.$qty.' from '.$loc.' to '.$dst.'.'); go('inventory');
   }
   q('INSERT INTO stock_movements(hotel_id,item_id,location,type,quantity,note,user_id,created_at) VALUES(1,?,?,?,?,?,NOW())',[$iid,$loc,$type,$sign*$qty,$note,$u['id']]);
   q('UPDATE stock_levels SET quantity=quantity+? WHERE item_id=? AND location=?',[$sign*$qty,$iid,$loc]);
   audit('stock_movement','inventory_item',$iid,['type'=>$type,'qty'=>$sign*$qty,'location'=>$loc]);
   $lowStockAlert($iid,$loc);
   flash(ucfirst(str_replace('_',' ',$type)).' of '.$qty.' recorded at '.$loc.'.');
   go('inventory');
   break;
 }
}

$cats=rows('SELECT * FROM inventory_categories ORDER BY name');
$items=rows("SELECT i.*,c.name cat,(SELECT COALESCE(SUM(quantity),0) FROM stock_levels sl WHERE sl.item_id=i.id) total_at, i.reorder_level reorder FROM inventory_items i LEFT JOIN inventory_categories c ON c.id=i.category_id WHERE i.deleted_at IS NULL ORDER BY i.name");
$levels=rows('SELECT sl.*,i.name,i.code,i.unit,i.reorder_level FROM stock_levels sl JOIN inventory_items i ON i.id=sl.item_id WHERE i.deleted_at IS NULL ORDER BY i.name,sl.location');
$movs=rows('SELECT m.*,i.name FROM stock_movements m JOIN inventory_items i ON i.id=m.item_id WHERE i.deleted_at IS NULL ORDER BY m.id DESC LIMIT 25');
$editItem=(int)($_GET['edit']??0); $ei=$editItem?row('SELECT * FROM inventory_items WHERE id=?',[$editItem]):null;

page_head('Inventory','inventory','Stores, stock levels and movements');

echo '<div class="kpis">';
kpi_card('Stock items',(string)($items?count($items):0),'Active catalogue');
$low=val('SELECT COUNT(*) FROM stock_levels sl JOIN inventory_items i ON i.id=sl.item_id WHERE sl.quantity<=i.reorder_level');
kpi_card('Low stock',(string)$low,'At or below reorder level','red');
kpi_card('Locations',(string)val('SELECT COUNT(DISTINCT location) FROM stock_levels'),'Storage points','blue');
echo '</div>';

/* The store manager's inbox. Every inventory request lands here first, with the
   items and the money it comes to, so the Director can decide from one screen. */
$canDecide=(bool)array_intersect(roles_of(),['director','general_manager','super_admin']);
$stockReqs=rows('SELECT pr.*,d.name dept,u.name reqby,'
 .'(SELECT COALESCE(SUM(requested_qty*est_cost),0) FROM purchase_requisition_items ri WHERE ri.requisition_id=pr.id) amount'
 .' FROM purchase_requisitions pr JOIN departments d ON d.id=pr.department_id JOIN users u ON u.id=pr.requested_by'
 .' WHERE pr.deleted_at IS NULL ORDER BY (pr.status=\'pending\') DESC, pr.id DESC LIMIT 15');
$pendingReqs=0; foreach($stockReqs as $sr){ if($sr['status']==='pending') $pendingReqs++; }
echo '<div class="panel" style="border-left:4px solid var(--gold)"><h2>Stock requests'.($pendingReqs?' '.badge($pendingReqs.' pending','warn'):'').'</h2>';
echo '<p class="hint">Department requests for stock from the store. They arrive here the moment they are raised; the Director is alerted with the full list and the amount at the same time.</p>';
echo '<table class="tbl"><thead><tr><th>Number</th><th>Department</th><th>Items</th><th class="num">Amount</th><th>Status</th>'.($canDecide?'<th>Decision</th>':'').'</tr></thead><tbody>';
foreach($stockReqs as $sr){
 echo '<tr><td><b>'.e($sr['number']).'</b><br><small>'.e($sr['reqby']).'</small></td><td>'.e($sr['dept']).'</td>'
  .'<td>'.e(stock_request_item_list((int)$sr['id'])?:'—').'</td><td class="num"><b>'.money($sr['amount']).'</b></td>'
  .'<td>'.status_badge($sr['status']).($sr['status']==='rejected'&&trim((string)($sr['decision_reason']??''))!==''?'<br><small>'.e($sr['decision_reason']).'</small>':'').'</td>';
 if($canDecide){
  echo '<td style="white-space:nowrap">';
  if($sr['status']==='pending'){
   form_open('purchases','reqstatus',['id'=>$sr['id']]);
   echo '<input type="hidden" name="nst" value="approved"><input type="hidden" name="back" value="inventory"><button class="btn sm tick">Approve</button></form>';
   form_open('purchases','reqstatus',['id'=>$sr['id']]);
   echo '<input type="hidden" name="nst" value="rejected"><input type="hidden" name="back" value="inventory">';
   echo '<input name="reason" placeholder="Reason (required)" style="margin-top:6px;width:160px;padding:7px;border:1px solid var(--line);border-radius:8px"><button class="btn sm danger" style="margin-top:6px">Reject</button></form>';
  }else{ echo '—'; }
  echo '</td>';
 }
 echo '</tr>';
}
if(!count($stockReqs)) echo '<tr><td colspan="'.($canDecide?6:5).'" style="text-align:center;color:var(--muted)">No stock requests yet.</td></tr>';
echo '</tbody></table></div>';

echo '<div class="twoCol"><div>';
echo '<div class="panel"><h2>Item catalogue</h2><p class="hint">Every stock item. Edit a detail, or move an item to the Trash.</p>';
echo '<table class="tbl"><thead><tr><th>Item</th><th>Code</th><th>Category</th><th class="num">On hand</th><th></th></tr></thead><tbody>';
foreach($items as $i){
 echo '<tr><td><b>'.e($i['name']).'</b><br><small>'.e($i['unit']).'</small></td><td>'.e($i['code']).'</td><td>'.e($i['cat']??'-').'</td><td class="num">'.num($i['total_at']).'</td><td style="white-space:nowrap"><a class="btn sm" href="'.BASE.'/index.php?page=inventory&edit='.(int)$i['id'].'">Edit</a> '.trash_button('inventory_items',(int)$i['id'],'inventory').'</td></tr>';
}
if(!count($items)) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No items yet.</td></tr>';
echo '</tbody></table></div>';
echo '<div class="panel"><h2>Stock levels</h2><p class="hint">Current quantities on hand by storage location.</p>';
echo '<table class="tbl"><thead><tr><th>Item</th><th>Code</th><th>Location</th><th class="num">Qty</th><th class="num">Reorder</th><th></th></tr></thead><tbody>';
foreach($levels as $s){
 $low2=$s['quantity']<=$s['reorder_level'];
 echo '<tr><td><b>'.e($s['name']).'</b><br><small>'.e($s['unit']).'</small></td><td>'.e($s['code']).'</td><td>'.e($s['location']).'</td><td class="num">'.num($s['quantity']).'</td><td class="num">'.num($s['reorder_level']).'</td><td>'.($low2?badge('Low stock','bad'):'').'</td></tr>';
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

echo '<div class="panel"><h2>'.($ei?'Edit item':'Add item').'</h2><p class="hint">'.($ei?'Update this stock item.':'Register a new stock item.').'</p>';
form_open('inventory','item');
if($ei) echo '<input type="hidden" name="id" value="'.(int)$ei['id'].'">';
echo '<div class="field"><label>Name</label><input name="name" value="'.e($ei['name']??'').'" required></div>';
echo '<div class="field"><label>Code</label><input name="code" value="'.e($ei['code']??'').'" placeholder="Auto if left blank"></div>';
echo '<div class="field"><label>Category</label><select name="category_id">'; foreach($cats as $c) echo '<option value="'.(int)$c['id'].'"'.($ei&&(int)$ei['category_id']===(int)$c['id']?' selected':'').'>'.e($c['name']).'</option>'; echo '</select></div>';
echo '<div class="field"><label>Unit</label><input name="unit" value="'.e($ei['unit']??'each').'"></div>';
echo '<div class="field"><label>Reorder level</label><input type="number" name="reorder_level" value="'.(float)($ei['reorder_level']??0).'" min="0" step="0.5"></div>';
echo '<div class="field"><label>Unit cost (UGX)</label><input type="number" name="unit_cost" value="'.(float)($ei['unit_cost']??0).'" min="0" step="100"></div>';
if(!$ei) echo '<div class="field"><label>Starting location</label><select name="location"><option>Main Store</option><option>Bar</option><option>Kitchen</option></select></div>';
else echo '<p class="hint" style="margin-top:4px"><a href="'.BASE.'/index.php?page=inventory">Cancel edit</a></p>';
echo '<button class="btn">'.($ei?'Save item':'Add item').'</button>'; form_close();
echo '</div></div></div>';
page_foot();
