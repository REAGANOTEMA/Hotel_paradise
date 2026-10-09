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
FACILITIES_LADDER = (480, 960, 1440, 1920)
HERO_LADDER = (640, 1024, 1440, 1920, 2560)

# The room card is a portrait frame. A wide photograph left alone would have its
# sides cut off by the browser instead of by us, and the small copies would then
# be cut from a different picture than the one on screen, so rooms are cropped
# here to the shape the card actually has.
ROOM_CARD_RATIO = (3.0, 4.0)

# Never enlarge: a copy wider than the original would only be resampled back up
# by the browser, which is exactly the softness we are trying to remove.
MIN_UPLIFT = 1.15


def save_like(path, im, quality=88):
    """Writes an image back in the format its own file name promises."""
    ext = os.path.splitext(path)[1].lower()
    if ext in (".jpg", ".jpeg"):
        im.convert("RGB").save(path, "JPEG", quality=quality, optimize=True, progressive=True)
    elif ext == ".webp":
        im.convert("RGB").save(path, "WEBP", quality=quality, method=6)
    else:
        im.save(path)


def derivative_copies(stem):
    """The narrower copies that belong to one original."""
    out = []
    folder = os.path.dirname(stem)
    base = os.path.basename(stem)
    for name in sorted(os.listdir(folder)):
        full = os.path.join(folder, name)
        if not os.path.isfile(full):
            continue
        other = os.path.splitext(name)[0]
        if not other.startswith(base + "-"):
            continue
        tail = other[len(base) + 1:]
        if tail.isdigit() and len(tail) >= 2:
            out.append(full)
    return out


def crop_to_ratio(im, ratio, focus=0.5):
    """
    Centre crops to a width:height ratio, keeping the middle of the frame.

    A bed is shot straight on and sits in the middle of it, so the middle is
    what is worth keeping. Returns the image and whether anything was cut.
    """
    target = ratio[0] / ratio[1]
    w, h = im.size
    if abs(w / h - target) <= 0.02:
        return im, False
    if w / h > target:                       # too wide, take a slice out of the sides
        new_w = max(1, round(h * target))
        left = max(0, min(round((w - new_w) * focus), w - new_w))
        return im.crop((left, 0, left + new_w, h)), True
    new_h = max(1, round(w / target))        # too tall, take one off the top and bottom
    top = max(0, min(round((h - new_h) * focus), h - new_h))
    return im.crop((0, top, w, top + new_h)), True


def crop_rooms():
    """Fits every room photograph to the card, and clears the copies of the old one."""
    folder = os.path.join(IMAGES, "rooms")
    if not os.path.isdir(folder):
        return
    originals = [
        f
        for f in sorted(os.listdir(folder))
        if os.path.isfile(os.path.join(folder, f))
        and f.lower().endswith(EXTS)
        and not _is_copy(f)
    ]
    if not originals:
        return

    print("  %-9s fitting %d photograph(s) to the %g:%g card"
          % ("rooms", len(originals), ROOM_CARD_RATIO[0], ROOM_CARD_RATIO[1]))
    for name in originals:
        full = os.path.join(folder, name)
        try:
            with Image.open(full) as im:
                im = ImageOps.exif_transpose(im)
                if im.mode not in ("RGB", "RGBA"):
                    im = im.convert("RGB")
                before = im.size
                cropped, changed = crop_to_ratio(im, ROOM_CARD_RATIO)
                if changed:
                    # A copy left over from the previous photograph would still be
                    # offered to a phone, and it is that old picture it points at,
                    # so it goes before any new copy is made.
                    stem = os.path.splitext(full)[0]
                    for old in derivative_copies(stem):
                        os.remove(old)
                    save_like(full, cropped)
                after = cropped.size
        except Exception as exc:  # a bad file should not stop the rest
            print("      %-34s skipped, %s" % (name, exc))
            continue

        if before == after:
            print("      %-34s already %g:%g  (%dx%d)"
                  % (name, ROOM_CARD_RATIO[0], ROOM_CARD_RATIO[1], after[0], after[1]))
        else:
            print("      %-34s %dx%d -> %dx%d  cropped to the card"
                  % (name, before[0], before[1], after[0], after[1]))


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
    crop_rooms()
    process(os.path.join(IMAGES, "dishes"), DISH_LADDER, "dishes")
    process(os.path.join(IMAGES, "rooms"), ROOM_LADDER, "rooms")
    process(os.path.join(IMAGES, "gallery"), GALLERY_LADDER, "gallery")
    process(os.path.join(IMAGES, "facilities"), FACILITIES_LADDER, "facilities")
    process(IMAGES, HERO_LADDER, "hero", match=is_hero)
    print()
    print("Now rebuild the site so it picks the new copies up:  npm run build")


if __name__ == "__main__":
    main()
