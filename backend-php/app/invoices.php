<?php
declare(strict_types=1);

/* =====================================================================
   INVOICES — the engine behind the hotel's invoicing and Pesapal module
   =====================================================================
   One file owns the rules every screen agrees on:

     - totals are always recomputed on the server from the invoice's own
       lines, never taken from the browser or memorised on the record;
     - a payment is never "successful" until the server has verified it
       with the gateway (idempotent checkout token, verification stamp);
     - every issue / void / discount / adjust is written to invoice_events
       by the user who did it, before the page that shows it is drawn;
     - the SQL upgrade in database/sql/patches/2026-10-17_invoice_module.sql
       may or may not have run yet, so every column read here is guarded the same way
       the rest of the console guards upgrades: missing means "absent",
       never a stack trace.

   Nothing here renders a page. The console module and the API call these
   helpers and paint their own screens.
   ===================================================================== */

if(!function_exists('invoice_columns')){
 function invoice_columns(): array{
  static $cols=[];
  if($cols!==[]) return $cols;
  $inv  =['billing_name'=>'','billing_email'=>'','billing_phone'=>'','due_date'=>'','issued_at'=>'',
         'issued_by'=>'','discount'=>'','currency'=>'','notes'=>'','updated_at'=>'','deleted_at'=>'','deleted_by'=>''];
  $pay  =['checkout_token'=>'','verified_at'=>'','gateway_result'=>'','payer_phone'=>''];
  $it   =['item_no'=>''];
  foreach(array_keys($inv) as $c){ if(hp_column_exists('invoices',$c)) $inv[$c]=$c; }
  foreach(array_keys($pay) as $c){ if(hp_column_exists('payments',$c)) $pay[$c]=$c; }
  foreach(array_keys($it)  as $c){ if(hp_column_exists('invoice_items',$c)) $it[$c]=$c; }
  return $cols=['invoice'=>$inv,'payment'=>$pay,'item'=>$it];
 }
}

/** The columns of a table this module may safely select, joined with commas. */
function invoice_cols(string $table,array $wanted): array{
  $map=invoice_columns();
  $src=$map[$table]??[];
  return array_values(array_filter($src,fn($c)=>$c!==''&&in_array($c,$wanted,true)));
}

/** Is the invoicing upgrade in place (invoices + its events table)? */
function invoice_ready(): bool{
  return hp_table_exists('invoices')
    && hp_table_exists('invoice_items')
    && hp_table_exists('payments')
    && hp_table_exists('invoice_events');
}

/** One event on the invoice's own trail. Written before the page shows. */
function invoice_event(int $id,string $event,float $amount=0.0,?string $reason=null,$from=null,$to=null): void{
  if(!invoice_ready()) return;
  if(!in_array($event,['issue','void','discount','adjust','note'],true)) return;
  $u=current_user();
  $snap=function($x): ?string{
    if($x===null) return null;
    $s=is_array($x)?json_encode($x,JSON_UNESCAPED_UNICODE):(string)$x;
    return substr($s,0,200);
  };
  q('INSERT INTO invoice_events(invoice_id,event,amount,reason,applier,from_value,to_value,created_at)
     VALUES(?,?,?,?,?,?,?,NOW())',
   [$id,$event,$amount,$reason!==null&&$reason!==''?$reason:null,$u['id']??null,
    $snap($from),$snap($to)]);
}

/** Recompute subtotal / tax / discount / total for an invoice from its own
 *  lines, then write the settled status. The server's numbers are the only
 *  numbers, so a discount or an adjusted line lands immediately and stays. */
function invoice_recompute(int $id): void{
  $disc=(float)val('SELECT COALESCE(discount,0) FROM invoices WHERE id=?',[$id]);
  $sub=(float)val('SELECT COALESCE(SUM(total),0) FROM invoice_items WHERE invoice_id=?',[$id]);
  $tax=(float)val('SELECT COALESCE(SUM(tax),0) FROM invoice_items WHERE invoice_id=?',[$id]);
  $total=max(0.0,round($sub+$tax-$disc,2));
  q('UPDATE invoices SET subtotal=?, tax=?, total=?, updated_at=NOW() WHERE id=?',[$sub,$tax,$total,$id]);
  invoice_set_status($id);
}

/** The amount of one line, computed once. A discount on a line makes the line
 *  cheaper; the invoice-level discount then sits in invoices.discount. */
function invoice_line_total(float $qty,float $unit,float $tax,float $disc): float{
  $gross=$qty*$unit;
  return round(max(0.0,$gross-$disc)+round($tax,2),2);
}

