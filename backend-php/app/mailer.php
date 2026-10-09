<?php
declare(strict_types=1);

/**
 * Outgoing email, the hotel's own.
 *
 * One place turns a message the hotel wants to send into something a mail
 * server will carry, whether that server is the machine this site runs on or a
 * hosted provider. Two transports are supported:
 *
 *   mail  - PHP's own mail() call. Right when the machine has a working
 *           sendmail/MTA and the site shares its host.
 *   smtp  - a small, self-contained SMTP conversation (with STARTTLS or SSL and
 *           AUTH LOGIN). Right for every real provider - Google Workspace,
 *           Microsoft 365, Zoho, Mailgun, Sendgrid - because it needs no
 *           library and no Composer.
 *
 * The settings are read from config.php under a "mail" key and can be
 * overridden by environment variables, so the same code works on a developer's
 * machine and in production with nothing edited on the way. Nothing here ever
 * throws: a broken mail server must never fail a payment or a booking. The
 * caller is told, in words, whether the message left and, if it did not, why.
 *
 * The three public entry points are:
 *
 *   mail_send($to,$subject,$html,$text,$opts)  send one message
 *   mail_html($title,$body,$preheader)         a branded HTML shell
 *   mail_configured()                          whether a transport is set up
 */

require_once __DIR__.'/bootstrap.php';

/** The hotel's published contact details, used in the messages and the footer. */
const MAIL_HOTEL_NAME='Hotel Paradise on the Nile';
const MAIL_HOTEL_CITY='Jinja, Uganda';
const MAIL_HOTEL_PHONE='+256 759 504 928';
const MAIL_HOTEL_EMAIL='frontdesk@hotelparadiseonthenile.info';
const MAIL_HOTEL_SITE='www.hotelparadiseonthenile.info';

/**
 * Where mail settings live.
 *
 * config.php is read first, then the environment, then a sensible default. The
 * environment wins so a host can be configured without touching a file, and the
 * file wins over the default so a local install can be pointed at a real
 * provider once. A missing config file is not an error: the site simply falls
 * back to the local mail() call.
 */
function mail_config(): array
{
 static $cfg=null;
 if($cfg!==null) return $cfg;

 $file=__DIR__.'/../config.php';
 $fromFile=is_readable($file)?require $file:[];
 if(!is_array($fromFile)) $fromFile=[];
 $m=(isset($fromFile['mail'])&&is_array($fromFile['mail']))?$fromFile['mail']:[];

 $pick=function(string $key,string $env,string $default) use ($m): string {
  $v=getenv($env);
  if(is_string($v)&&$v!=='') return $v;
  if(isset($m[$key])&&is_string($m[$key])&&$m[$key]!=='') return $m[$key];
  return $default;
 };

 $host=strtolower($pick('host','HP_MAIL_HOST',''));
 $secure=strtolower($pick('secure','HP_MAIL_SECURE','tls'));
 $user=$pick('username','HP_MAIL_USER','');
 $transport=strtolower($pick('transport','HP_MAIL_TRANSPORT',''));
 // A transport is only as real as its settings. If a host was given but no
 // transport was written down, smtp is what the writer meant; if there is no
 // host at all, the only thing left is the local mail() call.
 if($transport===''||!in_array($transport,['mail','smtp','log'],true)){
  $transport=$host!==''?'smtp':'mail';
 }

 $cfg=[
  'transport'=>$transport,
  'host'=>$host,
  'port'=>(int)$pick('port','HP_MAIL_PORT',$secure==='ssl'?'465':'587'),
  'secure'=>in_array($secure,['tls','ssl','none'],true)?$secure:'tls',
  'username'=>$user,
  'password'=>$pick('password','HP_MAIL_PASS',''),
  'from_email'=>$pick('from_email','HP_MAIL_FROM',MAIL_HOTEL_EMAIL),
  'from_name'=>$pick('from_name','HP_MAIL_FROM_NAME',MAIL_HOTEL_NAME),
  'reply_to'=>$pick('reply_to','HP_MAIL_REPLY',MAIL_HOTEL_EMAIL),
  'timeout'=>(int)$pick('timeout','HP_MAIL_TIMEOUT','15'),
 ];
 return $cfg;
}

