<?php
declare(strict_types=1);

/**
 * Reactions and comments on the hotel's public newsroom.
 *
 * The two tables this reads and writes are created here, on first use, with
 * CREATE TABLE IF NOT EXISTS only. Nothing in this file alters an existing
 * table, so it is safe on a database that has been running for years and on a
 * fresh installation alike. The patch under database/sql/patches carries the
 * same two statements for a host that prefers to run schema changes by hand.
 *
 * A visitor is never identified by an address they can choose. The browser is
 * asked for a random id it keeps in local storage, or the request may carry the
 * signed-in customer's session token; either way only a sha256 of that value is
 * stored, and a signed-in guest is hashed from their customer record rather
 * than from the token itself. No email, address or token is kept beside it.
 */

if(!function_exists('ensure_news_social_tables')){
  function ensure_news_social_tables(): void{
    try{
      q('CREATE TABLE IF NOT EXISTS news_reactions(
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
        news_id BIGINT UNSIGNED NOT NULL,
        reaction VARCHAR(16) NOT NULL,
        visitor_hash CHAR(64) NOT NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY(id),
        UNIQUE KEY uq_news_reaction(news_id, visitor_hash),
        KEY idx_news_reaction_news(news_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');

      q('CREATE TABLE IF NOT EXISTS news_comments(
        id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
        news_id BIGINT UNSIGNED NOT NULL,
        parent_id BIGINT UNSIGNED NULL,
        name VARCHAR(80) NOT NULL,
        email VARCHAR(160) NULL,
        body TEXT NOT NULL,
        visitor_hash CHAR(64) NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT \'published\',
        ip_hash CHAR(64) NULL,
        created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY(id),
        KEY idx_news_comments_news(news_id, status, created_at),
        KEY idx_news_comments_parent(parent_id)
      ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
    }catch(Throwable $e){
      error_log('[hotel news social] could not ensure tables: '.$e->getMessage());
    }
  }
}

/** The reactions the hotel publishes, and the house order they are shown in. */
if(!function_exists('news_reaction_kinds')){
  function news_reaction_kinds(): array{
    return ['like','love','applause'];
  }
}

/**
 * A stable, anonymous hash for the person reacting or commenting.
 *
 * A valid signed-in customer wins over a browser id, so the same account is the
 * same person on a phone and a laptop. Otherwise the random id the browser kept
 * is used. Only the hash leaves this function; the token and the browser id are
 * never stored. An empty string means the request carried neither.
 */
if(!function_exists('news_visitor_hash')){
  function news_visitor_hash(string $token='', string $visitor=''): string{
    $token=trim($token);
    if($token!=='' && function_exists('api_customer_from_token')){
      $c=api_customer_from_token($token);
      if($c && isset($c['id'])) return hash('sha256','customer:'.(int)$c['id']);
    }
    $visitor=trim($visitor);
    // The browser id is ours, but it still arrives from the network: keep it to
    // the harmless characters a random id is made of and cap its length.
    $visitor=preg_replace('/[^A-Za-z0-9_.:-]/','',$visitor) ?? '';
    if($visitor==='' || strlen($visitor)>128) return '';
    return hash('sha256','visitor:'.$visitor);
  }
}

/** A hash of the caller's address for rate limiting; never stored raw. */
if(!function_exists('news_ip_hash')){
  function news_ip_hash(): string{
    $ip=(string)($_SERVER['REMOTE_ADDR']??'');
    return $ip===''?'':hash('sha256','ip:'.$ip);
  }
}

/** The three legal reactions set to zero, so the response shape is stable. */
if(!function_exists('news_empty_reaction_totals')){
  function news_empty_reaction_totals(): array{
    return ['like'=>0,'love'=>0,'applause'=>0];
  }
}

/** Reaction counts for one story. */
if(!function_exists('news_reaction_totals')){
  function news_reaction_totals(int $newsId): array{
    $out=news_empty_reaction_totals();
    if($newsId<=0 || table_columns('news_reactions')===[]) return $out;
    foreach(rows('SELECT reaction,COUNT(*) AS c FROM news_reactions WHERE news_id=? GROUP BY reaction',[$newsId]) as $r){
      $kind=(string)($r['reaction']??'');
      if(array_key_exists($kind,$out)) $out[$kind]=(int)($r['c']??0);
    }
    return $out;
  }
}

/**
 * Reaction counts for every story at once, keyed by news id, so the list does
 * not make one query per card.
 */
if(!function_exists('news_reaction_totals_all')){
  function news_reaction_totals_all(): array{
    $out=[];
    if(table_columns('news_reactions')===[]) return $out;
    foreach(rows('SELECT news_id,reaction,COUNT(*) AS c FROM news_reactions GROUP BY news_id,reaction') as $r){
      $id=(int)($r['news_id']??0);
      $kind=(string)($r['reaction']??'');
      if($id<=0 || !in_array($kind,news_reaction_kinds(),true)) continue;
      if(!isset($out[$id])) $out[$id]=news_empty_reaction_totals();
      $out[$id][$kind]=(int)($r['c']??0);
    }
    return $out;
  }
}

/** The reaction this visitor has chosen on one story, or an empty string. */
if(!function_exists('news_my_reaction')){
  function news_my_reaction(int $newsId, string $visitorHash): string{
    if($newsId<=0 || $visitorHash==='' || table_columns('news_reactions')===[]) return '';
    $r=row('SELECT reaction FROM news_reactions WHERE news_id=? AND visitor_hash=? LIMIT 1',[$newsId,$visitorHash]);
    return $r?(string)$r['reaction']:'';
  }
}

/** Every reaction this visitor has chosen, keyed by news id. */
if(!function_exists('news_my_reactions')){
  function news_my_reactions(string $visitorHash): array{
    $out=[];
    if($visitorHash==='' || table_columns('news_reactions')===[]) return $out;
    foreach(rows('SELECT news_id,reaction FROM news_reactions WHERE visitor_hash=?',[$visitorHash]) as $r){
      $out[(int)$r['news_id']]=(string)$r['reaction'];
    }
    return $out;
  }
}

/** How many published comments a story has. */
if(!function_exists('news_comment_count')){
  function news_comment_count(int $newsId): int{
    if($newsId<=0 || table_columns('news_comments')===[]) return 0;
    $r=row("SELECT COUNT(*) AS c FROM news_comments WHERE news_id=? AND status='published'",[$newsId]);
    return $r?(int)$r['c']:0;
  }
}

/** Published comment counts for every story at once, keyed by news id. */
if(!function_exists('news_comment_counts_all')){
  function news_comment_counts_all(): array{
    $out=[];
    if(table_columns('news_comments')===[]) return $out;
    foreach(rows("SELECT news_id,COUNT(*) AS c FROM news_comments WHERE status='published' GROUP BY news_id") as $r){
      $out[(int)$r['news_id']]=(int)$r['c'];
    }
    return $out;
  }
}

/**
 * The published comments on a story, oldest first, as the article prints them.
 * The email address is deliberately left out of the response: it is for the
 * hotel's records, not for the public thread.
 */
if(!function_exists('news_published_comments')){
  function news_published_comments(int $newsId, int $limit=200): array{
    if($newsId<=0 || table_columns('news_comments')===[]) return [];
    $limit=max(1,min(500,$limit));
    $rows=rows("SELECT id,parent_id,name,body,created_at FROM news_comments
      WHERE news_id=? AND status='published'
      ORDER BY created_at ASC, id ASC LIMIT ".$limit,[$newsId]);
    return array_map(static function(array $c): array{
      return [
        'id'=>(int)$c['id'],
        'parent_id'=>isset($c['parent_id'])?(int)$c['parent_id']:null,
        'name'=>(string)$c['name'],
        'body'=>(string)$c['body'],
        'created_at'=>substr((string)$c['created_at'],0,16)
      ];
    },$rows);
  }
}

/** Whether this visitor has left too many comments in the last ten minutes. */
if(!function_exists('news_comment_rate_limited')){
  function news_comment_rate_limited(string $visitorHash, string $ipHash=''): bool{
    if(table_columns('news_comments')===[] || $visitorHash==='') return false;
    $r=row("SELECT COUNT(*) AS c FROM news_comments
      WHERE visitor_hash=? AND created_at>=DATE_SUB(NOW(),INTERVAL 10 MINUTE)",[$visitorHash]);
    if($r && (int)$r['c']>=3) return true;
    if($ipHash!==''){
      $r=row("SELECT COUNT(*) AS c FROM news_comments
        WHERE ip_hash=? AND created_at>=DATE_SUB(NOW(),INTERVAL 10 MINUTE)",[$ipHash]);
      if($r && (int)$r['c']>=10) return true;
    }
    return false;
  }
}

/** Writes a published comment and answers with the shape the thread prints. */
if(!function_exists('news_insert_comment')){
  function news_insert_comment(int $newsId, string $name, string $email, string $body, string $visitorHash, string $ipHash=''): array{
    q('INSERT INTO news_comments(news_id,parent_id,name,email,body,visitor_hash,status,ip_hash,created_at)
       VALUES(?,NULL,?,?,?,?,\'published\',?,NOW())',
      [$newsId,$name,($email===''?null:$email),$body,$visitorHash,($ipHash===''?null:$ipHash)]);
    $id=(int)db()->lastInsertId();
    $c=row('SELECT id,parent_id,name,body,created_at FROM news_comments WHERE id=?',[$id]);
    return [
      'id'=>(int)($c['id']??$id),
      'parent_id'=>null,
      'name'=>(string)($c['name']??$name),
      'body'=>(string)($c['body']??$body),
      'created_at'=>substr((string)($c['created_at']??date('Y-m-d H:i:s')),0,16)
    ];
  }
}
