<?php
declare(strict_types=1);

/**
 * Receipts, the hotel's own.
 *
 * One place turns a settled payment into the two things that follow it:
 *
 *   1. an email to the guest, with the same itemised receipt the front desk
 *      would hand over, and
 *   2. a "hotel copy" sheet for the console that prints itself the moment the
 *      money is recorded.
 *
 * Three rules shape everything here, and they are the whole point of the file:
 *
 *   Nothing without a payment. Every entry point reads the payment row first
 *   and refuses unless its status is exactly "successful". A pending request,
 *   a failed attempt and a reversed payment produce no email and no paper. A
 *   receipt is proof of money received, and it is never written before the
 *   money is.
 *
 *   One payment, one email. receipt_deliveries has a UNIQUE (payment_id,
 *   channel), so a double submit, a page refresh or a retry can never send the
 *   same receipt twice. The send is recorded the moment it is attempted, so a
 *   send that fails is not silently retried into a second copy.
 *
 *   The books always win. Every call is wrapped: a mail server that is down or
 *   a database that has not been upgraded leaves a line in the error log and
 *   nothing else. A payment is never failed because its receipt could not
 *   leave.
 *
 * The addresses come from the hotel's own records, in the order a guest would
 * expect: the profile on the order or booking first, then the account the
 * payment was made from, then the guest record. Nothing is guessed from a
 * request body, so a receipt can only go to an address the hotel already holds.
 */

require_once __DIR__.'/bootstrap.php';
require_once __DIR__.'/mailer.php';

/** The name a payment method is shown by, in words, on a receipt. */
function receipt_method_label(string $method): string
{
 $map=[
  'cash'=>'Cash','mtn_momo'=>'MTN Mobile Money','airtel_money'=>'Airtel Money',
  'card'=>'Card','bank'=>'Bank transfer','bank_transfer'=>'Bank transfer',
  'mobile_money'=>'Mobile money','pesapal'=>'Pesapal','other'=>'Other',
 ];
 $m=strtolower(trim($method));
 return $map[$m]??ucfirst(str_replace('_',' ',$m));
}

/**
 * Whether the delivery log exists, creating it if it does not.
 *
 * A fresh install runs the main SQL, which already carries this table; an
 * installation that predates it gets the table made here, once, so a receipt is
 * never lost to a migration that was not run. Nothing about the install is
 * changed beyond adding the one table this file owns.
 */
