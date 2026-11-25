<?php
declare(strict_types=1);

require_once __DIR__.'/../app/enterprise.php';

if(!hp_enterprise_ready(['hp_front_events','hp_handovers','hp_sensitive_actions','reception_records','housekeeping_tasks'])){
  page_head('Front Office','frontdesk');
  echo '<div class="panel"><h2>Upgrade required</h2><p class="hint">The Front Office tables are not installed yet. Run database/sql/patches/2026-11-25_enterprise_expansion.sql before opening this desk.</p></div>';
  page_foot(); exit;
}

function hp_front_event_add(int $reservationId,string $type,string $details,float $amount=0.0,?int $authId=null): void{
  $me=current_user();
  q('INSERT INTO hp_front_events(hotel_id,reservation_id,event_type,details,amount,authorization_id,created_by,created_at) VALUES(1,?,?,?,?,?,?,NOW())',
    [$reservationId,$type,mb_substr($details,0,500),$amount,$authId,(int)($me['id']??0)]);
  audit($type,'reservation',$reservationId,null,['details'=>$details,'amount'=>$amount]);
}

function hp_front_authorized($posted): ?int{
  $authId=(int)$posted;
  if($authId<1) return null;
  $a=row('SELECT * FROM hp_sensitive_actions WHERE id=? AND status=\'approved\'',[$authId]);
  return $a?$authId:null;
}

$act=$_GET['act']??'';
$rid=(int)($_GET['id']??$_POST['reservation_id']??0);
$me=current_user();
$uid=(int)($me['id']??0);

if($act==='feed'){
  header('Content-Type: application/json; charset=utf-8');
  $day0=today().' 00:00:00';
  $day1=date('Y-m-d',strtotime(today().' +1 day')).' 00:00:00';
  $arrivals=(int)val("SELECT COUNT(*) FROM reservations WHERE status IN('pending','confirmed') AND check_in>=? AND check_in<? AND deleted_at IS NULL",[$day0,$day1]);
  $departures=(int)val("SELECT COUNT(*) FROM reservations WHERE status='checked_in' AND check_out>=? AND check_out<? AND deleted_at IS NULL",[$day0,$day1]);
  $outstanding=(float)val("SELECT COALESCE(SUM(total-paid),0) FROM reservations WHERE status IN('pending','confirmed','checked_in') AND paid<total AND deleted_at IS NULL");
  $rev=(int)val('SELECT COUNT(*) FROM reception_records WHERE status=\'open\'');
  $latest=(string)val('SELECT COALESCE(MAX(updated_at),MAX(created_at),\"\") FROM reservations');
  echo json_encode(['arrivals'=>$arrivals,'departures'=>$departures,'outstanding'=>round($outstanding,2),'requests'=>$rev,'signature'=>md5($arrivals.'|'.$departures.'.'.$outstanding.'|'.$rev.'|'.$latest)]);
  exit;
}

