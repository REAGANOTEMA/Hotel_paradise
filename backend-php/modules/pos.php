<?php
declare(strict_types=1);

$act=$_GET['act']??'';
$u=current_user();
require_once __DIR__.'/../app/pos.php';

if($_SERVER['REQUEST_METHOD']==='POST'){
 switch($act){
  case 'shift':
   $outlet=$_POST['outlet']??'restaurant';
   if(!in_array($outlet,['restaurant','bar','front_desk','kitchen','store'],true)){
    flash('Choose a valid shift outlet.','bad'); go('pos');
   }
   $r=row('SELECT id FROM shifts WHERE user_id=? AND status=\'open\'',[$u['id']]);
   if($r){ flash('You already have an open shift.','warn'); go('pos'); }
   q('INSERT INTO shifts(hotel_id,user_id,outlet,opened_at,opening_cash) VALUES(1,?,?,NOW(),?)',[$u['id'],$outlet,round(max(0.0,(float)($_POST['opening']??0)),2)]);
   audit('open_shift','shift',(int)db()->lastInsertId(),['outlet'=>$outlet]);
   flash('Shift opened.');
   go('pos');
   break;
  case 'order':
   $outlet=$_POST['outlet']??'restaurant';
   $otype=$_POST['order_type']??'table';
   $items=$_POST['items']??[];
   if(!is_array($items)) $items=[];
   if(!in_array($outlet,['restaurant','bar','room_service'],true)){ flash('Choose a valid order outlet.','bad'); go('pos'); }
   if(!in_array($otype,['table','room','takeaway','delivery'],true)){ flash('Choose a valid order type.','bad'); go('pos'); }
   $shift=row('SELECT id FROM shifts WHERE user_id=? AND status=\'open\'',[$u['id']]);
   if(!$shift){ flash('Open a shift before taking an order.','bad'); go('pos'); }
   $num=next_number('ORD','orders','order_number');
   $ids=array_values(array_unique(array_map('intval',array_keys($items))));
   $itemMap=[];
   if($ids){
     $iph=implode(',',array_fill(0,count($ids),'?'));
     foreach(rows("SELECT id,price,name FROM menu_items WHERE active=1 AND id IN($iph)",$ids) as $mi) $itemMap[(int)$mi['id']]=$mi;
   }
   $orderLines=[];
   foreach($items as $iid=>$qty){ $total=0;
     if(is_array($qty)){ foreach($qty as $unit) $total+=(float)$unit; $qty=$total; }
     $qty=round((float)$qty,2);
     if($qty<=0) continue;
     if(!isset($itemMap[(int)$iid])) continue;
     $it=$itemMap[(int)$iid];
     $orderLines[]=['menu_item_id'=>(int)$iid,'custom_name'=>null,'quantity'=>$qty,
       'unit_price'=>(float)$it['price'],'note'=>null,'name'=>(string)$it['name']];
   }
   $customNames=$_POST['custom_name']??[];
   $customPrices=$_POST['custom_price']??[];
   $customQtys=$_POST['custom_qty']??[];
   $customNotes=$_POST['custom_note']??[];
   if(!is_array($customNames)) $customNames=[];
   if(!is_array($customPrices)) $customPrices=[];
   if(!is_array($customQtys)) $customQtys=[];
   if(!is_array($customNotes)) $customNotes=[];
   $customCount=max(count($customNames),count($customPrices),count($customQtys),count($customNotes));
   $customLines=0;
   for($i=0;$i<$customCount;$i++){
     $name=mb_substr(trim((string)($customNames[$i]??'')),0,190);
     $price=round((float)($customPrices[$i]??0),2);
     $qty=round((float)($customQtys[$i]??0),2);
     $note=mb_substr(trim((string)($customNotes[$i]??'')),0,500);
     if($name===''&&$price<=0&&$qty<=0&&$note==='') continue;
     if($name===''){ flash('Give the custom item a name.','bad'); go('pos'); }
     if($price<=0){ flash('Enter a price greater than zero for '.$name.'.','bad'); go('pos'); }
     if($qty<=0||$qty>999){ flash('Enter a quantity between 0.01 and 999 for '.$name.'.','bad'); go('pos'); }
     $orderLines[]=['menu_item_id'=>null,'custom_name'=>$name,'quantity'=>$qty,
       'unit_price'=>$price,'note'=>$note,'name'=>$name];
     $customLines++;
   }
   if(!$orderLines){ flash('Add at least one item to the order.','bad'); go('pos'); }
   if($customLines>0 && !hp_order_items_allow_custom()){
     flash('Custom items need the database update 2026-10-29_pos_custom_items.sql. Ask a manager to apply it, then try again.','bad');
     go('pos');
   }
   $sub=0;
   foreach($orderLines as $ln) $sub+=(float)$ln['unit_price']*(float)$ln['quantity'];
   $sub=round($sub,2);
   if($sub<=0){ flash('Choose at least one available menu item or add a priced custom item.','bad'); go('pos'); }
   $totals=pos_order_totals($sub);
   $tableName=in_array($otype,['table','room'],true)?mb_substr(trim((string)($_POST['table_name']??'')),0,60):'';
   q('INSERT INTO orders(hotel_id,user_id,shift_id,order_number,outlet,order_type,table_name,status,subtotal,tax,total,created_at) VALUES(1,?,?,?,?,?,?,\'pending\',?,?,?,NOW())',
     [$u['id'],$shift['id'],$num,$outlet,$otype,$tableName!==''?$tableName:null,$totals['subtotal'],$totals['tax'],$totals['total']]);
    $oid=(int)db()->lastInsertId();
    $notes=mb_substr(trim((string)($_POST['notes']??'')),0,1000);
    $canCustom=hp_order_items_allow_custom();
    $firstLine=true;
    foreach($orderLines as $ln){
     $lineNote=(string)($ln['note']??'');
     if($firstLine && $notes!=='') $lineNote=trim(($lineNote!==''?$lineNote.' — ':'').$notes);
     $total=(float)$ln['unit_price']*(float)$ln['quantity'];
     if($canCustom){
      q('INSERT INTO order_items(order_id,menu_item_id,custom_name,quantity,unit_price,total,notes) VALUES(?,?,?,?,?,?,?)',
        [$oid,$ln['menu_item_id'],$ln['custom_name'],$ln['quantity'],$ln['unit_price'],$total,$lineNote!==''?$lineNote:null]);
     }else{
      q('INSERT INTO order_items(order_id,menu_item_id,quantity,unit_price,total,notes) VALUES(?,?,?,?,?,?)',
        [$oid,$ln['menu_item_id'],$ln['quantity'],$ln['unit_price'],$total,$lineNote!==''?$lineNote:null]);
     }
     if($ln['menu_item_id']!==null) audit('order_item','menu_item',(int)$ln['menu_item_id'],['order'=>$oid,'qty'=>(float)$ln['quantity']]);
     else audit('custom_order_item','order',$oid,['name'=>(string)$ln['custom_name'],'qty'=>(float)$ln['quantity'],'price'=>(float)$ln['unit_price']]);
     $firstLine=false;
    }
   audit('create','order',$oid,['number'=>$num,'subtotal'=>$totals['subtotal'],'service_charge'=>$totals['tax'],'total'=>$totals['total']]);
   notify_console('desk-order:'.$oid,'order','New order '.$num,
    ucfirst(str_replace('_',' ',(string)$outlet)).' · '.count($orderLines).' item line(s) · '.money($totals['total']),
    ['order_id'=>$oid,'order_number'=>$num],['director','general_manager','cashier','kitchen'],'order',$oid);
   flash('Order '.$num.' sent to the kitchen or service area.');
   go('pos');
   break;
  case 'status':
   $oid=(int)($_GET['oid']??$_POST['oid']??0); $nst=$_POST['nst']??'';
   $r=row('SELECT status,order_number,total FROM orders WHERE id=?',[$oid]); if(!$r) break;
   $map=['accepted','preparing','ready','served','cancelled'];
   if(in_array($nst,$map,true)){
    $reason=mb_substr(trim((string)($_POST['reason']??'')),0,255);
    if($nst==='cancelled' && $reason===''){ flash('A reason is required to cancel an order.','bad'); go('pos'); }
    if($nst==='cancelled' && pos_order_paid($oid)>0.001){
     flash('This order has money against it. Reverse the payment before cancelling it.','bad'); go('pos');
    }
    if($nst==='cancelled'){
     q('INSERT INTO voids(hotel_id,ref_type,ref_id,reason,amount,user_id,created_at) VALUES(1,\'order\',?,?,?,?,NOW())',[$oid,$reason,(float)$r['total'],$u['id']]);
    }
     q('UPDATE orders SET status=? WHERE id=?',[$nst,$oid]);
     audit('order_status','order',$oid,['status'=>$r['status']],['status'=>$nst]);
     if($nst==='cancelled'){
      notify_console('desk-order-cancel:'.$oid,'incident','Order '.$r['order_number'].' cancelled',
       'Cancelled from the POS. Reason: '.$reason.'.',
       ['order_id'=>$oid],['director','general_manager','cashier','kitchen'],'order',$oid);
     }
     flash('Order '.$r['order_number'].' updated to '.$nst.'.');
   }
   go('pos');
   break;
  case 'settle':
   $oid=(int)($_GET['oid']??$_POST['oid']??0);
   $r=row('SELECT * FROM orders WHERE id=?',[$oid]);
   if(!$r){ flash('That order could not be found.','bad'); go('pos'); }
   $settled=pos_settle_order($r,(float)($_POST['amount']??0),(string)($_POST['method']??'cash'),(float)($_POST['discount']??0),(int)$u['id'],[
    'reference'=>(string)($_POST['reference']??''),
    'payer_phone'=>(string)($_POST['payer_phone']??''),
   ]);
   if(!$settled['ok']){ flash((string)$settled['error'],'bad'); go('pos'); }
   $payId=(int)$settled['payment_id'];
   notify_console('desk-order-payment:'.$payId,'payment','Order payment '.money($settled['amount']),
    'Received by '.str_replace('_',' ',(string)$settled['method']).' for order '.$r['order_number'].'.',
    ['order_id'=>$oid,'payment_id'=>$payId],['director','general_manager','accountant','cashier'],'payment',$payId);
   require_once __DIR__.'/../app/receipts.php';
   $receipt=receipts_after_payment($payId);
   $sentNote=($receipt['email_sent']??false)?' The receipt was emailed to '.$receipt['email_to'].'.':'';
   flash('Payment of '.money($settled['amount']).' recorded for order '.$r['order_number'].'.'.$sentNote.($receipt?receipts_copy_note($receipt):''));
   go('pos',['pay'=>$payId]);
   break;
 }
}

