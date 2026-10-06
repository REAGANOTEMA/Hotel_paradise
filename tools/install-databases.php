<?php
/**
 * Creates the databases, the MySQL accounts and the schema the site needs, in
 * the order they have to happen in, and then checks the result the way the site
 * checks it.
 *
 * The site is installed from exactly two files, and they are the only SQL in
 * the project: database/sql/hotelpardise_system/hotelpardise_system.sql and
 * database/sql/hotelpardise_website/hotelpardise_website.sql. Each is a
 * complete phpMyAdmin dump - schema and data together - and neither names the
 * database it belongs to, so this points the connection at each in turn.
 *
 * The accounts and the grants are not in the dumps, and a GRANT naming a table
 * cannot be granted before the table exists. So the order still matters:
 * databases, dumps, accounts, grants. Get it out of sequence and the grants
 * silently fail, and the only symptom is the site refusing to connect hours
 * later.
 *
 * It is also the one place that knows the MySQL passwords, and it does not
 * print them. They are read from backend-php/config.php, which is the file the
 * site itself reads and which is not in git, so the two can never drift apart
 * and the secrets never have to be written down twice.
 *
 * ---------------------------------------------------------------------------
 * IT CHECKS ITS OWN PRIVILEGES FIRST, and that is the important part
 * ---------------------------------------------------------------------------
 *
 * Not every MySQL account is allowed to create accounts. A hosting panel hands
 * out an account that may create and fill in one prefixed database and nothing
 * more, and running this as that account dies on
 *
 *   #1227 Access denied; you need (at least one of) the CREATE USER privilege(s)
 *
 * which says nothing about what to do next. The same error appears if the
 * account is this project's own, because it holds GRANT ALL on its one database
 * and that is not the same thing as the right to create MySQL users.
 *
 * So the privileges are read before anything is changed. If they are not
 * enough, this says so in one paragraph and stops having touched nothing,
 * rather than half way through with a password it was never allowed to set. And
 * if the site already reaches both databases with the credentials in config.php,
 * the accounts and grants are already correct, so there is nothing to do and
 * this says that instead of failing.
 *
 * Run it:  php tools/install-databases.php
 *          php tools/install-databases.php --check     (verify, change nothing)
 *
 * It needs a MySQL account that may CREATE DATABASE, CREATE USER and GRANT. On
 * XAMPP that is root with an empty password, which is what it tries first.
 * Elsewhere, give it one through the environment rather than on the command line,
 * so the password does not end up in the shell history or in the process list:
 *
 *   HP_ADMIN_USER=root HP_ADMIN_PASS=... php tools/install-databases.php
 */
declare(strict_types=1);

// This one creates databases, users and grants, so it must never answer to a
// web request. The guard is here, before anything is read or written, rather
// than left to $argv being undefined, which is what actually stopped it when
// somebody loaded it in a browser. That was luck: the moment the first line of
// the script moved off $argv, the same request would have reinstalled the
// databases over the live ones.
if(PHP_SAPI!=='cli'){
 http_response_code(403);
 header('Content-Type: text/plain; charset=utf-8');
 exit("Forbidden: install-databases.php is a command line tool.\n".
  "Run it as:  php tools/install-databases.php\n");
}

$root=dirname(__DIR__);
$checkOnly=in_array('--check',array_slice($argv??[],1),true);

$dbFile=$root.'/backend-php/config.php';
if(!is_readable($dbFile)){
 fwrite(STDERR,"Cannot read backend-php/config.php, so the MySQL passwords are unknown.\n".
  "That file is generated per machine and is not in git. Copy the shape from\n".
  "backend-php/app/bootstrap.php's db_config() and fill in the values.\n");
 exit(1);
}
$cfg=require $dbFile;

/** The only two SQL files there are: [label, path, database, tables, what it holds]. */
$dumps=[
 ['database/sql/hotelpardise_system/hotelpardise_system.sql',
  $root.'/database/sql/hotelpardise_system/hotelpardise_system.sql',
  (string)($cfg['db']['name']??''),100,'the hotel system'],
 ['database/sql/hotelpardise_website/hotelpardise_website.sql',
  $root.'/database/sql/hotelpardise_website/hotelpardise_website.sql',
  (string)($cfg['web_db']['name']??''),36,'the public website'],
];
foreach($dumps as [$rel,$file]){
 if(!is_readable($file)){
  fwrite(STDERR,"Cannot read $rel.\n".
   "Those two dumps are the whole database install; nothing else in the project is SQL.\n");
  exit(1);
 }
}

