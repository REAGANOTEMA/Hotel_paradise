<?php
declare(strict_types=1);
$u=current_user();

if($_SERVER['REQUEST_METHOD']==='POST'){
 $act=$_GET['act']??'';
 if($act==='close'){
  $sid=(int)($_POST['sid']??0);
  $sh=row('SELECT * FROM shifts WHERE id=? AND user_id=? AND status=\'open\'',[$sid,$u['id']]);
  if(!$sh){ flash('Find your open shift to close it.','bad'); go('shifts'); }
  $counted=(float)($_POST['counted']??0);
  $paySum=val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE user_id=? AND status='successful' AND created_at BETWEEN ? AND NOW()",[$u['id'],$sh['opened_at']]);
  $expected=$sh['opening_cash']+$paySum;
  $variance=$counted-$expected;
  q('UPDATE shifts SET closed_at=NOW(),expected_cash=?,counted_cash=?,variance=?,status=\'closed\' WHERE id=?',[$expected,$counted,$variance,$sid]);
  audit('close_shift','shift',$sid,['expected'=>$expected,'counted'=>$counted,'variance'=>$variance]);
  flash('Shift closed. Variance '.($variance<0?'-':'').money(abs($variance)).'.');
  go('shifts');
 }
}

$mine=row('SELECT * FROM shifts WHERE user_id=? AND status=\'open\'',[$u['id']]);
$list=rows("SELECT s.*,u.name uname FROM shifts s LEFT JOIN users u ON u.id=s.user_id ORDER BY s.id DESC LIMIT 40",[]);

page_head('Shifts','shifts','Cashier and waiter shifts with cash up');

if($mine){
 echo '<div class="panel" style="max-width:520px"><h2>Close your open shift</h2><p class="hint">'.e(ucfirst($mine['outlet'])).' shift opened '.fmtdt($mine['opened_at']).', opening cash '.money($mine['opening_cash']).'.</p>';
 form_open('shifts','close');
 echo '<input type="hidden" name="sid" value="'.(int)$mine['id'].'">';
 echo '<div class="field"><label>Cash counted at close (UGX)</label><input type="number" name="counted" step="100" min="0" required></div>';
 echo '<button class="btn">Close shift</button>'; form_close();
 echo '</div>';
}

echo '<div class="panel"><h2>Shift history</h2><p class="hint">Expected cash is opening cash plus payments recorded during the shift.</p>';
echo '<table class="tbl"><thead><tr><th>User</th><th>Outlet</th><th>Opened</th><th>Closed</th><th class="num">Opening cash</th><th class="num">Expected</th><th class="num">Counted</th><th class="num">Variance</th><th>Status</th></tr></thead><tbody>';
foreach($list as $s){
 $v=(float)$s['variance'];
 echo '<tr><td><b>'.e($s['uname']).'</b></td><td>'.e(ucfirst($s['outlet'])).'</td><td>'.fmtdt($s['opened_at']).'</td><td>'.($s['closed_at']?fmtdt($s['closed_at']):'-').'</td>';
 echo '<td class="num">'.money($s['opening_cash']).'</td><td class="num">'.money($s['expected_cash']).'</td><td class="num">'.money($s['counted_cash']).'</td>';
 echo '<td class="num" style="color:'.($v<0?'#c62828':($v>0?'#b26a00':'#2e7d32')).'">'.($v<0?'-':'').money(abs($v)).'</td>';
 echo '<td>'.($s['status']==='open'?badge('Open','gold'):badge('Closed','grey')).'</td></tr>';
}
if(!count($list)) echo '<tr><td colspan="9" style="text-align:center;color:var(--muted)">No shifts yet.</td></tr>';
echo '</tbody></table></div>';
page_foot();