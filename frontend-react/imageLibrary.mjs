/**
 * Image library scanner.
 *
 * Walks the /images folder and records, for every photo, the slug the site
 * refers to it by, its real pixel size and its extension. The result is written
 * to src/image-manifest.json so the React pages can:
 *
 *   - render the right file with the right extension on the first try,
 *   - reserve the exact box before the bytes arrive, so nothing jumps,
 *   - build a real srcset instead of asking a phone to download a desktop file,
 *   - show a designed placeholder immediately for photos that do not exist yet,
 *     with no 404 requests and no flash of a broken image.
 */

import fs from 'node:fs';
import path from 'node:path';

const EXTS = ['.jpg', '.jpeg', '.png', '.webp', '.avif'];

/** Reads the pixel dimensions out of a PNG, JPEG or WebP header. */
export function readSize(file) {
  let buf;
  try {
    buf = fs.readFileSync(file);
  } catch {
    return null;
  }
  if (buf.length < 26) return null;

  // PNG: 8 byte signature, then an IHDR chunk holding two big endian uint32s.
  if (buf.readUInt32BE(0) === 0x89504e47) {
    return { w: buf.readUInt32BE(16), h: buf.readUInt32BE(20) };
  }

  // WebP: RIFF container, the real dimensions live in the first chunk.
  if (buf.toString('ascii', 0, 4) === 'RIFF' && buf.toString('ascii', 8, 12) === 'WEBP') {
    const fourcc = buf.toString('ascii', 12, 16);
    if (fourcc === 'VP8X') {
      return {
        w: 1 + (buf[24] | (buf[25] << 8) | (buf[26] << 16)),
        h: 1 + (buf[27] | (buf[28] << 8) | (buf[29] << 16))
      };
    }
    if (fourcc === 'VP8L') {
      const bits = buf.readUInt32LE(21);
      return { w: (bits & 0x3fff) + 1, h: ((bits >> 14) & 0x3fff) + 1 };
    }
    if (fourcc === 'VP8 ') {
      return { w: (buf[26] | (buf[27] << 8)) & 0x3fff, h: (buf[28] | (buf[29] << 8)) & 0x3fff };
    }
    return null;
  }

  // JPEG: walk the segment markers until a start of frame is found.
  if (buf[0] === 0xff && buf[1] === 0xd8) {
    let i = 2;
    while (i < buf.length - 9) {
      if (buf[i] !== 0xff) { i++; continue; }
      const marker = buf[i + 1];
      const size = buf.readUInt16BE(i + 2);
      const isFrame =
        marker >= 0xc0 && marker <= 0xcf && ![0xc4, 0xc8, 0xcc].includes(marker);
      if (isFrame) {
        return { h: buf.readUInt16BE(i + 5), w: buf.readUInt16BE(i + 7) };
      }
      i += 2 + size;
    }
  }

  return null;
}

/** Lower cases the file name and drops the extension, which is the site slug. */
const toSlug = (name) =>
  name
    .toLowerCase()
    .replace(/\.[^.]+$/, '')
    .replace(/&/g, 'and')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

/**
 * Collapses a folder of photos into slug -> {ext,w,h,variants}.
 *
 * Two file shapes are understood:
 *   mushroom-soup.jpg        the original, the fallback for any screen
 *   mushroom-soup-480.jpg    a narrower copy, preferred by small screens
 *
 * A slug is only offered to a browser at a width the file really has, which is
 * what stops a phone being handed a 2400px original, and stops a desktop being
 * handed a 480px copy that has to be stretched.
 */
