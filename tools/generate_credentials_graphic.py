from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

base = r"C:\xampp\htdocs\Hotel_paradise"
logo_path = os.path.join(base, "Hotel-Paradise-on-the-Nile-Logo.webp")
out_path = os.path.join(base, "Hotel_Paradise_All_Dashboards_Credentials_PERFECT.png")

accounts = [
    ("Administrator", "Reagan Otema (Administrator)", "admin@hotelparadiseonthenile.info", "Admin@123", "Full system access"),
    ("Director", "Hotel Director", "director@hotelparadiseonthenile.info", "Paradise2026", "Executive oversight"),
    ("General Manager", "General Manager", "gm@hotelparadiseonthenile.info", "Paradise2026", "Operations management"),
    ("Finance / Accountant", "Finance Officer", "accounts@hotelparadiseonthenile.info", "Paradise2026", "Finance & accounting"),
    ("Cashier", "Cashier", "cashier@hotelparadiseonthenile.info", "Paradise2026", "Payments & cashiering"),
    ("Front Desk / Reception", "Front Desk Reception", "frontdesk@hotelparadiseonthenile.info", "Paradise2026", "Reservations & check-in"),
    ("Waiter", "Restaurant Waiter", "waiter@hotelparadiseonthenile.info", "Paradise2026", "Restaurant service"),
    ("Bar Staff", "Bar Staff", "bar@hotelparadiseonthenile.info", "Paradise2026", "Bar operations"),
    ("Kitchen", "Kitchen", "kitchen@hotelparadiseonthenile.info", "Paradise2026", "Kitchen operations"),
    ("Storekeeper", "Storekeeper", "store@hotelparadiseonthenile.info", "Paradise2026", "Store & inventory"),
    ("Procurement", "Procurement Officer", "procurement@hotelparadiseonthenile.info", "Paradise2026", "Purchasing & procurement"),
    ("Housekeeping", "Housekeeping", "housekeeping@hotelparadiseonthenile.info", "Paradise2026", "Room housekeeping"),
    ("Internal Auditor", "Internal Auditor", "auditor@hotelparadiseonthenile.info", "Paradise2026", "Audit & compliance"),
    ("All-Roles Staff (DB)", "Hotel Paradise Staff", "staff@hotelparadiseonthenile.info", "See DB / reset", "All assigned roles"),
]

W = 1860
margin = 60
header_h = 360
row_h = 74
table_top_pad = 90
footer_h = 120
H = header_h + table_top_pad + row_h * (len(accounts)+1) + footer_h + 60

NAVY = (7, 26, 51)
NAVY2 = (12, 40, 78)
GOLD = (212, 175, 55)
GOLD_SOFT = (232, 205, 120)
WHITE = (255, 255, 255)
MUTED = (180, 195, 215)
ROW_A = (16, 46, 86)
ROW_B = (11, 35, 67)

img = Image.new("RGB", (W, H), NAVY)
draw = ImageDraw.Draw(img)
for y in range(H):
    t = y / H
    r = int(NAVY[0]*(1-t) + NAVY2[0]*t)
    g = int(NAVY[1]*(1-t) + NAVY2[1]*t)
    b = int(NAVY[2]*(1-t) + NAVY2[2]*t)
    draw.line([(0,y),(W,y)], fill=(r,g,b))
draw.rectangle([0,0,W,8], fill=GOLD)
draw.rectangle([0,H-8,W,H], fill=GOLD)

def font(name, size):
    p = os.path.join(r"C:\Windows\Fonts", name)
    if os.path.exists(p):
        try: return ImageFont.truetype(p, size)
        except Exception: pass
    return ImageFont.load_default()
fb = lambda s: font("arialbd.ttf", s)
fr = lambda s: font("arial.ttf", s)
fblack = lambda s: font("ariblk.ttf", s) if os.path.exists(r"C:\Windows\Fonts\ariblk.ttf") else font("arialbd.ttf", s)

