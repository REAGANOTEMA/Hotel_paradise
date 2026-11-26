from pathlib import Path
import re
p=Path(r'C:\xampp\htdocs\Hotel_paradise\backend-php\modules\overview.php')
s=p.read_text(encoding='utf-8')
old="""page_head('CEO / Director Overview','overview','Whole-house performance, accountability and live activity');
echo '<div class="kpis">';
kpi_card('Revenue today',money(['today']),'Successful payments');
kpi_card('Yesterday',money(['yesterday']),'Successful payments');
kpi_card('This month',money(['month']),'Successful payments');
kpi_card('Year to date',money(['year']),'Successful payments');
kpi_card('Orders today',(string)['orders'],'Yesterday '.(int)['orders_yesterday']);
kpi_card('In house',(string)['inhouse'],'Of '.(int)['rooms'].' rooms &middot; '.(int)['available'].' available');
kpi_card('Arrivals today',(string)['arrivals'],'Departures '.(int)['departures']);
kpi_card('Orders unpaid',(string)['owed'],'All unsettled '.(int)['owed_all']);
kpi_card('Expenses today',money(['expenses_today']),'Month '.money(['expenses_month']));
kpi_card('Purchases month',money(['purchases_month']),'Sent, partial, received');
kpi_card('Voids today',money(['voids_today']),'Recorded voids');
kpi_card('Unpaid reservations',money(['unpaid_reservations']),'Confirmed / in house');
echo '</div>';"""
new=""" = ['rooms']>0 ? round((['inhouse']/['rooms'])*100) : 0;
=rows("SELECT DATE(created_at) d, COALESCE(SUM(amount),0) amt FROM payments WHERE status='successful' AND created_at>=? GROUP BY DATE(created_at) ORDER BY d", [date('Y-m-d',strtotime('-13 days')).' 00:00:00']);
=[]; foreach( as ){ [substr((string)['d'],0,10)]=(float)['amt']; }
=[]; =[]; for(=13;>=0;--){ =date('Y-m-d',strtotime("- days")); []=date('d M',strtotime()); []=[]??0.0; }
=[
 ['label'=>'Room/Bookings','value'=>(float)['month'],'color'=>'#D4AF37'],
 ['label'=>'Restaurant/Billed','value'=>(float)['billed_month'],'color'=>'#0B5D78'],
];
page_head('CEO / Director Overview','overview','Whole-house performance, accountability and live activity');
hp_dash_hero('Executive Command','Owner & Director performance overview','A premium executive view of revenue, occupancy, operations, guest flow and financial exposure across Hotel Paradise on the Nile.',[
 ['label'=>'Occupancy','value'=>.'%'],
 ['label'=>'Revenue today','value'=>money(['today'])],
 ['label'=>'Month revenue','value'=>money(['month'])],
 ['label'=>'Unpaid reservations','value'=>money(['unpaid_reservations'])],
],[
 ['label'=>'Analytics','href'=>BASE.'/index.php?page=analytics'],
 ['label'=>'Reports','href'=>BASE.'/index.php?page=reports','ghost'=>true],
 ['label'=>'Finance','href'=>BASE.'/index.php?page=finance','ghost'=>true],
]);
echo '<div class="kpis">';
kpi_card('Revenue today',money(['today']),'Successful payments','gold');
kpi_card('Yesterday',money(['yesterday']),'Successful payments','navy');
kpi_card('This month',money(['month']),'Successful payments','blue');
kpi_card('Year to date',money(['year']),'Successful payments','green');
kpi_card('Orders today',(string)['orders'],'Yesterday '.(int)['orders_yesterday'],'blue');
kpi_card('In house',(string)['inhouse'],'Of '.(int)['rooms'].' rooms · '.(int)['available'].' available','gold');
kpi_card('Occupancy',.'%','Occupied vs room inventory','ok');
kpi_card('Arrivals today',(string)['arrivals'],'Departures '.(int)['departures'],'navy');
kpi_card('Orders unpaid',(string)['owed'],'All unsettled '.(int)['owed_all'],['owed']>0?'warn':'ok');
kpi_card('Expenses today',money(['expenses_today']),'Month '.money(['expenses_month']),'warn');
kpi_card('Purchases month',money(['purchases_month']),'Sent, partial, received','blue');
kpi_card('Unpaid reservations',money(['unpaid_reservations']),'Confirmed / in house',['unpaid_reservations']>0?'warn':'ok');
echo '</div>';
echo '<div class="chartGrid">';
echo '<div class="panel chartCard span-8">'; hp_panel_head('Revenue trajectory','Successful payments, last 14 days.'); echo hp_line_chart([['label'=>'Revenue','values'=>,'color'=>'#D4AF37','area'=>true]],,['aria'=>'14 day revenue trend','empty'=>'No successful payments in the last 14 days.']); echo '</div>';
echo '<div class="panel chartCard span-4">'; hp_panel_head('Monthly revenue mix','Month-to-date booking revenue vs billed orders.'); echo hp_donut_chart(,['aria'=>'Revenue mix','center_label'=>'Month','money'=>true,'empty'=>'No month-to-date revenue data available.']); echo '</div>';
echo '</div>';"""
if old not in s:
    print('MISS')
else:
    p.write_text(s.replace(old,new),encoding='utf-8')
    print('ok')
