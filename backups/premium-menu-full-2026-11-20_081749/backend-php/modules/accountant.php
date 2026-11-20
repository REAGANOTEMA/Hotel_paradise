<?php
declare(strict_types=1);

$u=current_user();
require_once __DIR__.'/../app/finance.php';
require_once __DIR__.'/../app/finance_ui.php';

$act=$_GET['act']??'';
$range=finance_range(30);

if($act!=='' && str_starts_with($act,'export-')){
 $tb=finance_trial_balance($range['from'],$range['to_excl']);
 $pl=finance_income_statement($range['from'],$range['to_excl']);
 $bs=finance_balance_sheet($range['to']);
 $journal=finance_journal_rows($range['from'],$range['to_excl'],'',1000);
 $out=[];
 $name='accountant-'.$range['from'].'_'.$range['to'].'.csv';
 $headers=[];
 if($act==='export-tb'){
  $headers=['Code','Account','Type','Debit','Credit'];
  foreach($tb as $r) $out[]=[$r['account_code'],$r['account_name'],$r['account_type'],$r['debit'],$r['credit']];
  $name='trial-balance-'.$range['from'].'_'.$range['to'].'.csv';
 }elseif($act==='export-pl'){
  $headers=['Section','Code','Account','Amount'];
  foreach($pl['income'] as $r) $out[]=['Income',$r['account_code'],$r['account_name'],(float)$r['credit']-(float)$r['debit']];
  foreach($pl['expense'] as $r) $out[]=['Expense',$r['account_code'],$r['account_name'],(float)$r['debit']-(float)$r['credit']];
  $out[]=['Net','','Net profit',(float)$pl['net']];
  $name='income-statement-'.$range['from'].'_'.$range['to'].'.csv';
 }elseif($act==='export-bs'){
  $headers=['Section','Code','Account','Amount'];
  foreach($bs['assets'] as $r) $out[]=['Asset',$r['account_code'],$r['account_name'],(float)$r['debit']-(float)$r['credit']];
  foreach($bs['liabilities'] as $r) $out[]=['Liability',$r['account_code'],$r['account_name'],(float)$r['credit']-(float)$r['debit']];
  foreach($bs['equity'] as $r) $out[]=['Equity',$r['account_code'],$r['account_name'],(float)$r['credit']-(float)$r['debit']];
  $out[]=['Net','','Net income',(float)$bs['net_income']];
  $name='balance-sheet-'.$range['to'].'.csv';
 }elseif($act==='export-journal'){
  $headers=['Entry','Date','Description','Status','Created by','Posted by','Amount'];
  foreach($journal as $j) $out[]=[$j['entry_number'],$j['entry_date'],$j['description'],$j['status'],$j['created_name']??'', $j['posted_name']??'', $j['total']];
  $name='journal-'.$range['from'].'_'.$range['to'].'.csv';
 }else{
  finance_csv_download('accountant-'.$range['from'].'_'.$range['to'].'.csv',['No data'],[['No data']]);
 }
 finance_csv_download($name,$headers,$out);
}

