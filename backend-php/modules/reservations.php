<?php
declare(strict_types=1);

$act=$_GET['act']??'';
$id=(int)($_GET['id']??$_POST['id']??0);
$view=(int)($_GET['view']??0);

if($_SERVER['REQUEST_METHOD']==='POST' && $act){
 switch($act){
  case 'new':
   $gid=(int)($_POST['guest_id']??0);
   if(!$gid && trim($_POST['full_name']??'')){
    q('INSERT INTO guests(hotel_id,full_name,phone,email,nationality,id_type,id_number,created_at) VALUES(1,?,?,?,?,?,?,NOW())',
      [trim($_POST['full_name']),trim($_POST['phone']),trim($_POST['email']),trim($_POST['nationality']),trim($_POST['id_type']),trim($_POST['id_number'])]);
    $gid=(int)db()->lastInsertId();
    audit('create','guest',$gid);
   }
   if(!$gid){ flash('Choose a guest or enter guest details.','bad'); go('reservations',['new'=>1]); }
   $rt=(int)($_POST['room_type_id']??0); $qty=max(1,(int)($_POST['qty']??1));
   $rate=(float)($_POST['rate']??0);
   $rate=$rate>0?$rate:(float)val('SELECT base_rate FROM room_types WHERE id=?',[$rt]);
   $cin=trim($_POST['check_in']??''); $cout=trim($_POST['check_out']??'');
   if(!$cin||!$cout||$cout<=$cin){ flash('Please provide valid check in and check out dates.','bad'); go('reservations',['new'=>1]); }
   $nights=max(1,(int)ceil((strtotime($cout)-strtotime($cin))/86400));
   if($nights>30){ flash('Reservations cannot exceed 30 nights.','bad'); go('reservations',['new'=>1]); }
   $ci=$cin.' 14:00:00'; $co=$cout.' 11:00:00';
   $subtotal=$rate*$qty*$nights; $total=$subtotal;
   $num=next_number('HPN','reservations','booking_number');
   q('INSERT INTO reservations(hotel_id,guest_id,booking_number,source,check_in,check_out,adults,children,status,room_rate,nights,subtotal,tax,total,paid,notes,created_at) VALUES(1,?,?,?,?,?,?,?,\'pending\',?,?,?,0,?,0,?,NOW())',
     [$gid,$num,$_POST['source']??'walk_in',$ci,$co,(int)($_POST['adults']??1),(int)($_POST['children']??0),$rate,$nights,$subtotal,$total,trim($_POST['notes']??'')]);
   $rid=(int)db()->lastInsertId();
   q('INSERT INTO reservation_rooms(reservation_id,room_type_id,room_id,quantity,nightly_rate) VALUES(?,?,NULL,?,?)',[$rid,$rt,$qty,$rate]);
   audit('create','reservation',$rid,['booking_no'=>$num]);
   flash('Booking '.$num.' created for '.(int)$qty.' room(s).');
   go('reservations',['view'=>$rid]);
   break;

  case 'status':
   $st=$_POST['status']??''; $r=row('SELECT * FROM reservations WHERE id=?',[$id]); if(!$r) break;
   $allowed=['confirmed','checked_in','checked_out','cancelled','no_show'];
   if(!in_array($st,$allowed)) break;
   if($st==='checked_in'){
    $alloc=rows('SELECT rr.id,rr.room_type_id,rr.quantity,rr.room_id FROM reservation_rooms rr WHERE rr.reservation_id=?',[$id]);
    $need=0; foreach($alloc as $a) $need+=(int)$a['quantity'];
    $avail=val('SELECT COUNT(*) FROM rooms WHERE status=\'available\'');
    if($avail<$need){ flash('Not enough available rooms to check in.','bad'); go('reservations',['view'=>$id]); }
    foreach($alloc as $a){
     $taken=val('SELECT COUNT(*) FROM reservation_rooms WHERE reservation_id=? AND room_id IS NOT NULL',[$id]);
     for($i=0;$i<(int)$a['quantity'];$i++){
      $room=row('SELECT id FROM rooms WHERE room_type_id=? AND status=\'available\' ORDER BY room_number LIMIT 1',[$a['room_type_id']]);
      if(!$room) $room=row('SELECT id FROM rooms WHERE status=\'available\' ORDER BY room_number LIMIT 1',[]);
      if(!$room) break;
      q('UPDATE reservation_rooms SET room_id=? WHERE id=?',[$room['id'],$a['id']]);
      q('UPDATE rooms SET status=\'occupied\' WHERE id=?',[$room['id']]);
      audit('alloc_room','room',$room['id'],['reservation'=>$id]);
     }
     if($taken>0) break;
    }
   }
   if($st==='checked_out'){
    $rooms=rows('SELECT room_id FROM reservation_rooms WHERE reservation_id=? AND room_id IS NOT NULL',[$id]);
    foreach($rooms as $r2){ q('UPDATE rooms SET status=\'dirty\' WHERE id=?',[$r2['room_id']]); }
   }
   $old=['status'=>$r['status']];
   q('UPDATE reservations SET status=?,updated_at=NOW() WHERE id=?',[$st,$id]);
   audit('reservation_status','reservation',$id,$old,['status'=>$st]);
   flash('Reservation marked as '.str_replace('_',' ',$st).'.');
   go('reservations',['view'=>$id]);
   break;

  case 'payment':
   $amount=abs((float)($_POST['amount']??0));
   if($amount<=0){ flash('Enter a valid payment amount.','bad'); go('reservations',['view'=>$id]); }
   $method=$_POST['method']??'cash';
   q('INSERT INTO payments(hotel_id,user_id,reservation_id,amount,method,status,created_at) VALUES(1,?,?,?,?,\'successful\',NOW())',[current_user()['id'],$id,$amount,$method]);
   q('INSERT INTO guest_folio_entries(hotel_id,reservation_id,entry_type,description,amount,user_id,created_at) VALUES(1,?,?,?,?,NOW())',[$id,'payment',ucfirst(str_replace('_',' ',$method)).' payment',$amount,current_user()['id']]);
   q('UPDATE reservations SET paid=paid+?,updated_at=NOW() WHERE id=?',[$amount,$id]);
   audit('payment','reservation',$id,['amount'=>$amount,'method'=>$method]);
   flash('Payment of '.money($amount).' recorded.');
   go('reservations',['view'=>$id]);
   break;

  case 'folio':
   $amount=(float)($_POST['amount']??0); $desc=trim($_POST['description']??'');
   if(!$desc||$amount<=0){ flash('Enter a description and amount.','bad'); go('reservations',['view'=>$id]); }
   q('INSERT INTO guest_folio_entries(hotel_id,reservation_id,entry_type,description,amount,user_id,created_at) VALUES(1,?,?,?,?,NOW())',[$id,'charge',$desc,$amount,current_user()['id']]);
   audit('folio_charge','reservation',$id,['description'=>$desc,'amount'=>$amount]);
   flash('Charge added to the guest folio.');
   go('reservations',['view'=>$id]);
   break;
 }
}

