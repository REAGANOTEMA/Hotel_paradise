<?php
declare(strict_types=1);

/**
 * Keeps the database menu whole.
 *
 * The public menu page falls back on the menu the website ships whenever the
 * database cannot be reached, but a hosting install that imported only part of
 * the dump used to lose every dish it was missing the moment the live data
 * loaded: the live menu replaced the full one with the fraction. The site now
 * carries the same menu as a JSON file (backend-php/data/kitchen-menu.json) and
 * this file is what puts anything missing back, dish by dish.
 *
 * It only ever adds. A dish the database already holds is left exactly as the
 * kitchen set it unless the caller asks for a full reconciliation, so an
 * automatic repair can never quietly rewrite a price someone edited by hand.
 */

/** The kitchen menu the website ships, read once per request. */
function menu_canonical(): array{
 static $menu=null;
 if($menu!==null) return $menu;
 $file=__DIR__.'/../data/kitchen-menu.json';
 if(!is_readable($file)) return $menu=[];
 $raw=json_decode((string)file_get_contents($file),true);
 if(!is_array($raw)||!isset($raw['sections'])||!is_array($raw['sections'])) return $menu=[];
 return $menu=$raw;
}

/** How many dishes the shipped menu carries, used as the measure of "whole". */
function menu_canonical_count(): int{
 static $n=null;
 if($n!==null) return $n;
 $n=0;
 foreach(menu_canonical()['sections']??[] as $s){
  foreach((array)($s['groups']??[]) as $g){ $n+=count((array)($g['items']??[])); }
 }
 return $n;
}

/** Lower case and free of punctuation, so two spellings of one name meet. */
function menu_name_key(string $s): string{
 $s=strtolower($s);
 $s=preg_replace('/[^a-z0-9]+/u',' ',$s) ?? '';
 return trim($s);
}

/** Whether one table has one column, remembered for the life of the request. */
function menu_sync_has(PDO $pdo,string $table,string $col): bool{
 static $cache=[];
 if(!isset($cache[$table])){
  $cache[$table]=[];
  if(!preg_match('/^[A-Za-z0-9_]+$/',$table)) return false;
  try{
   $st=$pdo->query('SHOW COLUMNS FROM `'.$table.'`');
   foreach($st->fetchAll(PDO::FETCH_ASSOC) as $c){
    $cache[$table][strtolower((string)($c['Field']??''))]=true;
   }
  }catch(Throwable $e){ /* a database that cannot answer is treated as bare */ }
 }
 return isset($cache[$table][strtolower($col)]);
}

/**
 * Writes the dishes the shipped menu carries but the database is missing.
 *
 * $full is false for the automatic repair that runs when the public menu is
 * short: it inserts what is absent and switches on what is present but hidden,
 * and touches nothing else. With $full true the dishes already in the database
 * are rewritten from the shipped menu as well, so a corrected price or
 * description travels across; a dish the database holds is never deleted.
 *
 * Returns a small report rather than throwing, so a caller can run this on the
 * path of a guest's request without risking the page.
 */
