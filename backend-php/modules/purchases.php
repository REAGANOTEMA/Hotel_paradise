<?php
declare(strict_types=1);
$u=current_user();

if($_SERVER['REQUEST_METHOD']==='POST'){
 $act=$_GET['act']??'';
 switch($act){
  case 'req':
   $dept=(int)($_POST['department_id']??0);
   $items=$_POST['items']??[];
   $clean=[];
   foreach($items as $iid=>$row){ if($iid===''||!is_array($row)||!(float)($row['qty']??0)>0) continue; $clean[(int)$iid]=(float)$row['qty']; }
   if(!$dept||!count($clean)){ flash('Choose a department and add at least one item.','bad'); go('purchases');
   }
   $num=next_number('REQ','purchase_requisitions','number');
   q('INSERT INTO purchase_requisitions(hotel_id,number,department_id,requested_by,status,note,created_at) VALUES(1,?,?,?,\'pending\',?,NOW())',[$num,$dept,$u['id'],trim($_POST['note']??'')]);
   $rid=(int)db()->lastInsertId();
   foreach($clean as $iid=>$qty){ q('INSERT INTO purchase_requisition_items(requisition_id,item_id,requested_qty) VALUES(?,?,?)',[$rid,$iid,$qty]); }
   audit('create','requisition',$rid,['number'=>$num]);
   flash('Requisition '.$num.' sent for approval.');
   go('purchases');
   break;
  case 'reqstatus':
   $rid=(int)($_POST['id']??0); $nst=$_POST['nst']??'';
   $r=row('SELECT * FROM purchase_requisitions WHERE id=?',[$rid]); if(!$r) break;
   if(in_array($nst,['approved','rejected'])){
    q('UPDATE purchase_requisitions SET status=?,approved_by=?,approved_at=NOW() WHERE id=?',[$nst,$u['id'],$rid]);
    audit('requisition_'.$nst,'requisition',$rid,['status'=>$r['status']]);
    flash('Requisition '.$r['number'].' '.$nst.'.');
   }
   go('purchases');
   break;
  case 'reqtopo':
   $rid=(int)($_POST['id']??0);
   $r=row('SELECT * FROM purchase_requisitions WHERE id=? AND status=\'approved\'',[$rid]);
   if(!$r){ flash('Only approved requisitions can become purchase orders.','bad'); go('purchases'); }
   $rows=rows('SELECT * FROM purchase_requisition_items WHERE requisition_id=?',[$rid]);
   $num=next_number('PO','purchase_orders','number');
   q('INSERT INTO purchase_orders(hotel_id,number,supplier_id,requisition_id,status,notes,created_by,created_at) VALUES(1,?,?,?,\'sent\',?,?,NOW())',[$num,(int)($_POST['supplier_id']??0),$rid,trim($_POST['notes']??''),$u['id']]);
   $oid=(int)db()->lastInsertId();
   foreach($rows as $it){ q('INSERT INTO purchase_order_items(order_id,item_id,quantity,unit_cost,total,received_qty) VALUES(?,?,?,?,?,0)',[$oid,$it['item_id'],$it['requested_qty'],0,0]); }
   audit('create','purchase_order',$oid,['number'=>$num,'from_requisition'=>$rid]);
   flash('Purchase order '.$num.' created from requisition. Enter unit costs on the order.');
   go('purchases',['view'=>$oid]);
   break;
  case 'po':
   $sup=(int)($_POST['supplier_id']??0);
   $items=$_POST['items']??[];
   $clean=[];
   foreach($items as $iid=>$row){ if($iid===''||!is_array($row)||!(float)($row['qty']??0)>0) continue; $clean[(int)$iid]=[(float)$row['qty'],(float)($row['cost']??0)]; }
   if(!$sup||!count($clean)){ flash('Choose a supplier and add at least one item.','bad'); go('purchases'); }
   $num=next_number('PO','purchase_orders','number');
   q('INSERT INTO purchase_orders(hotel_id,number,supplier_id,status,expected_date,notes,created_by,created_at) VALUES(1,?,?,\'sent\',?,?,?,NOW())',[$num,$sup,trim($_POST['expected_date']??''),trim($_POST['notes']??''),$u['id']]);
   $oid=(int)db()->lastInsertId();
   foreach($clean as $iid=>$d){ $tot=$d[0]*$d[1]; q('INSERT INTO purchase_order_items(order_id,item_id,quantity,unit_cost,total,received_qty) VALUES(?,?,?,?,?,0)',[$oid,$iid,$d[0],$d[1],$tot]); }
   audit('create','purchase_order',$oid,['number'=>$num]);
   flash('Purchase order '.$num.' created.');
   go('purchases',['view'=>$oid]);
   break;
  case 'poitems':
   $oid=(int)($_POST['oid']??0);
   $iid=(int)($_POST['additem']??0); $qty=(float)($_POST['addqty']??0); $cost=(float)($_POST['addcost']??0);
   if(!$iid||$qty<=0){ flash('Choose an item and quantity.','bad'); go('purchases',['view'=>$oid]); }
   q('INSERT INTO purchase_order_items(order_id,item_id,quantity,unit_cost,total,received_qty) VALUES(?,?,?,?,?,0)',[$oid,$iid,$qty,$cost,$qty*$cost]);
   audit('update','purchase_order',$oid,['action'=>'add_items']);
   flash('Item added to the purchase order.');
   go('purchases',['view'=>$oid]);
   break;
  case 'receive':
   $oid=(int)($_POST['oid']??0);
   $items=$_POST['items']??[];
   $loc=trim($_POST['loc']??'')?:'Main Store';
   foreach($items as $piid=>$row){
    if(!is_array($row)) continue;
    $rcv=(float)($row['qty']??0); if($rcv<=0) continue;
    $poi=row('SELECT * FROM purchase_order_items WHERE id=? AND order_id=?',[(int)$piid,$oid]); if(!$poi) continue;
    $newRcv=$poi['received_qty']+$rcv; if($newRcv>$poi['quantity']) $newRcv=$poi['quantity'];
    $qty=(float)$newRcv-$poi['received_qty']; if($qty<=0) continue;
    q('UPDATE purchase_order_items SET received_qty=? WHERE id=?',[$newRcv,$poi['id']]);
    q('INSERT INTO stock_movements(hotel_id,item_id,location,type,quantity,unit_cost,reference_type,reference_id,note,user_id,created_at) VALUES(1,?,?,\'purchase_in\',?,?,?,?,?,?,NOW())',[$poi['item_id'],$loc,$qty,$poi['unit_cost'],'purchase_order',$oid,'GRN for PO '.$oid,$u['id']]);
    q('UPDATE stock_levels SET quantity=quantity+? WHERE item_id=? AND location=?',[$qty,$poi['item_id'],$loc]);
   }
   $totQty=val('SELECT COALESCE(SUM(quantity),0) FROM purchase_order_items WHERE order_id=?',[$oid]);
   $rcvQty=val('SELECT COALESCE(SUM(received_qty),0) FROM purchase_order_items WHERE order_id=?',[$oid]);
   q('UPDATE purchase_orders SET status=? WHERE id=?',[$rcvQty>=$totQty?'received':'partially_received',$oid]);
   audit('goods_receive','purchase_order',$oid,['location'=>$loc]);
   flash('Goods received and stock updated.');
   go('purchases',['view'=>$oid]);
   break;
  case 'pocancel':
   $oid=(int)($_POST['oid']??0);
   q('UPDATE purchase_orders SET status=\'cancelled\' WHERE id=?',[$oid]);
   audit('cancel','purchase_order',$oid);
   flash('Purchase order cancelled.');
   go('purchases');
   break;
 }
}

