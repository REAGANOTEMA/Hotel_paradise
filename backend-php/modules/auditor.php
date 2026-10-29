<?php
declare(strict_types=1);

$u=current_user();
require_once __DIR__.'/../app/finance.php';
require_once __DIR__.'/../app/finance_ui.php';

$act=$_GET['act']??'';
$range=finance_range(30);
$canReview=finance_role_can('audit');

if($act==='export'||($_GET['export']??'')==='csv'){
 $findings=finance_findings($range['from'],$range['to_excl'],1000);
 $out=[];
 foreach($findings as $f){
  $out[]=[
   $f['severity'],
   $f['type'],
   $f['title'],
   $f['detail'],
   $f['ref_type']??'',
   $f['ref_id']??'',
   $f['amount'],
   $f['expected'],
   $f['status'],
  ];
 }
 finance_csv_download('finance-findings-'.$range['from'].'_'.$range['to'].'.csv',
  ['Severity','Area','Finding','Detail','Reference type','Reference','Amount','Expected','Status'],$out);
}

if($_SERVER['REQUEST_METHOD']==='POST'){
 switch($act){
  case 'scan':
   $findings=finance_findings($range['from'],$range['to_excl'],1000);
   $n=finance_store_findings($findings,(int)$u['id']);
   flash($n.' finance finding(s) written to the review register.','ok');
   go('auditor',['from'=>$range['from'],'to'=>$range['to']]);
   break;
  case 'review':
   if(!$canReview){
    flash('Only the auditor, director or general manager may review findings.','bad');
    go('auditor');
   }
   $r=finance_review_finding((int)($_POST['finding_id']??0),(string)($_POST['status']??''),(string)($_POST['reason']??''),(int)$u['id']);
   flash($r['ok']?'Finding updated.':(string)$r['error'],$r['ok']?'ok':'bad');
   go('auditor');
   break;
 }
}

$findings=finance_findings($range['from'],$range['to_excl'],1000);
$summary=finance_summary($range['from'],$range['to_excl']);
$journals=finance_journal_rows($range['from'],$range['to_excl'],'',1000);
$bankReady=finance_bank_ready();
$banks=$bankReady?finance_bank_accounts():[];
$reconciliations=$bankReady?finance_reconciliations(0,100):[];
$auditRows=rows(
 "SELECT a.*,u.name uname FROM audit_logs a LEFT JOIN users u ON u.id=a.user_id
  WHERE a.created_at>=? AND a.created_at<?
    AND (a.action LIKE 'finance%' OR a.action IN('open_shift','close_shift','payment_reversed','expense_paid'))
  ORDER BY a.id DESC LIMIT 100",
 [$range['from'].' 00:00:00',$range['to_excl'].' 00:00:00']
);
$high=0;
$medium=0;
$low=0;
$openFindings=0;
foreach($findings as $f){
 if($f['severity']==='high') $high++;
 elseif($f['severity']==='medium') $medium++;
 else $low++;
 if(($f['status']??'open')==='open') $openFindings++;
}
$variance=(float)val("SELECT COALESCE(SUM(variance),0) FROM shifts WHERE status='closed' AND closed_at>=? AND closed_at<?",[$range['from'].' 00:00:00',$range['to_excl'].' 00:00:00']);
$bankGap=0.0;
foreach($banks as $b){
 $bankGap+=finance_bank_statement_balance($b,$range['from'],$range['to_excl'])-finance_bank_book_balance($b,$range['from'],$range['to_excl']);
}

page_head('Auditor Workspace','auditor',$range['label']);
finance_ui_print_header('Auditor workspace',$range['label']);
finance_ui_scripts();
finance_ui_range_form('auditor',$range);

echo '<div class="kpis">';
kpi_card('Open findings',(string)$openFindings,'Unresolved review items',$openFindings?'warn':'green');
kpi_card('High severity',(string)$high,'Needs immediate attention',$high?'bad':'navy');
kpi_card('Medium severity',(string)$medium,'Review and document',$medium?'gold':'navy');
kpi_card('Low severity',(string)$low,'Monitor and clear',$low?'blue':'navy');
kpi_card('Cash variance',($variance<0?'-':'').money(abs($variance)),'Closed shifts in range',abs($variance)>0.009?'bad':'green');
kpi_card('Journals in range',(string)count($journals),'Posted, draft and reversed');
kpi_card('Bank difference',($bankGap<0?'-':'').money(abs($bankGap)),'Statement less book balance',abs($bankGap)>0.009?'warn':'green');
kpi_card('Finance audit events',(string)count($auditRows),'Trail entries in range');
echo '</div>';

