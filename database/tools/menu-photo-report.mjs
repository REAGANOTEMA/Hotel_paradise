/**
 * Answers one question: does every photograph the menu points at really exist?
 *
 *   node database/tools/menu-photo-report.mjs            (fallback menu)
 *   node database/tools/menu-photo-report.mjs --live     (database export)
 *
 * --live reads the tab separated export in %TEMP%/liveitems.tsv, written with
 *
 *   SELECT c.id,c.name,c.outlet,c.sort_order,c.image,
 *          i.id,i.name,i.image,i.price,i.group_name
 *   FROM menu_categories c
 *   JOIN menu_items i ON i.category_id=c.id AND i.active=1
 *   ORDER BY c.sort_order,c.id,i.sort_order,i.id;
 *
 * Anything that has no file is printed, together with the closest names on
 * disk, which is normally a photograph filed under a misspelling.
 */

import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const EXTS = ['.jpg', '.jpeg', '.png', '.webp', '.avif'];

const slug = s =>
  String(s)
    .toLowerCase()
    .replace(/\.[^.]+$/, '')
    .replace(/&/g, 'and')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

function scan(sub) {
  const map = new Map();
  const dir = path.join(ROOT, 'images', sub);
  if (!fs.existsSync(dir)) return map;
  for (const name of fs.readdirSync(dir)) {
    const full = path.join(dir, name);
    if (!fs.statSync(full).isFile()) continue;
    const ext = path.extname(name).toLowerCase();
    if (!EXTS.includes(ext)) continue;
    let base = slug(name);
    const sized = /^(.*)-(\d{2,4})$/.exec(base);
    if (sized) base = sized[1];
    if (!base || map.has(base)) continue;
    map.set(base, name);
  }
  return map;
}

const dishes = scan('dishes');
const food = scan('food');

const where = (s) => (dishes.has(s) ? `images/dishes/${dishes.get(s)}` : food.has(s) ? `images/food/${food.get(s)}` : null);

/** The nearest file names on disk, for a slug that matches nothing exactly. */
const near = (s) => {
  const words = s.split('-').filter(w => w.length > 3);
  const pool = [...new Set([...dishes.keys(), ...food.keys()])];
  return pool
    .map(k => ({k, score: words.filter(w => k.includes(w)).length + (k.startsWith(s.slice(0, 8)) ? 1 : 0)}))
    .filter(x => x.score >= Math.max(2, Math.ceil(words.length * 0.6)))
    .sort((a, b) => b.score - a.score)
    .slice(0, 3)
    .map(x => x.k);
};

const live = process.argv.includes('--live');
const file = path.join(process.env.TEMP || '/tmp', 'liveitems.tsv');

let items = [];
let sections = [];

if (live) {
  const rows = fs.readFileSync(file, 'utf8').split(/\r?\n/).filter(Boolean).map(l => l.split('\t'));
  const seen = new Map();
  for (const r of rows) {
    const clean = v => (!v || v === 'NULL' ? '' : v);
    const [cid, cname, outlet, sort, rawBanner, iid, iname, rawImage] = r;
    if (!seen.has(cid)) {
      seen.set(cid, {id: cid, name: cname, outlet, banner: clean(rawBanner), items: []});
      sections.push(seen.get(cid));
    }
    seen.get(cid).items.push({name: iname, image: clean(rawImage)});
  }
  items = sections.flatMap(s => s.items.map(i => ({...i, section: s.name})));
} else {
  const src = fs.readFileSync(path.join(ROOT, 'frontend-react', 'src', 'menuData.ts'), 'utf8');
  const re = /item\(\s*(?:'((?:[^'\\]|\\.)*)'|"((?:[^"\\]|\\.)*)")\s*,\s*(?:'((?:[^'\\]|\\.)*)'|"((?:[^"\\]|\\.)*)")\s*,\s*[^,]+,\s*(?:'((?:[^'\\]|\\.)*)'|"((?:[^"\\]|\\.)*)")(?:\s*,\s*(?:'((?:[^'\\]|\\.)*)'|"((?:[^"\\]|\\.)*)"))?/g;
  let m;
  while ((m = re.exec(src))) {
    const name = (m[1] ?? m[2] ?? '').replace(/\\'/g, "'");
    const group = (m[5] ?? m[6] ?? '').replace(/\\'/g, "'");
    const image = (m[7] ?? m[8] ?? '').replace(/\\'/g, "'");
    if (name) items.push({name, image, section: group});
  }
  const secRe = /key:\s*'([^']+)',\s*\n\s*name:\s*'([^']+)',\s*\n\s*eyebrow:\s*'((?:[^'\\]|\\.)*)',\s*\n\s*blurb:\s*(?:'((?:[^'\\]|\\.)*)'|"((?:[^"\\]|\\.)*)"),\s*\n\s*image:\s*'([^']*)'/g;
  while ((m = secRe.exec(src))) sections.push({key: m[1], name: m[2], banner: m[6] || '', items: []});
}

const hit = [];
const missing = [];
for (const it of items) {
  const want = it.image ? slug(it.image) : slug(it.name);
  const found = where(want);
  (found ? hit : missing).push({...it, want, found});
}

console.log(`${live ? 'live' : 'fallback'} menu: ${items.length} dishes`);
console.log(`photograph on disk: ${hit.length}`);
console.log(`no photograph:      ${missing.length}`);
console.log('');
if (missing.length) {
  console.log('=== DISHES WITH NO PHOTOGRAPH ===');
  for (const x of missing) {
    const guess = near(x.want);
    console.log(`${x.section} > ${x.name}`);
    console.log(`    wants: ${x.image || x.want + '.jpg'}` + (guess.length ? `\n    near:  ${guess.join(', ')}` : ''));
  }
}

if (live) {
  const noBanner = sections.filter(s => !s.banner || !where(slug(s.banner)));
  console.log('');
  console.log(`=== SECTIONS: ${sections.length}, without a banner that exists: ${noBanner.length} ===`);
  for (const s of noBanner) console.log(`  ${s.outlet} ${s.name} -> ${s.banner || '(no banner)'}`);
}