if($_SERVER['REQUEST_METHOD']==='POST' && $act){
  switch($act){
   case 'allocate':
    $roomId=(int)($_POST['room_id']??0);
    $r=row("SELECT * FROM reservations WHERE id=? AND status IN('pending','confirmed') AND deleted_at IS NULL",[$rid]);
    $room=row("SELECT * FROM rooms WHERE id=? AND status='available' AND deleted_at IS NULL",[$roomId]);
    if(!$r||!$room){ flash('Choose an open booking and an available room.','bad'); go('frontdesk',['view'=>$rid]); }
    db()->beginTransaction();
    try{
      $st=q('UPDATE reservation_rooms SET room_id=? WHERE reservation_id=? AND room_id IS NULL ORDER BY id LIMIT 1',[$roomId,$rid]);
      if($st->rowCount()<1){
        q('INSERT INTO reservation_rooms(reservation_id,room_type_id,room_id,quantity,nightly_rate) VALUES(?,?,?,1,?)',[$rid,(int)$room['room_type_id'],$roomId,(float)$r['room_rate']]);
      }
      q("UPDATE rooms SET status='reserved' WHERE id=?",[$roomId]);
      db()->commit();
    }catch(Throwable $e){ db()->rollBack(); flash('The room could not be allocated. Please try again.','bad'); go('frontdesk',['view'=>$rid]); }
    hp_front_event_add($rid,'allocation','Room '.$room['room_number'].' allocated');
    flash('Room '.$room['room_number'].' allocated to booking '.$r['booking_number'].'.');
    go('frontdesk',['view'=>$rid]);
    break;

   case 'checkin':
    $r=row("SELECT * FROM reservations WHERE id=? AND status IN('pending','confirmed') AND deleted_at IS NULL",[$rid]);
    if(!$r){ flash('Booking not found or already checked in.','bad'); go('frontdesk',['view'=>$rid]); }
    $need=(int)val('SELECT COALESCE(SUM(quantity),0) FROM reservation_rooms WHERE reservation_id=?',[$rid]);
    $placed=(int)val('SELECT COUNT(*) FROM reservation_rooms WHERE reservation_id=? AND room_id IS NOT NULL',[$rid]);
    if($need<1||$placed<$need){ flash('Allocate '.$need.' room(s) before checking in.','bad'); go('frontdesk',['view'=>$rid]); }
    $ids=array_map('intval',array_column(rows('SELECT DISTINCT room_id FROM reservation_rooms WHERE reservation_id=? AND room_id IS NOT NULL',[$rid]),'room_id'));
    db()->beginTransaction();
    try{
      if($ids) q('UPDATE rooms SET status=\'occupied\' WHERE id IN ('.implode(',',array_fill(0,count($ids),'?')).')',$ids);
      q("UPDATE reservations SET status='checked_in',updated_at=NOW() WHERE id=?",[$rid]);
      db()->commit();
    }catch(Throwable $e){ db()->rollBack(); flash('Check in failed. Please try again.','bad'); go('frontdesk',['view'=>$rid]); }
    hp_front_event_add($rid,'check_in','Guest checked in at the front desk');
    notify_console('frontdesk-checkin-'.$rid,'booking','Guest checked in: '.$r['booking_number'],'Front office completed the check in.',['reservation_id'=>$rid],['director','general_manager'],'reservation',$rid);
    flash('Guest checked in.');
    go('frontdesk',['view'=>$rid]);
    break;

   case 'checkout':
    $r=row("SELECT * FROM reservations WHERE id=? AND status='checked_in' AND deleted_at IS NULL",[$rid]);
    if(!$r){ flash('Only guests in house can be checked out.','bad'); go('frontdesk',['view'=>$rid]); }
    $ids=array_map('intval',array_column(rows('SELECT DISTINCT room_id FROM reservation_rooms WHERE reservation_id=? AND room_id IS NOT NULL',[$rid]),'room_id'));
    $dept=(int)(val("SELECT id FROM departments WHERE name LIKE '%House%' LIMIT 1")?:1);
    db()->beginTransaction();
    try{
      if($ids) q('UPDATE rooms SET status=\'dirty\' WHERE id IN ('.implode(',',array_fill(0,count($ids),'?')).')',$ids);
      foreach($ids as $roomId){
        q('INSERT INTO housekeeping_tasks(property_id,room_id,assigned_to,task_type,priority,status,notes,created_at) VALUES(1,?,NULL,\'cleaning\',\'normal\',\'pending\',?,NOW())',[$roomId,'Checkout from '.($r['booking_number']??'')]);
      }
      q("UPDATE reservations SET status='checked_out',updated_at=NOW() WHERE id=?",[$rid]);
      db()->commit();
    }catch(Throwable $e){ db()->rollBack(); flash('Check out failed. Please try again.','bad'); go('frontdesk',['view'=>$rid]); }
    hp_front_event_add($rid,'check_out','Guest checked out; rooms sent to housekeeping');
    notify_console('frontdesk-checkout-'.$rid,'booking','Guest checked out: '.$r['booking_number'],'The room is dirty and a cleaning task was raised.',['reservation_id'=>$rid],['director','general_manager','housekeeping'],'reservation',$rid);
    flash('Guest checked out and housekeeping notified.');
    go('frontdesk',['view'=>$rid]);
    break;

   case 'early':
    $r=row("SELECT * FROM reservations WHERE id=? AND status IN('pending','confirmed') AND deleted_at IS NULL",[$rid]);
    if(!$r){ flash('Booking not found.','bad'); go('frontdesk',['view'=>$rid]); }
    $note=trim((string)($_POST['note']??'Early check in requested'));
    q("UPDATE reservations SET check_in=NOW(),updated_at=NOW() WHERE id=?",[$rid]);
    hp_front_event_add($rid,'early_check_in',$note);
    flash('Early check in recorded.');
    go('frontdesk',['view'=>$rid]);
    break;

   case 'extend':
    $r=row("SELECT * FROM reservations WHERE id=? AND status IN('confirmed','checked_in') AND deleted_at IS NULL",[$rid]);
    $newOut=hp_date_input($_POST['new_check_out']??'');
    if(!$r||!$newOut||$newOut<=substr((string)$r['check_out'],0,10)){ flash('Enter a departure date after the current one.','bad'); go('frontdesk',['view'=>$rid]); }
    if((strtotime($newOut)-strtotime(substr((string)$r['check_in'],0,10)))/86400>60){ flash('An extension cannot exceed 60 nights.','bad'); go('frontdesk',['view'=>$rid]); }
    $nights=max(1,(int)ceil((strtotime($newOut.' 11:00:00')-strtotime(substr((string)$r['check_in'],0,10).' 14:00:00'))/86400));
    $rooms=max(1,(int)val('SELECT COALESCE(SUM(quantity),0) FROM reservation_rooms WHERE reservation_id=?',[$rid]));
    $subtotal=round((float)$r['room_rate']*$rooms*$nights,2);
    $oldSub=(float)$r['subtotal'];
    $tax=$oldSub>0?round(((float)$r['tax']/$oldSub)*$subtotal,2):0;
    $total=round($subtotal+$tax,2);
    $delta=round($total-(float)$r['total'],2);
    db()->beginTransaction();
    try{
      q('UPDATE reservations SET check_out=?,nights=?,subtotal=?,tax=?,total=?,updated_at=NOW() WHERE id=?',[$newOut.' 11:00:00',$nights,$subtotal,$tax,$total,$rid]);
      if(abs($delta)>0.01) q('INSERT INTO guest_folio_entries(hotel_id,reservation_id,entry_type,description,amount,user_id,created_at) VALUES(1,?,\'adjustment\',?,?,?,NOW())',[$rid,'Stay extension adjustment '.($delta>0?'increase':'reduction'),abs($delta),$uid]);
      db()->commit();
    }catch(Throwable $e){ db()->rollBack(); flash('The extension could not be saved.','bad'); go('frontdesk',['view'=>$rid]); }
    hp_front_event_add($rid,'extension','Departure extended to '.$newOut,$delta);
    flash('Stay extended to '.$newOut.'. Folio adjusted by '.money(abs($delta)).'.');
    go('frontdesk',['view'=>$rid]);
    break;

   case 'late':
    $r=row("SELECT * FROM reservations WHERE id=? AND status='checked_in' AND deleted_at IS NULL",[$rid]);
    if(!$r){ flash('Only a guest in house can request late checkout.','bad'); go('frontdesk',['view'=>$rid]); }
    $reason=trim((string)($_POST['reason']??''));
    $authId=hp_front_authorized($_POST['authorization_id']??0);
    if($authId===null){
      $authId=hp_sensitive_request('late_checkout','reservation',$rid,0,$reason!==''?$reason:'Late checkout request');
      flash($authId?'Late checkout sent for authorization.':'The authorization queue is not installed.');
    }else{
      $until=trim((string)($_POST['until']??'14:00'));
      hp_front_event_add($rid,'late_check_out','Late checkout approved until '.$until,0,$authId);
      flash('Late checkout approved until '.e($until).'.');
    }
    go('frontdesk',['view'=>$rid]);
    break;

   case 'transfer':
    $r=row("SELECT * FROM reservations WHERE id=? AND status='checked_in' AND deleted_at IS NULL",[$rid]);
    $roomId=(int)($_POST['room_id']??0);
    $room=row("SELECT * FROM rooms WHERE id=? AND status='available' AND deleted_at IS NULL",[$roomId]);
    $current=row('SELECT * FROM reservation_rooms WHERE reservation_id=? AND room_id IS NOT NULL ORDER BY id LIMIT 1',[$rid]);
    if(!$r||!$room||!$current){ flash('Choose a guest in house, a current room and an available destination room.','bad'); go('frontdesk',['view'=>$rid]); }
    db()->beginTransaction();
    try{
      q('UPDATE reservation_rooms SET room_id=? WHERE id=?',[$roomId,(int)$current['id']]);
      q("UPDATE rooms SET status='dirty' WHERE id=?",[(int)$current['room_id']]);
      q("UPDATE rooms SET status='occupied' WHERE id=?",[$roomId]);
      db()->commit();
    }catch(Throwable $e){ db()->rollBack(); flash('Room transfer failed.','bad'); go('frontdesk',['view'=>$rid]); }
    hp_front_event_add($rid,'transfer','Transferred from room '.(string)val('SELECT room_number FROM rooms WHERE id=?',[(int)$current['room_id']]).' to '.$room['room_number']);
    notify_console('frontdesk-transfer-'.$rid,'incident','Room transfer: '.$r['booking_number'],'Housekeeping must clean the vacated room.',['reservation_id'=>$rid],['housekeeping','director','general_manager'],'reservation',$rid);
    flash('Guest transferred to room '.$room['room_number'].'.');
    go('frontdesk',['view'=>$rid]);
    break;

   case 'upgrade':
    $r=row("SELECT * FROM reservations WHERE id=? AND status IN('confirmed','checked_in') AND deleted_at IS NULL",[$rid]);
    $roomId=(int)($_POST['room_id']??0);
    $room=row("SELECT * FROM rooms WHERE id=? AND status='available' AND deleted_at IS NULL",[$roomId]);
    $reason=trim((string)($_POST['reason']??''));
    if(!$r||!$room||$reason===''){ flash('Choose an available room and give a reason for the upgrade.','bad'); go('frontdesk',['view'=>$rid]); }
    $authId=hp_front_authorized($_POST['authorization_id']??0);
    if($authId===null){
      $newRate=(float)val('SELECT base_rate FROM room_types WHERE id=?',[(int)$room['room_type_id']]);
      $delta=max(0,round(($newRate-(float)$r['room_rate'])*(int)$r['nights'],2));
      $created=hp_sensitive_request('upgrade','reservation',$rid,$delta,$reason);
      flash($created?'Upgrade sent for authorization.':'The authorization queue is not installed.');
      go('frontdesk',['view'=>$rid]);
    }
    $newRate=(float)val('SELECT base_rate FROM room_types WHERE id=?',[(int)$room['room_type_id']]);
    $oldRate=(float)$r['room_rate'];
    $delta=round(($newRate-$oldRate)*(int)$r['nights'],2);
    $rooms=max(1,(int)val('SELECT COALESCE(SUM(quantity),0) FROM reservation_rooms WHERE reservation_id=?',[$rid]));
    $subtotal=round($newRate*$rooms*(int)$r['nights'],2);
    $tax=$oldSub=(float)$r['subtotal'];
    $tax=$oldSub>0?round(((float)$r['tax']/$oldSub)*$subtotal,2):0;
    $total=round($subtotal+$tax,2);
    db()->beginTransaction();
    try{
      q('UPDATE reservation_rooms SET room_type_id=?,room_id=?,nightly_rate=? WHERE reservation_id=? ORDER BY id LIMIT 1',[(int)$room['room_type_id'],$roomId,$newRate,$rid]);
      q("UPDATE rooms SET status='occupied' WHERE id=?",[$roomId]);
      q('UPDATE reservations SET room_rate=?,subtotal=?,tax=?,total=?,updated_at=NOW() WHERE id=?',[$newRate,$subtotal,$tax,$total,$rid]);
      if(abs($delta)>0.01) q('INSERT INTO guest_folio_entries(hotel_id,reservation_id,entry_type,description,amount,user_id,created_at) VALUES(1,?,\'adjustment\',?,?,?,NOW())',[$rid,'Approved room upgrade',abs($delta),$uid]);
      db()->commit();
    }catch(Throwable $e){ db()->rollBack(); flash('The upgrade could not be applied.','bad'); go('frontdesk',['view'=>$rid]); }
    hp_front_event_add($rid,'upgrade','Upgraded to '.$room['room_number'],$delta,$authId);
    flash('Upgrade applied and folio adjusted.');
    go('frontdesk',['view'=>$rid]);
    break;

   case 'cancel':
    $r=row("SELECT * FROM reservations WHERE id=? AND status IN('pending','confirmed') AND deleted_at IS NULL",[$rid]);
    $reason=trim((string)($_POST['reason']??''));
    if(!$r||$reason===''){ flash('Give a cancellation reason.','bad'); go('frontdesk',['view'=>$rid]); }
    $authId=hp_front_authorized($_POST['authorization_id']??0);
    if($authId===null){
      $created=hp_sensitive_request('cancellation','reservation',$rid,(float)$r['total'],$reason);
      flash($created?'Cancellation sent for authorization.':'The authorization queue is not installed.');
      go('frontdesk',['view'=>$rid]);
    }
    $ids=array_map('intval',array_column(rows('SELECT DISTINCT room_id FROM reservation_rooms WHERE reservation_id=? AND room_id IS NOT NULL',[$rid]),'room_id'));
    db()->beginTransaction();
    try{
      if($ids) q('UPDATE rooms SET status=\'available\' WHERE id IN ('.implode(',',array_fill(0,count($ids),'?')).')',$ids);
      q("UPDATE reservations SET status='cancelled',updated_at=NOW() WHERE id=?",[$rid]);
      db()->commit();
    }catch(Throwable $e){ db()->rollBack(); flash('Cancellation failed.','bad'); go('frontdesk',['view'=>$rid]); }
    hp_front_event_add($rid,'cancellation',$reason,0,$authId);
    flash('Booking cancelled and any room released.');
    go('frontdesk',['view'=>$rid]);
    break;

   case 'refund':
    $r=row('SELECT * FROM reservations WHERE id=? AND deleted_at IS NULL',[$rid]);
    $amount=hp_money_input($_POST['amount']??0);
    $reason=trim((string)($_POST['reason']??''));
    if(!$r||$amount<=0||$reason===''){ flash('Enter a refund amount and reason.','bad'); go('frontdesk',['view'=>$rid]); }
    $amount=min($amount,(float)$r['paid']);
    if($amount<=0){ flash('This booking has no paid balance to refund.','bad'); go('frontdesk',['view'=>$rid]); }
    $authId=hp_front_authorized($_POST['authorization_id']??0);
    if($authId===null){
      $created=hp_sensitive_request('refund','reservation',$rid,$amount,$reason);
      flash($created?'Refund sent for authorization.':'The authorization queue is not installed.');
      go('frontdesk',['view'=>$rid]);
    }
    $pay=row("SELECT * FROM payments WHERE reservation_id=? AND status='successful' ORDER BY id DESC LIMIT 1",[$rid]);
    db()->beginTransaction();
    try{
      q('INSERT INTO guest_folio_entries(hotel_id,reservation_id,entry_type,description,amount,user_id,created_at) VALUES(1,?,\'refund\',?,?,?,NOW())',[$rid,'Approved refund: '.$reason,$amount,$uid]);
      q('UPDATE reservations SET paid=GREATEST(paid-?,0),updated_at=NOW() WHERE id=?',[$amount,$rid]);
      if($pay && $amount>=(float)$pay['amount']) q("UPDATE payments SET status='refunded',verified_at=NOW(),verified_by=?,verification_note=? WHERE id=?",['front_office','Refunded by front office authorization '.$authId,(int)$pay['id']]);
      db()->commit();
    }catch(Throwable $e){ db()->rollBack(); flash('The refund could not be recorded.','bad'); go('frontdesk',['view'=>$rid]); }
    hp_front_event_add($rid,'refund','Approved refund of '.money($amount),$amount,$authId);
    flash('Refund of '.money($amount).' recorded.');
    go('frontdesk',['view'=>$rid]);
    break;

   case 'deposit':
    $r=row("SELECT * FROM reservations WHERE id=? AND deleted_at IS NULL",[$rid]);
    $amount=hp_money_input($_POST['amount']??0);
    $method=$_POST['method']??'cash';
    $methods=payment_methods();
    if(!$r||$amount<=0||!isset($methods[$method])){ flash('Enter a valid deposit amount and method.','bad'); go('frontdesk',['view'=>$rid]); }
    q('INSERT INTO payments(hotel_id,user_id,reservation_id,amount,method,status,created_at) VALUES(1,?,?,?,?,\'successful\',NOW())',[$uid,$rid,$amount,$method]);
    $payId=(int)db()->lastInsertId();
    q('INSERT INTO guest_folio_entries(hotel_id,reservation_id,entry_type,description,amount,user_id,created_at) VALUES(1,?,\'payment\',?,?,?,NOW())',[$rid,'Deposit by '.ucfirst(str_replace('_',' ',$method)),$amount,$uid]);
    q('UPDATE reservations SET paid=paid+?,updated_at=NOW() WHERE id=?',[$amount,$rid]);
    hp_front_event_add($rid,'deposit','Deposit of '.money($amount).' received',$amount);
    notify_console('frontdesk-deposit-'.$payId,'payment','Deposit recorded: '.$r['booking_number'],money($amount).' by '.str_replace('_',' ',$method),['reservation_id'=>$rid,'payment_id'=>$payId],['cashier','accountant','director'],'payment',$payId);
    flash('Deposit of '.money($amount).' recorded.');
    go('frontdesk',['view'=>$rid]);
    break;

   case 'request':
    $guestId=(int)($_POST['guest_id']??0);
    $title=trim((string)($_POST['title']??''));
    $desc=trim((string)($_POST['description']??''));
    $dept=(int)(val("SELECT id FROM departments WHERE name LIKE '%Front%' LIMIT 1")?:1);
    if($guestId<1||$title===''||$desc===''){ flash('Choose a guest and enter a request.','bad'); go('frontdesk'); }
    q('INSERT INTO reception_records(property_id,department_id,created_by,guest_id,category,priority,title,description,status,created_at,updated_at) VALUES(1,?,?,?,\'Guest Request\',?,?,?,\'open\',NOW(),NOW())',[$dept,$uid,$guestId,$_POST['priority']??'normal',$title,$desc]);
    audit('guest_request','guest',$guestId,null,['title'=>$title]);
    notify_console('frontdesk-request-'.(int)db()->lastInsertId(),'incident','Guest request: '.$title,$desc,['guest_id'=>$guestId],['receptionist','director','general_manager'],'guest',$guestId);
    flash('Guest request recorded.');
    go('frontdesk');
    break;

   case 'handover':
    $expected=hp_money_input($_POST['cash_expected']??0);
    $counted=hp_money_input($_POST['cash_counted']??0);
    $incoming=(int)($_POST['incoming_user_id']??0);
    $label=trim((string)($_POST['shift_label']??''));
    $issues=trim((string)($_POST['open_issues']??''));
    $notes=trim((string)($_POST['handover_notes']??''));
    if($label===''||$incoming<1){ flash('Enter the shift name and the incoming colleague.','bad'); go('frontdesk',['act'=>'handovers']); }
    q('INSERT INTO hp_handovers(hotel_id,handover_date,shift_label,outgoing_user_id,incoming_user_id,cash_expected,cash_counted,variance,open_issues,handover_notes,created_by,created_at) VALUES(1,CURDATE(),?,?,?,?,?,?,?,?,?,NOW())',[$label,$uid,$incoming,$expected,$counted,round($counted-$expected,2),$issues,$notes,$uid]);
    $hid=(int)db()->lastInsertId();
    audit('handover','handover',$hid,['shift'=>$label]);
    notify_console('frontdesk-handover-'.$hid,'incident','Shift handover: '.$label,'Cash variance '.money(round($counted-$expected,2)).'.',['handover_id'=>$hid],['receptionist','cashier','director'],'handover',$hid);
    flash('Handover recorded for the incoming colleague.');
    go('frontdesk',['act'=>'handovers']);
    break;

   case 'handover_ack':
    $hid=(int)($_POST['handover_id']??0);
    $h=row('SELECT * FROM hp_handovers WHERE id=? AND acknowledged_at IS NULL',[$hid]);
    if(!$h){ flash('Handover not found or already acknowledged.','bad'); go('frontdesk',['act'=>'handovers']); }
    q('UPDATE hp_handovers SET incoming_user_id=?,acknowledged_at=NOW() WHERE id=?',[$uid,$hid]);
    audit('handover_ack','handover',$hid);
    flash('Handover acknowledged.');
    go('frontdesk',['act'=>'handovers']);
    break;
  }
}