$adminUser=getenv('HP_ADMIN_USER')?:'root';
$adminPass=getenv('HP_ADMIN_PASS');
if($adminPass===false) $adminPass='';
$host=$cfg['db']['host']?:'127.0.0.1';
$port=(string)($cfg['db']['port']??'');

mysqli_report(MYSQLI_REPORT_OFF);
$admin=@new mysqli($host,$adminUser,$adminPass,'',(int)($port?:3306));
if($admin->connect_errno){
 fwrite(STDERR,"Could not open MySQL on $host as \"$adminUser\": {$admin->connect_error}\n\n".
  "That is the account's own password being wrong, which is a different problem from the\n".
  "one below. On XAMPP it is root with an empty password. Elsewhere, set it in the\n".
  "environment rather than on the command line:\n\n".
  "  HP_ADMIN_USER=root HP_ADMIN_PASS=... php tools/install-databases.php\n");
 exit(1);
}
$admin->set_charset('utf8mb4');

$sysName=$cfg['db']['name'];      $sysUser=$cfg['db']['user'];   $sysPass=$cfg['db']['pass'];
$webName=$cfg['web_db']['name'];  $webUser=$cfg['web_db']['user']; $webPass=$cfg['web_db']['pass'];

/** The site connects from config.php; this connects as the site does. */
function site_can_open(string $host,int $port,string $user,string $pass,string $db,string $label): array{
 $c=@new mysqli($host,$user,$pass,$db,$port);
 if($c->connect_errno) return [false,$c->connect_error];
 $n=@$c->query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE()")->fetch_row()[0];
 $err=$c->error; $c->close();
 return [(int)$n>0,$err!==''?$err:$label.' is open'];
}

/**
 * What this MySQL account is actually allowed to do.
 *
 * Read from SHOW GRANTS rather than assumed, because the two things that are
 * easy to confuse both begin with GRANT ALL: ALL on one database, which is what
 * a hosting panel gives and is not enough to create a user, and ALL on *.*,
 * which is root and is.
 */
function privileges(mysqli $db): array{
 $all=false; $createUser=false; $createDb=false; $scopes=[];
 $r=$db->query('SHOW GRANTS FOR CURRENT_USER');
 if(!$r) return ['all'=>false,'createUser'=>false,'createDb'=>false,'scopes'=>[],'lines'=>[]];
 while($g=$r->fetch_row()){
  $line=(string)$g[0];
  if(!preg_match('/GRANT\s+(.+?)\s+ON\s+(\S+)\s+TO/i',$line,$m)) continue;
  $privs=strtoupper($m[1]); $scope=$m[2];
  // MariaDB gives every account a "GRANT USAGE ON *.*" line whether or not it
  // has any global rights at all. USAGE is the word for "no privileges", so
  // leaving it in would print *.* next to an account that has been given a
  // single database, and send the reader looking for rights that are not there.
  if($privs==='USAGE') continue;
  $scopes[]=$scope;
  $global=($scope==='*.*');
  if($global&&str_contains($privs,'ALL PRIVILEGES')) $all=true;
  if($global&&str_contains($privs,'CREATE USER')) $createUser=true;
  if($global&&str_contains($privs,'CREATE')) $createDb=true;
 }
 return ['all'=>$all,'createUser'=>$createUser||$all,'createDb'=>$createDb||$all,'scopes'=>$scopes,'lines'=>[]];
}

$priv=privileges($admin);

$fail=0; $warn=0; $skipped=0;
function step(string $label,bool $ok,string $detail=''): void{
 global $fail;
 if(!$ok) $fail++;
 printf("%s %s%s\n",$ok?'ok  ':'FAIL',$label,$detail!==''?"  ($detail)":'');
}
function note(string $label,string $detail=''): void{
 global $skipped;
 $skipped++;
 printf("skip %s%s\n",$label,$detail!==''?"  ($detail)":'');
}
function warn(string $label,string $detail=''): void{
 global $warn;
 $warn++;
 printf("warn %s%s\n",$label,$detail!==''?"  ($detail)":'');
}

