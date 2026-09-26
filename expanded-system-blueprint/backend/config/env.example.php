<?php
return [
    'db_host' => getenv('DB_HOST') ?: '127.0.0.1',
    'db_name' => getenv('DB_NAME') ?: 'hotel_paradise_nile',
    'db_user' => getenv('DB_USER') ?: 'root',
    'db_pass' => getenv('DB_PASS') ?: '',
    'app_url' => getenv('APP_URL') ?: 'http://localhost:8080',
];
