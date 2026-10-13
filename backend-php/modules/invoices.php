<?php
declare(strict_types=1);
$u=current_user();
require_once __DIR__.'/../app/invoices.php';

/* =====================================================================
   INVOICES — the hotel's billing desk
   =====================================================================
   Issues numbered invoices from guests and their bookings, voids them with a
   reason, gives discounts, records adjustments, and watches what the online
   (Pesapal) gateway has verified. Read by anyone who can reach the page;
   writing (issue/void/discount/adjust/record) is kept to the finance desks.
   ===================================================================== */

if(!invoice_can()){ page_head('Invoices'); echo '<div class="panel"><p class="hint">Access restricted to finance and management.</p></div>'; page_foot(); return; }
if(!invoice_ready()){ page_head('Invoices','','Invoicing is not on this installation yet'); echo '<div class="panel" style="border-left:4px solid var(--warn,#e0a800)"><h2>Invoicing upgrade not installed</h2><p class="hint">Run the three files in <b>database/invoice_module_sql/</b> against the MAIN database before the billing desk goes live. They are idempotent and safe to re-run.</p></div>'; page_foot(); return; }

/* ---------------- shared painters ---------------- */

/** A neat table of lines plus the running totals. */
function formula_invoice_lines(int $view,array $lines): void{
 echo '<table class="tbl"><thead><tr><th class="num">#</th><th>Description</th><th class="num">Qty</th><th class="num">Unit</th><th class="num">Total</th></tr></thead><tbody>';
 if(!$lines){ echo '<tr><td colspan="5" class="hint">No lines on this invoice yet.</td></tr>'; }
 foreach($lines as $l){
  echo '<tr><td class="num">'.e(($l['item_no']??'')).'</td><td>'.e($l['description']).'</td>'
   .'<td class="num">'.e(rtrim(rtrim(number_format((float)$l['quantity'],2,'.',''),'0'),'.')).'</td>'
   .'<td class="num">'.money($l['unit_price']).'</td>'
   .'<td class="num">'.money($l['total']).'</td></tr>';
 }
 $inv=row('SELECT subtotal,discount,total FROM invoices WHERE id=?',[$view]);
 echo '<tr><td colspan="4" class="num">Subtotal</td><td class="num">'.money($inv['subtotal']??0).'</td></tr>';
 if((float)($inv['discount']??0)>0) echo '<tr><td colspan="4" class="num">Discount</td><td class="num">-'.money($inv['discount']).'</td></tr>';
 echo '<tr><td colspan="4" class="num"><b>Total</b></td><td class="num"><b>'.money($inv['total']??0).'</b></td></tr>';
 echo '</tbody></table>';
}

/**
 * The printed invoice: a whole, self-contained, branded page.
 *
 * It carries the hotel's own crest, its address and its colours, so a bill that
 * leaves the desk looks like the house and not like a spreadsheet. It is built
 * as one HTML document and handed to a fresh window, which prints exactly the
 * sheet and nothing of the console around it. The document is JSON-encoded into
 * the script so no line, however it is punctuated, can break the page.
 */
