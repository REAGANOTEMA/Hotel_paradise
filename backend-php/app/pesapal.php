<?php
declare(strict_types=1);

/**
 * PESAPAL — the payment gateway the hotel settles through.
 *
 * Pesapal's v3 REST API is a four-step dance and this file is the only place
 * that knows it:
 *
 *   1. RequestToken ......... swap the consumer key/secret for a short-lived
 *                             bearer token (cached until it is almost expired).
 *   2. RegisterIPN .......... tell Pesapal where to reach us back, once, and
 *                             remember the ipn_id it hands back.
 *   3. SubmitOrderRequest ... hand over one order and get a redirect_url the
 *                             guest is sent to, plus an order_tracking_id.
 *   4. GetTransactionStatus . after the guest returns (or the IPN fires), ask
 *                             Pesapal what really happened and believe only
 *                             that answer — never the browser.
 *
 * Nothing here ever marks money as received on its own: it reports what the
 * gateway says and the caller decides. The keys live in config.php (never in
 * the browser), under a "pesapal" key, and can be overridden by the environment
 * (HP_PESAPAL_KEY / HP_PESAPAL_SECRET / HP_PESAPAL_ENV) so a host can be set up
 * without editing a file.
 *
 * Until a consumer key and secret are filled in, pesapal_enabled() is false and
 * the site keeps its safe offline behaviour: a payment is recorded as pending
 * and the front desk settles it. The moment the keys are present, the very same
 * checkout route starts sending guests to Pesapal.
 */

/** Where the gateway settings live: config.php, then the environment, then blank. */
function pesapal_config(): array
{
 static $cfg=null;
 if($cfg!==null) return $cfg;

 // Read through the shared loader, which parses config.php once and discards
 // any stray byte at the top of the file so it can never reach the JSON reply.
 $fromFile=hp_config();
 $p=(isset($fromFile['pesapal'])&&is_array($fromFile['pesapal']))?$fromFile['pesapal']:[];

 $pick=function(string $key,string $env,string $default) use($p): string {
  $v=getenv($env);
  if(is_string($v)&&$v!=='') return $v;
  if(isset($p[$key])&&is_string($p[$key])&&$p[$key]!=='') return $p[$key];
  return $default;
 };

 $env=strtolower($pick('env','HP_PESAPAL_ENV','sandbox'));
 $cfg=[
  'env'=>in_array($env,['live','production'],true)?'live':'sandbox',
  'consumer_key'=>$pick('consumer_key','HP_PESAPAL_KEY',''),
  'consumer_secret'=>$pick('consumer_secret','HP_PESAPAL_SECRET',''),
  'currency'=>strtoupper($pick('currency','HP_PESAPAL_CURRENCY','UGX')),
  // Optional absolute overrides. Left blank they are worked out from the request.
  'ipn_url'=>$pick('ipn_url','HP_PESAPAL_IPN_URL',''),
  'callback_url'=>$pick('callback_url','HP_PESAPAL_CALLBACK_URL',''),
 ];
 return $cfg;
}

/** Whether the gateway can actually be used: a key and a secret are both set. */
function pesapal_enabled(): bool
{
 $c=pesapal_config();
 return $c['consumer_key']!=='' && $c['consumer_secret']!=='';
}

/** The API host: live for real money, the sandbox while testing. */
function pesapal_base(): string
{
 return pesapal_config()['env']==='live'
  ? 'https://pay.pesapal.com/v3'
  : 'https://cybqa.pesapal.com/pesapalv3';
}

