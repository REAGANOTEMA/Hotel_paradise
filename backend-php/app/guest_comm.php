<?php
declare(strict_types=1);

/* Guest communications: the shared questions the messages and testimonials
   modules, the dashboards and the director's page all ask of the one table
   (guest_messages). Kept here so an inbox, a KPI and a board can never
   disagree about what a front desk role may open or what an experience is. */

/** The desks a guest can write to, shown in the order the console offers them. */
function guest_message_departments(): array{
 return ['front_office'=>'Front office','kitchen'=>'Kitchen'];
}

/** Whether the guest communications tables have been installed. */
function guest_message_ready(): bool{
 try{ return (int)val('SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?',['guest_messages'])>0; }
 catch(\Throwable $e){ return false; }
}

/** The departments the signed-in member may open. The front desk reads what is
 *  sent to the house, the kitchen what is sent to the kitchen, and management
 *  reads and answers both. Anyone not allowed into the messages module has no
 *  desk at all, so a finance clerk never sees a guest's correspondence. */
function guest_message_scope(): array{
 $r=roles_of();
 if(in_array('director',$r,true)||in_array('general_manager',$r,true)||in_array('super_admin',$r,true)) return array_keys(guest_message_departments());
 if(in_array('receptionist',$r,true)) return ['front_office'];
 if(in_array('kitchen',$r,true)) return ['kitchen'];
 return [];
}

/** How a guest message status reads on a badge and a filter. */
function guest_message_statuses(): array{
 return ['new'=>'New','assigned'=>'Assigned','resolved'=>'Resolved','featured'=>'Featured'];
}

/** How a source reads in a list. */
function guest_message_sources(): array{
 return ['website'=>'From the website','in_stay'=>'Guest in the house'];
}

/** Counts of guest work the reader's desk may open, shaped for the boards.
 *  Returns zeroed keys when the table is missing, so a dashboard never bursts
 *  while the upgrade has not yet run. */
function guest_message_counts(): array{
 $z=['total'=>0,'new'=>0,'open'=>0,'message'=>0,'experience'=>0,'front_office'=>0,'kitchen'=>0];
 try{
  if(!guest_message_ready()) return $z;
  $scope=guest_message_scope();
  if($scope===[]) return $z;
  $ph=implode(',',array_fill(0,count($scope),'?'));
  $rows=rows("SELECT kind,department,status,COUNT(*) n FROM guest_messages WHERE department IN ($ph) GROUP BY kind,department,status",$scope);
  foreach($rows as $r){
   $k=(string)$r['kind']; $d=(string)$r['department']; $s=(string)$r['status']; $n=(int)$r['n'];
   $z['total']+=$n;
   if($s==='new') $z['new']+=$n;
   if($s!=='resolved'&&$s!=='featured') $z['open']+=$n;
   if($k==='message') $z['message']+=$n;
   else $z['experience']+=$n;
   if(isset($z[$d])) $z[$d]+=$n;
  }
 }catch(\Throwable $e){}
 return $z;
}

/** The roles a guest communication should ring, for one desk and a kind.
 *  A kitchen message rings the kitchen and management; an experience rings
 *  marketing as well, because marketing decides what appears on the site. */
function guest_message_notify_roles(string $department,string $kind='message'): array{
 $roles=['director','general_manager','super_admin'];
 if($department==='kitchen') $roles[]='kitchen';
 else $roles[]='receptionist';
 if($kind==='experience') $roles[]='marketing';
 return $roles;
}