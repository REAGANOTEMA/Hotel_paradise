<?php
declare(strict_types=1);

/**
 * Premium dashboard helpers: real-data visualizations, no fake numbers.
 * All charts render as inline SVG with accessible labels and tooltips.
 */

function hp_dash_css(): string { return BASE . '/assets/dashboard-premium.css'; }

function hp_money_short($n): string {
  $v = (float)$n; $a = abs($v); $sign = $v < 0 ? '-' : '';
  if ($a >= 1000000000) return $sign.'UGX '.number_format($a/1000000000,1).'B';
  if ($a >= 1000000) return $sign.'UGX '.number_format($a/1000000,1).'M';
  if ($a >= 1000) return $sign.'UGX '.number_format($a/1000,1).'K';
  return money($v);
}

function hp_dash_hero(string $eyebrow, string $title, string $desc, array $chips=[], array $actions=[]): void {
  echo '<section class="dashHero"><div class="dashHeroGrid"><div>';
  echo '<div class="dashEyebrow">'.e($eyebrow).'</div>';
  echo '<h2>'.e($title).'</h2><p>'.e($desc).'</p>';
  if ($actions) {
    echo '<div class="dashHeroActions">';
    foreach ($actions as $a) {
      $cls = !empty($a['ghost']) ? 'btnGhost' : 'btn';
      echo '<a class="'.$cls.'" href="'.e($a['href']??'#').'">'.e($a['label']??'Open').'</a>';
    }
    echo '</div>';
  }
  echo '</div><div class="dashHeroMeta">';
  foreach ($chips as $c) {
    echo '<span class="heroChip"><b>'.e($c['label']??'').'</b> '.e($c['value']??'').'</span>';
  }
  echo '</div></div></section>';
}

function hp_panel_head(string $title, string $hint='', string $tools=''): void {
  echo '<div class="panelHead"><div><h2>'.e($title).'</h2>'.($hint!==''?'<p class="hint">'.e($hint).'</p>':'').'</div>';
  if ($tools!=='') echo '<div class="panelTools">'.$tools.'</div>';
  echo '</div>';
}

function hp_chart_empty(string $title, string $text): string {
  return '<div class="chartEmpty"><b>'.e($title).'</b>'.e($text).'</div>';
}

function hp_chart_palette(): array {
  return ['#D4AF37','#0B5D78','#123056','#2E7D32','#B26A00','#7A4B1F','#5C6BC0','#C62828'];
}

function hp_svg_start(int $w, int $h, string $label): string {
  return '<svg class="chartSvg" viewBox="0 0 '.$w.' '.$h.'" role="img" aria-label="'.e($label).'" preserveAspectRatio="xMidYMid meet">';
}

function hp_svg_end(string $summary=''): string {
  return ($summary!==''?'<title>'.e($summary).'</title>':'').'</svg>';
}

function hp_chart_legend(array $items): string {
  $h = '<div class="chartLegend">';
  foreach ($items as $it) {
    $h .= '<span class="legendItem"><span class="legendDot" style="background:'.e($it['color']??'#D4AF37').'"></span>'.e($it['label']??'').'</span>';
  }
  return $h.'</div>';
}

