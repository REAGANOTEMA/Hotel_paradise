<?php
declare(strict_types=1);

function nav_items(): array{
 return [
  'dashboard'=>'Dashboard','overview'=>'CEO / Director','reservations'=>'Reservations','rooms'=>'Rooms','guests'=>'Guests',
  'pos'=>'POS and Orders','fnb'=>'Food and Beverage','kitchen'=>'Kitchen','shifts'=>'Shifts','inventory'=>'Inventory','suppliers'=>'Suppliers',
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