if($_SERVER['REQUEST_METHOD']==='POST'){
 switch($act){
  case 'seed':
   $n=finance_seed_accounts();
   flash($n.' standard account(s) added to the chart of accounts.','ok');
   go('accountant');
   break;
  case 'post-auto':
   $r=finance_post_auto($range['from'],$range['to_excl'],(int)$u['id']);
   $msg='Automatic posting: '.$r['posted'].' posted, '.$r['skipped'].' skipped.';
   if(!$r['ok'] && $r['error']) $msg.=' '.$r['error'];
   flash($msg,$r['ok']?'ok':'warn');
   go('accountant',['from'=>$range['from'],'to'=>$range['to']]);
   break;
  case 'journal':
   $date=(string)($_POST['entry_date']??today());
   $desc=trim((string)($_POST['description']??''));
   $debit=(int)($_POST['debit_account']??0);
   $credit=(int)($_POST['credit_account']??0);
   $amount=(float)($_POST['amount']??0);
   if($desc===''||$debit<=0||$credit<=0||$amount<=0||$debit===$credit){
    flash('Complete the date, description, two different accounts and an amount above zero.','bad');
    go('accountant');
   }
   $r=finance_insert_journal($date,$desc,[
    ['account_id'=>$debit,'debit'=>$amount,'credit'=>0,'memo'=>$desc],
    ['account_id'=>$credit,'debit'=>0,'credit'=>$amount,'memo'=>$desc],
   ],(int)$u['id'],true);
   flash($r['ok']?'Journal entry posted.':(string)$r['error'],$r['ok']?'ok':'bad');
   go('accountant');
   break;
  case 'reverse':
   $r=finance_reverse_journal((int)($_POST['entry_id']??0),(string)($_POST['reason']??''),(int)$u['id']);
   flash($r['ok']?'Reversal journal posted.':(string)$r['error'],$r['ok']?'ok':'bad');
   go('accountant');
   break;
  case 'period-create':
   $r=finance_period_create((string)($_POST['period_name']??''),(string)($_POST['start_date']??''),(string)($_POST['end_date']??''),(int)$u['id']);
   flash($r['ok']?'Financial period created.':(string)$r['error'],$r['ok']?'ok':'bad');
   go('accountant');
   break;
  case 'period-close':
   $r=finance_period_close((int)($_POST['period_id']??0),(int)$u['id']);
   flash($r['ok']?'Financial period closed.':(string)$r['error'],$r['ok']?'ok':'bad');
   go('accountant');
   break;
  case 'period-reopen':
   $r=finance_period_reopen((int)($_POST['period_id']??0),(int)$u['id']);
   flash($r['ok']?'Financial period reopened.':(string)$r['error'],$r['ok']?'ok':'bad');
   go('accountant');
   break;
  case 'bank-account':
   $r=finance_bank_account_create($_POST,(int)$u['id']);
   flash($r['ok']?'Bank account added.':(string)$r['error'],$r['ok']?'ok':'bad');
   go('accountant');
   break;
  case 'bank-transaction':
   $r=finance_bank_transaction_add($_POST,(int)$u['id']);
   flash($r['ok']?'Statement line recorded.':(string)$r['error'],$r['ok']?'ok':'bad');
   go('accountant');
   break;
  case 'reconciliation':
   $r=finance_reconciliation_save(
    (int)($_POST['account_id']??0),
    (string)($_POST['period_start']??''),
    (string)($_POST['period_end']??''),
    (float)($_POST['statement_in']??0),
    (float)($_POST['statement_out']??0),
    (float)($_POST['statement_closing']??0),
    (string)($_POST['notes']??''),
    (int)$u['id']
   );
   flash($r['ok']?'Reconciliation prepared with a difference of '.money(abs((float)$r['difference'])).'.':(string)$r['error'],$r['ok']?'ok':'bad');
   go('accountant');
   break;
 }
}

$ready=finance_journal_ready();
$coa=finance_coa_accounts();
$summary=finance_summary($range['from'],$range['to_excl']);
$tb=$ready?finance_trial_balance($range['from'],$range['to_excl']):[];
$pl=$ready?finance_income_statement($range['from'],$range['to_excl']):['income'=>[],'expense'=>[],'total_income'=>0.0,'total_expense'=>0.0,'net'=>0.0];
$bs=$ready?finance_balance_sheet($range['to']):['assets'=>[],'liabilities'=>[],'equity'=>[],'total_assets'=>0.0,'total_liabilities'=>0.0,'total_equity'=>0.0,'net_income'=>0.0];
$journals=$ready?finance_journal_rows($range['from'],$range['to_excl'],trim((string)($_GET['q']??'')),300):[];
$periods=finance_periods();
$receivable=finance_receivables();
$payables=finance_payables();
$tax=finance_tax_summary($range['from'],$range['to_excl']);
$efris=finance_efris_summary();
$bankReady=finance_bank_ready();
$banks=$bankReady?finance_bank_accounts():[];
$reconciliations=$bankReady?finance_reconciliations(0,30):[];
$tbDebit=array_sum(array_map(static fn(array $r): float=>(float)$r['debit'],$tb));
$tbCredit=array_sum(array_map(static fn(array $r): float=>(float)$r['credit'],$tb));

