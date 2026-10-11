#!/usr/bin/env python3
"""
Rebuilds the carousel photograph that sits second in the hero, the pork
barbecue over the coals.

That photograph only ever arrived at 612x344, which a desktop then stretches
across a full width screen and shows soft. There is no larger original on disk,
so this rebuilds the hero copy at the widths the carousel actually asks for
using a high quality Lanczos step and a light unsharp mask, which reads
noticeably crisper than the browser's own upscale of the 612px file.

Run from the project root:

    python tools\\fix-hero-slide2.py

It rewrites, beside the existing files in /images/hero:

    pork-bbq-on-fire.webp        1280px, the file the slide is served from
    pork-bbq-on-fire-1024.webp   the real 1024px step
    pork-bbq-on-fire-640.webp    a phone step

The 480px copy is left in place. The manifest picks the new files up on the
next build, so finish with:  npm run build  and then the deploy step.
"""
from __future__ import annotations

import os

from PIL import Image, ImageFilter, ImageOps

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
HERO = os.path.join(ROOT, "images", "hero")

SOURCE = os.path.join(ROOT, "images", "pork-bbq-on-fire.jpg")
BASE = os.path.join(HERO, "pork-bbq-on-fire.webp")

# The widths the carousel actually requests, widest first so the base file is
# the widest one and every narrower step is a true downscale of it.
WIDTHS = [1280, 1024, 640]
QUALITY = 82


def sharpen(im: Image.Image) -> Image.Image:
    """A gentle unsharp mask: enough to counter the upscale, not a halo."""
    return im.filter(ImageFilter.UnsharpMask(radius=1.6, percent=115, threshold=3))


def main() -> None:
    if not os.path.exists(SOURCE):
        raise SystemExit("No source photograph at " + SOURCE)

    with Image.open(SOURCE) as im:
        im = ImageOps.exif_transpose(im).convert("RGB")
        src_w, src_h = im.size
        target_w = WIDTHS[0]
        target_h = round(src_h * target_w / src_w)

        up = im.resize((target_w, target_h), Image.LANCZOS)
        up = sharpen(up)

        for width in WIDTHS:
            height = round(target_h * width / target_w)
            frame = up if width == target_w else up.resize((width, height), Image.LANCZOS)
            out = BASE if width == target_w else os.path.join(HERO, "pork-bbq-on-fire-%d.webp" % width)
            frame.save(out, "WEBP", quality=QUALITY, method=6)
            print("  %-46s %dx%d  %.0fkB"
                  % (os.path.relpath(out, ROOT), frame.width, frame.height,
                     os.path.getsize(out) / 1024))

    print()
    print("Source was %dx%d. Now rebuild the site:  npm run build" % (src_w, src_h))


if __name__ == "__main__":
    main()