$openShift=row('SELECT * FROM shifts WHERE user_id=? AND status=\'open\'',[$u['id']]);

if(!$openShift){
 page_head('POS and Orders','pos','Point of sale');
 echo '<div class="panel" style="max-width:520px"><h2>Open a shift to begin</h2><p class="hint">Cashiers and waiters open a shift before taking orders or receiving payments.</p>';
 form_open('pos','shift');
 echo '<div class="field"><label>Outlet</label><select name="outlet"><option value="restaurant">Restaurant</option><option value="bar">Bar</option><option value="front_desk">Reception (Front desk)</option><option value="kitchen">Kitchen</option><option value="store">Store</option></select></div>';
 echo '<div class="field"><label>Opening cash (UGX)</label><input type="number" name="opening" value="0" min="0" step="500"></div>';
 echo '<button class="btn">Open shift</button>'; form_close();
 echo '</div>'; page_foot(); exit;
}

$outlet=$_GET['outlet']??'restaurant';
if(!in_array($outlet,['restaurant','bar','room_service'],true)) $outlet='restaurant';
$cats=rows('SELECT * FROM menu_categories WHERE outlet=? ORDER BY id',[$outlet]);
$items=rows('SELECT mi.*,mc.name cat FROM menu_items mi JOIN menu_categories mc ON mc.id=mi.category_id WHERE mc.outlet=? AND mi.active=1 ORDER BY mc.id,mi.name',[$outlet]);