echo '<div class="panel"><div class="panelHead"><div><h2>Exception scan</h2><p class="hint">Findings are computed from live transactions and can be written to the shared review register. The scan never edits a payment, order, journal or shift.</p></div><div class="finTools">'.finance_ui_export_buttons('auditor',$range).'</div></div>';
form_open('auditor','scan');
echo '<button class="btn">Scan and store findings</button>';
form_close();
echo '</div>';

echo '<div class="finSplit"><div class="finStack">';
echo '<div class="panel"><h2>Findings</h2><p class="hint">High severity first, then open items. Stored status is preserved between scans.</p>';
finance_ui_open('auditorFindings','Finance findings',[
 'severity'=>'Severity','area'=>'Area','title'=>'Finding','detail'=>'Detail','num:amount'=>'Amount','status'=>'Status'
 ],'','',true);
if(!$findings) finance_ui_empty(6,'No finance findings in this range.');
foreach($findings as $f){
 echo '<tr><td>'.finance_ui_severity((string)$f['severity']).'</td><td>'.e(ucfirst(str_replace('_',' ',(string)$f['type']))).'</td>';
 echo '<td><b>'.e((string)$f['title']).'</b></td><td>'.e((string)$f['detail']).'</td>';
 echo '<td class="num">'.($f['amount']===null?'-':money((float)$f['amount'])).'</td><td>'.finance_ui_status((string)($f['status']??'open')).'</td></tr>';
}
finance_ui_close(6,[],'No findings.');
echo '</div>';

echo '<div class="panel"><h2>Bank reconciliation review</h2><p class="hint">Book balance comes from successful payments and paid expenses. Statement balance comes from imported bank lines. A difference is a review trigger, not an automatic correction.</p>';
if(!$bankReady){
 finance_ui_alert('Bank reconciliation tables are not installed. Review and run the finance workspace patch before using bank matching.');
}elseif(!$banks){
 finance_ui_alert('No bank accounts have been configured yet.');
}else{
 finance_ui_open('auditorBanks','Bank accounts',['account'=>'Account','method'=>'Method','num:book'=>'Book','num:statement'=>'Statement','num:gap'=>'Difference'],'','',true);
 $bookTotal=0.0;
 $statementTotal=0.0;
 foreach($banks as $b){
  $book=finance_bank_book_balance($b,$range['from'],$range['to_excl']);
  $statement=finance_bank_statement_balance($b,$range['from'],$range['to_excl']);
  $gap=$statement-$book;
  $bookTotal+=$book;
  $statementTotal+=$statement;
  echo '<tr><td>'.e((string)$b['name']).'</td><td>'.e(finance_method_label((string)$b['method'])).'</td><td class="num">'.money($book).'</td><td class="num">'.money($statement).'</td>';
  echo '<td class="num" style="color:'.(abs($gap)>0.009?'#c62828':'#2e7d32').'">'.($gap<0?'-':'').money(abs($gap)).'</td></tr>';
 }
 finance_ui_close(5,[2=>['label'=>'Total','value'=>$bookTotal,'money'=>true],3=>['label'=>'Total','value'=>$statementTotal,'money'=>true]],'No bank accounts.');
}
echo '</div>';

echo '<div class="panel"><h2>Saved reconciliations</h2><p class="hint">Prepared and reviewed bank reconciliations, newest first.</p>';
finance_ui_open('auditorRecons','Reconciliations',['account'=>'Account','period'=>'Period','status'=>'Status','prepared'=>'Prepared by','reviewed'=>'Reviewed by','num:difference'=>'Difference'],'','',false);
if(!$reconciliations) finance_ui_empty(6,'No reconciliations have been saved.');
foreach($reconciliations as $r){
 $diff=(float)($r['difference']??0);
 echo '<tr><td>'.e((string)($r['account_name']??'-')).'</td><td>'.e(fmtdate($r['period_start']).' - '.fmtdate($r['period_end'])).'</td>';
 echo '<td>'.finance_ui_status((string)$r['status']).'</td><td>'.e((string)($r['prepared_name']??'-')).'</td><td>'.e((string)($r['reviewed_name']??'-')).'</td>';
 echo '<td class="num" style="color:'.(abs($diff)>0.009?'#c62828':'#2e7d32').'">'.($diff<0?'-':'').money(abs($diff)).'</td></tr>';
}
finance_ui_close(6,[],'No reconciliations.');
echo '</div>';
echo '</div><div class="finStack">';