$view=(int)($_GET['view']??0);
if($view){
 $o=row('SELECT po.*,s.name supplier,d.name dept FROM purchase_orders po JOIN suppliers s ON s.id=po.supplier_id LEFT JOIN purchase_requisitions pr ON pr.id=po.requisition_id LEFT JOIN departments d ON d.id=pr.department_id WHERE po.id=?',[$view]); if(!$o){ page_head('Purchases'); echo '<div class="panel"><p>Not found.</p></div>'; page_foot(); exit; }
 $items=rows('SELECT poi.*,i.name iname FROM purchase_order_items poi JOIN inventory_items i ON i.id=poi.item_id WHERE poi.order_id=?',[$view]);
 page_head('Purchase order '.$o['number'],'purchases','Supplier: '.$o['supplier']);
 echo '<div class="toolbar"><a class="btnGhost sm" href="'.BASE.'/index.php?page=purchases">&larr; Purchases</a>'.status_badge($o['status']).'</div>';

 echo '<div class="twoCol"><div>';
 echo '<div class="panel"><h2>Order items</h2><p class="hint">Expected quantities, unit costs and received goods.</p>';
 echo '<table class="tbl"><thead><tr><th>Item</th><th class="num">Ordered</th><th class="num">Unit cost</th><th class="num">Total</th><th class="num">Received</th></tr></thead><tbody>';
 foreach($items as $i){ echo '<tr><td><b>'.e($i['iname']).'</b></td><td class="num">'.num($i['quantity']).'</td><td class="num">'.money($i['unit_cost']).'</td><td class="num">'.money($i['total']).'</td><td class="num">'.num($i['received_qty']).'</td></tr>'; }
 echo '</tbody></table></div></div>';

 echo '<div>';
 echo '<div class="panel"><h2>Receive goods</h2><p class="hint">Receiving moves goods into stock automatically.</p>';
 form_open('purchases','receive',['oid'=>$view]);
 echo '<div class="field"><label>Deliver to location</label><select name="loc"><option>Main Store</option><option>Bar</option><option>Kitchen</option></select></div>';
 $pending=array_filter($items,fn($i)=>(float)($i['received_qty'])<(float)($i['quantity']));
 if(count($pending)){
  foreach($pending as $i){ echo '<div class="field"><label>'.e($i['iname']).'  (received '.num($i['received_qty']).' of '.num($i['quantity']).')</label><input type="number" step="0.5" min="0" name="items['.(int)$i['id'].'][qty]" value="'.num($i['quantity']-$i['received_qty']).'"></div>'; }
  echo '<button class="btn tick">Receive goods</button>';
 }else{ echo '<p style="color:var(--muted)">This order is fully received.</p>'; }
 form_close();
 echo '</div>';
 if($o['status']!=='cancelled'){ echo '<div class="panel"><h2>Add more items</h2><p class="hint">Extend this order with an item and its unit cost.</p>'; form_open('purchases','poitems',['oid'=>$view]);
  echo '<div class="field"><label>Item</label><select name="additem" id="addpoi"><option value="">Choose item</option>'; $listy=rows('SELECT * FROM inventory_items ORDER BY name'); foreach($listy as $it) echo '<option value="'.(int)$it['id'].'">'.e($it['name']).'</option>'; echo '</select></div>';
  echo '<div class="field"><label>Quantity</label><input type="number" name="addqty" min="0.5" step="0.5" value="1"></div>';
  echo '<div class="field"><label>Unit cost (UGX)</label><input type="number" name="addcost" min="0" step="100" value="0"></div>';
  echo '<button class="btn">Add to order</button>'; form_close(); echo '</div>'; }
 if($o['status']==='sent'||$o['status']==='partially_received'){ echo '<div class="panel">'; form_open('purchases','pocancel'); echo '<input type="hidden" name="oid" value="'.(int)$view.'"><button class="btn danger" onclick="return confirm(\'Cancel this purchase order?\')">Cancel order</button>'; form_close(); echo '</div>'; }
 echo '</div></div>';
 page_foot(); exit;
}