page_head('Accountant Workspace','accountant',$range['label']);
finance_ui_print_header('Accountant workspace',$range['label']);
finance_ui_scripts();
finance_ui_range_form('accountant',$range);

echo '<div class="kpis">';
kpi_card('Collections',money($summary['received']),'Successful payments in range',$summary['received']?'green':'navy');
kpi_card('Paid expenses',money($summary['expenses']),'Expenses paid in range',$summary['expenses']?'warn':'navy');
kpi_card('Operating result',money($pl['net']),'Income statement net result',$pl['net']>=0?'green':'warn');
kpi_card('Receivables',money($summary['receivable']),'Guest and invoice balances',$summary['receivable']?'gold':'navy');
kpi_card('Payables',money($summary['payable']),'Approved unpaid expenses',$summary['payable']?'warn':'navy');
kpi_card('Journal entries',(string)count($journals),'Posted and reversed in range');
kpi_card('Total assets',money($bs['total_assets']),'Balance sheet to '.fmtdate($range['to']));
kpi_card('Net profit to date',money($bs['net_income']),'Income less expenses to date',$bs['net_income']>=0?'green':'warn');
echo '</div>';

if(!$ready){
 finance_ui_alert('The accounting ledger tables are not available in this database. Review and run the finance workspace SQL patch before posting journals.');
 echo '<div class="panel"><h2>Chart of accounts</h2><p class="hint">A standard hotel chart of accounts is configuration data. It can be created once and then adjusted by the accountant.</p>';
 form_open('accountant','seed');
 echo '<button class="btn">Create standard chart of accounts</button>';
 form_close();
 echo '</div>';
}else{
 if(!$coa){
  echo '<div class="panel"><h2>Chart of accounts</h2><p class="hint">The ledger is installed but has no accounts. Create the standard hotel chart of accounts to begin posting.</p>';
  form_open('accountant','seed');
  echo '<button class="btn">Create standard chart of accounts</button>';
  form_close();
  echo '</div>';
 }

 echo '<div class="finSplit"><div class="finStack">';
 echo '<div class="panel"><div class="panelHead"><div><h2>Post automatic entries</h2><p class="hint">Post successful payments and paid expenses for the selected range. Entries are idempotent and closed periods are skipped.</p></div><div class="finTools">'.finance_ui_export_buttons('accountant',array_merge($range,['act'=>'export-journal'])).'</div></div>';
 form_open('accountant','post-auto');
 echo '<button class="btn">Post automatic entries</button>';
 form_close();
 echo '</div>';

 echo '<div class="panel"><h2>Manual journal</h2><p class="hint">A manual journal needs two different accounts and equal debit and credit amounts.</p>';
 form_open('accountant','journal');
 echo '<div class="formGrid">';
 echo '<div class="field"><label>Entry date</label><input type="date" name="entry_date" value="'.e(today()).'" required></div>';
 echo '<div class="field"><label>Amount (UGX)</label><input type="number" name="amount" min="0.01" step="0.01" required></div>';
 echo '<div class="field"><label>Debit account</label><select name="debit_account" required><option value="">Choose account</option>';
 foreach($coa as $a) echo '<option value="'.(int)$a['id'].'">'.e($a['account_code'].' - '.$a['account_name']).'</option>';
 echo '</select></div>';
 echo '<div class="field"><label>Credit account</label><select name="credit_account" required><option value="">Choose account</option>';
 foreach($coa as $a) echo '<option value="'.(int)$a['id'].'">'.e($a['account_code'].' - '.$a['account_name']).'</option>';
 echo '</select></div>';
 echo '</div>';
 echo '<div class="field"><label>Description</label><input type="text" name="description" maxlength="255" required></div>';
 echo '<button class="btn blue">Post journal</button>';
 form_close();
 echo '</div>';

 echo '<div class="panel"><h2>Reverse a journal</h2><p class="hint">Reversal creates a new posted journal with debits and credits swapped. The original stays visible.</p>';
 form_open('accountant','reverse');
 echo '<div class="formGrid">';
 echo '<div class="field"><label>Journal entry</label><select name="entry_id" required><option value="">Choose posted journal</option>';
 foreach($journals as $j) if($j['status']==='posted') echo '<option value="'.(int)$j['id'].'">'.e($j['entry_number'].' - '.$j['entry_date'].' - '.$j['description']).'</option>';
 echo '</select></div>';
 echo '<div class="field"><label>Reason</label><input type="text" name="reason" maxlength="255" required></div>';
 echo '</div><button class="btn danger">Post reversal</button>';
 form_close();
 echo '</div>';

 echo '<div class="panel"><h2>Financial periods</h2><p class="hint">Posts into a closed period are refused. Reopen a period only with a documented reason and management approval.</p>';
 form_open('accountant','period-create');
 echo '<div class="formGrid">';
 echo '<div class="field"><label>Period name</label><input type="text" name="period_name" maxlength="50" placeholder="October 2026" required></div>';
 echo '<div class="field"><label>Start date</label><input type="date" name="start_date" value="'.e(date('Y-m-01')).'" required></div>';
 echo '<div class="field"><label>End date</label><input type="date" name="end_date" value="'.e(date('Y-m-t')).'" required></div>';
 echo '</div><button class="btn">Create period</button>';
 form_close();
 finance_ui_open('accountantPeriods','Period list',[
  'name'=>'Period','dates'=>'Dates','status'=>'Status','action'=>'Action'
 ],'','',false);
 if(!$periods) finance_ui_empty(4,'No financial periods have been created.');
 foreach($periods as $p){
  echo '<tr><td>'.e((string)$p['period_name']).'</td><td>'.e(fmtdate($p['start_date']).' - '.fmtdate($p['end_date'])).'</td><td>'.finance_ui_status((string)$p['status']).'</td><td>';
  if($p['status']==='open'){
   form_open('accountant','period-close');
   echo '<input type="hidden" name="period_id" value="'.(int)$p['id'].'"><button class="btn sm" onclick="return confirm(\'Close this period? Journal posting will be blocked.\')">Close</button>';
   form_close();
  }else{
   form_open('accountant','period-reopen');
   echo '<input type="hidden" name="period_id" value="'.(int)$p['id'].'"><button class="btn sm blue" onclick="return confirm(\'Reopen this period?\')">Reopen</button>';
   form_close();
  }
  echo '</td></tr>';
 }
 finance_ui_close(4,[],'No financial periods.');
 echo '</div>';
 echo '</div><div class="finStack">';

 echo '<div class="panel"><h2>Trial balance</h2><p class="hint">Posted journals only, for the selected range.</p>';
 finance_ui_open('accountantTb','Trial balance',[
  'code'=>'Code','account'=>'Account','type'=>'Type','num:debit'=>'Debit','num:credit'=>'Credit'
 ],'','',true);
 if(!$tb) finance_ui_empty(5,'No posted journals in this range.');
 foreach($tb as $r){
  echo '<tr><td>'.e((string)$r['account_code']).'</td><td>'.e((string)$r['account_name']).'</td><td>'.e(ucfirst((string)$r['account_type'])).'</td>';
  echo '<td class="num">'.money((float)$r['debit']).'</td><td class="num">'.money((float)$r['credit']).'</td></tr>';
 }
 finance_ui_close(5,[3=>['label'=>'Total','value'=>$tbDebit,'money'=>true],4=>['label'=>'Total','value'=>$tbCredit,'money'=>true]],'No trial balance lines.');
 echo '</div>';

 echo '<div class="panel"><h2>Income statement</h2><p class="hint">Revenue less expenses for the selected range.</p>';
 finance_ui_open('accountantPl','Income statement',[
  'section'=>'Section','code'=>'Code','account'=>'Account','num:amount'=>'Amount'
 ],'','',true);
 $plRows=false;
 foreach($pl['income'] as $r){
  $plRows=true;
  echo '<tr><td>Income</td><td>'.e((string)$r['account_code']).'</td><td>'.e((string)$r['account_name']).'</td><td class="num">'.money((float)$r['credit']-(float)$r['debit']).'</td></tr>';
 }
 foreach($pl['expense'] as $r){
  $plRows=true;
  echo '<tr><td>Expense</td><td>'.e((string)$r['account_code']).'</td><td>'.e((string)$r['account_name']).'</td><td class="num">'.money((float)$r['debit']-(float)$r['credit']).'</td></tr>';
 }
 if(!$plRows) finance_ui_empty(4,'No income or expense journals in this range.');
 finance_ui_close(4,[],'No income statement lines.');
 echo '<p class="hint"><b>Net result:</b> '.money((float)$pl['net']).'</p>';
 echo '</div>';

 echo '<div class="panel"><h2>Balance sheet</h2><p class="hint">Position as at '.e(fmtdate($range['to'])).'.</p>';
 finance_ui_open('accountantBs','Balance sheet',[
  'section'=>'Section','code'=>'Code','account'=>'Account','num:amount'=>'Amount'
 ],'','',true);
 $bsRows=false;
 foreach($bs['assets'] as $r){ $bsRows=true; echo '<tr><td>Asset</td><td>'.e((string)$r['account_code']).'</td><td>'.e((string)$r['account_name']).'</td><td class="num">'.money((float)$r['debit']-(float)$r['credit']).'</td></tr>'; }
 foreach($bs['liabilities'] as $r){ $bsRows=true; echo '<tr><td>Liability</td><td>'.e((string)$r['account_code']).'</td><td>'.e((string)$r['account_name']).'</td><td class="num">'.money((float)$r['credit']-(float)$r['debit']).'</td></tr>'; }
 foreach($bs['equity'] as $r){ $bsRows=true; echo '<tr><td>Equity</td><td>'.e((string)$r['account_code']).'</td><td>'.e((string)$r['account_name']).'</td><td class="num">'.money((float)$r['credit']-(float)$r['debit']).'</td></tr>'; }
 if(!$bsRows) finance_ui_empty(4,'No balance sheet journals yet.');
 finance_ui_close(4,[],'No balance sheet lines.');
 echo '<p class="hint"><b>Assets:</b> '.money((float)$bs['total_assets']).' &middot; <b>Liabilities:</b> '.money((float)$bs['total_liabilities']).' &middot; <b>Equity:</b> '.money((float)$bs['total_equity']).' &middot; <b>Net income:</b> '.money((float)$bs['net_income']).'</p>';
 echo '</div>';

 echo '<div class="panel"><h2>Journal register</h2><p class="hint">Every posted, reversed and draft journal in the selected range.</p>';
 finance_ui_open('accountantJournals','Journal register',[
  'entry'=>'Entry','date'=>'Date','description'=>'Description','status'=>'Status','user'=>'Created by','num:total'=>'Amount'
 ],'','',true);
 if(!$journals) finance_ui_empty(6,'No journals in this range.');
 foreach($journals as $j){
  echo '<tr><td>'.e((string)$j['entry_number']).'</td><td>'.e(fmtdate($j['entry_date'])).'</td><td>'.e((string)$j['description']).'</td>';
  echo '<td>'.finance_ui_status((string)$j['status']).'</td><td>'.e((string)($j['created_name']??'-')).'</td><td class="num">'.money((float)$j['total']).'</td></tr>';
 }
 finance_ui_close(6,[],'No journals.');
 echo '</div>';
 echo '</div></div>';
}

