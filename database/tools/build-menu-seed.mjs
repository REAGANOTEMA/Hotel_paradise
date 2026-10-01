// Builds database/07_FULL_MENU_SEED.sql straight from menuData.ts, so the
// database holds exactly the menu the website shows. Run after a schema install.
import {mkdirSync, writeFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import {join} from 'node:path';
import {pathToFileURL} from 'node:url';

const root = process.argv[2] || process.cwd();
const src = join(root, 'frontend-react', 'src', 'menuData.ts');
const outFile = join(root, 'database', '07_FULL_MENU_SEED.sql');
const HOTEL_ID = 1;
const OUTLET = 'restaurant';

// esbuild ships with Vite, so it is resolved from the frontend rather than
// added as a dependency of its own. createRequire wants a file URL or an
// absolute path, and the root may well have been passed in as ".".
const require = createRequire(pathToFileURL(join(root, 'frontend-react', 'package.json')));
const {build} = await import(pathToFileURL(require.resolve('esbuild')).href);
const built = await build({
  entryPoints: [src],
  bundle: true,
  format: 'esm',
  write: false,
  platform: 'neutral',
  logLevel: 'silent',
});
const code = built.outputFiles[0].text;
const mod = await import('data:text/javascript;base64,' + Buffer.from(code).toString('base64'));
const {menuSections, tidySections, totalDishes} = mod;

const sections = tidySections(menuSections);

const q = v => (v === null || v === undefined ? 'NULL' : `'${String(v).replace(/\\/g, '\\\\').replace(/'/g, "''")}'`);
const n = v => (v === null || v === undefined ? 'NULL' : String(v));

// The whole safety of this file rests on these two keys being unique, because
// that is how a dish is recognised on reload. A duplicate name would make the
// reload update the first row and then fail loudly on the second, so it is
// checked here rather than discovered in the middle of an install.
const fail = msg => {
  throw new Error(`build-menu-seed: ${msg}`);
};
const repeated = list => [...new Set(list.filter((v, i) => list.indexOf(v) !== i))];
const dupCategories = repeated(sections.map(s => s.name));
if (dupCategories.length) fail(`two sections share the name ${dupCategories.join(', ')}`);

const dishes = sections.flatMap(s =>
  s.groups.flatMap(g => g.items.map(d => ({...d, section: s.name})))
);
const dupDishes = repeated(dishes.map(d => d.name));
if (dupDishes.length) fail(`two dishes share the name ${dupDishes.join(', ')}`);
if (dishes.length !== totalDishes(sections)) {
  fail(`walked ${dishes.length} dishes but the menu reports ${totalDishes(sections)}`);
}

// A section with no dishes would still be published on the website and would
// open to an empty list.
for (const s of sections) {
  if (!s.groups.flatMap(g => g.items).length) fail(`section ${s.name} has no dishes`);
}

const statements = [];

sections.forEach((s, i) => {
  statements.push(
    `-- ${s.name}\n` +
    `INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)\n` +
    `VALUES (${HOTEL_ID},${q(OUTLET)},${q(s.name)},${q(s.eyebrow || null)},${q(s.blurb || null)},${q(s.image || null)},${i + 1},1)\n` +
    `ON DUPLICATE KEY UPDATE\n` +
    `  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),\n` +
    `  sort_order=VALUES(sort_order), published=1;`
  );

  const rows = s.groups
    .flatMap(g => g.items)
    .map((d, j) =>
      `  (${HOTEL_ID},(SELECT id FROM menu_categories WHERE hotel_id=${HOTEL_ID} AND outlet=${q(OUTLET)} AND name=${q(s.name)}),` +
      `${q(d.name)},${q(d.group || null)},${q(d.desc || null)},${n(d.price)},${q(d.image || null)},${j + 1},1,1)`
    )
    .join(',\n');

  statements.push(
    `INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)\n` +
    `VALUES\n${rows}\n` +
    `ON DUPLICATE KEY UPDATE\n` +
    `  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),\n` +
    `  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;`
  );
});

// A dish taken off the website menu is unpublished, never deactivated and never
// deleted. Deactivating would tell the till the kitchen has stopped selling it,
// which is the hotel's decision and not this file's; deleting would break the
// foreign key from every past order. So the dish stays exactly as it is in the
// hotel system and simply stops being advertised.
const names = dishes.map(d => q(d.name)).join(',');
statements.push(
  `-- Restaurant rows this file used to publish and no longer does. Only the\n` +
  `-- restaurant outlet is touched: the bar and room service menus are the\n` +
  `-- hotel's own and are left alone.\n` +
  `UPDATE menu_items SET published = 0\n` +
  `WHERE hotel_id = ${HOTEL_ID} AND published = 1 AND name NOT IN (${names})\n` +
  `  AND category_id IN (SELECT id FROM menu_categories WHERE hotel_id=${HOTEL_ID} AND outlet=${q(OUTLET)});`
);

const catNames = sections.map(s => q(s.name)).join(',');
statements.push(
  `UPDATE menu_categories SET published = 0\n` +
  `WHERE hotel_id = ${HOTEL_ID} AND outlet=${q(OUTLET)} AND published = 1 AND name NOT IN (${catNames});`
);

const sql = `-- HOTEL PARADISE ON THE NILE - COMPLETE MENU SEED
-- Generated from frontend-react/src/menuData.ts by database/tools/build-menu-seed.mjs
-- Do not hand edit. Re-run the generator instead.
--
-- ${sections.length} sections, ${dishes.length} dishes for hotel ${HOTEL_ID}, every one of them carrying a rate
-- in Ugandan shillings. A dish with no rate is stored as NULL, which is what
-- the website reads as "Priced on request"; there are ${dishes.filter(d => d.price === null).length} of those.
--
-- Safe to run on a hotel that is already trading. Dishes are matched on their
-- name, so a reload updates the existing rows in place and keeps the ids that
-- past orders already reference. Nothing is deleted and nothing is deactivated:
-- this file only sets the published flag, which is the website's business
-- alone. The till's menu, the bar and room service are left exactly as they are.
--
-- Run it inside a transaction if you would rather see the whole result or none
-- of it.
--
-- Sauté and Sautéed carry an accent, and the dishes are matched on their name.
-- The line below tells the client to read this file as UTF-8; without it a
-- client that defaults to latin1 will store a mangled name, fail to match the
-- existing row on a reload, and quietly publish the same dish twice.

SET NAMES utf8mb4;

USE \`hotelpardise_system\`;

${statements.join('\n\n')}

-- What the website will now publish. These are the numbers that matter: a
-- section the guest can open but not order from, or a dish published under no
-- section at all, is a broken menu and shows up here.
SELECT COUNT(*) AS published_sections
  FROM menu_categories c
 WHERE c.hotel_id = ${HOTEL_ID} AND c.published = 1
   AND EXISTS (SELECT 1 FROM menu_items i WHERE i.category_id = c.id AND i.published = 1);

SELECT COUNT(*) AS published_dishes,
       SUM(price IS NULL) AS priced_on_request,
       COUNT(DISTINCT category_id) AS sections_covered
  FROM menu_items WHERE hotel_id = ${HOTEL_ID} AND published = 1;

-- Must both be zero. A published dish in no published section cannot be ordered.
SELECT COUNT(*) AS published_dish_with_no_section
  FROM menu_items i
  LEFT JOIN menu_categories c ON c.id = i.category_id
 WHERE i.hotel_id = ${HOTEL_ID} AND i.published = 1
   AND (c.id IS NULL OR c.published = 0);

-- Must be zero. A published section with nothing in it opens to a blank list.
SELECT COUNT(*) AS published_section_with_no_dish
  FROM menu_categories c
 WHERE c.hotel_id = ${HOTEL_ID} AND c.published = 1
   AND NOT EXISTS (SELECT 1 FROM menu_items i WHERE i.category_id = c.id AND i.published = 1);

-- The till's view is untouched by this file. If this changes, the seed has gone
-- outside its own business and taken the hotel's menu with it.
SELECT outlet, SUM(i.active = 1) AS sellable, SUM(i.published = 1) AS on_website
  FROM menu_items i JOIN menu_categories c ON c.id = i.category_id
 WHERE i.hotel_id = ${HOTEL_ID} GROUP BY outlet;
`;

mkdirSync(join(root, 'database'), {recursive: true});
writeFileSync(outFile, sql, 'utf8');
console.log(`wrote ${outFile}`);
console.log(`  sections ${sections.length}, dishes ${dishes.length} (menu reports ${totalDishes(sections)})`);