/** Whether the site has enough settings to attempt a send at all. */
function mail_configured(): bool
{
 $c=mail_config();
 if($c['transport']==='log') return true;
 if($c['transport']==='smtp') return $c['host']!=='';
 // mail() is always "configured"; whether the machine can deliver is another
 // question, and the caller hears about that in the result.
 return true;
}

/** A display name and address, quoted the way a mail header needs them. */
function mail_from_header(string $email,string $name=''): string
{
 $email=trim($email);
 if($name==='') return '<'.$email.'>';
 // Only the name is encoded, never the address, so the header stays valid.
 $safe=str_replace(["\r","\n",'"'],['','',"'"],$name);
 return mail_encode($safe).' <'.$email.'>';
}

/** A header value that may hold non-ASCII text, encoded as a MIME word. */
function mail_encode(string $text): string
{
 if(!preg_match('/[^\x20-\x7E]/',$text)) return $text;
 return '=?UTF-8?B?'.base64_encode($text).'?=';
}

/**
 * The walls of the branded email.
 *
 * Every message the hotel sends is the same shape: a gold bar, the crest, the
 * title, the body, and a quiet footer with the phone, the email and the
 * address. It is written with inline styles and a single table because email
 * clients strip <style> and dislike modern layout, so the design has to live in
 * attributes to survive Outlook, Gmail and a phone alike.
 */
function mail_html(string $title,string $bodyHtml,string $preheader=''): string
{
 $logo=mail_public_url('/images/paradise-logo.png');
 $pre=$preheader!==''?'<span style="display:none;visibility:hidden;opacity:0;height:0;width:0;overflow:hidden">'.e($preheader).'</span>':'';
 return '<!doctype html><html lang="en"><head><meta charset="utf-8">'
  .'<meta name="viewport" content="width=device-width,initial-scale=1">'
  .'<meta name="color-scheme" content="light only"><title>'.e($title).'</title></head>'
  .'<body style="margin:0;padding:0;background:#f2f4f8;-webkit-text-size-adjust:100%">'.$pre
  .'<table role="presentation" width="100%" cellpadding="0" cellspacing="0" style="background:#f2f4f8;padding:24px 12px">'
  .'<tr><td align="center">'
  .'<table role="presentation" width="600" cellpadding="0" cellspacing="0" style="max-width:600px;width:100%;background:#ffffff;border-radius:14px;overflow:hidden;box-shadow:0 10px 30px rgba(7,26,51,.08)">'
  .'<tr><td style="height:6px;background:linear-gradient(90deg,#b8860b,#e0b53a,#b8860b)"></td></tr>'
  .'<tr><td style="padding:26px 34px 6px;text-align:center;background:#071A33">'
  .($logo?'<img src="'.e($logo).'" alt="'.e(MAIL_HOTEL_NAME).'" width="72" height="72" style="display:inline-block;border:0;outline:none">':'')
  .'<div style="font-family:Georgia,\'Times New Roman\',serif;color:#ffffff;font-size:20px;letter-spacing:.14em;margin-top:12px">HOTEL PARADISE</div>'
  .'<div style="font-family:Arial,Helvetica,sans-serif;color:#e0b53a;font-size:10px;letter-spacing:.42em;margin-top:5px">ON THE NILE</div>'
  .'</td></tr>'
  .'<tr><td style="padding:30px 34px 8px;font-family:Arial,Helvetica,sans-serif;color:#1E2A3A;font-size:15px;line-height:1.62">'.$bodyHtml.'</td></tr>'
  .'<tr><td style="padding:18px 34px 30px">'
  .'<div style="border-top:1px solid #e6e9ef;padding-top:16px;font-family:Arial,Helvetica,sans-serif;color:#7b8798;font-size:12px;line-height:1.7;text-align:center">'
  .'<b style="color:#071A33">'.e(MAIL_HOTEL_NAME).'</b> &middot; '.e(MAIL_HOTEL_CITY).'<br>'
  .'Telephone '.e(MAIL_HOTEL_PHONE).' &middot; <a href="mailto:'.e(MAIL_HOTEL_EMAIL).'" style="color:#b8860b;text-decoration:none">'.e(MAIL_HOTEL_EMAIL).'</a><br>'
  .'<a href="https://'.e(MAIL_HOTEL_SITE).'" style="color:#7b8798;text-decoration:none">'.e(MAIL_HOTEL_SITE).'</a>'
  .'</div></td></tr>'
  .'</table>'
  .'<div style="font-family:Arial,Helvetica,sans-serif;color:#9aa6b6;font-size:11px;padding:14px 10px 0;text-align:center">This message was sent because a payment was recorded for you at Hotel Paradise on the Nile.</div>'
  .'</td></tr></table></body></html>';
}