function hp_line_chart(array $series, array $labels, array $opts=[]): string {
  $w=760; $h=320; $padL=58; $padR=20; $padT=20; $padB=42;
  $iw=$w-$padL-$padR; $ih=$h-$padT-$padB;
  $all=[]; foreach($series as $s){ foreach(($s['values']??[]) as $v) $all[]=(float)$v; }
  if(!$all || count($labels)<2) return hp_chart_empty('No trend data yet', $opts['empty']??'There is not enough historical data to draw this chart.');
  $max=max($all); $min=min(0.0,min($all)); if($max==$min) $max=$min+1;
  $n=count($labels); $xStep=$n>1?$iw/($n-1):$iw;
  $svg=hp_svg_start($w,$h,$opts['aria']??'Line chart');
  $svg.='<defs><linearGradient id="hpLg" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#D4AF37" stop-opacity=".28"/><stop offset="100%" stop-color="#D4AF37" stop-opacity="0"/></linearGradient></defs>';
  for($i=0;$i<=4;$i++){
    $y=$padT+$ih-($ih*$i/4); $val=$min+($max-$min)*$i/4;
    $svg.='<line x1="'.$padL.'" y1="'.$y.'" x2="'.($w-$padR).'" y2="'.$y.'" stroke="#e7e0d0" stroke-dasharray="4 6"/>';
    $svg.='<text x="'.($padL-10).'" y="'.($y+4).'" text-anchor="end" font-size="11" fill="#6b7280">'.e(hp_money_short($val)).'</text>';
  }
  foreach($labels as $i=>$lab){
    $x=$padL+$xStep*$i;
    if($i%max(1,(int)ceil($n/7))===0 || $i==$n-1){
      $svg.='<text x="'.$x.'" y="'.($h-14).'" text-anchor="middle" font-size="11" fill="#6b7280">'.e($lab).'</text>';
    }
  }
  $legend=[];
  foreach($series as $si=>$s){
    $vals=array_map('floatval',$s['values']??[]); $color=$s['color']??hp_chart_palette()[$si%8]; $legend[]=['label'=>$s['label']??('Series '.($si+1)),'color'=>$color];
    $pts=[]; foreach($vals as $i=>$v){ $x=$padL+$xStep*$i; $y=$padT+$ih-(($v-$min)/($max-$min))*$ih; $pts[]=$x.','.$y; }
    if(($s['area']??false) && $pts){
      $areaPts=$pts; $areaPts[]=( $padL+$xStep*(count($vals)-1) ).','.($padT+$ih); $areaPts[]=$padL.','.($padT+$ih);
      $svg.='<polygon points="'.implode(' ',$areaPts).'" fill="url(#hpLg)" />';
    }
    $svg.='<polyline fill="none" stroke="'.e($color).'" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" points="'.implode(' ',$pts).'"></polyline>';
    foreach($vals as $i=>$v){ $x=$padL+$xStep*$i; $y=$padT+$ih-(($v-$min)/($max-$min))*$ih;
      $svg.='<circle cx="'.$x.'" cy="'.$y.'" r="4" fill="#fff" stroke="'.e($color).'" stroke-width="2"><title>'.e(($s['label']??'Value').': '.money($v).' ('.($labels[$i]??'').')').'</title></circle>';
    }
  }
  $svg.=hp_svg_end($opts['aria']??'Line chart');
  return '<div class="chartWrap">'.$svg.hp_chart_legend($legend).'</div>';
}

function hp_bar_chart(array $items, array $opts=[]): string {
  $w=760; $h=320; $padL=58; $padR=20; $padT=20; $padB=56; $iw=$w-$padL-$padR; $ih=$h-$padT-$padB;
  $vals=array_map(fn($i)=>(float)($i['value']??0),$items);
  if(!$items) return hp_chart_empty('No data available', $opts['empty']??'No records matched the selected period.');
  $max=max($vals); if($max<=0) $max=1;
  $n=count($items); $gap=14; $bw=max(24, ($iw-$gap*($n-1))/$n);
  $svg=hp_svg_start($w,$h,$opts['aria']??'Bar chart');
  for($i=0;$i<=4;$i++){ $y=$padT+$ih-($ih*$i/4); $val=$max*$i/4;
    $svg.='<line x1="'.$padL.'" y1="'.$y.'" x2="'.($w-$padR).'" y2="'.$y.'" stroke="#e7e0d0" stroke-dasharray="4 6"/>';
    $svg.='<text x="'.($padL-10).'" y="'.($y+4).'" text-anchor="end" font-size="11" fill="#6b7280">'.e(hp_money_short($val)).'</text>';
  }
  foreach($items as $i=>$it){
    $v=(float)($it['value']??0); $bh=($v/$max)*$ih; $x=$padL+$i*($bw+$gap); $y=$padT+$ih-$bh;
    $color=$it['color']??hp_chart_palette()[$i%8];
    $svg.='<rect x="'.$x.'" y="'.$y.'" width="'.$bw.'" height="'.max(1,$bh).'" rx="8" fill="'.e($color).'"><title>'.e(($it['label']??'').': '.($opts['money']??true?money($v):num($v))).'</title></rect>';
    $svg.='<text x="'.($x+$bw/2).'" y="'.($h-18).'" text-anchor="middle" font-size="11" fill="#6b7280">'.e(mb_strimwidth((string)($it['label']??''),0,12,'…')).'</text>';
  }
  return '<div class="chartWrap">'.$svg.hp_svg_end().'</div>';
}

