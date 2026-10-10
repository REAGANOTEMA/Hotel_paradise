#!/usr/bin/env python3
"""
Writes the narrow copies the site actually serves, for every working folder that
was still missing them (the room bed tours, the meeting halls, the gallery, the
facilities, the food fallback and the site root plates).

It never touches an original: it only writes `<name>-<width>.jpg` beside it, the
same shape tools/make-derivatives.py produces, which SmartImage already picks up.
A file is skipped when it is small enough to serve as it stands, or when a copy
of the widest width this folder needs is already on disk.

    python tools/generate-derivatives.py          # write the missing copies
    python tools/generate-derivatives.py --check   # report only
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
COPY_EXTS = (".jpg", ".jpeg")

# Only an original heavier than this is worth a copy ladder. A 40 kB plate is
# already fast enough to hand to a phone exactly as it is.
HEAVY = 320 * 1024
QUALITY = 82

# (folder, ladder). The widest width is what tells whether a file was done.
FOLDERS = [
    ("executive-beds-images", (320, 480, 640, 960, 1280)),
    ("suit-beds-images",      (320, 480, 640, 960, 1280)),
    ("triple-beds-images",    (320, 480, 640, 960, 1280)),
    ("twin-bed-images",       (320, 480, 640, 960, 1280)),
    ("deluxe-double-beds-images", (320, 480, 640, 960, 1280)),
    ("meeting-rooms",         (320, 480, 640, 960, 1280)),
    ("gallery",               (480, 960, 1440)),
    ("facilities",            (480, 960, 1440)),
    ("food",                  (320, 480, 640, 960, 1280)),
    ("dishes",                (320, 480, 640, 960, 1280)),
    ("rooms",                 (320, 480, 640, 960, 1280)),
]

# The site root holds the working plates the pages point at by name. Only these
# are processed; the camera-size hero*.jpg originals are not used by any page and
# are left alone so the deploy is not padded with copies nothing reads.
ROOT_TARGETS = [
    "Bar", "Pool-Area", "Pool-768x512", "double-deluxe-bed",
    "executive-deluxe-room", "gym", "single-room", "tripple-room",
    "steak-with-wedges", "juice-hero", "wine-hero", "sea-food-hero",
    "paradise-banquet-hall-768x1024", "paradise-conference-room",
    "paradise-logo", "suite-bed", "Hotel-paradise", "hotel-paradise",
    "Hotel-Paradise-on-the-Nile-Conferences-Weddings-cover",
    "hotel-paradise-on-the-nile-conferences-weddings",
]
ROOT_LADDER = (480, 960, 1440)

CHECK = "--check" in sys.argv


def is_copy(name):
    stem = os.path.splitext(name)[0]
    tail = stem.rsplit("-", 1)[-1]
    return tail.isdigit() and len(tail) >= 2


def has_copy(path, width):
    stem = os.path.splitext(path)[0]
    return any(os.path.exists(stem + "-" + str(width) + ext) for ext in COPY_EXTS)


def find(folder, base):
    for ext in EXTS:
        p = os.path.join(folder, base + ext)
        if os.path.isfile(p):
            return p
    return None


def build(path, ladder):
    made = []
    original_bytes = os.path.getsize(path)
    stem = os.path.splitext(path)[0]
    if has_copy(path, ladder[-1]):
        return made, "done"
    with Image.open(path) as im:
        im = ImageOps.exif_transpose(im)
        if im.mode not in ("RGB", "RGBA"):
            im = im.convert("RGB")
        width = im.width
        for w in ladder:
            if w >= width:
                continue
            target = stem + "-" + str(w) + ".jpg"
            if os.path.exists(target):
                continue
            if CHECK:
                made.append((w, 0))
                continue
            h = max(1, round(im.height * w / im.width))
            out = im.resize((w, h), Image.LANCZOS).convert("RGB")
            out.save(target, "JPEG", quality=QUALITY, optimize=True, progressive=True)
            if os.path.getsize(target) > original_bytes * 0.85:
                os.remove(target)
                continue
            made.append((w, os.path.getsize(target)))
    return made, ("wrote" if made else "small")


def run():
    total_files = 0
    total_bytes = 0
    for folder, ladder in FOLDERS + [(None, ROOT_LADDER)]:
        if folder is None:
            base_dir = IMAGES
            names = [find(base_dir, b) for b in ROOT_TARGETS]
            label = "(site root)"
        else:
            base_dir = os.path.join(IMAGES, folder)
            if not os.path.isdir(base_dir):
                continue
            names = [
                os.path.join(base_dir, n)
                for n in sorted(os.listdir(base_dir))
                if os.path.isfile(os.path.join(base_dir, n))
                and n.lower().endswith(EXTS)
                and not is_copy(n)
            ]
            label = folder
        n = 0
        for path in names:
            if not path or not os.path.isfile(path):
                continue
            if os.path.getsize(path) < HEAVY:
                continue
            try:
                made, note = build(path, ladder)
            except Exception as exc:
                print("  %-28s %-40s skipped, %s" % (label, os.path.basename(path), exc))
                continue
            if made:
                n += 1
                total_files += 1
                b = sum(m[1] for m in made)
                total_bytes += b
                print("  %-28s %-40s %s" % (
                    label, os.path.basename(path),
                    ", ".join("%dpx %.0fkB" % (w, s / 1024) for w, s in made)))
        if n:
            print("  -> %s: %d file(s)" % (label, n))
    verb = "would write" if CHECK else "wrote"
    print("\n%s copies for %d original(s), %.1f MB of derivatives" % (
        verb, total_files, total_bytes / 1024 / 1024))


if __name__ == "__main__":
    run()
