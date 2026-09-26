<?php
declare(strict_types=1);

$d1=trim($_GET['from']??date('Y-m-d',strtotime('-14 days')));
$d2=trim($_GET['to']??today());
if($d2<$d1){ $tmp=$d1; $d1=$d2; $d2=$tmp; }

$nights=rows("SELECT DATE(check_in) d, COUNT(*) b, COALESCE(SUM(nights),0) room_nights FROM reservations WHERE DATE(check_in) BETWEEN ? AND ? AND status NOT IN('cancelled','no_show') GROUP BY DATE(check_in) ORDER BY d",[$d1,$d2]);
$totalNights=array_sum(array_map(fn($r)=>(int)$r['room_nights'],$nights));
$occupancy=min(100,round($totalNights/(69*count($nights))*100,1));

$byMethod=rows("SELECT method,COUNT(*) cnt,SUM(amount) total FROM payments WHERE status='successful' AND DATE(created_at) BETWEEN ? AND ? GROUP BY method ORDER BY total DESC",[$d1,$d2]);
$bySource=rows("SELECT r.source,COUNT(*) cnt,SUM(r.total) total FROM reservations r WHERE DATE(r.created_at) BETWEEN ? AND ? AND status NOT IN('cancelled') GROUP BY r.source ORDER BY total DESC",[$d1,$d2]);
$byDept=rows("SELECT d.name,SUM(e.amount) total FROM expenses e JOIN departments d ON d.id=e.department_id WHERE DATE(e.created_at) BETWEEN ? AND ? AND status IN('paid','approved') GROUP BY d.name ORDER BY total DESC",[$d1,$d2]);
$sold=rows("SELECT rt.name,COUNT(*) bookings FROM reservations r JOIN reservation_rooms rr ON rr.reservation_id=r.id JOIN room_types rt ON rt.id=rr.room_type_id WHERE DATE(r.created_at) BETWEEN ? AND ? AND r.status NOT IN('cancelled','no_show') GROUP BY rt.name ORDER BY bookings DESC",[$d1,$d2]);

$revTotal=array_sum(array_map(fn($m)=>(float)$m['total'],$byMethod));

page_head('Reports','reports','Management reporting and export');
echo '<div class="panel reports"><h2>Report period</h2><p class="hint">Choose a date range and the figures regenerate below.</p>';
echo '<form method="get" style="display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end"><input type="hidden" name="page" value="reports">';
echo '<label style="font-size:12px;color:var(--muted)">From <input type="date" name="from" value="'.e($d1).'" style="display:block;margin-top:5px;padding:9px;border:1px solid var(--line);border-radius:9px"></label>';
echo '<label style="font-size:12px;color:var(--muted)">To <input type="date" name="to" value="'.e($d2).'" style="display:block;margin-top:5px;padding:9px;border:1px solid var(--line);border-radius:9px"></label>';
echo '<button class="btn">Run report</button> <button class="btnGhost" onclick="window.print();return false">Print</button></form></div>';

echo '<div class="kpis">';
kpi_card('Bookings made',$nights?(string)array_sum(array_map(fn($n)=>(int)$n['b'],$nights)):'0','In selected period','blue');
kpi_card('Room nights',(string)$totalNights,'Sold in period');
kpi_card('Occupancy',(string)$occupancy.'%','Estimated average','gold');
kpi_card('Sales value',money($revTotal),'Successful payments');
echo '</div>';

echo '<div class="twoCol"><div>';
echo '<div class="panel"><h2>Revenue by payment method</h2><p class="hint">'.date('d M Y',strtotime($d1)).' to '.date('d M Y',strtotime($d2)).'</p>';
echo '<table class="tbl"><thead><tr><th>Method</th><th class="num">Transactions</th><th class="num">Total</th></tr></thead><tbody>';
foreach($byMethod as $m){ echo '<tr><td>'.e(ucfirst(str_replace('_',' ',$m['method']))).'</td><td class="num">'.(int)$m['cnt'].'</td><td class="num">'.money($m['total']).'</td></tr>'; }
echo '<tr><td><b>Total</b></td><td></td><td class="num"><b>'.money($revTotal).'</b></td></tr>';
echo '</tbody></table></div>';

echo '<div class="panel"><h2>Sales by room type</h2><p class="hint">Where bookings are landing.</p>';
echo '<table class="tbl"><thead><tr><th>Room type</th><th class="num">Bookings</th></tr></thead><tbody>';
foreach($sold as $s){ echo '<tr><td>'.e($s['name']).'</td><td class="num">'.(int)$s['bookings'].'</td></tr>'; }
if(!count($sold)) echo '<tr><td colspan="2" style="text-align:center;color:var(--muted)">No bookings in the period.</td></tr>';
echo '</tbody></table></div></div>';

echo '<div>';
echo '<div class="panel"><h2>Bookings by source</h2><p class="hint">Website, walk in, phone, email or agent.</p>';
echo '<table class="tbl"><thead><tr><th>Source</th><th class="num">Bookings</th><th class="num">Value</th></tr></thead><tbody>';
foreach($bySource as $s){ echo '<tr><td>'.e(ucfirst($s['source'])).'</td><td class="num">'.(int)$s['cnt'].'</td><td class="num">'.money($s['total']).'</td></tr>'; }
if(!count($bySource)) echo '<tr><td colspan="3" style="text-align:center;color:var(--muted)">No bookings in the period.</td></tr>';
echo '</tbody></table></div>';

echo '<div class="panel"><h2>Expenditure by department</h2><p class="hint">Approved and paid expenses.</p>';
echo '<table class="tbl"><thead><tr><th>Department</th><th class="num">Spent</th></tr></thead><tbody>';
foreach($byDept as $d){ echo '<tr><td>'.e($d['name']).'</td><td class="num">'.money($d['total']).'</td></tr>'; }
if(!count($byDept)) echo '<tr><td colspan="2" style="text-align:center;color:var(--muted)">No expenses in the period.</td></tr>';
echo '</tbody></table></div></div></div>';
page_foot();