echo '<div class="finSplit"><div class="finStack">';
echo '<div class="panel"><h2>Receivables</h2><p class="hint">Open guest, invoice and order balances. These are operational balances, not yet a posted ledger aging report.</p>';
finance_ui_open('accountantRecv','Receivables',['source'=>'Source','ref'=>'Reference','name'=>'Guest or customer','status'=>'Status','num:due'=>'Balance'],'','',true);
$recvRows=0;
foreach($receivable['invoices'] as $r){ $recvRows++; $due=(float)$r['total']-(float)$r['paid']; echo '<tr><td>Invoice</td><td>'.e((string)$r['invoice_number']).'</td><td>'.e((string)$r['billing_name']).'</td><td>'.finance_ui_status((string)$r['status']).'</td><td class="num">'.money($due).'</td></tr>'; }
foreach($receivable['reservations'] as $r){ $recvRows++; echo '<tr><td>Booking</td><td>'.e((string)$r['booking_number']).'</td><td>'.e((string)($r['full_name']??'')).'</td><td>'.finance_ui_status((string)$r['status']).'</td><td class="num">'.money((float)$r['total']-(float)$r['paid']).'</td></tr>'; }
foreach($receivable['orders'] as $r){ $recvRows++; echo '<tr><td>Order</td><td>'.e((string)$r['order_number']).'</td><td>'.e((string)($r['customer_name']??'')).'</td><td>'.finance_ui_status((string)$r['status']).'</td><td class="num">'.money((float)$r['total']-(float)$r['paid']).'</td></tr>'; }
if(!$recvRows) finance_ui_empty(5,'No open receivables.');
finance_ui_close(5,[],'No receivables.');
echo '</div>';

