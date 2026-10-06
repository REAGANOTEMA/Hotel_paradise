import fs from "node:fs";
const man = JSON.parse(fs.readFileSync("frontend-react/src/image-manifest.json","utf8"));
const src = fs.readFileSync("frontend-react/src/menuData.ts","utf8");
const slugify = s => s.toLowerCase().replace(/&/g,"and").replace(/[^a-z0-9]+/g,"-").replace(/^-+|-+$/g,"");
const names = [];
const re = /item\(\s*(?:'((?:[^'\\]|\\.)*)'|"((?:[^"\\]|\\.)*)")/g;
let m; while((m=re.exec(src))) names.push((m[1]??m[2]).replace(/\\'/g,"'"));
console.log("items found:", names.length);
const miss=[], hit=[];
for(const n of names){ const s=slugify(n); if(man.dishes[s]||man.food?.[s]) hit.push(n); else miss.push(n+"  => "+s); }
console.log("\nHIT:", hit.length, "MISS:", miss.length);
console.log("--- MISSING ---"); miss.forEach(x=>console.log(x));
const secs=[...src.matchAll(/key: '([a-z-]+)',\n    name:/g)].map(x=>x[1]);
console.log("\n--- SECTION BANNERS ---");
for(const k of secs){ const s="section-"+k; console.log((man.dishes[s]||man.food?.[s]?"ok  ":"MISS")+" "+s); }