page_head('POS and Orders','pos','Shift '.$openShift['outlet'].', opened '.fmtdt($openShift['opened_at']));
echo '<div class="flash ok" style="background:#fff8e6;color:#8a6200;border:1px solid #eeda9a;display:flex;justify-content:space-between;gap:12px;align-items:center"><span>Shift '.e($openShift['outlet']).' is open. Orders and payments are recorded against this shift.</span><a class="btnGhost sm" href="'.BASE.'/index.php?page=shifts">Cash up and close shift</a></div>';

echo '<div class="posWrap"><div>';
echo '<div class="panel"><h2>Take an order</h2><p class="hint">Pick an outlet, choose items and send to the kitchen.</p>';
form_open('pos','order');
echo '<div class="formRow">';
 echo '<div class="field"><label>Outlet</label><select name="outlet" onchange="location.href=\''.BASE.'/index.php?page=pos&outlet=\'+this.value"><option value="restaurant"'.checked($outlet,'restaurant').'>Restaurant</option><option value="bar"'.checked($outlet,'bar').'>Bar</option><option value="room_service"'.checked($outlet,'room_service').'>Room service</option></select></div>';
echo '<div class="field"><label>Order type</label><select name="order_type"><option value="table"'.checked('','1').'>Table</option><option value="room">Room service</option><option value="takeaway">Takeaway</option><option value="delivery">Delivery</option></select></div>';
 echo '<div class="field"><label>Table or room</label><input name="table_name" maxlength="60" placeholder="e.g. Table 4 or Room 12"></div>';
 echo '</div>';
 echo '<div class="menuCats">';
 $firstCat=(string)($cats[0]['name']??'');
 foreach($cats as $c){ echo '<button type="button" class="catBtn'.(($c['name']===$firstCat)?' on':'').'" data-cat="'.e($c['name']).'">'.e($c['name']).'</button>'; }
 echo '</div>';