echo '<div class="panel"><h2>Payables</h2><p class="hint">Approved unpaid expenses and paid expenses awaiting nothing further.</p>';
finance_ui_open('accountantPay','Payables',['expense'=>'Expense','category'=>'Category','description'=>'Description','status'=>'Status','num:amount'=>'Amount'],'','',true);
if(!$payables) finance_ui_empty(5,'No approved or paid expenses.');
foreach($payables as $p) echo '<tr><td>'.e((string)$p['number']).'</td><td>'.e((string)$p['category']).'</td><td>'.e((string)$p['description']).'</td><td>'.finance_ui_status((string)$p['status']).'</td><td class="num">'.money((float)$p['amount']).'</td></tr>';
finance_ui_close(5,[],'No payables.');
echo '</div>';
echo '</div><div class="finStack">';

echo '<div class="panel"><h2>Tax and service charge</h2><p class="hint">POS tax is currently a 3.5% service charge. Do not treat it as VAT without a configured VAT rate.</p>';
finance_ui_open('accountantTax','Tax summary',['source'=>'Source','num:orders'=>'Documents','num:subtotal'=>'Subtotal','num:tax'=>'Tax / service','num:total'=>'Total'],'','',false);
echo '<tr><td>Orders</td><td class="num">'.(int)($tax['orders']['orders']??0).'</td><td class="num">'.money((float)($tax['orders']['subtotal']??0)).'</td><td class="num">'.money((float)($tax['orders']['tax']??0)).'</td><td class="num">'.money((float)($tax['orders']['total']??0)).'</td></tr>';
echo '<tr><td>Invoices</td><td class="num">'.(int)($tax['invoices']['invoices']??0).'</td><td class="num">'.money((float)($tax['invoices']['subtotal']??0)).'</td><td class="num">'.money((float)($tax['invoices']['tax']??0)).'</td><td class="num">'.money((float)($tax['invoices']['total']??0)).'</td></tr>';
finance_ui_close(5,[],'No tax data.');
echo '</div>';

