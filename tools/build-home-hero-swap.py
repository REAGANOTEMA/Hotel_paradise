#!/usr/bin/env python3
"""
Builds the two home-page hero slides the director added: the Jinja bridge at
night and the high quality pork barbecue.

Both sources are small for a full-bleed carousel, so each is rebuilt at the
widths the carousel actually requests with a high quality Lanczos step, a
gentle unsharp mask and a whisper of contrast for a cleaner read on screen.

Run from the project root:

    python tools\\build-home-hero-swap.py

Rewrite, in /images/hero:

    pork-bbq.webp                 1280px base from the existing 1280 copy
    pork-bbq-1024.webp             1024px step
    pork-bbq-640.webp               640px phone step (rebuilt from the base)

    jinja-main-bridge-view-from-hotel-at-night.webp   1440px base
    jinja-main-bridge-view-from-hotel-at-night-1024.webp 1024px step
    jinja-main-bridge-view-from-hotel-at-night-640.webp  640px step

Then switch the carousel and rebuild:

    npm run build    (in frontend-react)
    node tools/deploy-site.mjs .
"""
from __future__ import annotations

import os

from PIL import Image, ImageEnhance, ImageFilter, ImageOps

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
HERO = os.path.join(ROOT, "images", "hero")

QUALITY = 85


def polish(im: Image.Image, sharpen: float = 1.0) -> Image.Image:
    im = im.filter(ImageFilter.UnsharpMask(radius=1.5, percent=int(118 * sharpen), threshold=3))
    im = ImageEnhance.Contrast(im).enhance(1.04)
    im = ImageEnhance.Brightness(im).enhance(1.02)
    return im


def upscale_to(im: Image.Image, width: int) -> Image.Image:
    h = max(1, round(im.height * width / im.width))
    return im.resize((width, h), Image.LANCZOS)


def write_webp(im: Image.Image, path: str, width: int) -> None:
    frame = upscale_to(im, width)
    frame.save(path, "WEBP", quality=QUALITY, method=6)
    print("  %-62s %dx%d  %.0fkB"
          % (os.path.relpath(path, ROOT), frame.width, frame.height, os.path.getsize(path) / 1024))


def build_pork_bbq() -> None:
    src = os.path.join(HERO, "pork-bbq-1280.webp")
    if not os.path.exists(src):
        raise SystemExit("missing " + src)
    with Image.open(src) as im:
        im = ImageOps.exif_transpose(im).convert("RGB")
    im = polish(im, sharpen=1.1)
    base = os.path.join(HERO, "pork-bbq.webp")
    im.save(base, "WEBP", quality=QUALITY, method=6)
    print("  %-62s %dx%d  %.0fkB"
          % (os.path.relpath(base, ROOT), im.width, im.height, os.path.getsize(base) / 1024))
    for w in (1024, 640):
        write_webp(im, os.path.join(HERO, "pork-bbq-%d.webp" % w), w)


def build_jinja_bridge() -> None:
    src = os.path.join(ROOT, "images", "jinja-main-bridge-view-from-hotel-at-night.jpeg")
    if not os.path.exists(src):
        raise SystemExit("missing " + src)
    with Image.open(src) as im:
        im = ImageOps.exif_transpose(im).convert("RGB")
    im = upscale_to(im, 1440)
    im = polish(im, sharpen=1.0)
    base = os.path.join(HERO, "jinja-main-bridge-view-from-hotel-at-night.webp")
    im.save(base, "WEBP", quality=QUALITY, method=6)
    print("  %-62s %dx%d  %.0fkB"
          % (os.path.relpath(base, ROOT), im.width, im.height, os.path.getsize(base) / 1024))
    for w in (1024, 640):
        write_webp(im, os.path.join(HERO, "jinja-main-bridge-view-from-hotel-at-night-%d.webp" % w), w)


def build_coctail_juice() -> None:
    src = os.path.join(ROOT, "images", "coctail-juice.jpg")
    if not os.path.exists(src):
        raise SystemExit("missing " + src)
    with Image.open(src) as im:
        im = ImageOps.exif_transpose(im).convert("RGB")
    # The hotel wants the 1024 copy to stand as the cocktail plate, so this one
    # is not blown up to a 1440 base that only softens it. The 1024 file is the
    # widest, and the build takes it as the source when no plain copy exists.
    im = upscale_to(im, 1024)
    im = polish(im, sharpen=1.05)
    base = os.path.join(HERO, "coctail-juice-1024.webp")
    im.save(base, "WEBP", quality=QUALITY, method=6)
    print("  %-62s %dx%d  %.0fkB"
          % (os.path.relpath(base, ROOT), im.width, im.height, os.path.getsize(base) / 1024))
    for w in (640, 480):
        write_webp(im, os.path.join(HERO, "coctail-juice-%d.webp" % w), w)
    # Retire the oversized base so the 1024 copy becomes the widest file and the
    # manifest serves it directly.
    stale = os.path.join(HERO, "coctail-juice.webp")
    if os.path.exists(stale):
        os.remove(stale)
        print("  removed over-scaled  coctail-juice.webp")


if __name__ == "__main__":
    print("pork-bbq:")
    build_pork_bbq()
    print("coctail juice (hero #4, 1024 stands in):")
    build_coctail_juice()
    print("jinja main bridge at night (kept on disk only):")
    build_jinja_bridge()
    print()
    print("Now rebuild the site:  npm run build   then   node tools/deploy-site.mjs .")