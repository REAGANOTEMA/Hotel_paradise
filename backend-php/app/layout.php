<?php
declare(strict_types=1);

require_once __DIR__.'/notify.php';

function nav_items(): array{
 return [
  'dashboard'=>'Dashboard','overview'=>'CEO / Director','reservations'=>'Reservations','rooms'=>'Rooms','guests'=>'Guests',
  'pos'=>'POS and Orders','fnb'=>'Food and Beverage','kitchen'=>'Kitchen','shifts'=>'Shifts','inventory'=>'Inventory','suppliers'=>'Suppliers',
  'purchases'=>'Purchases','expenses'=>'Expenses','finance'=>'Finance','approvals'=>'Approvals',
  'audit'=>'Audit Trail','reports'=>'Reports','users'=>'Team and Users','notifications'=>'Notifications','profile'=>'My Profile'
 ];
}

/** The rail, in groups. Every group and every link is dropped when the
 *  signed-in member is not allowed to open that module, so each person
 *  sees only their own console. */
function nav_groups(): array{
 return [
  ['label'=>'Front desk','items'=>[
    'dashboard'=>'Dashboard','overview'=>'CEO / Director','reservations'=>'Reservations','rooms'=>'Rooms','guests'=>'Guests']],
  ['label'=>'Food and beverage','items'=>[
    'pos'=>'POS and Orders','fnb'=>'Food and Beverage','kitchen'=>'Kitchen']],
  ['label'=>'Operations','items'=>[
    'shifts'=>'Shifts','inventory'=>'Inventory','suppliers'=>'Suppliers','purchases'=>'Purchases','expenses'=>'Expenses']],
  ['label'=>'Finance and control','items'=>[
    'finance'=>'Finance','approvals'=>'Approvals','reports'=>'Reports','audit'=>'Audit Trail']],
   ['label'=>'Administration','items'=>[
     'users'=>'Team and Users','notifications'=>'Notifications','profile'=>'My Profile']],
 ];
}

/** One 24px stroke icon per module. Kept in a single place so the rail,
 *  the header menu and the KPI cards all draw the same hand. */
