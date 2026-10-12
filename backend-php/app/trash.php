<?php
declare(strict_types=1);

/**
 * Soft delete, the "Trash".
 *
 * A record is never removed the moment someone presses Delete. It is marked
 * with deleted_at (and who did it) and immediately leaves the module list; it
 * then sits on the Trash page until a director or general manager either
 * restores it or removes it for good. Nothing is lost by a slip of the hand.
 *
 * Only the tables named in trash_registry() can be handled this way, and that
 * list is the only place a table name is ever accepted from a request, so the
 * browser can never point the UPDATE/DELETE at a table of its own choosing.
 */

/** The records the console may trash, and how each one reads on the Trash page.
 *  title is the column shown as the record's name, desc a quiet second line,
 *  page is the console module that owns it. */
function trash_registry(): array{
 return [
  'guests'                =>['label'=>'Guest',          'title'=>'full_name',      'desc'=>'email',          'page'=>'guests'],
  'suppliers'             =>['label'=>'Supplier',        'title'=>'name',           'desc'=>'contact_person','page'=>'suppliers'],
  'users'                 =>['label'=>'Team member','title'=>'name',           'desc'=>'email',          'page'=>'users'],
  'inventory_items'       =>['label'=>'Stock item','title'=>'name','desc'=>'code','page'=>'inventory'],
  'expenses'              =>['label'=>'Expense','title'=>'number','desc'=>'description','page'=>'expenses'],
  'event_requests'        =>['label'=>'Event request','title'=>'request_number','desc'=>'full_name','page'=>'events'],
  'facility_enquiries'    =>['label'=>'Facility enquiry','title'=>'enquiry_number','desc'=>'full_name','page'=>'events'],
  'news_posts'            =>['label'=>'News post','title'=>'title','desc'=>'category','page'=>'news'],
  'reservations'          =>['label'=>'Reservation','title'=>'booking_number','desc'=>'status','page'=>'reservations'],
  'purchase_requisitions' =>['label'=>'Requisition','title'=>'number','desc'=>'status','page'=>'purchases'],
  'purchase_orders'       =>['label'=>'Purchase order','title'=>'number','desc'=>'status','page'=>'purchases'],
  'rooms'                 =>['label'=>'Room','title'=>'room_number','desc'=>'status','page'=>'rooms'],
  'room_types'            =>['label'=>'Room type','title'=>'name','desc'=>'description','page'=>'rooms'],
 ];
}

function trash_supported(string $table): bool{ return array_key_exists($table,trash_registry()); }
function trash_meta(string $table): ?array{ return trash_registry()[$table]??null; }

/** Only the Director, the General Manager and the super admin may empty the
 *  Trash or bring something back out of it. Moving a record in is allowed to
 *  whoever may open the module that owns it. */
function trash_can_manage(): bool{
 if(in_array('super_admin',roles_of(),true)) return true;
 return (bool)array_intersect(roles_of(),['director','general_manager']);
}

function trash_soft_delete(string $table,int $id): bool{
 if(!trash_supported($table)||$id<=0) return false;
 // Never let a member move their own account to the Trash by accident.
 if($table==='users' && $id===(int)(current_user()['id']??0)) return false;
 $u=current_user();
 $st=q("UPDATE `$table` SET deleted_at=NOW(), deleted_by=? WHERE id=? AND deleted_at IS NULL",[$u['id']??null,$id]);
 return $st->rowCount()>0;
}

function trash_restore(string $table,int $id): bool{
 if(!trash_supported($table)||$id<=0) return false;
 $st=q("UPDATE `$table` SET deleted_at=NULL, deleted_by=NULL WHERE id=? AND deleted_at IS NOT NULL",[$id]);
 return $st->rowCount()>0;
}

function trash_purge(string $table,int $id): bool{
 if(!trash_supported($table)||$id<=0) return false;
 $st=q("DELETE FROM `$table` WHERE id=? AND deleted_at IS NOT NULL",[$id]);
 return $st->rowCount()>0;
}

/** How many records are sitting in the Trash, for the rail badge. */
function trash_count(): int{
 $n=0;
 foreach(trash_registry() as $table=>$meta){
  try{ $n+=(int)val("SELECT COUNT(*) FROM `$table` WHERE deleted_at IS NOT NULL"); }catch(Throwable $e){}
 }
 return $n;
}

/**
 * One "Move to Trash" button, wrapped in its own tiny form. Every table row
 * that offers it posts the same three fields, so one handler in the router
 * serves every module: which table, which row, and where to come back to.
 */
function trash_button(string $table,int $id,string $back=''): string{
 $meta=trash_meta($table);
 if($meta===null) return '';
 $what=strtolower($meta['label']);
 $msg='Move this '.$meta['label'].' to the Trash? You can restore it later from the Trash page.';
 return '<form method="post" class="actForm" onsubmit="return confirm('.json_encode($msg,JSON_UNESCAPED_SLASHES|JSON_HEX_APOS).')">'
  .'<input type="hidden" name="trash_action" value="trash">'
  .'<input type="hidden" name="table" value="'.e($table).'">'
  .'<input type="hidden" name="id" value="'.(int)$id.'">'
  .'<input type="hidden" name="back" value="'.e($back).'">'
  .'<button class="btn sm danger" type="submit">Delete</button></form>';
}

/**
 * The single place a Trash action is carried out. The router calls this after
 * the member is known and allowed on the page, and before the module runs.
 * Nothing here trusts the table name: it must be one the registry knows.
 */
function trash_handle(): void{
 if(($_SERVER['REQUEST_METHOD']??'')!=='POST') return;
 $action=trim((string)($_POST['trash_action']??''));
 if(!in_array($action,['trash','restore','purge'],true)) return;

 $table=trim((string)($_POST['table']??''));
 $id=(int)($_POST['id']??0);
 $back=trim((string)($_POST['back']??''));
 if(!trash_supported($table)){
  flash('That record type cannot be removed.','bad');
  go(in_array($back,page_names(),true)?$back:'dashboard');
 }
 $meta=trash_meta($table);

 if($action==='trash'){
  $page=$meta['page'];
  if(!page_allowed($page)){
   flash('Your role does not allow removing that record.','warn');
   go(in_array($back,page_names(),true)?$back:$page);
  }
  if($table==='users' && $id===(int)(current_user()['id']??0)){
   flash('You cannot delete the account you are signed in with.','warn');
   go($page);
  }
  if(trash_soft_delete($table,$id)){
   audit('trash',$table,$id);
   flash($meta['label'].' moved to Trash. It can be restored from the Trash page.');
  }else{
   flash('That record was already in the Trash.','warn');
  }
  go(in_array($back,page_names(),true)?$back:$page);
 }

 // restore / purge -- the director's and the general manager's call alone
 if(!trash_can_manage()){
  flash('Only the Director or General Manager can restore or erase records.','warn');
  go('trash');
 }
 if($action==='restore'){
  if(trash_restore($table,$id)){ audit('restore',$table,$id); flash($meta['label'].' restored.'); }
  else flash('That record is not in the Trash.','warn');
  go('trash');
 }
 if($action==='purge'){
  if(trash_purge($table,$id)){ audit('purge',$table,$id); flash($meta['label'].' deleted permanently.'); }
  else flash('Nothing to remove — it is no longer in the Trash.','warn');
  go('trash');
 }
}
