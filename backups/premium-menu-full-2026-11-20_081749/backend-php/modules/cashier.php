<?php
declare(strict_types=1);

$u=current_user();
require_once __DIR__.'/../app/finance.php';
require_once __DIR__.'/../app/finance_ui.php';

$act=$_GET['act']??'';
$range=finance_range(0);
$canCash=finance_role_can('cash');

if($act==='export'||($_GET['export']??'')==='csv'){
 $rows=finance_payment_rows([
  'from'=>$range['from'],
  'to_excl'=>$range['to_excl'],
  'limit'=>5000,
 ]);
 $out=[];
 foreach($rows as $p){
  $out[]=[
   $p['id'],
   $p['created_at'],
   $p['source'],
   $p['order_number']??$p['invoice_number']??$p['booking_number']??'',
   $p['method'],
   $p['status'],
   $p['amount'],
   $p['provider_reference']??'',
   $p['payer_phone']??'',
   $p['recorded_by']??'',
  ];
 }
 finance_csv_download('cashier-payments-'.$range['from'].'_'.$range['to'].'.csv',
  ['Payment','Time','Source','Reference','Method','Status','Amount','Provider reference','Payer phone','Recorded by'],$out);
}

if($_SERVER['REQUEST_METHOD']==='POST'){
 if(!$canCash){
  flash('Your role has read-only access to the cashier workspace.','bad');
  go('cashier');
 }
 switch($act){
  case 'open':
   $r=finance_shift_open((string)($_POST['outlet']??''),(float)($_POST['opening_cash']??0),(int)$u['id']);
   flash($r['ok']?'Shift opened with opening cash '.money((float)($_POST['opening_cash']??0)).'.':(string)$r['error'],$r['ok']?'ok':'bad');
   go('cashier');
   break;
  case 'close':
   $r=finance_shift_close((int)($_POST['sid']??0),(int)$u['id'],(float)($_POST['counted']??0),false);
   flash($r['ok']?'Shift closed. Expected '.money((float)$r['expected']).', variance '.((float)$r['variance']<0?'-':'').money(abs((float)$r['variance'])).'.':(string)$r['error'],$r['ok']?'ok':'bad');
   go('cashier');
   break;
  case 'movement':
   $r=finance_cash_movement(
    (int)($_POST['sid']??0),
    (int)$u['id'],
    (string)($_POST['movement_type']??''),
    (string)($_POST['direction']??''),
    (float)($_POST['amount']??0),
    (string)($_POST['reason']??''),
    (string)($_POST['reference']??''),
    false
   );
   flash($r['ok']?'Drawer movement recorded.':(string)$r['error'],$r['ok']?'ok':'bad');
   go('cashier');
   break;
 }
}

$shift=finance_open_shift((int)$u['id']);
$today=finance_summary(today().' 00:00:00',date('Y-m-d',strtotime(today().' +1 day')).' 00:00:00');
$myPayments=finance_payment_rows([
 'from'=>today().' 00:00:00',
 'to_excl'=>date('Y-m-d',strtotime(today().' +1 day')).' 00:00:00',
 'limit'=>5000,
]);
$myPayments=array_values(array_filter($myPayments,static fn(array $p): bool=>(int)($p['user_id']??0)===(int)$u['id']));
$myTotals=finance_payment_totals($myPayments);

page_head('Cashier Workspace','cashier',date('l, j F Y').' - cash desk');
finance_ui_print_header('Cashier workspace',$range['label']);
finance_ui_scripts();

echo '<div class="kpis">';
kpi_card('Cash received today',money($today['cash']),'Successful cash payments',$today['cash']?'green':'navy');
kpi_card('My collections today',money($myTotals['successful']),'All methods recorded by me',$myTotals['successful']?'green':'navy');
kpi_card('Pending payments',money($today['pending_amount']),$today['pending_count'].' awaiting confirmation',$today['pending_amount']?'gold':'navy');
kpi_card('Receivable balance',money($today['receivable']),'Orders, invoices and bookings',$today['receivable']?'warn':'navy');
kpi_card('Open shifts',(string)$today['open_shifts'],'Across all outlets',$today['open_shifts']?'blue':'navy');
kpi_card('Shift status',$shift?'Open':'Closed',$shift?ucfirst((string)$shift['outlet']).' since '.fmtdt($shift['opened_at']):'Start a shift to take cash',$shift?'green':'warn');
echo '</div>';

