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

/** The hero carousel is a numbered sequence, grouped the same way as folders. */
function scanHero(dir) {
  const out = [];
  if (!fs.existsSync(dir)) return out;

  const byBase = new Map();
  for (const name of fs.readdirSync(dir)) {
    if (!/^hero\d+([-.]\d+)?\.[a-z0-9]+$/i.test(name)) continue;
    const ext = path.extname(name).toLowerCase();
    if (!EXTS.includes(ext)) continue;

    const base = toSlug(name);
    const sized = /^(hero\d+)-(\d{2,4})$/.exec(base);
    const key = sized ? sized[1] : base;
    const width = sized ? Number(sized[2]) : 0;
    if (!byBase.has(key)) byBase.set(key, { slug: key, ext: ext.slice(1), w: 0, h: 0, variants: [] });

    const entry = byBase.get(key);
    const size = readSize(path.join(dir, name)) || { w: width, h: 0 };
    if (width) {
      entry.variants.push({ w: width, ext: ext.slice(1), h: size.h });
    } else if (!entry.w) {
      entry.ext = ext.slice(1);
      entry.w = size.w;
      entry.h = size.h;
    }
  }

  // hero2 before hero10, not the other way round.
  for (const key of [...byBase.keys()].sort((a, b) => a.localeCompare(b, undefined, {numeric: true}))) {
    const entry = byBase.get(key);
    entry.variants.sort((a, b) => a.w - b.w);
    entry.variants = entry.variants.filter(v => !entry.w || v.w < entry.w);
    out.push(entry);
  }
  return out;
}

export function buildImageManifest(imagesRoot) {
  return {
    dishes: scanFolder(path.join(imagesRoot, 'dishes')),
    rooms: scanFolder(path.join(imagesRoot, 'rooms')),
    gallery: scanFolder(path.join(imagesRoot, 'gallery')),
    hero: scanHero(imagesRoot)
  };
}