function receipts_ready(): bool
{
 static $ready=null;
 if($ready!==null) return $ready;
 try{
  $have=(int)val('SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?',['receipt_deliveries']);
  if($have===0){
   q("CREATE TABLE IF NOT EXISTS receipt_deliveries (
     id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
     payment_id BIGINT UNSIGNED NOT NULL,
     hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
     source VARCHAR(20) NOT NULL DEFAULT '',
     reference VARCHAR(120) NOT NULL DEFAULT '',
     channel ENUM('email','print') NOT NULL DEFAULT 'email',
     recipient VARCHAR(190) NOT NULL DEFAULT '',
     status ENUM('sent','failed') NOT NULL DEFAULT 'failed',
     attempts INT UNSIGNED NOT NULL DEFAULT 0,
     last_error VARCHAR(500) DEFAULT NULL,
     provider_message_id VARCHAR(190) DEFAULT NULL,
     created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
     updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
     PRIMARY KEY (id),
     UNIQUE KEY uq_receipt_payment_channel (payment_id, channel),
     KEY idx_receipt_source (source)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
  }
  return $ready=true;
 }catch(\Throwable $e){
  error_log('[hotel receipts] delivery log unavailable: '.$e->getMessage());
  return $ready=false;
 }
}

/** Whether this payment has already had a receipt sent to the guest. */
function receipt_email_already_sent(int $paymentId): bool
{
 if(!receipts_ready()) return false;
 try{
  return (int)val("SELECT COUNT(*) FROM receipt_deliveries WHERE payment_id=? AND channel='email' AND status='sent'",[$paymentId])>0;
 }catch(\Throwable $e){ return false; }
}

/**
 * Reads a settled payment back into everything a receipt needs, or nothing.
 *
 * This is the gate the rest of the file stands behind: unless the row exists
 * and its status is exactly "successful", null comes back and no email or paper
 * is ever produced.
 */
function receipts_context(int $paymentId): ?array
{
 if($paymentId<=0) return null;
 $p=row('SELECT * FROM payments WHERE id=?',[$paymentId]);
 if(!$p) return null;
 if(strtolower(trim((string)($p['status']??'')))!=='successful') return null;

 $ctx=[
  'payment_id'=>(int)$p['id'],
  'amount'=>(float)$p['amount'],
  'method'=>(string)$p['method'],
  'method_label'=>receipt_method_label((string)$p['method']),
  'paid_at'=>(string)($p['created_at']??date('Y-m-d H:i:s')),
  'reference'=>trim((string)($p['provider_reference']??'')),
  'kind'=>'',
  'ref'=>'',
  'guest'=>['name'=>'','phone'=>'','email'=>''],
  'lines'=>[],
  'meta'=>[],
  'totals'=>['subtotal'=>null,'tax'=>0.0,'discount'=>0.0,'total'=>0.0,'paid'=>0.0,'balance'=>0.0],
 ];

 // The account the payment was made from, when the guest was signed in. It is
 // the last resort for an email and the first place a name is found.
 $customer=null;
 if(!empty($p['customer_id'])){
  try{ $customer=row('SELECT full_name,email,phone FROM customers WHERE id=?',[(int)$p['customer_id']]); }catch(\Throwable $e){ $customer=null; }
 }

 try{
  if(!empty($p['order_id'])){
   $o=row('SELECT * FROM orders WHERE id=?',[(int)$p['order_id']]);
   if(!$o) return null;
   $ctx['kind']='order';
   $ctx['ref']=(string)$o['order_number'];

   $rows=rows('SELECT oi.quantity,oi.unit_price,oi.total,oi.notes,mi.name'
    .' FROM order_items oi LEFT JOIN menu_items mi ON mi.id=oi.menu_item_id'
    .' WHERE oi.order_id=? ORDER BY oi.id',[(int)$p['order_id']]);
   foreach($rows as $l){
    $note=receipt_clean_note((string)($l['notes']??''));
    $qty=(float)$l['quantity'];
    $ctx['lines'][]=[
     'name'=>(string)($l['name']??'Item'),
     'qty'=>rtrim(rtrim(number_format($qty,2,'.',''),'0'),'.'),
     'unit'=>(float)$l['unit_price'],
     'total'=>(float)$l['total'],
     'note'=>$note,
    ];
   }

   $name=(string)($o['customer_name']??'');
   if($name===''){ $name=trim((string)($customer['full_name']??'')); }
   $phone=(string)($o['customer_phone']??'');
   if($phone===''){ $phone=(string)($customer['phone']??''); }
   $email=(string)($o['customer_email']??'');
   if($email===''){ $email=(string)($customer['email']??''); }
   $ctx['guest']=['name'=>$name,'phone'=>$phone,'email'=>receipt_valid_email($email)];

   $ctx['totals']['subtotal']=(float)$o['subtotal'];
   $ctx['totals']['tax']=(float)$o['tax'];
   $ctx['totals']['discount']=(float)$o['discount'];
   $ctx['totals']['total']=(float)$o['total'];
   $ctx['meta']=[
    'Outlet'=>ucfirst((string)$o['outlet']),
    'Service'=>$o['order_type']==='room'?'Room service':ucfirst((string)$o['order_type']),
    'Placed'=>fmtdt($o['created_at']??null),
   ];
   if(!empty($o['table_name'])) $ctx['meta']['Table or room']=(string)$o['table_name'];
   if(!empty($o['delivery_address'])) $ctx['meta']['Deliver to']=(string)$o['delivery_address'];

  }elseif(!empty($p['reservation_id'])){
   $r=row('SELECT r.*,g.full_name,g.phone,g.email FROM reservations r JOIN guests g ON g.id=r.guest_id WHERE r.id=?',[(int)$p['reservation_id']]);
   if(!$r) return null;
   $ctx['kind']='booking';
   $ctx['ref']=(string)$r['booking_number'];

   $rooms=rows('SELECT COALESCE(rt.name,\'Room\') AS name,COALESCE(SUM(rr.quantity),1) AS qty'
    .' FROM reservation_rooms rr LEFT JOIN room_types rt ON rt.id=rr.room_type_id'
    .' WHERE rr.reservation_id=? GROUP BY COALESCE(rt.name,\'Room\') ORDER BY MIN(rr.id)',[(int)$p['reservation_id']]);
   foreach($rooms as $rm){
    $qty=(int)$rm['qty'];
    $ctx['lines'][]=['name'=>trim((string)$rm['name']).($qty>1?' × '.$qty:''),
     'qty'=>'', 'unit'=>null, 'total'=>null, 'note'=>''];
   }
   // The room line carries no price of its own on the receipt; the money is
   // shown once, in the totals, exactly as the guest read it at booking.

   $name=(string)$r['full_name'];
   if($name===''){ $name=(string)($customer['full_name']??''); }
   $email=(string)($r['email']??'');
   if($email===''){ $email=(string)($customer['email']??''); }
   $ctx['guest']=['name'=>$name,'phone'=>(string)$r['phone'],'email'=>receipt_valid_email($email)];

   $ctx['totals']['subtotal']=(float)$r['subtotal'];
   $ctx['totals']['tax']=(float)($r['tax']??0);
   $ctx['totals']['total']=(float)$r['total'];
   $ctx['meta']=[
    'Room'=>$ctx['lines'][0]['name']??'Room',
    'Check in'=>fmtdt($r['check_in']??null),
    'Check out'=>fmtdt($r['check_out']??null),
    'Nights'=>(int)($r['nights']??1),
    'Guests'=>(int)($r['adults']??1).' adult(s)'.((int)($r['children']??0)?', '.(int)$r['children'].' child(ren)':''),
   ];

  }else{
   // A payment that belongs to neither an order nor a booking has no receipt
   // shape the hotel publishes, so it is left alone.
   return null;
  }
 }catch(\Throwable $e){
  error_log('[hotel receipts] could not read payment '.$paymentId.': '.$e->getMessage());
  return null;
 }

 // What has really settled against this reference, so the balance is honest.
 $sql=$ctx['kind']==='order'
  ?'SELECT COALESCE(SUM(amount),0) FROM payments WHERE order_id=? AND status=\'successful\''
  :'SELECT COALESCE(SUM(amount),0) FROM payments WHERE reservation_id=? AND status=\'successful\'';
 $paid=(float)val($sql,[(int)$p['order_id']?: (int)$p['reservation_id']]);
 $ctx['totals']['paid']=round($paid,2);
 $ctx['totals']['balance']=round(max(0.0,$ctx['totals']['total']-$paid),2);

 return $ctx;
}

/** The name and phone a web order's note carries, when the columns are blank. */
function receipt_clean_note(string $note): string
{
 $note=trim($note);
 if($note==='') return '';
 if(strpos($note,'Web takeaway order from ')!==0) return $note;
 $rest=substr($note,strlen('Web takeaway order from '));
 $parts=preg_split('/\s+-\s+/',$rest,2);
 return isset($parts[1])?trim($parts[1],". \t\n\r"):'';
}

/** Keeps only an address the hotel can actually send to. */
function receipt_valid_email(string $email): string
{
 $email=trim($email);
 return filter_var($email,FILTER_VALIDATE_EMAIL)?$email:'';
}

/**
 * Sends the guest their receipt, at most once per payment.
 *
 * @return array{sent:bool,to:string,error:?string,skipped:bool}
 */
function receipts_send_email(array $ctx): array
{
 $out=['sent'=>false,'to'=>'','error'=>null,'skipped'=>false];
 $pid=(int)$ctx['payment_id'];
 $to=(string)($ctx['guest']['email']??'');

 if(receipt_email_already_sent($pid)){ $out['skipped']=true; return $out; }
 if($to===''){
  // Nothing to send to is not a failure worth a receipt entry: the sheet still
  // prints, and a later payment on the same booking can carry the address.
  $out['error']='No email address is on file for this guest.';
  return $out;
 }
 $out['to']=$to;

 $subject=($ctx['kind']==='booking'?'Your booking receipt ':'Your order receipt ').$ctx['ref'];
 $html=receipts_email_html($ctx);
 $text=receipts_email_text($ctx);

 $res=mail_send($to,$subject,$html,$text);
 $out['sent']=(bool)$res['ok'];
 $out['error']=$res['ok']?null:($res['error']??'The message could not be sent.');
 receipt_log($pid,$ctx,$to,$res['ok'],$out['error']);
 return $out;
}

/** Records the attempt, so a second attempt is refused and the books can see it. */
function receipt_log(int $paymentId,array $ctx,string $recipient,bool $ok,?string $error): void
{
 if(!receipts_ready()) return;
 try{
  q('INSERT INTO receipt_deliveries(payment_id,hotel_id,source,reference,channel,recipient,status,attempts,last_error,created_at)'
    ." VALUES(?,1,?,?,'email',?,?,1,?,NOW())"
    .' ON DUPLICATE KEY UPDATE status=VALUES(status),attempts=attempts+1,last_error=VALUES(last_error),recipient=VALUES(recipient),updated_at=NOW()',
   [$paymentId,(string)$ctx['kind'],(string)$ctx['ref'],$recipient,$ok?'sent':'failed',$error]);
 }catch(\Throwable $e){
  error_log('[hotel receipts] could not log delivery for payment '.$paymentId.': '.$e->getMessage());
 }
}

/**
 * The one call a module makes after recording a payment.
 *
 * It confirms the money is really in before doing anything, sends the guest
 * their copy once, and hands back the context so the caller can print the hotel
 * copy on the same screen. On any other kind of payment it returns null and
 * nothing at all happens.
 */
function receipts_after_payment(int $paymentId): ?array
{
 try{
  $ctx=receipts_context($paymentId);
  if($ctx===null) return null;
  $send=receipts_send_email($ctx);
  $ctx['email_sent']=$send['sent'];
  $ctx['email_to']=$send['to']!==''?$send['to']:(string)($ctx['guest']['email']??'');
  $ctx['email_error']=$send['error'];
  $ctx['email_skipped']=$send['skipped'];
  return $ctx;
 }catch(\Throwable $e){
  error_log('[hotel receipts] payment '.$paymentId.' receipt skipped: '.$e->getMessage());
  return null;
 }
}

/* ==================================================================
   THE HOTEL COPY

   The console prints its own copy of the same receipt the guest is
   emailed, so the front desk has the money on paper the moment it is
   taken. These two functions build that sheet; a module hands the paper
   to receipt_template() and lets receipt_print() put it on the printer.
   ================================================================== */

/** The receipt_sheet() argument for a settled payment's hotel copy. */
function receipts_paper(array $ctx): array
{
 $meta=[];
 $meta[$ctx['kind']==='booking'?'Booking':'Order']=$ctx['ref'];
 foreach($ctx['meta'] as $k=>$v){ if($v!==''&&$v!==null) $meta[$k]=$v; }
 if(($ctx['guest']['name']??'')!=='') $meta['Guest']=$ctx['guest']['name'];
 if(($ctx['guest']['phone']??'')!=='') $meta['Phone']=$ctx['guest']['phone'];
 if(($ctx['guest']['email']??'')!=='') $meta['Email']=$ctx['guest']['email'];
 $meta['Paid by']=$ctx['method_label'];
 if(($ctx['reference']??'')!=='') $meta['Payment ref']=$ctx['reference'];
 $meta['Received']=fmtdt($ctx['paid_at']);

 $lines=[];
 foreach($ctx['lines'] as $l){
  $lines[]=['name'=>$l['name'],'qty'=>$l['qty'],'note'=>$l['note'],
   'amount'=>$l['total']!==null?money($l['total']):null];
 }

 $t=[];
 if($ctx['totals']['subtotal']!==null) $t[]=['Subtotal',money($ctx['totals']['subtotal'])];
 if(($ctx['totals']['tax']??0)>0) $t[]=['Service charge (3.5%)',money($ctx['totals']['tax'])];
 if(($ctx['totals']['discount']??0)>0) $t[]=['Discount','-'.money($ctx['totals']['discount'])];
 $t[]=['Total',money($ctx['totals']['total'])];
 $t[]=['Payment received',money($ctx['amount']),'big'];
 $t[]=['Total paid to date',money($ctx['totals']['paid'])];
 $t[]=['Balance due',money($ctx['totals']['balance'])];

 $foot='HOTEL COPY &middot; '.$ctx['method_label'].' payment of '.money($ctx['amount']).' received. '
  .($ctx['guest']['email']!==''?'Receipt emailed to '.$ctx['guest']['email'].'.':'No email on file for this guest.');

 return ['kind'=>'RECEIPT (HOTEL COPY)','number'=>$ctx['ref'],'meta'=>$meta,'lines'=>$lines,'totals'=>$t,'foot'=>$foot];
}

/**
 * Emits a fresh hotel copy for the console to print, if and only if the payment
 * settled. A module calls this on the page it redirects to after recording the
 * money; a payment that never happened produces no template and no printing.
 */
function receipts_hotel_template(int $paymentId,bool $fresh=true): void
{
 if(!function_exists('receipt_sheet')) return;
 try{
  $ctx=receipts_context($paymentId);
  if($ctx===null) return;
  receipt_template('pay-'.(int)$paymentId,receipt_sheet(receipts_paper($ctx)),$fresh);
 }catch(\Throwable $e){
  error_log('[hotel receipts] hotel copy for payment '.$paymentId.' skipped: '.$e->getMessage());
 }
}

/* ==================================================================
   THE GUEST'S EMAIL
   ================================================================== */

/** The itemised HTML the guest receives, built from the same context. */
function receipts_email_html(array $ctx): string
{
 $g=$ctx['guest'];
 $greeting=trim((string)$g['name'])!==''?trim((string)$g['name']):'Guest';
 $first=preg_split('/\s+/',trim($greeting))[0]?:'Guest';

 $rows='';
 foreach($ctx['lines'] as $l){
  $rows.='<tr>'
   .'<td style="padding:9px 0;border-bottom:1px solid #eef1f6;color:#1E2A3A;font-size:14px">'.e($l['name'])
    .($l['qty']!==''&&$l['qty']!==null?' <span style="color:#7b8798">× '.e($l['qty']).'</span>':'')
    .(!empty($l['note'])?'<br><span style="color:#7b8798;font-size:12px">'.e($l['note']).'</span>':'')
   .'</td>'
   .'<td style="padding:9px 0;border-bottom:1px solid #eef1f6;color:#1E2A3A;font-size:14px;text-align:right;white-space:nowrap">'
    .($l['total']!==null?e(money($l['total'])):'&nbsp;')
   .'</td></tr>';
 }

 $moneyRow=function(string $label,string $value,bool $strong=false,bool $minus=false) : string {
  return '<tr><td style="padding:4px 0;color:'.($strong?'#071A33':'#5b6878').';font-size:'.($strong?'15px':'13.5px').';'.($strong?'font-weight:bold':'').'">'.e($label).'</td>'
   .'<td style="padding:4px 0;text-align:right;color:'.($strong?'#071A33':'#5b6878').';font-size:'.($strong?'15px':'13.5px').';'.($strong?'font-weight:bold':'').'">'
   .($minus?'&minus;':'').e($value).'</td></tr>';
 };

 $totals='';
 if($ctx['totals']['subtotal']!==null) $totals.=$moneyRow('Subtotal',money($ctx['totals']['subtotal']));
 if(($ctx['totals']['tax']??0)>0) $totals.=$moneyRow('Service charge (3.5%)',money($ctx['totals']['tax']));
 if(($ctx['totals']['discount']??0)>0) $totals.=$moneyRow('Discount','-'.money($ctx['totals']['discount']));
 $totals.=$moneyRow('Total',money($ctx['totals']['total']),true);

 $paidRow='<tr><td colspan="2" style="padding:14px 0 4px">'
  .'<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f6f8fb;border:1px solid #e6e9ef;border-radius:10px">'
  .'<tr><td style="padding:14px 16px;font-family:Arial,Helvetica,sans-serif">'
  .'<div style="color:#2e7d32;font-size:15px;font-weight:bold">Payment received &middot; '.e(money($ctx['amount'])).'</div>'
  .'<div style="color:#5b6878;font-size:12.5px;margin-top:4px">'.e($ctx['method_label'])
   .' &middot; '.e(fmtdt($ctx['paid_at'])).(($ctx['reference']??'')!==''?' &middot; Ref '.e($ctx['reference']):'').'</div>'
  .'</td></tr></table></td></tr>';

 $metaRow=function(string $label,string $value): string {
  return '<tr><td style="padding:3px 0;color:#7b8798;font-size:13px">'.e($label).'</td>'
   .'<td style="padding:3px 0;color:#1E2A3A;font-size:13px;text-align:right;font-weight:600">'.e($value).'</td></tr>';
 };
 $meta='';
 foreach($ctx['meta'] as $k=>$v){ if($v!==''&&$v!==null) $meta.=$metaRow((string)$k,(string)$v); }
 $meta.=$metaRow('Receipt number',(string)$ctx['ref']);

 $balance=(float)$ctx['totals']['balance'];
 $balanceLine=$balance>0.001
  ?'<tr><td style="padding:6px 0 0;color:#b26a00;font-size:13.5px;font-weight:bold">Balance still due</td>'
   .'<td style="padding:6px 0 0;text-align:right;color:#b26a00;font-size:13.5px;font-weight:bold">'.e(money($balance)).'</td></tr>'
  :'<tr><td colspan="2" style="padding:8px 0 0;color:#2e7d32;font-size:13.5px;font-weight:bold">Paid in full. Thank you.</td></tr>';

 $body='<p style="margin:0 0 8px;font-size:17px;color:#071A33"><b>Thank you, '.e($first).'.</b></p>'
  .'<p style="margin:0 0 18px;color:#5b6878">Your payment has been received and this is your official receipt.'
  .' We are delighted to have you with us.</p>'
  .'<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:0 0 18px">'.$meta.'</table>'
  .($rows!==''?'<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:0 0 6px">'.$rows.'</table>':'')
  .'<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:6px 0 0">'.$totals.'</table>'
  .'<table role="presentation" width="100%" cellpadding="0" cellspacing="0">'.$paidRow.'</table>'
  .'<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="margin:6px 0 0">'.$balanceLine.'</table>'
  .'<p style="margin:22px 0 0;color:#5b6878;font-size:13px;line-height:1.6">With every good wish,<br>'
  .'<b style="color:#071A33">The Front Desk</b><br>'.e(MAIL_HOTEL_NAME).'</p>';

 return mail_html('Receipt '.$ctx['ref'].' · '.MAIL_HOTEL_NAME,$body,'Your receipt for '.$ctx['ref'].' from '.MAIL_HOTEL_NAME.'.');
}

/** The plain-text twin of the receipt, for a client that shows no HTML. */
function receipts_email_text(array $ctx): string
{
 $L=[];
 $L[]=MAIL_HOTEL_NAME;
 $L[]=MAIL_HOTEL_CITY.' · '.MAIL_HOTEL_PHONE;
 $L[]=str_repeat('=',42);
 $L[]='OFFICIAL RECEIPT';
 $L[]='Receipt number: '.$ctx['ref'];
 $L[]='Guest: '.($ctx['guest']['name']!==''?$ctx['guest']['name']:'Guest');
 foreach($ctx['meta'] as $k=>$v){ if($v!==''&&$v!==null) $L[]=$k.': '.$v; }
 $L[]='';
 if($ctx['lines']){
  $L[]='ITEMS';
  foreach($ctx['lines'] as $l){
   $L[]='- '.$l['name'].($l['qty']!==''&&$l['qty']!==null?' x '.$l['qty']:'')
     .($l['total']!==null?'  '.money($l['total']):'').($l['note']!==''?'  ('.$l['note'].')':'');
  }
  $L[]='';
 }
 if($ctx['totals']['subtotal']!==null) $L[]='Subtotal: '.money($ctx['totals']['subtotal']);
 if(($ctx['totals']['tax']??0)>0) $L[]='Service charge (3.5%): '.money($ctx['totals']['tax']);
 if(($ctx['totals']['discount']??0)>0) $L[]='Discount: -'.money($ctx['totals']['discount']);
 $L[]='Total: '.money($ctx['totals']['total']);
 $L[]='';
 $L[]='PAYMENT RECEIVED: '.money($ctx['amount']);
 $L[]='Method: '.$ctx['method_label'];
 $L[]='Received: '.fmtdt($ctx['paid_at']);
 if(($ctx['reference']??'')!=='') $L[]='Reference: '.$ctx['reference'];
 $L[]='Total paid to date: '.money($ctx['totals']['paid']);
 if((float)$ctx['totals']['balance']>0.001){
  $L[]='Balance still due: '.money($ctx['totals']['balance']);
 }else{
  $L[]='Paid in full. Thank you.';
 }
 $L[]='';
 $L[]='Thank you for choosing '.MAIL_HOTEL_NAME.'.';
 $L[]='This is your official receipt.';
 return implode("\n",$L);
}
