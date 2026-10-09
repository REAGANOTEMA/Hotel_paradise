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

 $flashHtml='';
 if($f=flash_out()){ $flashHtml='<div class="flash '.e($f['type']).'"><span class="noteIco">'.($f['type']==='bad'?'!':'✓').'</span><span>'.e($f['msg']).'</span></div>'; }

 $tpl=<<<'HTML'
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">
<meta name="theme-color" content="#071A33">
<title>Sign in | Hotel Paradise on the Nile</title>
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:ital,wght@0,500;0,600;0,700;1,500&display=swap" rel="stylesheet">
<link rel="stylesheet" href="%%BASE%%/assets/admin.css">
<link rel="icon" type="image/png" sizes="64x64" href="%%SITE%%/images/logo-64.png">
<link rel="apple-touch-icon" href="%%SITE%%/images/logo-192.png">
</head>
<body class="loginBody">
<div class="loginWrap">
  <div class="loginBg" aria-hidden="true"></div>
  <div id="particles-js" class="loginParticles" aria-hidden="true"></div>

  <header class="loginTop">
    <a class="loginBrandTop" href="%%HOME%%" aria-label="Hotel Paradise on the Nile website">
      <img src="%%LOGO%%" alt="Hotel Paradise on the Nile logo">
      <span class="lbtText"><span>HOTEL PARADISE</span><small>ON THE NILE</small></span>
    </a>
    <a class="loginBack" href="%%HOME%%">
      <svg viewBox="0 0 24 24"><path d="M15 5l-7 7 7 7"/></svg>
      <span>Back to website</span>
    </a>
  </header>

  <main class="loginCard">
    <aside class="loginShowcase">
      <div class="lsTop">
        <span class="lsKicker">Jinja &middot; Uganda</span>
        <img class="lsLogo" src="%%LOGO%%" alt="Hotel Paradise on the Nile logo">
        <h2 class="lsName">Hotel Paradise<small>ON THE NILE</small></h2>
        <p class="lsBlurb">A riverside retreat on the banks of the Nile, where warm Ugandan hospitality meets quiet luxury.</p>
        <div class="lsStars" aria-label="Five star standard"><span>&#9733;</span><span>&#9733;</span><span>&#9733;</span><span>&#9733;</span><span>&#9733;</span></div>
      </div>
      <div class="lsMeta">
        <div><b>24/7</b><span>Front desk</span></div>
        <div><b>69</b><span>Rooms</span></div>
        <div><b>05m</b><span>To town</span></div>
      </div>
    </aside>

    <div class="loginPane">
      <span class="loginKicker">Management Suite</span>
      <h1 class="loginTitle">Welcome back</h1>
      <p class="loginSub">Sign in to the Hotel Paradise on the Nile management system.</p>
      %%FLASH%%
      <form method="post" id="loginForm" novalidate>
        <div id="emailStep">
          <div class="field">
            <label for="emailInput">Email address</label>
            <div class="inputWrap">
              <span class="iIco" aria-hidden="true"><svg viewBox="0 0 24 24"><rect x="2.5" y="4.5" width="19" height="15" rx="2.5"/><path d="M3 7l9 6 9-6"/></svg></span>
              <input id="emailInput" name="email" type="email" required autocomplete="username" autofocus placeholder="you@hotelparadise.com">
            </div>
            <small class="fieldErr" id="emailErr" hidden>Please enter a valid email address.</small>
          </div>
          <button type="button" class="btn" onclick="proceedToPassword()">Continue with email</button>
        </div>
        <div id="passwordStep" style="display:none">
          <div class="loginStepHead"><span><strong>Email:</strong> <span id="emailDisplay"></span></span><button type="button" class="linkish" onclick="backToEmail()">Change</button></div>
          <div class="field">
            <label for="passwordInput">Password</label>
            <div class="inputWrap">
              <span class="iIco" aria-hidden="true"><svg viewBox="0 0 24 24"><rect x="4.5" y="10.5" width="15" height="10" rx="2.5"/><path d="M8 10.5V7a4 4 0 0 1 8 0v3.5"/><circle cx="12" cy="15.5" r="1.4"/></svg></span>
              <input id="passwordInput" name="password" type="password" required autocomplete="current-password" placeholder="Enter your password">
              <button type="button" class="pwToggle" id="pwToggle" aria-label="Show password" onclick="togglePassword()"><svg viewBox="0 0 24 24"><path d="M2.5 12S6 5.5 12 5.5 21.5 12 21.5 12 18 18.5 12 18.5 2.5 12 2.5 12z"/><circle cx="12" cy="12" r="3"/></svg></button>
            </div>
          </div>
          <button type="submit" class="btn">Sign in securely</button>
        </div>
      </form>
      <p class="loginSecure"><svg viewBox="0 0 24 24"><path d="M12 3l7 3v5c0 4.4-3 8.2-7 9.5-4-1.3-7-5.1-7-9.5V6z"/><path d="M9.3 12.1l1.9 1.9 3.6-3.8"/></svg> Secured access for authorised Paradise staff</p>
      <div class="loginCredit">Management system by <a href="https://reagansoftinnovation.com" target="_blank" rel="noopener noreferrer">Reagansoft Innovation Limited</a></div>
      <a class="loginHome" href="%%HOME%%"><svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3a14.5 14.5 0 0 1 0 18 14.5 14.5 0 0 1 0-18z"/></svg> Return to the website</a>
    </div>
  </main>

  <footer class="loginFoot">
    <span>&copy; %%YEAR%% Hotel Paradise on the Nile Ltd</span>
    <span class="lfDot" aria-hidden="true"></span>
    <span>Plot 12, 19 &amp; 25 Kiira Lane, Jinja</span>
  </footer>