/** Scheme and host of this installation, so Pesapal can call us back. */
function pesapal_origin(): string
{
 $https=(!empty($_SERVER['HTTPS'])&&strtolower((string)$_SERVER['HTTPS'])!=='off');
 // Behind a load balancer or a proxy the TLS is terminated before the request
 // reaches PHP, so $_SERVER['HTTPS'] is empty even though the guest is on
 // https. The forwarded header is the only place that says so, and the live
 // gateway refuses an http callback, so it is honoured before giving up.
 if(!$https&&isset($_SERVER['HTTP_X_FORWARDED_PROTO'])){
  $fwd=explode(',',(string)$_SERVER['HTTP_X_FORWARDED_PROTO']);
  $https=strtolower(trim($fwd[0]))==='https';
 }
 if(!$https&&(string)($_SERVER['SERVER_PORT']??'')==='443') $https=true;
 $scheme=$https?'https':'http';
 $host=(string)($_SERVER['HTTP_HOST']??'');
 if($host==='') $host='localhost';
 return $scheme.'://'.$host;
}

/** The absolute URL Pesapal posts the IPN to (server to server). */
function pesapal_ipn_url(): string
{
 $c=pesapal_config();
 if($c['ipn_url']!=='') return $c['ipn_url'];
 return pesapal_origin().BASE.'/api.php?act=pesapal_ipn';
}

/** The absolute URL the guest's browser is returned to after paying. */
function pesapal_callback_url(string $merchantRef): string
{
 $c=pesapal_config();
 if($c['callback_url']!=='') return $c['callback_url'];
 return pesapal_origin().BASE.'/api.php?act=pesapal_callback&reference='.rawurlencode($merchantRef);
}

/** The little scratch pad for the token and the ipn_id (never web-reachable). */
function pesapal_store_path(): string
{
 $dir=__DIR__.'/../storage';
 if(!is_dir($dir)){
  @mkdir($dir,0775,true);
  // Keep the folder out of the web and out of git, the way storage is used.
  $ht=$dir.'/.htaccess';
  if(!file_exists($ht)) @file_put_contents($ht,"Require all denied\nDeny from all\n");
 }
 return $dir.'/pesapal.json';
}

function pesapal_store_read(): array
{
 $f=pesapal_store_path();
 if(!is_file($f)) return [];
 $raw=@file_get_contents($f);
 if($raw===false||$raw==='') return [];
 $d=json_decode($raw,true);
 return is_array($d)?$d:[];
}

function pesapal_store_write(array $d): void
{
 $f=pesapal_store_path();
 $json=json_encode($d,JSON_PRETTY_PRINT|JSON_UNESCAPED_SLASHES);
 if($json===false) return;
 // Write to a scratch file and rename it into place. A rename is atomic, so a
 // second checkout reading the cache at the very same moment sees either the
 // whole old file or the whole new one - never the empty half-written file a
 // plain overwrite can leave behind (which cost every following payment a fresh
 // token and a fresh IPN registration, and the guest the extra wait).
 $tmp=$f.'.'.getmypid().'.tmp';
 if(@file_put_contents($tmp,$json,LOCK_EX)===false){ @unlink($tmp); return; }
 if(!@rename($tmp,$f)){ @unlink($tmp); @file_put_contents($f,$json,LOCK_EX); }
}

/**
 * A single JSON call to Pesapal.
 *
 * Returns ['ok'=>bool,'code'=>int,'data'=>array,'error'=>string]. Network and
 * parse failures are returned, never thrown, because the caller is a guest's
 * checkout and must be able to show a human sentence instead of an error page.
 */
