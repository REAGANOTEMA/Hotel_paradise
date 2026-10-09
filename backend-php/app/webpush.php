<?php
declare(strict_types=1);

/**
 * Browser Web Push, implemented against the RFCs so nothing depends on a third
 * party. This is the piece that turns a device subscription into bytes that a
 * push service (Mozilla, Google's FCM, Apple's push service) will deliver.
 *
 *  - RFC 8291  Message Encryption for Web Push (aes128gcm), which encrypts a
 *              payload with ECDH over P-256 and HKDF, much as the spec draws.
 *  - RFC 8292  VAPID, the signed identification that lets the push service
 *              trust this server enough to keep its URL session alive.
 *
 * None of this is proprietary. The push service only needs an HTTPS endpoint;
 * it does not need to be Google, Mozilla or Apple, and nothing in this file is
 * tied to a contract key, a project id or an account. The VAPID key pair is the
 * only credential involved, and it is held in backend-php/vapid.php, which is
 * in .gitignore with config.php.
 *
 * Honest limit: a real end-to-end delivery (this server -> a push service ->
 * a real phone) can only be proven from a phone+signed HTTPS domain. This file
 * has been verified for structure, RFC conformance and that encrypted bytes
 * decrypt on the Web Crypto side with a test subscription, but whether Mozilla /
 * FCM / Apple literally rings a given device has to be confirmed on a device.
 */

namespace WebPush;

const VAPID_PATH = __DIR__.'/../vapid.php';

/**
 * On Windows, OpenSSL refuses to generate an EC key unless it can read an
 * openssl.cnf. A web server usually supplies one; a CLI script often does not.
 * This points OpenSSL at a real config file when none is set, and only falls
 * back to writing a minimal one for the key generation call. The config is a
 * profile for certificate requests, never a secret, so storing it next to the
 * code is fine - unlike vapid.php, which holds the signing key.
 */
function ensure_conf(): void
{
 if(($v=getenv('OPENSSL_CONF'))!==false && $v!=='' && is_readable($v)) return;
 foreach(['C:/xampp/apache/conf/openssl.cnf','/etc/ssl/openssl.cnf','/usr/local/etc/openssl/openssl.cnf'] as $cand){
  if(is_readable($cand)){ putenv('OPENSSL_CONF='.$cand); return; }
 }
 $dir=__DIR__.'/../storage';
 if(!is_dir($dir)) @mkdir($dir,0775,true);
 $f=$dir.'/openssl.cnf';
 if(!is_file($f)) @file_put_contents($f,"[req]\ndistinguished_name=req_dn\n[req_dn]\n");
 putenv('OPENSSL_CONF='.$f);
}

/** A usable openssl command line program, or null. A fallback for PHP builds
 *  whose OpenSSL cannot read a config file under this process. */
function find_openssl_cli(): ?string
{
 $env=getenv('OPENSSL_BIN');
 if(is_string($env)&&$env!==''&&is_file($env)) return $env;
 foreach(['C:/xampp/apache/bin/openssl.exe','/usr/bin/openssl','/usr/local/bin/openssl','/opt/homebrew/bin/openssl'] as $cand){
  if(is_file($cand)) return $cand;
 }
 if(function_exists('exec')){
  $o=[]; @exec('where openssl 2>NUL', $o, $rc);
  if($rc===0 && isset($o[0]) && trim($o[0])!==''){ $p=trim($o[0]); return is_file($p)?$p:null; }
  $o=[]; @exec('command -v openssl 2>/dev/null', $o, $rc);
  if($rc===0 && isset($o[0]) && trim($o[0])!==''){ $p=trim($o[0]); return is_file($p)?$p:null; }
 }
 return null;
}

/**
 * A fresh P-256 key pair on this machine, native OpenSSL first and the command
 * line program second. Some PHP builds (notably XAMPP on Windows) cannot create
 * an EC key because OpenSSL cannot reach a config file from that process; the
 * same key is produced by "openssl genpkey -algorithm EC" and loaded back, so
 * notification delivery keeps working there without admin surgery.
 */
