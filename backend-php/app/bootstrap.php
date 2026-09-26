<?php
declare(strict_types=1);

if(session_status()===PHP_SESSION_NONE) session_start();
date_default_timezone_set('Africa/Kampala');
mb_internal_encoding('UTF-8');

const DB_HOST='127.0.0.1';
const DB_NAME='hotel_paradise_nile';
const DB_USER='root';
const DB_PASS='';
const BASE=''.'/hotelparadiseonthenile/backend-php';
const SITE_URL=''.'/hotelparadiseonthenile';

function db(): PDO{
 static $pdo=null;
 if($pdo===null){
  $pdo=new PDO('mysql:host='.DB_HOST.';dbname='.DB_NAME.';charset=utf8mb4',DB_USER,DB_PASS,[
   PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,
   PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC
  ]);
 }
 return $pdo;
}
function q(string $sql,array $p=[]){ $st=db()->prepare($sql); $st->execute($p); return $st; }
function rows(string $sql,array $p=[]){ return q($sql,$p)->fetchAll(); }
function row(string $sql,array $p=[]){ $r=q($sql,$p)->fetch(); return $r===false?null:$r; }
function val(string $sql,array $p=[]){ $r=q($sql,$p)->fetchColumn(); return $r===false?null:$r; }

function e($v=null): string{ return htmlspecialchars((string)$v,ENT_QUOTES,'UTF-8'); }
function money($v): string{ return 'UGX '.number_format((float)$v,0); }
function num($v): string{ return number_format((float)$v,0); }
function today(): string{ return date('Y-m-d'); }
function now_s(): string{ return date('Y-m-d H:i:s'); }
function fmtdt($d): string{ return $d?date('d M Y H:i',strtotime((string)$d)):''; }
function fmtdate($d): string{ return $d?date('d M Y',strtotime((string)$d)):''; }

function current_user(): ?array{ return $_SESSION['user']??null; }
function set_current_user(array $u): void{ $_SESSION['user']=$u; }
function logout_user(): void{ unset($_SESSION['user']); }
function roles_of(): array{ return $_SESSION['roles']??[]; }
function has_role(string $role): bool{
 if(in_array('super_admin',roles_of())) return true;
 return in_array($role,roles_of());
}

function page_allowed(string $page): bool{
 $u=current_user(); if(!$u) return false;
 $r=roles_of();
 if(in_array('super_admin',$r)) return true;
 $map=[
  'dashboard'=>[],
  'reservations'=>['receptionist','general_manager','director','accountant','events_manager'],
  'rooms'=>['receptionist','housekeeping','general_manager','director','maintenance'],
  'guests'=>['receptionist','general_manager','director','accountant'],
  'pos'=>['waiter','bar_staff','cashier','kitchen','general_manager','director'],
  'shifts'=>['cashier','general_manager','director','accountant'],
  'inventory'=>['storekeeper','general_manager','director','accountant'],
  'suppliers'=>['procurement','storekeeper','general_manager','director','accountant'],
  'purchases'=>['procurement','storekeeper','general_manager','director','accountant'],
  'expenses'=>['accountant','general_manager','director','receptionist','housekeeping','kitchen'],
  'finance'=>['accountant','general_manager','director','cashier'],
  'approvals'=>['general_manager','director','accountant'],
  'audit'=>['auditor','general_manager','director','accountant'],
  'reports'=>['general_manager','director','accountant','auditor'],
  'users'=>['general_manager','director']
 ];
 $allowed=$map[$page]??[];
 if($allowed===[]) return true;
 return (bool)array_intersect($r,$allowed);
}

function flash(string $msg,string $type='ok'): void{ $_SESSION['flash']=['msg'=>$msg,'type'=>$type]; }
function flash_out(): ?array{ if(isset($_SESSION['flash'])){ $f=$_SESSION['flash']; unset($_SESSION['flash']); return $f;} return null; }

function audit(string $action,?string $entity=null,$id=null,$old=null,$new=null): void{
 $u=current_user();
 q('INSERT INTO audit_logs(hotel_id,user_id,action,entity_type,entity_id,old_values,new_values,ip_address,user_agent,created_at) VALUES(1,?,?,?,?,?,?,?,?,NOW())',[
  $u['id']??null,$action,$entity,$id,
  $old===null?null:json_encode($old),
  $new===null?null:json_encode($new),
  $_SERVER['REMOTE_ADDR']??null,
  substr($_SERVER['HTTP_USER_AGENT']??'',0,250)
 ]);
}

function next_number(string $prefix,string $table,string $col): string{
 $d=date('Ymd'); $p=$prefix.'-'.$d.'-';
 $max=val("SELECT MAX($col) FROM $table WHERE $col LIKE ?",[$p.'%']);
 $n=(int)substr((string)$max,strlen($p))+1;
 return $p.str_pad((string)$n,3,'0',STR_PAD_LEFT);
}

function go(string $page,array $q=[]): void{
 $qs=(count($q)?'&'.http_build_query($q):'');
 header('Location: '.BASE.'/index.php?page='.$page.$qs); exit;
}

function badge(string $text,string $tone='grey'): string{
 $tones=['ok'=>'#2e7d32','warn'=>'#b26a00','bad'=>'#c62828','gold'=>'#C9A227','navy'=>'#1E3A5F','blue'=>'#0B5D78','grey'=>'#64748b'];
 $c=$tones[$tone]??$tones['grey'];
 return '<span class="badge" style="background:'.$c.'1a;color:'. $c.';border:1px solid '.$c.'55">'.e($text).'</span>';
}

function payment_methods(): array{ return ['cash'=>'Cash','mtn_momo'=>'Mobile Money','airtel_money'=>'Airtel Money','card'=>'Card','bank'=>'Bank Transfer','other'=>'Other']; }

function role_label(string $r): string{
 $map=['super_admin'=>'Administrator','director'=>'Director','general_manager'=>'General Manager','accountant'=>'Finance','cashier'=>'Cashier','receptionist'=>'Front Desk','waiter'=>'Waiter','bar_staff'=>'Bar Staff','kitchen'=>'Kitchen','storekeeper'=>'Storekeeper','procurement'=>'Procurement','housekeeping'=>'Housekeeping','auditor'=>'Auditor'];
 return $map[$r]??str_replace('_',' ',$r);
}