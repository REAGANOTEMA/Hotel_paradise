/**
 * Brings the database menu to the same menu the website renders.
 *
 *   node database/tools/sync-menu-db.mjs            write it
 *   node database/tools/sync-menu-db.mjs --dry      print the SQL only
 *
 * menuData.ts is the file the pages fall back on when the database has
 * nothing, and it holds every dish the kitchen filed: 251 dishes in 19
 * sections. A partial import had left the database with a fraction of that,
 * which meant the live menu replaced the full one with the fraction as soon as
 * the page loaded. This puts the two back in step, dish by dish, by reading
 * menuData.ts the same way the site does, reading the credentials the site
 * uses, and writing only what differs.
 *
 * Nothing that has been sold is thrown away. A dish already on a ticket keeps
 * its row and is switched off rather than deleted, a category still holding
 * such a dish stays, and the bar and the room service are not touched at all.
 * Run it as often as you like: a second run changes nothing.
 */
import {execFileSync} from 'node:child_process';
import fs from 'node:fs';
import path from 'node:path';
import {createRequire} from 'node:module';
import {fileURLToPath, pathToFileURL} from 'node:url';

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..', '..');
const MYSQL = process.env.MYSQL || 'C:\\xampp\\mysql\\bin\\mysql.exe';
const DRY = process.argv.includes('--dry');

/** A command that runs, whichever of the candidates this machine has. */
const run = (cmd, args, opts = {}) =>
  execFileSync(cmd, args, {encoding: 'utf8', maxBuffer: 64 * 1024 * 1024, windowsHide: true, ...opts});

function pick(cands, args, what) {
  for (const cmd of cands) {
    if (!cmd) continue;
    try { run(cmd, args); return cmd; } catch { /* try the next one */ }
  }
  throw new Error('No ' + what + ' found. Tried: ' + cands.filter(Boolean).join(', '));
}

/* ------------------------------------------------------------------ the menu */

const entry = path.join(ROOT, 'frontend-react', 'src', 'menuData.ts');
const require = createRequire(pathToFileURL(path.join(ROOT, 'frontend-react', 'package.json')));
const {build} = await import(pathToFileURL(require.resolve('esbuild')).href);
const built = await build({entryPoints: [entry], bundle: true, format: 'esm', write: false, platform: 'neutral', logLevel: 'silent'});
const {menuSections} = await import('data:text/javascript;base64,' + Buffer.from(built.outputFiles[0].text).toString('base64'));

// The sections in the order they are printed, each dish carrying the heading
// it sits under, which is the group_name the till reads.
const sections = menuSections.map((s, i) => ({
  ...s,
  sort: (i + 1) * 10,
  dishes: s.groups.flatMap(g => g.items.map(d => ({...d, group: g.name})))
}));

const dishes = sections.flatMap(s => s.dishes);
const seen = new Set();
for (const d of dishes) {
  if (!Number.isFinite(d.price)) throw new Error(d.name + ' has no price, so it cannot be sold.');
  if (seen.has(d.name)) throw new Error('Two dishes share the name ' + d.name + '.');
  seen.add(d.name);
}

/* ------------------------------------------------------- the database, read */

const php = pick([process.env.PHP, 'C:\\xampp\\php\\php.exe', 'php'], ['-v'], 'PHP');
const configPath = path.join(ROOT, 'backend-php', 'config.php').replace(/\\/g, '/');
const cfg = JSON.parse(run(php, ['-r', `echo json_encode(require '${configPath}');`]));
if (!cfg || !cfg.db) throw new Error('backend-php/config.php does not hold a db record.');
const {db} = cfg;

/**
 * A statement, or a whole script, run on the same connection the site uses.
 *
 * The script goes in on standard input rather than as an argument: a menu is
 * tens of thousands of characters, and a command line that long is refused
 * outright on Windows.
 */
const mysql = sql =>
  run(MYSQL, ['-u', db.user, '--default-character-set=utf8mb4', db.name, '-B', '-N'], {
    env: {...process.env, MYSQL_PWD: db.pass},
    input: sql
  });
const tsv = sql => mysql(sql).split(/\r?\n/).filter(Boolean).map(line => line.split('\t'));

const cats = tsv('SELECT id,outlet,name FROM menu_categories ORDER BY id').map(r => ({
  id: Number(r[0]), outlet: r[1], name: r[2]
}));
const items = tsv('SELECT id,category_id,name,active FROM menu_items ORDER BY id').map(r => ({
  id: Number(r[0]), category: Number(r[1]), name: r[2], active: r[3] === '1'
}));
const sold = new Set(tsv('SELECT DISTINCT menu_item_id FROM order_items').map(r => Number(r[0])));

const catById = new Map(cats.map(c => [c.id, c]));
/** Lower case and free of punctuation, so two spellings of one name meet. */
const norm = s => String(s).toLowerCase().replace(/[^a-z0-9]+/g, ' ').trim();
const itemsByName = new Map();
for (const it of items) {
  const key = norm(it.name);
  if (!itemsByName.has(key)) itemsByName.set(key, []);
  itemsByName.get(key).push(it);
}