function pesapal_http(string $method,string $path,?array $body=null,?string $token=null): array
{
 $url=pesapal_base().$path;
 $headers=[
  'Accept: application/json',
  'Content-Type: application/json',
 ];
 if($token!==null&&$token!=='') $headers[]='Authorization: Bearer '.$token;
 $payload=$body===null?null:json_encode($body,JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE);

 $result=['ok'=>false,'code'=>0,'data'=>[],'error'=>''];

 if(function_exists('curl_init')){
  $ch=curl_init($url);
  curl_setopt_array($ch,[
   CURLOPT_RETURNTRANSFER=>true,
   CURLOPT_CUSTOMREQUEST=>$method,
   CURLOPT_HTTPHEADER=>$headers,
   // A guest is standing at the till while these run, so neither the connect
   // nor the whole call is allowed to hang for long: better a quick, honest
   // "try again" than a spinner that runs for a minute. The token and the IPN
   // are cached, so the only call on the critical path is the order submit.
   CURLOPT_CONNECTTIMEOUT=>10,
   CURLOPT_TIMEOUT=>25,
   CURLOPT_SSL_VERIFYPEER=>true,
   CURLOPT_SSL_VERIFYHOST=>2,
  ]);
  if($payload!==null) curl_setopt($ch,CURLOPT_POSTFIELDS,$payload);
  $raw=curl_exec($ch);
  $code=(int)curl_getinfo($ch,CURLINFO_HTTP_CODE);
  if($raw===false){ $result['error']='Could not reach the payment gateway: '.curl_error($ch); curl_close($ch); return $result; }
  curl_close($ch);
 }else{
  $ctx=stream_context_create(['http'=>[
   'method'=>$method,
   'header'=>implode("\r\n",$headers),
   'content'=>$payload,
   'timeout'=>25,
   'ignore_errors'=>true,
  ]]);
  $raw=@file_get_contents($url,false,$ctx);
  $code=0;
  if(isset($http_response_header[0])&&preg_match('/\s(\d{3})\s/',$http_response_header[0],$m)) $code=(int)$m[1];
  if($raw===false){ $result['error']='Could not reach the payment gateway.'; return $result; }
 }
 $result['code']=$code;
 $json=json_decode((string)$raw,true);
 $result['data']=is_array($json)?$json:[];
 if($code<200||$code>=300){
  $result['error']=pesapal_error_message($result['data'],$code);
  return $result;
 }
 $result['ok']=true;
 return $result;
}

/** Turn a Pesapal error body into a sentence a person can read. */
function pesapal_error_message(array $data,int $code): string
{
 foreach(['error','message','error_description'] as $k){
  if(isset($data[$k])&&is_string($data[$k])&&$data[$k]!=='') return $data[$k];
 }
 if(isset($data['error'])&&is_array($data['error'])){
  $first=reset($data['error']);
  if(is_string($first)) return $first;
 }
 return 'The payment gateway returned an error (HTTP '.$code.').';
}

/** A bearer token, reusing the cached one until it is nearly expired. */
function pesapal_token(): array
{
 $store=pesapal_store_read();
 $now=time();
 if(isset($store['token'],$store['token_expires'])&&is_string($store['token'])
    &&(int)$store['token_expires']>$now+60){
  return ['ok'=>true,'token'=>$store['token'],'error'=>''];
 }
 $c=pesapal_config();
 $r=pesapal_http('POST','/api/Auth/RequestToken',[
  'consumer_key'=>$c['consumer_key'],
  'consumer_secret'=>$c['consumer_secret'],
 ]);
 if(!$r['ok']){
  return ['ok'=>false,'token'=>'','error'=>$r['error']!==''?$r['error']:'The payment gateway would not issue a token.'];
 }
 $token=(string)($r['data']['token']??'');
 if($token===''){
  return ['ok'=>false,'token'=>'','error'=>'The payment gateway did not return a token. Check the consumer key and secret.'];
 }
 // Pesapal tokens live a few minutes; keep a margin so we never present a
 // token that expires mid-call.
 $exp=$now+240;
 if(isset($r['data']['expiryDate'])){
  $t=strtotime((string)$r['data']['expiryDate']);
  if($t!==false) $exp=min($t,$now+280);
 }
 $store['token']=$token;
 $store['token_expires']=$exp;
 pesapal_store_write($store);
 return ['ok'=>true,'token'=>$token,'error'=>''];
}

