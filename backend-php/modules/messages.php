<?php
declare(strict_types=1);
require_once __DIR__.'/../app/guest_comm.php';

/*
 * Guest Messages: the front-of-house inbox.
 *
 * Every message a guest sends to the front office or the kitchen from the
 * website lands here, as does a message from a guest already in the house.
 * Each person opens only their own desk: the front desk answers what is sent
 * to the house, the kitchen answers what is sent to the kitchen, and
 * management reads and answers both. A message is assigned the moment someone
 * takes it, and the reply lives on the same row so the whole conversation - as
 * thin as it is - stays in one place and the director can read any thread.
 */

$u=current_user();
$me=(int)($u['id']??0);
$scope=guest_message_scope();
$act=$_GET['act']??'';
$tones=['new'=>'warn','assigned'=>'blue','resolved'=>'ok','featured'=>'gold'];

if($_SERVER['REQUEST_METHOD']==='POST'){
 $id=(int)($_POST['id']??0);
 $row=null;
 if($id) $row=row('SELECT * FROM guest_messages WHERE id=?',$id?[$id]:[-1]);
 if($row&&in_array($row['department'],$scope,true)){
  if($act==='assign'){
   if((int)$row['assigned_to']!==$me){
    q('UPDATE guest_messages SET assigned_to=?,status=IF(status=\'new\',\'assigned\',status),updated_at=NOW() WHERE id=?',[$me,$id]);
    audit('assign_guest_message','guest_messages',$id,['assigned_to'=>$row['assigned_to']],['assigned_to'=>$me]);
    notify_console('gm:assign:'.$id,'communication','Guest message assigned',
     e($u['name']).' took '.e($row['reference']).' ('.e(guest_message_departments()[$row['department']]??$row['department']).').',
     ['reference'=>$row['reference'],'department'=>$row['department'],'id'=>$id],
     guest_message_notify_roles((string)$row['department']));
    flash('Message assigned to you.');
   }else{ flash('This message is already assigned to you.'); }
  }
  if($act==='reply'){
   $reply=trim($_POST['reply']??'');
   if($reply===''){
    flash('A reply needs some words.','bad');
   }else{
    q('UPDATE guest_messages SET reply=?,replied_by=?,replied_at=NOW(),assigned_to=?,status=IF(status=\'new\',\'assigned\',status),updated_at=NOW() WHERE id=?',
      [$reply,$me,$me,$id]);
    audit('reply_guest_message','guest_messages',$id,['reply'=>$row['reply']],['reply'=>$reply]);
    notify_console('gm:reply:'.$id,'communication','Reply sent to '.e($row['full_name']),
     e($u['name']).' answered '.e($row['reference']).'.',
     ['reference'=>$row['reference'],'id'=>$id],guest_message_notify_roles((string)$row['department']));
    $to=trim((string)($row['email']??''));
    if($to!==''){
     try{
      require_once __DIR__.'/../app/mailer.php';
      $subj='Re: '.($row['subject']!==''?$row['subject']:$row['reference']);
      $body='<p style="margin:0 0 14px">Hello '.e($row['full_name']).',</p>'
        .'<p style="margin:0 0 14px">The '.e((guest_message_departments()[$row['department']]??'').' of Hotel Paradise on the Nile').' has replied to your message:</p>'
        .'<blockquote style="margin:0 0 14px;padding:10px 14px;border-left:3px solid #C9A227;background:#faf9f5">'.nl2br(e($reply)).'</blockquote>'
        .'<p style="margin:0">We remain at your service, and if there is anything else, please write again or call +256 759 504 928.</p>';
      $r=mail_send($to,$subj,mail_html('Your message to Hotel Paradise on the Nile',$body));
      $z=$r['ok']?'reply-good':'reply-fail';
     }catch(\Throwable $e){ $z='reply-note'; }
    }
    flash('Reply sent.'.(($to??'')!==''?' The guest also received it by email.':''));
   }
  }
  if($act==='status'){
   $nst=(string)($_POST['nst']??'');
   if(in_array($nst,['new','assigned','resolved'],true)){
    q('UPDATE guest_messages SET status=?,updated_at=NOW() WHERE id=?',[$nst,$id]);
    audit('status_guest_message','guest_messages',$id,['status'=>$row['status']],['status'=>$nst]);
    notify_console('gm:status:'.$id.':'.$nst,'communication','Message '.e($nst),
     e($row['reference']).' is now '.e($nst).'.',['reference'=>$row['reference'],'status'=>$nst,'id'=>$id],
     guest_message_notify_roles((string)$row['department']));
    flash('Message marked '.$nst.'.');
   }
  }
 }elseif($id){
  flash('That message is not on your desk.','bad');
 }
 go('messages',array_merge(['view'=>$id],array_filter(['dept'=>$_GET['dept']??'','st'=>$_GET['st']??'','q'=>trim((string)($_GET['q']??''))],fn($v)=>$v!=='')));
}

