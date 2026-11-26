from pathlib import Path
import re
p=Path(r'C:\xampp\htdocs\Hotel_paradise\backend-php\modules\overview.php')
s=p.read_text(encoding='utf-8')
pat=r"/\* ------------------------------------------------------------------ the screen \*/.*?echo '</div>';(?=\s*/\* --------------------------------------------------------------- order view \*/)"
m=re.search(pat,s,flags=re.S)
new=r"""/* ------------------------------------------------------------------ the screen */
 = ['rooms']>0 ? round((['inhouse']/['rooms'])*100,1) : 0;
=rows("SELECT DATE(created_at) d, COALESCE(SUM(amount),0) amt FROM payments WHERE status='successful' AND created_at>=? GROUP BY DATE(created_at) ORDER BY d", [date('Y-m-d',strtotime('-13 days')).' 00:00:00']);
=[]; foreach( as ){ [substr((string)['d'],0,10)]=(float)['amt']; }
=[]; =[]; for(=13;>=0;--){ =date('Y-m-d',strtotime("- days")); []=date('d M',strtotime()); []=[]??0.0; }
=[
 ['label'=>'Payments month','value'=>(float)['month'],'color'=>'#D4AF37'],
 ['label'=>'Billed month','value'=>(float)['billed_month'],'color'=>'#0B5D78'],
 ['label'=>'Expenses month','value'=>(float)['expenses_month'],'color'=>'#C62828'],
 ['label'=>'Purchases month','value'=>(float)['purchases_month'],'color'=>'#123056'],
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
kpi_card('Revenue today',money(['today']),'vs ' . money(['yesterday']) . ' yesterday',['today']?'green':'navy');
kpi_card('Revenue this month',money(['month']),'Since '.,'blue');
kpi_card('Revenue this year',money(['year']),'YTD','gold');
kpi_card('Orders today',(string)['orders'],'vs '.['orders_yesterday'].' yesterday',(['orders']>=['orders_yesterday'])?'blue':'navy');
kpi_card('In house',(string)['inhouse'].' / '.['rooms'],'Avail: '.['available'].', Clean: '.['cleaning'],['inhouse']?'gold':'navy');
kpi_card('Occupancy',.'%','Maintenance: '.['maintenance'],'ok');
kpi_card('Arrivals today',(string)['arrivals'],'Expected check-ins',['arrivals']?'green':'navy');
kpi_card('Departures today',(string)['departures'],'Expected check-outs',['departures']?'blue':'navy');
kpi_card('Pending/Active orders',(string)['owed_all'],money(['billed_month']).' billed this month',['owed_all']?'warn':'ok');
kpi_card('Unpaid balances',money(['unpaid_reservations']),'Reservations/orders outstanding',['unpaid_reservations']>0?'red':'green');
kpi_card('Expenses this month',money(['expenses_month']),'+ Purch: '.money(['purchases_month']),'warn');
echo '</div>';
echo '<div class="chartGrid">';
echo '<div class="panel chartCard span-8">'; hp_panel_head('Revenue trajectory','Successful payments, last 14 days.'); echo hp_line_chart([['label'=>'Revenue','values'=>,'color'=>'#D4AF37','area'=>true]],,['aria'=>'14 day revenue trend','empty'=>'No successful payments in the last 14 days.']); echo '</div>';
echo '<div class="panel chartCard span-4">'; hp_panel_head('Monthly financial mix','Month-to-date payments, billed orders, expenses and purchases.'); echo hp_donut_chart(,['aria'=>'Monthly financial mix','center_label'=>'Month','money'=>true,'empty'=>'No month-to-date data available.']); echo '</div>';
echo '</div>';"""
assert m
p.write_text(s[:m.start()]+new+s[m.end():],encoding='utf-8')
print('ok')