$reqs=rows('SELECT pr.*,d.name dept,u.name reqby FROM purchase_requisitions pr JOIN departments d ON d.id=pr.department_id JOIN users u ON u.id=pr.requested_by ORDER BY pr.id DESC LIMIT 30');
$pos=rows('SELECT po.*,s.name supplier FROM purchase_orders po JOIN suppliers s ON s.id=po.supplier_id ORDER BY po.id DESC LIMIT 30');
$depts=rows('SELECT * FROM departments ORDER BY name');
$items=rows('SELECT * FROM inventory_items ORDER BY name');
$suppliers=rows('SELECT * FROM suppliers WHERE active=1 ORDER BY name');

page_head('Purchases','purchases','Requisitions, purchase orders and receiving');
echo '<div class="twoCol"><div>';

echo '<div class="panel"><h2>Purchase requisitions</h2><p class="hint">Department requests awaiting approval or converted to orders.</p>';
echo '<table class="tbl"><thead><tr><th>Number</th><th>Department</th><th>Requested by</th><th>Status</th><th></th></tr></thead><tbody>';
foreach($reqs as $r){
$line=(int)val('SELECT COALESCE(SUM(ri.requested_qty),0) FROM purchase_requisition_items ri WHERE ri.requisition_id=?',[$r['id']]);
  echo '<tr><td><b>'.e($r['number']).'</b></td><td>'.e($r['dept']).'</td><td>'.e($r['reqby']).'</td><td><small style="color:var(--muted)">'.$line.' item(s)</small></td><td>'.status_badge($r['status']).'</td><td>';
 if($r['status']==='pending'){ form_open('purchases','reqstatus',['id'=>$r['id']]); echo '<input type="hidden" name="nst" value="approved"><button class="btn sm tick">Approve</button>'; form_close(); form_open('purchases','reqstatus',['id'=>$r['id']]); echo '<input type="hidden" name="nst" value="rejected"><button class="btn sm danger">Reject</button>'; form_close(); }
 if($r['status']==='approved'){ echo ' <button class="btn sm blue" onclick="document.getElementById(\'poFrom'.(int)$r['id'].'\').hidden=false">Create purchase order</button>';
  echo '<div id="poFrom'.(int)$r['id'].'" hidden style="margin-top:10px;background:#f6f4ea;border:1px solid var(--line);border-radius:10px;padding:12px">';
  form_open('purchases','reqtopo'); echo '<input type="hidden" name="id" value="'.(int)$r['id'].'">';
  echo '<div class="field"><label>Supplier</label><select name="supplier_id">'; foreach($suppliers as $s) echo '<option value="'.(int)$s['id'].'">'.e($s['name']).'</option>'; echo '</select></div>';
  echo '<div class="field"><label>Notes</label><input name="notes"></div><button class="btn sm">Create from requisition</button>'; form_close(); echo '</div>';
 }
 echo '</td></tr>';
}
echo '</tbody></table></div>';

