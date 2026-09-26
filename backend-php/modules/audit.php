<?php
declare(strict_types=1);

$act=$_GET['act']??'';
$search=trim($_GET['q']??'');
$where='1=1'; $params=[];
if($search!==''){ $where.=' AND (a.action LIKE ? OR a.entity_type LIKE ? OR u.name LIKE ?)'; $params=['%'.$search.'%','%'.$search.'%','%'.$search.'%']; }
$list=rows("SELECT a.*,u.name uname FROM audit_logs a LEFT JOIN users u ON u.id=a.user_id WHERE $where ORDER BY a.id DESC LIMIT 120",$params);

page_head('Audit trail','audit','A tamper evident record of critical actions');
echo '<div class="panel"><h2>Audit log</h2><p class="hint">Read only. Every critical action below shows who did what and when. Financial reversals and voids are never silently deleted.</p>';
echo '<form method="get" style="display:flex;gap:8px;margin-bottom:16px"><input type="hidden" name="page" value="audit"><input name="q" value="'.e($search).'" placeholder="Filter by action, module or user..." style="padding:9px 12px;border:1px solid var(--line);border-radius:9px;flex:1;max-width:360px"><button class="btn sm">Filter</button></form>';
if(!has_role('auditor')&&!has_role('super_admin')) echo '<div class="flash warn" style="max-width:480px">Sensitive fields such as before and after values are available to reviewers and administrators only.</div>';
echo '<table class="tbl"><thead><tr><th>When</th><th>User</th><th>Action</th><th>Entity</th><th class="num">Ref</th><th>IP address</th></tr></thead><tbody>';
foreach($list as $a){
 echo '<tr><td>'.fmtdt($a['created_at']).'</td><td><b>'.e($a['uname']??'System').'</b></td><td>'.e(str_replace('_',' ',$a['action'])).'</td><td>'.e(str_replace('_',' ',$a['entity_type']??'')).'</td><td class="num">'.($a['entity_id']?e($a['entity_id']):'-').'</td><td style="font-size:12px;color:var(--muted)">'.e($a['ip_address']??'').'</td></tr>';
}
if(!count($list)) echo '<tr><td colspan="6" style="text-align:center;color:var(--muted)">No activity recorded.</td></tr>';
echo '</tbody></table></div>';
page_foot();