<?php
declare(strict_types=1);
require __DIR__.'/backend-php/app/bootstrap.php';
require_once __DIR__.'/backend-php/app/guest_comm.php';

echo 'ready: '.(guest_message_ready()?'yes':'no')."\n";
echo 'departments: '.implode(',',guest_message_departments())."\n";
echo 'statuses: '.implode(',',array_keys(guest_message_statuses()))."\n";
echo 'sources: '.implode(',',guest_message_sources())."\n";
echo 'counts: '.json_encode(guest_message_counts())."\n";
echo 'roles msg kitchen: '.json_encode(guest_message_notify_roles('kitchen'))."\n";
echo 'roles exp front: '.json_encode(guest_message_notify_roles('front_office','experience'))."\n";
echo 'scope (no session): '.json_encode(guest_message_scope())."\n";

$cards=0;
$cards=count(rows('SELECT id FROM guest_messages LIMIT 5'));
echo 'query rows: '.$cards."\n";
echo "SMOKE OK\n";