if($act==='card'){
  $r=row('SELECT r.*,g.full_name,g.phone,g.email,g.nationality,g.id_type,g.id_number FROM reservations r JOIN guests g ON g.id=r.guest_id WHERE r.id=?',[$rid]);
  if(!$r){ page_head('Registration card','frontdesk'); echo '<div class="panel"><p>Booking not found.</p></div>'; page_foot(); exit; }
  $rooms=rows('SELECT rn.room_number,rt.name rtype FROM reservation_rooms rr LEFT JOIN rooms rn ON rn.id=rr.room_id LEFT JOIN room_types rt ON rt.id=rr.room_type_id WHERE rr.reservation_id=?',[$rid]);
  page_head('Registration card '.e($r['booking_number']),'frontdesk','Guest registration and identification record');
  echo '<style>@media print{.side,.top,.toTop,.toolbar,.askBtn,.voiceBtn{display:none!important}.content,.main{margin:0!important;padding:0!important;width:100%!important}.regCard{box-shadow:none!important;border:0!important}}</style>';
  echo '<div class="toolbar"><button class="btn" onclick="window.print();return false">Print registration card</button> <a class="btnGhost sm" href="'.BASE.'/index.php?page=frontdesk&view='.$rid.'">Back to booking</a></div>';
  echo '<div class="panel regCard" style="max-width:780px;margin:auto;padding:28px">';
  echo '<h2 style="text-align:center">HOTEL PARADISE ON THE NILE</h2><p style="text-align:center;margin-top:-8px">Jinja, Uganda · Guest Registration Card</p><hr>';
  echo '<div class="res-meta">';
  echo '<div class="field"><label>Guest</label><b>'.e($r['full_name']).'</b></div>';
  echo '<div class="field"><label>Booking</label><b>'.e($r['booking_number']).'</b></div>';
  echo '<div class="field"><label>Telephone</label><b>'.e($r['phone']??'').'</b></div>';
  echo '<div class="field"><label>Email</label><b>'.e($r['email']??'').'</b></div>';
  echo '<div class="field"><label>Nationality</label><b>'.e($r['nationality']??'').'</b></div>';
  echo '<div class="field"><label>ID type</label><b>'.e($r['id_type']??'').'</b></div>';
  echo '<div class="field"><label>ID number</label><b>'.e($r['id_number']??'').'</b></div>';
  echo '<div class="field"><label>Check in</label><b>'.fmtdt($r['check_in']).'</b></div>';
  echo '<div class="field"><label>Check out</label><b>'.fmtdt($r['check_out']).'</b></div>';
  echo '<div class="field"><label>Rate per night</label><b>'.money($r['room_rate']).'</b></div>';
  echo '<div class="field"><label>Total</label><b>'.money($r['total']).'</b></div>';
  echo '</div><h3>Rooms</h3><table class="tbl"><thead><tr><th>Room</th><th>Type</th></tr></thead><tbody>';
  foreach($rooms as $rm) echo '<tr><td>'.e($rm['room_number']??'Not allocated').'</td><td>'.e($rm['rtype']??'').'</td></tr>';
  echo '</tbody></table><p style="margin-top:30px">Guest signature: ____________________________ &nbsp;&nbsp; Reception: ____________________________</p></div>';
  page_foot(); exit;
}

