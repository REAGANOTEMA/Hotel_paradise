from pathlib import Path
p=Path(r'C:\xampp\htdocs\Hotel_paradise\backend-php\modules\dashboard.php')
s=p.read_text(encoding='utf-8')
old='''=today();
// A day as a half-open range (00:00:00 today up to, not including, 00:00:00
// tomorrow). Written as a range rather than DATE(created_at)=? so MySQL can
// use the index on the column instead of scanning the whole table.
=.' 00:00:00';
=date('Y-m-d',strtotime(.' +1 day')).' 00:00:00';
=[
 'arrivals'=>val("SELECT COUNT(*) FROM reservations WHERE status IN('pending','confirmed') AND check_in>=? AND check_in<?",[,]),
 'inhouse'=>val("SELECT COUNT(*) FROM rooms WHERE status='occupied'"),
 'avail'=>val("SELECT COUNT(*) FROM rooms WHERE status='available'"),
 'rooms'=>val("SELECT COUNT(*) FROM rooms WHERE deleted_at IS NULL"),
 'depart'=>val("SELECT COUNT(*) FROM reservations WHERE status='checked_in' AND check_out>=? AND check_out<?",[,]),
 'rev'=>val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=? AND created_at<?",[,]),
 'pend'=>val("SELECT COUNT(*) FROM expenses WHERE status='pending'",[])+val("SELECT COUNT(*) FROM purchase_requisitions WHERE status='pending'",[]),
 'low'=>val("SELECT COUNT(*) FROM stock_levels sl JOIN inventory_items i ON i.id=sl.item_id WHERE sl.quantity<=i.reorder_level AND i.active=1",[]),
];
=rows("SELECT r.id,r.booking_number,g.id guest_id,g.full_name,rt.name rtype,r.adults FROM reservations r JOIN guests g ON g.id=r.guest_id JOIN reservation_rooms rr ON rr.reservation_id=r.id JOIN room_types rt ON rt.id=rr.room_type_id WHERE r.status IN('pending','confirmed') AND r.check_in>=? AND r.check_in<? ORDER BY r.check_in",[,]);
=rows("SELECT r.id,g.id guest_id,g.full_name,rt.name rtype,rr.room_id,rn.room_number FROM reservations r JOIN guests g ON g.id=r.guest_id JOIN reservation_rooms rr ON rr.reservation_id=r.id JOIN room_types rt ON rt.id=rr.room_type_id LEFT JOIN rooms rn ON rn.id=rr.room_id WHERE r.status='checked_in' AND r.deleted_at IS NULL GROUP BY r.id,g.id,g.full_name,rt.name,rr.room_id,rn.room_number ORDER BY CASE WHEN g.full_name='' THEN 1 ELSE 0 END,g.full_name");
=rows("SELECT p.id,p.amount,p.method,p.status,DATE(p.created_at) d,u.name usr FROM payments p LEFT JOIN users u ON u.id=p.user_id WHERE p.created_at>=? AND p.created_at<? ORDER BY p.id DESC LIMIT 8",[,]);
=rows("SELECT 'expense' kind,e.number ref,e.amount amount,e.department_name dept FROM (SELECT e.id,e.number,e.amount,d.name department_name FROM expenses e LEFT JOIN departments d ON d.id=e.department_id WHERE e.status='pending') e UNION ALL SELECT 'requisition',pr.number,0,d.name FROM purchase_requisitions pr LEFT JOIN departments d ON d.id=pr.department_id WHERE pr.status='pending' LIMIT 6",[]);

page_head('Dashboard','dashboard',date('l, j F Y'));
echo '<div class="kpis">';
kpi_card('Arrivals today',(string)['arrivals'],'Expected check ins');
kpi_card('In house',(string)['inhouse'],'Guests staying tonight');
kpi_card('Rooms available',(string)['avail'],'Of '.(int)['rooms'].' rooms');
kpi_card('Departures today',(string)['depart'],'Check outs expected');
kpi_card('Revenue today',money(['rev']),'Successful payments');
kpi_card('Pending approvals',(string)['pend'],'Expenses and requisitions');
kpi_card('Low stock items',(string)['low'],'At or below reorder level');
echo '</div>';'''
new='''=today();
=.' 00:00:00';
=date('Y-m-d',strtotime(.' +1 day')).' 00:00:00';
=date('Y-m-d',strtotime('monday this week')).' 00:00:00';
=[
 'arrivals'=>(int)val("SELECT COUNT(*) FROM reservations WHERE status IN('pending','confirmed') AND check_in>=? AND check_in<?",[,]),
 'inhouse'=>(int)val("SELECT COUNT(*) FROM rooms WHERE status='occupied'"),
 'avail'=>(int)val("SELECT COUNT(*) FROM rooms WHERE status='available'"),
 'rooms'=>(int)val("SELECT COUNT(*) FROM rooms WHERE deleted_at IS NULL"),
 'depart'=>(int)val("SELECT COUNT(*) FROM reservations WHERE status='checked_in' AND check_out>=? AND check_out<?",[,]),
 'rev'=>(float)val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=? AND created_at<?",[,]),
 'week_rev'=>(float)val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=?",[]),
 'pend'=>(int)val("SELECT COUNT(*) FROM expenses WHERE status='pending'",[])+(int)val("SELECT COUNT(*) FROM purchase_requisitions WHERE status='pending'",[]),
 'low'=>(int)val("SELECT COUNT(*) FROM stock_levels sl JOIN inventory_items i ON i.id=sl.item_id WHERE sl.quantity<=i.reorder_level AND i.active=1",[]),
];
=rows("SELECT r.id,r.booking_number,g.id guest_id,g.full_name,rt.name rtype,r.adults FROM reservations r JOIN guests g ON g.id=r.guest_id JOIN reservation_rooms rr ON rr.reservation_id=r.id JOIN room_types rt ON rt.id=rr.room_type_id WHERE r.status IN('pending','confirmed') AND r.check_in>=? AND r.check_in<? ORDER BY r.check_in",[,]);
=rows("SELECT r.id,g.id guest_id,g.full_name,rt.name rtype,rr.room_id,rn.room_number FROM reservations r JOIN guests g ON g.id=r.guest_id JOIN reservation_rooms rr ON rr.reservation_id=r.id JOIN room_types rt ON rt.id=rr.room_type_id LEFT JOIN rooms rn ON rn.id=rr.room_id WHERE r.status='checked_in' AND r.deleted_at IS NULL GROUP BY r.id,g.id,g.full_name,rt.name,rr.room_id,rn.room_number ORDER BY CASE WHEN g.full_name='' THEN 1 ELSE 0 END,g.full_name");
=rows("SELECT p.id,p.amount,p.method,p.status,DATE(p.created_at) d,u.name usr FROM payments p LEFT JOIN users u ON u.id=p.user_id WHERE p.created_at>=? AND p.created_at<? ORDER BY p.id DESC LIMIT 8",[,]);
=rows("SELECT 'expense' kind,e.number ref,e.amount amount,e.department_name dept FROM (SELECT e.id,e.number,e.amount,d.name department_name FROM expenses e LEFT JOIN departments d ON d.id=e.department_id WHERE e.status='pending') e UNION ALL SELECT 'requisition',pr.number,0,d.name FROM purchase_requisitions pr LEFT JOIN departments d ON d.id=pr.department_id WHERE pr.status='pending' LIMIT 6",[]);
=rows("SELECT DATE(created_at) d, COALESCE(SUM(amount),0) amt FROM payments WHERE status='successful' AND created_at>=? GROUP BY DATE(created_at) ORDER BY d", [date('Y-m-d',strtotime('-6 days')).' 00:00:00']);
=[]; foreach( as ){ [substr((string)['d'],0,10)]=(float)['amt']; }
=[]; =[]; for(=6;>=0;--){ =date('Y-m-d',strtotime("- days")); []=date('D',strtotime()); []=[]??0.0; }
=rows("SELECT status,COUNT(*) n FROM rooms WHERE deleted_at IS NULL GROUP BY status");
 = ['rooms']>0 ? round((['inhouse']/['rooms'])*100) : 0;

page_head('Dashboard','dashboard',date('l, j F Y'));
hp_dash_hero('Operations Command','Hotel performance at a glance','A live operational overview for Hotel Paradise on the Nile, combining arrivals, occupancy, revenue, approvals and service signals in one premium workspace.',[
  ['label'=>'Occupancy','value'=>.'%'],
  ['label'=>'Revenue today','value'=>money(['rev'])],
  ['label'=>'Pending approvals','value'=>(string)['pend']],
  ['label'=>'Low stock','value'=>(string)['low']],
],[
  ['label'=>'Reservations','href'=>BASE.'/index.php?page=reservations'],
  ['label'=>'Front Office','href'=>BASE.'/index.php?page=frontdesk','ghost'=>true],
  ['label'=>'Reports','href'=>BASE.'/index.php?page=reports','ghost'=>true],
]);
echo '<div class="kpis">';
kpi_card('Arrivals today',(string)['arrivals'],'Expected check ins','blue');
kpi_card('In house',(string)['inhouse'],'Guests staying tonight','gold');
kpi_card('Rooms available',(string)['avail'],'Of '.(int)['rooms'].' rooms','green');
kpi_card('Departures today',(string)['depart'],'Check outs expected','navy');
kpi_card('Revenue today',money(['rev']),'Week to date '.money(['week_rev']),'ok');
kpi_card('Pending approvals',(string)['pend'],'Expenses and requisitions',['pend']>0?'warn':'ok');
kpi_card('Low stock items',(string)['low'],'At or below reorder level',['low']>0?'warn':'ok');
kpi_card('Occupancy rate',.'%','Occupied rooms vs total inventory','blue');
echo '</div>';

echo '<div class="chartGrid">';
echo '<div class="panel chartCard span-8">'; hp_panel_head('Revenue trend','Successful payments over the last 7 days.','<span class="pillFilter"><span class="on">7 days</span></span>');
echo hp_line_chart([['label'=>'Revenue','values'=>,'color'=>'#D4AF37','area'=>true]],,['aria'=>'Seven day revenue trend','empty'=>'No successful payments recorded in the last 7 days.']);
echo '</div>';
echo '<div class="panel chartCard span-4">'; hp_panel_head('Room status','Current room inventory by operational status.');
=[]; =['available'=>'#2E7D32','occupied'=>'#D4AF37','reserved'=>'#0B5D78','dirty'=>'#C62828','cleaning'=>'#12809f','maintenance'=>'#6b7280','out_of_service'=>'#374151','inspected'=>'#66bb6a'];
foreach( as ){ []=['label'=>ucwords(str_replace('_',' ',['status'])),'value'=>(int)['n'],'color'=>[['status']]??'#123056']; }
echo hp_donut_chart(,['aria'=>'Room status distribution','center_label'=>'Rooms','center_value'=>(string)['rooms'],'money'=>false,'empty'=>'No rooms found in inventory.']);
echo '</div></div>';'''
if old not in s:
    print('MISS')
else:
    p.write_text(s.replace(old,new), encoding='utf-8')
    print('ok')
