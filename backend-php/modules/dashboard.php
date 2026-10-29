<?php
declare(strict_types=1);
require_once __DIR__.'/../app/guest_comm.php';

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
 'rooms'=>val("SELECT COUNT(*) FROM rooms WHERE deleted_at IS NULL"),
 'depart'=>val("SELECT COUNT(*) FROM reservations WHERE status='checked_in' AND check_out>=? AND check_out<?",[$day0,$day1]),
 'rev'=>val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND created_at>=? AND created_at<?",[$day0,$day1]),
 'pend'=>val("SELECT COUNT(*) FROM expenses WHERE status='pending'",[])+val("SELECT COUNT(*) FROM purchase_requisitions WHERE status='pending'",[]),
 'low'=>val("SELECT COUNT(*) FROM stock_levels sl JOIN inventory_items i ON i.id=sl.item_id WHERE sl.quantity<=i.reorder_level AND i.active=1",[]),
];
$arrivals=rows("SELECT r.id,r.booking_number,g.full_name,rt.name rtype,r.adults FROM reservations r JOIN guests g ON g.id=r.guest_id JOIN reservation_rooms rr ON rr.reservation_id=r.id JOIN room_types rt ON rt.id=rr.room_type_id WHERE r.status IN('pending','confirmed') AND r.check_in>=? AND r.check_in<? ORDER BY r.check_in",[$day0,$day1]);
$inhouse=rows("SELECT r.id,g.full_name,rt.name rtype,rr.room_id,rn.room_number FROM reservations r JOIN guests g ON g.id=r.guest_id JOIN reservation_rooms rr ON rr.reservation_id=r.id JOIN room_types rt ON rt.id=rr.room_type_id LEFT JOIN rooms rn ON rn.id=rr.room_id WHERE r.status='checked_in' AND r.deleted_at IS NULL GROUP BY r.id,g.full_name,rt.name,rr.room_id,rn.room_number ORDER BY g.full_name");
$payments=rows("SELECT p.id,p.amount,p.method,p.status,DATE(p.created_at) d,u.name usr FROM payments p LEFT JOIN users u ON u.id=p.user_id WHERE p.created_at>=? AND p.created_at<? ORDER BY p.id DESC LIMIT 8",[$day0,$day1]);
$pend=rows("SELECT 'expense' kind,e.number ref,e.amount amount,e.department_name dept FROM (SELECT e.id,e.number,e.amount,d.name department_name FROM expenses e LEFT JOIN departments d ON d.id=e.department_id WHERE e.status='pending') e UNION ALL SELECT 'requisition',pr.number,0,d.name FROM purchase_requisitions pr LEFT JOIN departments d ON d.id=pr.department_id WHERE pr.status='pending' LIMIT 6",[]);

page_head('Dashboard','dashboard',date('l, j F Y'));
echo '<div class="kpis">';
kpi_card('Arrivals today',(string)$k['arrivals'],'Expected check ins');
kpi_card('In house',(string)$k['inhouse'],'Guests staying tonight');
kpi_card('Rooms available',(string)$k['avail'],'Of '.(int)$k['rooms'].' rooms');
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
else{ echo '<div class="miniList">'; foreach($pend as $p){ echo '<div class="li"><span>'.e($p['ref']).'<br><small>'.e(ucfirst($p['kind'])).'</small></span>'.($p['amount']>0?'<b>'.money($p['amount']).'</b>':'').'</div>'; } echo '</div><a class="btn sm btnAttn" style="margin-top:12px" href="'.BASE.'/index.php?page=approvals">Review approvals</a>'; }
echo '</div></div></div>';