$day0=today().' 00:00:00';
$day1=date('Y-m-d',strtotime(today().' +1 day')).' 00:00:00';
$arrivals=rows("SELECT r.id,r.booking_number,r.check_in,r.status,r.total,r.paid,g.full_name,g.phone,rt.name rtype FROM reservations r JOIN guests g ON g.id=r.guest_id LEFT JOIN reservation_rooms rr ON rr.reservation_id=r.id LEFT JOIN room_types rt ON rt.id=rr.room_type_id WHERE r.status IN('pending','confirmed') AND r.check_in>=? AND r.check_in<? AND r.deleted_at IS NULL ORDER BY r.check_in",[$day0,$day1]);
$departures=rows("SELECT r.id,r.booking_number,r.check_out,r.total,r.paid,g.full_name,rn.room_number FROM reservations r JOIN guests g ON g.id=r.guest_id LEFT JOIN reservation_rooms rr ON rr.reservation_id=r.id LEFT JOIN rooms rn ON rn.id=rr.room_id WHERE r.status='checked_in' AND r.check_out>=? AND r.check_out<? AND r.deleted_at IS NULL ORDER BY r.check_out",[$day0,$day1]);
$outstanding=rows("SELECT r.id,r.booking_number,g.full_name,r.total,r.paid,r.status FROM reservations r JOIN guests g ON g.id=r.guest_id WHERE r.status IN('pending','confirmed','checked_in') AND r.paid<r.total AND r.deleted_at IS NULL ORDER BY (r.total-r.paid) DESC LIMIT 30");
$openRequests=rows("SELECT rr.id,rr.title,rr.priority,rr.created_at,g.full_name FROM reception_records rr LEFT JOIN guests g ON g.id=rr.guest_id WHERE rr.status='open' ORDER BY rr.created_at DESC LIMIT 20");
$handovers=rows('SELECT h.*,u.name outgoing,v.name incoming FROM hp_handovers h LEFT JOIN users u ON u.id=h.outgoing_user_id LEFT JOIN users v ON v.id=h.incoming_user_id ORDER BY h.id DESC LIMIT 20');
$guests=rows('SELECT id,full_name,phone FROM guests WHERE deleted_at IS NULL ORDER BY full_name LIMIT 300');
$users=rows("SELECT id,name FROM users WHERE status='active' ORDER BY name");
$roomOptions=rows("SELECT r.id,r.room_number,rt.name rtype FROM rooms r JOIN room_types rt ON rt.id=r.room_type_id WHERE r.status='available' AND r.deleted_at IS NULL ORDER BY r.room_number");
$pendingAuth=rows("SELECT a.*,r.booking_number FROM hp_sensitive_actions a LEFT JOIN reservations r ON r.id=a.entity_id WHERE a.status='pending' AND a.entity_type='reservation' ORDER BY a.id DESC LIMIT 20");

