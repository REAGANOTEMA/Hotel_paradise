from pathlib import Path
p=Path(r'C:\xampp\htdocs\Hotel_paradise\backend-php\modules\dashboard.php')
s=p.read_text(encoding='utf-8')
s=s.replace("=date('Y-m-d',strtotime(.' +1 day')).' 00:00:00';","=date('Y-m-d',strtotime(.' +1 day')).' 00:00:00';",1)
p.write_text(s,encoding='utf-8')
print('ok')