function invoice_print(array $inv,array $lines,float $paid,float $due): void{
 $b=hotel_brand();
 $num=(string)($inv['invoice_number']?:('Draft #'.$inv['id']));
 $issued=fmtdt($inv['issued_at']??$inv['created_at']);
 $dueDate=substr((string)($inv['due_date']??''),0,10);
 $statusRaw=(string)$inv['status'];
 $statusLabel=ucwords(str_replace('_',' ',$statusRaw));
 $void=in_array($statusRaw,['cancelled','void','refunded'],true);
 $paidOff=!$void && $due<=0.0001 && $paid>0;

 $subtotal=(float)($inv['subtotal']??0);
 $discount=(float)($inv['discount']??0);
 $total=(float)($inv['total']??0);

 $rows=''; $i=0;
 foreach($lines as $l){
  $i++;
  $qty=rtrim(rtrim(number_format((float)$l['quantity'],2,'.',''),'0'),'.');
  $rows.='<tr><td class="num">'.$i.'</td><td>'.e((string)$l['description']).'</td>'
   .'<td class="num">'.e($qty).'</td><td class="num">'.money($l['unit_price']).'</td><td class="num">'.money($l['total']).'</td></tr>';
 }
 if($i===0) $rows='<tr><td colspan="5" style="text-align:center;color:#8a99ab;padding:18px">No lines on this invoice.</td></tr>';

 $billName=trim((string)($inv['billing_name']??''));
 $billEmail=trim((string)($inv['billing_email']??''));
 $billPhone=trim((string)($inv['billing_phone']??''));

 $body='<div class="doc">'
  .($void?'<div class="watermark">VOID</div>':'')
  .'<header class="docHead">'
   .'<div class="docBrand"><img class="docLogo" src="'.e($b['logo']).'" alt="">'
    .'<div><div class="docName">HOTEL PARADISE<span>ON THE NILE</span></div>'
    .'<div class="docTag">'.e($b['city']).' &middot; '.e($b['country']).' &middot; Since 1998</div></div></div>'
   .'<div class="docContact"><div><b>'.e($b['legal']).'</b></div>'
    .'<div>'.e($b['address']).'</div><div>'.e($b['po_box']).'</div>'
    .'<div>Tel: '.e(implode(' / ',$b['phones'])).'</div>'
    .'<div>'.e($b['email']).'</div><div>'.e($b['website']).'</div></div>'
  .'</header>'
  .'<div class="docTitle"><div class="docKind">INVOICE</div><div class="docNo">'.e($num).'</div></div>'
  .'<div class="docMeta">'
   .'<div class="metaBlock"><h4>BILLED TO</h4><p><b>'.e($billName!==''?$billName:'-').'</b>'
    .($billEmail!==''?'<br>'.e($billEmail):'').($billPhone!==''?'<br>'.e($billPhone):'').'</p></div>'
   .'<div class="metaBlock right"><h4>DETAILS</h4><table class="kv">'
    .'<tr><td>Issued</td><td>'.e($issued).'</td></tr>'
    .($dueDate!==''?'<tr><td>Due</td><td>'.e($dueDate).'</td></tr>':'')
    .'<tr><td>Status</td><td>'.e($statusLabel).'</td></tr>'
   .'</table></div>'
  .'</div>'
  .'<table class="lines"><thead><tr><th class="num">#</th><th>Description</th><th class="num">Qty</th><th class="num">Unit</th><th class="num">Total</th></tr></thead><tbody>'.$rows.'</tbody></table>'
  .'<div class="docFoot">'
   .'<div class="words"><b>AMOUNT IN WORDS</b>'.e(amount_in_words($total)).'</div>'
   .'<table class="totals">'
    .'<tr><td>Subtotal</td><td>'.money($subtotal).'</td></tr>'
    .($discount>0?'<tr><td>Discount</td><td>-'.money($discount).'</td></tr>':'')
    .'<tr class="grand"><td>Total</td><td>'.money($total).'</td></tr>'
    .($paid>0?'<tr><td>Received</td><td>'.money($paid).'</td></tr>':'')
    .'<tr class="'.($due>0?'balance':'').'"><td>Balance due</td><td>'.money($due).'</td></tr>'
   .'</table>'
  .'</div>'
  .'<div class="docSign"><div class="signLine">Authorised signature</div>'
   .($paidOff?'<div class="stamp">PAID</div>':($void?'<div class="stamp void">VOID</div>':'')).'</div>'
  .(!empty($inv['notes'])?'<div class="docTerms"><b>Notes:</b> '.e((string)$inv['notes']).'</div>':'')
  .'<div class="docTerms">Thank you for choosing '.e($b['name']).'. Kindly settle any balance by the date shown. Payments are accepted by cash, mobile money, card or bank transfer. This document is computer generated and is valid without a handwritten signature.</div>'
  .'<div class="docCredit">Designed by Reagansoft Innovation Limited &middot; reagansoftinnovation.com</div>'
  .'</div>';

 $doc='<!doctype html><html lang="en"><head><meta charset="utf-8">'
  .'<meta name="viewport" content="width=device-width,initial-scale=1">'
  .'<title>Invoice '.e($num).' &middot; '.e($b['name']).'</title>'
  .'<style>'.document_css().'</style></head><body>'.$body
  .'<div class="noprint" style="text-align:center;margin:18px">'
  .'<button onclick="window.print()" style="padding:11px 22px;border:0;border-radius:9px;background:#0b2545;color:#fff;font:600 14px Arial,Helvetica,sans-serif;cursor:pointer">Print / Save PDF</button></div>'
  .'<style>@media print{.noprint{display:none}}</style></body></html>';

 $docJs=json_encode($doc,JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE|JSON_HEX_TAG|JSON_HEX_AMP|JSON_HEX_APOS|JSON_HEX_QUOT);
 echo '<button class="btn sm" style="margin-top:14px" onclick="invoicePrint()">Print / Save PDF</button>';
 echo '<script>function invoicePrint(){var w=window.open("","_blank","width=820,height=1000");if(!w){return false}var d=w.document;d.open();d.write('.$docJs.');d.close();w.focus();setTimeout(function(){try{w.print()}catch(e){}},400);return false}</script>';
}

