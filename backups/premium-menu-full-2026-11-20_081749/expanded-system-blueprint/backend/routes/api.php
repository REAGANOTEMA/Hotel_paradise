<?php
require_once __DIR__.'/../src/Database.php';
require_once __DIR__.'/../src/Response.php';
$path=parse_url($_SERVER['REQUEST_URI'],PHP_URL_PATH);
if($path==='/api/health') json_response(['ok'=>true,'service'=>'Hotel Paradise on the Nile API','version'=>'1.0']);
if($path==='/api/dashboard/summary') {
  $db=Database::pdo();
  $counts=[];
  foreach(['rooms','reservations','invoices','payments'] as $t){ try{$counts[$t]=(int)$db->query("SELECT COUNT(*) FROM `$t`")->fetchColumn();}catch(Throwable $e){$counts[$t]=0;} }
  json_response(['ok'=>true,'hotel'=>'Hotel Paradise on the Nile','currency'=>'UGX','counts'=>$counts]);
}
json_response(['ok'=>false,'message'=>'Endpoint not implemented yet. Connect module controllers here.'],404);
