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
    echo '<div class="sideBrand"><img class="sideLogo" src="'.SITE_URL.'/images/paradise-logo.png" alt="Hotel Paradise on the Nile logo"><span class="sbText" style="text-shadow: 0 2px 10px rgba(0,0,0,0.8)"><span style="color:#ffffff">HOTEL PARADISE</span><small style="color:#d4af37">ON THE NILE</small></span></div>';
  if($f=flash_out()){ echo '<div class="flash '.e($f['type']).'">'.e($f['msg']).'</div>'; }
  echo '<h1 style="font-size:28px;margin-bottom:6px;font-weight:700;background:linear-gradient(135deg,#071A33 0%,#d4af37 100%);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text">Welcome back</h1><p>Sign in to the Hotel Paradise on the Nile management system.</p>';
  echo '<form method="post" id="loginForm">';
  echo '<div id="emailStep">';
  echo '<div class="field"><label>Email address</label><input id="emailInput" name="email" type="email" required autocomplete="username" autofocus placeholder="Enter your email address"></div>';
  echo '<button type="button" class="btn" style="width:100%;justify-content:center" onclick="proceedToPassword()">Continue with Email</button>';
  echo '</div>';
  echo '<div id="passwordStep" style="display:none">';
  echo '<div style="margin-bottom:12px;padding:10px;background:#f8f9fa;border-radius:8px;font-size:13px;color:#666">';
  echo '<strong>Email:</strong> <span id="emailDisplay"></span><br><button type="button" style="background:none;border:none;color:var(--navy);text-decoration:underline;cursor:pointer;padding:4px 0;font-size:12px" onclick="backToEmail()">Change email</button>';
  echo '</div>';
  echo '<div class="field"><label>Password</label><input id="passwordInput" name="password" type="password" required autocomplete="current-password" placeholder="Enter your password"></div>';
  echo '<button type="submit" class="btn" style="width:100%;justify-content:center">Sign in</button>';
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
    echo '<div class="demo" style="border:0;margin-top:14px;padding-top:0">Management system by <a href="https://reagansoftinnovation.com" target="_blank" rel="noopener" rel="noreferrer" style="color:var(--gold)">Reagansoft Innovation Limited</a></div>';
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