echo '<div class="panel"><h2>Purchase orders</h2><p class="hint">Orders sent to suppliers and their receiving status.</p>';
echo '<table class="tbl"><thead><tr><th>Number</th><th>Supplier</th><th>Created</th><th>Status</th><th></th></tr></thead><tbody>';
foreach($pos as $p){ echo '<tr><td><b>'.e($p['number']).'</b></td><td>'.e($p['supplier']).'</td><td>'.fmtdt($p['created_at']).'</td><td>'.status_badge($p['status']).'</td><td><a class="btn sm" href="'.BASE.'/index.php?page=purchases&view='.(int)$p['id'].'">Open</a></td></tr>'; }
echo '</tbody></table></div></div>';

echo '<div>';
$deptsel=count($depts)?$depts[0]['id']:0;
echo '<div class="panel"><h2>New requisition</h2><p class="hint">Request stock for a department.</p>';
form_open('purchases','req');
echo '<div class="field"><label>Department</label><select name="department_id">'; foreach($depts as $d) echo '<option value="'.(int)$d['id'].'">'.e($d['name']).'</option>'; echo '</select></div>';
echo '<div class="field"><label>Items needed</label><div id="reqitems"></div></div>';
echo '<button type="button" class="btnGhost sm" onclick="addReqRow()">+ Add item</button>';
echo '<div class="field" style="margin-top:14px"><label>Note</label><input name="note"></div>';
echo '<button class="btn">Submit for approval</button>'; form_close();
echo '</div>';