/** Runs a whole .sql file, statement by statement, on the one connection. */
function run_file(mysqli $db,string $path): void{
 $sql=file_get_contents($path);
 if($sql===false) throw new RuntimeException('cannot read '.basename($path));
 if(!$db->multi_query($sql)) throw new RuntimeException(basename($path).': '.$db->error);
 // Every result has to be read, and thrown away, before the connection can be
 // used again. Stopping early on more_results() is not enough: it goes false on
 // the last statement even when that statement returned rows, and the connection
 // is then left mid-sequence and refuses the next command with "commands out of
 // sync". So each result is fetched and released, and the walk continues while
 // next_result() still has one to give.
 do{
  if($res=$db->store_result()) $res->free();
 }while($db->next_result());
 if($db->errno) throw new RuntimeException(basename($path).': '.$db->error);
}

/** A quoted SQL string literal. The passwords contain ] } ^ and are not plain. */
function lit(mysqli $db,string $v): string{ return "'".$db->real_escape_string($v)."'"; }

// An account is created for localhost and for 127.0.0.1 because MariaDB decides
// which one matches from the address in the connection, and a site whose DSN
// says 127.0.0.1 is entitled to work whether or not it is talking to a socket.
$hosts=['localhost','127.0.0.1'];
$portNum=(int)($port?:3306);

echo "Hotel Paradise on the Nile - database install\n";
echo "as $adminUser on $host".($checkOnly?'   (--check, nothing will be changed)':'')."\n\n";

// Error 1227, "you need (at least one of) the CREATE USER privilege(s)", is the
// single most common way this script fails, and its cause is invisible from the
// error alone: the account is fine, it just is not root, and only root may
// create MySQL accounts on XAMPP. The one thing that turns a working install
// into that error is HP_ADMIN_USER pointing at something else, usually left
// over in the shell from an earlier attempt, so it is called out by name.
if(strcasecmp($adminUser,'root')!==0){
 echo "note HP_ADMIN_USER is set to \"$adminUser\", not root.\n";
 echo "     Only an account with rights on *.* can create MySQL accounts, and this one may\n";
 echo "     not have them. That produces error 1227 further down. On XAMPP this variable is\n";
 echo "     not needed at all: unset it and run the script again with no HP_* variables set.\n\n";
}

// ---------------------------------------------------------------------------
// 1. What can this account do? Asked before anything is touched.
// ---------------------------------------------------------------------------
echo "privileges of $adminUser\n";
printf("     %s\n",$priv['all']?'ALL PRIVILEGES on *.* - can create databases, users and grants'
  :'limited'.($priv['createUser']?' (CREATE USER)':'').($priv['createDb']?' (CREATE)':''));
foreach($priv['scopes'] as $s) echo "     granted on $s\n";
echo "\n";

$sysOk=site_can_open($host,$portNum,$sysUser,$sysPass,$sysName,'the hotel system is open');
$webOk=site_can_open($host,$portNum,$webUser,$webPass,$webName,'the website database is open');
$alreadyWorks=$sysOk[0]&&$webOk[0];

if(!$priv['createUser']&&!$alreadyWorks){
 fwrite(STDERR,
  "\"$adminUser\" may not create MySQL accounts, and the site cannot open its databases,\n".
  "so this cannot be fixed from here. Nothing has been changed.\n\n".
  "Why: error 1227 is what MySQL says when the account running this holds its rights on a\n".
  "database rather than on *.*. A hosting panel's account is like that, and so is this\n".
  "project's own hotelpardise_system account, which holds GRANT ALL on its one database and\n".
  "that is not the same thing as the right to create a user.\n\n".
  "The account has to be created by whoever can create accounts:\n\n".
  "  1. On XAMPP, that is root with an empty password. Run:\n".
  "       php tools/install-databases.php\n\n".
  "  2. On hosting, your control panel creates the MySQL user for you. Create the account,\n".
  "     then put the panel's user name and password in backend-php/config.php, then run this\n".
  "     again. The panel's account usually cannot grant the website user rights on the\n".
  "     hotel's database, which is a second thing only the host can do: ask them for\n".
  "     SELECT on menu_categories, menu_items, room_types, rooms and hotels, plus INSERT on\n".
  "     guests, reservations, reservation_rooms, orders and order_items.\n");
 exit(1);
}

