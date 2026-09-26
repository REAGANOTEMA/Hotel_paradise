<?php
declare(strict_types=1);

function nav_items(): array{
 return [
  'dashboard'=>'Dashboard','reservations'=>'Reservations','rooms'=>'Rooms','guests'=>'Guests',
  'pos'=>'POS and Orders','shifts'=>'Shifts','inventory'=>'Inventory','suppliers'=>'Suppliers',
  'purchases'=>'Purchases','expenses'=>'Expenses','finance'=>'Finance','approvals'=>'Approvals',
  'audit'=>'Audit Trail','reports'=>'Reports','users'=>'Team and Users'
 ];
}

function page_head(string $title,string $active='dashboard',string $sub=''): void{
 $u=current_user();
 $flash=flash_out();
 $items=nav_items();
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

 echo '<aside class="side" id="side"><a class="sideBrand" href="'.BASE.'/index.php?page=dashboard"><img class="sideLogo" src="'.SITE_URL.'/images/logo-256.png" alt="Hotel Paradise on the Nile logo"><span class="sbText"><span>HOTEL PARADISE</span><small>ON THE NILE</small></span></a>';
 echo '<button class="sideClose" id="sideClose" type="button" aria-label="Close menu"><span></span><span></span></button>';
 echo '<div class="sideLabel">MANAGEMENT SYSTEM</div><nav class="sideNav" aria-label="Modules">';
 foreach($items as $k=>$lbl){
  if(!page_allowed($k)) continue;
  $on=$k===$active?' class="on"':'';
  echo '<a href="'.BASE.'/index.php?page='.$k.'"'.$on.'><span class="dot"></span>'.e($lbl).'</a>';
 }
 echo '</nav><div class="sideFoot"><a href="'.SITE_URL.'/" target="_blank" rel="noopener">Open website</a></div></aside>';

 echo '<div class="main" id="mainContent"><header class="top"><button class="sideToggle" id="sideToggle" type="button" aria-label="Open menu" aria-controls="side" aria-expanded="false"><span></span><span></span><span></span></button><div class="topTitles"><h1 class="pageTitle">'.e($title).'</h1>'.($sub?'<p class="pageSub">'.e($sub).'</p>':'').'</div><div class="topRight"><span class="who">'.e($u['name']??'').'</span><span class="whoRole">'.role_label(roles_of()[0]??'').'</span><a class="btnGhost sm" href="'.BASE.'/index.php?page=logout">Sign out</a></div></header>';
 if($flash){ echo '<div class="flash '.e($flash['type']).'">'.e($flash['msg']).'</div>'; }
 echo '<div class="content">';
}

/**
 * One small script for the whole console. It gives the sidebar a drawer on a
 * narrow screen, and wraps every data table in a scroll box so a wide report
 * never pushes the page sideways on a phone.
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
 $cards=['navy'=>'#0f2850','gold'=>'#b08d1a','green'=>'#14532d','red'=>'#7f1d1d','blue'=>'#0B5D78'];
 echo '<div class="kpi" style="--k:'.($cards[$tone]??$cards['navy']).'"><div class="kpiLbl">'.e($label).'</div><div class="kpiVal">'.$value.'</div>'.($hint?'<div class="kpiHint">'.e($hint).'</div>':'').'</div>';
}

function filter_bar(string $extra=''): void{
 echo '<div class="toolbar">'.$extra.'</div>';
}

function status_badge(string $status, bool $neutral=false): string{
 $tones=['available'=>'ok','confirmed'=>'blue','checked_in'=>'gold','checked_out'=>'grey','cancelled'=>'bad','pending'=>'warn','paid'=>'ok','open'=>'gold','successful'=>'ok','reserved'=>'warn','occupied'=>'gold','dirty'=>'bad','cleaning'=>'blue','inspected'=>'ok','maintenance'=>'grey','approved'=>'ok','rejected'=>'bad','served'=>'ok','preparing'=>'warn','ready'=>'blue'];
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