function generate_keypair(): ?array
{
 ensure_conf();
 // "private_key_bits" is passed too: PHP 8.0 wants a bits figure to exist
 // before it will look at the curve name at all.
 $k=openssl_pkey_new(['curve_name'=>'prime256v1','private_key_type'=>OPENSSL_KEYTYPE_EC,'private_key_bits'=>384]);
 if($k!==false){
  $d=openssl_pkey_get_details($k);
  if(is_array($d)&&isset($d['key'],$d['ec']['x'],$d['ec']['y']))
   return ['key'=>$d['key'],'raw'=>"\x04".$d['ec']['x'].$d['ec']['y']];
 }
 while(openssl_error_string()){}
 $cli=find_openssl_cli();
 if($cli===null) return null;
 $tmp=tempnam(sys_get_temp_dir(),'hpn');
 if($tmp===false) return null;
 $cmd=escapeshellarg($cli).' genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out '.escapeshellarg($tmp).' 2>&1';
 $o=[]; $rc=255; @exec($cmd,$o,$rc);
 $pem='';
 if($rc===0&&is_readable($tmp)) $pem=file_get_contents($tmp)??'';
 @unlink($tmp);
 if(trim($pem)==='') return null;
 $key=openssl_pkey_get_private($pem);
 if($key===false) return null;
 $d=openssl_pkey_get_details($key);
 if(!is_array($d)||!isset($d['ec']['x'],$d['ec']['y'])) return null;
 return ['key'=>$pem,'raw'=>"\x04".$d['ec']['x'].$d['ec']['y']];
}

/** The server's short-lived VAPID identity, read from the gitignored file. */
function vapid(): ?array
{
 if(!is_readable(VAPID_PATH)) return null;
 try{
  $c=require VAPID_PATH;
 }catch(\Throwable $e){ return null; }
 if(!is_array($c)
   || !isset($c['private'],$c['public'],$c['subject'])
   || !is_string($c['private']) || $c['private']===''
   || !is_string($c['public']) || $c['public']===''
   || !is_string($c['subject']) || $c['subject']==='') return null;
 return ['private'=>$c['private'],'public'=>$c['public'],'subject'=>$c['subject']];
}

function b64u_encode(string $raw): string
{
 return rtrim(strtr(base64_encode($raw),'+/','-_'),'=');
}

function b64u_decode(string $b64): string
{
 $v=rtrim(strtr($b64,'-_','+/'),'=');
 $out=base64_decode($v,true);
 return $out===false?'':$out;
}

/**
 * HKDF-Expand-SHA256. Written out because hash_hkdf() runs Extract and Expand
 * as one call, while RFC 8291 needs the Extract result (the PRK) handed to
 * several Expands with different info strings.
 */
function hkdf_expand(string $prk,string $info,int $len): string
{
 $t=''; $okm='';
 for($i=1; strlen($okm)<$len; $i++){
  $t=hash_hmac('sha256',$t.$info.chr($i),$prk,true);
  $okm.=$t;
 }
 return substr($okm,0,$len);
}

/** The raw 65-byte uncompressed point (0x04 + X + Y) of a P-256 public key. */
function raw_public(\OpenSSLAsymmetricKey $key): string
{
 $d=openssl_pkey_get_details($key);
 if(!is_array($d) || !isset($d['ec']['x'],$d['ec']['y'])) return '';
 return "\x04".$d['ec']['x'].$d['ec']['y'];
}

/** Builds an SPKI PEM for a peer's raw uncompressed P-256 point. */
function pem_public(string $raw): string
{
 if(strlen($raw)!==65 || $raw[0]!==chr(4)) return '';
 $x=substr($raw,1,32); $y=substr($raw,33,32);
 $der=hex2bin('3059'.'3013'.'06072a8648ce3d0201'.'06082a8648ce3d030107'.'0342'.'00')."\x04".$x.$y;
 $b='-----BEGIN PUBLIC KEY-----'.PHP_EOL;
 $b.=chunk_split(base64_encode($der),64,PHP_EOL);
 $b.='-----END PUBLIC KEY-----';
 return $b;
}

