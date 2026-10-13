<?php
require_once 'C:/xampp/htdocs/Hotel_paradise/backend-php/app/bootstrap.php';
echo "== users ==\n";
foreach (rows('SELECT id,name,email,roles,status,department FROM users ORDER BY id') as $u) {
  echo $u['id']." | ".$u['name']." | ".$u['email']." | roles=".$u['roles']." | ".$u['status']." | dept=".($u['department']??'')."\n";
}
$tables = array_column(rows("SHOW TABLES"), null);
echo "\n== system tables (".count($tables).") ==\n";
echo implode(', ', array_map(function($r){ $k=array_keys($r); return $r[$k[0]]; }, rows("SHOW TABLES")))."\n";