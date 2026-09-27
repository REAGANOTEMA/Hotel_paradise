#!/usr/bin/env python3
"""
Puts a photograph into the hero carousel.

The carousel only reads files named hero1, hero2 ... from /images, in numeric
order, so a photograph that is going to head the home page has to be copied in
under one of those names.

    python tools/make-hero.py triple-room.jpg 8

reads images/rooms/triple-room.jpg and writes images/hero8.webp, scaled to fit a
1920px wide screen and no larger, since a photograph is only ever shown behind
the opening writing and is cropped to fill whatever screen it lands on.
"""

import os
import sys

try:
    from PIL import Image, ImageOps
except ImportError:
    sys.exit("Pillow is not installed. Run:  pip install pillow")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGES = os.path.join(ROOT, "images")

# The carousel is a full bleed background, so 1920 covers a desktop outright and
# the smaller copies are built from here afterwards.
HERO_MAX_WIDTH = 1920
HERO_QUALITY = 80


def main():
    if len(sys.argv) != 3:
        sys.exit(__doc__)

    name, slot = sys.argv[1], sys.argv[2]
    if not slot.isdigit():
        sys.exit("The slot must be a number, for example: 8")

    source = os.path.join(IMAGES, "rooms", name)
    if not os.path.isfile(source):
        source = os.path.join(IMAGES, name)
    if not os.path.isfile(source):
        sys.exit("No photograph called " + name + " in images/rooms or images/")

    with Image.open(source) as im:
        im = ImageOps.exif_transpose(im)
        if im.mode not in ("RGB", "RGBA"):
            im = im.convert("RGB")

        if im.width > HERO_MAX_WIDTH:
            height = round(im.height * HERO_MAX_WIDTH / im.width)
            im = im.resize((HERO_MAX_WIDTH, height), Image.LANCZOS)

        target = os.path.join(IMAGES, "hero" + slot + ".webp")
        im.save(target, "WEBP", quality=HERO_QUALITY, method=6)

    kb = os.path.getsize(target) / 1024
    print("  %-24s ->  %s  %dx%d  %.0fkB"
          % (name, os.path.basename(target), im.width, im.height, kb))
    print()
    print("Now build the smaller copies and the site:")
    print("    python tools/make-derivatives.py")
    print("    npm run build")


if __name__ == "__main__":
    main()