page_head('Front Office','frontdesk','Live arrivals, departures and stay changes');
echo '<script>(function(){var k="hpn-frontdesk-signature";setInterval(function(){fetch("'.BASE.'/index.php?page=frontdesk&act=feed",{credentials:"same-origin"}).then(function(r){return r.json()}).then(function(d){var p=localStorage.getItem(k);if(p&&p!==d.signature)location.reload();localStorage.setItem(k,d.signature)}).catch(function(){})},30000)})();</script>';
echo '<div class="kpis">';
kpi_card('Arrivals today',(string)count($arrivals),'Expected check ins');
kpi_card('Departures today',(string)count($departures),'Expected check outs');
kpi_card('Outstanding bookings',(string)count($outstanding),'Balance due');
kpi_card('Open requests',(string)count($openRequests),'Front desk queue');
echo '</div>';

echo '<div class="toolbar"><a class="btn" href="'.BASE.'/index.php?page=reservations&act=new">+ New reservation</a>';
echo '<a class="btnGhost sm" href="'.BASE.'/index.php?page=frontdesk&act=handovers">Shift handovers</a>';
echo '<a class="btnGhost sm" href="'.BASE.'/index.php?page=frontdesk&view='.$rid.'">Open selected booking</a></div>';

if($rid){
  $r=row('SELECT r.*,g.full_name,g.phone,g.email,g.nationality,g.id_type,g.id_number FROM reservations r JOIN guests g ON g.id=r.guest_id WHERE r.id=?',[$rid]);
  if($r){
   $allocated=rows('SELECT rr.id,rr.room_id,rr.quantity,rr.nightly_rate,rn.room_number,rt.name rtype FROM reservation_rooms rr LEFT JOIN rooms rn ON rn.id=rr.room_id LEFT JOIN room_types rt ON rt.id=rr.room_type_id WHERE rr.reservation_id=? ORDER BY rr.id',[$rid]);
   $events=rows('SELECT e.*,u.name actor FROM hp_front_events e LEFT JOIN users u ON u.id=e.created_by WHERE e.reservation_id=? ORDER BY e.id DESC LIMIT 20',[$rid]);
   $auths=rows('SELECT a.*,u.name requester FROM hp_sensitive_actions a LEFT JOIN users u ON u.id=a.requested_by WHERE a.entity_type=\'reservation\' AND a.entity_id=? ORDER BY a.id DESC LIMIT 12',[$rid]);
   $balance=max(0,(float)$r['total']-(float)$r['paid']);
   echo '<div class="panel"><h2>'.e($r['booking_number']).' · '.e($r['full_name']).'</h2><p class="hint">'.status_badge($r['status']).' · Balance '.money($balance).' · <a href="'.BASE.'/index.php?page=frontdesk&act=card&id='.$rid.'">Print registration card</a></p>';
   echo '<table class="tbl"><thead><tr><th>Room</th><th>Type</th><th class="num">Rate</th></tr></thead><tbody>';
   foreach($allocated as $a) echo '<tr><td>'.e($a['room_number']??'Not allocated').'</td><td>'.e($a['rtype']??'').'</td><td class="num">'.money($a['nightly_rate']).'</td></tr>';
   echo '</tbody></table>';
   echo '<div class="formGrid" style="margin-top:14px">';
   echo '<div><h3>Allocate an available room</h3>'; form_open('frontdesk','allocate',['view'=>$rid]);
   echo '<input type="hidden" name="reservation_id" value="'.$rid.'"><div class="field"><label>Room</label><select name="room_id" required><option value="">Choose room...</option>';
   foreach($roomOptions as $rm) echo '<option value="'.(int)$rm['id'].'">'.e($rm['room_number'].' · '.$rm['rtype']).'</option>';
   echo '</select></div><button class="btn sm">Allocate room</button>'; form_close(); echo '</div>';
   echo '<div><h3>Extension</h3>'; form_open('frontdesk','extend',['view'=>$rid]);
   echo '<input type="hidden" name="reservation_id" value="'.$rid.'">'.field('New departure date','new_check_out',date('Y-m-d',strtotime((string)$r['check_out'].' +1 day')),'date','',true).'<button class="btn sm">Extend stay</button>'; form_close(); echo '</div>';
   echo '<div><h3>Transfer / upgrade</h3>'; form_open('frontdesk','transfer',['view'=>$rid]);
   echo '<input type="hidden" name="reservation_id" value="'.$rid.'"><div class="field"><label>Destination room</label><select name="room_id" required><option value="">Choose room...</option>';
   foreach($roomOptions as $rm) echo '<option value="'.(int)$rm['id'].'">'.e($rm['room_number'].' · '.$rm['rtype']).'</option>';
   echo '</select></div><button class="btn sm">Transfer guest</button>'; form_close();
   form_open('frontdesk','upgrade',['view'=>$rid]);
   echo '<input type="hidden" name="reservation_id" value="'.$rid.'"><div class="field"><label>Upgrade room</label><select name="room_id" required><option value="">Choose room...</option>';
   foreach($roomOptions as $rm) echo '<option value="'.(int)$rm['id'].'">'.e($rm['room_number'].' · '.$rm['rtype']).'</option>';
   echo '</select></div>'.field('Reason','reason','','text','Required for authorization',true).'<button class="btnGhost sm">Request upgrade</button>'; form_close(); echo '</div>';
   echo '</div>';
   echo '<div class="toolbar" style="margin-top:14px">';
   if(in_array($r['status'],['pending','confirmed'],true)){
    form_open('frontdesk','checkin',['view'=>$rid]); echo '<input type="hidden" name="reservation_id" value="'.$rid.'"><button class="btn">Check in</button>'; form_close();
    form_open('frontdesk','early',['view'=>$rid]); echo '<input type="hidden" name="reservation_id" value="'.$rid.'"><input type="hidden" name="note" value="Early check in recorded"><button class="btnGhost">Early check in</button>'; form_close();
   }
   if($r['status']==='checked_in'){
    form_open('frontdesk','checkout',['view'=>$rid]); echo '<input type="hidden" name="reservation_id" value="'.$rid.'"><button class="btn danger">Check out</button>'; form_close();
    form_open('frontdesk','late',['view'=>$rid]); echo '<input type="hidden" name="reservation_id" value="'.$rid.'">'.field('Reason','reason','','text','Late checkout reason',true).'<button class="btnGhost sm">Request late checkout</button>'; form_close();
   }
   if(in_array($r['status'],['pending','confirmed'],true)){
    form_open('frontdesk','cancel',['view'=>$rid]); echo '<input type="hidden" name="reservation_id" value="'.$rid.'">'.field('Reason','reason','','text','Cancellation reason',true).'<button class="btnGhost sm">Request cancellation</button>'; form_close();
   }
   echo '</div>';
   echo '<div class="twoCol" style="margin-top:16px"><div><h3>Deposit / payment</h3>'; form_open('frontdesk','deposit',['view'=>$rid]);
   echo '<input type="hidden" name="reservation_id" value="'.$rid.'">'.field('Amount','amount',(string)(int)$balance,'number','',true);
   echo '<div class="field"><label>Method</label><select name="method">'; foreach(payment_methods() as $k=>$v) echo '<option value="'.e($k).'">'.e($v).'</option>'; echo '</select></div><button class="btn sm">Record payment</button>'; form_close();
   echo '<h3 style="margin-top:14px">Refund</h3>'; form_open('frontdesk','refund',['view'=>$rid]);
   echo '<input type="hidden" name="reservation_id" value="'.$rid.'">'.field('Amount','amount','','number','',true).field('Reason','reason','','text','Required for authorization',true).'<button class="btnGhost sm">Request refund</button>'; form_close(); echo '</div>';
   echo '<div><h3>Pending authorizations</h3>';
   if(!$auths) echo '<p class="emptyLine">No authorization requests for this booking.</p>';
   else foreach($auths as $a) echo '<div class="li"><span><b>'.e(str_replace('_',' ',$a['action_type'])).'</b><br><small>'.e($a['reason']).' · '.e($a['status']).'</small></span>'.badge($a['status'],$a['status']==='approved'?'ok':($a['status']==='rejected'?'bad':'warn')).'</div>';
   echo '<h3 style="margin-top:14px">Stay events</h3>';
   if(!$events) echo '<p class="emptyLine">No stay events recorded.</p>';
   else foreach($events as $ev) echo '<div class="li"><span><b>'.e(str_replace('_',' ',$ev['event_type'])).'</b><br><small>'.e($ev['details']??'').' · '.e($ev['actor']??'System').'</small></span><b>'.($ev['amount']>0?money($ev['amount']):'').'</b></div>';
   echo '</div></div></div>';
  }
}