/* ------------------------------------------------------------- the writes */

const q = v => (v === null || v === undefined ? 'NULL' : "'" + String(v).replace(/\\/g, '\\\\').replace(/'/g, "\\'") + "'");
const price = p => (p === null || p === undefined ? 'NULL' : q(Number(p)));

const takenCats = new Set();
const takenItems = new Set();
const sql = ['SET NAMES utf8mb4;', 'START TRANSACTION;'];
let newCats = 0;
let newItems = 0;

for (const sec of sections) {
  // A category the site already prints under this name is kept, so the
  // photographs and the orders already pointed at it follow the menu across.
  const keep = cats.find(c => norm(c.name) === norm(sec.name) && !takenCats.has(c.id));
  let cid;
  if (keep) {
    takenCats.add(keep.id);
    cid = String(keep.id);
    sql.push(
      `UPDATE menu_categories SET name=${q(sec.name)},eyebrow=${q(sec.eyebrow ?? '')},blurb=${q(sec.blurb ?? '')},` +
      `image=${q(sec.image ?? '')},sort_order=${sec.sort},outlet='restaurant' WHERE id=${keep.id};`
    );
  } else {
    // The id is parked in a variable of its own: every insert that follows
    // moves LAST_INSERT_ID() on, and the dishes of this section must still
    // land in this category rather than in the one after it.
    sql.push(
      `INSERT INTO menu_categories(hotel_id,outlet,name,eyebrow,blurb,image,sort_order) ` +
      `VALUES(1,'restaurant',${q(sec.name)},${q(sec.eyebrow ?? '')},${q(sec.blurb ?? '')},${q(sec.image ?? '')},${sec.sort});`
    );
    sql.push(`SET @cat${newCats} := LAST_INSERT_ID();`);
    cid = `@cat${newCats}`;
    newCats++;
  }

  let at = 0;
  for (const d of sec.dishes) {
    at += 10;
    // The dish is found by name anywhere in the restaurant, so a plate that
    // moved between sections keeps its history. A bar or room service dish of
    // the same name is left where it is and the restaurant gets its own row.
    const found = (itemsByName.get(norm(d.name)) || []).find(
      it => !takenItems.has(it.id) && catById.get(it.category)?.outlet === 'restaurant'
    );
    if (found) {
      takenItems.add(found.id);
      sql.push(
        `UPDATE menu_items SET category_id=${cid},name=${q(d.name)},description=${q(d.desc ?? '')},price=${price(d.price)},` +
        `image=${q(d.image || '')},group_name=${q(d.group)},sort_order=${at},active=1 WHERE id=${found.id};`
      );
    } else {
      sql.push(
        `INSERT INTO menu_items(hotel_id,category_id,name,description,price,image,group_name,sort_order,active) ` +
        `VALUES(1,${cid},${q(d.name)},${q(d.desc ?? '')},${price(d.price)},${q(d.image || '')},${q(d.group)},${at},1);`
      );
      newItems++;
    }
  }
}

// What the restaurant once sold but no longer does: switched off if a ticket
// still points at it, otherwise removed, with the category after it when that
// leaves the category holding nothing.
const stale = items.filter(it => !takenItems.has(it.id) && catById.get(it.category)?.outlet === 'restaurant');
const hold = stale.filter(it => sold.has(it.id));
const drop = stale.filter(it => !sold.has(it.id));
if (hold.length) sql.push(`UPDATE menu_items SET active=0 WHERE id IN (${hold.map(it => it.id).join(',')});`);
if (drop.length) sql.push(`DELETE FROM menu_items WHERE id IN (${drop.map(it => it.id).join(',')});`);

const stillHeld = new Set(hold.map(it => it.category));
const orphanCats = cats.filter(
  c => c.outlet === 'restaurant' && !takenCats.has(c.id) && !stillHeld.has(c.id)
);
if (orphanCats.length) sql.push(`DELETE FROM menu_categories WHERE id IN (${orphanCats.map(c => c.id).join(',')});`);

sql.push('COMMIT;');

/* ------------------------------------------------------------------ output */

const report = [
  `sections : ${sections.length} (${sections.length - newCats} kept, ${newCats} new)`,
  `dishes   : ${dishes.length} (${dishes.length - newItems} already there, ${newItems} added)`,
  `retired  : ${hold.length} kept off the menu, ${drop.length} removed`,
  `untouched: ${cats.filter(c => c.outlet !== 'restaurant').length} bar and room service categories, ` +
    `${items.filter(i => catById.get(i.category)?.outlet !== 'restaurant').length} of their dishes`
].join('\n  ');

if (DRY) {
  console.log(sql.join('\n'));
  console.error('\n' + report);
} else {
  mysql(sql.join('\n'));
  console.log(report);
  console.log('written to ' + db.name);
}
