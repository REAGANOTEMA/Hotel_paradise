#!/usr/bin/env python3
"""
Fills the gaps in the photograph copies for a fixed, hand checked list.

The site never asks for a copy wider than a file really is, so an original that
is only served at one size is fine, but a heavy original that is the only file
wide enough for a desktop card is the one that gets picked and costs a guest
several megabytes. This script names exactly those files, and writes only the
narrower copies that are missing. It never crops or rewrites an original, so it
is safe to run beside the full tools/make-derivatives.py.

    python tools/generate-missing-derivatives.py
"""

import os
import sys

try:
    from PIL import Image, ImageOps
except ImportError:
    sys.exit("Pillow is not installed. Run:  pip install pillow")

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGES = os.path.join(ROOT, "images")

# The ladder the dish and food cards use. Rooms use the same widths, laid out
# as a portrait frame by the card itself.
LADDER = (320, 480, 640, 960, 1280)

ORIGINAL_EXTS = (".jpg", ".jpeg", ".png", ".webp")

# (folder, original base name) for every photograph the audit found with a
# heavy original and no copy wide enough for the box it is shown in.
TARGETS = [
    # dishes: shown on the menu detail, needs the wide retina copy too
    ("dishes", "pork-spring-roll"),
    ("dishes", "avocado-and-lettuce-salad"),
    ("dishes", "chicken-salad-sandwich"),
    ("dishes", "tuna-salad"),
    ("dishes", "chicken-wrap"),
    ("dishes", "special-chicken-wings"),
    # food: the fallback group behind the dishes
    ("food", "pork-spring-roll"),
    ("food", "liver-with-shredded-vegetables"),
    ("food", "chocolate-cake-slice"),
    ("food", "classic-carrot-cake"),
    ("food", "bolognese"),
    ("food", "sizzler-pork-plate"),
    ("food", "avocado-lettuce-salad"),
    ("food", "chicken-salad-sandwich"),
    ("food", "chilli-beef-and-veggie-chips"),
    ("food", "golden-fried-cauliflower"),
    ("food", "smoked-fish"),
    ("food", "tuna-salad"),
    ("food", "chicken-wrap"),
    ("food", "special-chicken-wings"),
    # rooms: the only two room originals that are both heavy and uncovered
    ("rooms", "deluxe-double"),
    ("rooms", "triple-room"),
]


def find_original(folder, base):
    """The one file in the folder that is the photograph itself, never a copy."""
    path_dir = os.path.join(IMAGES, folder)
    for ext in ORIGINAL_EXTS:
        candidate = os.path.join(path_dir, base + ext)
        if os.path.isfile(candidate):
            return candidate
    return None


def build_copies(path):
    original_bytes = os.path.getsize(path)
    made, kept = [], []

    with Image.open(path) as im:
        im = ImageOps.exif_transpose(im)
        if im.mode not in ("RGB", "RGBA"):
            im = im.convert("RGB")
        source_width = im.width
        stem = os.path.splitext(path)[0]

        for width in LADDER:
            if width >= source_width:
                continue
            target = stem + "-" + str(width) + ".jpg"
            if os.path.exists(target):
                kept.append(width)
                continue

            height = max(1, round(im.height * width / im.width))
            resized = im.resize((width, height), Image.LANCZOS)
            resized.convert("RGB").save(
                target, "JPEG", quality=82, optimize=True, progressive=True
            )

            # A copy that saves almost nothing is clutter, so it goes, exactly
            # as the full generator treats it.
            if os.path.getsize(target) > original_bytes * 0.85:
                os.remove(target)
                continue
            made.append((width, os.path.getsize(target)))

    return source_width, made, kept


def main():
    if not os.path.isdir(IMAGES):
        sys.exit("No images folder found at " + IMAGES)

    print("Filling missing photograph copies")
    total = 0
    for folder, base in TARGETS:
        path = find_original(folder, base)
        if not path:
            print("  %-9s %-34s no original found" % (folder, base))
            continue
        try:
            width, made, kept = build_copies(path)
        except Exception as exc:
            print("  %-9s %-34s skipped, %s" % (folder, base, exc))
            continue

        if made:
            sizes = ", ".join("%dpx %.0fkB" % (w, b / 1024) for w, b in made)
            print("  %-9s %-34s %dpx  ->  %s" % (folder, base, width, sizes))
            total += len(made)
        else:
            note = "copies already complete" if kept else "too small for this ladder"
            print("  %-9s %-34s %dpx  ->  %s" % (folder, base, width, note))

    print()
    print("Wrote %d new cop%s." % (total, "y" if total == 1 else "ies"))
    print("Now rebuild the site so it picks them up:  npm run build")


if __name__ == "__main__":
    main()
