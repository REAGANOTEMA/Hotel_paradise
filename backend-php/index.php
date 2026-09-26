<?php
declare(strict_types=1);
require __DIR__.'/app/bootstrap.php';
require __DIR__.'/app/layout.php';

function pagelogin(): void{
 if($_SERVER['REQUEST_METHOD']==='POST'){
  $email=trim($_POST['email']??'');
  $pass=$_POST['password']??'';
  $u=row('SELECT * FROM users WHERE email=? AND status=\'active\'',[$email]);
  if($u && password_verify($pass,$u['password_hash'])){
   unset($u['password_hash']);
   set_current_user($u);
   $rs=rows('SELECT r.name FROM user_roles ur JOIN roles r ON r.id=ur.role_id WHERE ur.user_id=?',[$u['id']]);
   $_SESSION['roles']=array_column($rs,'name');
   audit('login','user',$u['id']);
   flash('Welcome back, '.$u['name']);
   go('dashboard');
  }
  flash('Incorrect email or password. Please try again.','bad');
 }
  echo '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover"><title>Sign in | Hotel Paradise on the Nile</title>';
  echo '<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@500;600;700&display=swap" rel="stylesheet">';
  echo '<link rel="stylesheet" href="'.BASE.'/assets/admin.css">';
  echo '<link rel="icon" type="image/png" sizes="64x64" href="'.SITE_URL.'/images/logo-64.png">';
  echo '<link rel="apple-touch-icon" href="'.SITE_URL.'/images/logo-192.png"></head><body>';
  echo '<div class="loginWrap"><div class="loginCard">';
  echo '<div class="sideBrand"><img class="sideLogo" src="'.SITE_URL.'/images/logo-256.png" alt="Hotel Paradise on the Nile logo"><span class="sbText"><span>HOTEL PARADISE</span><small>ON THE NILE</small></span></div>';
  if($f=flash_out()){ echo '<div class="flash '.e($f['type']).'">'.e($f['msg']).'</div>'; }
  echo '<h1 style="font-size:26px;color:var(--navy);margin-bottom:4px">Welcome back</h1><p>Sign in to the Hotel Paradise on the Nile management system.</p>';
  echo '<form method="post">';
  echo '<div class="field"><label>Email address</label><input name="email" type="email" required autocomplete="username" autofocus></div>';
  echo '<div class="field"><label>Password</label><input name="password" type="password" required autocomplete="current-password"></div>';
  echo '<button class="btn" style="width:100%;justify-content:center">Sign in</button></form>';
  echo '<div class="demo">Demo accounts, password <b>Paradise2026</b> except the administrator which uses <b>Admin@123</b>.<br>Administrator: <b>admin@hotelparadiseonthenile.info</b><br>Front desk: <b>frontdesk@hotelparadiseonthenile.info</b></div>';
  echo '<div class="demo" style="border:0;margin-top:14px;padding-top:0">Management system by <a href="https://reagansoftinnovation.com" target="_blank" rel="noopener noreferrer" style="color:var(--gold)">Reagansoft Innovation Limited</a></div>';
  echo '</div></div></body></html>';
}

$page=$_GET['page']??'dashboard';

if($page==='login'){ pagelogin(); exit; }
if($page==='logout'){ audit('logout','user',current_user()['id']??null); logout_user(); header('Location: '.BASE.'/index.php?page=login'); exit; }

if(!current_user()){ header('Location: '.BASE.'/index.php?page=login'); exit; }

if(!page_allowed($page)){
 page_head('Not permitted','dashboard');
 echo '<div class="panel"><h2>Access restricted</h2><p class="hint">Your role does not allow access to this module. Contact the administrator if you believe this is a mistake.</p><a class="btn" href="'.BASE.'/index.php?page=dashboard">Back to dashboard</a></div>';
 page_foot(); exit;
}

$mod=__DIR__.'/modules/'.$page.'.php';
if(is_file($mod)){ require $mod; }else{ page_head('Page not found'); echo '<div class="panel"><p>Module not found.</p></div>'; page_foot(); }