function hp_donut_chart(array $items, array $opts=[]): string {
  $total=0.0; foreach($items as $it) $total+=(float)($it['value']??0);
  if($total<=0) return hp_chart_empty('No breakdown available', $opts['empty']??'There is no data to break down for this period.');
  $cx=150; $cy=150; $r=92; $ir=58; $circ=2*M_PI*$r; $offset=0; $svg=hp_svg_start(560,300,$opts['aria']??'Donut chart');
  $legend=[];
  foreach($items as $i=>$it){
    $v=max(0.0,(float)($it['value']??0)); $frac=$v/$total; $dash=$circ*$frac; $color=$it['color']??hp_chart_palette()[$i%8]; $legend[]=['label'=>($it['label']??'').' ('.number_format($frac*100,1).'%)','color'=>$color];
    $svg.='<circle cx="'.$cx.'" cy="'.$cy.'" r="'.$r.'" fill="transparent" stroke="'.e($color).'" stroke-width="'.($r-$ir).'" stroke-dasharray="'.$dash.' '.($circ-$dash).'" stroke-dashoffset="'.(-$offset).'" transform="rotate(-90 '.$cx.' '.$cy.')"><title>'.e(($it['label']??'').': '.($opts['money']??true?money($v):num($v))).'</title></circle>';
    $offset+=$dash;
  }
  $svg.='<circle cx="'.$cx.'" cy="'.$cy.'" r="'.$ir.'" fill="#fff"/>';
  $svg.='<text x="'.$cx.'" y="'.($cy-4).'" text-anchor="middle" font-size="12" fill="#6b7280">'.e($opts['center_label']??'Total').'</text>';
  $svg.='<text x="'.$cx.'" y="'.($cy+20).'" text-anchor="middle" font-size="18" font-weight="700" fill="#071A33">'.e($opts['center_value']??($opts['money']??true?hp_money_short($total):num($total))).'</text>';
  $svg.=hp_svg_end();
  return '<div class="chartWrap"><div style="display:flex;gap:14px;align-items:center;flex-wrap:wrap"><div style="flex:0 1 300px;min-width:260px">'.$svg.'</div><div style="flex:1 1 180px">'.hp_chart_legend($legend).'</div></div></div>';
}

function hp_metric_rows(array $rows): string {
  if(!$rows) return hp_chart_empty('No comparison data', 'There is no data to compare for this view.');
  $max=0.0; foreach($rows as $r) $max=max($max,(float)($r['value']??0)); if($max<=0) $max=1;
  $h='<div class="metricRows">';
  foreach($rows as $r){
    $v=(float)($r['value']??0); $pct=min(100,($v/$max)*100); $tone=e($r['tone']??'');
    $h.='<div class="metricRow"><div class="metricLabel">'.e($r['label']??'').(!empty($r['sub'])?'<small>'.e($r['sub']).'</small>':'').'</div>'
      .'<div class="metricBar '.$tone.'"><i style="width:'.$pct.'%"></i></div>'
      .'<div class="metricVal">'.($r['display']??($r['money']??true?money($v):num($v))).'</div></div>';
  }
  return $h.'</div>';
}
