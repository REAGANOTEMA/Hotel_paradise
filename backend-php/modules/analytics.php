<?php
declare(strict_types=1);

function an_range(): array{
  $from=trim((string)($_GET['from']??date('Y-m-d',strtotime('-29 days'))));
  $to=trim((string)($_GET['to']??today()));
  if(!preg_match('/^\d{4}-\d{2}-\d{2}$/',$from)) $from=date('Y-m-d',strtotime('-29 days'));
  if(!preg_match('/^\d{4}-\d{2}-\d{2}$/',$to)) $to=today();
  if($from>$to){ $tmp=$from; $from=$to; $to=$tmp; }
  if((strtotime($to)-strtotime($from))/86400>365) $from=date('Y-m-d',strtotime($to.' -1 year'));
  return [$from.' 00:00:00',$to.' 23:59:59',$from,$to];
}

function an_csv(array $rows): void{
  header('Content-Type: text/csv; charset=utf-8');
  header('Content-Disposition: attachment; filename="hotel-analytics-'.date('Y-m-d').'.csv"');
  $out=fopen('php://output','w');
  foreach($rows as $r){
    $line=[];
    foreach($r as $v) $line[]='"'.str_replace('"','""',(string)$v).'"';
    fwrite($out,implode(',',$line)."\n");
  }
  fclose($out); exit;
}

[$fromTs,$toTs,$fromDay,$toDay]=an_range();
$type=$_GET['type']??'';
$roomDaily=rows("SELECT DATE(check_in) d,COUNT(*) bookings,SUM(total) revenue,SUM(paid) received FROM reservations WHERE check_in>=? AND check_in<=? AND status NOT IN('cancelled','no_show') AND deleted_at IS NULL GROUP BY DATE(check_in)",[$fromTs,$toTs]);
$payDaily=rows("SELECT DATE(created_at) d,SUM(amount) amount,COUNT(*) n FROM payments WHERE status='successful' AND created_at>=? AND created_at<=? GROUP BY DATE(created_at)",[$fromTs,$toTs]);
$posDaily=rows("SELECT DATE(created_at) d,SUM(total) amount,COUNT(*) n FROM pos_sales WHERE status='completed' AND created_at>=? AND created_at<=? GROUP BY DATE(created_at)",[$fromTs,$toTs]);
$daily=[];
foreach($roomDaily as $r) $daily[$r['d']]['rooms']=$r;
foreach($payDaily as $r) $daily[$r['d']]['payments']=$r;
foreach($posDaily as $r) $daily[$r['d']]['pos']=$r;
ksort($daily);
$dailyRows=[['Date','Room bookings','Room revenue','Payments received','POS sales','POS receipts']];
foreach($daily as $date=>$d) $dailyRows[]=[$date,$d['rooms']['bookings']??0,$d['rooms']['revenue']??0,$d['payments']['amount']??0,$d['pos']['amount']??0,$d['pos']['n']??0];
$paymentMix=rows("SELECT method,SUM(amount) amount,COUNT(*) n FROM payments WHERE status='successful' AND created_at>=? AND created_at<=? GROUP BY method ORDER BY amount DESC",[$fromTs,$toTs]);
$paymentRows=[['Method','Transactions','Amount']];
foreach($paymentMix as $p) $paymentRows[]=$p;

if($type==='daily') an_csv($dailyRows);
if($type==='payments') an_csv($paymentRows);

