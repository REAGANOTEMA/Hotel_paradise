<?php
declare(strict_types=1);

/*
 * The restaurant's own dashboard.
 *
 * The restaurant sells from the same menu and writes the same orders as the
 * bar, with outlet='restaurant'. This page brings that outlet into one view:
 * what is waiting, what has been sold today, what is on the restaurant list,
 * and the shift the member is carrying. It writes nothing itself - the POS, the
 * F&B till and Shifts own the transactions - so opening it can never change a
 * bill.
 */

$u=current_user();
$day0=today().' 00:00:00';
$day1=date('Y-m-d',strtotime(today().' +1 day')).' 00:00:00';

$ordersToday=rows(
 "SELECT o.*,
   (SELECT COALESCE(SUM(p.amount),0) FROM payments p WHERE p.order_id=o.id AND p.status='successful') paid
  FROM orders o
  WHERE o.outlet='restaurant' AND o.deleted_at IS NULL AND o.created_at>=? AND o.created_at<?
  ORDER BY o.id DESC LIMIT 20",[$day0,$day1]
);

$open=rows(
 "SELECT o.*,
   (SELECT COALESCE(SUM(p.amount),0) FROM payments p WHERE p.order_id=o.id AND p.status='successful') paid
  FROM orders o
  WHERE o.outlet='restaurant' AND o.deleted_at IS NULL AND o.status IN('pending','accepted','preparing','ready')
  ORDER BY o.id ASC LIMIT 20",[]
);

$k=[
 'orders'=>count($ordersToday),
 'sales'=>array_sum(array_map(static fn(array $o): float=>(float)$o['total'],$ordersToday)),
 'collected'=>array_sum(array_map(static fn(array $o): float=>(float)$o['paid'],$ordersToday)),
 'open'=>count($open),
 'menu'=>(int)val("SELECT COUNT(*) FROM menu_items mi JOIN menu_categories mc ON mc.id=mi.category_id WHERE mc.outlet='restaurant' AND mi.active=1",[]),
 'shifts'=>(int)val("SELECT COUNT(*) FROM shifts WHERE outlet='restaurant' AND status='open'",[]),
];
$owed=count(array_filter($ordersToday,static fn(array $o): bool=>(float)$o['paid']+0.001<(float)$o['total']));

$linesBy=[];
$allIds=array_values(array_unique(array_merge(
 array_map(static fn(array $o): int=>(int)$o['id'],$ordersToday),
 array_map(static fn(array $o): int=>(int)$o['id'],$open)
)));
if($allIds){
 $ph=implode(',',array_fill(0,count($allIds),'?'));
 foreach(rows("SELECT oi.order_id,oi.quantity,".hp_order_item_name_sql()." FROM order_items oi LEFT JOIN menu_items mi ON mi.id=oi.menu_item_id WHERE oi.order_id IN($ph) ORDER BY oi.id",$allIds) as $ln){
  $linesBy[(int)$ln['order_id']][]=$ln;
 }
}