if($view){
 $r=row('SELECT r.*,g.full_name,g.phone,g.email,g.nationality,g.id_type,g.id_number FROM reservations r JOIN guests g ON g.id=r.guest_id WHERE r.id=?',[$view]); if(!$r) { page_head('Reservation'); echo '<div class="panel"><p>Not found.</p></div>'; page_foot(); exit; }
 $rooms=rows('SELECT rt.name,rr.quantity,rr.nightly_rate,rn.room_number FROM reservation_rooms rr JOIN room_types rt ON rt.id=rr.room_type_id LEFT JOIN rooms rn ON rn.id=rr.room_id WHERE rr.reservation_id=?',[$view]);
 $folio=rows('SELECT * FROM guest_folio_entries WHERE reservation_id=? ORDER BY id',[$view]);
 $payments=rows('SELECT * FROM payments WHERE reservation_id=? ORDER BY id',[$view]);
 $charges=$r['total']; foreach($folio as $f) if($f['entry_type']==='charge') $charges+=$f['amount'];
 $paid=$r['paid']; $balance=$charges-$paid;
 page_head('Reservation '.$r['booking_number'],'reservations','Folio and guest details');
 echo '<div class="toolbar"><a class="btnGhost sm" href="'.BASE.'/index.php?page=reservations">&larr; All reservations</a>'.status_badge($r['status']).'</div>';
 echo '<div class="twoCol"><div>';
 echo '<div class="panel"><h2>Guest and stay</h2><p class="hint">Contact and reservation information.</p>';
 echo '<div class="res-meta">';
 echo '<div class="field"><label>Guest</label><b>'.e($r['full_name']).'</b>'.($r['phone']?'<br><span>'.e($r['phone']).'</span>':'').($r['email']?'<br><span>'.e($r['email']).'</span>':'').'</div>';
 echo '<div class="field"><label>Booking number</label><b>'.e($r['booking_number']).'</b></div>';
 echo '<div class="field"><label>Check in</label><b>'.fmtdt($r['check_in']).'</b></div>';
 echo '<div class="field"><label>Check out</label><b>'.fmtdt($r['check_out']).'</b></div>';
 echo '<div class="field"><label>Guests</label><b>'.(int)$r['adults'].' adult(s), '.(int)$r['children'].' child(ren)</b></div>';
 echo '<div class="field"><label>Source</label><b>'.e(ucfirst($r['source'])).'</b></div>';
 echo '</div>';
 echo '</div>';
 echo '<div class="panel"><h2>Rooms</h2><table class="tbl"><thead><tr><th>Room type</th><th class="num">Qty</th><th class="num">Nightly rate</th><th>Room</th></tr></thead><tbody>';
 foreach($rooms as $rm){ echo '<tr><td>'.e($rm['name']).'</td><td class="num">'.(int)$rm['quantity'].'</td><td class="num">'.money($rm['nightly_rate']).'</td><td>'.e($rm['room_number']??'Pending allocation').'</td></tr>'; }
 echo '</tbody></table></div>';
 echo '<div class="panel"><h2>Guest folio</h2><p class="hint">Charges and payments on this stay.</p><div class="miniList">';
 echo '<div class="li"><span>Room charge, '.$r['nights'].' night(s)</span><b>'.money($r['total']).'</b></div>';
 foreach($folio as $f){ $sign=$f['entry_type']==='payment'||$f['entry_type']==='refund'?'-':'+'; echo '<div class="li"><span>'.e(ucfirst($f['entry_type'])).' '.e($f['description']).'<br><small style="color:var(--muted)">'.fmtdt($f['created_at']).'</small></span><b>'.$sign.''.money($f['amount']).'</b></div>'; }
 echo '</div><div style="border-top:2px solid var(--line);margin-top:10px;padding-top:12px"><div class="payRow2"><span>Total charges</span><b>'.money($charges).'</b></div><div class="payRow2"><span>Total paid</span><b>'.money($paid).'</b></div><div class="payRow2"><span style="font-weight:700;color:'.($balance>0?'var(--gold)':'#2e7d32').'">Balance</span><b>'.money($balance).'</b></div></div>';
 echo '</div></div>';

 echo '<div>';
 echo '<div class="panel"><h2>Actions</h2><p class="hint">Move this booking through its lifecycle.</p>';
 if($r['status']==='pending'){ echo '<div style="display:flex;gap:8px;flex-wrap:wrap">'; form_open('reservations','status',['id'=>$view]); echo '<input type="hidden" name="status" value="confirmed"><button class="btn">Confirm</button>'; form_close();
   form_open('reservations','status',['id'=>$view]); echo '<input type="hidden" name="status" value="no_show"><button class="btnGhost">Mark no show</button>'; form_close();
   form_open('reservations','status',['id'=>$view]); echo '<input type="hidden" name="status" value="cancelled"><button class="btnGhost">Cancel</button>'; form_close(); echo '</div>'; }
 if($r['status']==='confirmed'){ form_open('reservations','status',['id'=>$view]); echo '<input type="hidden" name="status" value="checked_in"><button class="btn">Check in</button>'; form_close(); }
 if($r['status']==='checked_in'){ form_open('reservations','status',['id'=>$view]); echo '<input type="hidden" name="status" value="checked_out"><button class="btn danger">Check out</button>'; form_close(); }
 echo '</div>';

 echo '<div class="panel"><h2>Record a payment</h2><p class="hint">Balance '.money($balance).'</p>';
 form_open('reservations','payment',['id'=>$view]);
 echo '<div class="field"><label>Amount</label><input type="number" step="500" min="0" name="amount" value="'.(int)$balance.'"></div>';
 echo '<div class="field"><label>Method</label><select name="method">'; foreach(payment_methods() as $k=>$v2) echo '<option value="'.$k.'">'.$v2.'</option>'; echo '</select></div>';
 echo '<button class="btn tick">Save payment</button>'; form_close();
 echo '</div>';

 echo '<div class="panel"><h2>Add folio charge</h2><p class="hint">Extra charges such as meals, bar or laundry.</p>';
 form_open('reservations','folio',['id'=>$view]);
 echo '<div class="field"><label>Description</label><input name="description" placeholder="e.g. Laundry, mini bar"></div>';
 echo '<div class="field"><label>Amount</label><input type="number" step="500" min="1" name="amount"></div>';
 echo '<button class="btn blue">Add charge</button>'; form_close();
 echo '</div></div></div>';
 page_foot(); exit;
}

