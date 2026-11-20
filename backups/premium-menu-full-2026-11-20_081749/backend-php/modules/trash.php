<?php
declare(strict_types=1);

/**
 * Trash — everything the console has moved out of the way but not removed.
 *
 * A record leaves its module the moment it is deleted, and lands here. The
 * Director or General Manager can put it straight back where it came from, or
 * remove it for good. Nothing on this page is reachable by anyone else.
 */

page_head('Trash','trash','Deleted records — restore them, or remove them for good.');

if(!trash_can_manage()){
 echo '<div class="panel"><h2>Access restricted</h2><p class="hint">Only the Director and the General Manager may open the Trash.</p><a class="btn" href="'.BASE.'/index.php?page=dashboard">Back to dashboard</a></div>';
 page_foot(); exit;
}

$registry=trash_registry();
$total=trash_count();

/* The people who deleted things, in one read, so the listing can say who. */
$who=[];
foreach(rows('SELECT id,name FROM users') as $u) $who[(int)$u['id']]=$u['name'];

echo '<div class="panel"><p class="hint" style="margin:0">Records moved out of the modules wait here. Restore one to put it back, or delete it for good to remove it permanently. A record is never removed until you do that second step.</p></div>';

if($total===0){
 echo '<div class="panel"><h2>Nothing in the Trash</h2><p class="hint">When you delete a guest, expense, news post or any other record, it will wait here so it can be brought back.</p><p><a class="btn" href="'.BASE.'/index.php?page=dashboard">Back to dashboard</a></p></div>';
 page_foot(); exit;
}

foreach($registry as $table=>$meta){
 $list=[];
 try{
  $list=rows("SELECT t.*, u.name AS del_by FROM `$table` t LEFT JOIN users u ON u.id=t.deleted_by WHERE t.deleted_at IS NOT NULL ORDER BY t.deleted_at DESC LIMIT 300");
 }catch(Throwable $e){ continue; }
 if(!$list) continue;

 $titleCol=$meta['title']; $descCol=$meta['desc'];
 echo '<div class="panel"><div class="panelHead"><h2>'.e($meta['label']).'s</h2><span class="badge grey">'.count($list).'</span></div>';
 echo '<p class="hint">Deleted from '.e($meta['label']).' records. The original module is <b>'.e($meta['page']).'</b>.</p>';
 echo '<table class="tbl"><thead><tr><th>Record</th><th>Deleted</th><th>By</th><th style="text-align:right">Action</th></tr></thead><tbody>';
 foreach($list as $r){
  $title=(string)($r[$titleCol]??''); if($title==='') $title='#'.(int)$r['id'];
  $desc=(string)($r[$descCol]??'');
  echo '<tr>';
  echo '<td><b>'.e($title).'</b>'.($desc!==''?'<br><small>'.e($desc).'</small>':'').'</td>';
  echo '<td>'.e(fmtdt($r['deleted_at'])).'</td>';
  echo '<td>'.e($r['del_by']??($who[(int)($r['deleted_by']??0)]??'—')).'</td>';
  echo '<td style="text-align:right;white-space:nowrap">';
  echo '<form method="post" class="actForm" onsubmit="return confirm(\'Put this record back where it came from?\');">'.csrf_field();
  echo '<input type="hidden" name="trash_action" value="restore"><input type="hidden" name="table" value="'.e($table).'"><input type="hidden" name="id" value="'.(int)$r['id'].'">';
  echo '<button class="btn sm" type="submit">Restore</button></form> ';
  echo '<form method="post" class="actForm" onsubmit="return confirm(\'Delete this record for good? This cannot be undone.\');">'.csrf_field();
  echo '<input type="hidden" name="trash_action" value="purge"><input type="hidden" name="table" value="'.e($table).'"><input type="hidden" name="id" value="'.(int)$r['id'].'">';
  echo '<button class="btn sm danger" type="submit">Delete permanently</button></form>';
  echo '</td></tr>';
 }
 echo '</tbody></table></div>';
}

page_foot();
