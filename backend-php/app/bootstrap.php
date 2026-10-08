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
 *
 * The two arguments exist so the arithmetic can be checked against every layout
 * the site is installed in, which is the one way to be sure a move to hosting
 * will not bring the 404s back. Production always calls it with no arguments.
 */
function hp_paths(?string $appDir=null, ?string $docRoot=null): array{
 static $real=null;
 // The real answer is worked out once per request. Passing the folders in asks
 // about some other layout, so that is always worked out afresh and never kept.
 $asking=($appDir===null && $docRoot===null);
 if($asking && $real!==null) return $real;

 $appDir=str_replace('\\','/',$appDir??dirname(__DIR__));  // .../backend-php
 $siteDir=dirname($appDir);                                  // the public website
 $docRoot=str_replace('\\','/',rtrim($docRoot??($_SERVER['DOCUMENT_ROOT']??''),'/'));

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

 // The site's own folder comes out as / when the site fills the domain. Left
 // alone that would read //images/logo.png, which a browser treats as a
 // protocol relative address and looks for on a host called "images", so an
 // empty site path is the honest answer for a site at the domain root.
 $site=$toUrl($siteDir);
 $paths=[
  'base'=>$toUrl($appDir),
  'site'=>($site==='/'?'':$site),
 ];
 if($asking) $real=$paths;
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
  return false;
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

/**
 * Removes anything secret from a driver message before it is shown or logged.
 *
 * A PDOException message is safe on its own, but the exception it is thrown from
 * carries the arguments of the new PDO() call in its stack trace, and those
 * arguments are the DSN, the user name and the password. With display_errors on,
 * which is the default in a local XAMPP install, that trace is printed straight
 * into the browser, so a database that would not open printed the production
 * password to whoever happened to load the page. Nothing that leaves this file
 * is allowed to carry a configured password, so every message goes through here
 * first, whatever it came from.
 */
function db_scrub(string $text): string{
  $cfg=db_config();
  foreach([$cfg['pass'],$cfg['web']['pass']] as $secret){
   if(is_string($secret)&&$secret!=='') $text=str_replace($secret,'[redacted]',$text);
  }
  return $text;
}

/**
 * The one sentence a person can act on.
 *
 * "Access denied for user 'x'@'localhost' (using password: YES)" does not say
 * which of the three possible causes is true, and the two most common ones look
 * identical on screen: the account does not exist, or the password in config.php
 * is not the password the account has. Saying that plainly saves the reader the
 * only part of the job that is actually hard.
 */
function db_failure_reason(PDOException $e,string $dbName,string $user): string{
  $m=$e->getMessage();
  if(stripos($m,'access denied')!==false)
   return 'MySQL refused the password for user "'.$user.'" on database "'.$dbName.'". The account either does not exist, or its password is not the one in backend-php/config.php.';
  if(stripos($m,'unknown database')!==false)
   return 'The database "'.$dbName.'" does not exist. The schema has not been installed into it.';
  if(stripos($m,'connection refused')!==false||stripos($m,'no connection could be made')!==false)
   return 'MySQL could not be reached on '.db_config()['host'].'. The MySQL service is probably not running.';
  if(stripos($m,'no such file or directory')!==false)
   return 'MySQL could not be reached. The host in backend-php/config.php is not a socket this PHP can open.';
  return 'MySQL did not accept the request: '.db_scrub($m);
}

/** Opens a connection and says clearly in the log which one could not open. */
function db_connect(string $dsn,string $dbName,string $user,string $pass): PDO{
  try{
   return new PDO($dsn.';dbname='.$dbName,$user,$pass,[
    PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC
   ]);
  }catch(PDOException $e){
   $reason=db_failure_reason($e,$dbName,$user);
   // The log keeps the SQLSTATE, which is what tells a wrong password (1045)
   // apart from a missing database (1049) when reading it back days later.
   error_log('[hotel db] cannot open '.$dbName.' as '.$user.'@'.db_config()['host']
    .' [SQLSTATE '.$e->getCode().']: '.$reason);
   // A new exception, not the original. Re-throwing the driver's would put the
   // PDO arguments back on the page through the new stack trace.
   throw new RuntimeException($reason,0);
  }
}

/**
 * The page shown when the hotel database cannot be opened at all.
 *
 * Without this the console died on an uncaught PDOException, which meant a
 * configuration mistake reached the visitor as a PHP stack trace instead of as
 * an explanation. It is a standalone page with its own styling because the real
 * console layout is built by functions that need the very database that is
 * missing, and cannot be used to report its own absence.
 *
 * The fix steps sit inside a collapsed section, so a live site shows one calm
 * sentence while a person setting the site up can open the rest.
 */
function db_setup_page(string $reason): void{
  http_response_code(503);
  header('Content-Type: text/html; charset=utf-8');
  $cfg=db_config();
  $steps=[
   'Is MySQL running? Open the XAMPP Control Panel and start MySQL, or run "net start MySQL".',
   'Do the database and the user exist? Run: php tools/install-databases.php',
   'Are the credentials right? backend-php/config.php holds the user name and the password. The password there has to match the one the MySQL account was created with.',
   'Did the host change on hosting? A host that is not localhost almost always wants a user name with the account prefix on it, for example yourname_'.$cfg['user'].'.',
   'Has something been overridden? The environment variables HP_DB_HOST, HP_DB_PORT, HP_DB_NAME, HP_DB_USER and HP_DB_PASS win over config.php, and HP_WEB_DB_NAME, HP_WEB_DB_USER and HP_WEB_DB_PASS do the same for the website database.'
  ];
  echo '<!doctype html><html lang="en"><head><meta charset="utf-8">';
  echo '<meta name="viewport" content="width=device-width,initial-scale=1">';
  echo '<title>Database unavailable | Hotel Paradise on the Nile</title>';
  echo '<style>body{margin:0;background:#f4f6f9;color:#1E3A5F;font:15px/1.6 "DM Sans",system-ui,-apple-system,Segoe UI,Roboto,sans-serif}'
   .'.wrap{max-width:640px;margin:8vh auto;padding:0 20px}'
   .'h1{font-size:22px;margin:0 0 6px}p.lead{margin:0 0 18px;color:#475569}'
   .'box{background:#fff;border:1px solid #dfe4ec;border-left:4px solid #b26a00;border-radius:6px;padding:18px 20px}'
   .'code,pre{font-family:ui-monospace,Consolas,monospace;font-size:13px}'
   .'pre{background:#0f172a;color:#e2e8f0;padding:12px 14px;border-radius:5px;overflow-x:auto}'
   .'ol{margin:8px 0 0;padding-left:20px}li{margin-bottom:8px}'
   .'small{color:#64748b;font-size:13px;margin-top:20px}</style></head><body><div class="wrap">';
  echo '<h1>The management system cannot reach its database</h1>';
  echo '<p class="lead">Nothing has been changed and no data was lost. The site needs its MySQL database before it can sign anyone in.</p>';
  echo '<div class="box"><p>'.e($reason).'</p>';
  echo '<details><summary style="cursor:pointer;font-weight:600;margin-top:14px">How to fix this</summary><ol>';
  foreach($steps as $s) echo '<li>'.e($s).'</li>';
  echo '</ol><p class="small">The exact command for this machine is:</p>';
  echo '<pre>php tools/install-databases.php</pre></details>';
  echo '<p class="small">Details are in the Apache and PHP error log.</p>';
  echo '</div></div></body></html>';
  exit;
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
   try{
    $pdo=db_connect($c['dsn'],$c['name'],$c['user'],$c['pass']);
   }catch(RuntimeException $e){
    // The whole console reads and writes the hotel database, so there is no
    // part of a page that can be shown without it. Answer with the explanation
    // rather than letting the request end in a fatal error.
    db_setup_page($e->getMessage());
   }
  }
  return $pdo;
}

/**
 * The website's own database, used only for website specific tables.
 *
 * Unlike the hotel database this one is not made of page furniture: only the
 * health check reads it, and it reports the failure as part of its own answer.
 * So the sanitised exception is passed on and the caller decides, which is why
 * a website database that is down degrades the health check instead of blanking
 * the console.
 */

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
  // The director's own page: the money, every order, every customer, and the
  // detail behind either of them. Deliberately not opened to accountants or
  // auditors - it is the view of the house, not of the ledger.
  'overview'=>['director','general_manager'],
  'reservations'=>['receptionist','general_manager','director','accountant','events_manager'],
  'rooms'=>['receptionist','housekeeping','general_manager','director','maintenance'],
  'guests'=>['receptionist','general_manager','director','accountant'],
  'pos'=>['waiter','bar_staff','cashier','kitchen','general_manager','director'],
  // Food and beverage runs the floor: the outlets, the bills, the payments.
  'fnb'=>['waiter','bar_staff','cashier','general_manager','director'],
  // The kitchen sees food only - no prices, no payments, no guests.
  'kitchen'=>['kitchen','general_manager','director'],
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