/**
 * The shared secret two parties to a subscription agree on: this server's
 * throwaway key and the browser's subscription key.
 */
function ecdh_shared(string $asPrivatePem,string $uaRawPoint): ?string
{
 $asPriv=openssl_pkey_get_private($asPrivatePem);
 $uaPem=pem_public($uaRawPoint);
 if($asPriv===false || $uaPem==='') return null;
 $uaPub=openssl_pkey_get_public($uaPem);
 if($uaPub===false) return null;
 $secret=openssl_pkey_derive($uaPub,$asPriv);
 return is_string($secret)&&$secret!==''?$secret:null;
}

/**
 * Encrypts a payload for one subscription (RFC 8291).
 * Returns the full aes128gcm body: header || ciphertext || tag.
 */
function encrypt(string $endpoint,string $p256dhB64,string $authB64,string $plain): ?string
{
 $uaRaw=b64u_decode($p256dhB64);
 $auth=b64u_decode($authB64);
 if(strlen($uaRaw)!==65||strlen($auth)!==16) return null;

 $as=generate_keypair();
 if($as===null) return null;
 $asPriv=$as['key'];
 $asPubRaw=$as['raw'];

 $shared=ecdh_shared($asPriv,$uaRaw);
 if($shared===null) return null;

 // IKM = HKDF-Expand(HKDF-Extract(auth_secret, ecdh_secret), auth_info, 32)
 $authInfo="WebPush: info\x00".$uaRaw.$asPubRaw;
 $prkAuth=hash_hmac('sha256',$shared,$auth,true);   // HKDF-Extract(auth_secret, ecdh_secret)
 $ikm=hkdf_expand($prkAuth,$authInfo,32);

 $salt=random_bytes(16);
 $prk=hash_hmac('sha256',$ikm,$salt,true);          // HKDF-Extract(salt, IKM)
 $cek=hkdf_expand($prk,"Content-Encoding: aes128gcm\x00",16);
 $nonce=hkdf_expand($prk,"Content-Encoding: nonce\x00",12);

 $record=$plain."\x02";                       // single record, delimiter then no padding
 $rs=4096;
 $header=$salt.pack('N',$rs).chr(65).$asPubRaw;
 $cipher=openssl_encrypt($record,'aes-128-gcm',$cek,OPENSSL_RAW_DATA,$nonce,$tag,$header,16);
 if($cipher===false) return null;

 return $header.$cipher.$tag;
}

/** Turns an ASN.1 DER ECDSA signature into the raw r||s the JWT wants. */
function der_signature_raw(string $der): ?string
{
 $i=0; $n=strlen($der);
 $read=function(int &$i) use($der,$n): ?int{
  if($i>=$n) return null;
  $len=ord($der[$i++]);
  if($len&0x80){
   $count=$len&0x7f; $len=0;
   for($k=0;$k<$count;$k++){ if($i>=$n) return null; $len=($len<<8)|ord($der[$i++]); }
  }
  return $len;
 };
 if($i>=$n || $der[$i++]!==chr(0x30)) return null;   // SEQUENCE
 if($read($i)===null) return null;                    // sequence length
 if($i>=$n || $der[$i++]!==chr(0x02)) return null;    // INTEGER r
 $rLen=$read($i); if($rLen===null||$i+$rLen>$n) return null;
 $r=substr($der,$i,$rLen); $i+=$rLen;
 if($i>=$n || $der[$i++]!==chr(0x02)) return null;    // INTEGER s
 $sLen=$read($i); if($sLen===null||$i+$sLen>$n) return null;
 $s=substr($der,$i,$sLen);
 $pad=function(string $v): string{ // drop a leading zero added for the sign bit, then fix width 32
  if($v!==''&&$v[0]===chr(0)) $v=substr($v,1);
  return str_pad($v,32,"\x00",STR_PAD_LEFT);
 };
 return $pad($r).$pad($s);
}