/** A public, absolute address for an asset, so it loads inside a mail client. */
function mail_public_url(string $path): string
{
 $path='/'.ltrim($path,'/');
 $site=defined('SITE_URL')?SITE_URL:'';
 $host=(string)($_SERVER['HTTP_HOST']??'');
 $scheme=(!empty($_SERVER['HTTPS'])&&strtolower((string)$_SERVER['HTTPS'])!=='off')?'https':'http';
 if($host==='') return 'https://'.MAIL_HOTEL_SITE.$path;
 return $scheme.'://'.$host.$site.$path;
}

/**
 * Sends one message. Never throws.
 *
 * @return array{ok:bool,transport:string,error:?string,to:string,subject:string}
 */
function mail_send(string $to,string $subject,string $html,string $text='',array $opts=[]): array
{
 $cfg=mail_config();
 $result=['ok'=>false,'transport'=>$cfg['transport'],'error'=>null,'to'=>$to,'subject'=>$subject];

 $to=trim($to);
 if(!filter_var($to,FILTER_VALIDATE_EMAIL)){
  $result['error']='The recipient address is not a valid email address.';
  return $result;
 }
 if(preg_match('/[\r\n]/',$subject)){
  $result['error']='The subject may not contain line breaks.';
  return $result;
 }

 // Reply-To is optional and always validated before it is trusted into a header.
 $reply=trim((string)($opts['reply_to']??$cfg['reply_to']));
 if($reply!==''&&!filter_var($reply,FILTER_VALIDATE_EMAIL)) $reply=$cfg['from_email'];

 if($text==='') $text=mail_text_from_html($html);

 $parts=mail_compose($to,$subject,$html,$text,$reply,$cfg);
 if($parts['error']!==null){ $result['error']=$parts['error']; return $result; }

 // A log transport is for a developer who wants to see the message without a
 // mail server. It is never chosen unless someone asks for it by name.
 if($cfg['transport']==='log'){
  error_log('[hotel mail] to '.$to.' | '.$subject."\n".$parts['raw']);
  $result['ok']=true;
  return $result;
 }

 if($cfg['transport']==='smtp'){
  $sent=mail_smtp_send($cfg,$parts);
  $result['ok']=$sent['ok'];
  $result['error']=$sent['error'];
  $result['transport']='smtp';
  return $result;
 }

 $headers=$parts['headers'];
 $ok=false;
 try{
  $ok=@mail($to,mail_encode($subject),$parts['body'],$headers,'-f'.$cfg['from_email']);
 }catch(\Throwable $e){
  $result['error']=$e->getMessage();
  return $result;
 }
 $result['ok']=(bool)$ok;
 $result['transport']='mail';
 if(!$ok) $result['error']='The local mail server refused the message. Check the mail settings in config.php.';
 return $result;
}

/**
 * Builds the message once, in the shapes both transports need.
 *
 * A multipart/alternative body carries a plain text copy and an HTML copy of
 * the same thing, so a phone that cannot show the design still shows the words.
 */
