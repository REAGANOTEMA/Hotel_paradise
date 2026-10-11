<?php
declare(strict_types=1);

/**
 * News, Updates, Opportunities and Careers.
 *
 * Everything the hotel wants to publish to the public - announcements, updates,
 * opportunities for the community, recruitment vacancies and the employee of the
 * month - lives in one table. This console gives the authorised team (marketing,
 * human resource, events, management) a place to write, edit, pin, unpublish and
 * remove those posts.
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
      body MEDIUMTEXT NULL,
      image VARCHAR(255) NULL,
      department VARCHAR(120) NULL,
      location VARCHAR(120) NULL,
      employment_type VARCHAR(60) NULL,
      salary VARCHAR(120) NULL,
      deadline DATE NULL,
      apply_email VARCHAR(160) NULL,
      apply_url VARCHAR(300) NULL,
      author_name VARCHAR(120) NULL,
      author_role VARCHAR(120) NULL,
      pinned TINYINT(1) NOT NULL DEFAULT 0,
      status VARCHAR(20) NOT NULL DEFAULT \'published\',
      publish_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      views INT UNSIGNED NOT NULL DEFAULT 0,
      created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
      updated_at DATETIME NULL,
      PRIMARY KEY(id),
      UNIQUE KEY uq_news_slug(slug),
      KEY idx_news_cat(category),
      KEY idx_news_status(status,publish_at),
      KEY idx_news_pinned(pinned,publish_at)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
  }
}

$u=current_user();
ensure_news_table();

$CATS=[
  'news'=>['label'=>'News & announcements','tone'=>'navy'],
  'update'=>['label'=>'Updates & notices','tone'=>'blue'],
  'opportunity'=>['label'=>'Opportunities','tone'=>'gold'],
  'recruitment'=>['label'=>'Recruitment','tone'=>'warn'],
  'employee'=>['label'=>'Employee of the month','tone'=>'ok'],
];
$STATS=['published'=>['label'=>'Published','tone'=>'ok'],'draft'=>['label'=>'Draft','tone'=>'grey']];

$act=$_GET['act']??'list';

if($_SERVER['REQUEST_METHOD']==='POST'){
  $a=$_GET['act']??'';
  if($a==='delete'){
    $id=(int)($_POST['id']??0);
    $r=row('SELECT * FROM news_posts WHERE id=?',[$id]);
    if($r){
      q('DELETE FROM news_posts WHERE id=?',[$id]);
      audit('news_delete','news_posts',$id,['slug'=>$r['slug'],'title'=>$r['title']]);
      flash('Post deleted.');
    }else{
      flash('Post not found.','bad');
    }
    go('news');
  }
  if($a==='save'){
    $id=(int)($_POST['id']??0);
    $title=trim((string)($_POST['title']??''));
    $slug=trim((string)($_POST['slug']??''));
    if($slug===''){
      $slug=strtolower(preg_replace('/[^a-zA-Z0-9\-]+/','-',mb_strtolower($title)));
      $slug=trim($slug,'-');
      if($slug==='') $slug='post-'.date('Ymd-His');
    }
    $slug=preg_replace('/[^a-zA-Z0-9\-]/','-',$slug);
    $slug=trim(preg_replace('/-+/','-',$slug),'-');
    $cat=(string)($_POST['category']??'news');
    if(!isset($CATS[$cat])) $cat='news';
    $excerpt=mb_substr(trim((string)($_POST['excerpt']??'')),0,320);
    $body=(string)($_POST['body']??'');
    $image=trim((string)($_POST['image']??''));
    $department=trim((string)($_POST['department']??''));
    $location=trim((string)($_POST['location']??''));
    $employment_type=trim((string)($_POST['employment_type']??''));
    $salary=trim((string)($_POST['salary']??''));
    $deadline=trim((string)($_POST['deadline']??''));
    $apply_email=strtolower(trim((string)($_POST['apply_email']??'')));
    $apply_url=trim((string)($_POST['apply_url']??''));
    $author_name=trim((string)($_POST['author_name']??($u['name']??'')));
    $author_role=trim((string)($_POST['author_role']??''));
    $pinned=(int)((bool)($_POST['pinned']??0));
    $status=(string)($_POST['status']??'published');
    if(!isset($STATS[$status])) $status='published';
    $publish_at=trim((string)($_POST['publish_at']??''));
    if($publish_at==='') $publish_at=date('Y-m-d H:i:s');

    if($title===''){ flash('Title is required.','bad'); go('news'); }

    if($id>0){
      $exists=row('SELECT id FROM news_posts WHERE slug=? AND id!=?',[$slug,$id]);
      if($exists){ flash('That slug is already in use. Choose another.','bad'); go('news','act=edit&id='.$id); }
      q('UPDATE news_posts SET slug=?,title=?,category=?,excerpt=?,body=?,image=?,department=?,location=?,employment_type=?,salary=?,deadline=?,apply_email=?,apply_url=?,author_name=?,author_role=?,pinned=?,status=?,publish_at=?,updated_at=NOW() WHERE id=?',
        [$slug,$title,$cat,$excerpt,$body,$image,$department,$location,$employment_type,$salary,$deadline,$apply_email,$apply_url,$author_name,$author_role,$pinned,$status,$publish_at,$id]);
      audit('news_update','news_posts',$id,['slug'=>$slug]);
      flash('Post updated.');
    }else{
      $exists=row('SELECT id FROM news_posts WHERE slug=?',[$slug]);
      if($exists){ flash('That slug is already in use. Choose another.','bad'); go('news','act=new'); }
      q('INSERT INTO news_posts(hotel_id,slug,title,category,excerpt,body,image,department,location,employment_type,salary,deadline,apply_email,apply_url,author_name,author_role,pinned,status,publish_at,created_at) VALUES(1,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,NOW())',
        [$slug,$title,$cat,$excerpt,$body,$image,$department,$location,$employment_type,$salary,$deadline,$apply_email,$apply_url,$author_name,$author_role,$pinned,$status,$publish_at]);
      $nid=(int)db()->lastInsertId();
      audit('news_create','news_posts',$nid,['slug'=>$slug]);
      flash('Post published.');
    }
  }
  go('news');
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
  page_head('News & Careers','news','Hotel news, updates, opportunities and recruitment');
  echo '<div class="kpis">';
  kpi_card('Published posts',(string)val("SELECT COUNT(*) FROM news_posts WHERE status='published'"),'Visible on the website','ok');
  kpi_card('Pinned',(string)val("SELECT COUNT(*) FROM news_posts WHERE pinned=1 AND status='published'"),'Featured on the homepage','gold');
  kpi_card('Recruitment',(string)val("SELECT COUNT(*) FROM news_posts WHERE category='recruitment' AND status='published'"),'Open vacancies','warn');
  kpi_card('Opportunities',(string)val("SELECT COUNT(*) FROM news_posts WHERE category='opportunity' AND status='published'"),'Community opportunities','blue');
  echo '</div>';
  echo '<div class="panel">';
  echo '<div class="tbHead" style="justify-content:space-between;align-items:center"><h2>All posts</h2><a class="btn" href="'.BASE.'/index.php?page=news&act=new">New post</a></div>';
  echo '<table class="tbl"><thead><tr><th>Title</th><th>Category</th><th>Status</th><th>Pinned</th><th>Author</th><th>Published</th><th>Views</th><th></th></tr></thead><tbody>';
  $list=rows('SELECT * FROM news_posts ORDER BY pinned DESC, publish_at DESC, id DESC LIMIT 200',[]);
  if(!$list){ echo '<tr><td colspan="8" style="text-align:center;color:var(--muted)">No posts yet. Create the first one.</td></tr>'; }
  foreach($list as $r){
    echo '<tr>';
    echo '<td><b>'.e($r['title']).'</b><br><small>'.e($r['slug']).'</small></td>';
    echo '<td>'.news_badge((string)$r['category'],$CATS).'</td>';
    echo '<td>'.news_status((string)$r['status'],$STATS).'</td>';
    echo '<td>'.((int)$r['pinned']?badge('Pinned','gold'):'—').'</td>';
    echo '<td>'.e($r['author_name']?:'—').($r['author_role']?'<br><small>'.e($r['author_role']).'</small>':'').'</td>';
    echo '<td>'.e(fmtdt($r['publish_at'])).'</td>';
    echo '<td class="num">'.(int)$r['views'].'</td>';
    echo '<td style="white-space:nowrap">';
    echo '<a class="btn sm navy" href="'.BASE.'/index.php?page=news&act=edit&id='.(int)$r['id'].'">Edit</a> ';
    form_open('news','delete',['id'=>$r['id']],['style'=>'display:inline']);
    echo '<button class="btn sm bad" type="submit" onclick="return confirm(\'Delete this post? This cannot be undone.\')">Delete</button>';
    form_close();
    echo '</td>';
    echo '</tr>';
  }
  echo '</tbody></table></div>';
  page_foot(); exit;
}

if($act==='new'||$act==='edit'){
  $id=(int)($_GET['id']??0);
  $r=null;
  if($act==='edit'&&$id>0){ $r=row('SELECT * FROM news_posts WHERE id=?',[$id]); }
  if($act==='edit'&&!$r){ flash('Post not found.','bad'); go('news'); }
  $title=(string)($r['title']??'');
  $slug=(string)($r['slug']??'');
  $cat=(string)($r['category']??'news');
  $excerpt=(string)($r['excerpt']??'');
  $body=(string)($r['body']??'');
  $image=(string)($r['image']??'');
  $department=(string)($r['department']??'');
  $location=(string)($r['location']??'');
  $employment_type=(string)($r['employment_type']??'');
  $salary=(string)($r['salary']??'');
  $deadline=(string)($r['deadline']??'');
  $apply_email=(string)($r['apply_email']??'');
  $apply_url=(string)($r['apply_url']??'');
  $author_name=(string)($r['author_name']??($u['name']??''));
  $author_role=(string)($r['author_role']??'');
  $pinned=(int)($r['pinned']??0);
  $status=(string)($r['status']??'published');
  $publish_at=(string)($r['publish_at']??date('Y-m-d H:i:s'));
  if(strlen($publish_at)>16) $publish_at=substr($publish_at,0,16);

  page_head($act==='edit'?'Edit post':'New post','news','Write news, updates, opportunities or a vacancy');
  echo '<div class="panel">';
  form_open('news','save',['id'=>$id]);
  echo '<div class="grid" style="grid-template-columns:2fr 1fr;gap:20px">';
  echo '<div class="col">';
  field('Title','title',$title,'text','Title for the public page',true);
  field('Slug','slug',$slug,'text','URL-friendly identifier (auto-generated if left blank)');
  area('Excerpt','excerpt',$excerpt,'Short description shown in cards and lists (max 320 characters)');
  area('Body','body',$body,'Full article or vacancy details (line breaks become paragraphs)','',8);
  echo '</div>';
  echo '<div class="col">';
  echo '<div class="field"><label>Category</label><select name="category">';
  foreach($CATS as $k=>$c){ echo '<option value="'.e($k).'"'.checked($cat,$k).'>'.e($c['label']).'</option>'; }
  echo '</select></div>';
  echo '<div class="field"><label>Status</label><select name="status">';
  foreach($STATS as $k=>$c){ echo '<option value="'.e($k).'"'.checked($status,$k).'>'.e($c['label']).'</option>'; }
  echo '</select></div>';
  field('Publish at','publish_at',$publish_at,'datetime-local');
  echo '<label class="check" style="margin:8px 0 12px;display:flex;align-items:center;gap:8px"><input type="checkbox" name="pinned" value="1"'.checked($pinned,1).'/> Pin to the top (featured)</label>';
  field('Main image URL','image',$image,'url','Optional: e.g. ./images/news/photo.webp');
  field('Department','department',$department,'text','e.g. Housekeeping, Food and Beverage, Human Resource');
  field('Location','location',$location,'text','e.g. Hotel Paradise, Jinja');
  field('Employment type','employment_type',$employment_type,'text','e.g. Full-time, Part-time, Internship');
  field('Salary','salary',$salary,'text','e.g. Competitive, negotiable, UGX 2,000,000');
  field('Application deadline','deadline',$deadline,'date');
  field('Apply by email','apply_email',$apply_email,'email');
  field('Apply by URL','apply_url',$apply_url,'url');
  field('Author name','author_name',$author_name,'text');
  field('Author role','author_role',$author_role,'text');
  echo '</div>';
  echo '</div>';
  echo '<div style="margin-top:16px;display:flex;gap:10px">';
  echo '<button class="btn" type="submit">Save post</button>';
  echo '<a class="btn ghost" href="'.BASE.'/index.php?page=news">Cancel</a>';
  echo '</div>';
  form_close();
  echo '</div>';
  page_foot(); exit;
}

flash('Unknown action.','bad'); go('news');
