<?php
/**
 * Sets a staff account's password from a terminal.
 *
 * The console can already reset a password, under Team and Users, but only for
 * somebody who is signed in. That is no use at all on the first login, or after
 * the last administrator's password is lost, because getting to that page needs
 * the password being reset. This is the way out of that, and the only reason
 * anybody needs phpMyAdmin to sign in.
 *
 * It also refuses to set a password the system would later call weak, because
 * the one thing a reset like this must not do is make the account easier to
 * break than it was.
 *
 * Run it:
 *   php tools/set-password.php admin@hotelparadiseonthenile.info "NewPassword123"
 *
 * The password is taken as an argument rather than asked for, so nothing is
 * echoed to the terminal. It is still an argument, so on a shared machine it is
 * visible in the process list for as long as the command runs; that is the
 * lesser problem next to being locked out, and the alternative of typing it
 * silently is a password that then exists in the shell history.
 */
declare(strict_types=1);

// Changing a password is not something a web request should be able to ask for.
// Nothing in this file would stop it on its own: with no arguments the web SAPI
// leaves $argv undefined and the script died on a fatal error a few lines down
// rather than doing anything, but that is the accident of where the first $argv
// sits, not a decision. The check is deliberate, and it is first.
if(PHP_SAPI!=='cli'){
 http_response_code(403);
 header('Content-Type: text/plain; charset=utf-8');
 exit("Forbidden: set-password.php is a command line tool.\n".
  "Run it as:  php tools/set-password.php <email> <new password>\n");
}

require dirname(__DIR__).'/backend-php/app/bootstrap.php';

$email=trim((string)($argv[1]??''));
$pass=(string)($argv[2]??'');

// --list is answered before the password is demanded, because the question it
// answers is the first one anybody has: which addresses exist at all.
if($email==='--list'){
 printf("%-4s %-44s %-10s %s\n",'id','email','status','roles');
 foreach(rows('SELECT u.id,u.email,u.status,GROUP_CONCAT(r.name ORDER BY r.name) AS roles
   FROM users u
   LEFT JOIN user_roles ur ON ur.user_id=u.id
   LEFT JOIN roles r ON r.id=ur.role_id
   GROUP BY u.id,u.email,u.status
   ORDER BY u.id') as $u){
  printf("%-4s %-44s %-10s %s\n",$u['id'],$u['email'],$u['status'],$u['roles']?:'(none)');
 }
 exit(0);
}

if($email===''||$pass===''){
 fwrite(STDERR,
  "Sets a staff account's password.\n\n".
  "  php tools/set-password.php <email> <new password>\n\n".
  "  php tools/set-password.php --list          show the accounts and their roles\n");
 exit(1);
}

/** The rules the console applies, so a password set here is not a weaker one. */
if(strlen($pass)<8){
 fwrite(STDERR,"The password must be at least 8 characters. The console enforces the same.\n");
 exit(1);
}
if(strlen($pass)>200){
 fwrite(STDERR,"The password must be 200 characters or fewer.\n");
 exit(1);
}

$u=row('SELECT id,email,name,status FROM users WHERE email=?',[$email]);
if(!$u){
 fwrite(STDERR,"No account has the email address \"$email\".\n\n".
  "The sign-in page cannot tell that apart from a wrong password: it says the same\n".
  "thing for both, which is correct behaviour and unhelpful when you are setting up.\n".
  "Run the same command with --list to see the addresses that do exist.\n");
 exit(1);
}

// Hashed the same way the console hashes it, so a password set here and one set
// from the users page are stored identically and neither surprises the other.
q('UPDATE users SET password_hash=? WHERE id=?',[password_hash($pass,PASSWORD_DEFAULT),$u['id']]);
audit('set_password_by_cli','user',$u['id']);

printf("ok   password changed for %s (%s), status %s\n",$u['email'],$u['name'],$u['status']);

// An account left pending or suspended cannot sign in at all, and the message
// is the same "incorrect" one. Saying so here saves the second round of the
// same confusion.
if($u['status']!=='active'){
 printf("warn this account's status is \"%s\". It will keep being refused until it is set to\n",$u['status']);
 printf("     active, under Team and Users in the console.\n");
}

$roles=rows('SELECT r.name FROM user_roles ur JOIN roles r ON r.id=ur.role_id WHERE ur.user_id=?',[$u['id']]);
if(!$roles){
 printf("warn this account has no roles, so it can reach nothing but the dashboard.\n");
}