if($act==='new'){
 $types=rows('SELECT * FROM room_types WHERE active=1 ORDER BY base_rate DESC');
 $guests=rows('SELECT * FROM guests ORDER BY full_name');
 page_head('New reservation','reservations','Create a new booking');
 echo '<div class="panel" style="max-width:820px">';
 form_open('reservations','new');
 echo '<div class="field"><label>Guest</label><select name="guest_id" required><option value="">Select an existing guest...</option>';
 foreach($guests as $g) echo '<option value="'.(int)$g['id'].'">'.e($g['full_name']).($g['phone']?'  ('.e($g['phone']).')':'').'</option>';
 echo '</select></div>';
 echo '<p style="color:var(--muted);font-size:12.5px">Or enter a new guest below and they will be added automatically.</p>';
 echo '<div class="formGrid"><div class="field"><label>Full name</label><input name="full_name"></div>';
 echo '<div class="field"><label>Phone</label><input name="phone"></div>';
 echo '<div class="field"><label>Email</label><input name="email"></div>';
 echo '<div class="field"><label>Nationality</label><input name="nationality"></div>';
 echo '<div class="field"><label>ID type</label><input name="id_type" placeholder="National ID or Passport"></div>';
 echo '<div class="field"><label>ID number</label><input name="id_number"></div></div>';
 echo '<div class="formRow">';
 echo '<div class="field"><label>Room type</label><select name="room_type_id" required id="rt">'; foreach($types as $t2) echo '<option value="'.(int)$t2['id'].'" data-rate="'.(int)$t2['base_rate'].'">'.e($t2['name']).'  '.money($t2['base_rate']).'</option>'; echo '</select></div>';
 echo '<div class="field"><label>Rooms</label><input type="number" name="qty" value="1" min="1" max="5"></div></div>';
 echo '<div class="field"><label>Nightly rate (UGX, pre filled)</label><input type="number" name="rate" id="rate"></div>';
 echo '<div class="formRow"><div class="field"><label>Check in</label><input type="date" name="check_in" value="'.today().'"></div>';
 echo '<div class="field"><label>Check out</label><input type="date" name="check_out" value="'.date('Y-m-d',strtotime('+1 day')).'"></div></div>';
 echo '<div class="formRow"><div class="field"><label>Adults</label><input type="number" name="adults" value="1" min="1"></div>';
 echo '<div class="field"><label>Children</label><input type="number" name="children" value="0" min="0"></div>';
 echo '<div class="field"><label>Source</label><select name="source">'; foreach(['website'=>'Website','walk_in'=>'Walk in','phone'=>'Phone','email'=>'Email','agent'=>'Agent','other'=>'Other'] as $k=>$v3) echo '<option value="'.$k.'">'.$v3.'</option>'; echo '</select></div></div>';
 echo '<div class="field"><label>Notes</label><textarea name="notes" rows="2"></textarea></div>';
 echo '<button class="btn">Create reservation</button> <a class="btnGhost" href="'.BASE.'/index.php?page=reservations">Cancel</a>';
 form_close();
 echo '<script>var rt=document.getElementById("rt");var r2=document.getElementById("rate");function sr(){r2.value=rt.options[rt.selectedIndex].dataset.rate;}rt.addEventListener("change",sr);sr();</script>';
 echo '</div>'; page_foot(); exit;
}