function svg_icon(string $name): string{
 $p=[
  'grid'=>'<rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/>',
  'chart'=>'<path d="M21.2 15.9A10 10 0 1 1 8 2.8"/><path d="M22 12A10 10 0 0 0 12 2v10z"/>',
  'calendar'=>'<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 11h18"/>',
  'bed'=>'<path d="M2 19v-9a2 2 0 0 1 2-2h16a2 2 0 0 1 2 2v9"/><path d="M2 15h20"/><path d="M6 10V7a2 2 0 0 1 2-2h8a2 2 0 0 1 2 2v3"/>',
  'users'=>'<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.87"/><path d="M16 3.13a4 4 0 0 1 0 7.75"/>',
  'cart'=>'<circle cx="9" cy="20" r="1.6"/><circle cx="18" cy="20" r="1.6"/><path d="M2 3h3l2.4 11.2a2 2 0 0 0 2 1.6h8.5a2 2 0 0 0 2-1.55L21.5 7H6"/>',
  'fork'=>'<path d="M6 2v7a2.5 2.5 0 0 0 2.5 2.5h0V22"/><path d="M4 2v5M8.5 2v5"/><path d="M17 2c2.4 2.6 2.6 7.5.4 10.4V22"/>',
  'pot'=>'<path d="M4 10h16v6a4 4 0 0 1-4 4H8a4 4 0 0 1-4-4v-6z"/><path d="M2 10h20"/><path d="M9.5 6.5c0-1.4 1.2-1.4 1.2-3M14 6.5c0-1.4 1.2-1.4 1.2-3"/>',
  'clock'=>'<circle cx="12" cy="12" r="9"/><path d="M12 7v5.2l3.2 1.9"/>',
  'box'=>'<path d="M21 8.5l-9-5-9 5v7l9 5 9-5v-7z"/><path d="M3 8.5l9 5 9-5"/><path d="M12 13.5v9"/>',
  'truck'=>'<path d="M1.5 4.5h14v11h-14z"/><path d="M15.5 9h4l3 3.2v3.3h-7z"/><circle cx="5.5" cy="18" r="2.2"/><circle cx="18" cy="18" r="2.2"/>',
  'bag'=>'<path d="M6 2L3 6.2V21a1.8 1.8 0 0 0 1.8 1.8h14.4A1.8 1.8 0 0 0 21 21V6.2L18 2z"/><path d="M3 6.2h18"/><path d="M16 10a4 4 0 0 1-8 0"/>',
  'receipt'=>'<path d="M5.5 2.5h13v19l-3.2-2-2.1 2-2.2-2-2.1 2-3.4-2z"/><path d="M9 8h6M9 12h6M9 16h4"/>',
  'coins'=>'<ellipse cx="12" cy="6" rx="7.5" ry="3.2"/><path d="M4.5 6v5c0 1.8 3.4 3.2 7.5 3.2s7.5-1.4 7.5-3.2V6"/><path d="M4.5 11v5c0 1.8 3.4 3.2 7.5 3.2s7.5-1.4 7.5-3.2v-5"/>',
  'trend'=>'<polyline points="22 7 13.5 15.5 8.5 10.5 2 17"/><polyline points="16 7 22 7 22 13"/>',
  'check'=>'<path d="M21.8 11.1V12a9.8 9.8 0 1 1-5.8-8.9"/><polyline points="21.5 5 12 14.5 9.2 11.7"/>',
  'file'=>'<path d="M14 2.5H6.5a2 2 0 0 0-2 2v15a2 2 0 0 0 2 2h11a2 2 0 0 0 2-2V8z"/><polyline points="14 2.5 14 8 19.5 8"/><path d="M15.5 13.5h-7M15.5 17h-7"/>',
  'bars'=>'<path d="M6 20v-5M12 20V8M18 20v-9"/><path d="M3 20.5h18"/>',
  'user'=>'<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
  'globe'=>'<circle cx="12" cy="12" r="9"/><path d="M3 12h18"/><path d="M12 3a14.5 14.5 0 0 1 0 18 14.5 14.5 0 0 1 0-18z"/>',
  'logout'=>'<path d="M9.5 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4.5"/><polyline points="16 17 21 12 16 7"/><path d="M21 12H9"/>',
  'bell'=>'<path d="M18 8.5a6 6 0 1 0-12 0c0 6-2.5 7.5-2.5 7.5h17S18 14.5 18 8.5z"/><path d="M13.7 20a2 2 0 0 1-3.4 0"/>',
  'alert'=>'<path d="M12 3.5L2.5 20h19z"/><path d="M12 10v4.2M12 17.2v.1"/>',
  'wallet'=>'<path d="M20 7.5V6a2 2 0 0 0-2-2H5.5A2.5 2.5 0 0 0 3 6.5v11A2.5 2.5 0 0 0 5.5 20H19a2 2 0 0 0 2-2v-8.5a2 2 0 0 0-2-2H5"/><circle cx="16.5" cy="14" r="1.2"/>',
  'plate'=>'<circle cx="12" cy="12" r="9"/><circle cx="12" cy="12" r="4.5"/>',
  'spark'=>'<path d="M12 3l1.9 5.4L19.5 10l-5.6 1.7L12 17l-1.9-5.3L4.5 10l5.6-1.6z"/>',
 ];
 $d=$p[$name]??$p['grid'];
 return '<svg viewBox="0 0 24 24" aria-hidden="true">'.$d.'</svg>';
}

/** Which icon a KPI card asks for, read off the label it was given, so
 *  no module has to pass one. */
function kpi_icon(string $label): string{
 $map=[
  '/arrival|check.?in/i'=>'calendar','/depart|check.?out/i'=>'logout','/in house|occupan/i'=>'bed',
  '/room/i'=>'bed','/reservation|booking/i'=>'calendar','/guest|customer|member/i'=>'users',
  '/revenue|payment|amount|money|sales|collection|total/i'=>'coins','/price|rate|tariff/i'=>'trend',
  '/approval|pending|awaiting/i'=>'check','/stock|reorder|level/i'=>'box','/inventory|item/i'=>'box',
  '/order|pass|cook|meal|dish/i'=>'pot','/table|cover/i'=>'plate','/shift|hour|time/i'=>'clock',
  '/expense|cost|bill/i'=>'wallet','/purchase|requisition/i'=>'bag','/supplier|deliver/i'=>'truck',
  '/audit|trail|log/i'=>'file','/report|chart|analy/i'=>'bars','/task|alert|issue|risk/i'=>'alert',
  '/balance|cash|profit|income/i'=>'trend','/team|user|staff/i'=>'users',
 ];
 foreach($map as $re=>$ico){ if(preg_match($re,$label)) return $ico; }
 return 'spark';
}