if($canReview && $findings){
 echo '<div class="panel"><h2>Review a stored finding</h2><p class="hint">A reason is recorded in the audit trail. Clearing a finding does not change the underlying transaction.</p>';
 form_open('auditor','review');
 echo '<div class="formGrid">';
 echo '<div class="field"><label>Finding</label><select name="finding_id" required><option value="">Choose a stored finding</option>';
 foreach($findings as $f){
  if(empty($f['id'])) continue;
  echo '<option value="'.(int)$f['id'].'">'.e('['.strtoupper((string)$f['severity']).'] '.$f['title']).'</option>';
 }
 echo '</select></div>';
 echo '<div class="field"><label>Decision</label><select name="status" required><option value="reviewed">Reviewed</option><option value="cleared">Cleared</option><option value="open">Reopen</option></select></div>';
 echo '</div>';
 echo '<div class="field"><label>Reason</label><input type="text" name="reason" maxlength="255" required></div>';
 echo '<button class="btn blue">Save decision</button>';
 form_close();
 echo '</div>';
}

echo '<div class="panel"><h2>Journal integrity</h2><p class="hint">Posted journals in range. Unbalanced entries are also raised as high-severity findings.</p>';
finance_ui_open('auditorJournals','Journals',['entry'=>'Entry','date'=>'Date','description'=>'Description','status'=>'Status','user'=>'Created by','num:total'=>'Amount'],'','',true);
if(!$journals) finance_ui_empty(6,'No journals in this range.');
foreach($journals as $j) echo '<tr><td>'.e((string)$j['entry_number']).'</td><td>'.e(fmtdate($j['entry_date'])).'</td><td>'.e((string)$j['description']).'</td><td>'.finance_ui_status((string)$j['status']).'</td><td>'.e((string)($j['created_name']??'-')).'</td><td class="num">'.money((float)$j['total']).'</td></tr>';
finance_ui_close(6,[],'No journals.');
echo '</div>';

echo '<div class="panel"><h2>Finance audit trail</h2><p class="hint">Critical finance actions from the shared audit log for the selected range.</p>';
finance_ui_open('auditorTrail','Audit trail',['time'=>'Time','user'=>'User','action'=>'Action','entity'=>'Entity','ref'=>'Reference'],'','',true);
if(!$auditRows) finance_ui_empty(5,'No finance audit events in this range.');
foreach($auditRows as $a){
 $entity=trim((string)($a['entity_type']??''));
 $ref=$entity!==''?$entity.' #'.(int)($a['entity_id']??0):'-';
 echo '<tr><td>'.e(fmtdt($a['created_at'])).'</td><td>'.e((string)($a['uname']??'System')).'</td><td>'.e((string)$a['action']).'</td>';
 echo '<td>'.e($entity!==''?$entity:'-').'</td><td>'.e($ref).'</td></tr>';
}
finance_ui_close(5,[],'No audit events.');
echo '</div>';

echo '<div class="panel"><h2>Cash and collections</h2><p class="hint">Operational totals for the selected range, including cash and non-cash collections.</p>';
finance_ui_open('auditorCash','Cash summary',['measure'=>'Measure','num:value'=>'Value'],'','',false);
echo '<tr><td>Cash collections</td><td class="num">'.money((float)$summary['cash']).'</td></tr>';
echo '<tr><td>Non-cash collections</td><td class="num">'.money((float)$summary['noncash']).'</td></tr>';
echo '<tr><td>Reversed or refunded</td><td class="num">'.money((float)$summary['reversed']).'</td></tr>';
echo '<tr><td>Paid expenses</td><td class="num">'.money((float)$summary['expenses']).'</td></tr>';
echo '<tr><td>Open shifts now</td><td class="num">'.(int)$summary['open_shifts'].'</td></tr>';
finance_ui_close(2,[],'No cash data.');
echo '</div>';
echo '</div></div>';

echo '<div class="toolbar"><a class="btnGhost" href="'.e(finance_page_link('accountant')).'">Accountant workspace</a><a class="btnGhost" href="'.e(finance_page_link('cashier')).'">Cashier workspace</a><a class="btnGhost" href="'.e(finance_page_link('audit')).'">Full audit log</a></div>';

page_foot();
