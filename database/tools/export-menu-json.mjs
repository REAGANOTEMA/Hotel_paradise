// Exports the menu the website ships as a JSON file the PHP API can read.
//
// The public menu page falls back on frontend-react/src/menuData.ts whenever the
// database is unreachable. A hosting install that imported only part of the menu
// used to pull the page down to that fraction the moment the live data loaded,
// because there was nothing on the server that knew the whole menu. This writes
// the same 251 dishes out as backend-php/data/kitchen-menu.json so the API can
// put any missing dish back into the database by itself.
//
// Run it after any change to menuData.ts:
//
//   node database/tools/export-menu-json.mjs
//
import {mkdirSync, writeFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import {dirname, join, resolve} from 'node:path';
import {fileURLToPath, pathToFileURL} from 'node:url';

const ROOT = resolve(process.argv[2] || join(dirname(fileURLToPath(import.meta.url)), '..', '..'));
const entry = join(ROOT, 'frontend-react', 'src', 'menuData.ts');
const require = createRequire(pathToFileURL(join(ROOT, 'frontend-react', 'package.json')));
const {build} = await import(pathToFileURL(require.resolve('esbuild')).href);
const built = await build({
  entryPoints: [entry],
  bundle: true,
  format: 'esm',
  write: false,
  platform: 'neutral',
  logLevel: 'silent'
});
const mod = await import('data:text/javascript;base64,' + Buffer.from(built.outputFiles[0].text).toString('base64'));
const {menuSections, MENU_REVISION} = mod;

// The shape the API reads: sections, each holding its groups, each holding its
// dishes. The group name travels with every dish as its till heading, exactly
// as the database holds it in menu_items.group_name.
const out = {
  revision: MENU_REVISION,
  source: 'frontend-react/src/menuData.ts',
  sections: menuSections.map(s => ({
    name: s.name,
    eyebrow: s.eyebrow || '',
    blurb: s.blurb || '',
    image: s.image || '',
    groups: s.groups.map(g => ({
      name: g.name,
      items: g.items.map(i => ({
        name: i.name,
        desc: i.desc || '',
        price: i.price,
        image: i.image || '',
        group: g.name
      }))
    }))
  }))
};

const dest = join(ROOT, 'backend-php', 'data', 'kitchen-menu.json');
mkdirSync(dirname(dest), {recursive: true});
writeFileSync(dest, JSON.stringify(out, null, 2) + '\n');

const dishes = out.sections.reduce((n, s) => n + s.groups.reduce((m, g) => m + g.items.length, 0), 0);
console.log(`wrote ${dishes} dishes in ${out.sections.length} sections to ${dest}`);
