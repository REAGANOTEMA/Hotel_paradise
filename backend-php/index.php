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
    echo '<div class="loginWrap"><div id="particles-js" style="position:absolute;inset:0;z-index:1"></div><div class="loginCard" style="z-index:2;position:relative;">';
    echo '<div class="sideBrand"><img class="sideLogo" src="'.SITE_URL.'/images/paradise-logo.png" alt="Hotel Paradise on the Nile logo"><span class="sbText"><span>HOTEL PARADISE</span><small>ON THE NILE</small></span></div>';
  if($f=flash_out()){ echo '<div class="flash '.e($f['type']).'"><span class="noteIco">'.($f['type']==='bad'?'!':'✓').'</span><span>'.e($f['msg']).'</span></div>'; }
  echo '<h1 class="loginTitle">Welcome back</h1><p class="loginSub">Sign in to the Hotel Paradise on the Nile management system.</p>';
  echo '<form method="post" id="loginForm">';
  echo '<div id="emailStep">';
  echo '<div class="field"><label for="emailInput">Email address</label><input id="emailInput" name="email" type="email" required autocomplete="username" autofocus placeholder="Enter your email address"></div>';
  echo '<button type="button" class="btn" onclick="proceedToPassword()">Continue with Email</button>';
  echo '</div>';
  echo '<div id="passwordStep" style="display:none">';
  echo '<div class="loginStepHead"><span><strong>Email:</strong> <span id="emailDisplay"></span></span><button type="button" class="linkish" onclick="backToEmail()">Change email</button></div>';
  echo '<div class="field"><label for="passwordInput">Password</label><input id="passwordInput" name="password" type="password" required autocomplete="current-password" placeholder="Enter your password"></div>';
  echo '<button type="submit" class="btn">Sign in</button>';
  echo '</div>';
  echo '</form>'.PHP_EOL;
  echo '<script>
  function proceedToPassword(){
    const email = document.getElementById("emailInput").value.trim();
    if(!email || !/^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/.test(email)){
      alert("Please enter a valid email address");
      return;
    }
    document.getElementById("emailDisplay").textContent = email;
    document.getElementById("emailStep").style.display = "none";
    document.getElementById("passwordStep").style.display = "block";
    document.getElementById("passwordInput").focus();
  }
  function backToEmail(){
    document.getElementById("passwordStep").style.display = "none";
    document.getElementById("emailStep").style.display = "block";
    document.getElementById("emailInput").focus();
  }
  document.getElementById("loginForm").addEventListener("keydown", function(e){
    if(e.key === "Enter"){
      if(document.getElementById("emailStep").style.display !== "none"){
        e.preventDefault();
        proceedToPassword();
      }
    }
  });
  </script>';
 if(demo_logins_enabled()) echo '';
    echo '<div class="loginCredit">Management system by <a href="https://reagansoftinnovation.com" target="_blank" rel="noopener" rel="noreferrer">Reagansoft Innovation Limited</a></div>';
   echo '</div></div><script src="https://cdn.jsdelivr.net/npm/particles.js@2.0.0/particles.min.js"></script>';
   echo '<script>particlesJS("particles-js",{particles:{number:{value:40,density:{enable:true,value_area:800}},color:{value:"#d4af37"},shape:{type:"circle"},opacity:{value:0.5,random:false},size:{value:2,random:true},line_linked:{enable:true,distance:150,color:"#d4af37",opacity:0.3,width:1},move:{enable:true,speed:1.5,direction:"none",random:false,straight:false,out_mode:"out",bounce:false}},interactivity:{detect_on:"canvas",events:{onhover:{enable:false},onclick:{enable:false}}},retina_detect:true});</script>';
   echo '</body></html>';
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