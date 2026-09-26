#!/usr/bin/env python3
"""
Builds the small copies the website uses for phones and for the widths a
photograph is actually displayed at.

Drop a full size photograph into /images/dishes, /images/rooms, /images/gallery
or /images (as hero1, hero2 ...), then run:

    python tools/make-derivatives.py

For every original this writes narrower copies beside it, for example:

    mushroom-soup.jpg          the original, never resized
    mushroom-soup-320.jpg      for a phone
    mushroom-soup-480.jpg      for a small card
    mushroom-soup-960.jpg      for a retina card

The site then hands each screen the smallest file that still covers it, so a
photograph is never downloaded at 2400px to fill a 300px card, and never
stretched from 480px to fill a desktop column.

Requires Pillow:  pip install pillow
"""

import os
import sys

try:
    from PIL import Image, ImageOps
except ImportError:
    sys.exit("Pillow is not installed. Run:  pip install pillow")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGES = os.path.join(ROOT, "images")

EXTS = (".jpg", ".jpeg", ".png", ".webp")
# Widths a card is ever displayed at, doubled for retina where the layout is
# a fixed pixel size rather than a fluid column.
DISH_LADDER = (320, 480, 640, 960, 1280)
ROOM_LADDER = (320, 480, 640, 960, 1280)
GALLERY_LADDER = (480, 960, 1440, 1920)
HERO_LADDER = (640, 1024, 1440, 1920, 2560)

# Never enlarge: a copy wider than the original would only be resampled back up
# by the browser, which is exactly the softness we are trying to remove.
MIN_UPLIFT = 1.15


def already_built(path, width, mtime):
    """True when a current copy of this width is already on disk."""
    for ext in EXTS:
        sidecar = path + "-" + str(width) + ext
        if os.path.exists(sidecar) and os.path.getmtime(sidecar) >= mtime:
            return True
    return False


def build_copies(path, ladder, quality=82):
    mtime = os.path.getmtime(path)
    stem = os.path.splitext(path)[0]
    original_bytes = os.path.getsize(path)
    made, skipped = [], []

    with Image.open(path) as im:
        im = ImageOps.exif_transpose(im)
        if im.mode not in ("RGB", "RGBA"):
            im = im.convert("RGB")
        source_width = im.width

        for width in ladder:
            if width >= source_width:
                # The original already covers this size, nothing to gain.
                continue
            if already_built(path, width, mtime):
                skipped.append(width)
                continue

            height = max(1, round(im.height * width / im.width))
            resized = im.resize((width, height), Image.LANCZOS)

            target = stem + "-" + str(width) + ".jpg"
            if im.mode == "RGBA":
                resized.convert("RGB").save(
                    target, "JPEG", quality=quality, optimize=True, progressive=True
                )
            else:
                resized.save(target, "JPEG", quality=quality, optimize=True, progressive=True)

            size = os.path.getsize(target)
            # A copy that saves almost nothing is just clutter in the folder.
            if size > original_bytes * 0.85:
                os.remove(target)
                continue

            made.append((width, size))

    return source_width, made, skipped


def process(folder, ladder, label, match=None):
    if not os.path.isdir(folder):
        return
    originals = [
        f
        for f in sorted(os.listdir(folder))
        if os.path.isfile(os.path.join(folder, f))
        and f.lower().endswith(EXTS)
        and not _is_copy(f)
        and (match is None or match(f))
    ]
    if not originals:
        print("  %-9s no photographs yet" % label)
        return

    print("  %-9s %d photograph(s)" % (label, len(originals)))
    for name in originals:
        full = os.path.join(folder, name)
        try:
            source_width, made, skipped = build_copies(full, ladder)
        except Exception as exc:  # keep going, a bad file should not stop the rest
            print("      %-34s skipped, %s" % (name, exc))
            continue

        if made:
            sizes = ", ".join("%dpx %.0fkB" % (w, b / 1024) for w, b in made)
            print("      %-34s %dpx wide  ->  %s" % (name, source_width, sizes))
        elif skipped:
            print("      %-34s %dpx wide  ->  copies up to date"
                  % (name, source_width))
        else:
            print("      %-34s %dpx wide  ->  too small for this ladder, "
                  "supply a larger original" % (name, source_width))


def _is_copy(name):
    stem = os.path.splitext(name)[0]
    tail = stem.rsplit("-", 1)[-1]
    return tail.isdigit() and len(tail) >= 2


def is_hero(name):
    """Only the numbered carousel photographs, never the logo or favicons."""
    stem = os.path.splitext(name)[0]
    return stem.lower().startswith("hero") and stem.lower()[4:].isdigit()


def main():
    if not os.path.isdir(IMAGES):
        sys.exit("No images folder found at " + IMAGES)
    print("Building photograph copies from", IMAGES)
    process(os.path.join(IMAGES, "dishes"), DISH_LADDER, "dishes")
    process(os.path.join(IMAGES, "rooms"), ROOM_LADDER, "rooms")
    process(os.path.join(IMAGES, "gallery"), GALLERY_LADDER, "gallery")
    process(IMAGES, HERO_LADDER, "hero", match=is_hero)
    print()
    print("Now rebuild the site so it picks the new copies up:  npm run build")


if __name__ == "__main__":
    main()