/** The two letters in the roundel beside a name: the initials off the
 *  record, never anything guessed from the email. */
function initials(?string $name): string{
 $w=preg_split('/\s+/',trim((string)$name))?:[];
 $s='';
 foreach($w as $x){ if($x!=='') $s.=mb_strtoupper(mb_substr($x,0,1)); if(mb_strlen($s)>=2) break; }
 return $s!==''?$s:'HP';
}

function page_head(string $title,string $active='dashboard',string $sub=''): void{
 $u=current_user();
 $flash=flash_out();
 $me=$u['name']??'';
 $role=role_label(roles_of()[0]??'');
 echo '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1,viewport-fit=cover">';
 echo '<title>'.e($title).' | Hotel Paradise on the Nile</title>';
 echo '<link rel="preconnect" href="https://fonts.googleapis.com">';
 echo '<link href="https://fonts.googleapis.com/css2?family=DM+Sans:wght@400;500;600;700&family=Playfair+Display:wght@500;600;700&display=swap" rel="stylesheet">';
 echo '<link rel="stylesheet" href="'.BASE.'/assets/admin.css">';
 echo '<link rel="icon" type="image/png" sizes="64x64" href="'.SITE_URL.'/images/logo-64.png">';
 echo '<link rel="apple-touch-icon" href="'.SITE_URL.'/images/logo-192.png">';
 echo '</head><body><div class="app">';

 echo '<a class="skipLink" href="#mainContent">Skip to content</a>';
 echo '<div class="sideScrim" id="sideScrim" hidden></div>';

 /* ---- the rail ---- */
 echo '<aside class="side" id="side">';
 echo '<a class="sideBrand" href="'.BASE.'/index.php?page=dashboard"><img class="sideLogo" src="'.SITE_URL.'/images/paradise-logo.png" alt="Hotel Paradise on the Nile logo"><span class="sbText"><span>HOTEL PARADISE</span><small>ON THE NILE</small></span></a>';
 echo '<button class="sideClose" id="sideClose" type="button" aria-label="Close menu"><span></span><span></span></button>';
 echo '<nav class="sideNav" aria-label="Modules">';
 foreach(nav_groups() as $g){
  $open=array_filter(array_keys($g['items']),static fn(string $k): bool=>page_allowed($k));
  if(!$open) continue;
  echo '<div class="sideGroup"><p class="sideLabel">'.e($g['label']).'</p>';
  foreach($g['items'] as $k=>$lbl){
   if(!page_allowed($k)) continue;
   $on=$k===$active?' class="on"':'';
   $cur=$k===$active?' aria-current="page"':'';
   echo '<a href="'.BASE.'/index.php?page='.$k.'"'.$on.$cur.'><span class="ico">'.svg_icon(nav_icon_key($k)).'</span><span class="lbl">'.e($lbl).'</span></a>';
  }
  echo '</div>';
 }
 echo '</nav>';
 echo '<div class="sideProfile"><a class="avatar" href="'.BASE.'/index.php?page=profile" aria-label="My profile">'.e(initials($me)).'</a>';
 echo '<span class="sideWho"><b>'.e($me).'</b><small>'.e($role).'</small></span>';
 echo '<a class="sideSignOut" href="'.BASE.'/index.php?page=logout" title="Sign out" aria-label="Sign out">'.svg_icon('logout').'</a></div>';
 echo '<div class="sideFoot"><a href="'.SITE_URL.'/" target="_blank" rel="noopener">Open website</a>';
 echo '<button class="sideShrink" id="sideShrink" type="button" aria-label="Collapse menu" title="Collapse menu"><svg viewBox="0 0 24 24" aria-hidden="true"><polyline points="13 6 19 12 13 18"/><path d="M5 5v14"/></svg></button>';
 echo '</div></aside>';

 /* ---- the header ---- */
 echo '<div class="main" id="mainContent"><header class="top">';
 echo '<button class="sideToggle" id="sideToggle" type="button" aria-label="Open menu" aria-controls="side" aria-expanded="false"><span></span><span></span><span></span></button>';
 echo '<div class="topTitles"><h1 class="pageTitle">'.e($title).'</h1>'.($sub?'<p class="pageSub">'.e($sub).'</p>':'').'</div>';
 echo '<div class="topRight">';
 /* The bell is the same feed as the notifications page: a member sees their
    own events, never anyone else's. It is drawn only when the tables exist. */
 if(notify_ready()){
  $nUnread=notify_unread((int)($u['id']??0));
  $nItems=notify_list((int)($u['id']??0),6);
  echo '<div class="notifyWrap">';
  echo '<button class="notifyBtn" id="notifyBtn" type="button" aria-haspopup="true" aria-expanded="false" aria-controls="notifyMenu" aria-label="Notifications'.($nUnread?' ('.$nUnread.' unread)':'').'">';
  echo svg_icon('bell');
  echo '<span class="notifyBadge" id="notifyBadge"'.($nUnread?'':' hidden').'>'.($nUnread>99?'99+':(int)$nUnread).'</span>';
  echo '</button>';
  echo '<div class="notifyMenu" id="notifyMenu" hidden>';
  echo '<div class="menuHead"><b>Notifications</b><small>'.($nUnread?$nUnread.' unread':'You are up to date').'</small></div>';
  echo '<div class="notifyFeed" id="notifyFeed">';
  if($nItems===[]){ echo '<p class="notifyEmpty">Nothing yet. Bookings, orders and payments will appear here.</p>'; }
  else{
   foreach($nItems as $n){
    $un=$n['read_at']===null?' unread':'';
    echo '<a class="notifyItem'.$un.'" href="'.BASE.'/index.php?page=notifications" data-id="'.(int)$n['id'].'">';
    echo '<span class="nIco">'.svg_icon($n['type']==='payment'?'coins':($n['type']==='order'?'pot':($n['type']==='booking'?'calendar':'bell'))).'</span>';
    echo '<span class="nTxt"><b>'.e($n['title']).'</b><small>'.e($n['body']).'</small><time>'.e(fmtdt($n['created_at'])).'</time></span>';
    echo '</a>';
   }
  }
  echo '</div>';
  echo '<a class="notifyAll" href="'.BASE.'/index.php?page=notifications">View all notifications</a>';
  echo '</div></div>';
 }
 echo '<button class="profBtn" id="profBtn" type="button" aria-haspopup="true" aria-expanded="false" aria-controls="profMenu">';
 echo '<span class="avatar">'.e(initials($me)).'</span>';
 echo '<span class="whoWrap"><span class="who">'.e($me).'</span><span class="whoRole">'.e($role).'</span></span>';
 echo '<svg class="chev" viewBox="0 0 24 24" aria-hidden="true"><polyline points="6 9 12 15 18 9"/></svg>';
 echo '</button>';
 echo '<div class="profMenu" id="profMenu" hidden>';
 echo '<div class="menuHead"><b>'.e($me).'</b><small>'.e($role).' &middot; '.e($u['email']??'').'</small></div>';
 echo '<a href="'.BASE.'/index.php?page=profile">'.svg_icon('user').'My profile</a>';
 echo '<a href="'.SITE_URL.'/" target="_blank" rel="noopener">'.svg_icon('globe').'Open website</a>';
 echo '<a class="danger" href="'.BASE.'/index.php?page=logout">'.svg_icon('logout').'Sign out</a>';
 echo '</div></div></header>';

 /* ---- what the last action left behind, as a notification ---- */
 if($flash){
  $ico=$flash['type']==='bad'?'!':($flash['type']==='warn'?'!':'✓');
  echo '<div class="toastWrap" id="toasts"><div class="toast '.e($flash['type']).'" role="status"><span class="noteIco">'.$ico.'</span><span>'.e($flash['msg']).'</span><button type="button" aria-label="Dismiss">&times;</button></div></div>';
 }
 echo '<div class="content">';
}