if(!$shift){
 if(!$canCash){
  finance_ui_alert('No shift is open. Your role has read-only access to the cashier workspace.');
 }else{
  echo '<div class="panel" style="max-width:620px"><h2>Open your shift</h2><p class="hint">Opening cash is the physical cash in the drawer before the first sale. It is not revenue.</p>';
  form_open('cashier','open');
  echo '<div class="formGrid">';
  echo '<div class="field"><label>Outlet</label><select name="outlet" required>';
  foreach(['restaurant'=>'Restaurant','bar'=>'Bar','front_desk'=>'Front desk','store'=>'Store'] as $k=>$v) echo '<option value="'.e($k).'">'.e($v).'</option>';
  echo '</select></div>';
  echo '<div class="field"><label>Opening cash (UGX)</label><input type="number" name="opening_cash" min="0" step="100" value="0" required></div>';
  echo '</div><button class="btn">Open shift</button>';
  form_close();
  echo '</div>';
 }
}else{
 $expected=finance_shift_expected_cash($shift);
 $cashSales=finance_shift_cash_sales($shift);
 $movement=finance_shift_movement_total((int)$shift['id']);
 $byMethod=finance_shift_by_method($shift);
 $movements=finance_shift_movements((int)$shift['id']);
 $shiftPayments=finance_shift_payments($shift,5000);
 $shiftTotals=finance_payment_totals($shiftPayments);

 echo '<div class="finSplit"><div class="finStack">';
 echo '<div class="panel"><div class="panelHead"><div><h2>Current shift</h2><p class="hint">'.e(ucfirst((string)$shift['outlet'])).' opened '.fmtdt($shift['opened_at']).'. Expected cash combines opening cash, cash collections and drawer movements.</p></div><div class="finTools">'.finance_ui_export_buttons('cashier',$range).'</div></div>';
 echo '<div class="kpis">';
 kpi_card('Opening cash',money((float)$shift['opening_cash']),'Float at start');
 kpi_card('Cash collections',money($cashSales),'Successful cash payments');
 kpi_card('Cash in',money($movement['in']),'Drawer additions');
 kpi_card('Cash out',money($movement['out']),'Payouts, drops and refunds');
 kpi_card('Expected cash',money($expected),'Count this before closing',$expected>0?'green':'navy');
 kpi_card('Shift collected',money($shiftTotals['successful']),'All methods in this shift',$shiftTotals['successful']?'green':'navy');
 echo '</div>';

 if($canCash){
  echo '<div class="finSplit" style="margin-top:16px"><div>';
  echo '<h3>Close shift</h3><p class="hint">Settle any unpaid orders first. The variance is the counted cash minus expected cash.</p>';
  form_open('cashier','close');
  echo '<input type="hidden" name="sid" value="'.(int)$shift['id'].'">';
  echo '<div class="formGrid">';
  echo '<div class="field"><label>Cash counted (UGX)</label><input type="number" name="counted" min="0" step="100" required></div>';
  echo '<div class="field"><label>Expected cash</label><input type="text" value="'.e(money($expected)).'" readonly></div>';
  echo '</div><button class="btn" onclick="return confirm(\'Close this shift now?\')">Close shift</button>';
  form_close();
  echo '</div><div>';
  echo '<h3>Record drawer movement</h3><p class="hint">Every movement needs a reason. Large cash-outs alert management.</p>';
  form_open('cashier','movement');
  echo '<input type="hidden" name="sid" value="'.(int)$shift['id'].'">';
  echo '<div class="formGrid">';
  echo '<div class="field"><label>Movement type</label><select name="movement_type" required>';
  foreach(['float'=>'Float','cash_in'=>'Cash in','cash_out'=>'Cash out','drop'=>'Bank drop','payout'=>'Payout','refund'=>'Refund','correction'=>'Correction'] as $k=>$v) echo '<option value="'.e($k).'">'.e($v).'</option>';
  echo '</select></div>';
  echo '<div class="field"><label>Direction</label><select name="direction" required><option value="in">Cash in</option><option value="out">Cash out</option></select></div>';
  echo '<div class="field"><label>Amount (UGX)</label><input type="number" name="amount" min="1" step="100" required></div>';
  echo '<div class="field"><label>Reference</label><input type="text" name="reference" maxlength="190"></div>';
  echo '</div>';
  echo '<div class="field"><label>Reason</label><textarea name="reason" rows="2" maxlength="500" required></textarea></div>';
  echo '<button class="btn blue">Record movement</button>';
  form_close();
  echo '</div></div>';
 }else{
  finance_ui_alert('Your role can read the shift, payments and drawer movements but cannot change them.');
 }
 echo '</div></div>';

 echo '<div class="panel"><h2>Payments in this shift</h2><p class="hint">Payments linked to this shift, plus older payments recorded by you during the shift window.</p>';
 finance_ui_open('cashierShiftPayments','Shift payments',[
  'time'=>'Time','source'=>'Source','ref'=>'Reference','method'=>'Method','status'=>'Status','num:amount'=>'Amount','user'=>'Recorded by'
 ],'','',true);
 if(!$shiftPayments) finance_ui_empty(7,'No payments have been recorded in this shift yet.');
 foreach($shiftPayments as $p){
  $ref=$p['order_number']??$p['invoice_number']??$p['booking_number']??('Payment #'.(int)$p['id']);
  echo '<tr><td>'.e(fmtdt($p['created_at'])).'</td><td>'.e(ucfirst((string)$p['source'])).'</td><td>'.e((string)$ref).'</td>';
  echo '<td>'.e(finance_method_label((string)$p['method'])).'</td><td>'.finance_ui_status((string)$p['status']).'</td>';
  echo '<td class="num">'.money((float)$p['amount']).'</td><td>'.e((string)($p['recorded_by']??'-')).'</td></tr>';
 }
 finance_ui_close(7,[5=>['label'=>'Total','value'=>$shiftTotals['successful'],'money'=>true]],'No payments in this shift.');
 echo '</div>';

 echo '<div class="panel"><h2>Drawer movements</h2><p class="hint">Cash movements are separate from sales and are included in expected cash.</p>';
 finance_ui_open('cashierMovements','Drawer movements',[
  'time'=>'Time','type'=>'Type','direction'=>'Direction','num:amount'=>'Amount','reason'=>'Reason','status'=>'Status'
 ],'','',true);
 if(!$movements) finance_ui_empty(6,'No drawer movements recorded in this shift.');
 $movementTotal=0.0;
 foreach($movements as $m){
  $signed=(string)$m['direction']==='out'?-(float)$m['amount']:(float)$m['amount'];
  $movementTotal+=$signed;
  echo '<tr><td>'.e(fmtdt($m['created_at'])).'</td><td>'.e(str_replace('_',' ',ucfirst((string)$m['movement_type']))).'</td>';
  echo '<td>'.e(ucfirst((string)$m['direction'])).'</td><td class="num" style="color:'.($signed<0?'#c62828':'#2e7d32').'">'.($signed<0?'-':'').money(abs($signed)).'</td>';
  echo '<td>'.e((string)$m['reason']).($m['reference']?' <span class="hint">('.e((string)$m['reference']).')</span>':' ').'</td>';
  echo '<td>'.finance_ui_status((string)$m['status']).'</td></tr>';
 }
 finance_ui_close(6,[3=>['label'=>'Net','value'=>$movementTotal,'money'=>true]],'No drawer movements.');
 echo '</div>';

 echo '<div class="panel"><h2>Today by payment method</h2><p class="hint">All successful collections recorded today, across the desk.</p>';
 finance_ui_open('cashierMethods','Collections by method',[
  'method'=>'Method','num:transactions'=>'Transactions','num:amount'=>'Amount'
 ],'','',false);
 $methodTotal=0.0;
 if(!$byMethod) finance_ui_empty(3,'No successful payments today.');
 foreach($byMethod as $m){
  $methodTotal+=(float)$m['amount'];
  echo '<tr><td>'.e(finance_method_label((string)$m['method'])).'</td><td class="num">'.(int)$m['transactions'].'</td><td class="num">'.money((float)$m['amount']).'</td></tr>';
 }
 finance_ui_close(3,[2=>['label'=>'Total','value'=>$methodTotal,'money'=>true]],'No collections today.');
 echo '</div>';
}

echo '<div class="toolbar"><a class="btnGhost" href="'.e(finance_page_link('finance',['from'=>$range['from'],'to'=>$range['to']])).'">Open finance ledger</a>';
echo '<a class="btnGhost" href="'.e(finance_page_link('shifts')).'">Shift history</a></div>';

page_foot();