// Guest communications: the messages and experiences on this member's desk.
// A front desk member sees what is sent to the house, the kitchen what is sent
// to the kitchen, and the management team sees both, uncounted and unread.
$gmc=guest_message_counts();
if(guest_message_ready()&&$gmc['total']>0){
 $gs=guest_message_scope();
 $ph=implode(',',array_fill(0,count($gs),'?'));
 $recentM=rows("SELECT id,reference,full_name,department,subject,status FROM guest_messages WHERE kind='message' AND department IN ($ph) ORDER BY id DESC LIMIT 5",$gs);
 $recentX=rows("SELECT id,full_name,rating,message,status FROM guest_messages WHERE kind='experience' AND department IN ($ph) ORDER BY id DESC LIMIT 3",$gs);
 $tones=['new'=>'warn','assigned'=>'blue','resolved'=>'ok','featured'=>'gold'];
 echo '<div class="dashGrid" style="margin-top:18px"><div class="panel">';
 echo '<h2>Guest messages</h2><p class="hint">'.($gmc['new']>0?$gmc['new'].' new waiting for an answer.':'').'What guests have sent to your desk.</p>';
 if(!$recentM){ echo '<p class="emptyLine">No guest messages on your desk.</p>'; }
 else{
  echo '<table class="tbl"><thead><tr><th>Guest</th><th>Desk</th><th>Subject</th><th>Status</th></tr></thead><tbody>';
  foreach($recentM as $m){
   echo '<tr><td><b>'.e($m['full_name']).'</b><br><small>'.e($m['reference']).'</small></td>';
   echo '<td>'.e(guest_message_departments()[$m['department']]??$m['department']).'</td>';
   echo '<td>'.e($m['subject']??'(no subject)').'</td>';
   echo '<td>'.badge(guest_message_statuses()[$m['status']]??$m['status'],$tones[$m['status']]??'grey').'</td></tr>';
  }
  echo '</tbody></table>';
 }
 echo '<div style="margin-top:12px"><a class="btn sm btnAttn" href="'.BASE.'/index.php?page=messages">Open guest messages</a></div>';
 echo '</div>';
 if(page_allowed('testimonials')&&$recentX){
  echo '<div class="panel"><h2>Guest experiences</h2><p class="hint">The latest stay reviews on your desk.</p><div class="miniList">';
  foreach($recentX as $x){
   echo '<div class="li"><span>'.e($x['full_name']).'<br><small>'.str_repeat('&#9733;',(int)$x['rating']).' &middot; <em>'.e(mb_strimwidth((string)$x['message'],0,48,'&hellip;')).'</em></small></span>'.badge(guest_message_statuses()[$x['status']]??$x['status'],$tones[$x['status']]??'grey').'</div>';
  }
  echo '</div><div style="margin-top:12px"><a class="btn sm" href="'.BASE.'/index.php?page=testimonials">Open experiences</a></div>';
  echo '</div>';
 }
 echo '</div>';
}

// The newsroom, as much of it as this member holds. A department writes its own
// small stories here; an editor and the management team see their whole desk.
$cap=news_capability();
if($cap!==null){
  $me=current_user();
  $canAll=$cap['can_all'];
  $isContrib=$cap['tier']==='contributor';
  $labels=['news'=>'News & announcements','update'=>'Updates & notices','opportunity'=>'Opportunities','recruitment'=>'Recruitment','employee'=>'Employee of the month'];
  $quick=$canAll?['news','update','opportunity']:array_values(array_intersect($cap['categories']??[],['news','update','opportunity']));
  if($quick===[]) $quick=['news'];
  $w=[]; $a=[];
  if($isContrib){ $w[]='created_by=?'; $a[]=(int)($me['id']??0); }
  elseif(!$canAll){ $w[]='category IN('.implode(',',array_fill(0,count($cap['categories']),'?')).')'; $a=array_merge($a,$cap['categories']); }
  $recent=rows('SELECT id,title,category,status,views FROM news_posts'.($w?' WHERE '.implode(' AND ',$w):'').' ORDER BY id DESC LIMIT 5',$a);

  echo '<div class="dashGrid" style="margin-top:18px"><div class="panel">';
  echo '<h2>'.($isContrib?'Your newsroom':'Newsroom').'</h2>';
  echo '<p class="hint">'.($isContrib
    ? 'A short news item or update for '.e($cap['department']?:'your department').'. It goes on the website signed with your department.'
    : 'Write a news item or a service update. For a vacancy, or a full story with a photograph, open the newsroom.').'</p>';
  form_open('news','save');
  echo '<input type="hidden" name="return" value="dashboard"/>';
  field('Headline','title','','text','The title shown on the website',true);
  echo '<div class="twoCol"><div class="col">';
  echo '<div class="field"><label>Category</label><select name="category">';
  foreach($quick as $qk){ echo '<option value="'.e($qk).'">'.e($labels[$qk]??$qk).'</option>'; }
  echo '</select></div>';
  echo '</div><div class="col">';
  echo '<div class="field"><label>When</label><select name="status"><option value="published">Publish now</option><option value="draft">Save as draft</option></select></div>';
  echo '</div></div>';
  area('The story','body','','A sentence or two. Leave a blank line between paragraphs.','',4);
  echo '<div style="display:flex;gap:10px;flex-wrap:wrap"><button class="btn" type="submit">Publish</button>'
    .'<a class="btn ghost" href="'.BASE.'/index.php?page=news">Open the newsroom</a></div>';
  form_close();
  echo '</div>';

  echo '<div class="panel"><h2>'.($isContrib?'Your latest posts':'Latest posts').'</h2>';
  if(!$recent){ echo '<p class="emptyLine">Nothing written yet.</p>'; }
  else{
    echo '<table class="tbl"><thead><tr><th>Title</th><th>Category</th><th>Status</th><th>Views</th><th></th></tr></thead><tbody>';
    foreach($recent as $rp){
      echo '<tr><td><b>'.e($rp['title']).'</b></td><td>'.e($labels[$rp['category']]??$rp['category']).'</td>'
        .'<td>'.e(ucfirst((string)$rp['status'])).'</td><td>'.(int)$rp['views'].'</td>'
        .'<td><a class="btn sm" href="'.BASE.'/index.php?page=news&act=edit&id='.(int)$rp['id'].'">Open</a></td></tr>';
    }
    echo '</tbody></table>';
  }
  echo '</div></div>';
}

stock_request_dashboard_panel('dashboard');

page_foot();