$days=max(1,(int)round((strtotime($toDay)-strtotime($fromDay))/86400)+1);
$roomRevenue=(float)val("SELECT COALESCE(SUM(total),0) FROM reservations WHERE check_in>=? AND check_in<=? AND status NOT IN('cancelled','no_show') AND deleted_at IS NULL",[$fromTs,$toTs]);
$roomNights=(float)val("SELECT COALESCE(SUM(r.nights*rr.quantity),0) FROM reservations r JOIN reservation_rooms rr ON rr.reservation_id=r.id WHERE r.check_in>=? AND r.check_in<=? AND r.status NOT IN('cancelled','no_show') AND r.deleted_at IS NULL",[$fromTs,$toTs]);
$availableRooms=(float)val('SELECT COUNT(*) FROM rooms WHERE deleted_at IS NULL');
$payments=(float)val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=? AND created_at<=?",[$fromTs,$toTs]);
$pos=(float)val("SELECT COALESCE(SUM(total),0) FROM pos_sales WHERE status='completed' AND created_at>=? AND created_at<=?",[$fromTs,$toTs]);
$expenses=(float)val("SELECT COALESCE(SUM(amount),0) FROM expenses WHERE status='paid' AND paid_at>=? AND paid_at<=? AND deleted_at IS NULL",[$fromTs,$toTs]);
$outstanding=(float)val("SELECT COALESCE(SUM(total-paid),0) FROM reservations WHERE status IN('pending','confirmed','checked_in') AND paid<total AND deleted_at IS NULL");
$invoiceDue=(float)val("SELECT COALESCE(SUM(total),0) FROM invoices WHERE status IN('issued','partially_paid') AND deleted_at IS NULL");
$sourceMix=rows("SELECT source,COUNT(*) bookings,SUM(total) value FROM reservations WHERE check_in>=? AND check_in<=? AND deleted_at IS NULL GROUP BY source ORDER BY value DESC",[$fromTs,$toTs]);
$expenseMix=rows("SELECT category,SUM(amount) amount,COUNT(*) n FROM expenses WHERE status='paid' AND paid_at>=? AND paid_at<=? AND deleted_at IS NULL GROUP BY category ORDER BY amount DESC",[$fromTs,$toTs]);
$housekeeping=(int)val("SELECT COUNT(*) FROM housekeeping_tasks WHERE status IN('completed','verified') AND COALESCE(completed_at,NOW())>=? AND COALESCE(completed_at,NOW())<=?",[$fromTs,$toTs]);
$maintenance=(int)val("SELECT COUNT(*) FROM maintenance_tickets WHERE status IN('resolved','closed') AND COALESCE(resolved_at,NOW())>=? AND COALESCE(resolved_at,NOW())<=?",[$fromTs,$toTs]);
$failedLogins=(int)val("SELECT COUNT(*) FROM login_attempts WHERE successful=0 AND attempted_at>=? AND attempted_at<=?",[$fromTs,$toTs]);
$capacity=$availableRooms*$days;
$occupancy=$capacity>0?min(100,round(($roomNights/$capacity)*100,1)):0;

page_head('Analytics','analytics','Revenue, occupancy and departmental performance');
echo '<div class="panel"><h2>Reporting period</h2>';
echo '<form method="get" action="'.BASE.'/index.php"><input type="hidden" name="page" value="analytics"><div class="formGrid">'.field('From','from',$fromDay,'date','',true).field('To','to',$toDay,'date','',true).'</div><button class="btn">Run report</button></form>';
echo '<div class="toolbar"><a class="btnGhost sm" href="'.BASE.'/index.php?page=analytics&from='.$fromDay.'&to='.$toDay.'&type=daily">Export daily CSV</a><a class="btnGhost sm" href="'.BASE.'/index.php?page=analytics&from='.$fromDay.'&to='.$toDay.'&type=payments">Export payment mix CSV</a></div></div>';

echo '<div class="kpis">';
kpi_card('Room revenue',money($roomRevenue),'Reservations checking in');
kpi_card('Payments received',money($payments),'Successful payments');
kpi_card('Occupancy',$occupancy.'%',number_format($roomNights,0).' room nights of '.number_format($capacity,0));
kpi_card('Net after expenses',money(($roomRevenue+$pos)-$expenses),'Revenue view less paid expenses');
echo '</div>';