$dept=trim((string)($_GET['dept']??''));
if($dept===''||!in_array($dept,$scope,true)) $dept=$scope[0]??'';
$st=trim((string)($_GET['st']??''));
if($st!==''&&!in_array($st,['new','assigned','resolved'],true)) $st='';
$q=trim((string)($_GET['q']??''));
$view=(int)($_GET['view']??0);

$w=['kind=\'message\''];
$a=[];
if(count($scope)>1&&$dept!==''){ $w[]='department=?'; $a[]=$dept; }
elseif(count($scope)===1){ $w[]='department=?'; $a[]=$dept; }
if($st!==''){ $w[]='status=?'; $a[]=$st; }
if($q!==''){ $w[]='(full_name LIKE ? OR phone LIKE ? OR email LIKE ? OR subject LIKE ? OR reference LIKE ?)';
 $a=array_merge($a,['%'.$q.'%','%'.$q.'%','%'.$q.'%','%'.$q.'%','%'.$q.'%']); }

$list=rows("SELECT gm.*,u.name assigned_name FROM guest_messages gm LEFT JOIN users u ON u.id=gm.assigned_to WHERE ".implode(' AND ',$w)." ORDER BY gm.id DESC LIMIT 120",$a);

$row=null;
if($view) $row=row('SELECT gm.*,u.name assigned_name FROM guest_messages gm LEFT JOIN users u ON u.id=gm.assigned_to WHERE gm.id=?',[$view]);
if($row&&!in_array($row['department'],$scope,true)){ $row=null; }

$counts=guest_message_counts();
page_head('Guest Messages','messages','Every message a guest has sent to the front office or the kitchen');

echo '<div class="kpis">';
kpi_card('New messages',(string)$counts['new'],'Waiting for a first answer');
kpi_card('Open',(string)$counts['open'],'New or assigned, not yet resolved');
kpi_card('All messages',(string)$counts['message'].' / '.$counts['total'],count($list)>0?'Latest '.count($list).' shown below':'On your desk');
kpi_card('Kitchen',(string)$counts['kitchen'],'Sent to the kitchen');
kpi_card('Front office',(string)$counts['front_office'],'Sent to the house');
echo '</div>';

echo '<div class="toolbar">';
echo '<a class="btn" href="'.BASE.'/index.php?page=testimonials">Guest experiences</a>';
echo '<form method="get" style="display:flex;gap:6px;flex-wrap:wrap;margin-left:auto">';
echo '<input type="hidden" name="page" value="messages">';
if(count($scope)>1){
 echo '<select name="dept" style="padding:9px 12px;border:1px solid var(--line);border-radius:9px" onchange="this.form.submit()"><option value="">Every desk</option>';
 foreach($scope as $d){ echo '<option value="'.e($d).'"'.($dept===$d?' selected':'').'>'.e(guest_message_departments()[$d]??$d).'</option>'; }
 echo '</select>';
}
echo '<select name="st" style="padding:9px 12px;border:1px solid var(--line);border-radius:9px" onchange="this.form.submit()"><option value="">Any status</option>';
foreach(guest_message_statuses() as $k=>$v){ if($k==='featured') continue; echo '<option value="'.e($k).'"'.($st===$k?' selected':'').'>'.e($v).'</option>'; }
echo '</select>';
echo '<input name="q" value="'.e($q).'" placeholder="Search guest, phone or subject..." style="padding:9px 12px;border:1px solid var(--line);border-radius:9px">';
echo '<button class="btn sm">Search</button></form></div>';

if(!guest_message_ready()){
 echo '<div class="panel"><h2>Guest Messages</h2><p class="hint">The guest communications upgrade has not been installed on this database yet.</p><p>Run <code>database/sql/patches/2026-10-12_guest_messages.sql</code> and refresh this page.</p></div>';
 page_foot(); return;
}