$st=$_GET['st']??'';
$qtext=trim($_GET['q']??'');
$where='1=1'; $params=[];
if($st){ $where.=' AND r.status=?'; $params[]=$st; }
if($qtext!==''){ $where.=' AND (g.full_name LIKE ? OR r.booking_number LIKE ?)'; $params[]='%'.$qtext.'%'; $params[]='%'.$qtext.'%'; }
$list=rows("SELECT r.id,r.booking_number,r.check_in,r.check_out,r.status,r.total,r.paid,r.adults,g.full_name FROM reservations r JOIN guests g ON g.id=r.guest_id WHERE $where ORDER BY r.check_in DESC LIMIT 200",$params);

page_head('Reservations','reservations','Bookings, arrivals and departures');
echo '<div class="toolbar"><a class="btn" href="'.BASE.'/index.php?page=reservations&act=new">+ New reservation</a></div>';
echo '<div class="rfilter">';
foreach([''=>'All','pending'=>'Pending','confirmed'=>'Confirmed','checked_in'=>'In house','checked_out'=>'Checked out','cancelled'=>'Cancelled','no_show'=>'No show'] as $k=>$v4){
 echo '<a href="'.BASE.'/index.php?page=reservations'.($k?'&st='.$k:'').'"><button class="'.($st===$k?'on':'').'">'.$v4.'</button></a>';
}
echo '<form method="get" style="margin-left:auto;display:flex;gap:6px"><input type="hidden" name="page" value="reservations"><input name="q" value="'.e($qtext).'" placeholder="Search guest or booking..." style="padding:9px 12px;border:1px solid var(--line);border-radius:9px"><button class="btn sm">Search</button></form></div>';
echo '<div class="panel"><table class="tbl"><thead><tr><th>Booking</th><th>Guest</th><th>Check in</th><th>Check out</th><th class="num">Total</th><th class="num">Paid</th><th>Status</th><th></th></tr></thead><tbody>';
foreach($list as $r){ echo '<tr><td>'.e($r['booking_number']).'</td><td><b>'.e($r['full_name']).'</b></td><td>'.fmtdate($r['check_in']).'</td><td>'.fmtdate($r['check_out']).'</td><td class="num">'.money($r['total']).'</td><td class="num">'.money($r['paid']).'</td><td>'.status_badge($r['status']).'</td><td><a class="btn sm" href="'.BASE.'/index.php?page=reservations&view='.(int)$r['id'].'">Open</a></td></tr>'; }
if(!count($list)) echo '<tr><td colspan="8" style="text-align:center;color:var(--muted)">No reservations found.</td></tr>';
echo '</tbody></table></div>';
page_foot();