echo '<div class="twoCol"><div><div class="panel"><h2>Arrivals today</h2><p class="hint">Pending and confirmed reservations due in.</p><table class="tbl"><thead><tr><th>Booking</th><th>Guest</th><th>Time</th><th>Type</th><th></th></tr></thead><tbody>';
foreach($arrivals as $a) echo '<tr><td>'.e($a['booking_number']).'</td><td><b>'.e($a['full_name']).'</b><br><small>'.e($a['phone']??'').'</small></td><td>'.fmtdt($a['check_in']).'</td><td>'.e($a['rtype']??'').'</td><td><a class="btn sm" href="'.BASE.'/index.php?page=frontdesk&view='.(int)$a['id'].'">Open</a></td></tr>';
if(!$arrivals) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">No arrivals today.</td></tr>';
echo '</tbody></table></div>';
echo '<div class="panel"><h2>Guest requests</h2><p class="hint">Open requests raised at the desk.</p><table class="tbl"><thead><tr><th>Guest</th><th>Request</th><th>Priority</th></tr></thead><tbody>';
foreach($openRequests as $r) echo '<tr><td>'.e($r['full_name']??'Guest').'</td><td>'.e($r['title']).'</td><td>'.status_badge($r['priority']).'</td></tr>';
if(!$openRequests) echo '<tr><td colspan="3" style="text-align:center;color:var(--muted)">No open requests.</td></tr>';
echo '</tbody></table></div></div>';

