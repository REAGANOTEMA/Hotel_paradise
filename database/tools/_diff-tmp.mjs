import {readFileSync} from 'node:fs';
import {createRequire} from 'node:module';
import {join, resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
const root = process.cwd();
const require = createRequire(pathToFileURL(resolve(join(root, 'frontend-react', 'package.json'))));
const {build} = await import(pathToFileURL(require.resolve('esbuild')).href);
const built = await build({entryPoints:[join(root,'frontend-react','src','menuData.ts')], bundle:true, format:'esm', write:false, platform:'neutral', logLevel:'silent'});
const mod = await import('data:text/javascript;base64,' + Buffer.from(built.outputFiles[0].text).toString('base64'));
const live = mod.menuSections.flatMap(s => s.groups.flatMap(g => g.items.map(d => ({...d, _sec: s.name}))));
const filed = JSON.parse(readFileSync(join(root,'database','tools','kitchen-menu-additions.json'),'utf8')).items;
const norm = s => String(s).normalize('NFD').replace(/[\u0300-\u036f]/g,'').toLowerCase().replace(/&/g,'and').replace(/[^a-z0-9]+/g,'');
const byNorm = new Map();
for (const d of live) { const k = norm(d.name); if(!byNorm.has(k)) byNorm.set(k,[]); byNorm.get(k).push(d); }
const miss=[], priceDiff=[], secNote=[], dupes=[], same=[];
for (const f of filed) {
  const hit = byNorm.get(norm(f.item));
  if (!hit) { miss.push(f); continue; }
  if (hit.length > 1) dupes.push(f.item + ' -> matches ' + hit.length);
  const d = hit[0];
  if (d.price !== f.price) priceDiff.push({item:f.item, filed:f.price, live:d.price, sec:d._sec});
  else same.push(f.item);
}
console.log('ON SITE NOW : ' + live.length + ' dishes in ' + mod.menuSections.length + ' sections');
console.log('NEW FILING  : ' + filed.length + ' dishes in ' + new Set(filed.map(f=>f.category)).size + ' categories');
console.log('');
console.log('=== MATCHES THE SITE EXACTLY ON PRICE: ' + same.length + ' ===');
console.log('');
console.log('=== NOT ON THE SITE AT ALL: ' + miss.length + ' ===');
for (const m of miss) console.log('  + ' + m.category.padEnd(20) + ' ' + String(m.price).padStart(6) + '  ' + m.item);
console.log('');
console.log('=== PRICE MISMATCH: ' + priceDiff.length + '  (filed is authoritative) ===');
for (const p of priceDiff.sort((a,b)=>(b.live-b.filed)-(a.live-a.filed))) {
  const delta = p.live - p.filed;
  console.log('  ! ' + p.item.padEnd(40) + ' filed ' + String(p.filed).padStart(6) + '  site ' + String(p.live).padStart(6) + '  ' + (delta>0?'site +':'') + delta);
}
if (dupes.length) { console.log(''); console.log('=== AMBIGUOUS: ' + dupes.length + ' ==='); dupes.forEach(x=>console.log('  ? '+x)); }