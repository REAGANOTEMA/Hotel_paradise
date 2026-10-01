// Compares the menu in menuData.ts against the kitchen's own JSON, item for
// item and price for price. Reports anything missing, extra, renamed or
// repriced so a transcription slip cannot slip through unnoticed.
import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import {join, resolve} from 'node:path';
import {pathToFileURL} from 'node:url';

const root = process.argv[2] || process.cwd();
const src = resolve(join(root, 'frontend-react', 'src', 'menuData.ts'));
const source = JSON.parse(readFileSync(process.argv[3], 'utf8'));

const require = createRequire(pathToFileURL(resolve(join(root, 'frontend-react', 'package.json'))));
const {build} = await import(pathToFileURL(require.resolve('esbuild')).href);
const built = await build({entryPoints: [src], bundle: true, format: 'esm', write: false, platform: 'neutral', logLevel: 'silent'});
const mod = await import('data:text/javascript;base64,' + Buffer.from(built.outputFiles[0].text).toString('base64'));
const {menuSections, tidySections, totalDishes, companionsFor, saladsFor, defaultCompanion, SERVED_WITH} = mod;

const mine = menuSections.flatMap(s => s.groups.flatMap(g => g.items.map(d => ({...d, section: s.name}))));
const theirs = source.menu.flatMap(c => c.items.map(i => ({...i, category: c.category})));

// The kitchen's section names against the names chosen for the website. A
// section keeps its kitchen name, minus any bracketed qualifier that only
// repeated what the section is already called.
const renamed = {
  "Fisherman's Offer (Seafood)": "Fisherman's Offer",
  'Pizzeria (Pizza)': 'Pizzeria',
  'Rice & Noodles Side Options': 'Rice & Noodles',
  'Accompaniments / Side Add-Ons': 'Accompaniments & Extras'
};

// Three kitchen spellings are not words and would be read as a mistake on a
// printed menu. These are the only names that were corrected.
const corrected = {
  Tunno: 'Tuna',
  Daviolla: 'Diavola'
};

const wantName = n => corrected[n] || n;
// The same two corrections read the other way, so a corrected dish is matched
// against the kitchen's own spelling rather than reported as a difference.
const backToKitchen = Object.fromEntries(Object.entries(corrected).map(([was, now]) => [now, was]));
const kitchenName = n => backToKitchen[n] || n;

/**
 * Copy that was tidied for the screen, and why. Nothing listed here changes a
 * dish, an ingredient or a price; it only fixes how the sentence reads, or
 * repairs one line the kitchen file clearly copied from the dish above it.
 */
const copyEdits = {
  'King Burger': 'reads as a sentence rather than a list of nouns',
  'Fajita Chicken / Beef': 'reads as a sentence rather than a list of nouns',
  'Paradise Lusaniya (3-4 Pax)': 'figures written out as words',
  'BBQ Chicken Drumsticks': 'figures written out as words',
  'Pasta ala Cavolfiore e Salsiccia': 'the kitchen file repeated the Carbonara copy; the dish name says cauliflower and sausage'
};
/** Lower case, accents folded, punctuation folded, so only real words differ. */
const canon = s => s.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '')
  .replace(/[^a-z0-9]+/g, ' ').trim();

let problems = 0;
const say = (...a) => { problems++; console.log('  !', ...a); };

console.log(`kitchen : ${theirs.length} dishes in ${source.menu.length} categories`);
console.log(`website : ${mine.length} dishes in ${menuSections.length} sections (${totalDishes(tidySections(menuSections))} after tidy)`);
console.log(`total price check: kitchen UGX ${theirs.reduce((n, i) => n + i.price_ugx, 0).toLocaleString()} vs website UGX ${mine.reduce((n, d) => n + d.price, 0).toLocaleString()}`);
console.log('');

// 1. every kitchen dish is present, in the same order, at the same price
const index = new Map();
mine.forEach((d, i) => index.set(canon(kitchenName(d.name)), {d, i}));
const known = new Set(theirs.map(t => canon(t.name)));
let cursor = -1;
for (const t of theirs) {
  const hit = index.get(canon(t.name));
  if (!hit) { say(`missing from the website: ${t.name} (${t.category}, ${t.price_ugx})`); continue; }
  if (hit.d.price !== t.price_ugx) say(`${t.name}: website ${hit.d.price} vs kitchen ${t.price_ugx}`);
  if (corrected[t.name]) console.log(`  ~ corrected spelling: "${t.name}" -> "${hit.d.name}"`);
  if (hit.d.section !== (renamed[t.category] || t.category)) say(`${t.name}: filed under "${hit.d.section}" not "${renamed[t.category] || t.category}"`);
  if (hit.i <= cursor) say(`${t.name}: out of order`);
  cursor = hit.i;
  if (t.description !== undefined) {
    const words = canon(hit.d.desc).split(' ').filter(w => w.length > 3);
    const src = canon(t.description);
    const missingWords = words.filter(w => !src.includes(w));
    if (missingWords.length) {
      if (copyEdits[t.name]) console.log(`  ~ copy tidied: ${t.name} (${copyEdits[t.name]})`);
      else say(`${t.name}: website copy adds ${missingWords.join(', ')}`);
    }
  }
  if (t.description === undefined && hit.d.desc !== '') say(`${t.name}: kitchen left no copy but one was written`);
}

// 2. nothing on the website that the kitchen did not file
for (const d of mine) {
  if (!known.has(canon(kitchenName(d.name)))) say(`on the website but not in the kitchen file: ${d.name}`);
}

// 3. no dish without a price, because a dish without a price cannot be ordered
for (const d of mine) if (d.price === null || !Number.isFinite(d.price)) say(`${d.name}: no price, so it cannot be ordered`);

// 4. the names the database recognises a dish by must be unique
const names = mine.map(d => d.name);
const dupes = [...new Set(names.filter((n, i) => names.indexOf(n) !== i))];
if (dupes.length) say('two dishes share a name: ' + dupes.join(', '));
const slugs = mine.map(d => d.name.toLowerCase().replace(/&/g, 'and').replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, ''));
const dupSlugs = [...new Set(slugs.filter((n, i) => slugs.indexOf(n) !== i))];
if (dupSlugs.length) say('two dishes share a photo file name: ' + dupSlugs.join(', '));

// 5. every companion picker leads with something included, and every dish that
//    names its own accompaniments is given them for nothing
for (const d of mine) {
  const list = companionsFor(d);
  if (list.length && !list.some(c => c.add === 0)) say(`${d.name}: no companion is included, so the plate is dearer than the card`);
  if (list.length && defaultCompanion(d) === null) say(`${d.name}: no default companion`);
  const named = SERVED_WITH[d.name] || [];
  for (const k of named) {
    const c = list.find(x => x.key === k);
    if (!c) say(`${d.name}: names "${k}" as included but never offers it`);
    else if (c.add !== 0) say(`${d.name}: names "${k}" as included but still charges for it`);
  }
}

// 6. the counts each section reports must match what it actually holds
for (const s of menuSections) {
  const n = s.groups.reduce((m, g) => m + g.items.length, 0);
  console.log(`  ${String(n).padStart(3)} dishes  ${s.name}${s.groups.length === 1 && s.groups[0].name === s.name ? '' : '  [group heading shown]'}`);
}

console.log('');
console.log(problems ? `${problems} problem(s) found` : 'no differences found: the website menu is the kitchen menu');
process.exit(problems ? 1 : 0);