echo '<div class="twoCol"><div class="panel"><h2>Period summary</h2><table class="tbl"><tbody>';
echo '<tr><th>Room revenue</th><td class="num">'.money($roomRevenue).'</td></tr>';
echo '<tr><th>F&B completed sales</th><td class="num">'.money($pos).'</td></tr>';
echo '<tr><th>Payments collected</th><td class="num">'.money($payments).'</td></tr>';
echo '<tr><th>Expenses paid</th><td class="num">'.money($expenses).'</td></tr>';
echo '<tr><th>Room nights sold</th><td class="num">'.number_format($roomNights,0).'</td></tr>';
echo '<tr><th>Average daily rate</th><td class="num">'.money($roomNights>0?$roomRevenue/$roomNights:0).'</td></tr>';
echo '<tr><th>RevPAR</th><td class="num">'.money($capacity>0?$roomRevenue/$capacity:0).'</td></tr>';
echo '<tr><th>Reservation balance</th><td class="num">'.money($outstanding).'</td></tr>';
echo '<tr><th>Open invoice value</th><td class="num">'.money($invoiceDue).'</td></tr>';
echo '<tr><th>Rooms cleaned</th><td class="num">'.$housekeeping.'</td></tr>';
echo '<tr><th>Maintenance closed</th><td class="num">'.$maintenance.'</td></tr>';
echo '<tr><th>Failed logins</th><td class="num">'.$failedLogins.'</td></tr>';
echo '</tbody></table></div>';

echo '<div><div class="panel"><h2>Payment mix</h2><table class="tbl"><thead><tr><th>Method</th><th class="num">Count</th><th class="num">Amount</th></tr></thead><tbody>';
foreach($paymentMix as $p) echo '<tr><td>'.e(str_replace('_',' ',$p['method'])).'</td><td class="num">'.e($p['n']).'</td><td class="num">'.money($p['amount']).'</td></tr>';
if(!$paymentMix) echo '<tr><td colspan="3" style="text-align:center;color:var(--muted)">No payments in this period.</td></tr>';
echo '</tbody></table></div>';
echo '<div class="panel"><h2>Booking sources</h2><table class="tbl"><thead><tr><th>Source</th><th class="num">Bookings</th><th class="num">Value</th></tr></thead><tbody>';
foreach($sourceMix as $s) echo '<tr><td>'.e(ucfirst(str_replace('_',' ',(string)$s['source']))).'</td><td class="num">'.e($s['bookings']).'</td><td class="num">'.money($s['value']).'</td></tr>';
if(!$sourceMix) echo '<tr><td colspan="3" style="text-align:center;color:var(--muted)">No bookings in this period.</td></tr>';
echo '</tbody></table></div></div></div>';

echo '<div class="panel"><h2>Daily performance</h2><table class="tbl"><thead><tr><th>Date</th><th class="num">Bookings</th><th class="num">Room revenue</th><th class="num">Payments</th><th class="num">POS sales</th></tr></thead><tbody>';
foreach($dailyRows as $i=>$r){ if($i===0) continue; echo '<tr><td>'.e($r[0]).'</td><td class="num">'.e($r[1]).'</td><td class="num">'.money($r[2]).'</td><td class="num">'.money($r[3]).'</td><td class="num">'.money($r[4]).'</td></tr>'; }
if(count($dailyRows)<2) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No activity in this period.</td></tr>';
echo '</tbody></table></div>';

echo '<div class="panel"><h2>Expense categories</h2><table class="tbl"><thead><tr><th>Category</th><th class="num">Entries</th><th class="num">Amount</th></tr></thead><tbody>';
foreach($expenseMix as $e) echo '<tr><td>'.e($e['category']).'</td><td class="num">'.e($e['n']).'</td><td class="num">'.money($e['amount']).'</td></tr>';
if(!$expenseMix) echo '<tr><td colspan="3" style="text-align:center;color:var(--muted)">No paid expenses in this period.</td></tr>';
echo '</tbody></table></div>';
receipt_print('analytics');
page_foot();