echo '<div class="panel"><h2>New purchase order</h2><p class="hint">Order directly from a supplier.</p>';
form_open('purchases','po');
echo '<div class="field"><label>Supplier</label><select name="supplier_id">'; foreach($suppliers as $s) echo '<option value="'.(int)$s['id'].'">'.e($s['name']).'</option>'; echo '</select></div>';
echo '<div class="field"><label>Items (qty and unit cost)</label><div id="poitems"></div></div>';
echo '<button type="button" class="btnGhost sm" onclick="addPORow()">+ Add item</button>';
echo '<div class="field" style="margin-top:14px"><label>Expected date</label><input type="date" name="expected_date"></div>';
echo '<div class="field"><label>Notes</label><input name="notes"></div>';
echo '<button class="btn">Create order</button>'; form_close();
echo '</div></div></div>';

$opts='';
foreach($items as $it) $opts.="<option value=\"{$it['id']}\">".htmlspecialchars(($it['name']))."</option>";
echo '<script>
var opts=\''.addslashes($opts).'\';
function addPORow(id){ var d=document.getElementById("poitems"); var row=document.createElement("div"); row.style.cssText="display:flex;gap:8px;margin-bottom:8px"; row.innerHTML="<select class=\'poItemSel\' style=\'flex:1;padding:9px;border:1px solid var(--line);border-radius:8px\'></select><input class=\'poQty\' type=\'number\' placeholder=\'Qty\' style=\'width:90px;padding:9px;border:1px solid var(--line);border-radius:8px\'><input class=\'poCost\' type=\'number\' placeholder=\'Cost\' step=\'100\' style=\'width:110px;padding:9px;border:1px solid var(--line);border-radius:8px\'><button type=\'button\' onclick=\'this.parentNode.remove()\'>x</button>";
 row.querySelector(".poItemSel").innerHTML="<option value=\'\'>Choose item</option>"+opts;
 row.querySelector(".poItemSel").onchange=function(){ this.name="items["+this.value+"][qty]"; this.nextElementSibling.name="items["+this.value+"][qty]"; this.nextElementSibling.nextElementSibling.name="items["+this.value+"][cost]"; };
 d.appendChild(row);
}
function addReqRow(){ var d=document.getElementById("reqitems"); var row=document.createElement("div"); row.style.cssText="display:flex;gap:8px;margin-bottom:8px"; row.innerHTML="<select class=\'rqItemSel\' style=\'flex:1;padding:9px;border:1px solid var(--line);border-radius:8px\'></select><input class=\'rqQty\' type=\'number\' placeholder=\'Qty\' style=\'width:110px;padding:9px;border:1px solid var(--line);border-radius:8px\'><button type=\'button\' onclick=\'this.parentNode.remove()\'>x</button>";
 row.querySelector(".rqItemSel").innerHTML="<option value=\'\'>Choose item</option>"+opts;
 row.querySelector(".rqItemSel").onchange=function(){ this.name="items["+this.value+"][qty]"; this.nextElementSibling.name="items["+this.value+"][qty]"; };
 d.appendChild(row);
}
addPORow();addPORow();addReqRow();addReqRow();
</script>';
page_foot();