/* ---------------- actions ---------------- */
if($_SERVER['REQUEST_METHOD']==='POST'){
 $act=$_GET['act']??'';
 $id=(int)($_POST['id']??0);

 if($act==='draft'){
  // A fresh draft from the front desk. Held open so lines can be added at the
  // clerk's own pace; only issue() numbers it.
  $bname=trim($_POST['bname']??'');
  if($bname===''){ flash('A billing name is required.','bad'); go('invoices'); }
  $bemail=filter_var(trim($_POST['bemail']??''),FILTER_VALIDATE_EMAIL)?:null;
  $bphone=trim($_POST['bphone']??'');
  $cols=invoice_columns()['invoice'];
  // A draft still needs a number: the column is NOT NULL and UNIQUE on this
  // installation. It gets a provisional tag now and the real INV number when it
  // is issued, so no draft can ever collide with another or with an invoice.
  $provisional=next_number('DRF','invoices','invoice_number');
  $set=['hotel_id'=>1,'invoice_number'=>$provisional,'status'=>'draft','subtotal'=>0.0,'tax'=>0.0,'total'=>0.0];
  if($cols['billing_name']!=='')  $set['billing_name']=$bname;
  if($cols['billing_email']!=='') $set['billing_email']=$bemail;
  if($cols['billing_phone']!=='') $set['billing_phone']=$bphone;
  if($cols['notes']!=='')         $set['notes']=trim($_POST['notes']??'');
  $c=array_keys($set); $v=array_values($set);
  // created_at comes from NOW(), never from PHP.
  $sql='INSERT INTO invoices('.implode(',',$c).',created_at) VALUES('.implode(',',array_fill(0,count($c),'?')).',NOW())';
  q($sql,$v);
  $nid=(int)db()->lastInsertId();
  audit('invoice_draft','invoice',$nid,[],['billing_name'=>$bname]);
  invoice_event($nid,'note',0.0,'Draft started');
  flash('Draft created. Add its lines, then issue.');
  go('invoices',['view'=>$nid]);
 }

 if($act==='line'){
  $inv=row('SELECT * FROM invoices WHERE id=?',[$id]);
  if(!$inv||$inv['status']!=='draft'){ flash('Lines can only be added to an open draft.','bad'); go('invoices'); }
  $desc=trim($_POST['desc']??''); $qty=(float)($_POST['qty']??0); $unit=(float)($_POST['unit']??0);
  $tax=(float)($_POST['tax']??0); $disc=(float)($_POST['disc']??0);
  if($desc===''||$qty<=0||$unit<=0){ flash('A line needs a description, a quantity and a unit price.','bad'); go('invoices',['view'=>$id]); }
  $n=(int)val('SELECT COALESCE(MAX(item_no),0)+1 FROM invoice_items WHERE invoice_id=?',[$id]);
  q('INSERT INTO invoice_items(invoice_id,item_no,description,quantity,unit_price,tax,discount,total)
     VALUES(?,?,?,?,?,?,?,?)',[$id,$n,$desc,$qty,$unit,$tax,$disc,invoice_line_total($qty,$unit,$tax,$disc)]);
  invoice_recompute($id);
  flash('Line added.');
  go('invoices',['view'=>$id]);
 }

 if($act==='issue'){
  if(!invoice_can_write()){ flash('Only finance desks may issue invoices.','bad'); go('invoices'); }
  $inv=row('SELECT * FROM invoices WHERE id=?',[$id]);
  if(!$inv){ flash('Invoice not found.','bad'); go('invoices'); }
  if($inv['status']!=='draft'){ flash('Only a draft can be issued.','bad'); go('invoices',['view'=>$id]); }
  if((int)val('SELECT COUNT(*) FROM invoice_items WHERE invoice_id=?',[$id])===0){ flash('Add at least one line before issuing.','bad'); go('invoices',['view'=>$id]); }
  $bc=invoice_columns()['invoice'];
  if($bc['billing_name']===''||trim((string)$inv['billing_name'])===''){ flash('A billing name is required before issuing.','bad'); go('invoices',['view'=>$id]); }
  $num=invoice_issue($id);
  flash('Invoice '.$num.' issued and open for payment.');
  go('invoices',['view'=>$id]);
 }

 if($act==='void'){
  if(!invoice_can_write()){ flash('Only finance desks may void invoices.','bad'); go('invoices'); }
  $reason=trim($_POST['reason']??'');
  if($reason===''){ flash('A void needs a reason.','bad'); go('invoices',['view'=>$id]); }
  invoice_void($id,$reason);
  flash('Invoice voided on record. Any money already received is a refund decision, not a void.');
  go('invoices',['view'=>$id]);
 }

 if($act==='discount'){
  if(!invoice_can_write()){ flash('Only finance desks may give a discount.','bad'); go('invoices'); }
  $amount=(float)($_POST['amount']??0); $reason=trim($_POST['reason']??'');
  if($amount<=0||$reason===''){ flash('A discount needs a positive amount and a reason.','bad'); go('invoices',['view'=>$id]); }
  invoice_discount($id,$amount,$reason);
  flash('Discount recorded against the invoice.');
  go('invoices',['view'=>$id]);
 }

 if($act==='adjust'){
  if(!invoice_can_write()){ flash('Only finance desks may adjust an invoice.','bad'); go('invoices'); }
  $delta=(float)($_POST['delta']??0); $reason=trim($_POST['reason']??'');
  if($delta==0.0||$reason===''){ flash('An adjustment needs a non-zero figure and a reason.','bad'); go('invoices',['view'=>$id]); }
  invoice_adjust($id,$delta,$reason);
  flash('Adjustment recorded on the invoice.');
  go('invoices',['view'=>$id]);
 }

 if($act==='payment'){
  if(!invoice_can_write()){ flash('Only finance desks may record a payment.','bad'); go('invoices'); }
  $amount=(float)($_POST['amount']??0); $method=trim($_POST['method']??'');
  if($amount<=0||!array_key_exists($method,payment_methods())){ flash('Choose a valid method and a positive amount.','bad'); go('invoices',['view'=>$id]); }
  $inv=row('SELECT * FROM invoices WHERE id=?',[$id]);
  if(!$inv){ flash('Invoice not found.','bad'); go('invoices'); }
  $due=invoice_balance($id);
  if($due<=0){ flash('This invoice is already settled.','bad'); go('invoices',['view'=>$id]); }
  $rec=min($amount,$due);
  $ref=next_number('PAY','payments','provider_reference');
  q('INSERT INTO payments(hotel_id,user_id,invoice_id,amount,method,provider,provider_reference,status,created_at)
     VALUES(1,?,?,?,?,?,?,?,NOW())',
   [$u['id']??null,$id,$rec,$method,$method==='cash'?'cash':'desk',$ref,'successful']);
  if(hp_column_exists('payments','verified_at')) q('UPDATE payments SET verified_at=NOW() WHERE provider_reference=?',[$ref]);
  invoice_recompute($id);
  audit('invoice_payment','invoice',$id,[],['provider_reference'=>$ref,'amount'=>$rec]);
  invoice_event($id,'note',$rec,'Payment of '.money($rec).' recorded ('.str_replace('_',' ',$method).')');
  $left=invoice_balance($id);
  flash('Payment of '.money($rec).' recorded. '.($left>0?'Balance outstanding: '.money($left).'.':'Invoice fully settled.'));
  go('invoices',['view'=>$id]);
 }
}

/* ---------------- data ---------------- */
$tab=trim((string)($_GET['tab']??'')); $q=trim((string)($_GET['q']??''));
$tabs=['open'=>1,'all'=>1,'draft'=>1,'paid'=>1,'cancelled'=>1];
if(!isset($tabs[$tab])) $tab='open';

$where=['1=1']; $arg=[];
if($q!==''){ $where[]='(inv.invoice_number LIKE ? OR inv.billing_name LIKE ? OR inv.billing_email LIKE ?)'; $arg[]="%$q%"; $arg[]="%$q%"; $arg[]="%$q%"; }
if($tab==='open'){ $where[]="inv.status IN('draft','issued','partially_paid')"; }
elseif($tab==='draft'){ $where[]="inv.status='draft'"; }
elseif($tab==='paid'){ $where[]="inv.status IN('paid','partially_paid')"; }
elseif($tab==='cancelled'){ $where[]="inv.status IN('cancelled','refunded')"; }

$list=rows('SELECT inv.id,inv.invoice_number,inv.status,inv.total,inv.discount,inv.created_at,'
  .'inv.billing_name,inv.billing_email, inv.issued_at,'
  .' (SELECT COALESCE(SUM(p.amount),0) FROM payments p WHERE p.invoice_id=inv.id AND p.status=\'successful\') paid'
  .' FROM invoices inv WHERE '.implode(' AND ',$where).' ORDER BY COALESCE(inv.issued_at,inv.created_at) DESC LIMIT 100',$arg);

$kpis=[
 'issued'=>val("SELECT COUNT(*) FROM invoices WHERE status IN('issued','partially_paid','paid')"),
 'drafts'=>val("SELECT COUNT(*) FROM invoices WHERE status='draft'"),
 'open'=>val("SELECT COUNT(*) FROM invoices WHERE status IN('issued','partially_paid')"),
 'due'=>val("SELECT COALESCE(SUM(total)-COALESCE((SELECT SUM(amount) FROM payments py WHERE py.invoice_id=i.id AND py.status='successful'),0),0) FROM invoices i WHERE i.status IN('issued','partially_paid')"),
 'verifying'=>val("SELECT COUNT(*) FROM payments WHERE invoice_id IS NOT NULL AND status='pending' AND provider='pesapal'"),
];

page_head('Invoices','invoices','Billing, discounts and Pesapal-verified payments');
echo '<div class="kpis">';
kpi_card('Issued',(string)$kpis['issued'],'Issued invoices on record','navy');
kpi_card('Drafts',(string)$kpis['drafts'],'Not yet numbered','gold');
kpi_card('Open balances',(string)$kpis['open'],'Waiting to be settled','blue');
kpi_card('Still owed',money($kpis['due']),'Across issued invoices','red');
kpi_card('Gateway pending',(string)$kpis['verifying'],'Awaiting Pesapal verification','warn');
echo '</div>';

/* ---------------- one invoice ---------------- */
$view=(int)($_GET['view']??0);
if($view>0){
 $inv=row('SELECT * FROM invoices WHERE id=?',[$view]);
 if($inv && ($inv['deleted_at']??null)===null){
  $lines=invoice_lines($view);
  $paid=invoice_settled($view);
  $due=invoice_balance($view);
  $events=rows('SELECT * FROM invoice_events WHERE invoice_id=? ORDER BY id DESC',[$view]);
  $payments=rows("SELECT id,amount,method,status,provider_reference,created_at FROM payments WHERE invoice_id=? ORDER BY id DESC",[$view]);

  echo '<div class="panel"><h2 style="display:inline-block;margin-right:10px">Invoice '.e($inv['invoice_number']?:('draft #'.$inv['id'])).'</h2>'
   .status_badge($inv['status']).' <span class="hint">'.e($inv['billing_name']??'').' &middot; '.e($inv['billing_email']??'').' &middot; '.e($inv['billing_phone']??'').'</span>';

  echo '<div style="margin:14px 0">'.formula_invoice_lines($view,$lines).'</div>';

  if($inv['status']==='draft'){
   echo '<div class="grid2">';
   form_open('invoices','draft',['id'=>$view]);
   field('Billing name','bname',$inv['billing_name']??'','text','',true);
   field('Email','bemail',$inv['billing_email']??'','email');
   field('Phone','bphone',$inv['billing_phone']??'','tel');
   field('Notes','notes',$inv['notes']??'','text','');
   echo '<button class="btn sm blue">Save draft details</button>'; form_close();
   echo '</div>';

   echo '<hr style="border-top:1px solid var(--line);margin:18px 0">';
   echo '<h3 style="margin:0 0 6px">Add a line</h3>';
   form_open('invoices','line',['id'=>$view]);
   field('Description','desc','','text','What is being billed, e.g. "Deluxe room nights".',true);
   echo '<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(130px,1fr));gap:12px">';
   field('Qty','qty','1','number','');
   field('Unit price','unit','','number','');
   field('Tax','tax','0','number','');
   field('Line discount','disc','0','number','');
   echo '</div>';
   echo '<button class="btn sm">Add line</button>'; form_close();
   if(count($lines)>0){
    if(invoice_can_write()){
     form_open('invoices','issue',['id'=>$view]);
     echo '<button class="btn" style="margin-top:14px" onclick="return confirm(\'Issue this invoice now? It will be numbered and open for payment immediately.\')">Issue invoice</button>';
     form_close();
    }else{ echo '<p class="hint" style="margin-top:12px">Only finance desks may issue.</p>'; }
   }
  }else{
   echo '<p class="hint" style="margin:10px 0">'.money($paid).' received'
    .($due>0?' &middot; '.money($due).' outstanding':' &middot; fully settled').'</p>';
   if(in_array($inv['status'],['issued','partially_paid'],true)){
    echo '<div class="grid2">';
    echo '<div class="panel" style="margin:0"><h3>Record a desk payment</h3>';
    if(invoice_can_write()){
     form_open('invoices','payment',['id'=>$view]);
     echo '<div style="display:grid;grid-template-columns:1fr 1fr;gap:12px">';
     field('Amount (max '.money($due).')','amount',(string)max(0,floor($due)),'number','');
     echo '<div class="field"><label for="f_method">Method</label><select id="f_method" name="method">';
     foreach(payment_methods() as $mk=>$ml){ echo '<option value="'.e($mk).'">'.e($ml).'</option>'; }
     echo '</select></div>';
     echo '</div>';
     echo '<button class="btn sm tick">Record received</button>'; form_close();
    }else{ echo '<p class="hint">Only finance desks may record a payment.</p>'; }
    echo '</div>';

    echo '<div class="panel" style="margin:0"><h3>Void this invoice</h3>';
    if(invoice_can_write()){
     form_open('invoices','void',['id'=>$view]);
     field('Reason','reason','','text','Why this invoice can never be paid.',true);
     echo '<button class="btn sm danger" onclick="return confirm(\'Void this invoice? It stays on record but is closed. Money received is a refund decision.\')">Void</button>';
     form_close();
    }else{ echo '<p class="hint">Only finance desks may void.</p>'; }
    echo '</div>';
    echo '</div>';

    echo '<div class="grid2" style="margin-top:20px">';
    echo '<div class="panel" style="margin:0"><h3>Discount</h3>';
    if(invoice_can_write()){
     form_open('invoices','discount',['id'=>$view]);
     field('Amount (UGX)','amount','','number','Invoice-level discount.',true);
     field('Reason','reason','','text','Why the hotel discounts.',true);
     echo '<button class="btn sm">Apply</button>'; form_close();
    }else{ echo '<p class="hint">Only finance desks may discount.</p>'; }
    echo '</div>';
    echo '<div class="panel" style="margin:0"><h3>Adjustment line</h3>';
    if(invoice_can_write()){
     form_open('invoices','adjust',['id'=>$view]);
     field('Delta (± UGX)','delta','','number','Use a minus sign to lower the bill.',true);
     field('Reason','reason','','text','What the adjustment is for.',true);
     echo '<button class="btn sm">Add</button>'; form_close();
    }else{ echo '<p class="hint">Only finance desks may adjust.</p>'; }
    echo '</div>';
    echo '</div>';
   }
  }

  echo '<h3 style="margin:22px 0 6px">Payments</h3>';
  if($payments){
   echo '<table class="tbl"><thead><tr><th>#</th><th class="num">Amount</th><th>Method</th><th>Status</th><th>Reference</th><th>Date</th></tr></thead><tbody>';
   foreach($payments as $p){
    echo '<tr><td>'.e($p['id']).'</td><td class="num">'.money($p['amount']).'</td>'
     .'<td>'.e(str_replace('_',' ',$p['method'])).'</td><td>'.status_badge($p['status']).'</td>'
     .'<td>'.e($p['provider_reference']).'</td><td>'.fmtdt($p['created_at']).'</td></tr>';
   }
   echo '</tbody></table>';
  }else{ echo '<p class="hint">No payments on record yet.</p>'; }

  echo '<h3 style="margin:22px 0 6px">Trail</h3>';
  if($events){
   echo '<table class="tbl"><thead><tr><th>Event</th><th class="num">Amount</th><th>Reason</th><th>Date</th></tr></thead><tbody>';
   foreach($events as $ev){
    echo '<tr><td>'.badge($ev['event'],$ev['event']==='void'?'bad':($ev['event']==='issue'?'ok':($ev['event']==='discount'?'warn':'grey'))).'</td><td class="num">'.money($ev['amount']).'</td>'
     .'<td>'.e($ev['reason']??'').'</td><td>'.fmtdt($ev['created_at']).'</td></tr>';
   }
   echo '</tbody></table>';
  }else{ echo '<p class="hint">Nothing has touched this invoice yet.</p>'; }

  invoice_print($inv,$lines,$paid,$due);
  echo '</div>';
  page_foot(); return;
 }
}

/* ---------------- the list ---------------- */
echo '<div class="toolbar">';
echo '<a class="btn sm" href="'.BASE.'/index.php?page=invoices&tab=all'.($q!==''?'&q='.urlencode($q):'').'">All</a>';
foreach([['open','Open'],['draft','Drafts'],['paid','Paid'],['cancelled','Voided']] as $t){
 echo '<a class="btn sm'.($tab===$t[0]?' blue':'').'" href="'.BASE.'/index.php?page=invoices&tab='.$t[0].($q!==''?'&q='.urlencode($q):'').'">'.$t[1].'</a>';
}
echo '<form method="get" style="margin-left:auto;display:flex;gap:8px"><input type="hidden" name="page" value="invoices"><input type="hidden" name="tab" value="'.e($tab).'">'
 .'<input name="q" value="'.e($q).'" placeholder="Number, name, email" style="padding:8px;border:1px solid var(--line);border-radius:8px">'
 .'<button class="btn sm">Find</button></form>';
echo '</div>';

echo '<div class="panel"><h2>New invoice</h2><p class="hint">A draft is numbered when it is issued. Add the billing details here and it opens ready for lines.</p>';
if(invoice_can_write()){
 form_open('invoices','draft');
 field('Billing name','bname','','text','Who the bill is addressed to.',true);
 echo '<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:16px">';
 field('Email','bemail','','email','For the emailed copy.');
 field('Phone','bphone','','tel','To confirm the payment on.');
 echo '</div>';
 field('Notes','notes','','text','Anything worth remembering about the stay.');
 echo '<button class="btn sm blue">Start draft</button>'; form_close();
}else{ echo '<p class="hint">Only finance desks may draft an invoice.</p>'; }
echo '</div>';

if(!$list){ echo empty_state('No invoices here yet','Issue a draft to open the billing desk.'); }
else{
 echo '<div class="panel"><table class="tbl"><thead><tr><th>Number</th><th>Billed to</th><th class="num">Total</th><th class="num">Received</th><th class="num">Due</th><th>Status</th><th>Issued</th></tr></thead><tbody>';
 foreach($list as $inv){
  $due=max(0,(float)$inv['total']-(float)($inv['paid']??0));
  echo '<tr><td><a href="'.BASE.'/index.php?page=invoices&view='.(int)$inv['id'].'">'.e($inv['invoice_number']?:('draft #'.$inv['id'])).'</a></td>'
   .'<td>'.e($inv['billing_name']?:'-').'</td><td class="num">'.money($inv['total']).'</td>'
   .'<td class="num">'.money($inv['paid']??0).'</td><td class="num">'.money($due).'</td>'
   .'<td>'.status_badge($inv['status']).'</td><td>'.fmtdt($inv['issued_at']).'</td></tr>';
 }
 echo '</tbody></table></div>';
}
page_foot();