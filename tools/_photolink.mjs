/**
 * Pairs every dish on the live menu with a photograph that is really on disk.
 *
 *   node tools/_photolink.mjs          print what would change
 *   node tools/_photolink.mjs --write  run the UPDATEs
 *
 * The menu tables hold an `image` column, but most rows were left empty, so the
 * site fell back to guessing a file name from the dish name, and every guess
 * that did not land exactly (an accent, a bracket, a plural) came up as a plate
 * with no photograph. This reads the build manifest, takes the closest slug that
 * really exists, and stores it in the form the site reads: the bare file name,
 * no folder and no width, because SmartImage turns whatever it is given into a
 * slug and looks that slug up. A dish with nothing near it keeps what it has.
 */
import {execFileSync} from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const MYSQL = process.env.MYSQL || 'C:\\xampp\\mysql\\bin\\mysql.exe';
const WRITE = process.argv.includes('--write');

/** Exactly what SmartImage.tsx does to a file name before looking it up. */
const bare = (name) =>
  String(name)
    .toLowerCase()
    .replace(/\.[^.]+$/, '')
    .replace(/&/g, 'and')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');

/** How much of a guess overlaps the real file name, 0 to 1. */
const overlap = (a, b) => {
  const A = new Set(bare(a).split('-').filter(Boolean));
  const B = new Set(bare(b).split('-').filter(Boolean));
  if (!A.size || !B.size) return 0;
  let hit = 0;
  for (const w of A) if (B.has(w)) hit++;
  return hit / Math.max(A.size, B.size);
};

const manifest = JSON.parse(
  fs.readFileSync(path.join(ROOT, 'frontend-react', 'src', 'image-manifest.json'), 'utf8')
);

/** Every slug the build can actually serve, with the extension to ask for. */
const serve = new Map();
for (const folder of ['dishes', 'food']) {
  for (const [slug, entry] of Object.entries(manifest[folder] || {})) {
    if (!serve.has(slug)) serve.set(slug, `${slug}.${entry.ext}`);
  }
}
const slugs = [...serve.keys()];

const mysql = (sql) =>
  execFileSync(MYSQL, ['-u', 'root', '-N', '-B', '-e', sql], {
    encoding: 'utf8',
    maxBuffer: 64 * 1024 * 1024,
    windowsHide: true
  });

const rows = mysql(
  "SELECT i.id, i.name, IFNULL(i.image,'') FROM hotelpardise_system.menu_items i WHERE i.active=1"
)
  .split('\n')
  .filter(Boolean)
  .map((l) => {
    const at = l.indexOf('\t');
    const mid = l.indexOf('\t', at + 1);
    return {id: l.slice(0, at), name: l.slice(at + 1, mid), image: l.slice(mid + 1).replace(/\r/g, '')};
  });

const keep = [];
const change = [];
for (const r of rows) {
  const now = bare(r.image);
  if (now && serve.has(now)) {
    if (r.image === serve.get(now)) continue; // already in the form the site reads
    change.push({id: r.id, name: r.name, from: r.image, to: serve.get(now)});
    continue;
  }

  let best = null;
  let score = 0;
  for (const slug of slugs) {
    const s = overlap(r.name, slug);
    if (s > score) {
      score = s;
      best = slug;
    }
  }
  if (best && score >= 0.6) change.push({id: r.id, name: r.name, from: r.image, to: serve.get(best)});
  else keep.push(r);
}

console.log(`menu rows:          ${rows.length}`);
console.log(`already right:      ${rows.length - change.length - keep.length}`);
console.log(`photograph to link: ${change.length}`);
console.log(`no photograph:      ${keep.length}`);
console.log('');
for (const c of change) console.log(`  ${c.id}\t${c.name}\t=> ${c.to}`);
if (keep.length) {
  console.log('\nwith nothing close enough to use:');
  for (const k of keep) console.log(`  ${k.id}\t${k.name}`);
}

if (WRITE && change.length) {
  const esc = (s) => s.replace(/\\/g, '\\\\').replace(/'/g, "''");
  const sql = change
    .map((c) => `UPDATE hotelpardise_system.menu_items SET image='${esc(c.to)}' WHERE id=${Number(c.id)};`)
    .join('\n');
  execFileSync(MYSQL, ['-u', 'root'], {input: sql, encoding: 'utf8', windowsHide: true});
  console.log(`\nupdated ${change.length} rows`);
}