</div>
<script src="https://cdn.jsdelivr.net/npm/particles.js@2.0.0/particles.min.js"></script>
<script>
  function proceedToPassword(){
    var el=document.getElementById('emailInput'), err=document.getElementById('emailErr');
    var email=el.value.trim();
    if(!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)){
      el.setAttribute('aria-invalid','true'); if(err) err.hidden=false; el.focus(); return;
    }
    el.removeAttribute('aria-invalid'); if(err) err.hidden=true;
    document.getElementById('emailDisplay').textContent=email;
    document.getElementById('emailStep').style.display='none';
    document.getElementById('passwordStep').style.display='block';
    document.getElementById('passwordInput').focus();
  }
  function backToEmail(){
    document.getElementById('passwordStep').style.display='none';
    document.getElementById('emailStep').style.display='block';
    document.getElementById('emailInput').focus();
  }
  function togglePassword(){
    var p=document.getElementById('passwordInput'), b=document.getElementById('pwToggle');
    var show=p.type==='password';
    p.type=show?'text':'password';
    b.setAttribute('aria-label',show?'Hide password':'Show password');
    b.classList.toggle('on',show);
  }
  document.getElementById('loginForm').addEventListener('keydown',function(e){
    if(e.key==='Enter'){
      if(document.getElementById('emailStep').style.display!=='none'){ e.preventDefault(); proceedToPassword(); }
    }
  });
  particlesJS('particles-js',{particles:{number:{value:34,density:{enable:true,value_area:900}},color:{value:'#e0b53a'},shape:{type:'circle'},opacity:{value:0.45,random:true},size:{value:1.8,random:true},line_linked:{enable:true,distance:160,color:'#e0b53a',opacity:0.22,width:1},move:{enable:true,speed:1.1,direction:'none',random:false,straight:false,out_mode:'out',bounce:false}},interactivity:{detect_on:'canvas',events:{onhover:{enable:false},onclick:{enable:false}}},retina_detect:true});
</script>
</body>
</html>
HTML;

 echo str_replace(
  ['%%BASE%%','%%SITE%%','%%HOME%%','%%LOGO%%','%%FLASH%%','%%YEAR%%'],
  [e(BASE),e(SITE_URL),e(SITE_URL.'/'),e(SITE_URL.'/images/paradise-logo.png'),$flashHtml,date('Y')],
  $tpl
 );
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
