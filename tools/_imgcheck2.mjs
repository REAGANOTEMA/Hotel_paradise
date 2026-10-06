import fs from "node:fs";
const man = JSON.parse(fs.readFileSync("frontend-react/src/image-manifest.json","utf8"));
console.log("dishes keys:", Object.keys(man.dishes).length, "food keys:", Object.keys(man.food).length, "rooms:", Object.keys(man.rooms).length, "gallery:", Object.keys(man.gallery).length, "hero:", man.hero.length);
for (const k of ["fruit-salad","banana-split","croissants","profiteroles","lemon-tart","chocolate-mousse","white-forest-cake","mango-tart","classic-carrot-cake","chocolate-fudge-slice","egg-fried-rice","vegetable-spring-roll","special-chicken-wings","crispy-chicken-legs"]) {
  console.log(k, "| dishes:", !!man.dishes[k], "| food:", !!man.food[k]);
}
const src = fs.readFileSync("frontend-react/src/menuData.ts","utf8");
const secs=[...src.matchAll(/key: '([a-z-]+)',\r?\n\s+name:/g)].map(x=>x[1]);
console.log("sections:", secs.length, secs.join(","));
for(const k of secs){ const s="section-"+k; console.log((man.dishes[s]||man.food?.[s]?"ok  ":"MISS")+" "+s); }