function mail_compose(string $to,string $subject,string $html,string $text,string $reply,array $cfg): array
{
 $out=['error'=>null,'headers'=>'','body'=>'','raw'=>'','subject'=>mail_encode($subject)];
 $boundary='=_hp_'.bin2hex(random_bytes(12));
 $from=mail_from_header($cfg['from_email'],$cfg['from_name']);

 $body='--'.$boundary."\r\nContent-Type: text/plain; charset=UTF-8\r\nContent-Transfer-Encoding: base64\r\n\r\n"
  .chunk_split(base64_encode($text),76,"\r\n")
  .'--'.$boundary."\r\nContent-Type: text/html; charset=UTF-8\r\nContent-Transfer-Encoding: base64\r\n\r\n"
  .chunk_split(base64_encode($html),76,"\r\n")
  .'--'.$boundary.'--';

 $headers='From: '.$from."\r\n"
  .'To: '.$to."\r\n"
  .($reply!==''?'Reply-To: '.$reply."\r\n":'')
  .'MIME-Version: 1.0'."\r\n"
  .'Content-Type: multipart/alternative; boundary="'.$boundary.'"'."\r\n"
  .'Date: '.date('r')."\r\n"
  .'Message-ID: <'.bin2hex(random_bytes(12)).'@'.mail_message_domain($cfg['from_email']).">\r\n"
  .'X-Mailer: Hotel Paradise management system'."\r\n";

 $out['headers']=$headers;
 $out['body']=$body;
 $out['raw']=$headers.'Subject: '.$out['subject']."\r\n\r\n".$body;
 // The raw form used on the wire puts To and Subject first, as a mail client
 // expects to read them before it reads anything it cannot show.
 $out['raw']='To: '.$to."\r\n".'Subject: '.$out['subject']."\r\n".$headers."\r\n".$body;
 return $out;
}

/** The domain half of an address, for a plausible Message-ID. */
function mail_message_domain(string $email): string
{
 $at=strrpos($email,'@');
 $domain=$at===false?'hotelparadiseonthenile.info':substr($email,$at+1);
 return preg_replace('/[^A-Za-z0-9.\-]/','',$domain)?:'hotelparadiseonthenile.info';
}

/** A readable plain-text copy, so the message survives a client with no HTML. */
function mail_text_from_html(string $html): string
{
 $t=preg_replace('#<(script|style)[^>]*>.*?</\1>#is',' ',$html)??$html;
 $t=preg_replace('#<br\s*/?>#i',"\n",$t)??$t;
 $t=preg_replace('#</(p|div|tr|h[1-6]|li)>#i',"\n",$t)??$t;
 $t=strip_tags($t);
 $t=html_entity_decode($t,ENT_QUOTES,'UTF-8');
 $t=preg_replace('/[ \t]+/',' ',$t)??$t;
 $t=preg_replace('/\n{3,}/',"\n\n",$t)??$t;
 return trim($t);
}

/**
 * The SMTP conversation.
 *
 * Deliberately small and literal: connect, greet, upgrade to TLS if asked,
 * authenticate if asked, hand over one message, say goodbye. Every step is
 * checked against the code the server answered with, and the first thing that
 * goes wrong becomes the sentence the caller logs. Nothing beyond the line
 * endings a mail server requires is assumed.
 */
