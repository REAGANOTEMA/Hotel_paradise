// Builds database/07_FULL_MENU_SEED.sql straight from menuData.ts, so the
// database holds exactly the menu the website shows. Run after a schema install.
import {mkdirSync, writeFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import {join} from 'node:path';
import {pathToFileURL} from 'node:url';

const root = process.argv[2] || process.cwd();
const src = join(root, 'frontend-react', 'src', 'menuData.ts');
const outFile = join(root, 'database', '07_FULL_MENU_SEED.sql');

// esbuild ships with Vite, so it is resolved from the frontend rather than
// added as a dependency of its own
const require = createRequire(join(root, 'frontend-react', 'package.json'));
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

let catId = 0;
let itemId = 0;
const catRows = [];
const itemRows = [];

for (const s of sections) {
  catId++;
  const dishes = s.groups.flatMap(g => g.items);
  catRows.push(`(${catId},'restaurant',${q(s.name)},${q(s.eyebrow || '')},${q(s.blurb || '')},${q(s.image || '')},${catId})`);
  for (const d of dishes) {
    itemId++;
    itemRows.push(
      `(${itemId},${catId},${q(d.name)},${q(d.group || '')},${q(d.desc || '')},${n(d.price)},${q(d.image || '')},${itemId})`
    );
  }
}

const sql = `-- HOTEL PARADISE ON THE NILE - COMPLETE MENU SEED
-- Generated from frontend-react/src/menuData.ts by database/tools/build-menu-seed.mjs
-- Do not hand edit. Re-run the generator instead.
--
-- ${sections.length} sections, ${itemId} dishes. A dish priced on request is stored
-- as NULL, which is what the website reads as "Priced on request".
--
-- Safe to run more than once: the dishes are matched on their name, so running
-- it again refreshes the menu instead of duplicating it.

USE \`hotelpardise_system\`;

DELETE FROM menu_items WHERE hotel_id = 1;
DELETE FROM menu_categories WHERE hotel_id = 1;

INSERT INTO menu_categories (id,hotel_id,outlet,name,eyebrow,blurb,image,sort_order) VALUES
${catRows.join(',\n')};

INSERT INTO menu_items (id,hotel_id,category_id,name,group_name,description,price,image,sort_order,active) VALUES
${itemRows.join(',\n')};

SELECT COUNT(*) AS sections FROM menu_categories WHERE hotel_id = 1;
SELECT COUNT(*) AS dishes, SUM(price IS NULL) AS priced_on_request FROM menu_items WHERE hotel_id = 1 AND active = 1;
`;

mkdirSync(join(root, 'database'), {recursive: true});
writeFileSync(outFile, sql, 'utf8');
console.log(`wrote ${outFile}`);
console.log(`  sections ${sections.length}, dishes ${itemId} (expected ${totalDishes(sections)})`);