if(!$priv['createUser']){
 note("cannot create MySQL accounts, and the site already reaches both databases",
  'so the accounts and grants are already correct and there is nothing to change');
}

// ---------------------------------------------------------------------------
// 2. The site as it stands, which is the measurement that counts.
// ---------------------------------------------------------------------------
echo "as the site connects, using the passwords in backend-php/config.php\n";
step("the management system can open $sysName",$sysOk[0],$sysOk[0]?'tables visible':$sysOk[1]);
step("the website can open $webName",$webOk[0],$webOk[0]?'tables visible':$webOk[1]);
echo "\n";

if($checkOnly){
 printf("\n%s\n",$alreadyWorks
  ?'the site is installed correctly: both databases open, both accounts work'
  :'the site is NOT working yet. Drop --check to install it.');
 exit($alreadyWorks?0:1);
}

if($alreadyWorks&&!$priv['createUser']){
 echo "install complete - nothing needed changing\n";
 exit(0);
}

// ---------------------------------------------------------------------------
// 3. The install, in the only order that works.
// ---------------------------------------------------------------------------
if(!$priv['createDb']){
 note('cannot create databases',"if $sysName does not exist, the hosting panel must create it");
}else{
 foreach([[$sysName,'the hotel system'],[$webName,'the public website']] as [$n,$what]){
  $ok=@$admin->query("CREATE DATABASE IF NOT EXISTS `".$admin->real_escape_string($n)."`
    CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
  step("create $n, which holds $what",(bool)$ok,$ok?'':$admin->error);
 }
}

// The dumps carry schema and data together, and neither one says which
// database it belongs to, so the connection is pointed at each in turn. A
// phpMyAdmin dump has no DROP TABLE and no CREATE IF NOT EXISTS in it: it can
// only be loaded into an empty database, and a database that already has
// tables is a site being used, whose rows are not this script's to touch.
// The loads come before the grants because a GRANT naming a table cannot be
// granted before the table exists; getting that backwards fails silently and
// leaves the site unable to sign in hours later.
echo "\ndumps\n";
foreach($dumps as [$rel,$file,$dbName,$expected,$what]){
 if($dbName===''){ step("load $rel",false,'no database name for it in backend-php/config.php'); continue; }
 $t=(int)@$admin->query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema="
  .lit($admin,$dbName)." AND table_type='BASE TABLE'")->fetch_row()[0];
 if($t>=$expected){ note("load $rel","$dbName already has $t tables"); continue; }
 if($t>0){
  step("load $rel",false,"$dbName has only $t of the $expected tables, so a load now would stop half way. ".
   "Its rows are left alone; drop the database if you really want it rebuilt from the dump");
  continue;
 }
 if(!@$admin->select_db($dbName)){ step("load $rel",false,$admin->error); continue; }
 try{
  run_file($admin,$file);
  $t=(int)@$admin->query("SELECT COUNT(*) FROM information_schema.tables WHERE table_schema="
   .lit($admin,$dbName)." AND table_type='BASE TABLE'")->fetch_row()[0];
  step("load $rel",$t>=$expected,"$t tables in $dbName");
 }catch(RuntimeException $e){ step("load $rel",false,$e->getMessage()); }
}

echo "\naccounts\n";
foreach([[$sysUser,$sysPass,'the management system'],[$webUser,$webPass,'the public website']] as [$u,$p,$what]){
 foreach($hosts as $h){
  $uq=$admin->real_escape_string($u); $hq=$admin->real_escape_string($h); $pq=lit($admin,$p);
  $ok=@$admin->query("CREATE USER IF NOT EXISTS '$uq'@'$hq' IDENTIFIED BY $pq");
  if($ok) $ok=@$admin->query("ALTER USER '$uq'@'$hq' IDENTIFIED BY $pq");
  step("set the password for '$u'@'$h', which is $what",(bool)$ok,$ok?'':$admin->error);
 }
}
foreach($hosts as $h){
 $ok=@$admin->query("GRANT ALL PRIVILEGES ON `$sysName`.* TO ".lit($admin,$sysUser).'@'.lit($admin,$h));
 step("grant '$sysUser'@'$h' full access to $sysName",(bool)$ok,$ok?'':$admin->error);
}

