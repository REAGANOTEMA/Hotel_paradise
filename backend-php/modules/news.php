<?php
declare(strict_types=1);

/**
 * News, Updates, Opportunities and Careers.
 *
 * Everything the hotel wants to publish to the public - announcements, updates,
 * opportunities for the community, recruitment vacancies and the employee of the
 * month - lives in one table. This console gives the authorised team (marketing,
 * human resource, events, management) a place to write, edit, pin, unpublish and
 * remove those posts, and to attach the photograph that heads each one.
 *
 * The public website reads the published ones through the read-only API
 * (backend-php/api.php act=news), so what is written here appears everywhere.
 */

if(!function_exists('ensure_news_table')){
  function ensure_news_table(): void{
    q('CREATE TABLE IF NOT EXISTS news_posts(
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
      slug VARCHAR(180) NOT NULL,
      title VARCHAR(200) NOT NULL,
      category VARCHAR(20) NOT NULL DEFAULT \'news\',
      excerpt VARCHAR(320) NOT NULL DEFAULT \'\',
      body MEDIUMTEXT DEFAULT NULL,
      image VARCHAR(255) DEFAULT NULL,
      department VARCHAR(120) DEFAULT NULL,
      location VARCHAR(120) DEFAULT NULL,
      employment_type VARCHAR(60) DEFAULT NULL,
      salary VARCHAR(120) DEFAULT NULL,
      deadline DATE DEFAULT NULL,
      apply_email VARCHAR(160) DEFAULT NULL,
      apply_url VARCHAR(300) DEFAULT NULL,
      author_name VARCHAR(120) DEFAULT NULL,
      author_role VARCHAR(120) DEFAULT NULL,
      pinned TINYINT(1) NOT NULL DEFAULT 0,
      status VARCHAR(20) NOT NULL DEFAULT \'published\',
      publish_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      views INT UNSIGNED NOT NULL DEFAULT 0,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME DEFAULT NULL,
      deleted_at TIMESTAMP NULL DEFAULT NULL,
      deleted_by BIGINT UNSIGNED DEFAULT NULL,
      PRIMARY KEY(id),
      UNIQUE KEY uq_news_slug(slug),
      KEY idx_news_cat(category),
      KEY idx_news_status(status,publish_at),
      KEY idx_news_pinned(pinned,publish_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
  }
}

/**
 * The human resource role, added on first use.
 *
 * Human resource publishes vacancies and the employee of the month, so the role
 * has to exist before an administrator can hand it to a colleague. It is only
 * ever added, and never on a database that already knows the name.
 */
if(!function_exists('ensure_news_roles')){
  function ensure_news_roles(): void{
    try{
      if(!val('SELECT id FROM roles WHERE name=?',['human_resource'])){
        q('INSERT INTO roles(name) VALUES(?)',['human_resource']);
      }
    }catch(Throwable $e){
      error_log('[hotel news] could not ensure human_resource role: '.$e->getMessage());
    }
  }
}

/** The folder on the public website where a news photograph is kept. */
if(!function_exists('news_upload_dir')){
  function news_upload_dir(): string{
    return dirname(__DIR__,2).'/images/news';
  }
}

/**
 * The URL a stored image should be shown from.
 *
 * A photograph may have been uploaded here (stored as ./images/news/name) or
 * pasted in as a full address on another host, so both are understood and the
 * console is handed something a browser can actually load.
 */
if(!function_exists('news_image_src')){
  function news_image_src(?string $image): string{
    $image=trim((string)$image);
    if($image==='') return '';
    if(preg_match('#^https?://#i',$image)) return $image;
    if(strpos($image,'//')===0) return $image;
    return rtrim(SITE_URL,'/').'/'.ltrim(preg_replace('#^\.?/#','',$image),'/');
  }
}

/**
 * Takes a photograph from the form and files it on the public website.
 *
 * Only a real image of a sensible size is accepted, it is written under a name
 * the uploader cannot choose, and the copy it replaces (when it was one of ours)
 * is removed. Returns the stored path, or an empty string when nothing usable
 * was sent, and writes the reason into $error.
 */
if(!function_exists('news_save_upload')){
  function news_save_upload(string $field,string $slug,?string $old,string &$error): string{
    if(!isset($_FILES[$field])||!is_array($_FILES[$field])) return '';
    $f=$_FILES[$field];
    if(($f['error']??UPLOAD_ERR_NO_FILE)===UPLOAD_ERR_NO_FILE) return '';
    if(($f['error']??UPLOAD_ERR_NO_FILE)!==UPLOAD_ERR_OK){
      $error='The photograph could not be uploaded (error '.$f['error'].').';
      return '';
    }
    if(($f['size']??0)>4*1024*1024){ $error='That photograph is larger than 4MB. Please choose a smaller one.'; return ''; }
    $info=@getimagesize((string)$f['tmp_name']);
    if(!$info||empty($info['mime'])||strpos((string)$info['mime'],'image/')!==0){
      $error='That file is not a picture. Please choose a JPG, PNG, GIF or WebP image.';
      return '';
    }
    $ext=['image/jpeg'=>'jpg','image/png'=>'png','image/gif'=>'gif','image/webp'=>'webp'][$info['mime']]??'jpg';
    $dir=news_upload_dir();
    if(!is_dir($dir)&&!@mkdir($dir,0775,true)){ $error='The image folder could not be created on the server.'; return ''; }
    $stem=preg_replace('/[^a-z0-9]+/','-',strtolower($slug));
    $stem=trim(substr($stem,0,60),'-');
    if($stem==='') $stem='news';
    $name='news-'.$stem.'-'.date('YmdHis').'-'.substr(bin2hex(random_bytes(3)),0,6).'.'.$ext;
    if(!@move_uploaded_file((string)$f['tmp_name'],$dir.'/'.$name)){ $error='The photograph could not be saved on the server.'; return ''; }
    // Remove the picture this one replaces, but only when it was one of ours.
    $oldName=basename((string)$old);
    if($oldName!==''&&preg_match('/^news-[A-Za-z0-9.\-]+$/',$oldName)&&is_file($dir.'/'.$oldName)){ @unlink($dir.'/'.$oldName); }
    return './images/news/'.$name;
  }
}

/** Deletes a news photograph from disk, but only one this console wrote. */
if(!function_exists('news_delete_upload')){
  function news_delete_upload(?string $image): void{
    $name=basename(trim((string)$image));
    if($name!==''&&preg_match('/^news-[A-Za-z0-9.\-]+$/',$name)){
      $file=news_upload_dir().'/'.$name;
      if(is_file($file)) @unlink($file);
    }
  }
}

/**
 * Remembers who wrote a post, so a department can find and manage its own
 * stories and not anyone else's. Added on first use to a database that predates
 * the column; an existing column makes MySQL say so, which is ignored.
 */
if(!function_exists('ensure_news_created_by')){
  function ensure_news_created_by(): void{
    try{ q('ALTER TABLE news_posts ADD COLUMN created_by BIGINT UNSIGNED NULL AFTER author_role'); }
    catch(Throwable $e){ /* the column is already there */ }
  }
}

$u=current_user();
ensure_news_table();
ensure_news_roles();
ensure_news_created_by();

$CATS=[
  'news'=>['label'=>'News & announcements','tone'=>'navy'],
  'update'=>['label'=>'Updates & notices','tone'=>'blue'],
  'opportunity'=>['label'=>'Opportunities','tone'=>'gold'],
  'recruitment'=>['label'=>'Recruitment','tone'=>'warn'],
  'employee'=>['label'=>'Employee of the month','tone'=>'ok'],
];
$STATS=['published'=>['label'=>'Published','tone'=>'ok'],'draft'=>['label'=>'Draft','tone'=>'grey']];

/* What this member may do here. The console gates the module itself, but the
   category, the department and whose post may be edited are decided here, on
   the record, so a crafted request cannot step outside the role. */
$cap=news_capability();
if($cap===null){
  page_head('Not permitted','news');
  echo '<div class="panel"><h2>Access restricted</h2><p class="hint">Your role does not write for the newsroom. Contact the administrator if you believe this is a mistake.</p><a class="btn" href="'.BASE.'/index.php?page=dashboard">Back to dashboard</a></div>';
  page_foot(); exit;
}
$canAll=$cap['can_all'];
$isContrib=$cap['tier']==='contributor';
$allowedCats=$canAll?array_keys($CATS):$cap['categories'];
if($allowedCats===[]) $allowedCats=['news'];
$homeCats=$isContrib?['news','update']:$allowedCats;
$capLabel=$cap['label'];
$capDept=(string)($cap['department']??'');

/** Whose posts this member may open or remove. */
$inScope=static function(?array $r) use($canAll,$isContrib,$allowedCats,$u): bool{
  if($r===null) return false;
  if($canAll) return true;
  if($isContrib) return (int)($r['created_by']??0)===(int)($u['id']??0);
  return in_array((string)$r['category'],$allowedCats,true);
};

$act=$_GET['act']??'list';

if($_SERVER['REQUEST_METHOD']==='POST'){
  $a=$_GET['act']??'';
  if($a==='delete'){
    $id=(int)($_GET['id']??$_POST['id']??0);
    $r=row('SELECT * FROM news_posts WHERE id=?',[$id]);
    if(!$r){
      flash('Post not found.','bad');
    }elseif(!$inScope($r)){
      flash('That post does not belong to you. Ask an editor to change it.','bad');
    }else{
      q('UPDATE news_posts SET deleted_at=NOW(),deleted_by=? WHERE id=?',[(int)($u['id']??null),$id]);
      audit('trash','news_posts',$id,['slug'=>$r['slug'],'title'=>$r['title']]);
      notify_console('news:trash:'.$id, 'communication','Newsroom: '.$r['title'].' moved to trash',
        'A news post was moved to Trash by '.($u['name']??'a team member').'.',
        ['news_id'=>$id,'slug'=>$r['slug']],['director','general_manager','super_admin'],'news_post',$id);
      flash('News post moved to Trash.');
    }
    go('news');
  }
  if($a==='publish'){
    /* A one-tap toggle from the list: take a draft live, or pull a live post
       back to draft. Only an editor or owner may flip it, and the Director is
       told either way, so nothing appears or disappears from the site silently. */
    $id=(int)($_GET['id']??$_POST['id']??0);
    $r=row('SELECT * FROM news_posts WHERE id=?',[$id]);
    if(!$r){
      flash('Post not found.','bad');
    }elseif(!$inScope($r)){
      flash('That post does not belong to you. Ask an editor to change it.','bad');
    }else{
      $next=$r['status']==='published'?'draft':'published';
      q('UPDATE news_posts SET status=?,updated_at=NOW() WHERE id=?',[$next,$id]);
      audit('news_'.$next,'news_posts',$id,['slug'=>$r['slug']]);
      notify_console('news:'.$next.':'.$id, 'communication',
        'Newsroom: '.$r['title'].' '.($next==='published'?'is now live':'taken down'),
        ($next==='published'?'Published':'Unpublished').' on the website by '.($u['name']??'a team member').'.',
        ['news_id'=>$id,'slug'=>$r['slug'],'status'=>$next],['director','general_manager','super_admin'],'news_post',$id);
      flash('Post '.($next==='published'?'published':'moved to draft').'.');
    }
    go('news');
  }
  if($a==='save'){
    $id=(int)($_POST['id']??0);
    $title=trim((string)($_POST['title']??''));
    $slug=trim((string)($_POST['slug']??''));
    $title=mb_substr($title,0,200);
    if($slug==='') $slug=$title;
    $slug=strtolower($slug);
    $slug=str_replace('&','and',$slug);
    $slug=preg_replace('/[^a-z0-9]+/','-',$slug);
    $slug=trim($slug,'-');
    $slug=substr($slug,0,180);
    if($slug==='') $slug='post-'.date('Ymd-His');
    $category=(string)($_POST['category']??'news');
    if(!isset($CATS[$category])) $category=$allowedCats[0];
    if(!$canAll&&!in_array($category,$allowedCats,true)) $category=$allowedCats[0];
    $excerpt=mb_substr(trim((string)($_POST['excerpt']??'')),0,320);
    $body=trim((string)($_POST['body']??''));
    $image=trim((string)($_POST['image']??''));
    $department=mb_substr(trim((string)($_POST['department']??'')),0,120);
    $location=mb_substr(trim((string)($_POST['location']??'')),0,120);
    $employment_type=mb_substr(trim((string)($_POST['employment_type']??'')),0,60);
    $salary=mb_substr(trim((string)($_POST['salary']??'')),0,120);
    $deadline=trim((string)($_POST['deadline']??''));
    $apply_email=strtolower(trim((string)($_POST['apply_email']??'')));
    $apply_url=trim((string)($_POST['apply_url']??''));
    $author_name=mb_substr(trim((string)($_POST['author_name']??($u['name']??''))),0,120);
    $author_role=mb_substr(trim((string)($_POST['author_role']??'')),0,120);
    if($author_role==='') $author_role=mb_substr($capLabel,0,120);
    // A department writes under its own name, and only a full editor or an
    // owner may feature a post; a contributor rings no front page.
    if($isContrib&&$capDept!=='') $department=mb_substr($capDept,0,120);
    $pinned=$isContrib?0:(int)((bool)($_POST['pinned']??0));
    $status=(string)($_POST['status']??'published');
    if(!isset($STATS[$status])) $status='published';
    $publish_at=trim((string)($_POST['publish_at']??''));
    if($publish_at==='') $publish_at=date('Y-m-d H:i:s');
    if(strlen($publish_at)===16) $publish_at.=':00';
    if(($deadline!==''&&!preg_match('/^\d{4}-\d{2}-\d{2}$/',$deadline))) $deadline='';
    if($apply_email!==''&&!filter_var($apply_email,FILTER_VALIDATE_EMAIL)) $apply_email='';

    if($title===''){ flash('Title is required.','bad'); go('news',$id>0?['act'=>'edit','id'=>$id]:['act'=>'new']); }

    // A new photograph takes the place of the stored one. The URL field is a
    // fallback for a picture hosted elsewhere, so it is only used when nothing
    // was uploaded this time.
    $uploadError='';
    $uploaded=news_save_upload('image_file',$slug,$image,$uploadError);
    if($uploadError!==''){ flash($uploadError,'bad'); go('news',$id>0?['act'=>'edit','id'=>$id]:['act'=>'new']); }
    if($uploaded!=='') $image=$uploaded;
    if(!empty($_POST['image_remove'])){ news_delete_upload($image); $image=''; }

    $fields=[$slug,$title,$category,$excerpt,$body,$image,$department,$location,$employment_type,$salary,
      $deadline!==''?$deadline:null,$apply_email,$apply_url,$author_name,$author_role,$pinned,$status,$publish_at];

    $dest=((string)($_POST['return']??''))==='dashboard'?'dashboard':'news';

    if($id>0){
      $old=row('SELECT * FROM news_posts WHERE id=?',[$id]);
      if($old===null){ flash('Post not found.','bad'); go('news'); }
      if(!$inScope($old)){ flash('That post does not belong to you. Ask an editor to change it.','bad'); go('news'); }
      $exists=row('SELECT id FROM news_posts WHERE slug=? AND id!=?',[$slug,$id]);
      if($exists){ flash('That slug is already in use. Choose another.','bad'); go('news',['act'=>'edit','id'=>$id]); }
      try{
        q('UPDATE news_posts SET slug=?,title=?,category=?,excerpt=?,body=?,image=?,department=?,location=?,employment_type=?,salary=?,deadline=?,apply_email=?,apply_url=?,author_name=?,author_role=?,pinned=?,status=?,publish_at=?,updated_at=NOW() WHERE id=?',
          array_merge($fields,[$id]));
        audit('news_update','news_posts',$id,['slug'=>$slug]);
        flash('Post updated.');
      }catch(Throwable $e){
        error_log('[hotel news] update failed: '.$e->getMessage());
        flash('The post could not be saved. Please try again.','bad');
        go('news',['act'=>'edit','id'=>$id]);
      }
    }else{
      $exists=row('SELECT id FROM news_posts WHERE slug=?',[$slug]);
      if($exists){ flash('That slug is already in use. Choose another.','bad'); go('news',['act'=>'new']); }
      try{
        $ins=array_merge([$slug,$title,$category,$excerpt,$body,$image,$department,$location,$employment_type,$salary,
          $deadline!==''?$deadline:null,$apply_email,$apply_url,$author_name,$author_role,(int)($u['id']??0),$pinned,$status,$publish_at]);
        q('INSERT INTO news_posts(hotel_id,slug,title,category,excerpt,body,image,department,location,employment_type,salary,deadline,apply_email,apply_url,author_name,author_role,created_by,pinned,status,publish_at,created_at) VALUES(1,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,NOW())',
          $ins);
        $id=(int)db()->lastInsertId();
        audit('news_create','news_posts',$id,['slug'=>$slug]);
        flash($status==='published'
          ?(strtotime($publish_at)>time()?'Post saved and scheduled.':'Post published.')
          :'Post saved as a draft.');
      }catch(Throwable $e){
        error_log('[hotel news] insert failed: '.$e->getMessage());
        flash('The post could not be saved. Please try again.','bad');
        go('news',['act'=>'new']);
      }
    }

    // Tell the right consoles, and the right phones, that something went live.
    // The author is never rung for their own post (notify_console sees to it).
    if($status==='published'&&strtotime($publish_at)<=time()){
      $aud=['director','general_manager','super_admin'];
      if(in_array($category,['recruitment','employee'],true)) $aud[]='human_resource';
      if(in_array($category,['news','update','opportunity'],true)){ $aud[]='marketing'; $aud[]='events_manager'; }
      foreach(news_roles() as $rl=>$rp){ if($rp['tier']==='contributor'&&($rp['department']??'')===$department) $aud[]=$rl; }
      $aud=array_values(array_unique($aud));
      $catLabel=$CATS[$category]['label']??'News';
      notify_console('news:publish:'.$id.':'.substr(md5($title.'|'.$body.'|'.$publish_at),0,10),
        'communication','Newsroom: '.$title,
        mb_substr($excerpt!==''?$excerpt:$catLabel.' published on the website.',0,200),
        ['news_id'=>$id,'slug'=>$slug,'category'=>$category],$aud,'news_post',$id);
    }
    go($dest);
  }
}

function news_badge(string $cat,array $CATS): string{
  $c=$CATS[$cat]??['label'=>$cat,'tone'=>'grey'];
  return badge($c['label'],$c['tone']);
}
function news_status(string $s,array $STATS): string{
  $c=$STATS[$s]??['label'=>$s,'tone'=>'grey'];
  return badge($c['label'],$c['tone']);
}

if($act==='list'){
  $fq=trim((string)($_GET['q']??''));
  $fcat=(string)($_GET['cat']??'');
  $fstatus=(string)($_GET['status']??'');
  $fpinned=(string)($_GET['pinned']??'');
  if($fcat!==''&&!isset($CATS[$fcat])) $fcat='';
  if($fstatus!==''&&!isset($STATS[$fstatus])) $fstatus='';

  $where=[]; $args=[];
  if($fq!==''){ $where[]='(title LIKE ? OR excerpt LIKE ? OR body LIKE ? OR department LIKE ?)'; $like='%'.$fq.'%'; array_push($args,$like,$like,$like,$like); }
  if($fcat!==''){ $where[]='category=?'; $args[]=$fcat; }
  if($fstatus!==''){ $where[]='status=?'; $args[]=$fstatus; }
  if($fpinned==='1'){ $where[]='pinned=1'; }
  $where[]='deleted_at IS NULL';
  // Everything this member sees is already theirs: a department reads only its
  // own posts, an editor only the kinds it may write, an owner the whole desk.
  $scope=''; $sargs=[];
  if($isContrib){ $where[]='created_by=?'; $args[]=(int)($u['id']??0); $scope=' AND created_by=?'; $sargs[]=(int)($u['id']??0); }
  elseif(!$canAll){ $in=implode(',',array_fill(0,count($allowedCats),'?')); $where[]='category IN('.$in.')'; foreach($allowedCats as $ac) $args[]=$ac; $scope=' AND category IN('.$in.')'; $sargs=$allowedCats; }
  $scope.=' AND deleted_at IS NULL';
  $sql='SELECT * FROM news_posts'.($where?' WHERE '.implode(' AND ',$where):'').' ORDER BY pinned DESC, publish_at DESC, id DESC LIMIT 300';

  $sub=$canAll
    ? 'Hotel news, updates, opportunities and recruitment'
    : ($isContrib
      ? 'Write news and updates for '.($capDept!==''?$capDept:'your department').'. An editor reviews recruitment and the front page.'
      : 'The news, updates and opportunities your team publishes');
  page_head('News & Careers','news',$sub);
  echo '<div class="kpis">';
  kpi_card('Published posts',(string)val("SELECT COUNT(*) FROM news_posts WHERE status='published'".$scope,$sargs),'Visible on the website','ok');
  kpi_card('Pinned',(string)val("SELECT COUNT(*) FROM news_posts WHERE pinned=1 AND status='published'".$scope,$sargs),'Featured on the website','gold');
  if($canAll){
    kpi_card('Recruitment',(string)val("SELECT COUNT(*) FROM news_posts WHERE category='recruitment' AND status='published' AND deleted_at IS NULL",[]),'Open vacancies','warn');
    kpi_card('Employee of the month',(string)val("SELECT COUNT(*) FROM news_posts WHERE category='employee' AND status='published' AND deleted_at IS NULL",[]),'Celebrated colleagues','blue');
  }else{
    kpi_card('Drafts',(string)val("SELECT COUNT(*) FROM news_posts WHERE status='draft'".$scope,$sargs),'Not on the website yet','grey');
    kpi_card('Reach',(string)val("SELECT COALESCE(SUM(views),0) FROM news_posts WHERE status='published'".$scope,$sargs),'Reads on the website','blue');
  }
  echo '</div>';

  echo '<div class="panel">';
  echo '<div class="tbHead" style="display:flex;justify-content:space-between;align-items:center;gap:16px;flex-wrap:wrap">'
    .'<h2 style="margin:0">'.($isContrib?'Your posts':'All posts').'</h2>'
    .'<a class="btn" href="'.BASE.'/index.php?page=news&act=new">New post</a></div>';

  // The same search and filters the website offers, so the console can find a
  // post the moment a colleague asks about it.
  echo '<form class="toolbar" method="get" action="'.BASE.'/index.php" style="gap:10px;flex-wrap:wrap;align-items:flex-end">';
  echo '<input type="hidden" name="page" value="news"/>';
  echo '<div class="field" style="margin:0;min-width:230px;flex:1"><label>Search</label>'
    .'<input type="search" name="q" value="'.e($fq).'" placeholder="Title, excerpt, body or department"/></div>';
  echo '<div class="field" style="margin:0"><label>Category</label><select name="cat"><option value="">All categories</option>';
  foreach(($canAll?$CATS:array_intersect_key($CATS,array_flip($allowedCats))) as $k=>$c){ echo '<option value="'.e($k).'"'.($fcat===$k?' selected':'').'>'.e($c['label']).'</option>'; }
  echo '</select></div>';
  echo '<div class="field" style="margin:0"><label>Status</label><select name="status"><option value="">Any status</option>';
  foreach($STATS as $k=>$c){ echo '<option value="'.e($k).'"'.($fstatus===$k?' selected':'').'>'.e($c['label']).'</option>'; }
  echo '</select></div>';
  echo '<div class="field" style="margin:0"><label>Pinned</label><select name="pinned"><option value="">All</option><option value="1"'.($fpinned==='1'?' selected':'').'>Pinned only</option></select></div>';
  echo '<button class="btn navy" type="submit">Filter</button>';
  if($fq!==''||$fcat!==''||$fstatus!==''||$fpinned!=='') echo '<a class="btn ghost" href="'.BASE.'/index.php?page=news">Clear</a>';
  echo '</form>';

  $list=rows($sql,$args);
  echo '<table class="tbl"><thead><tr><th></th><th>Title</th><th>Category</th><th>Status</th><th>Flags</th><th>Author</th><th>Published</th><th>Views</th><th></th></tr></thead><tbody>';
  if(!$list){ echo '<tr><td colspan="9" style="text-align:center;color:var(--muted);padding:26px">No posts match. '.($fq!==''||$fcat!==''||$fstatus!==''||$fpinned!==''?'Try clearing the filters, or c':'C').'reate the first one.</td></tr>'; }
  foreach($list as $r){
    $img=news_image_src((string)($r['image']??''));
    $link=SITE_URL.'/news.html#'.rawurlencode((string)$r['slug']);
    echo '<tr>';
    echo '<td style="width:64px">'.($img?'<img src="'.e($img).'" alt="" style="width:52px;height:40px;object-fit:cover;border-radius:5px;border:1px solid var(--line2)"/>':'<span style="display:inline-block;width:52px;height:40px;border-radius:5px;background:#f1ede2"></span>').'</td>';
    echo '<td><b>'.e($r['title']).'</b><br><small>'.e($r['slug']).'</small></td>';
    echo '<td>'.news_badge((string)$r['category'],$CATS).'</td>';
    echo '<td>'.news_status((string)$r['status'],$STATS).'</td>';
    echo '<td>'.((int)$r['pinned']?badge('Pinned','gold'):'').(($r['category']==='recruitment'&&(string)($r['deadline']??'')!=='')?' '.badge('Closes '.fmtdate($r['deadline']),'warn'):'').'</td>';
    echo '<td>'.e($r['author_name']?:'â€”').($r['author_role']?'<br><small>'.e($r['author_role']).'</small>':'').'</td>';
    echo '<td>'.e(fmtdt($r['publish_at'])).'</td>';
    echo '<td>'.(int)$r['views'].'</td>';
    echo '<td style="white-space:nowrap">';
    echo '<a class="btn sm blue" href="'.e($link).'" target="_blank" rel="noopener">View</a> ';
    echo '<a class="btn sm navy" href="'.BASE.'/index.php?page=news&act=edit&id='.(int)$r['id'].'">Edit</a> ';
    form_open('news','publish',['id'=>$r['id']],['style'=>'display:inline']);
    echo '<button class="btn sm '.(($r['status']==='published')?'blue':'tick').'" type="submit">'.(($r['status']==='published')?'Unpublish':'Publish').'</button>';
    form_close();
    form_open('news','delete',['id'=>$r['id']],['style'=>'display:inline','onsubmit'=>"return confirm('Move this post to the Trash? You can restore it from the Trash page.')"]);
    echo '<button class="btn sm danger" type="submit">Delete</button>';
    form_close();
    echo '</td>';
    echo '</tr>';
  }
  echo '</tbody></table>';
  echo '</div>';
  page_foot(); exit;
}

if($act==='edit'||$act==='new'){
  $id=$act==='edit'?(int)($_GET['id']??0):0;
  $r=$id>0?row('SELECT * FROM news_posts WHERE id=?',[$id]):null;
  if($act==='edit'&&!$r){ flash('Post not found.','bad'); go('news'); }
  if($act==='edit'&&!$inScope($r)){ flash('That post does not belong to you. Ask an editor to change it.','bad'); go('news'); }

  $val=static function(string $k,string $d='') use($r): string{ return (string)($r[$k]??$d); };
  $cat=$val('category',$allowedCats[0]);
  if(!isset($CATS[$cat])||(!$canAll&&!in_array($cat,$allowedCats,true))) $cat=$allowedCats[0];
  $status=$val('status','published');
  if(!isset($STATS[$status])) $status='published';
  $publish=$val('publish_at',date('Y-m-d H:i'));
  if($publish!=='') $publish=substr(str_replace('T',' ',$publish),0,16);
  $image=$val('image');
  $imageSrc=news_image_src($image);
  $slug=$val('slug');
  $preview=$slug!==''&&$status==='published'?SITE_URL.'/news.html#'.rawurlencode($slug):'';
  $showVacancy=array_intersect(['recruitment','opportunity'],$allowedCats)!==[];

  $formSub=$canAll
    ? 'Write news, updates, opportunities or a vacancy'
    : ($isContrib ? 'Write a news item or a service update for '.($capDept!==''?$capDept:'your department') : 'Write a news item, a service update or an opportunity');
  page_head($id?'Edit post':'New post','news',$formSub);
  // The form carries a photograph, so it must be sent as multipart data.
  form_open('news','save',[],['enctype'=>'multipart/form-data']);
  echo '<input type="hidden" name="id" value="'.$id.'"/>';
  echo '<div class="panel">';
  echo '<div class="twoCol" style="align-items:flex-start">';

  /* ---- the writing ---- */
  echo '<div class="col">';
  field('Title','title',$val('title'),'text','The headline shown on the website and in listings',true);
  field('Slug','slug',$val('slug'),'text','URL-friendly address (auto-generated from the title when blank)');
  area('Excerpt','excerpt',$val('excerpt'),'One or two sentences shown on the card (max 320 characters)');
  area('Body','body',$val('body'),'The full story or vacancy details. A blank line starts a new paragraph.','',10);
  echo '</div>';

  /* ---- the controls ---- */
  echo '<div class="col">';
  echo '<div class="field"><label for="f_category">Category</label><select id="f_category" name="category">';
  foreach(($canAll?$CATS:array_intersect_key($CATS,array_flip($allowedCats))) as $k=>$c){ echo '<option value="'.e($k).'"'.($cat===$k?' selected':'').'>'.e($c['label']).'</option>'; }
  echo '</select><small class="hint">'.($isContrib?'A general news item or a service update.':($canAll?'Recruitment is for vacancies, Employee of the month for the colleague being honoured.':'News, a service update, or an opportunity for the community.')).'</small></div>';
  echo '<div class="field"><label for="f_status">Status</label><select id="f_status" name="status">';
  foreach($STATS as $k=>$c){ echo '<option value="'.e($k).'"'.($status===$k?' selected':'').'>'.e($c['label']).'</option>'; }
  echo '</select></div>';
  field('Publish at','publish_at',$publish,'datetime-local','Leave blank to publish immediately');
  if(!$isContrib){
    echo '<label class="check" style="display:flex;align-items:center;gap:8px;margin:4px 0 14px"><input type="checkbox" name="pinned" value="1"'.((int)$val('pinned')===1?' checked':'').'/> Pin to the top (featured)</label>';
  }

  /* ---- the photograph ---- */
  echo '<div class="field"><label for="f_image_file">Main photograph</label>';
  echo '<div style="display:flex;gap:14px;align-items:flex-start">';
  echo '<img id="newsPrev" src="'.($imageSrc?e($imageSrc):SITE_URL.'/images/Hotel-Paradise-on-the-Nile-Logo.webp').'" alt="" style="width:120px;height:90px;object-fit:cover;border-radius:6px;border:1px solid var(--line2);background:#f1ede2;flex:none"/>';
  echo '<div style="flex:1"><input id="f_image_file" type="file" name="image_file" accept="image/*"/>';
  echo '<small class="hint" style="display:block;margin-top:6px">Upload a JPG, PNG, GIF or WebP up to 4MB. Shown at the head of the post.</small>';
  if($imageSrc){
    echo '<label class="check" style="display:flex;align-items:center;gap:8px;margin-top:8px;font-size:13px"><input type="checkbox" name="image_remove" value="1"/> Remove the current photograph</label>';
  }
  echo '</div></div></div>';
  field('Or photograph URL','image',$image,'text','Leave as it is to keep the current picture. Paste a full web address to use an image hosted elsewhere.');

  /* ---- the vacancy detail, only where the role may write one ---- */
  if($showVacancy){
    echo '<div class="panel" id="vacancyPanel" style="background:#fafbfd;margin:6px 0 0;box-shadow:none">';
    echo '<h3 style="margin:0 0 4px">Vacancy &amp; opportunity details</h3>';
    echo '<p class="hint" style="margin:0 0 12px">Fill these for a recruitment or opportunity post. They are shown in the apply panel on the website.</p>';
    field('Department','department',$val('department'),'text','e.g. Housekeeping, Food and Beverage, Human Resource');
    field('Location','location',$val('location'),'text','e.g. Hotel Paradise, Jinja');
    field('Employment type','employment_type',$val('employment_type'),'text','e.g. Full-time, Part-time, Internship');
    field('Salary','salary',$val('salary'),'text','e.g. Competitive, negotiable, UGX 2,000,000');
    field('Application deadline','deadline',substr($val('deadline'),0,10),'date');
    field('Apply by email','apply_email',$val('apply_email'),'email');
    field('Apply by URL','apply_url',$val('apply_url'),'url');
    echo '</div>';
  }elseif($capDept!==''){
    field('Department','department_note',$capDept,'text','Your posts are filed under '.$capDept.'.',false,true);
  }

  field('Author name','author_name',$val('author_name',$u['name']??''),'text','Who signs the post on the website');
  field('Author role','author_role',$val('author_role',$capLabel),'text','e.g. Human Resource, Management Team');
  echo '</div>';
  echo '</div>';

  echo '<div style="margin-top:18px;display:flex;gap:10px;flex-wrap:wrap">';
  echo '<button class="btn" type="submit">'.($id?'Save changes':'Publish post').'</button>';
  if($preview) echo '<a class="btn ghost2" href="'.e($preview).'" target="_blank" rel="noopener">Preview on site</a>';
  echo '<a class="btn ghost" href="'.BASE.'/index.php?page=news">Cancel</a>';
  echo '</div>';
  form_close();
  echo '</div>';

  // Live preview of the chosen photograph, and the vacancy panel appears only
  // for a category that carries vacancy detail.
  echo '<script>(function(){'
    .'var i=document.getElementById("f_image_file"),p=document.getElementById("newsPrev");'
    .'if(i&&p){i.addEventListener("change",function(e){var f=e.target.files&&e.target.files[0];if(!f)return;'
    .'var rd=new FileReader();rd.onload=function(ev){p.src=ev.target.result};rd.readAsDataURL(f);});}'
    .'var s=document.getElementById("f_category"),v=document.getElementById("vacancyPanel");'
    .'if(s&&v){var t=function(){v.style.display=(s.value==="recruitment"||s.value==="opportunity")?"":"none"};s.addEventListener("change",t);t();}'
    .'})();</script>';
  page_foot(); exit;
}

flash('Unknown action.','bad'); go('news');