/** How much of an invoice the bank has really seen: successful payments only. */
function invoice_settled(int $id): float{
  return (float)val("SELECT COALESCE(SUM(amount),0) FROM payments
     WHERE invoice_id=? AND status='successful'",[$id]);
}

/** What the guest still owes, never the memo on the record. */
function invoice_balance(int $id): float{
  $r=row('SELECT total FROM invoices WHERE id=?',[$id]);
  if(!$r) return 0.0;
  return round(max(0.0,(float)$r['total']-invoice_settled($id)),2);
}

/** Bring the invoice's status in line with the money it has actually seen.
 *  draft stays draft until issued; a cancelled invoice never unpublishes. */
function invoice_set_status(int $id): void{
  $inv=row('SELECT status,issued_at,total FROM invoices WHERE id=?',[$id]);
  if(!$inv) return;
  if(in_array($inv['status'],['cancelled','refunded'],true)) return;
  $due=round((float)$inv['total']-invoice_settled($id),2);
  if($inv['issued_at']===null||$inv['issued_at']===''){
    if($due>=(float)$inv['total'] && $inv['total']>0) q('UPDATE invoices SET status=\'draft\' WHERE id=?',[$id]);
    return;
  }
  if($due<=0.0)      $next='paid';
  elseif(invoice_settled($id)>0.0) $next='partially_paid';
  else               $next='issued';
  q('UPDATE invoices SET status=? WHERE id=? AND status NOT IN(\'cancelled\',\'refunded\')',[$next,$id]);
}

/** Issue a draft: number it, stamp who and when, open it to payment, and
 *  normalise the balance on the way. Returns the invoice number. */
function invoice_issue(int $id): string{
  $inv=row('SELECT * FROM invoices WHERE id=?',[$id]);
  if(!$inv) return '';
  if(($inv['status']??'draft')!=='draft') return (string)$inv['invoice_number'];
  $num=next_number('INV','invoices','invoice_number');
  $u=current_user();
  // The SET fragment and its values are built together, in the same order, so
  // the placeholders can never drift away from the arguments (a mismatch here
  // once put a user id where the invoice number belonged).
  $set=['status=\'issued\'','invoice_number=?'];
  $arg=[$num];
  if(hp_column_exists('invoices','issued_at')){ $set[]='issued_at=NOW()'; }
  if(hp_column_exists('invoices','issued_by')){ $set[]='issued_by=?'; $arg[]=$u['id']??null; }
  $arg[]=$id;
  q('UPDATE invoices SET '.implode(',',$set).' WHERE id=?',$arg);
  invoice_period_defaults($id);
  invoice_recompute($id);
  invoice_event($id,'issue',0.0,'Invoice issued');
  audit('invoice_issue','invoice',$id,['status'=>'draft'],['status'=>'issued','number'=>$num]);
  return $num;
}

/** A due date if the schema carries one and the draft did not set its own. */
function invoice_period_defaults(int $id): void{
  $cols=invoice_columns();
  if($cols['invoice']['due_date']==='') return;
  $r=row('SELECT due_date FROM invoices WHERE id=?',[$id]);
  if($r && ($r['due_date']??'')==='') q('UPDATE invoices SET due_date=DATE_ADD(CURDATE(),INTERVAL 7 DAY) WHERE id=?',[$id]);
}

/** Void an issued invoice: it stays on the record, numbered and dated, but the
 *  balance is closed and it can no longer be paid. */
function invoice_void(int $id,string $reason): void{
  $inv=row('SELECT * FROM invoices WHERE id=?',[$id]);
  if(!$inv||in_array($inv['status'],['cancelled','refunded'],true)) return;
  $before=['status'=>$inv['status'],'total'=>(float)$inv['total']];
  // A void closes the bill; it is not the Trash. deleted_* is left alone.
  q('UPDATE invoices SET status=\'cancelled\', updated_at=NOW() WHERE id=?',[$id]);
  // money already seen is never un-seen: it is a refund decision, not a void.
  invoice_event($id,'void',0.0,$reason,$before,['status'=>'cancelled']);
  audit('invoice_void','invoice',$id,$before,['status'=>'cancelled','reason'=>$reason]);
}

/** Apply (or reverse) an invoice-level discount with a reason. */
function invoice_discount(int $id,float $amount,string $reason): void{
  $before=(float)val('SELECT COALESCE(discount,0) FROM invoices WHERE id=?',[$id]);
  $amount=round(max(0.0,$amount),2);
  q('UPDATE invoices SET discount=?, updated_at=NOW() WHERE id=?',[$amount,$id]);
  invoice_recompute($id);
  invoice_event($id,'discount',$amount,$reason,$before,$amount);
  audit('invoice_discount','invoice',$id,['discount'=>$before],['discount'=>$amount,'reason'=>$reason]);
}

/** A manual adjustment line (can lower as well as raise the bill). */
function invoice_adjust(int $id,float $delta,string $reason): void{
  $delta=round($delta,2);
  $n=(int)val('SELECT COALESCE(MAX(item_no),0)+1 FROM invoice_items WHERE invoice_id=?',[$id]);
  q('INSERT INTO invoice_items(invoice_id,item_no,description,quantity,unit_price,tax,discount,total)
     VALUES(?,?,?,1,?,0,0,?)',[$id,$n,$reason!==''?$reason:'Adjustment',$delta,$delta]);
  invoice_recompute($id);
  invoice_event($id,'adjust',$delta,$reason);
  audit('invoice_adjust','invoice',$id,['line'=>$n],['delta'=>$delta,'reason'=>$reason]);
}

/** The line items of an invoice, in printed order, with any invoice-level
 *  discount already deducted on the final line. */
function invoice_lines(int $id): array{
  $lines=rows('SELECT * FROM invoice_items WHERE invoice_id=? ORDER BY item_no,id',[$id]);
  $disc=(float)val('SELECT COALESCE(discount,0) FROM invoices WHERE id=?',[$id]);
  if($disc>0.0){
    $n=(int)val('SELECT COALESCE(MAX(item_no),0)+1 FROM invoice_items WHERE invoice_id=?',[$id]);
    $lines[]=['id'=>0,'item_no'=>$n,'description'=>'Discount',
      'quantity'=>1,'unit_price'=>-$disc,'tax'=>0.0,'discount'=>0.0,'total'=>-$disc];
  }
  return $lines;
}

/** Whether a console user may manage invoices at all. */
function invoice_can(): bool{
  return page_allowed('invoices');
}

/** Whether a console user may write to an invoice (issue/void/discount/adjust).
 *  Read-anyone, write only the desks management trusts. */
function invoice_can_write(): bool{
  return invoice_can() && (bool)array_intersect(roles_of(),['director','general_manager','super_admin','accountant','cashier']);
}