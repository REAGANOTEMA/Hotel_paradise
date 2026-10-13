<?php
declare(strict_types=1);

/**
 * Stock requisitions, the "inventory request" the departments raise.
 *
 * A department asks the store for what it needs. The request lands with the
 * store manager at once, and the Director is alerted with the full list and the
 * money it comes to, so the decision can be made from the one screen she reads.
 * Nothing here touches the database directly except through the shared helpers,
 * and every ring goes through notify_console, so the bell on every device stays
 * the single story of what happened.
 */

/** The people who own the store and receive every inventory request. */
function stock_request_manager_roles(): array
{
 return ['storekeeper','inventory_manager'];
}

/** The line items of a requisition, with the figures the Director is shown. */
function stock_request_lines(int $rid): array
{
 return rows(
  'SELECT ri.*,i.name item_name,i.unit,i.code,(ri.requested_qty*ri.est_cost) line_total'
  .' FROM purchase_requisition_items ri JOIN inventory_items i ON i.id=ri.item_id'
  .' WHERE ri.requisition_id=? ORDER BY i.name', [$rid]);
}

/** What a requisition comes to, in shillings, from the figures frozen on its lines. */
function stock_request_total(int $rid): float
{
 return (float)val('SELECT COALESCE(SUM(requested_qty*est_cost),0) FROM purchase_requisition_items WHERE requisition_id=?', [$rid]);
}

/** One line a person can read: "12 kg of Beef". */
function stock_request_item_list(int $rid): string
{
 $parts=[];
 foreach(stock_request_lines($rid) as $l){
  $parts[]=num($l['requested_qty']).' '.$l['unit'].' '.$l['item_name'];
 }
 return implode(', ', $parts);
}

/** A member's name, for the words the Director reads. */
function stock_request_user_name(?int $id): string
{
 if(!$id) return 'the system';
 return (string)(val('SELECT name FROM users WHERE id=?', [$id]) ?: 'a team member');
}

/**
 * The Director approves or turns a request down. A refusal must carry a reason:
 * the reason is written on the request and is the first thing the department
 * and the store read, so a "no" is never silent.
 *
 * @return array{ok:bool,error:?string}
 */
function stock_request_decide(int $rid, string $status, string $reason, int $by): array
{
 if(!in_array($status,['approved','rejected'],true)) return ['ok'=>false,'error'=>'bad-status'];
 $r=row('SELECT * FROM purchase_requisitions WHERE id=?', [$rid]);
 if(!$r) return ['ok'=>false,'error'=>'not-found'];
 $reason=trim($reason);
 if($status==='rejected' && $reason==='') return ['ok'=>false,'error'=>'reason-required'];

 q('UPDATE purchase_requisitions SET status=?,approved_by=?,approved_at=NOW(),decision_reason=? WHERE id=?',
  [$status,$by,$reason!==''?$reason:null,$rid]);
 audit('requisition_'.$status,'requisition',$rid,['status'=>$r['status'],'reason'=>$reason]);

 $total=stock_request_total($rid);
 $who=stock_request_user_name($by);
 if($status==='approved'){
  $body='Approved by '.$who.'. The list comes to '.money($total).'. The store can now issue the stock or raise a purchase order.';
 }else{
  $body='Turned down by '.$who.' — '.$reason.'. Amount requested was '.money($total).'.';
 }

 notify_console('req-'.$status.':'.$rid,'communication','Stock request '.$r['number'].' '.$status,$body,
  ['requisition_id'=>$rid,'number'=>$r['number'],'amount'=>$total,'status'=>$status],
  array_merge(['director','general_manager'],stock_request_manager_roles()),'requisition',$rid);
 return ['ok'=>true,'error'=>null];
}