/** The ipn_id, registering once with Pesapal and remembering it afterwards. */
function pesapal_ipn_id(): array
{
 $store=pesapal_store_read();
 if(isset($store['ipn_id'],$store['ipn_url'])&&is_string($store['ipn_id'])&&$store['ipn_id']!==''
    &&$store['ipn_url']===pesapal_ipn_url()){
  return ['ok'=>true,'id'=>$store['ipn_id'],'error'=>''];
 }
 $t=pesapal_token();
 if(!$t['ok']) return ['ok'=>false,'id'=>'','error'=>$t['error']];

 $url=pesapal_ipn_url();
 $r=pesapal_http('POST','/api/URLSetup/RegisterIPN',[
  'url'=>$url,
  'ipn_notification_type'=>'GET',
 ],$t['token']);
 if(!$r['ok']) return ['ok'=>false,'id'=>'','error'=>$r['error']];

 // The response shape has moved around across Pesapal releases; accept the
 // known spellings rather than fail on a field rename.
 $id=(string)($r['data']['ipn_id']??$r['data']['ipnId']??$r['data']['IPNID']??'');
 if($id==='') return ['ok'=>false,'id'=>'','error'=>'The payment gateway did not confirm the notification URL.'];
 $store=pesapal_store_read();
 $store['ipn_id']=$id;
 $store['ipn_url']=$url;
 pesapal_store_write($store);
 return ['ok'=>true,'id'=>$id,'error'=>''];
}

/**
 * An address Pesapal will accept for billing.
 *
 * Pesapal requires a billing email, but a guest is only ever asked for a phone
 * number, and many pay with no address at all. A blank one would fail the whole
 * checkout, so the hotel's own reservations address stands in - it only ever
 * lands on Pesapal's billing field, never in place of the guest's own receipt.
 */
function pesapal_billing_email(string $given): string
{
 $given=trim($given);
 if($given!==''&&filter_var($given,FILTER_VALIDATE_EMAIL)) return $given;
 $cfg=hp_config();
 $m=(is_array($cfg)&&isset($cfg['mail'])&&is_array($cfg['mail']))?$cfg['mail']:[];
 $accts=(isset($m['accounts'])&&is_array($m['accounts']))?$m['accounts']:[];
 foreach(['reservation','bookings','restaurant'] as $k){
  if(isset($accts[$k]['from_email'])&&filter_var((string)$accts[$k]['from_email'],FILTER_VALIDATE_EMAIL)) return (string)$accts[$k]['from_email'];
 }
 if(isset($m['from_email'])&&filter_var((string)$m['from_email'],FILTER_VALIDATE_EMAIL)) return (string)$m['from_email'];
 return '';
}

/**
 * Hand one order to Pesapal.
 *
 * $order = [
 *   'reference'   => the merchant reference we will get back (our pay ref),
 *   'amount'      => float, in the hotel's currency,
 *   'description' => a short human phrase,
 *   'email'       => billing email (may be blank),
 *   'phone'       => billing phone (may be blank),
 *   'name'        => billing name (split into first/last),
 *   'country'     => ISO-2 country code, defaults to UG,
 * ]
 * Returns ['ok','redirect_url','tracking_id','error'].
 */
function pesapal_submit_order(array $order): array
{
 $tn=pesapal_token();
 if(!$tn['ok']) return ['ok'=>false,'redirect_url'=>'','tracking_id'=>'','error'=>$tn['error']];
 $ipn=pesapal_ipn_id();
 if(!$ipn['ok']) return ['ok'=>false,'redirect_url'=>'','tracking_id'=>'','error'=>$ipn['error']];

 $ref=(string)($order['reference']??'');
 $name=trim((string)($order['name']??'Guest'));
 $parts=preg_split('/\s+/',($name!==''?$name:'Guest'),2);
 $first=$parts[0]??'Guest';
 $last=$parts[1]??'';

 $body=[
  'id'=>$ref,
  'currency'=>pesapal_config()['currency'],
  'amount'=>round((float)($order['amount']??0),2),
  'description'=>(string)($order['description']??('Payment '.$ref)),
  'callback_url'=>pesapal_callback_url($ref),
  'notification_id'=>$ipn['id'],
  'billing_address'=>[
   'email_address'=>pesapal_billing_email((string)($order['email']??'')),
   'phone_number'=>(string)($order['phone']??''),
   'country_code'=>strtoupper((string)($order['country']??'UG')),
   'first_name'=>$first,
   'middle_name'=>'',
   'last_name'=>$last,
  ],
 ];
 $r=pesapal_http('POST','/api/Transactions/SubmitOrderRequest',$body,$tn['token']);
 if(!$r['ok']) return ['ok'=>false,'redirect_url'=>'','tracking_id'=>'','error'=>$r['error']];
 $url=(string)($r['data']['redirect_url']??$r['data']['redirectUrl']??'');
 $tid=(string)($r['data']['order_tracking_id']??$r['data']['orderTrackingId']??'');
 if($url==='') return ['ok'=>false,'redirect_url'=>'','tracking_id'=>$tid,'error'=>'The payment gateway did not return a checkout link.'];
 return ['ok'=>true,'redirect_url'=>$url,'tracking_id'=>$tid,'error'=>''];
}

