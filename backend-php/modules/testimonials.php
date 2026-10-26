<?php
declare(strict_types=1);
require_once __DIR__.'/../app/guest_comm.php';

/*
 * Guest Experiences: the written stay reviews guests leave on the website.
 *
 * A guest writes their experience through the same channel as a message but it
 * is filed apart (kind = experience). This module is where a team member reads
 * the story, answers it when a guest gave contact details, and marks it
 * "featured" for it to appear on the website - the marketing team curates,
 * management approves, and the site only ever shows what has been featured.
 */

$u=current_user();
$me=(int)($u['id']??0);
$scope=guest_experience_scope();
$act=$_GET['act']??'';
$tones=['new'=>'warn','assigned'=>'blue','resolved'=>'ok','featured'=>'gold'];

function gm_stars(int $n): string{
 $n=min(5,max(1,$n));
 return str_repeat('&#9733;',$n).($n<5?str_repeat('&#9734;',5-$n):'');
}

if($_SERVER['REQUEST_METHOD']==='POST'){
 $id=(int)($_POST['id']??0);
 $row=$id?row('SELECT * FROM guest_messages WHERE id=? AND kind=\'experience\'',[$id]):null;
 if($row&&in_array($row['department'],$scope,true)){
  if($act==='status'){
   $nst=(string)($_POST['nst']??'');
   if($nst==='featured'){
    // A featured experience goes public on the website. Only one is kept in
    // the enclosure at a time; the rest stay resolved until they are called up.
    q('UPDATE guest_messages SET status=\'featured\',updated_at=NOW() WHERE id=?',[$id]);
    q('UPDATE guest_messages SET status=\'resolved\' WHERE kind=\'experience\' AND status=\'featured\' AND id<>?',[$id]);
   }elseif(in_array($nst,['new','assigned','resolved'],true)){
    q('UPDATE guest_messages SET status=?,updated_at=NOW() WHERE id=?',[$nst,$id]);
   }else{ $nst=''; }
   if($nst!==''){
    audit('status_guest_experience','guest_messages',$id,['status'=>$row['status']],['status'=>$nst]);
    notify_console('gx:status:'.$id.':'.$nst,'communication','Experience '.e($nst),
     e($row['full_name']).'&#39;s stay is now '.e($nst).'.',['reference'=>$row['reference'],'status'=>$nst,'id'=>$id],
     guest_message_notify_roles((string)$row['department'],'experience'));
    flash('Experience marked '.$nst.($nst==='featured'?' and is now visible on the website.':''));
   }
  }
 }elseif($id){
  flash('That experience is not on your desk.','bad');
 }
 go('testimonials',array_merge(['view'=>$id],array_filter(['dept'=>$_GET['dept']??'','st'=>$_GET['st']??''],fn($v)=>$v!=='')));
}

$dept=trim((string)($_GET['dept']??''));
if($dept===''||!in_array($dept,$scope,true)) $dept='';
$st=trim((string)($_GET['st']??''));
if($st!==''&&!in_array($st,['new','assigned','resolved','featured'],true)) $st='';
$view=(int)($_GET['view']??0);

$w=['kind=\'experience\''];
$a=[];
if(count($scope)>1&&$dept!==''){ $w[]='department=?'; $a[]=$dept; }
elseif(count($scope)===1){ $w[]='department=?'; $a[]=$dept; }
if($st!==''){ $w[]='status=?'; $a[]=$st; }
$list=rows("SELECT gm.*,u.name assigned_name FROM guest_messages gm LEFT JOIN users u ON u.id=gm.assigned_to WHERE ".implode(' AND ',$w)." ORDER BY gm.id DESC LIMIT 120",$a);

$row=null;
if($view) $row=row('SELECT gm.*,u.name assigned_name FROM guest_messages gm LEFT JOIN users u ON u.id=gm.assigned_to WHERE gm.id=? AND gm.kind=\'experience\'',[$view]);
if($row&&!in_array($row['department'],$scope,true)){ $row=null; }

$counts=guest_message_counts($scope);
$featured=0;
if(guest_message_ready()){ try{ $featured=(int)val("SELECT COUNT(*) FROM guest_messages WHERE kind='experience' AND status='featured'"); }catch(\Throwable $e){} }
page_head('Guest Experiences','testimonials','The stay reviews guests write on the website');

echo '<div class="kpis">';
kpi_card('New experiences',(string)$counts['new'],'Waiting for a read');
kpi_card('Open',(string)$counts['open'],'Still needing a response');
kpi_card('All experiences',(string)$counts['experience'],'Stories written by guests');
kpi_card('On the website',(string)$featured,'The story the site is showing');
echo '</div>';

echo '<div class="toolbar">';
echo '<a class="btn" href="'.BASE.'/index.php?page=messages">Guest messages</a>';
echo '<form method="get" style="display:flex;gap:6px;flex-wrap:wrap;margin-left:auto">';
echo '<input type="hidden" name="page" value="testimonials">';
if(count($scope)>1){
 echo '<select name="dept" style="padding:9px 12px;border:1px solid var(--line);border-radius:9px" onchange="this.form.submit()"><option value="">Every desk</option>';
 foreach($scope as $d){ echo '<option value="'.e($d).'"'.($dept===$d?' selected':'').'>'.e(guest_message_departments()[$d]??$d).'</option>'; }
 echo '</select>';
}
echo '<select name="st" style="padding:9px 12px;border:1px solid var(--line);border-radius:9px" onchange="this.form.submit()"><option value="">Any status</option>';
foreach(guest_message_statuses() as $k=>$v){ echo '<option value="'.e($k).'"'.($st===$k?' selected':'').'>'.e($v).'</option>'; }
echo '</select></form></div>';

