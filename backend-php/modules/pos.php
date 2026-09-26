<?php
declare(strict_types=1);

$act=$_GET['act']??'';
$u=current_user();

if($_SERVER['REQUEST_METHOD']==='POST'){
 switch($act){
  case 'shift':
   $outlet=$_POST['outlet']??'restaurant';
   $r=row('SELECT id FROM shifts WHERE user_id=? AND status=\'open\'',[$u['id']]);
   if($r){ flash('You already have an open shift.','warn'); go('pos'); }
   q('INSERT INTO shifts(hotel_id,user_id,outlet,opened_at,opening_cash) VALUES(1,?,?,NOW(),?)',[$u['id'],$outlet,(float)($_POST['opening']??0)]);
   audit('open_shift','shift',(int)db()->lastInsertId(),['outlet'=>$outlet]);
   flash('Shift opened.');
   go('pos');
   break;
  case 'order':
   $outlet=$_POST['outlet']??'restaurant';
   $otype=$_POST['order_type']??'table';
   $items=$_POST['items']??[];
   if(!count($items)){ flash('Add at least one item to the order.','bad'); go('pos'); }
   $shift=row('SELECT id FROM shifts WHERE user_id=? AND status=\'open\'',[$u['id']]);
   $num=next_number('ORD','orders','order_number');
   $sub=0;
   foreach($items as $iid=>$qty){ $total=0;
     if(is_array($qty)){ foreach($qty as $unit) $total+=(float)$unit; $qty=$total; }
     if((float)$qty<=0) continue;
     $it=row('SELECT price FROM menu_items WHERE id=? AND active=1',[(int)$iid]);
     if(!$it) continue;
     $sub+=$it['price']*(float)$qty;
   }
   q('INSERT INTO orders(hotel_id,user_id,shift_id,order_number,outlet,order_type,table_name,status,subtotal,tax,total,created_at) VALUES(1,?,?,?,?,?,?,\'pending\',?,0,?,NOW())',
     [$u['id'],$shift['id']??null,$num,$outlet,$otype,trim($_POST['table_name']??''),$sub,$sub]);
   $oid=(int)db()->lastInsertId();
   foreach($items as $iid=>$qty){
    if(is_array($qty)){ $qty=array_sum($qty); }
    if((float)$qty<=0) continue;
    $it=row('SELECT price,name FROM menu_items WHERE id=? AND active=1',[(int)$iid]);
    if(!$it) continue;
    q('INSERT INTO order_items(order_id,menu_item_id,quantity,unit_price,total) VALUES(?,?,?,?,?)',[$oid,(int)$iid,(float)$qty,$it['price'],$it['price']*(float)$qty]);
    audit('order_item','menu_item',(int)$iid,['order'=>$oid,'qty'=>(float)$qty]);
   }
   audit('create','order',$oid,['number'=>$num]);
   flash('Order '.$num.' sent to the kitchen or service area.');
   go('pos');
   break;
  case 'status':
   $oid=(int)($_POST['oid']??0); $nst=$_POST['nst']??'';
   $r=row('SELECT status,order_number FROM orders WHERE id=?',[$oid]); if(!$r) break;
   $map=['accepted','preparing','ready','served','cancelled'];
   if(in_array($nst,$map)){
    if($nst==='cancelled' && !trim($_POST['reason']??'')){ flash('A reason is required to cancel an order.','bad'); go('pos'); }
    if($nst==='cancelled'){
     q('INSERT INTO voids(hotel_id,ref_type,ref_id,reason,amount,user_id,created_at) VALUES(1,\'order\',?,?,?,?,NOW())',[$oid,trim($_POST['reason']),abs($r['status']==='pending'?0:val('SELECT SUM(total) FROM order_items WHERE order_id=?',[$oid])),$u['id']]);
    }
    q('UPDATE orders SET status=? WHERE id=?',[$nst,$oid]);
    audit('order_status','order',$oid,['status'=>$r['status']],['status'=>$nst]);
    flash('Order '.$r['order_number'].' updated to '.$nst.'.');
   }
   go('pos');
   break;
  case 'settle':
   $oid=(int)($_POST['oid']??0);
   $r=row('SELECT * FROM orders WHERE id=?',[$oid]); if(!$r) break;
   $discount=(float)($_POST['discount']??0);
   $method=$_POST['method']??'cash';
   $due=$r['total']-$discount;
   $paidNow=(float)($_POST['amount']??$due);
   $grandPaid=(float)$r['subtotal']>0?0:0;
   if($paidNow>0){
    q('INSERT INTO payments(hotel_id,user_id,order_id,amount,method,status,created_at) VALUES(1,?,?,?,?,\'successful\',NOW())',[$u['id'],$oid,$paidNow,$method]);
    audit('payment','order',$oid,['amount'=>$paidNow,'method'=>$method]);
    q('UPDATE orders SET discount=?,subtotal=?,total=? WHERE id=?',[$discount,$r['subtotal'],$due,$oid]);
    $tot=val('SELECT COALESCE(SUM(amount),0) FROM payments WHERE order_id=? AND status=\'successful\'',[$oid]);
    q('UPDATE orders SET status=? WHERE id=?',[$tot>=$due?'paid':'partially_paid',$oid]);
    flash('Payment of '.money($paidNow).' recorded for order '.$r['order_number'].'.');
   } else { flash('Enter the amount collected.','bad'); }
   go('pos');
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
$cats=rows('SELECT * FROM menu_categories WHERE outlet=? ORDER BY id',[$outlet]);
$items=rows('SELECT mi.*,mc.name cat FROM menu_items mi JOIN menu_categories mc ON mc.id=mi.category_id WHERE mc.outlet=? AND mi.active=1 ORDER BY mc.id,mi.name',[$outlet]);

page_head('POS and Orders','pos','Shift '.$openShift['outlet'].', opened '.fmtdt($openShift['opened_at']));
echo '<div class="flash ok" style="background:#fff8e6;color:#8a6200;border:1px solid #eeda9a">Shift '.e($openShift['outlet']).' is open. Orders and payments are recorded against this shift.</div>';

echo '<div class="posWrap"><div>';
echo '<div class="panel"><h2>Take an order</h2><p class="hint">Pick an outlet, choose items and send to the kitchen.</p>';
form_open('pos','order');
echo '<div class="formRow">';
echo '<div class="field"><label>Outlet</label><select name="outlet" onchange="location.href=\''.BASE.'/index.php?page=pos&outlet=\'+this.value"><option value="restaurant"'.checked($outlet,'restaurant').'>Restaurant</option><option value="bar"'.checked($outlet,'bar').'>Bar</option><option value="front_desk"'.checked($outlet,'front_desk').'>Reception (Front desk)</option><option value="kitchen"'.checked($outlet,'kitchen').'>Kitchen</option><option value="store"'.checked($outlet,'store').'>Store</option></select></div>';
echo '<div class="field"><label>Order type</label><select name="order_type"><option value="table"'.checked('','1').'>Table</option><option value="room">Room service</option><option value="takeaway">Takeaway</option><option value="delivery">Delivery</option></select></div>';
echo '<div class="field"><label>Table name</label><input name="table_name" placeholder="e.g. Table 4"></div>';
echo '</div>';
echo '<div class="menuCats">';
$cur=null;
foreach($cats as $c){ $activeCat=($c['id']==($cur??0)); }
foreach($cats as $c){ echo '<button type="button" class="catBtn'.(($c['name']===$cats[0]['name'])?' on':'').'" data-cat="'.e($c['name']).'">'.e($c['name']).'</button>'; }
echo '</div>';
echo '<div class="itemGrid">';
foreach($items as $it){ echo '<div class="itemCard cat_'.e($it['cat']).'" onclick="addItem(\''.$it['id'].'\',\''.e($it['name']).'\','.$it['price'].')"><div class="nm">'.e($it['name']).'</div><div class="pr">'.money($it['price']).'</div></div>'; }
echo '</div>';
echo '<div style="margin-top:18px"><h3>Cart</h3><div id="cart" style="background:#fbfaf6;border:1px solid var(--line);border-radius:12px;padding:14px"><p style="color:var(--muted);margin:0">Click items above to add them to the order.</p></div>';
echo '<div class="field" style="margin-top:14px"><label>Notes</label><input name="notes" placeholder="Anything the kitchen should know"></div>';
echo '<button class="btn">Send order</button> <button type="button" class="btnGhost" onclick="clearCart()">Clear cart</button>'; form_close();
echo '</div></div>';

echo '<div class="panel"><h2>Today\'s orders</h2><p class="hint">Kitchen and service workflow.</p>';
$ordersToday=rows('SELECT o.* FROM orders o ORDER BY o.id DESC LIMIT 15');
echo '<div class="miniList">';
foreach($ordersToday as $o){
 $itRows=rows('SELECT mi.name,oi.quantity FROM order_items oi JOIN menu_items mi ON mi.id=oi.menu_item_id WHERE oi.order_id=?',[$o['id']]);
 echo '<div class="li" style="flex-direction:column;align-items:stretch">';
 echo '<div style="display:flex;justify-content:space-between;gap:10px"><span><b>'.e($o['order_number']).'</b> &middot; '.e($o['outlet']).' &middot; '.e($o['order_type']).($o['table_name']?' &middot; '.e($o['table_name']):'').'<br><small style="color:var(--muted)">';
 $first=true; foreach($itRows as $i){ if(!$first) echo ', '; echo e($i['name']).' x'.(float)$i['quantity']; $first=false; } echo '</small></span><b>'.money($o['total']).'</b>'.status_badge($o['status']).'</div>';
 echo '<div style="display:flex;gap:6px;flex-wrap:wrap;margin-top:8px">';
 if(in_array($o['status'],['pending'])){ echo '<form method="post" action="'.BASE.'/index.php?page=pos&amp;act=status"><input type="hidden" name="oid" value="'.(int)$o['id'].'"><input type="hidden" name="nst" value="accepted"><button class="btn sm blue">Accept</button></form>'; }
 if($o['status']==='accepted'||$o['status']==='pending'){ echo '<form method="post" action="'.BASE.'/index.php?page=pos&amp;act=status"><input type="hidden" name="oid" value="'.(int)$o['id'].'"><input type="hidden" name="nst" value="preparing"><button class="btn sm blue">Start preparing</button></form>'; }
 if($o['status']==='preparing'){ echo '<form method="post" action="'.BASE.'/index.php?page=pos&amp;act=status"><input type="hidden" name="oid" value="'.(int)$o['id'].'"><input type="hidden" name="nst" value="ready"><button class="btn sm tick">Mark ready</button></form>'; }
 if($o['status']==='ready'){ echo '<form method="post" action="'.BASE.'/index.php?page=pos&amp;act=status"><input type="hidden" name="oid" value="'.(int)$o['id'].'"><input type="hidden" name="nst" value="served"><button class="btn sm">Mark served</button></form>'; }
 if(in_array($o['status'],['pending','ready','served','preparing','accepted'])){ echo '<a class="btn sm" href="#settle'.(int)$o['id'].'" onclick="document.getElementById(\'settle'.(int)$o['id'].'\').hidden=false">Settle</a>'; }
 echo '</div>';
 echo '<div id="settle'.(int)$o['id'].'" hidden style="margin-top:10px;background:#f6f4ea;border:1px solid var(--line);border-radius:10px;padding:12px">';
 form_open('pos','settle',['oid'=>$o['id']]);
 echo '<div class="formRow">';
 echo '<div class="field"><label>Amount collected</label><input type="number" name="amount" value="'.(int)$o['total'].'" step="100"></div>';
 echo '<div class="field"><label>Discount</label><input type="number" name="discount" value="0" step="100"></div>';
 echo '<div class="field"><label>Method</label><select name="method">'; foreach(payment_methods() as $k=>$v) echo '<option value="'.$k.'">'.$v.'</option>'; echo '</select></div></div>';
 echo '<button class="btn tick">Record payment</button>'; form_close();
 form_open('pos','status',['oid'=>$o['id']]);
 echo '<input type="hidden" name="nst" value="cancelled"><div style="display:flex;gap:6px;margin-top:8px"><input name="reason" placeholder="Reason to cancel" style="flex:1;padding:8px 10px;border:1px solid var(--line);border-radius:8px"><button class="btn sm danger" onclick="return confirm(\'Cancel this order?\')">Cancel order</button></div>'; form_close();
 echo '</div></div>';
}
if(!count($ordersToday)) echo '<p style="color:var(--muted)">No orders yet this session.</p>';
echo '</div></div></div></div>';

echo '<script>
var cart={};var cartEl=document.getElementById("cart");
function addItem(id,name,price){ if(!cart[id]) cart[id]={name:name,price:price,qty:0}; cart[id].qty++; drawCart(); }
function chg(id,d){ if(cart[id]){ cart[id].qty+=d; if(cart[id].qty<=0) delete cart[id]; } drawCart(); }
function clearCart(){ cart={}; drawCart(); }
function drawCart(){ cartEl.innerHTML="";
 var html=""; var total=0; var keys=Object.keys(cart);
 if(!keys.length){ cartEl.innerHTML="<p style=\\"color:var(--muted);margin:0\\">Click items above to add them to the order.</p>"; return; }
 keys.forEach(function(id){ var c=cart[id]; total+=c.price*c.qty;
  html+="<div class=\\"cartRow\\"><span><b>"+c.name+"</b> x "+c.qty+"</span><span>"+(c.price*c.qty).toLocaleString()+" <button type=\\"button\\" onclick=\\"chg("+id+",-1)\\">&#8722;</button> <button type=\\"button\\" onclick=\\"chg("+id+",1)\\">+</button></span></div>";
  html+="<input type=\\"hidden\\" name=\\"items["+id+"]\\" value=\\""+c.qty+"\\">";
 });
 html+="<div class=\\"totals\\"><div class=\\"tt\\"><span>Total</span><b>"+total.toLocaleString()+" UGX</b></div></div>";
 cartEl.innerHTML="<div class=\\"cart\\">"+html+"</div>";
}
var btns=document.querySelectorAll(".catBtn");
btns.forEach(function(b){ b.addEventListener("click",function(){
  btns.forEach(function(x){x.classList.remove("on");});
  b.classList.add("on");
  document.querySelectorAll(".itemCard").forEach(function(c){ c.style.display=(c.className.indexOf(b.dataset.cat)>-1||b.dataset.cat==="All")?"block":"none"; });
});});
</script>';
page_foot();