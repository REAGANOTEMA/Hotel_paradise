#!/usr/bin/env python3
"""
Genuine, scannable QR codes for Hotel Paradise on the Nile.

Only two guest journeys are encoded, exactly as the brief requires:

  1. the food menu and ordering page, and
  2. the rooms and booking page,

plus a single branded landing page at /qr/ that offers nothing but those
two actions. Nothing here points at the console, the database, the server
or any payment page.

Each code is written as a high-resolution PNG (for digital use and for
printing) and as an SVG (vector, for the printer). A print sheet that
carries the hotel logo and a short instruction line is composed beside
the code, never on top of it, so no module of the QR pattern is ever
covered.

Run from the project root:

    py tools\\make-qr-codes.py

The destinations are the production HTTPS addresses. When the live domain
is not reachable from the machine that runs this, the codes are still
correct: decoding them returns the exact URL, which is what makes them
printable today and live the moment DNS is pointed at the host.
"""
from __future__ import annotations

import os
from PIL import Image, ImageDraw, ImageFont

try:
    import segno
except ImportError as exc:  # pragma: no cover - the operator sees this
    raise SystemExit(
        "segno is required: py -m pip install segno"
    ) from exc

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
OUT = os.path.join(ROOT, "qr")

DOMAIN = "https://hotelparadiseonthenile.info"

# The real routes that already exist in this project. These are the pages
# the website itself links to, so the QR codes can never drift away from
# the working menu and booking flows.
TARGETS = {
    "landing": f"{DOMAIN}/qr/",
    "menu": f"{DOMAIN}/menu.html",
    "booking": f"{DOMAIN}/rooms.html",
}

TITLES = {
    "landing": "Hotel Paradise on the Nile",
    "menu": "View the menu and order",
    "booking": "Book a room",
}

NAVY = "#071A33"
GOLD = "#C9A227"
INK = "#1c2733"
MUTED = "#5D6878"


def make_codes() -> None:
    os.makedirs(OUT, exist_ok=True)
    for key, url in TARGETS.items():
        # Error correction level H tolerates about 30% damage, which is what
        # keeps a printed code readable after a scuff or a coffee ring.
        qr = segno.make(url, error="h")
        png = os.path.join(OUT, f"{key}.png")
        svg = os.path.join(OUT, f"{key}.svg")
        # dark=navy, light=white, quiet zone of 4 modules on every side.
        qr.save(
            png,
            scale=24,
            border=4,
            dark=NAVY,
            light="#FFFFFF",
        )
        qr.save(svg, scale=12, border=4, dark=NAVY, light="#FFFFFF")
        print(f"wrote {os.path.relpath(png, ROOT)}  ->  {url}")
        print(f"wrote {os.path.relpath(svg, ROOT)}")


def _font(size: int, bold: bool = False):
    """A real TrueType face when one is present, Arial otherwise."""
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


def _centered(draw: ImageDraw.ImageDraw, text: str, font, cy: int, width: int, fill):
    left, top, right, bottom = draw.textbbox((0, 0), text, font=font)
    draw.text(((width - (right - left)) / 2 - left, cy - (bottom - top) / 2 - top), text, font=font, fill=fill)


def make_print_sheet() -> None:
    """A4 landscape at 300 DPI: logo, code and one short instruction line.

    The QR is drawn inset from the paper and the logo sits above it, so the
    artwork never touches the pattern.
    """
    dpi = 300
    w, h = int(11.69 * dpi), int(8.27 * dpi)  # A4 landscape
    sheet = Image.new("RGB", (w, h), "#FFFFFF")
    draw = ImageDraw.Draw(sheet)

    # A restrained navy rule and gold hairline top and bottom.
    draw.rectangle([0, 0, w, 14], fill=NAVY)
    draw.rectangle([0, h - 8, w, h], fill=GOLD)

    logo_path = os.path.join(ROOT, "images", "logo-256.png")
    if not os.path.exists(logo_path):
        logo_path = os.path.join(ROOT, "logo-256.png")

    # Centre the QR on the page.
    qr_img = Image.open(os.path.join(OUT, "landing.png")).convert("RGB")
    qr_side = 900
    qr_img = qr_img.resize((qr_side, qr_side), Image.NEAREST)
    qr_x = (w - qr_side) // 2
    qr_y = int(2.15 * dpi)
    sheet.paste(qr_img, (qr_x, qr_y))

    if os.path.exists(logo_path):
        logo = Image.open(logo_path).convert("RGBA")
        ls = 250
        logo.thumbnail((ls, ls), Image.LANCZOS)
        sheet.paste(logo, ((w - logo.width) // 2, int(0.55 * dpi)), logo)

    f_big = _font(58, bold=True)
    f_mid = _font(34, bold=True)
    f_small = _font(26)

    _centered(draw, "HOTEL PARADISE ON THE NILE", f_big, int(1.45 * dpi), w, NAVY)
    _centered(draw, "Scan to view the menu or book a room", f_mid, int(1.82 * dpi), w, GOLD)
    _centered(
        draw,
        "Point your phone camera at the code, then choose VIEW MENU or BOOK A ROOM.",
        f_small,
        h - int(1.15 * dpi),
        w,
        MUTED,
    )
    _centered(draw, "hotelparadiseonthenile.info", f_small, h - int(0.8 * dpi), w, INK)

    out = os.path.join(OUT, "print-sheet.png")
    sheet.save(out, dpi=(dpi, dpi))
    print(f"wrote {os.path.relpath(out, ROOT)}")


if __name__ == "__main__":
    make_codes()
    make_print_sheet()
