import {createRequire} from 'node:module';
import {join, resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
const root = process.cwd();
const require = createRequire(pathToFileURL(resolve(join(root, 'frontend-react', 'package.json'))));
const {build} = await import(pathToFileURL(require.resolve('esbuild')).href);
const built = await build({entryPoints:[join(root,'frontend-react','src','menuData.ts')], bundle:true, format:'esm', write:false, platform:'neutral', logLevel:'silent'});
const mod = await import('data:text/javascript;base64,' + Buffer.from(built.outputFiles[0].text).toString('base64'));
const want = ['Starters & Salads','Soups','Omelets & Snacks','Sandwiches','Burgers','Rolex Wraps & Burritos','Fisherman\'s Offer','House Specials & Platters','Chicken Dishes','Beef & Goat Main Courses','Pork Courses','Italian Pastas','Asian & Indian Curries','Accompaniments & Extras','Desserts & Bakery'];
for (const s of mod.menuSections) {
  if (!want.includes(s.name)) continue;
  console.log('\n### ' + s.name);
  for (const g of s.groups) for (const d of g.items) console.log('   ' + String(d.price).padStart(6) + '  ' + d.name);
}
console.log('\n### (not printed) ' + mod.menuSections.filter(s=>!want.includes(s.name)).map(s=>s.name+' '+s.groups.flatMap(g=>g.items).length).join(' | '));