echo '<div><div class="panel"><h2>Departures today</h2><p class="hint">Guests in house due to leave.</p><table class="tbl"><thead><tr><th>Guest</th><th>Room</th><th>Time</th><th></th></tr></thead><tbody>';
foreach($departures as $d) echo '<tr><td><b>'.e($d['full_name']).'</b></td><td>'.e($d['room_number']??'Not allocated').'</td><td>'.fmtdt($d['check_out']).'</td><td><a class="btn sm" href="'.BASE.'/index.php?page=frontdesk&view='.(int)$d['id'].'">Open</a></td></tr>';
if(!$departures) echo '<tr><td colspan="4" style="text-align:center;color:var(--muted)">No departures today.</td></tr>';
echo '</tbody></table></div>';
echo '<div class="panel"><h2>Outstanding payments</h2><p class="hint">Bookings with a balance due.</p><table class="tbl"><thead><tr><th>Booking</th><th>Guest</th><th class="num">Balance</th></tr></thead><tbody>';
foreach($outstanding as $o) echo '<tr><td><a href="'.BASE.'/index.php?page=frontdesk&view='.(int)$o['id'].'">'.e($o['booking_number']).'</a></td><td>'.e($o['full_name']).'</td><td class="num">'.money((float)$o['total']-(float)$o['paid']).'</td></tr>';
if(!$outstanding) echo '<tr><td colspan="3" style="text-align:center;color:var(--muted)">All bookings are settled.</td></tr>';
echo '</tbody></table></div></div></div>';

