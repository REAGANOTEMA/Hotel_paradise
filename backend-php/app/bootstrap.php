<?php
declare(strict_types=1);

if(session_status()===PHP_SESSION_NONE) session_start();
date_default_timezone_set('Africa/Kampala');
mb_internal_encoding('UTF-8');

/**
 * Where the console and the public site live, worked out from where this file
 * actually is rather than written down here.
 *
 * These used to be hard coded to /hotelparadiseonthenile, which is right for
 * exactly one way of installing the site and wrong for every other. On this
 * machine the console sits at /Hotel_paradise, so every stylesheet and logo
 * came back 404 and the console rendered unstyled. Deriving the paths means the
 * console works in the domain root, in a subfolder, or in a project folder on a
 * developer's machine, with nothing to edit on the way to hosting.
 *
 * BASE is the backend-php folder, the one this file's parent directory.
 * SITE_URL is the folder above it, which is the public website.
 *
 * They are defined rather than declared const because the value depends on the
 * request, and a constant has to be known before the code runs.
 */
function hp_paths(): array{
 static $paths=null;
 if($paths!==null) return $paths;

 $appDir=str_replace('\\','/',dirname(__DIR__));          // .../backend-php
 $siteDir=dirname($appDir);                               // the public website
 $docRoot=str_replace('\\','/',rtrim($_SERVER['DOCUMENT_ROOT']??'','/'));

 // Only a path that really sits inside the document root can be expressed as a
 // URL. Anything else (a Windows path, a symbolic link outside the root) falls
 // back to the folder name, which is right for the usual shared hosting layout.
 $toUrl=function(string $dir) use($docRoot){
  if($docRoot!=='' && strpos($dir,$docRoot)===0){
   $rel=substr($dir,strlen($docRoot));
   return $rel===''?'/':rtrim($rel,'/');
  }
  return '/'.basename($dir);
 };

 $base=$toUrl($appDir);
 $paths=[
  'base'=>$base,
  'site'=>($siteDir===$appDir?$base:$toUrl($siteDir)),
 ];
 return $paths;
}

define('BASE',hp_paths()['base']);
define('SITE_URL',hp_paths()['site']);

/**
 * Whether the sign in page may print the demo passwords.
 *
 * It used to print them unconditionally, which handed the administrator's
 * password to anyone who loaded the page. It is off unless someone deliberately
 * switches it on, and a hosting platform will never set this, so the live site
 * shows nothing but the form.
 *
 * To turn it on on a development machine, set HP_DEMO_LOGINS=1 before starting
 * Apache, or put it in httpd.conf / .htaccess as:
 *
 *   SetEnv HP_DEMO_LOGINS 1
 */
function demo_logins_enabled(): bool{
  $v=getenv('HP_DEMO_LOGINS');
  if($v===false && isset($_SERVER['HP_DEMO_LOGINS'])) $v=$_SERVER['HP_DEMO_LOGINS'];
  if($v===false) return false;
  return in_array(strtolower(trim((string)$v)),['1','true','yes','on'],true);
}

/**
 * Where the databases are.
 *
 * The passwords live in config.php, which is never committed, and every value
 * can be overridden by an environment variable so that a host with a MySQL
 * hostname of its own needs no edit at all. The old hard coded values are kept
 * only as a last resort, so a missing config file still says something useful
 * in the error log instead of failing on an undefined constant.
 */
function db_config(): array{
 static $cfg=null;
 if($cfg!==null) return $cfg;
 $file=__DIR__.'/../config.php';
 $fromFile=is_readable($file)?require $file:[];
 if(!is_array($fromFile)) $fromFile=[];
 // config.php nests the website settings under 'web_db', so a dotted name such
 // as "web_db.pass" has to be walked rather than looked up whole
 $fromConfig=function(string $path) use($fromFile){
  $node=$fromFile;
  foreach(explode('.',$path) as $step){
   if(!is_array($node)||!array_key_exists($step,$node)) return null;
   $node=$node[$step];
  }
  return $node;
 };
 $pick=function(string $path,string $env,string $fallback) use($fromConfig): string{
  $v=getenv($env);
  if(is_string($v)&&$v!=='') return $v;
  $v=$fromConfig($path);
  if(is_string($v)&&$v!=='') return $v;
  return $fallback;
 };
 $host=$pick('db.host','HP_DB_HOST','127.0.0.1');
 $port=$pick('db.port','HP_DB_PORT','');
 return $cfg=[
  'dsn'=>'mysql:host='.$host.($port!==''?';port='.$port:'').';charset=utf8mb4',
  'host'=>$host,'port'=>$port,
  'name'=>$pick('db.name','HP_DB_NAME','hotelpardise_system'),
  'user'=>$pick('db.user','HP_DB_USER','hotelpardise_system'),
  'pass'=>$pick('db.pass','HP_DB_PASS',''),
  'web'=>[
   'name'=>$pick('web_db.name','HP_WEB_DB_NAME','hotelpardise_website'),
   'user'=>$pick('web_db.user','HP_WEB_DB_USER','hotelpardise_website'),
   'pass'=>$pick('web_db.pass','HP_WEB_DB_PASS',''),
  ],
 ];
}

/** Opens a connection and says clearly in the log which one could not open. */
function db_connect(string $dsn,string $dbName,string $user,string $pass): PDO{
 try{
  return new PDO($dsn.';dbname='.$dbName,$user,$pass,[
   PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,
   PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC
  ]);
 }catch(PDOException $e){
  error_log('[hotel db] cannot open '.$dbName.' as '.$user.'@'.db_config()['host'].': '.$e->getMessage());
  throw $e;
 }
}

/**
 * The hotel database. The management system uses this, and so does the public
 * menu and takeaway ordering, because the menu the guest reads, the order the
 * kitchen receives and the row the till settles have to be the same rows.
 */
function db(): PDO{
 static $pdo=null;
 if($pdo===null){
  $c=db_config();
  $pdo=db_connect($c['dsn'],$c['name'],$c['user'],$c['pass']);
 }
 return $pdo;
}

/** The website's own database, used only for website specific tables. */
function web_db(): PDO{
 static $pdo=null;
 if($pdo===null){
  $c=db_config();
  $pdo=db_connect($c['dsn'],$c['web']['name'],$c['web']['user'],$c['web']['pass']);
 }
 return $pdo;
}

/** A short description of a connection for the health check, never a secret. */
function db_label(PDO $pdo): string{
 $cfg=db_config();
 foreach([[$cfg['name'],$cfg['user']],[$cfg['web']['name'],$cfg['web']['user']]] as $pair){
  try{ if($pdo->query('SELECT DATABASE()')->fetchColumn()===$pair[0]) return $pair[0]===$pair[1]?$pair[0]:$pair[0].' as '.$pair[1]; }catch(Throwable $e){}
 }
 try{ return (string)$pdo->query('SELECT DATABASE()')->fetchColumn(); }catch(Throwable $e){ return 'unknown'; }
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