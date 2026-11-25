<?php
declare(strict_types=1);

function hp_enterprise_ready(array $tables): bool{
  foreach($tables as $t){ if(!hp_table_exists($t)) return false; }
  return true;
}

function hp_sensitive_request(string $type,string $entity,int $entityId,float $amount,string $reason): ?int{
  $types=['refund','discount','cancellation','upgrade','void','payroll_approval','disciplinary_action','late_checkout'];
  if(!in_array($type,$types,true)||$entityId<1||trim($reason)==='') return null;
  $me=current_user();
  q('INSERT INTO hp_sensitive_actions(hotel_id,action_type,entity_type,entity_id,amount,reason,requested_by,status,created_at) VALUES(1,?,?,?,?,?,?,\'pending\',NOW())',
    [$type,$entity,$entityId,$amount,mb_substr(trim($reason),0,500),(int)($me['id']??0)]);
  $id=(int)db()->lastInsertId();
  audit('sensitive_request',$entity,$entityId,null,['action_type'=>$type,'amount'=>$amount,'reason'=>$reason]);
  notify_console('sensitive-'.$id,'approval','Authorization needed: '.str_replace('_',' ',$type),
    mb_substr(trim($reason),0,160).' · '.money($amount),
    ['sensitive_action_id'=>$id,'entity_type'=>$entity,'entity_id'=>$entityId],
    ['director','general_manager','auditor'],$entity,$entityId);
  return $id;
}

function hp_sensitive_pending(int $entityId,string $entity,string $type): ?array{
  return row('SELECT * FROM hp_sensitive_actions WHERE entity_type=? AND entity_id=? AND action_type=? AND status=\'pending\' ORDER BY id DESC LIMIT 1',[$entity,$entityId,$type]);
}

function hp_sensitive_decide(int $id,string $status,string $note): bool{
  if(!in_array($status,['approved','rejected'],true)) return false;
  $a=row('SELECT * FROM hp_sensitive_actions WHERE id=?',[$id]);
  if(!$a||$a['status']!=='pending') return false;
  $me=current_user();
  q('UPDATE hp_sensitive_actions SET authorized_by=?,status=?,decided_at=NOW() WHERE id=?',[(int)($me['id']??0),$status,$id]);
  audit('sensitive_decision','sensitive_action',$id,['status'=>$a['status']],['status'=>$status,'note'=>$note]);
  notify_console('sensitive-decision-'.$id,'approval','Authorization '.str_replace('_',' ',$status),
    str_replace('_',' ',(string)$a['action_type']).' · '.$note,
    ['sensitive_action_id'=>$id,'entity_type'=>$a['entity_type'],'entity_id'=>(int)$a['entity_id']],
    ['director','general_manager','auditor'],(string)$a['entity_type'],(int)$a['entity_id']);
  return true;
}

function hp_money_input($v): float{
  return max(0,round(abs((float)$v),2));
}

function hp_date_input($v): string{
  $s=trim((string)$v);
  return preg_match('/^\d{4}-\d{2}-\d{2}$/',$s)?$s:'';
}