echo '<div class="panel"><h2>Raise a guest request</h2>'; form_open('frontdesk','request');
echo '<div class="formGrid"><div class="field"><label>Guest</label><select name="guest_id" required><option value="">Choose guest...</option>';
foreach($guests as $g) echo '<option value="'.(int)$g['id'].'">'.e($g['full_name'].' ('.$g['phone'].')').'</option>';
echo '</select></div>'.field('Title','title','','text','e.g. Extra towels',true);
echo '<div class="field"><label>Priority</label><select name="priority">'; foreach(['low'=>'Low','normal'=>'Normal','high'=>'High','urgent'=>'Urgent'] as $k=>$v) echo '<option value="'.e($k).'"'.($k==='normal'?' selected':'').'>'.e($v).'</option>'; echo '</select></div>';
echo '</div>'.area('Request','description','','What does the guest need?','',3).'<button class="btn">Record request</button>'; form_close(); echo '</div>';

if($act==='handovers'){
  echo '<div class="panel"><h2>Shift handover</h2><p class="hint">Record the cash position and open issues for the incoming colleague.</p>';
  form_open('frontdesk','handover');
  echo '<div class="formGrid">'.field('Shift','shift_label','e.g. Morning 06:00-14:00','text','',true);
  echo '<div class="field"><label>Incoming colleague</label><select name="incoming_user_id" required><option value="">Choose colleague...</option>';
  foreach($users as $u) echo '<option value="'.(int)$u['id'].'">'.e($u['name']).'</option>';
  echo '</select></div>'.field('Expected cash','cash_expected','0','number').field('Counted cash','cash_counted','0','number').'</div>';
  area('Open issues','open_issues','','Guests, rooms or payments still outstanding','',3);
  area('Handover notes','handover_notes','','Anything the next shift must know','',3);
  echo '<button class="btn">Save handover</button>'; form_close(); echo '</div>';
}

echo '<div class="panel"><h2>Handover register</h2><table class="tbl"><thead><tr><th>Date</th><th>Shift</th><th>Outgoing</th><th>Incoming</th><th class="num">Variance</th><th>Acknowledged</th><th></th></tr></thead><tbody>';
foreach($handovers as $h) echo '<tr><td>'.e($h['handover_date']).'</td><td>'.e($h['shift_label']).'</td><td>'.e($h['outgoing']??'').'</td><td>'.e($h['incoming']??'Pending').'</td><td class="num">'.money($h['variance']).'</td><td>'.($h['acknowledged_at']?fmtdt($h['acknowledged_at']):badge('Awaiting','warn')).'</td><td>';
if(!$h['acknowledged_at']){ form_open('frontdesk','handover_ack'); echo '<input type="hidden" name="handover_id" value="'.(int)$h['id'].'"><button class="btn sm">Acknowledge</button>'; form_close(); }
echo '</td></tr>';
if(!$handovers) echo '<tr><td colspan="7" style="text-align:center;color:var(--muted)">No handovers recorded yet.</td></tr>';
echo '</tbody></table></div>';

echo '<div class="panel"><h2>Sensitive actions awaiting authorization</h2><table class="tbl"><thead><tr><th>Action</th><th>Booking</th><th class="num">Amount</th><th>Reason</th><th></th></tr></thead><tbody>';
foreach($pendingAuth as $a) echo '<tr><td>'.e(str_replace('_',' ',$a['action_type'])).'</td><td>'.e($a['booking_number']??'#'.$a['entity_id']).'</td><td class="num">'.money($a['amount']).'</td><td>'.e($a['reason']).'</td><td><a class="btn sm" href="'.BASE.'/index.php?page=security">Review</a></td></tr>';
if(!$pendingAuth) echo '<tr><td colspan="5" style="text-align:center;color:var(--muted)">Nothing waiting for approval.</td></tr>';
echo '</tbody></table></div>';
receipt_print('frontdesk');
page_foot();