if($row){
 echo '<div class="panel"><div class="toolbar" style="margin-bottom:14px">';
 echo '<div><h2>'.e($row['reference']).'</h2><p class="hint" style="margin:0">'.e(fmtdt($row['created_at'])).' &middot; '.e(guest_message_sources()[$row['source']]??$row['source']).' &middot; '.e(guest_message_departments()[$row['department']]??$row['department']).' &middot; '.badge(guest_message_statuses()[$row['status']]??$row['status'],$tones[$row['status']]??'grey').'</p></div>';
 echo '<div class="bar"><a class="btnGhost sm" href="'.BASE.'/index.php?page=messages'.($dept!==''?'&dept='.e($dept):'').'">Back</a></div></div>';

 echo '<div class="res-meta" style="margin-bottom:16px">';
 echo '<div class="field" style="margin:0"><label>Guest</label><div>'.e($row['full_name']).'</div></div>';
 echo '<div class="field" style="margin:0"><label>Phone</label><div>'.e($row['phone']??'Not given').'</div></div>';
 echo '<div class="field" style="margin:0"><label>Email</label><div>'.e($row['email']??'Not given').'</div></div>';
 if($row['room_number']!=='') echo '<div class="field" style="margin:0"><label>Room</label><div>'.e($row['room_number']).'</div></div>';
 echo '<div class="field" style="margin:0"><label>Subject</label><div>'.e($row['subject']??'No subject').'</div></div>';
 echo '<div class="field" style="margin:0"><label>Assigned to</label><div>'.e($row['assigned_name']??'Nobody yet').'</div></div>';
 echo '</div>';

 echo '<div class="panel" style="background:#fbfaf6"><p style="margin:0;white-space:pre-line;font-size:14.5px;line-height:1.7">'.e($row['message']).'</p></div>';

 if($row['reply']!==''){
  echo '<div class="panel" style="background:#f4f7fa;border-color:#dbe6ee"><h2>Answer sent</h2>';
  echo '<p style="margin:0 0 8px;white-space:pre-line">'.e($row['reply']).'</p>';
  echo '<p class="hint" style="margin:0">'.e($row['replied_at']?fmtdt($row['replied_at']):'').' &middot; '.e(val('SELECT name FROM users WHERE id=?',[(int)$row['replied_by']])??'').'</p></div>';
 }

 echo '<div class="twoCol"><div>';
 echo '<div class="panel"><h2>Reply to the guest</h2><p class="hint">Your answer is stored on the message'.($row['email']!==''?' and emailed to the guest right away':'').'.</p>';
 form_open('messages','reply');
 echo '<input type="hidden" name="id" value="'.(int)$row['id'].'">';
 area('Reply','reply','','What would you like the guest to know? A time, a price, a yes or a no.','',5);
 echo '<button class="btn">Send reply</button> ';
 form_close();
 echo '</div></div><div>';
 echo '<div class="panel"><h2>Take it or mark it</h2><p class="hint">Taking the message puts your name on it; resolving it closes it off the open board.</p>';
 echo '<div style="display:flex;gap:8px;flex-wrap:wrap">';
 form_open('messages','assign');
 echo '<input type="hidden" name="id" value="'.(int)$row['id'].'"><button class="btn sm blue"'.((int)$row['assigned_to']===$me?' disabled':'').'>Assign to me</button>';
 form_close();
 if($row['status']!=='resolved'){
  form_open('messages','status');
  echo '<input type="hidden" name="id" value="'.(int)$row['id'].'"><input type="hidden" name="nst" value="resolved"><button class="btn sm">Resolve message</button>';
  form_close();
 }else{
  form_open('messages','status');
  echo '<input type="hidden" name="id" value="'.(int)$row['id'].'"><input type="hidden" name="nst" value="assigned"><button class="btn sm ghost">Reopen</button>';
  form_close();
 }
 echo '</div></div></div></div>';
 page_foot(); return;
}

echo '<div class="panel"><h2>Inbox</h2><p class="hint">'.(count($scope)===1?'Your desk: '.e(guest_message_departments()[$dept]??$dept):'All desks you may open').'. A guest wrote here because they wanted an answer - take or reply before it grows cold.</p>';
if(!count($list)){ echo '<p class="emptyLine">No guest messages'.($q!==''?' matching '.e($q):'').'. New messages from the website land here with a ring on the bell.</p>'; }
else{
 echo '<table class="tbl"><thead><tr><th>Ref</th><th>Guest</th><th>Desk</th><th>Subject</th><th>Status</th><th>Sent</th><th></th></tr></thead><tbody>';
 foreach($list as $m){
  $here=(int)$m['id']===$view;
  echo '<tr'.($here?' style="background:#fbfaf3"':'').'>';
  echo '<td><b>'.e($m['reference']).'</b></td>';
  echo '<td><b>'.e($m['full_name']).'</b>'.(($m['phone']??'')!==''?'<br><small>'.e($m['phone']).'</small>':'').($m['room_number']!==''?'<br><small>Room '.e($m['room_number']).'</small>':'').'</td>';
  echo '<td>'.e(guest_message_departments()[$m['department']]??$m['department']).'</td>';
  echo '<td>'.e($m['subject']??'(no subject)').'</td>';
  echo '<td>'.badge(guest_message_statuses()[$m['status']]??$m['status'],$tones[$m['status']]??'grey').'</td>';
  echo '<td>'.fmtdate($m['created_at']).'</td>';
  echo '<td><a class="btn sm" href="'.BASE.'/index.php?page=messages&view='.(int)$m['id'].'">Open</a></td></tr>';
 }
 echo '</tbody></table>';
}
echo '</div>';
page_foot();