function mail_smtp_send(array $cfg,array $parts): array
{
 $host=$cfg['host'];
 $port=(int)$cfg['port'];
 $secure=$cfg['secure'];
 $timeout=max(5,(int)$cfg['timeout']);

 $target=($secure==='ssl'?'ssl':'tcp').'://'.$host.':'.$port;
 $ctx=stream_context_create(['ssl'=>[
  'verify_peer'=>true,'verify_peer_name'=>true,'allow_self_signed'=>false,
 ]]);
 $fp=@stream_socket_client($target,$errno,$errstr,$timeout,STREAM_CLIENT_CONNECT,$ctx);
 if(!$fp) return ['ok'=>false,'error'=>'Could not reach the mail server '.$host.':'.$port.' ('.$errstr.').'];

 stream_set_timeout($fp,$timeout);
 $read=function() use ($fp): string{
  $data='';
  while(($line=fgets($fp,515))!==false){
   $data.=$line;
   // A line whose fourth character is a space ends the reply; "250-" means more.
   if(strlen($line)<4||$line[3]===' ') break;
  }
  return $data;
 };
 $code=function(string $reply): int{ return (int)substr(trim($reply),0,3); };
 $say=function(string $cmd,?int $expect=null) use ($fp,$read,$code): array{
  fwrite($fp,$cmd."\r\n");
  $reply=$read();
  $got=$code($reply);
  if($expect!==null&&intdiv($got,100)!==$expect) return ['ok'=>false,'code'=>$got,'reply'=>$reply];
  return ['ok'=>true,'code'=>$got,'reply'=>$reply];
 };

 $greeting=$read();
 if($code($greeting)!==2) { fclose($fp); return ['ok'=>false,'error'=>'The mail server did not greet us: '.trim($greeting)]; }

 $ehloHost=mail_message_domain($cfg['from_email']);
 $ehlo=$say('EHLO '.$ehloHost,2);
 if(!$ehlo['ok']){ fclose($fp); return ['ok'=>false,'error'=>'The mail server rejected EHLO: '.trim($ehlo['reply'])]; }

 if($secure==='tls'){
  $start=$say('STARTTLS',2);
  if(!$start['ok']){ fclose($fp); return ['ok'=>false,'error'=>'STARTTLS was refused: '.trim($start['reply'])]; }
  $crypto=@stream_socket_enable_crypto($fp,true,STREAM_CRYPTO_METHOD_TLS_CLIENT);
  if($crypto!==true){ fclose($fp); return ['ok'=>false,'error'=>'Could not start a secure TLS session with the mail server.']; }
  $ehlo=$say('EHLO '.$ehloHost,2);
  if(!$ehlo['ok']){ fclose($fp); return ['ok'=>false,'error'=>'The mail server rejected EHLO after TLS: '.trim($ehlo['reply'])]; }
 }

 if($cfg['username']!==''){
  $auth=$say('AUTH LOGIN',3);
  if(!$auth['ok']){ fclose($fp); return ['ok'=>false,'error'=>'The mail server does not offer AUTH LOGIN.']; }
  $usr=$say(base64_encode($cfg['username']),3);
  if(!$usr['ok']){ fclose($fp); return ['ok'=>false,'error'=>'The mail server rejected the username.']; }
  $pass=$say(base64_encode($cfg['password']),2);
  if(!$pass['ok']){ fclose($fp); return ['ok'=>false,'error'=>'The mail server rejected the password.']; }
 }

 $from=$say('MAIL FROM:<'.$cfg['from_email'].'>',2);
 if(!$from['ok']){ fclose($fp); return ['ok'=>false,'error'=>'The mail server rejected the sender: '.trim($from['reply'])]; }

 // The recipient list is rebuilt from the one address the caller gave, so a
 // comma in a display name can never turn into a second blind recipient.
 foreach(mail_recipients($parts['raw']) as $rcpt){
  $r=$say('RCPT TO:<'.$rcpt.'>',2);
  if(!$r['ok']){ fclose($fp); return ['ok'=>false,'error'=>'The mail server rejected the recipient '.$rcpt.': '.trim($r['reply'])]; }
 }

 $data=$say('DATA',3);
 if(!$data['ok']){ fclose($fp); return ['ok'=>false,'error'=>'The mail server refused the message body.']; }

 $wire=mail_dot_stuff($parts['raw']);
 fwrite($fp,$wire."\r\n.\r\n");
 $end=$read();
 if($code($end)!==2){ fclose($fp); return ['ok'=>false,'error'=>'The mail server did not accept the message: '.trim($end)]; }

 @$say('QUIT',2);
 fclose($fp);
 return ['ok'=>true,'error'=>null];
}

/** The clean recipient addresses out of a raw message's To header. */
function mail_recipients(string $raw): array
{
 $out=[];
 foreach(preg_split('/\r?\n/',$raw)?:[] as $line){
  if(stripos($line,'To:')===0){
   $rest=trim(substr($line,3));
   if(preg_match_all('/[^\s<>@]+@[^\s<>@]+/',$rest,$m)){
    foreach($m[0] as $addr){ if(filter_var($addr,FILTER_VALIDATE_EMAIL)) $out[]=$addr; }
   }
  }
 }
 return $out;
}

/**
 * Makes a message safe for a DATA exchange: CRLF endings and a leading dot
 * doubled, which is the one rule that stops a line starting with a full stop
 * from being read as the end of the message.
 */
function mail_dot_stuff(string $raw): string
{
 $raw=str_replace(["\r\n","\r"],"\n",$raw);
 $raw=str_replace("\n","\r\n",$raw);
 $raw=preg_replace('/^\./m','..',$raw)??$raw;
 return $raw;
}