/** The VAPID JWT that proves this server owns the public key it shows. */
function vapid_token(array $vapid,string $aud): string
{
 $header=b64u_encode(json_encode(['typ'=>'JWT','alg'=>'ES256'],JSON_UNESCAPED_SLASHES));
 $claims=b64u_encode(json_encode(['aud'=>$aud,'exp'=>time()+43200,'sub'=>$vapid['subject']],JSON_UNESCAPED_SLASHES));
 $signingInput=$header.'.'.$claims;
 $sig='';
 openssl_sign($signingInput,$der,$vapid['private'],OPENSSL_ALGO_SHA256);
 if($der!==''){
  $raw=der_signature_raw($der);
  if($raw!==null) $sig=b64u_encode($raw);
 }
 return $signingInput.'.'.$sig;
}

/** The origin of an endpoint - what the push service wants in the JWT audience. */
function endpoint_origin(string $endpoint): string
{
 $p=parse_url($endpoint);
 $scheme=isset($p['scheme'])?strtolower($p['scheme']):'https';
 $host=$p['host']??'';
 $port=isset($p['port'])&&!in_array($p['port'],[80,443],true)?':'.$p['port']:'';
 return $scheme.'://'.$host.$port;
}

/**
 * Delivers one payload to one subscription. $payload is a small array that will
 * become the notification body ('{"title":"...","body":"..."}').
 *
 * Returns ['ok'=>bool,'http'=>int,'error'=>string|null,'gone'=>bool]. A 404/410
 * from the push service means the subscription itself is dead, which is why
 * "gone" is told apart from a plain failure: the caller should retire the row.
 *
 * The last stage - the actual network call - uses curl with a hard timeout and
 * TLS verification on, so a push service that cannot be reached fails here
 * without echoing a stack trace back at whoever raised the notification.
 */
function send(string $endpoint,string $p256dh,string $auth,array $payload,array $vapid): array
{
 $raw=encrypt($endpoint,$p256dh,$auth,(string)json_encode($payload,JSON_UNESCAPED_SLASHES|JSON_UNESCAPED_UNICODE));
 if($raw===null){
  return ['ok'=>false,'http'=>0,'error'=>'Could not build the web push payload','gone'=>false];
 }
 if(!function_exists('curl_init')) return ['ok'=>false,'http'=>0,'error'=>'cURL is not available on this server','gone'=>false];

 $token=vapid_token($vapid,endpoint_origin($endpoint));
 $headers=[
  'Content-Type: application/octet-stream',
  'Content-Encoding: aes128gcm',
  'TTL: 2419200',
  'Urgency: high',
  'Authorization: vapid t='.$token.', k='.$vapid['public'],
 ];
 $ch=curl_init($endpoint);
 curl_setopt_array($ch,[
  CURLOPT_POST=>true,
  CURLOPT_POSTFIELDS=>$raw,
  CURLOPT_HTTPHEADER=>$headers,
  CURLOPT_RETURNTRANSFER=>true,
  CURLOPT_CONNECTTIMEOUT=>5,
  CURLOPT_TIMEOUT=>10,
  CURLOPT_SSL_VERIFYPEER=>true,
 ]);
 $body=curl_exec($ch);
 $http=(int)curl_getinfo($ch,CURLINFO_RESPONSE_CODE);
 $err=curl_error($ch);
 curl_close($ch);

 $gone=in_array($http,[404,410],true);
 if($gone) return ['ok'=>false,'http'=>$http,'error'=>($err!==''?$err:'Subscription is no longer valid ('.$http.')'),'gone'=>true];
 if($http>=200&&$http<300) return ['ok'=>true,'http'=>$http,'error'=>null,'gone'=>false];
 return ['ok'=>false,'http'=>$http,'error'=>($err!==''?$err:'Push service rejected the request ('.$http.')'),'gone'=>false];
}

/** Whether everything the sender needs is in place. Used by health checks. */
function configured(): bool
{
 $v=vapid();
 return $v!==null && function_exists('curl_init');
}