/** The icon a module carries in the rail. */
function nav_icon_key(string $page): string{
 $map=['dashboard'=>'grid','overview'=>'chart','reservations'=>'calendar','rooms'=>'bed','guests'=>'users',
  'pos'=>'cart','fnb'=>'fork','kitchen'=>'pot','shifts'=>'clock','inventory'=>'box','suppliers'=>'truck',
  'purchases'=>'bag','expenses'=>'receipt','finance'=>'coins','approvals'=>'check','audit'=>'file',
  'reports'=>'bars','users'=>'users','notifications'=>'bell','profile'=>'user'];
 return $map[$page]??'grid';
}

/**
 * One small script for the whole console. It gives the rail a drawer on a
 * narrow screen, the header a member menu, the rail a remembered collapsed
 * state, dismissible notifications, and wraps every data table in a scroll
 * box so a wide report never pushes the page sideways on a phone.
 */
function page_scripts(): void{
 echo <<<'HTML'
<script>
(function(){
  var side=document.getElementById('side'),scrim=document.getElementById('sideScrim'),
      open=document.getElementById('sideToggle'),close=document.getElementById('sideClose');
  function set(on){
    if(!side)return;
    side.classList.toggle('open',on);
    document.body.classList.toggle('navOpen',on);
    if(open)open.setAttribute('aria-expanded',on?'true':'false');
    if(scrim)scrim.hidden=!on;
  }
  if(open)open.addEventListener('click',function(){set(!side.classList.contains('open'))});
  if(close)close.addEventListener('click',function(){set(false)});
  if(scrim)scrim.addEventListener('click',function(){set(false)});
  document.addEventListener('keydown',function(e){if(e.key==='Escape')set(false)});
  var wide=window.matchMedia('(min-width:1081px)');
  var onWide=function(e){if(e.matches)set(false)};
  if(wide.addEventListener)wide.addEventListener('change',onWide);else if(wide.addListener)wide.addListener(onWide);

  /* the member menu in the header */
  var pb=document.getElementById('profBtn'),pm=document.getElementById('profMenu');
  if(pb&&pm){
    var setProf=function(on){pb.setAttribute('aria-expanded',on?'true':'false');pm.hidden=!on;};
    pb.addEventListener('click',function(e){e.stopPropagation();setProf(pm.hidden)});
    document.addEventListener('click',function(e){if(!pm.hidden&&!pm.contains(e.target))setProf(false)});
    document.addEventListener('keydown',function(e){if(e.key==='Escape')setProf(false)});
  }

     document.addEventListener('keydown',function(e){if(e.key==='Escape')setProf(false)});
   }

  /* the bell: the same feed the notifications page shows, refreshed quietly.
     It never blocks the page and gives up silently if the network is gone. */
  var nb=document.getElementById('notifyBtn'),nm=document.getElementById('notifyMenu');
  if(nb&&nm){
    var badge=document.getElementById('notifyBadge'),feed=document.getElementById('notifyFeed');
    var esc=function(s){return String(s==null?'':s).replace(/[&<>"]/g,function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]})};
    var setB=function(on){nb.setAttribute('aria-expanded',on?'true':'false');nm.hidden=!on};
    var paint=function(d){
      if(!d||!d.ok)return;
      if(badge){badge.textContent=d.unread>99?'99+':d.unread;badge.hidden=d.unread<=0}
      if(feed&&d.items){
        feed.innerHTML=d.items.map(function(n){
          return '<a class="notifyItem'+(n.read?'':' unread')+'" href="index.php?page=notifications" data-id="'+n.id+'">'
            +'<span class="nTxt"><b>'+esc(n.title)+'</b><small>'+esc(n.body)+'</small><time>'+esc(n.when)+'</time></span></a>';
        }).join('')||'<p class="notifyEmpty">Nothing yet. Bookings, orders and payments will appear here.</p>';
      }
    };
    var load=function(){fetch('notify_api.php?act=feed',{credentials:'same-origin'}).then(function(r){return r.json()}).then(paint).catch(function(){})};
    nb.addEventListener('click',function(e){e.stopPropagation();var on=nm.hidden;setB(on);if(on)load()});
    document.addEventListener('click',function(e){if(!nm.hidden&&!nm.contains(e.target)&&!nb.contains(e.target))setB(false)});
    document.addEventListener('keydown',function(e){if(e.key==='Escape')setB(false)});
    load();
    setInterval(function(){if(!document.hidden)load()},60000);
  }

  /* the rail remembers whether it was left collapsed */
  var sc=document.getElementById('sideShrink');
  if(sc){
    var apply=function(on){
      document.body.classList.toggle('sideCollapsed',on);
      sc.setAttribute('aria-label',on?'Expand menu':'Collapse menu');
      sc.setAttribute('title',on?'Expand menu':'Collapse menu');
    };
    try{if(localStorage.getItem('hpn_side')==='1')apply(true)}catch(e){}
    sc.addEventListener('click',function(){
      var on=!document.body.classList.contains('sideCollapsed');
      apply(on);
      try{localStorage.setItem('hpn_side',on?'1':'0')}catch(e){}
    });
  }

   /* notifications: any "ok" note leaves on its own, a warning or an error
      stays until it is read and dismissed */
   var dismiss=function(t){
     if(!t||t.dataset.gone)return;
     t.dataset.gone='1';
     t.classList.add('toastOut');
     setTimeout(function(){if(t.parentNode)t.parentNode.removeChild(t)},300);
   };
   Array.prototype.forEach.call(document.querySelectorAll('#toasts .toast'),function(t){
     var x=t.querySelector('button');
     if(x)x.addEventListener('click',function(){dismiss(t)});
     if(!t.classList.contains('bad')&&!t.classList.contains('warn')){
       setTimeout(function(){dismiss(t)},6000);
     }
   });

   /* lightweight submit loading state - adds .loading to the submitting button */
   document.addEventListener('submit', function(e){
     var frm=e.target;
     if(!frm) return;
     var btn=frm.querySelector('button[type=submit],input[type=submit]');
     if(btn && !btn.disabled){
       btn.classList.add('loading');
       btn.setAttribute('aria-busy','true');
       setTimeout(function(){
         if(btn.parentNode){
           btn.classList.remove('loading');
           btn.removeAttribute('aria-busy');
         }
       }, 8000);
     }
   }, true);

  document.querySelectorAll('table.tbl').forEach(function(t){
    if(t.parentNode&&t.parentNode.classList.contains('tableScroll'))return;
    var w=document.createElement('div');w.className='tableScroll';
    t.parentNode.insertBefore(w,t);w.appendChild(t);
  });
})();
</script>
HTML;
}

function page_foot(): void{
 echo '</div></div></div>';
 page_scripts();
 echo '</body></html>';
}

function kpi_card(string $label,string $value,string $hint='',string $tone='navy'): void{
  $cards=['navy'=>'#0f2850','gold'=>'#b08d1a','green'=>'#2e7d32','red'=>'#c62828','blue'=>'#0B5D78','ok'=>'#2e7d32','warn'=>'#b26a00'];
  $t = strtolower($tone);
  $k = $cards[$t] ?? $cards['navy'];
  echo '<div class="kpi" style="--k:'.$k.'">'
   .'<span class="kpiIco">'.svg_icon(kpi_icon($label)).'</span>'
   .'<div class="kpiLbl">'.e($label).'</div><div class="kpiVal">'.$value.'</div>'
   .($hint?'<div class="kpiHint">'.e($hint).'</div>':'').'</div>';
}

function filter_bar(string $extra=''): void{
 echo '<div class="toolbar">'.$extra.'</div>';
}

/** The room a panel leaves empty, drawn so it reads as designed rather
 *  than unfinished. */
function empty_state(string $title,string $text=''): void{
 echo '<div class="emptyState"><span class="esIco">'.svg_icon('plate').'</span><h3>'.e($title).'</h3>'
  .($text?'<p>'.e($text).'</p>':'').'</div>';
}

function status_badge(string $status, bool $neutral=false): string{
 $tones=['available'=>'ok','confirmed'=>'blue','checked_in'=>'gold','checked_out'=>'grey','cancelled'=>'bad','no_show'=>'bad','pending'=>'warn','paid'=>'ok','open'=>'gold','successful'=>'ok','accepted'=>'blue','reserved'=>'warn','occupied'=>'gold','dirty'=>'bad','cleaning'=>'blue','inspected'=>'ok','maintenance'=>'grey','out_of_service'=>'grey','approved'=>'ok','rejected'=>'bad','served'=>'ok','preparing'=>'warn','ready'=>'blue'];
 return badge(str_replace('_',' ',$status),$tones[$status]??'grey');
}

function checked(string $v,string $c): string{ return $v===$c?' checked':''; }
function sel(array $opts,string $v): string{ return isset($opts[$v]); }

function form_open(string $page,string $action='',array $extra=[]): void{
 $qs=array_merge(['page'=>$page,'act'=>$action?:''],$extra);
 echo '<form method="post" action="'.BASE.'/index.php?'.http_build_query($qs).'">';
}
function form_close(): void{ echo '</form>'; }

function back_button(string $label='Back'): void{
 echo '<a class="btnGhost sm" href="javascript:history.back()">'.e($label).'</a>';
}

/* ==================================================================
   THE PAPER A DASHBOARD PRINTS ON

   Three of these dashboards print: the kitchen prints a docket, food
   and beverage prints a bill, the director's page prints an order or a
   guest statement. They all work the same way, and it is worth saying
   once why.

   A receipt is handed to receipt_template() as HTML inside a <template>
   element, which the browser keeps out of the layout entirely: it is
   not drawn, it is not in the accessibility tree, and it is not printed
   until something asks for it. receipt_print() then does four jobs:

     1. On the first load of a page, any receipt marked fresh prints
        itself. That is what makes a docket come off the printer as an
        order lands, without anybody touching the screen.
     2. What has been printed is remembered in local storage under
        $key, so the screen refreshes itself every few seconds without
        reprinting yesterday's tickets.
     3. A Print button calls printReceipt(id), which puts exactly that
        one sheet on the paper.
     4. If the module passes a feed address, the page asks it every
        fifteen seconds whether an order exists that this screen has
        not drawn yet, and reloads when one does. The reload draws it,
        and rule 1 prints it.

   The printing itself is one class on <body>: while it is there, the
   console is hidden and the sheet is the only thing on the page.
   ================================================================== */

/** The guest a web order was placed by, read out of the note the site wrote. */
function order_customer(?string $note): ?array{
 if($note===null||$note==='') return null;
 if(!preg_match('/^Web takeaway order from (.+?),\s*([+\d][0-9\s]{6,})/u',$note,$m)) return null;
 return ['name'=>trim($m[1]),'phone'=>trim($m[2])];
}

/** What is left of a line note once the guest's name and number are taken off. */
function prep_note(?string $note): string{
 if($note===null||$note==='') return '';
 if(strpos($note,'Web takeaway order from ')!==0) return trim($note);
 $rest=substr($note,strlen('Web takeaway order from '));
 $parts=preg_split('/\s+-\s+/',$rest,2);
 return isset($parts[1])?trim($parts[1],". \t\n\r"):'';
}

/**
 * The contact details a web order carried: email, the address it is to be
 * delivered to, and any note the guest left. Every field is optional, so a
 * console reading an order from a database that has not run the upgrade gets
 * blanks rather than an error and simply shows what it has.
 */
function order_delivery(?array $order): array{
 $out=['email'=>'','address'=>'','notes'=>''];
 if(!is_array($order)) return $out;
 $out['email']=trim((string)($order['customer_email']??''));
 $out['address']=trim((string)($order['delivery_address']??''));
 $out['notes']=trim((string)($order['delivery_notes']??''));
 return $out;
}

/**
 * One sheet of paper.
 *
 * $kind     what the paper is called, in the bar across the top
 * $number   the reference printed large
 * $meta     label/value pairs printed under it: table, time, outlet, guest
 * $lines    each with name, qty, note and amount (amount may be null)
 * $totals   label/value pairs at the foot: subtotal, service, total
 * $foot     the line under the totals, or null
 */
function receipt_sheet(array $r): string{
 $h='<div class="sheet">';
 $h.='<div class="sheetBar">'.e($r['kind']??'RECEIPT').'</div>';
 $h.='<div class="sheetHotel"><b>HOTEL PARADISE ON THE NILE</b><span>Jinja &middot; Uganda &middot; +256 759 504 928</span></div>';
 if(isset($r['number'])) $h.='<div class="sheetNo">'.e($r['number']).'</div>';
 if(!empty($r['meta'])){
  $h.='<div class="sheetMeta">';
  foreach($r['meta'] as $k=>$v){ if($v===null||$v==='') continue; $h.='<span><i>'.e($k).'</i>'.e($v).'</span>'; }
  $h.='</div>';
 }
 if(!empty($r['lines'])){
  $h.='<div class="sheetLines">';
  foreach($r['lines'] as $l){
   $h.='<div class="sheetLine"><b>'.e($l['name']??'').'</b>';
   if(isset($l['qty'])&&$l['qty']!=='') $h.='<span class="q">'.e($l['qty']).'</span>';
   if(!empty($l['note'])) $h.='<em>'.e($l['note']).'</em>';
   if(array_key_exists('amount',$l)&&$l['amount']!==null) $h.='<span class="a">'.e($l['amount']).'</span>';
   $h.='</div>';
  }
  $h.='</div>';
 }
 if(!empty($r['totals'])){
  $h.='<div class="sheetTotals">';
  foreach($r['totals'] as $t){
   // Each row is [label, value] or [label, value, 'big']. The label and the
   // figure are written separately because a receipt rules between them.
   $label=(string)($t[0]??$t['label']??'');
   $value=(string)($t[1]??$t['value']??'');
   $big=!empty($t[2])||!empty($t['big']);
   $h.='<span class="'.($big?'big':'').'">'.e($label).'</span><b class="'.($big?'big':'').'">'.e($value).'</b>';
  }
  $h.='</div>';
 }
 if(!empty($r['foot'])) $h.='<div class="sheetFoot">'.$r['foot'].'</div>';
 $h.='<div class="sheetCut">Thank you &middot; Hotel Paradise on the Nile</div>';
 $h.='</div>';
 return $h;
}

/** One sheet, waiting in the wings. $fresh means this one prints itself. */
function receipt_template($id,string $html,bool $fresh=false): void{
 echo '<template data-receipt="'.e((string)$id).'"'.($fresh?' data-new="1"':'').'>'.$html.'</template>';
}

/** The printer: prints, remembers, and watches for work this screen has not drawn. */
function receipt_print(string $key,string $feed=''): void{
 echo '<div id="printStack" aria-hidden="true"></div>';
 $keyJs=json_encode('hpn_printed_'.$key);
 $feedJs=json_encode($feed);
 echo <<<HTML
<script>
(function(){
 var KEY={$keyJs},FEED={$feedJs},store={};
 try{store=JSON.parse(localStorage.getItem(KEY)||'{}')||{}}catch(e){store={}}
 var tpl=[].slice.call(document.querySelectorAll('template[data-receipt]'));
 function go(list){
  if(!list.length)return;
  var s=document.getElementById('printStack');if(!s)return;
  s.innerHTML='';
  list.forEach(function(t){s.appendChild(t.content.cloneNode(true))});
  document.body.classList.add('printing');
  try{window.print()}catch(e){}
  list.forEach(function(t){store[t.getAttribute('data-receipt')]=1});
  try{localStorage.setItem(KEY,JSON.stringify(store))}catch(e){}
 }
 window.printReceipt=function(id){go(tpl.filter(function(t){return t.getAttribute('data-receipt')===String(id)}))};
 window.addEventListener('afterprint',function(){
  document.body.classList.remove('printing');
  var s=document.getElementById('printStack');if(s)s.innerHTML='';
 });
 var fresh=tpl.filter(function(t){return t.getAttribute('data-new')==='1'&&!store[t.getAttribute('data-receipt')]});
 if(fresh.length)setTimeout(function(){go(fresh)},250);
 if(FEED){
  setInterval(function(){
   fetch(FEED,{headers:{'Accept':'application/json'},credentials:'same-origin'})
    .then(function(r){return r.json()})
    .then(function(d){
     var known={};tpl.forEach(function(t){known[t.getAttribute('data-receipt')]=1});
     if((d.ids||[]).some(function(id){return !known[String(id)]}))location.reload();
    }).catch(function(){});
  },15000);
 }
})();
</script>
HTML;
}
function nav_profile_item(): string {
  return '';
}

