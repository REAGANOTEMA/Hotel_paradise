<?php
declare(strict_types=1);

$t=today();
// A day as a half-open range (00:00:00 today up to, not including, 00:00:00
// tomorrow). Written as a range rather than DATE(created_at)=? so MySQL can
// use the index on the column instead of scanning the whole table.
$day0=$t.' 00:00:00';
$day1=date('Y-m-d',strtotime($t.' +1 day')).' 00:00:00';
$k=[
 'arrivals'=>val("SELECT COUNT(*) FROM reservations WHERE status IN('pending','confirmed') AND check_in>=? AND check_in<?",[$day0,$day1]),
 'inhouse'=>val("SELECT COUNT(*) FROM rooms WHERE status='occupied'"),
 'avail'=>val("SELECT COUNT(*) FROM rooms WHERE status='available'"),
 'depart'=>val("SELECT COUNT(*) FROM reservations WHERE status='checked_in' AND check_out>=? AND check_out<?",[$day0,$day1]),
 'rev'=>val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=? AND created_at<?",[$day0,$day1]),
 'pend'=>val("SELECT COUNT(*) FROM expenses WHERE status='pending'",[])+val("SELECT COUNT(*) FROM purchase_requisitions WHERE status='pending'",[]),
 'low'=>val("SELECT COUNT(*) FROM stock_levels sl JOIN inventory_items i ON i.id=sl.item_id WHERE sl.quantity<=i.reorder_level AND i.active=1",[]),
];
$arrivals=rows("SELECT r.id,r.booking_number,g.full_name,rt.name rtype,r.adults FROM reservations r JOIN guests g ON g.id=r.guest_id JOIN reservation_rooms rr ON rr.reservation_id=r.id JOIN room_types rt ON rt.id=rr.room_type_id WHERE r.status IN('pending','confirmed') AND r.check_in>=? AND r.check_in<? ORDER BY r.check_in",[$day0,$day1]);
$inhouse=rows("SELECT r.id,g.full_name,rt.name rtype,rr.room_id,rn.room_number FROM reservations r JOIN guests g ON g.id=r.guest_id JOIN reservation_rooms rr ON rr.reservation_id=r.id JOIN room_types rt ON rt.id=rr.room_type_id LEFT JOIN rooms rn ON rn.id=rr.room_id WHERE r.status='checked_in' ORDER BY g.full_name");
$payments=rows("SELECT p.id,p.amount,p.method,p.status,DATE(p.created_at) d,u.name usr FROM payments p LEFT JOIN users u ON u.id=p.user_id WHERE p.created_at>=? AND p.created_at<? ORDER BY p.id DESC LIMIT 8",[$day0,$day1]);
$pend=rows("SELECT 'expense' kind,e.number ref,e.amount amount,e.department_name dept FROM (SELECT e.id,e.number,e.amount,d.name department_name FROM expenses e LEFT JOIN departments d ON d.id=e.department_id WHERE e.status='pending') e UNION ALL SELECT 'requisition',pr.number,0,d.name FROM purchase_requisitions pr LEFT JOIN departments d ON d.id=pr.department_id WHERE pr.status='pending' LIMIT 6",[]);

page_head('Dashboard','dashboard',date('l, j F Y'));
echo '<div class="kpis">';
kpi_card('Arrivals today',(string)$k['arrivals'],'Expected check ins');
kpi_card('In house',(string)$k['inhouse'],'Guests staying tonight');
kpi_card('Rooms available',(string)$k['avail'],'Of 69 rooms');
kpi_card('Departures today',(string)$k['depart'],'Check outs expected');
kpi_card('Revenue today',money($k['rev']),'Successful payments');
kpi_card('Pending approvals',(string)$k['pend'],'Expenses and requisitions');
kpi_card('Low stock items',(string)$k['low'],'At or below reorder level');
echo '</div>';

echo '<div class="dashGrid"><div>';
echo '<div class="panel"><h2>Expected arrivals today</h2><p class="hint">Pending and confirmed reservations due in today.</p>';
if(!$arrivals){ echo '<p class="emptyLine">No expected arrivals today.</p>'; }
else{ echo '<table class="tbl"><thead><tr><th>Booking</th><th>Guest</th><th>Room type</th><th>Guests</th><th></th></tr></thead><tbody>';
 foreach($arrivals as $r){ echo '<tr><td>'.e($r['booking_number']).'</td><td><b>'.e($r['full_name']).'</b></td><td>'.e($r['rtype']).'</td><td>'.(int)$r['adults'].'</td><td><a class="btn sm" href="'.BASE.'/index.php?page=reservations&view='.(int)$r['id'].'">View</a></td></tr>'; }
 echo '</tbody></table>'; }
echo '</div>';
echo '<div class="panel"><h2>In house now</h2><p class="hint">Guests currently occupying a room.</p>';
if(!$inhouse){ echo '<p class="emptyLine">No guests in house.</p>'; }
else{ echo '<table class="tbl"><thead><tr><th>Guest</th><th>Room type</th><th>Room</th></tr></thead><tbody>';
 foreach($inhouse as $r){ echo '<tr><td><b>'.e($r['full_name']).'</b></td><td>'.e($r['rtype']).'</td><td>'.e($r['room_number']??'Not allocated').'</td></tr>'; }
 echo '</tbody></table>'; }
echo '</div></div>';

echo '<div><div class="panel"><h2>Payments today</h2><p class="hint">Latest successful payments.</p>';
if(!$payments){ echo '<p class="emptyLine">No payments recorded yet today.</p>'; }
else{ echo '<div class="miniList">'; foreach($payments as $p){ echo '<div class="li"><span>'.e($p['usr']??'Walk in').'<br><small>'.e($p['method']).'</small></span><b>'.money($p['amount']).'</b></div>'; } echo '</div>'; }
echo '</div>';
echo '<div class="panel"><h2>Awaiting approval</h2><p class="hint">Expense requests and purchase requisitions.</p>';
if(!count($pend)){ echo '<p class="emptyLine">Everything is up to date.</p>'; }
else{ echo '<div class="miniList">'; foreach($pend as $p){ echo '<div class="li"><span>'.e($p['ref']).'<br><small>'.e(ucfirst($p['kind'])).'</small></span>'.($p['amount']>0?'<b>'.money($p['amount']).'</b>':'').'</div>'; } echo '</div><a class="btn sm" style="margin-top:12px" href="'.BASE.'/index.php?page=approvals">Review approvals</a>'; }
echo '</div></div></div>';

page_foot();