function scanFolder(dir) {
  const out = {};
  if (!fs.existsSync(dir)) return out;

  for (const name of fs.readdirSync(dir).sort()) {
    const full = path.join(dir, name);
    if (!fs.statSync(full).isFile()) continue;
    const ext = path.extname(name).toLowerCase();
    if (!EXTS.includes(ext)) continue;

    const base = toSlug(name);
    if (!base) continue;

    // A trailing -NNN is a generated derivative width, not part of the slug.
    const sized = /^(.*)-(\d{2,4})$/.exec(base);
    const slug = sized ? sized[1] : base;
    const width = sized ? Number(sized[2]) : 0;
    if (!slug) continue;

    const size = readSize(full) || { w: width, h: 0 };
    const entry = (out[slug] ??= { ext: ext.slice(1), w: 0, h: 0, variants: [] });

    if (!width) {
      // The original. Only the first one for a slug counts.
      if (entry.w) continue;
      entry.ext = ext.slice(1);
      entry.w = size.w;
      entry.h = size.h;
    } else {
      entry.variants.push({ w: width, ext: ext.slice(1), h: size.h });
    }
  }

  for (const entry of Object.values(out)) {
    entry.variants.sort((a, b) => a.w - b.w);
    // Never advertise a copy wider than the original it came from.
    entry.variants = entry.variants.filter(v => !entry.w || v.w < entry.w);
  }
  return out;
}

/**
 * The home page carousel, in the order it plays.
 *
 * Each entry names a file under /images, with or without a subfolder and
 * without its extension, and the build works out everything else: the real
 * pixel size, the narrower copies sitting beside it, and whether the slot is
 * a still photograph or the hotel film. A slot whose file is missing is
 * skipped with a warning rather than shown as an empty frame.
 *
 *   hero/view     a photograph in /images/hero
 *   hero1         a photograph in /images itself
 *   hotel-view    a video, played over hotel-view-poster.jpg
 *
 * Every slot is a different picture. `/images/hero` holds the resized WebP set
 * the page is built from, so the carousel never falls back to a multi megabyte
 * camera original, and no two slides are the same photograph under two names.
 * The order is matched, one for one, to HERO_COPY on the home page. The
 * headline shots the hotel asked for come first - the main building, the pool,
 * the beds, the conference and wedding scenes, the view, the entrance and the
 * signature dishes and drinks - and the remaining classic hero photographs
 * follow behind them.
 */
const HERO_SEQUENCE = [
  'hero/pool',
  'hero/hotel',
  'hero/bed-executive',
  'hero/food-table',
  'hero/burger',
  'hero/food-fruit',
  'hero/food-spread',
  'hero/view',
  'hero/food-pizza-two',
  'hero/bed-suite',
  'hero/food-fish',
  'hero/food-pizza'
];

const VIDEO_EXTS = ['.mp4', '.webm', '.mov', '.m4v'];

/** Escapes a slug so it can be matched literally inside a regular expression. */
const escapeRe = (s) => s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

/**
 * Reads one slot of the carousel: the file itself, the `-NNN` copies that
 * narrow it for a phone, and the poster if the slot is a film.
 *
 * The file name is matched literally, never split on a trailing number, so
 * `suite-320.jpg` stays a photograph called suite-320 and does not turn into
 * a 320 pixel copy of a room called suite.
 */