echo '<div class="panel"><h2>eFRIS readiness</h2><p class="hint">This page reports internal invoice status only. No URA submission is attempted here.</p>';
if(!$efris['ready']){
 finance_ui_alert('eFRIS invoice tables are not installed. Fiscalisation remains unavailable.');
}elseif(!$efris['counts']){
 finance_ui_alert('eFRIS tables are installed but no fiscal invoices have been recorded.');
}else{
 finance_ui_open('accountantEfris','eFRIS invoice states',['status'=>'Status','num:total'=>'Invoices'],'','',false);
 foreach($efris['counts'] as $c) echo '<tr><td>'.finance_ui_status((string)$c['status']).'</td><td class="num">'.(int)$c['total'].'</td></tr>';
 finance_ui_close(2,[],'No eFRIS invoices.');
}
echo '</div>';
echo '</div></div>';

echo '<div class="panel"><h2>Bank reconciliation</h2><p class="hint">Configure bank and mobile money accounts, record statement lines, then prepare a reconciliation. The auditor reviews the saved snapshot.</p>';
if(!$bankReady){
 finance_ui_alert('Bank reconciliation tables are not installed. Review and run database/sql/patches/2026-10-31_finance_workspace.sql.');
}else{
 echo '<div class="finSplit"><div>';
 echo '<h3>Add account</h3>';
 form_open('accountant','bank-account');
 echo '<div class="formGrid">';
 echo '<div class="field"><label>Account name</label><input type="text" name="name" maxlength="150" required></div>';
 echo '<div class="field"><label>Bank or provider</label><input type="text" name="bank_name" maxlength="150"></div>';
 echo '<div class="field"><label>Account holder</label><input type="text" name="account_name" maxlength="190"></div>';
 echo '<div class="field"><label>Last four digits</label><input type="text" name="last4" maxlength="12"></div>';
 echo '<div class="field"><label>Payment method</label><select name="method" required>';
 foreach(payment_methods() as $k=>$v) echo '<option value="'.e($k).'">'.e($v).'</option>';
 echo '</select></div>';
 echo '<div class="field"><label>Opening balance</label><input type="number" name="opening_balance" step="0.01" value="0" required></div>';
 echo '<div class="field"><label>Currency</label><input type="text" name="currency" value="UGX" maxlength="8" required></div>';
 echo '</div><button class="btn">Add account</button>';
 form_close();

 echo '<h3 style="margin-top:18px">Record statement line</h3>';
 form_open('accountant','bank-transaction');
 echo '<div class="formGrid">';
 echo '<div class="field"><label>Bank account</label><select name="account_id" required><option value="">Choose account</option>';
 foreach($banks as $b) echo '<option value="'.(int)$b['id'].'">'.e((string)$b['name']).'</option>';
 echo '</select></div>';
 echo '<div class="field"><label>Statement date</label><input type="date" name="transaction_date" value="'.e(today()).'" required></div>';
 echo '<div class="field"><label>Direction</label><select name="direction" required><option value="in">Money in</option><option value="out">Money out</option></select></div>';
 echo '<div class="field"><label>Amount</label><input type="number" name="amount" min="0.01" step="0.01" required></div>';
 echo '<div class="field"><label>Reference</label><input type="text" name="reference" maxlength="190"></div>';
 echo '</div>';
 echo '<div class="field"><label>Description</label><input type="text" name="description" maxlength="255" required></div>';
 echo '<button class="btn blue">Record statement line</button>';
 form_close();
 echo '</div><div>';
 echo '<h3>Prepare reconciliation</h3>';
 form_open('accountant','reconciliation');
 echo '<div class="formGrid">';
 echo '<div class="field"><label>Bank account</label><select name="account_id" required><option value="">Choose account</option>';
 foreach($banks as $b) echo '<option value="'.(int)$b['id'].'">'.e((string)$b['name']).'</option>';
 echo '</select></div>';
 echo '<div class="field"><label>Period start</label><input type="date" name="period_start" value="'.e(date('Y-m-01')).'" required></div>';
 echo '<div class="field"><label>Period end</label><input type="date" name="period_end" value="'.e(date('Y-m-t')).'" required></div>';
 echo '<div class="field"><label>Statement money in</label><input type="number" name="statement_in" step="0.01" value="0" required></div>';
 echo '<div class="field"><label>Statement money out</label><input type="number" name="statement_out" step="0.01" value="0" required></div>';
 echo '<div class="field"><label>Statement closing</label><input type="number" name="statement_closing" step="0.01" value="0" required></div>';
 echo '</div>';
 echo '<div class="field"><label>Notes</label><input type="text" name="notes" maxlength="500"></div>';
 echo '<button class="btn">Prepare reconciliation</button>';
 form_close();
 echo '</div></div>';

 finance_ui_open('accountantBanks','Bank accounts',['account'=>'Account','method'=>'Method','number'=>'Last four','num:book'=>'Book to date','num:statement'=>'Statement to date','num:gap'=>'Difference'],'','',true);
 if(!$banks) finance_ui_empty(6,'No bank accounts yet.');
 foreach($banks as $b){
  $book=finance_bank_book_balance($b,'1970-01-01',date('Y-m-d',strtotime($range['to'].' +1 day')));
  $statement=finance_bank_statement_balance($b,'1970-01-01',date('Y-m-d',strtotime($range['to'].' +1 day')));
  $gap=$statement-$book;
  echo '<tr><td>'.e((string)$b['name']).'</td><td>'.e(finance_method_label((string)$b['method'])).'</td><td>'.e((string)($b['account_number_last4']??'-')).'</td>';
  echo '<td class="num">'.money($book).'</td><td class="num">'.money($statement).'</td><td class="num" style="color:'.(abs($gap)>0.009?'#c62828':'#2e7d32').'">'.($gap<0?'-':'').money(abs($gap)).'</td></tr>';
 }
 finance_ui_close(6,[],'No bank accounts.');
 echo '</div>';

 echo '<div class="panel"><h2>Recent statement lines</h2><p class="hint">Imported statement lines are evidence for reconciliation. They do not post to the ledger automatically.</p>';
 $statementLines=$bankReady?rows("SELECT t.*,a.name account_name FROM finance_bank_transactions t JOIN finance_bank_accounts a ON a.id=t.account_id ORDER BY t.transaction_date DESC,t.id DESC LIMIT 120",[]):[];
 finance_ui_open('accountantBankLines','Statement lines',['date'=>'Date','account'=>'Account','description'=>'Description','reference'=>'Reference','direction'=>'Direction','num:amount'=>'Amount','status'=>'Status'],'','',true);
 if(!$statementLines) finance_ui_empty(7,'No statement lines recorded.');
 foreach($statementLines as $t) echo '<tr><td>'.e(fmtdate($t['transaction_date'])).'</td><td>'.e((string)$t['account_name']).'</td><td>'.e((string)$t['description']).'</td><td>'.e((string)($t['reference']??'-')).'</td><td>'.e(ucfirst((string)$t['direction'])).'</td><td class="num">'.money((float)$t['amount']).'</td><td>'.finance_ui_status((string)$t['status']).'</td></tr>';
 finance_ui_close(7,[],'No statement lines.');
 echo '</div>';

 echo '<div class="panel"><h2>Saved reconciliations</h2><p class="hint">A reconciliation is a snapshot of the book balance and statement balance at the period end.</p>';
 finance_ui_open('accountantRecons','Reconciliations',['account'=>'Account','period'=>'Period','status'=>'Status','num:book'=>'Book','num:statement'=>'Statement','num:difference'=>'Difference','prepared'=>'Prepared by'],'','',true);
 if(!$reconciliations) finance_ui_empty(7,'No reconciliations saved.');
 foreach($reconciliations as $r){
  $diff=(float)($r['difference']??0);
  echo '<tr><td>'.e((string)($r['account_name']??'-')).'</td><td>'.e(fmtdate($r['period_start']).' - '.fmtdate($r['period_end'])).'</td><td>'.finance_ui_status((string)$r['status']).'</td>';
  echo '<td class="num">'.money((float)($r['book_balance']??0)).'</td><td class="num">'.money((float)($r['statement_closing']??0)).'</td>';
  echo '<td class="num" style="color:'.(abs($diff)>0.009?'#c62828':'#2e7d32').'">'.($diff<0?'-':'').money(abs($diff)).'</td><td>'.e((string)($r['prepared_name']??'-')).'</td></tr>';
 }
 finance_ui_close(7,[],'No reconciliations.');
 echo '</div>';
}
echo '</div>';

echo '<div class="toolbar"><a class="btnGhost" href="'.e(finance_page_link('cashier')).'">Cashier workspace</a><a class="btnGhost" href="'.e(finance_page_link('auditor')).'">Auditor workspace</a><a class="btnGhost" href="'.e(finance_page_link('expenses')).'">Expenses</a></div>';

page_foot();
