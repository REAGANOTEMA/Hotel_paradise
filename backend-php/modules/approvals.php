<?php
declare(strict_types=1);
require_once __DIR__.'/../app/stock_requests.php';

$exp=rows('SELECT e.*,d.name dept,u.name reqby FROM expenses e JOIN departments d ON d.id=e.department_id JOIN users u ON u.id=e.requested_by WHERE e.status=\'pending\' ORDER BY e.id');
$reqs=rows('SELECT pr.*,d.name dept,u.name reqby,'
 .'(SELECT COALESCE(SUM(requested_qty),0) FROM purchase_requisition_items ri WHERE ri.requisition_id=pr.id) qty,'
 .'(SELECT COALESCE(SUM(requested_qty*est_cost),0) FROM purchase_requisition_items ri WHERE ri.requisition_id=pr.id) amount'
 .' FROM purchase_requisitions pr JOIN departments d ON d.id=pr.department_id JOIN users u ON u.id=pr.requested_by WHERE pr.status=\'pending\' ORDER BY pr.id');
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

echo '<div class="panel"><h2>Stock requests</h2><p class="hint">Every inventory request goes to the store manager and waits here for the Director. Approve it, or turn it down and say why.</p>';
echo '<table class="tbl"><thead><tr><th>Number</th><th>Department</th><th>Items</th><th class="num">Amount</th><th>Requested by</th><th>Decision</th></tr></thead><tbody>';
foreach($reqs as $r){
 echo '<tr><td><b>'.e($r['number']).'</b></td><td>'.e($r['dept']).'</td>'
  .'<td>'.e(stock_request_item_list((int)$r['id'])?:'—').'</td>'
  .'<td class="num"><b>'.money($r['amount']).'</b></td><td>'.e($r['reqby']).'</td><td style="white-space:nowrap">';
 form_open('purchases','reqstatus',['id'=>$r['id']]);
 echo '<input type="hidden" name="nst" value="approved"><input type="hidden" name="back" value="purchases">';
 echo '<button class="btn sm tick">Approve</button></form>';
 /* A refusal always carries a reason, so the department and the store learn
    exactly why the request was turned down. */
 form_open('purchases','reqstatus',['id'=>$r['id']]);
 echo '<input type="hidden" name="nst" value="rejected"><input type="hidden" name="back" value="purchases">';
 echo '<input name="reason" placeholder="Reason (required)" style="margin-top:6px;width:180px;padding:7px;border:1px solid var(--line);border-radius:8px">';
 echo '<button class="btn sm danger" style="margin-top:6px">Reject</button></form>';
 echo '</td></tr>';
}
if(!count($reqs)) echo '<tr><td colspan="6" style="text-align:center;color:var(--muted)">Nothing waiting.</td></tr>';
echo '</tbody></table></div></div>';

echo '<div>';
echo '<div class="panel"><h2>Open shifts</h2><p class="hint">Cashiers with a shift still open are expected to cash up at close.</p>';
echo '<div class="miniList">';
foreach($openShifts as $s){ echo '<div class="li"><span>'.e($s['uname']).'<br><small>'.e(ucfirst($s['outlet'])).' opened '.fmtdt($s['opened_at']).'</small></span><b>'.money($s['opening_cash']).'</b></div>'; }
if(!count($openShifts)) echo '<p class="emptyLine">No open shifts at the moment.</p>';
echo '</div></div>';

echo '<div class="panel"><h2>Large payments today</h2><p class="hint">Transactions above 1,000,000 that warrant a glance.</p>';
echo '<div class="miniList">';
foreach($highValPayments as $p){ echo '<div class="li"><span>'.money($p['amount']).'<br><small>'.e($p['usr']??'-').' via '.e($p['method']).', '.fmtdt($p['created_at']).'</small></span>'.status_badge($p['status']).'</div>'; }
if(!count($highValPayments)) echo '<p class="emptyLine">No large payments recorded.</p>';
echo '</div></div></div></div>';
page_foot();