logo_y = 28
logo_h = 150
if os.path.exists(logo_path):
    logo = Image.open(logo_path).convert("RGBA")
    ratio = logo_h / logo.height
    logo_w = int(logo.width * ratio)
    logo = logo.resize((logo_w, logo_h), Image.LANCZOS)
    glow = Image.new("RGBA", (logo_w+40, logo_h+40), (0,0,0,0))
    glow.paste(logo, (20,20), logo)
    gblur = glow.filter(ImageFilter.GaussianBlur(8))
    img.paste(gblur, ((W-logo_w)//2 - 20, logo_y - 20), gblur)
    img.paste(logo, ((W-logo_w)//2, logo_y), logo)
    draw = ImageDraw.Draw(img)
    title_y = logo_y + logo_h + 18
else:
    title_y = 60

def center_text(y, text, f, fill):
    bbox = draw.textbbox((0,0), text, font=f)
    tw = bbox[2]-bbox[0]
    draw.text(((W-tw)//2, y), text, font=f, fill=fill)

center_text(title_y, "ALL DASHBOARDS — EMAILS & PASSWORDS", fblack(54), WHITE)
center_text(title_y+70, "Hotel Paradise on the Nile  •  Management System Access Credentials", fb(28), GOLD_SOFT)
center_text(title_y+112, "Login: http://localhost/Hotel_paradise/backend-php/", fr(24), MUTED)

dy = title_y + 154
draw.line([(margin, dy), (W-margin, dy)], fill=GOLD, width=3)

table_x = margin
table_y = dy + 30
table_w = W - margin*2
cols = [60, 280, 290, 460, 220, 370]
headers = ["#", "DASHBOARD / ROLE", "ACCOUNT NAME", "EMAIL", "PASSWORD", "ACCESS"]

hx, hy = table_x, table_y
draw.rounded_rectangle([table_x, hy, table_x+table_w, hy+row_h], radius=12, fill=GOLD)
for i,h in enumerate(headers):
    draw.text((hx+14, hy+23), h, font=fb(22), fill=NAVY)
    hx += cols[i]

for idx, (role, name, email, pwd, access) in enumerate(accounts, start=1):
    ry = hy + row_h * idx
    fill = ROW_A if idx % 2 == 1 else ROW_B
    draw.rectangle([table_x, ry, table_x+table_w, ry+row_h], fill=fill)
    draw.line([(table_x, ry+row_h), (table_x+table_w, ry+row_h)], fill=(40,70,110), width=1)
    vals = [str(idx), role, name, email, pwd, access]
    x = table_x
    for i,v in enumerate(vals):
        fnt = fb(21) if i in (1,4) else fr(20)
        color = WHITE
        if i == 4:
            color = (255, 210, 120) if pwd == "Admin@123" else (180, 235, 190) if pwd == "Paradise2026" else (255,160,160)
        elif i == 3:
            color = (220, 235, 255)
        elif i == 1:
            color = (255,255,255)
        tv = v
        max_w = cols[i]-22
        while draw.textbbox((0,0), tv, font=fnt)[2] > max_w and len(tv) > 4:
            tv = tv[:-4] + "..."
        draw.text((x+14, ry+24), tv, font=fnt, fill=color)
        x += cols[i]

table_bottom = hy + row_h * (len(accounts)+1)
draw.rounded_rectangle([table_x, hy, table_x+table_w, table_bottom], radius=12, outline=GOLD, width=2)

fy = table_bottom + 28
draw.rounded_rectangle([table_x, fy, table_x+table_w, fy+72], radius=10, fill=(20, 50, 90))
note1 = "VERIFIED SYSTEM ACCOUNTS  •  Admin password differs  •  Change all passwords before going live"
note2 = "staff@hotelparadiseonthenile.info exists in DB with all roles; password not in plain text — reset via Team & Users or set-password.php"
for j,(note,fnt,col,yy) in enumerate([(note1,fb(22),GOLD_SOFT,fy+12),(note2,fr(19),MUTED,fy+42)]):
    bbox = draw.textbbox((0,0), note, font=fnt)
    nw = bbox[2]-bbox[0]
    draw.text(((W-nw)//2, yy), note, font=fnt, fill=col)

img.save(out_path, "PNG", optimize=True)
img.convert('RGB').save(out_path.replace('.png','.jpg'), 'JPEG', quality=95, subsampling=0, optimize=True)
print(out_path)