echo "\ndata\n";
// The dumps arrive with their data already in them, so this only counts. A
// zero here means the load above reported ok and then put nothing in, which
// is worth saying out loud rather than leaving to be found at the first sign
// in attempt.
$haveUsers=0;
try{ $haveUsers=(int)@$admin->query("SELECT COUNT(*) FROM `$sysName`.users")->fetch_row()[0]; }catch(Throwable $e){}
step("$sysName.users has staff to sign in with",$haveUsers>0,"$haveUsers users");
$haveDishes=0;
try{ $haveDishes=(int)@$admin->query("SELECT COUNT(*) FROM `$sysName`.menu_items")->fetch_row()[0]; }catch(Throwable $e){}
step("$sysName.menu_items has the menu",$haveDishes>0,"$haveDishes dishes");

// The website account is granted the published menu and may take a booking, but
// not the hotel's money or guest documents. Only a *.* account can do this,
// because it reaches across into the hotel's database.
echo "\nwebsite account, which reads the published menu and may take a booking\n";
if($priv['all']){
 foreach($hosts as $h){
  $who=lit($admin,$webUser).'@'.lit($admin,$h);
  $ok=@$admin->query("GRANT SELECT, INSERT, UPDATE, DELETE ON `$webName`.* TO $who");
  $ok=$ok&&@$admin->query("GRANT SELECT ON `$sysName`.menu_categories TO $who");
  $ok=$ok&&@$admin->query("GRANT SELECT ON `$sysName`.menu_items TO $who");
  $ok=$ok&&@$admin->query("GRANT SELECT ON `$sysName`.room_types TO $who");
  $ok=$ok&&@$admin->query("GRANT SELECT ON `$sysName`.rooms TO $who");
  $ok=$ok&&@$admin->query("GRANT SELECT ON `$sysName`.hotels TO $who");
  $ok=$ok&&@$admin->query("GRANT SELECT (id, phone, full_name) ON `$sysName`.guests TO $who");
  $ok=$ok&&@$admin->query("GRANT SELECT (booking_number) ON `$sysName`.reservations TO $who");
  $ok=$ok&&@$admin->query("GRANT INSERT ON `$sysName`.guests TO $who");
  $ok=$ok&&@$admin->query("GRANT INSERT ON `$sysName`.reservations TO $who");
  $ok=$ok&&@$admin->query("GRANT INSERT ON `$sysName`.reservation_rooms TO $who");
  $ok=$ok&&@$admin->query("GRANT INSERT ON `$sysName`.orders TO $who");
  $ok=$ok&&@$admin->query("GRANT INSERT ON `$sysName`.order_items TO $who");
  step("grant '$webUser'@'$h' the published menu and booking rights",(bool)$ok,$ok?'':$admin->error);
 }
}else{
 warn("'$webUser' cannot be granted rights on $sysName",
  'only an account with rights on *.* can reach across databases. If the website cannot read the menu, ask the host to add these.');
}

$haveSettings=0;
try{ $haveSettings=(int)@$admin->query("SELECT COUNT(*) FROM `$webName`.website_settings")->fetch_row()[0]; }catch(Throwable $e){}
step("$webName.website_settings has the site's settings",$haveSettings>0,"$haveSettings settings");

@$admin->query('FLUSH PRIVILEGES');

// The check that counts is not the one above, which ran as an account that can
// see anything. It is the one the site makes, with the password the site holds.
echo "\nas the site connects\n";
$sysOk=site_can_open($host,$portNum,$sysUser,$sysPass,$sysName,'the hotel system is open');
$webOk=site_can_open($host,$portNum,$webUser,$webPass,$webName,'the website database is open');
step("the management system can open $sysName",$sysOk[0],$sysOk[0]?'tables visible':$sysOk[1]);
step("the website can open $webName",$webOk[0],$webOk[0]?'tables visible':$webOk[1]);

echo "\n";
if($fail) echo "$fail step(s) failed\n";
if($warn) echo "$warn warning(s)\n";
echo $fail?($warn?'':'')."install incomplete - see the FAIL lines above\n"
 :'install complete - nothing to do on the next run'.($warn?'':'')."\n";
exit($fail?1:0);