echo '<div class="itemGrid">';
foreach($items as $it){ echo '<div class="itemCard cat_'.e($it['cat']).'" onclick="addItem(\''.$it['id'].'\',\''.e($it['name']).'\','.$it['price'].')"><div class="nm">'.e($it['name']).'</div><div class="pr">'.money($it['price']).'</div></div>'; }
echo '</div>';
echo '<div style="margin-top:18px"><h3>Cart</h3><div id="cart" style="background:#fbfaf6;border:1px solid var(--line);border-radius:12px;padding:14px"><p style="color:var(--muted);margin:0">Click items above to add them to the order.</p></div>';
if(hp_order_items_allow_custom()){
 echo '<div style="margin-top:16px;background:#f6f4ea;border:1px solid var(--line);border-radius:12px;padding:14px">';
 echo '<h3 style="margin:0 0 4px">Custom item or special request</h3><p class="hint" style="margin:0 0 12px">For something a guest asks for that is not on the menu. It prints on the kitchen docket, the bill and the receipt beside the menu lines.</p>';
 echo '<div class="formRow">';
 echo '<div class="field"><label for="customName">Item</label><input id="customName" maxlength="190" placeholder="e.g. Grilled tilapia, off menu"></div>';
 echo '<div class="field"><label for="customPrice">Price (UGX)</label><input id="customPrice" type="number" min="0.01" step="0.01" placeholder="0.00"></div>';
 echo '<div class="field"><label for="customQty">Quantity</label><input id="customQty" type="number" min="0.01" max="999" step="0.01" value="1"></div>';
 echo '<div class="field"><label for="customNote">Kitchen note</label><input id="customNote" maxlength="500" placeholder="e.g. no onions"></div>';
 echo '</div>';
 echo '<button type="button" class="btnGhost" onclick="addCustom()">Add custom item</button>';
 echo '</div>';
}else{
 echo '<p class="hint" style="margin-top:14px">Custom items are available after the database update <b>2026-10-29_pos_custom_items.sql</b> is applied.</p>';
}
echo '<div class="field" style="margin-top:14px"><label>Notes</label><input name="notes" placeholder="Anything the kitchen should know"></div>';
echo '<button class="btn">Send order</button> <button type="button" class="btnGhost" onclick="clearCart()">Clear cart</button>'; form_close();
echo '</div></div>';