/**
 * Ask Pesapal what really happened to a transaction.
 * Returns ['ok','status_code','description','raw','error'] where status_code is
 * Pesapal's 0=INVALID 1=COMPLETED 2=FAILED 3=REVERSED.
 */
function pesapal_transaction_status(string $trackingId): array
{
 $tn=pesapal_token();
 if(!$tn['ok']) return ['ok'=>false,'status_code'=>-1,'description'=>'','raw'=>[],'error'=>$tn['error']];
 $r=pesapal_http('GET','/api/Transactions/GetTransactionStatus?orderTrackingId='.rawurlencode($trackingId),null,$tn['token']);
 if(!$r['ok']) return ['ok'=>false,'status_code'=>-1,'description'=>'','raw'=>$r['data'],'error'=>$r['error']];
 $d=$r['data'];
 return [
  'ok'=>true,
  'status_code'=>(int)($d['status_code']??-1),
  'description'=>(string)($d['payment_status_description']??$d['status_description']??''),
  'raw'=>$d,
  'error'=>'',
 ];
}

/** Map Pesapal's words onto the payment table's status enum. */
function pesapal_map_status(string $description,int $code): string
{
 $d=strtolower(trim($description));
 if($code===1||$d==='completed'||$d==='success') return 'successful';
 if($code===2||$d==='failed') return 'failed';
 if($code===3||$d==='reversed') return 'reversed';
 if($d==='invalid') return 'failed';
 return 'pending';
}

/**
 * The method the guest actually paid with, read from the gateway's own status
 * body and mapped onto this system's payment methods.
 *
 * The checkout page only lets a guest say how they intend to pay; Pesapal's own
 * page is where the choice is really made, and only the status reply says which
 * one was used. A guest who tapped "MTN" and then paid by card is a card payment
 * in every book that matters, and mapping the gateway's word back means the
 * receipt, the invoice and Finance all agree with what the money actually was.
 * Returns '' when Pesapal named no method, so the caller never overwrites a
 * method with a guess.
 */
function pesapal_payment_method(array $raw): string
{
 $m=strtolower(trim((string)($raw['payment_method']??$raw['paymentMethod']??'')));
 if($m==='') return '';
 if(strpos($m,'mtn')!==false) return 'mtn_momo';
 if(strpos($m,'airtel')!==false) return 'airtel_money';
 if(strpos($m,'mpesa')!==false||strpos($m,'m-pesa')!==false) return 'mobile_money';
 if(strpos($m,'visa')!==false||strpos($m,'master')!==false||strpos($m,'amex')!==false
    ||strpos($m,'american express')!==false||strpos($m,'card')!==false) return 'card';
 if(strpos($m,'bank')!==false) return 'bank';
 if(strpos($m,'pesapal')!==false) return 'pesapal';
 return '';
}

/** The number or account the guest paid from, as Pesapal masked it. */
function pesapal_payer_account(array $raw): string
{
 $a=$raw['payment_account']??$raw['paymentAccount']??'';
 return is_string($a)?trim($a):'';
}