if(!guest_message_ready()){
 echo '<div class="panel"><h2>Guest Experiences</h2><p class="hint">The guest communications upgrade has not been installed on this database yet.</p><p>Run <code>database/sql/patches/2026-10-12_guest_messages.sql</code> (or the installer) and refresh this page.</p></div>';
 page_foot(); return;
}

if($row){
 echo '<div class="panel"><div class="toolbar" style="margin-bottom:14px">';
 echo '<div><h2>'.e($row['full_name']).'\'s stay</h2><p class="hint" style="margin:0">'.e($row['reference']).' &middot; '.e(fmtdt($row['created_at'])).' &middot; '.e(guest_message_departments()[$row['department']]??$row['department']).' &middot; '.badge(guest_message_statuses()[$row['status']]??$row['status'],$tones[$row['status']]??'grey').'</p></div>';
 echo '<div class="bar"><a class="btnGhost sm" href="'.BASE.'/index.php?page=testimonials'.($dept!==''?'&dept='.e($dept):'').'">Back</a></div></div>';

 echo '<div class="res-meta" style="margin-bottom:16px">';
 echo '<div class="field" style="margin:0"><label>Guest</label><div>'.e($row['full_name']).' <span style="color:var(--gold)">'.gm_stars((int)$row['rating']).'</span></div></div>';
 echo '<div class="field" style="margin:0"><label>Phone</label><div>'.e($row['phone']??'Not given').'</div></div>';
 echo '<div class="field" style="margin:0"><label>Email</label><div>'.e($row['email']??'Not given').'</div></div>';
 echo '<div class="field" style="margin:0"><label>Desk</label><div>'.e(guest_message_departments()[$row['department']]??$row['department']).'</div></div>';
 echo '</div>';

 echo '<div class="panel" style="background:#fbfaf6"><p style="margin:0;font-size:15px;line-height:1.75;white-space:pre-line">'.e($row['message']).'</p></div>';

 if($row['reply']!==''){
  echo '<div class="panel" style="background:#f4f7fa;border-color:#dbe6ee"><h2>Answer sent</h2><p style="margin:0;white-space:pre-line">'.e($row['reply']).'</p></div>';
 }

 echo '<div class="panel"><h2>Curate this experience</h2><p class="hint">"Feature on website" publishes the story on the site at once (one feature is shown at a time). Resolve closes it off the open board.</p>';
 echo '<div style="display:flex;gap:8px;flex-wrap:wrap">';
 form_open('testimonials','status');
 echo '<input type="hidden" name="id" value="'.(int)$row['id'].'">';
 if($row['status']!=='featured'){ echo '<input type="hidden" name="nst" value="featured"><button class="btn">Feature on website</button>'; }
 else{ echo '<input type="hidden" name="nst" value="resolved"><button class="btn ghost">Unfeature</button>'; }
 form_close();
 if($row['status']!=='resolved'&&$row['status']!=='featured'){
  form_open('testimonials','status');
  echo '<input type="hidden" name="id" value="'.(int)$row['id'].'"><input type="hidden" name="nst" value="resolved"><button class="btn sm">Resolve</button>';
  form_close();
 }
 echo '</div></div>';
 page_foot(); return;
}

echo '<div class="panel"><h2>From our guests</h2><p class="hint">The stories guests leave on the website. A featured story is the one currently shown on the site.</p>';
if(!count($list)){ echo '<p class="emptyLine">No experiences'.($st!==''||$dept!==''?' with this filter':'').' yet. When a guest writes one on the website it lands here with a ring.</p>'; }
else{
 echo '<table class="tbl"><thead><tr><th>Guest</th><th>Rating</th><th>Desk</th><th>The story</th><th>Status</th><th>Written</th><th></th></tr></thead><tbody>';
 foreach($list as $x){
  echo '<tr>';
  echo '<td><b>'.e($x['full_name']).'</b>'.(($x['phone']??'')!==''?'<br><small>'.e($x['phone']).'</small>':'').'</td>';
  echo '<td style="color:var(--gold);font-weight:700;white-space:nowrap">'.gm_stars((int)$x['rating']).'</td>';
  echo '<td>'.e(guest_message_departments()[$x['department']]??$x['department']).'</td>';
  echo '<td>'.e(mb_strimwidth((string)$x['message'],0,72,'&hellip;')).'</td>';
  echo '<td>'.badge(guest_message_statuses()[$x['status']]??$x['status'],$tones[$x['status']]??'grey').'</td>';
  echo '<td>'.fmtdate($x['created_at']).'</td>';
  echo '<td><a class="btn sm" href="'.BASE.'/index.php?page=testimonials&view='.(int)$x['id'].'">Open</a></td></tr>';
 }
 echo '</tbody></table>';
}
echo '</div>';
page_foot();