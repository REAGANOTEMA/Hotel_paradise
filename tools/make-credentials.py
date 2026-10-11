#!/usr/bin/env python3
"""
Draws the branded sign-in sheet the hotel director keeps: every staff account,
its role and its password, on one clean 150 DPI page.

The accounts are the fourteen that the installer creates. Thirteen share one
password and the administrator is the only one that differs, which the sheet
states plainly, together with the reminder to change them from Team and Users
after the first sign in.

Run from the project root:

    python tools\\make-credentials.py

It writes hotel_paradise_dashboard_credentials.png beside the other brand art
in the project root.
"""
from __future__ import annotations

import os

from PIL import Image, ImageDraw, ImageFont

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "hotel_paradise_dashboard_credentials.png")

DPI = 150
W, H = 1240, 1754  # A4 portrait at 150 DPI

NAVY = "#071A33"
NAVY2 = "#0F2850"
GOLD = "#C9A227"
GOLD2 = "#E0B53A"
INK = "#1C2733"
MUTED = "#5D6878"
LINE = "#E4E0D2"
PAPER = "#F6F3EA"

# email, role, password
ACCOUNTS = [
    ("admin@hotelparadiseonthenile.info", "Administrator", "Admin@123"),
    ("director@hotelparadiseonthenile.info", "Director", "Paradise2026"),
    ("gm@hotelparadiseonthenile.info", "General Manager", "Paradise2026"),
    ("accounts@hotelparadiseonthenile.info", "Finance", "Paradise2026"),
    ("cashier@hotelparadiseonthenile.info", "Cashier", "Paradise2026"),
    ("frontdesk@hotelparadiseonthenile.info", "Front Desk", "Paradise2026"),
    ("waiter@hotelparadiseonthenile.info", "Waiter", "Paradise2026"),
    ("bar@hotelparadiseonthenile.info", "Bar", "Paradise2026"),
    ("kitchen@hotelparadiseonthenile.info", "Kitchen", "Paradise2026"),
    ("store@hotelparadiseonthenile.info", "Storekeeper", "Paradise2026"),
    ("procurement@hotelparadiseonthenile.info", "Procurement", "Paradise2026"),
    ("housekeeping@hotelparadiseonthenile.info", "Housekeeping", "Paradise2026"),
    ("auditor@hotelparadiseonthenile.info", "Internal Auditor", "Paradise2026"),
    ("testkitchen@hotelparadiseonthenile.info", "Test Kitchen", "Paradise2026"),
]


def font(size: int, bold: bool = False):
    names = (
        ["arialbd.ttf", "Arial_Bold.ttf", "calibrib.ttf"]
        if bold
        else ["arial.ttf", "Arial.ttf", "calibri.ttf"]
    )
    for name in names:
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            continue
    return ImageFont.load_default()


def text_w(draw, s, f):
    l, t, r, b = draw.textbbox((0, 0), s, font=f)
    return r - l


def right(draw, s, f, right_x, y, fill):
    draw.text((right_x - text_w(draw, s, f), y), s, font=f, fill=fill)


def main() -> None:
    img = Image.new("RGB", (W, H), PAPER)
    d = ImageDraw.Draw(img)

    # Navy masthead with a gold hairline beneath it.
    d.rectangle([0, 0, W, 190], fill=NAVY)
    d.rectangle([0, 190, W, 196], fill=GOLD)

    logo_path = os.path.join(ROOT, "images", "logo-256.png")
    if not os.path.exists(logo_path):
        logo_path = os.path.join(ROOT, "logo-256.png")
    if os.path.exists(logo_path):
        try:
            logo = Image.open(logo_path).convert("RGBA")
            logo.thumbnail((112, 112), Image.LANCZOS)
            ring = Image.new("RGBA", (logo.width + 10, logo.height + 10), (255, 255, 255, 255))
            ring.paste(logo, (5, 5), logo)
            img.paste(ring, (44, 39), ring)
        except OSError:
            pass

    d.text((178, 52), "HOTEL PARADISE ON THE NILE", font=font(34, True), fill="#FFFFFF")
    d.text((180, 100), "Staff sign-in sheet  |  hotel management system", font=font(20), fill="#C9D3E0")
    right(d, "KEEP PRIVATE", font(18, True), W - 44, 62, GOLD2)

    y = 250
    d.text((60, y), "Sign-in accounts", font=font(40, True), fill=NAVY)
    y += 62
    d.text((60, y), "Fourteen accounts. The administrator is the only one with a different password; "
                     "every other account is Paradise2026.", font=font(19), fill=MUTED)
    y += 44

    # Column headers.
    col_email = 64
    col_role = 720
    col_pass = 980
    d.rectangle([52, y, W - 52, y + 46], fill=NAVY2)
    d.text((col_email, y + 12), "EMAIL", font=font(18, True), fill="#FFFFFF")
    d.text((col_role, y + 12), "ROLE", font=font(18, True), fill="#FFFFFF")
    d.text((col_pass, y + 12), "PASSWORD", font=font(18, True), fill="#FFFFFF")
    y += 46

    f_email = font(18)
    f_role = font(18)
    f_pass = font(19, True)
    row_h = 46
    for i, (email, role, password) in enumerate(ACCOUNTS):
        if i % 2:
            d.rectangle([52, y, W - 52, y + row_h], fill="#EFEBDD")
        d.text((col_email, y + 13), email, font=f_email, fill=INK)
        d.text((col_role, y + 13), role, font=f_role, fill=MUTED)
        d.text((col_pass, y + 12), password, font=f_pass, fill=NAVY)
        y += row_h
    d.rectangle([52, y, W - 52, y + 2], fill=LINE)

    # A short, unmissable warning under the table.
    y += 34
    d.rectangle([52, y, W - 52, y + 96], fill="#FBF3DA", outline=GOLD, width=2)
    d.text((72, y + 16), "Change these before the hotel goes live.", font=font(21, True), fill=NAVY)
    d.text((72, y + 50), "Sign in as the administrator, open Team and Users, and set a strong, "
                         "unique password for every member of staff.", font=font(17), fill=MUTED)

    # Footer credit.
    fy = H - 96
    d.rectangle([0, fy, W, H], fill=NAVY)
    d.rectangle([0, fy, W, fy + 5], fill=GOLD)
    d.text((60, fy + 26), "Hotel Paradise on the Nile Ltd  |  Jinja, Uganda  |  hotelparadiseonthenile.info",
           font=font(16), fill="#C9D3E0")
    d.text((60, fy + 52), "System designed, built and supported by Reagansoft Innovation Limited  |  "
                          "reagansoftinnovation.com  |  WhatsApp 0730 314 979",
           font=font(15, True), fill=GOLD2)

    img.save(OUT, dpi=(DPI, DPI))
    print("wrote %s  %dx%d" % (os.path.relpath(OUT, ROOT), W, H))


if __name__ == "__main__":
    main()