function scanSlot(imagesRoot, token) {
  const slash = token.lastIndexOf('/');
  const sub = slash < 0 ? '' : token.slice(0, slash);
  const base = slash < 0 ? token : token.slice(slash + 1);
  const dir = sub ? path.join(imagesRoot, sub) : imagesRoot;
  if (!fs.existsSync(dir)) return null;

  const dirUrl = './images/' + (sub ? sub.replace(/\\/g, '/') + '/' : '');
  const variants = [];
  const stills = [];
  const films = [];

  for (const name of fs.readdirSync(dir)) {
    const ext = path.extname(name).toLowerCase();
    if (!EXTS.includes(ext) && !VIDEO_EXTS.includes(ext)) continue;
    const stem = name.slice(0, name.length - ext.length).toLowerCase();
    const full = path.join(dir, name);

    if (stem === base) {
      (VIDEO_EXTS.includes(ext) ? films : stills).push({file: name, ext: ext.slice(1), full});
      continue;
    }
    if (new RegExp('^' + escapeRe(base) + '-\\d{2,4}$').test(stem)) {
      const size = readSize(full) || {w: 0, h: 0};
      variants.push({
        file: name,
        ext: ext.slice(1),
        w: size.w || Number(stem.slice(base.length + 1)),
        h: size.h
      });
    }
  }

  if (!stills.length && !films.length && !variants.length) return null;

  // Two files can answer to the same name in different cases; take them in a
  // predictable order so the carousel never changes between builds.
  stills.sort((a, b) => a.file.localeCompare(b.file));
  films.sort((a, b) => a.file.localeCompare(b.file));
  variants.sort((a, b) => a.w - b.w);

  // The film slot: played over its poster, which is named after the film.
  if (!stills.length && films.length) {
    const film = films[0];
    const size = readSize(film.full) || {w: 0, h: 0};
    const posterStem = base + '-poster';
    const posterName = fs.readdirSync(dir).find(f => path.parse(f).name.toLowerCase() === posterStem);
    const poster = posterName
      ? (() => {
          const pext = path.extname(posterName).slice(1).toLowerCase();
          const psize = readSize(path.join(dir, posterName)) || {w: 0, h: 0};
          return {dir: dirUrl, file: posterName, ext: pext, w: psize.w, h: psize.h};
        })()
      : undefined;
    return {
      slug: base,
      dir: dirUrl,
      file: film.file,
      ext: film.ext,
      w: size.w,
      h: size.h,
      variants: [],
      kind: 'video',
      poster
    };
  }

  // A still, or a photograph that only exists as narrow copies: the widest of
  // those copies then stands in for the original, which is what keeps
  // `hero/view` (960, 1280 and 1920 only) from asking the browser for a
  // `view.webp` that was never written.
  let shot = stills[0];
  if (!shot) {
    const widest = variants.pop();
    shot = {file: widest.file, ext: widest.ext, full: path.join(dir, widest.file)};
  }
  const size = readSize(shot.full) || {w: 0, h: 0};

  return {
    slug: base,
    dir: dirUrl,
    file: shot.file,
    ext: shot.ext,
    w: size.w,
    h: size.h,
    // Never advertise a copy as wide as the file it is served from.
    variants: variants.filter(v => !size.w || v.w < size.w),
    kind: 'image'
  };
}

/** The carousel, built in the order the homepage plays it. */
function scanHero(imagesRoot) {
  const out = [];
  for (const token of HERO_SEQUENCE) {
    const slot = scanSlot(imagesRoot, token);
    if (!slot) console.warn('  hero       ' + token + ' skipped, no file found');
    else out.push(slot);
  }
  return out;
}

export function buildImageManifest(imagesRoot) {
  return {
    dishes: scanFolder(path.join(imagesRoot, 'dishes')),
    // The kitchen keeps two working folders: /images/dishes (the files the menu
    // is built from) and /images/food (a filing copy). A dish that has no plate
    // in /images/dishes is served from /images/food, so a photograph the kitchen
    // filed only once is never shown as an empty box.
    food: scanFolder(path.join(imagesRoot, 'food')),
    rooms: scanFolder(path.join(imagesRoot, 'rooms')),
    gallery: scanFolder(path.join(imagesRoot, 'gallery')),
    // The hotel's six headline facts, each illustrated by one landscape plate.
    facilities: scanFolder(path.join(imagesRoot, 'facilities')),
    // Photographs that live in the site root itself: the new room plates
    // (single-room, tripple-room, executive-deluxe-room), the pool, the gym,
    // the bar, the main building and the hotel logo.
    site: scanFolder(imagesRoot),
    // The meeting rooms and banquet halls the events page is built from.
    halls: scanFolder(path.join(imagesRoot, 'meeting-rooms')),
    // The rooms page bed tours: each room type keeps its own working folder of
    // bed photographs, named beds-* so a slug can never collide with a dish.
    'beds-exec': scanFolder(path.join(imagesRoot, 'executive-beds-images')),
    'beds-suit': scanFolder(path.join(imagesRoot, 'suit-beds-images')),
    'beds-triple': scanFolder(path.join(imagesRoot, 'triple-beds-images')),
    'beds-twin': scanFolder(path.join(imagesRoot, 'twin-bed-images')),
    hero: scanHero(imagesRoot)
  };
}