function menu_sync_complete(PDO $pdo,bool $full=false): array{
 $report=['ok'=>true,'added'=>0,'updated'=>0,'shown'=>0,'categories'=>0,'skipped'=>0,'error'=>null];
 $sections=menu_canonical()['sections']??[];
 if(!$sections){ $report['ok']=false; $report['error']='The shipped menu file could not be read.'; return $report; }

 $hasCatEyebrow=menu_sync_has($pdo,'menu_categories','eyebrow');
 $hasCatBlurb=menu_sync_has($pdo,'menu_categories','blurb');
 $hasCatImage=menu_sync_has($pdo,'menu_categories','image');
 $hasCatSort=menu_sync_has($pdo,'menu_categories','sort_order');
 $hasDesc=menu_sync_has($pdo,'menu_items','description');
 $hasImage=menu_sync_has($pdo,'menu_items','image');
 $hasGroup=menu_sync_has($pdo,'menu_items','group_name');
 $hasSort=menu_sync_has($pdo,'menu_items','sort_order');
 $hasActive=menu_sync_has($pdo,'menu_items','active');

 $cats=[];
 foreach($pdo->query('SELECT id,outlet,name FROM menu_categories ORDER BY id')->fetchAll() as $c){
  $cats[(int)$c['id']]=['outlet'=>(string)$c['outlet'],'key'=>menu_name_key((string)$c['name'])];
 }
 $items=[];
 foreach($pdo->query('SELECT id,category_id,name'.($hasActive?',active':'').' FROM menu_items ORDER BY id')->fetchAll() as $it){
  $items[(int)$it['id']]=[
   'category'=>(int)$it['category_id'],
   'key'=>menu_name_key((string)$it['name']),
   'active'=>$hasActive?((int)$it['active']===1):true
  ];
 }
 $byKey=[];
 foreach($items as $id=>$it){ $byKey[$it['key']][]=$id; }

 $takenCats=[]; $takenItems=[];
 $seq=0;

 // One repair at a time. Two guests loading the page together on an install
 // that has not been repaired yet must not each insert the same dish, so a
 // request that cannot take the lock serves the menu it already has.
 $locked=false;
 try{ $locked=((int)$pdo->query("SELECT GET_LOCK('hp_menu_sync',5)")->fetchColumn())===1; }catch(Throwable $e){}
 if(!$locked){ $report['skipped']=1; return $report; }

 $pdo->beginTransaction();
 try{
  foreach($sections as $s){
   $seq++;
   $secName=trim((string)($s['name']??''));
   if($secName==='') continue;
   $secKey=menu_name_key($secName);

   // A restaurant category the site already prints under this name is kept, so
   // the photographs and the orders pointed at it follow the menu across.
   $cid=null;
   foreach($cats as $id=>$c){
    if(isset($takenCats[$id])) continue;
    if($c['outlet']==='restaurant'&&$c['key']===$secKey){ $cid=$id; break; }
   }

   if($cid!==null){
    $takenCats[$cid]=true;
    if($full){
     $sets=[]; $vals=[];
     if($hasCatEyebrow){ $sets[]='eyebrow=?'; $vals[]=(string)($s['eyebrow']??''); }
     if($hasCatBlurb){ $sets[]='blurb=?'; $vals[]=(string)($s['blurb']??''); }
     if($hasCatImage){ $sets[]='image=?'; $vals[]=(string)($s['image']??''); }
     if($hasCatSort){ $sets[]='sort_order=?'; $vals[]=$seq*10; }
     if($sets){ $vals[]=$cid; $st=$pdo->prepare('UPDATE menu_categories SET '.implode(',',$sets).' WHERE id=?'); $st->execute($vals); }
    }
   }else{
    $cols=['hotel_id','outlet','name']; $vals=[1,'restaurant',$secName];
    if($hasCatEyebrow){ $cols[]='eyebrow'; $vals[]=(string)($s['eyebrow']??''); }
    if($hasCatBlurb){ $cols[]='blurb'; $vals[]=(string)($s['blurb']??''); }
    if($hasCatImage){ $cols[]='image'; $vals[]=(string)($s['image']??''); }
    if($hasCatSort){ $cols[]='sort_order'; $vals[]=$seq*10; }
    $st=$pdo->prepare('INSERT INTO menu_categories('.implode(',',$cols).') VALUES('.implode(',',array_fill(0,count($cols),'?')).')');
    $st->execute($vals);
    $cid=(int)$pdo->lastInsertId();
    $cats[$cid]=['outlet'=>'restaurant','key'=>$secKey];
    $takenCats[$cid]=true;
    $report['categories']++;
   }

   $at=0;
   foreach((array)($s['groups']??[]) as $g){
    $gName=(string)($g['name']??'');
    foreach((array)($g['items']??[]) as $d){
     $at+=10;
     $dName=trim((string)($d['name']??''));
     if($dName==='') continue;
     $key=menu_name_key($dName);
     $price=($d['price']===null||$d['price']==='')?null:(float)$d['price'];

     // Found by name anywhere in the restaurant, so a plate that moved between
     // sections keeps its row and its history. A bar or room service dish of the
     // same name is left where it is and the restaurant gets its own.
     $found=null;
     foreach($byKey[$key]??[] as $id){
      if(isset($takenItems[$id])) continue;
      if(($cats[$items[$id]['category']]['outlet']??'')!=='restaurant') continue;
      $found=$id; break;
     }

     if($found!==null){
      $takenItems[$found]=true;
      if($full){
       $sets=['category_id=?','name=?']; $vals=[$cid,$dName];
       if($hasDesc){ $sets[]='description=?'; $vals[]=(string)($d['desc']??''); }
       $sets[]='price=?'; $vals[]=$price;
       if($hasImage){ $sets[]='image=?'; $vals[]=(string)($d['image']??''); }
       if($hasGroup){ $sets[]='group_name=?'; $vals[]=$gName; }
       if($hasSort){ $sets[]='sort_order=?'; $vals[]=$at; }
       if($hasActive){ $sets[]='active=?'; $vals[]=1; }
       $vals[]=$found;
       $st=$pdo->prepare('UPDATE menu_items SET '.implode(',',$sets).' WHERE id=?'); $st->execute($vals);
       $report['updated']++;
      }elseif($hasActive&&!$items[$found]['active']){
       $st=$pdo->prepare('UPDATE menu_items SET active=1 WHERE id=?'); $st->execute([$found]);
       $report['shown']++;
      }
      continue;
     }

     $cols=['hotel_id','category_id','name']; $vals=[1,$cid,$dName];
     if($hasDesc){ $cols[]='description'; $vals[]=(string)($d['desc']??''); }
     $cols[]='price'; $vals[]=$price;
     if($hasImage){ $cols[]='image'; $vals[]=(string)($d['image']??''); }
     if($hasGroup){ $cols[]='group_name'; $vals[]=$gName; }
     if($hasSort){ $cols[]='sort_order'; $vals[]=$at; }
     if($hasActive){ $cols[]='active'; $vals[]=1; }
     $st=$pdo->prepare('INSERT INTO menu_items('.implode(',',$cols).') VALUES('.implode(',',array_fill(0,count($cols),'?')).')');
     $st->execute($vals);
     $newId=(int)$pdo->lastInsertId();
     $items[$newId]=['category'=>$cid,'key'=>$key,'active'=>true];
     $takenItems[$newId]=true;
     $report['added']++;
    }
   }
  }
  $pdo->commit();
 }catch(Throwable $e){
  if($pdo->inTransaction()) $pdo->rollBack();
  $report['ok']=false;
  $report['error']=$e->getMessage();
 }finally{
  try{ $pdo->query("SELECT RELEASE_LOCK('hp_menu_sync')"); }catch(Throwable $e){}
 }
 return $report;
}
