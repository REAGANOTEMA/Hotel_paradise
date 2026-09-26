<?php
declare(strict_types=1);

$exp=rows('SELECT e.*,d.name dept,u.name reqby FROM expenses e JOIN departments d ON d.id=e.department_id JOIN users u ON u.id=e.requested_by WHERE e.status=\'pending\' ORDER BY e.id');
$reqs=rows('SELECT pr.*,d.name dept,u.name reqby FROM purchase_requisitions pr JOIN departments d ON d.id=pr.department_id JOIN users u ON u.id=pr.requested_by WHERE pr.status=\'pending\' ORDER BY pr.id');
$openShifts=rows("SELECT s.*,u.name uname FROM shifts s JOIN users u ON u.id=s.user_id WHERE s.status='open'");
$highValPayments=rows("SELECT p.*,u.name usr FROM payments p LEFT JOIN users u ON u.id=p.user_id WHERE p.amount>=1000000 AND DATE(p.created_at)=? ORDER BY p.id DESC LIMIT 5",[today()]);

page_head('Approvals','approvals','Queue of items awaiting authorisation');
echo '<div class="kpis">';
kpi_card('Pending expenses',(string)count($exp),'Awaiting approval','gold');
kpi_card('Pending requisitions',(string)count($reqs),'Purchase requests','blue');
kpi_card('Open shifts',(string)count($openShifts),'To be closed and cashed','warn');
echo '</div>';

echo '<div class="twoCol"><div>';
echo '<div class="panel"><h2>Expense requests</h2><p class="hint">Higher level authorisation is required before payment.</p>';
echo '<table class="tbl"><thead><tr><th>Number</th><th>Department</th><th>Description</th><th class="num">Amount</th><th>Requested by</th><th></th></tr></thead><tbody>';
foreach($exp as $e){ echo '<tr><td><b>'.e($e['number']).'</b></td><td>'.e($e['dept']).'</td><td>'.e($e['description']).'</td><td class="num">'.money($e['amount']).'</td><td>'.e($e['reqby']).'</td><td>'; form_open('expenses','status',['id'=>$e['id']]); echo '<input type="hidden" name="nst" value="approved"><button class="btn sm tick">Approve</button>'; form_close(); form_open('expenses','status',['id'=>$e['id']]); echo '<input type="hidden" name="nst" value="rejected"><button class="btn sm danger">Reject</button>'; form_close(); echo '</td></tr>'; }
if(!count($exp)) echo '<tr><td colspan="6" style="text-align:center;color:var(--muted)">Nothing waiting.</td></tr>';
echo '</tbody></table></div>';

echo '<div class="panel"><h2>Purchase requisitions</h2><p class="hint">Department purchase requests awaiting authorisation.</p>';
echo '<table class="tbl"><thead><tr><th>Number</th><th>Department</th><th>Requested by</th><th></th></tr></thead><tbody>';
foreach($reqs as $r){ echo '<tr><td><b>'.e($r['number']).'</b></td><td>'.e($r['dept']).'</td><td>'.e($r['reqby']).'</td><td>'; form_open('purchases','reqstatus',['id'=>$r['id']]); echo '<input type="hidden" name="nst" value="approved"><button class="btn sm tick">Approve</button>'; form_close(); form_open('purchases','reqstatus',['id'=>$r['id']]); echo '<input type="hidden" name="nst" value="rejected"><button class="btn sm danger">Reject</button>'; form_close(); echo '</td></tr>'; }
if(!count($reqs)) echo '<tr><td colspan="4" style="text-align:center;color:var(--muted)">Nothing waiting.</td></tr>';
echo '</tbody></table></div></div>';

echo '<div>';
echo '<div class="panel"><h2>Open shifts</h2><p class="hint">Cashiers with a shift still open are expected to cash up at close.</p>';
echo '<div class="miniList">';
foreach($openShifts as $s){ echo '<div class="li"><span>'.e($s['uname']).'<br><small style="color:var(--muted)">'.e(ucfirst($s['outlet'])).' opened '.fmtdt($s['opened_at']).'</small></span><b>'.money($s['opening_cash']).'</b></div>'; }
if(!count($openShifts)) echo '<p style="color:var(--muted)">No open shifts at the moment.</p>';
echo '</div></div>';

echo '<div class="panel"><h2>Large payments today</h2><p class="hint">Transactions above 1,000,000 that warrant a glance.</p>';
echo '<div class="miniList">';
foreach($highValPayments as $p){ echo '<div class="li"><span>'.money($p['amount']).'<br><small style="color:var(--muted)">'.e($p['usr']??'-').' via '.e($p['method']).', '.fmtdt($p['created_at']).'</small></span>'.status_badge($p['status']).'</div>'; }
if(!count($highValPayments)) echo '<p style="color:var(--muted)">No large payments recorded.</p>';
echo '</div></div></div></div>';
page_foot();