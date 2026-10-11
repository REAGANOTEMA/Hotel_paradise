#!/usr/bin/env python3
"""
Genuine, scannable QR codes for Hotel Paradise on the Nile.

The guest journeys encoded here are the ones the website itself serves:

  * the branded landing page at /qr/ that offers the two guest actions,
  * the food menu and ordering page,
  * the rooms and booking page, and
  * the counter / point of sale flow, which sends a guest straight to the
    menu order form so an order at the till is the same order the kitchen sees.

Nothing here points at the console, the database or the server.

Each code is written as a high-resolution PNG (for digital use and for
printing, with the hotel logo set in the middle) and as an SVG (vector, left
clean for the printer, since a printer cannot place a raster logo). A print
sheet that carries the hotel logo, one short instruction line and the credit is
composed beside the code, never on top of it, so no module of the QR pattern is
ever covered.

Run from the project root:

    py tools\\make-qr-codes.py

The destinations are the production HTTPS addresses. The codes decode to the
exact URL whether or not the domain is reachable from this machine.
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
    "pos": f"{DOMAIN}/menu.html#order",
}

TITLES = {
    "landing": "Hotel Paradise on the Nile",
    "menu": "View the menu and order",
    "booking": "Book a room",
    "pos": "Order and bill at the counter",
}

# The logo is set into the middle of the printed PNG codes. Error correction
# level H tolerates roughly 30% loss, so a plate this size never puts a module
# out of reach of a scanner.
LOGO_FRACTION = 0.21

NAVY = "#071A33"
GOLD = "#C9A227"
GOLD2 = "#E0B53A"
INK = "#1c2733"
MUTED = "#5D6878"

STUDIO_NAME = "Reagansoft Innovation Limited"
STUDIO_URL = "reagansoftinnovation.com"
STUDIO_WA = "WhatsApp 0730 314 979"


def _logo_path() -> str | None:
    for rel in (("images", "logo-256.png"), ("logo-256.png",), ("paradise-logo.png",)):
        p = os.path.join(ROOT, *rel)
        if os.path.exists(p):
            return p
    return None


def _brand_plate(size: int) -> Image.Image:
    """A white, softly ringed plate holding the hotel logo, for the code centre."""
    plate = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(plate)
    draw.rounded_rectangle([0, 0, size - 1, size - 1], radius=int(size * 0.16), fill=(255, 255, 255, 255))
    draw.rounded_rectangle([0, 0, size - 1, size - 1], radius=int(size * 0.16), outline=GOLD, width=max(2, size // 42))
    logo_path = _logo_path()
    if logo_path:
        logo = Image.open(logo_path).convert("RGBA")
        inner = int(size * 0.74)
        logo.thumbnail((inner, inner), Image.LANCZOS)
        plate.paste(logo, ((size - logo.width) // 2, (size - logo.height) // 2), logo)
    return plate


def bake_logo(png_path: str) -> None:
    """Sets the logo plate into the centre of a finished QR png."""
    qr = Image.open(png_path).convert("RGBA")
    side = qr.width
    plate = _brand_plate(int(side * LOGO_FRACTION))
    qr.paste(plate, ((side - plate.width) // 2, (side - plate.height) // 2), plate)
    qr.convert("RGB").save(png_path)


def make_codes() -> None:
    os.makedirs(OUT, exist_ok=True)
    for key, url in TARGETS.items():
        # Error correction level H tolerates about 30% damage, which is what
        # keeps a printed code readable after a scuff or a coffee ring, and
        # what leaves room for the logo plate in the middle.
        qr = segno.make(url, error="h")
        png = os.path.join(OUT, f"{key}.png")
        svg = os.path.join(OUT, f"{key}.svg")
        # dark=navy, light=white, quiet zone of 4 modules on every side.
        qr.save(png, scale=24, border=4, dark=NAVY, light="#FFFFFF")
        bake_logo(png)
        # The vector copy is left clean for the printer.
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


def _sheet(code_key: str, title: str, subtitle: str, instruction: str) -> None:
    """A4 landscape at 300 DPI: logo, code, one instruction line and the credit."""
    dpi = 300
    w, h = int(11.69 * dpi), int(8.27 * dpi)  # A4 landscape
    sheet = Image.new("RGB", (w, h), "#FFFFFF")
    draw = ImageDraw.Draw(sheet)

    # A restrained navy rule and gold hairline top and bottom.
    draw.rectangle([0, 0, w, 14], fill=NAVY)
    draw.rectangle([0, h - 8, w, h], fill=GOLD)

    html_logo = _logo_path()
    if html_logo:
        logo = Image.open(html_logo).convert("RGBA")
        ls = 250
        logo.thumbnail((ls, ls), Image.LANCZOS)
        sheet.paste(logo, ((w - logo.width) // 2, int(0.55 * dpi)), logo)

    # Centre the QR on the page, with its logo plate already baked in.
    qr_img = Image.open(os.path.join(OUT, f"{code_key}.png")).convert("RGB")
    qr_side = 900
    qr_img = qr_img.resize((qr_side, qr_side), Image.NEAREST)
    qr_x = (w - qr_side) // 2
    qr_y = int(2.15 * dpi)
    sheet.paste(qr_img, (qr_x, qr_y))

    f_big = _font(58, bold=True)
    f_mid = _font(34, bold=True)
    f_small = _font(26)
    f_tiny = _font(20)

    _centered(draw, "HOTEL PARADISE ON THE NILE", f_big, int(1.45 * dpi), w, NAVY)
    _centered(draw, title, f_mid, int(1.82 * dpi), w, GOLD)
    _centered(draw, instruction, f_small, h - int(1.35 * dpi), w, MUTED)
    _centered(draw, f"{DOMAIN.replace('https://', '')}", f_small, h - int(1.0 * dpi), w, INK)
    _centered(
        draw,
        f"{subtitle}   |   Built by {STUDIO_NAME}  |  {STUDIO_URL}  |  {STUDIO_WA}",
        f_tiny,
        h - int(0.62 * dpi),
        w,
        MUTED,
    )

    out = os.path.join(OUT, f"print-sheet-{code_key}.png" if code_key != "landing" else "print-sheet.png")
    sheet.save(out, dpi=(dpi, dpi))
    print(f"wrote {os.path.relpath(out, ROOT)}")


def make_print_sheets() -> None:
    _sheet(
        "landing",
        "Scan to view the menu or book a room",
        "Point your phone camera at the code, then choose an action.",
        "Point your phone camera at the code, then choose VIEW MENU or BOOK A ROOM.",
    )
    _sheet(
        "menu",
        "View the menu and order",
        "One sheet for the dining room and the terrace.",
        "Point your phone camera at the code to open the menu and send your order.",
    )
    _sheet(
        "booking",
        "Book a room",
        "One sheet for reception, the lobby and the rooms.",
        "Point your phone camera at the code to see the rooms and begin a booking.",
    )
    _sheet(
        "pos",
        "Order and bill at the counter",
        "One sheet for the bar and the point of sale till.",
        "Point your phone camera at the code to open the order form the kitchen reads.",
    )


if __name__ == "__main__":
    make_codes()
    make_print_sheets()
