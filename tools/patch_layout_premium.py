from pathlib import Path
p=Path(r'C:\xampp\htdocs\Hotel_paradise\backend-php\app\layout.php')
s=p.read_text(encoding='utf-8')
old="  echo '<link rel=\"stylesheet\" href=\"'.BASE.'/assets/admin.css\">'; echo '<link rel=\"stylesheet\" href=\"'.BASE.'/assets/luxury-admin.css\">';"
new="  echo '<link rel=\"stylesheet\" href=\"'.BASE.'/assets/admin.css\">';\n  echo '<link rel=\"stylesheet\" href=\"'.BASE.'/assets/luxury-admin.css\">';\n  echo '<link rel=\"stylesheet\" href=\"'.BASE.'/assets/dashboard-premium.css\">';"
assert old in s
s=s.replace(old,new,1)
old2="require_once __DIR__.'/notify.php';"
new2="require_once __DIR__.'/notify.php';\nrequire_once __DIR__.'/dashboard_ui.php';"
assert old2 in s
s=s.replace(old2,new2,1)
p.write_text(s,encoding='utf-8')
print('ok')
