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
 * config.php, read once per request and never a byte of it printed.
 *
 * config.php is a plain "return [...]" file, and it is asked for by several
 * callers in the same request - the database, Pesapal, the mailer. Because it
 * starts with "<?php" a well formed file prints nothing, but a byte-order mark
 * or a stray blank line saved at the very top of it by an editor is printed
 * every single time the file is included. In an API that answers with JSON,
 * those few bytes are appended in front of the JSON and the browser refuses to
 * parse it, which the checkout page can only report as the payment service
 * being unreachable. This reads the file under its own output buffer, throws
 * that stray output away, and caches the array, so the settings are parsed once
 * and nothing the file emits can ever reach the response.
 */
if(!function_exists('hp_config')){
 function hp_config(): array{
  static $cfg=null;
  if($cfg!==null) return $cfg;
  $file=__DIR__.'/../config.php';
  if(!is_readable($file)) return $cfg=[];
  ob_start();
  $got=include $file;
  ob_end_clean();
  return $cfg=is_array($got)?$got:[];
 }
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
 $fromFile=hp_config();
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

/** Does this database have the named table? Used only to decide whether a
 *  repair is worth attempting; a missing information_schema is answered with
 *  a quiet "no" rather than a fatal. */
function hp_table_exists(string $table): bool{
 try{
  return (int)val('SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=?',[$table])>0;
 }catch(Throwable $e){ return false; }
}

/** Does this database have the named column on that table? */
function hp_column_exists(string $table,string $col): bool{
 try{
  return (int)val('SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME=? AND COLUMN_NAME=?',[$table,$col])>0;
 }catch(Throwable $e){ return false; }
}

/** Adds a column the running database does not have yet, and does nothing at
 *  all when it already does. A locked or read-only database is left to the page
 *  to explain, so this never turns a missing column into a stack trace. */
function hp_ensure_column(string $table,string $col,string $definition): void{
 if(!hp_table_exists($table)||hp_column_exists($table,$col)) return;
 try{ db()->exec('ALTER TABLE `'.$table.'` ADD COLUMN '.$definition); }
 catch(Throwable $e){ error_log('[hotel repair] could not add '.$table.'.'.$col.': '.$e->getMessage()); }
}

/**
 * The soft-delete columns, brought up to date on every console page.
 *
 * Every module in the console lists what has not been trashed, and the Trash
 * page reads who deleted a record. Some of those tables are created by the
 * modules themselves the first time they are opened, and the earliest installs
 * were made before deleted_at and deleted_by were part of that definition - so
 * a table could exist without them and every list on it would fail. Rather than
 * fail, the column is added, once, when it is found missing. On a table that
 * already has it this is a single indexed lookup and no change.
 */
function hp_ensure_soft_delete_columns(): void{
 static $done=false;
 if($done) return;
 $done=true;
 $tables=['guests','suppliers','users','inventory_items','inventory_categories','expenses',
  'event_requests','facility_enquiries','news_posts','reservations','purchase_requisitions',
  'purchase_orders','rooms','room_types','customers','orders'];
 foreach($tables as $t){
  hp_ensure_column($t,'deleted_at','deleted_at TIMESTAMP NULL DEFAULT NULL');
  hp_ensure_column($t,'deleted_by','deleted_by BIGINT UNSIGNED NULL');
 }
}

/**
 * The stock and requisition columns a later export left behind.
 *
 * The inventory form writes a unit cost, a requisition line keeps the cost it
 * was raised at, and a refusal keeps its reason. All three columns are used by
 * the pages that own them, so an install whose schema was imported from a dump
 * taken before they were added fails the moment Purchases, Inventory or the
 * Approvals queue opens. They are added once, here, in the same way as the
 * soft-delete columns, so those pages open on an older database too.
 */
function hp_ensure_procurement_columns(): void{
 static $done=false;
 if($done) return;
 $done=true;
 hp_ensure_column('inventory_items','unit_cost','unit_cost DECIMAL(14,2) NOT NULL DEFAULT 0.00');
 hp_ensure_column('purchase_requisitions','decision_reason','decision_reason VARCHAR(255) NULL');
 hp_ensure_column('purchase_requisition_items','est_cost','est_cost DECIMAL(14,2) NOT NULL DEFAULT 0.00');
}

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

/**
 * Who may write in the newsroom, and how much of it.
 *
 * The newsroom is not for everybody, and it is not the same for everybody
 * either. Four roles run it outright: the director, the general manager, the
 * human resource office (which owns vacancies and the employee of the month)
 * and the system administrator - the "computer" desk that keeps the website
 * and the consoles running. Marketing and events write the guest-facing news,
 * updates and opportunities. Every other department carries its own notices:
 * they may publish news and service updates filed under their own department,
 * and nothing more, so a busy house still tells its own small stories without
 * anyone handing over the whole front page.
 *
 * tiers: owner       - every category, every post, pin, schedule and delete
 *        editor      - the named categories, pins, schedules and deletes them
 *        contributor - their own news and updates, filed under their dept
 */
function news_roles(): array{
 return [
  'super_admin'    => ['tier'=>'owner'],
  'director'       => ['tier'=>'owner'],
  'general_manager'=> ['tier'=>'owner'],
  'human_resource' => ['tier'=>'owner'],
  'marketing'      => ['tier'=>'editor','categories'=>['news','update','opportunity']],
  'events_manager' => ['tier'=>'editor','categories'=>['news','update','opportunity']],
  'receptionist'   => ['tier'=>'contributor','department'=>'Front Office','categories'=>['news','update']],
  'housekeeping'   => ['tier'=>'contributor','department'=>'Housekeeping','categories'=>['news','update']],
  'kitchen'        => ['tier'=>'contributor','department'=>'Kitchen','categories'=>['news','update']],
  'waiter'         => ['tier'=>'contributor','department'=>'Food and Beverage','categories'=>['news','update']],
  'bar_staff'      => ['tier'=>'contributor','department'=>'Bar','categories'=>['news','update']],
  'storekeeper'    => ['tier'=>'contributor','department'=>'Stores','categories'=>['news','update']],
  'procurement'    => ['tier'=>'contributor','department'=>'Procurement','categories'=>['news','update']],
  'maintenance'    => ['tier'=>'contributor','department'=>'Maintenance','categories'=>['news','update']],
  'accountant'     => ['tier'=>'contributor','department'=>'Finance','categories'=>['news','update']],
  'cashier'        => ['tier'=>'contributor','department'=>'Finance','categories'=>['news','update']],
 ];
}

/**
 * What the signed-in member may do in the newsroom, or null when the newsroom
 * is not theirs at all. The strongest role a person holds decides the tier, so
 * a director who also carries a shop-floor role is never held back by it.
 *
 * The returned array carries: tier, role, can_all, the categories they may
 * publish (null means every category), the department their posts are filed
 * under, and a label to sign a post with.
 */
function news_capability(): ?array{
 if(!current_user()) return null;
 $map=news_roles();
 $rank=['contributor'=>1,'editor'=>2,'owner'=>3];
 $best=null;
 foreach(roles_of() as $role){
  $p=$map[$role]??null;
  if($p===null) continue;
  if($best===null || ($rank[$p['tier']]??0)>($rank[$best['tier']]??0)) $best=$p+['role'=>$role];
 }
 if($best===null) return null;
 $best['can_all']=$best['tier']==='owner';
 $best['categories']=$best['can_all']?null:($best['categories']??[]);
 $best['department']=$best['department']??null;
 $best['label']=role_label($best['role']);
 return $best;
}

/**
 * Every console page the router will ever open, with the roles allowed to see
 * it. An empty list means the page is open to any signed-in member (their own
 * dashboard, their own profile, their own notifications). This is the single
 * source of truth: the router uses its keys as a whitelist, so a page name that
 * is not on it can never be turned into a file path.
 */
function page_caps(): array{
 return [
  'dashboard'=>[], // own view
  // The bell is every signed-in member's own: they see only their notifications.
  'notifications'=>[], // own
  // Director's full view. The General Manager sits beside the Director on the
  // whole house so nothing about the hotel is ever hidden from the person who
  // runs it day to day.
  'overview'=>['director','general_manager'],
  'integrity'=>['director','general_manager','auditor'],
  'reservations'=>['director','general_manager','receptionist','events_manager'],
  'events'=>['director','general_manager','events_manager','marketing'],
  'news'=>array_keys(news_roles()),
  'rooms'=>['director','general_manager','receptionist','housekeeping','maintenance'],
  'guests'=>['director','general_manager','receptionist'],
  'pos'=>['director','general_manager','cashier','waiter','bar_staff'],
  'fnb'=>['director','general_manager','cashier','waiter','bar_staff'],
  'kitchen'=>['director','general_manager','kitchen'],
  'shifts'=>['director','general_manager','cashier','waiter','bar_staff','housekeeping','maintenance'],
  'inventory'=>['director','general_manager','storekeeper','inventory_manager'],
  'suppliers'=>['director','general_manager','procurement','storekeeper'],
  'purchases'=>['director','general_manager','procurement','storekeeper','inventory_manager','kitchen','housekeeping','maintenance'],
  // Guest communications: the front desk answers what is sent to the house,
  // the kitchen answers what is sent to the kitchen, and management hears both.
  'messages'=>['director','general_manager','receptionist','kitchen'],
  'testimonials'=>['director','general_manager','marketing'],
  'expenses'=>['director','general_manager','accountant'],
  'finance'=>['director','general_manager','accountant','cashier'],
  'invoices'=>['director','general_manager','accountant','cashier','auditor'],
  'approvals'=>['director','general_manager','accountant'],
  'audit'=>['director','general_manager','auditor'],
  'reports'=>['director','general_manager','accountant','auditor'],
  'users'=>['director','general_manager'],
  'trash'=>['director','general_manager'],
  'profile'=>[]
 ];
}

/** The console pages the router may open, in one place. */
function page_names(): array{
 return array_keys(page_caps());
}

function page_allowed(string $page): bool{
 $u=current_user(); if(!$u) return false;
 $r=roles_of();
 if(in_array('super_admin',$r)) return true;
 $map=page_caps();
 if(!array_key_exists($page,$map)) return false;
 $allowed=$map[$page];
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

/** One badge shape, seven tones. Purely presentational: the class carries
 *  the colour so admin.css stays the single place the look is written. */
function badge(string $text,string $tone='grey'): string{
 static $tones=['ok'=>1,'warn'=>1,'bad'=>1,'gold'=>1,'navy'=>1,'blue'=>1,'grey'=>1];
 $t=isset($tones[$tone])?$tone:'grey';
 return '<span class="badge '.e($t).'">'.e($text).'</span>';
}

function payment_methods(): array{ return ['cash'=>'Cash','mtn_momo'=>'Mobile Money','airtel_money'=>'Airtel Money','card'=>'Card','bank'=>'Bank Transfer','other'=>'Other']; }

function role_label(string $r): string{
 $map=['super_admin'=>'Administrator','director'=>'Director','general_manager'=>'General Manager','accountant'=>'Finance','cashier'=>'Cashier','receptionist'=>'Front Desk','waiter'=>'Waiter','bar_staff'=>'Bar Staff','kitchen'=>'Kitchen','storekeeper'=>'Storekeeper','procurement'=>'Procurement','housekeeping'=>'Housekeeping','auditor'=>'Auditor','events_manager'=>'Events Manager','marketing'=>'Marketing','maintenance'=>'Maintenance','human_resource'=>'Human Resource'];
 return $map[$r]??str_replace('_',' ',$r);
}

/* Soft delete ("Trash"): the helpers every module and the router share. */
require_once __DIR__.'/trash.php';