<?php
// patch layout.php to include premium dashboard assets/helpers
$path = 'C:\xampp\htdocs\Hotel_paradise\backend-php\app\layout.php';
$s = file_get_contents($path);
$old = "  echo '<link rel=\"stylesheet\" href=\"'.BASE.'/assets/admin.css\">'; echo '<link rel=\"stylesheet\" href=\"'.BASE.'/assets/luxury-admin.css\">';";
$new = "  echo '<link rel=\"stylesheet\" href=\"'.BASE.'/assets/admin.css\">'; echo '<link rel=\"stylesheet\" href=\"'.BASE.'/assets/luxury-admin.css\">';\n  echo '<link rel=\"stylesheet\" href=\"'.BASE.'/assets/dashboard-premium.css\">';";
if (strpos($s,$old)===false) { echo "MISS1\n"; exit(1); }
$s = str_replace($old,$new,$s);
$old2 = "require_once __DIR__.'/notify.php';";
$new2 = "require_once __DIR__.'/notify.php';\nrequire_once __DIR__.'/dashboard_ui.php';";
if (strpos($s,$old2)===false) { echo "MISS2\n"; exit(1); }
$s = str_replace($old2,$new2,$s);
file_put_contents($path,$s);
echo "ok\n";