echo '<div class="panel"><h2>Today\'s orders</h2><p class="hint">Kitchen and service workflow.</p>';
$ordersToday=rows("SELECT o.*,(SELECT COALESCE(SUM(p.amount),0) FROM payments p WHERE p.order_id=o.id AND p.status='successful') paid
 FROM orders o WHERE DATE(o.created_at)=CURDATE() ORDER BY o.id DESC LIMIT 15");
// Fetch every order's lines in one pass instead of one query per order.
$linesBy=[];
if($ordersToday){
 $oids=array_map(fn($o)=>(int)$o['id'],$ordersToday);
 $oph=implode(',',array_fill(0,count($oids),'?'));
 foreach(rows("SELECT oi.order_id,".hp_order_item_name_sql().",oi.quantity FROM order_items oi LEFT JOIN menu_items mi ON mi.id=oi.menu_item_id WHERE oi.order_id IN($oph) ORDER BY oi.id",$oids) as $ln){
  $linesBy[(int)$ln['order_id']][]=$ln;
 }
}
echo '<div class="miniList">';
 foreach($ordersToday as $o){
  $itRows=$linesBy[(int)$o['id']]??[];
  $paid=(float)$o['paid'];
  $due=max(0.0,(float)$o['total']-$paid);
  $canCancel=$paid<=0.001 && $o['status']!=='cancelled';
  echo '<div class="li" style="flex-direction:column;align-items:stretch">';
  echo '<div style="display:flex;justify-content:space-between;gap:10px"><span><b>'.e($o['order_number']).'</b> &middot; '.e($o['outlet']).' &middot; '.e($o['order_type']).($o['table_name']?' &middot; '.e($o['table_name']):'').'<br><small>';
  $first=true; foreach($itRows as $i){ if(!$first) echo ', '; echo e($i['name']).' x'.(float)$i['quantity']; $first=false; } echo '</small></span><span style="text-align:right"><b>'.money($o['total']).'</b><br><small>Paid '.money($paid).' &middot; Due '.money($due).'</small><br>'.status_badge($o['status']).'</span></div>';
  echo '<div style="display:flex;gap:6px;flex-wrap:wrap;margin-top:8px">';
  if(in_array($o['status'],['pending'],true)){ echo '<form method="post" action="'.BASE.'/index.php?page=pos&amp;act=status">'.csrf_field().'<input type="hidden" name="oid" value="'.(int)$o['id'].'"><input type="hidden" name="nst" value="accepted"><button class="btn sm blue">Accept</button></form>'; }
  if($o['status']==='accepted'||$o['status']==='pending'){ echo '<form method="post" action="'.BASE.'/index.php?page=pos&amp;act=status">'.csrf_field().'<input type="hidden" name="oid" value="'.(int)$o['id'].'"><input type="hidden" name="nst" value="preparing"><button class="btn sm blue">Start preparing</button></form>'; }
  if($o['status']==='preparing'){ echo '<form method="post" action="'.BASE.'/index.php?page=pos&amp;act=status">'.csrf_field().'<input type="hidden" name="oid" value="'.(int)$o['id'].'"><input type="hidden" name="nst" value="ready"><button class="btn sm tick">Mark ready</button></form>'; }
  if($o['status']==='ready'){ echo '<form method="post" action="'.BASE.'/index.php?page=pos&amp;act=status">'.csrf_field().'<input type="hidden" name="oid" value="'.(int)$o['id'].'"><input type="hidden" name="nst" value="served"><button class="btn sm">Mark served</button></form>'; }
  if($due>0.001 && $o['status']!=='cancelled'){ echo '<a class="btn sm" href="#settle'.(int)$o['id'].'" onclick="document.getElementById(\'settle'.(int)$o['id'].'\').hidden=false">Take payment</a>'; }
  echo '</div>';
  if($due>0.001 && $o['status']!=='cancelled'){
   echo '<div id="settle'.(int)$o['id'].'" hidden style="margin-top:10px;background:#f6f4ea;border:1px solid var(--line);border-radius:10px;padding:12px">';
   form_open('pos','settle',['oid'=>$o['id']]);
   echo '<div class="formRow">';
   echo '<div class="field"><label>Amount collected</label><input type="number" name="amount" value="'.number_format($due,2,'.','').'" min="0.01" step="0.01" required></div>';
   echo '<div class="field"><label>Discount</label><input type="number" name="discount" value="0" min="0" step="0.01"'.($paid>0?' disabled':'').'></div>';
   echo '<div class="field"><label>Method</label><select name="method">'; foreach(payment_methods() as $k=>$v) echo '<option value="'.e($k).'">'.e($v).'</option>'; echo '</select></div>';
   echo '<div class="field"><label>Payment reference</label><input name="reference" maxlength="190" placeholder="MoMo, card or bank reference"></div>';
   echo '<div class="field"><label>Payer phone</label><input name="payer_phone" maxlength="50" placeholder="Optional, for mobile money"></div>';
   echo '</div>';
   echo '<button class="btn tick">Record payment</button>'; form_close();
   echo '</div>';
  }
  if($canCancel){
   echo '<div style="margin-top:10px;background:#fdf1f0;border:1px solid #f2c9c5;border-radius:10px;padding:12px">';
   form_open('pos','status',['oid'=>$o['id']]);
   echo '<input type="hidden" name="nst" value="cancelled"><div style="display:flex;gap:6px;margin-top:0"><input name="reason" maxlength="255" placeholder="Reason to cancel" style="flex:1;padding:8px 10px;border:1px solid var(--line);border-radius:8px" required><button class="btn sm danger" onclick="return confirm(\'Cancel this order?\')">Cancel order</button></div>'; form_close();
   echo '</div>';
  }elseif($o['status']!=='cancelled'){
   echo '<p class="hint" style="margin:9px 0 0">This order has payments. Reverse the payment before cancelling it.</p>';
  }
 }
if(!count($ordersToday)) echo '<p class="emptyLine">No orders yet this session.</p>';
echo '</div></div></div></div>';

echo <<<'POSJS'
<script>
var cart={};var cartEl=document.getElementById("cart");var customSeq=0;
function esc(v){var m={"&":"&amp;","<":"&lt;",">":"&gt;",'"':"&quot;","'":"&#39;"};return String(v).replace(/[&<>"']/g,function(c){return m[c];});}
function money(n){return Number(n).toLocaleString(undefined,{maximumFractionDigits:2});}
function addItem(id,name,price){var key="m"+id;if(!cart[key])cart[key]={kind:"menu",id:String(id),name:name,price:Number(price),qty:0};cart[key].qty++;drawCart();}
function addCustom(){
 var n=document.getElementById("customName"),p=document.getElementById("customPrice"),q=document.getElementById("customQty"),t=document.getElementById("customNote");
 var name=(n.value||"").trim(),price=parseFloat(p.value),qty=parseFloat(q.value),note=(t.value||"").trim();
 if(!name){alert("Give the custom item a name.");n.focus();return;}
 if(!isFinite(price)||price<=0){alert("Enter a price greater than zero.");p.focus();return;}
 if(!isFinite(qty)||qty<=0||qty>999){alert("Enter a quantity between 0.01 and 999.");q.focus();return;}
 cart["c"+(++customSeq)]={kind:"custom",name:name,price:price,qty:qty,note:note};
 n.value="";p.value="";q.value="1";t.value="";drawCart();n.focus();
}
function chg(key,d){if(cart[key]){cart[key].qty+=d;if(cart[key].qty<=0)delete cart[key];}drawCart();}
function clearCart(){cart={};drawCart();}
function drawCart(){cartEl.innerHTML="";
 var html="";var total=0;var keys=Object.keys(cart);
 if(!keys.length){cartEl.innerHTML="<p style=\"color:var(--muted);margin:0\">Click items above, or add a custom item, to start the order.</p>";return;}
 keys.forEach(function(key){
  var c=cart[key];total+=c.price*c.qty;
  var note=c.kind==="custom"&&c.note?"<div class=\"cartNote\">"+esc(c.note)+"</div>":"";
  html+="<div class=\"cartRow\"><span><b>"+esc(c.name)+"</b>"+(c.kind==="custom"?" <small class=\"badge\">Custom</small>":"")+" x "+c.qty+note+"</span><span>"+money(c.price*c.qty)+" <button type=\"button\" onclick=\"chg('"+key+"',-1)\">&#8722;</button> <button type=\"button\" onclick=\"chg('"+key+"',1)\">+</button></span></div>";
  if(c.kind==="custom"){
   html+="<input type=\"hidden\" name=\"custom_name[]\" value=\""+esc(c.name)+"\">"
    +"<input type=\"hidden\" name=\"custom_price[]\" value=\""+esc(c.price)+"\">"
    +"<input type=\"hidden\" name=\"custom_qty[]\" value=\""+esc(c.qty)+"\">"
    +"<input type=\"hidden\" name=\"custom_note[]\" value=\""+esc(c.note)+"\">";
  }else{
   html+="<input type=\"hidden\" name=\"items["+esc(c.id)+"]\" value=\""+esc(c.qty)+"\">";
  }
 });
 var service=Math.round(total*0.035);
 html+="<div class=\"totals\"><div class=\"tt\"><span>Subtotal</span><b>"+money(total)+" UGX</b></div>";
 html+="<div class=\"tt\" style=\"font-size:13px;font-weight:600\"><span>Service charge (3.5%)</span><b>"+money(service)+" UGX</b></div>";
 html+="<div class=\"tt\"><span>Total</span><b>"+money(total+service)+" UGX</b></div></div>";
 cartEl.innerHTML="<div class=\"cart\">"+html+"</div>";
}
var btns=document.querySelectorAll(".catBtn");
btns.forEach(function(b){ b.addEventListener("click",function(){
  btns.forEach(function(x){x.classList.remove("on");});
  b.classList.add("on");
  document.querySelectorAll(".itemCard").forEach(function(c){ c.style.display=(c.className.indexOf(b.dataset.cat)>-1||b.dataset.cat==="All")?"block":"none"; });
});});
</script>
POSJS;
require_once __DIR__.'/../app/receipts.php';
// A payment just taken in this session leaves a hotel copy for the printer and
// a fresh flag on it, so it prints by itself. A page opened any other way has
// no fresh receipt and prints nothing.
$payPrint=(int)($_GET['pay']??0);
if($payPrint>0) receipts_hotel_template($payPrint,true);
receipt_print('pos');
page_foot();