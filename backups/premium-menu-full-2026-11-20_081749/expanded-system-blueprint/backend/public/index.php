<?php
$path=parse_url($_SERVER['REQUEST_URI'],PHP_URL_PATH);
if(str_starts_with($path,'/api/')) { require __DIR__.'/../routes/api.php'; }
else { header('Content-Type:text/plain'); echo "Hotel Paradise on the Nile API
"; }