$customToday=0;
if(hp_order_items_allow_custom()){
 $customToday=(int)val("SELECT COUNT(*) FROM order_items oi JOIN orders o ON o.id=oi.order_id
  WHERE oi.custom_name IS NOT NULL AND oi.custom_name<>'' AND o.outlet='restaurant'
  AND o.created_at>=? AND o.created_at<?",[$day0,$day1]);
}

$myShift=row("SELECT * FROM shifts WHERE user_id=? AND status='open' ORDER BY id DESC LIMIT 1",[$u['id']]);
$menuCats=rows("SELECT mc.name,COUNT(mi.id) items,MIN(mi.price) low,MAX(mi.price) high
 FROM menu_categories mc LEFT JOIN menu_items mi ON mi.category_id=mc.id AND mi.active=1
 WHERE mc.outlet='restaurant' GROUP BY mc.id,mc.name ORDER BY mc.id",[]);

page_head('Restaurant Dashboard','restaurant',date('l, j F Y').' · the restaurant');

echo '<div class="kpis">';
kpi_card('Restaurant orders today',(string)$k['orders'],'Across the restaurant outlet');
kpi_card('Restaurant sales today',money($k['sales']),'Billed, before payment',$k['sales']?'green':'navy');
kpi_card('Collected today',money($k['collected']),'Successful payments',$k['collected']?'green':'navy');
kpi_card('Waiting now',(string)$k['open'],'Orders still in service',$k['open']?'gold':'navy');
kpi_card('Still to settle',(string)$owed,'Restaurant bills not paid in full',$owed?'warn':'navy');
kpi_card('On the restaurant list',(string)$k['menu'],'Active dishes and drinks');
kpi_card('Custom requests today',(string)$customToday,'Lines written off menu',$customToday?'blue':'navy');
kpi_card('Open restaurant shifts',(string)$k['shifts'],'Shifts being carried',$k['shifts']?'blue':'navy');
echo '</div>';

echo '<div class="toolbar"><div class="bar">';
echo '<a class="btn sm" href="'.BASE.'/index.php?page=pos&amp;outlet=restaurant">Take a restaurant order</a>';
echo '<a class="btnGhost sm" href="'.BASE.'/index.php?page=fnb&amp;outlet=restaurant">Restaurant bills and payments</a>';
echo '<a class="btnGhost sm" href="'.BASE.'/index.php?page=shifts">Shifts and cash up</a>';
if(page_allowed('inventory')) echo '<a class="btnGhost sm" href="'.BASE.'/index.php?page=inventory">Restaurant stock</a>';
echo '</div></div>';

echo '<div class="dashGrid"><div>';

echo '<div class="panel"><h2>Orders waiting in the restaurant</h2><p class="hint">Pending, accepted, preparing and ready restaurant orders.</p>';
if(!$open){
 echo '<p class="emptyLine">The restaurant has no orders waiting.</p>';
}else{
 echo '<table class="tbl"><thead><tr><th>Order</th><th>Service</th><th>Items</th><th class="num">Total</th><th>Status</th><th></th></tr></thead><tbody>';
 foreach($open as $o){
  $oid=(int)$o['id'];
  $names=[];
  foreach($linesBy[$oid]??[] as $ln) $names[]=$ln['name'].' x'.rtrim(rtrim(number_format((float)$ln['quantity'],2,'.',''),'0'),'.');
  echo '<tr><td><b>'.e($o['order_number']).'</b><br><small>'.date('H:i',strtotime((string)$o['created_at'])).'</small></td>';
  echo '<td>'.e($o['order_type']==='room'?'Room service':ucfirst((string)$o['order_type'])).($o['table_name']?'<br><small>'.e((string)$o['table_name']).'</small>':'').'</td>';
  echo '<td>'.e(implode(', ',array_slice($names,0,3))).(count($names)>3?' &hellip;':'').'</td>';
  echo '<td class="num">'.money($o['total']).'</td><td>'.status_badge($o['status']).'</td>';
  echo '<td><a class="btnGhost sm" href="'.BASE.'/index.php?page=fnb&amp;view='.$oid.'">Open bill</a></td></tr>';
 }
 echo '</tbody></table>';
}
echo '</div>';

echo '<div class="panel"><h2>Restaurant orders today</h2><p class="hint">Every restaurant order placed today, newest first.</p>';
if(!$ordersToday){
 echo '<p class="emptyLine">No restaurant orders have been placed today yet.</p>';
}else{
 echo '<table class="tbl"><thead><tr><th>Order</th><th>Time</th><th>Service</th><th class="num">Total</th><th class="num">Paid</th><th>Status</th><th></th></tr></thead><tbody>';
 foreach($ordersToday as $o){
  $oid=(int)$o['id']; $paid=(float)$o['paid'];
  echo '<tr><td><b>'.e($o['order_number']).'</b></td><td>'.date('H:i',strtotime((string)$o['created_at'])).'</td>';
  echo '<td>'.e($o['order_type']==='room'?'Room service':ucfirst((string)$o['order_type'])).($o['table_name']?' &middot; '.e((string)$o['table_name']):'').'</td>';
  echo '<td class="num">'.money($o['total']).'</td>';
  echo '<td class="num" style="'.($paid+0.001>=(float)$o['total']?'color:#2e7d32':($paid>0?'color:#b26a00':'color:#c62828')).'">'.money($paid).'</td>';
  echo '<td>'.status_badge($o['status']).'</td>';
  echo '<td><a class="btnGhost sm" href="'.BASE.'/index.php?page=fnb&amp;view='.$oid.'">Open</a></td></tr>';
 }
 echo '</tbody></table>';
}
echo '</div></div>';

echo '<div>';
echo '<div class="panel"><h2>Your shift</h2>';
if($myShift){
 echo '<p class="hint">'.e(ucfirst((string)$myShift['outlet'])).' shift opened '.fmtdt((string)$myShift['opened_at']).', opening cash '.money($myShift['opening_cash']).'.</p>';
 echo '<a class="btn sm" href="'.BASE.'/index.php?page=shifts">Close or review the shift</a>';
}else{
 echo '<p class="emptyLine">You have no open shift. Open one at the till before taking orders or payments.</p>';
 echo '<a class="btn sm" href="'.BASE.'/index.php?page=pos&amp;outlet=restaurant">Open the restaurant till</a>';
}
echo '</div>';

echo '<div class="panel"><h2>On the restaurant list</h2><p class="hint">The active dishes and drinks, by section.</p>';
if(!$menuCats){
 echo '<p class="emptyLine">The restaurant menu is empty. Add items in Food and Beverage.</p>';
}else{
 echo '<div class="miniList">';
 foreach($menuCats as $mc){
  echo '<div class="li"><span><b>'.e($mc['name']).'</b><br><small>'.(int)$mc['items'].' item'.((int)$mc['items']===1?'':'s').'</small></span>';
  if((int)$mc['items']>0) echo '<b>'.money($mc['low']).' &ndash; '.money($mc['high']).'</b>';
  echo '</div>';
 }
 echo '</div>';
 echo '<div style="margin-top:12px"><a class="btnGhost sm" href="'.BASE.'/index.php?page=fnb&amp;outlet=restaurant">Open restaurant bills</a></div>';
}
echo '</div>';
echo '</div></div>';

page_foot();
