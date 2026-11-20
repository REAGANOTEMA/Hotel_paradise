// One-off patch: gives every fallback dish that has a photograph on disk an
// explicit image, and a banner to each of the nineteen sections. Safe to run
// more than once - it only ever fills a slot that is still blank.
import fs from 'node:fs';

const FILE = 'frontend-react/src/menuData.ts';

const banners = {
  starters: 'caesar-salad.jpg',
  soups: 'mushroom-soup.jpg',
  omelets: 'spanish-omelet.jpg',
  sandwiches: 'classic-blt-sandwich.jpg',
  burgers: 'king-burger.jpg',
  wraps: 'beef-rolex.jpg',
  seafood: 'grilled-king-fish.jpg',
  house: 'mixed-grill-platter.jpg',
  chicken: 'bbq-chicken-drumstick.jpg',
  beef: 'king-steak.jpg',
  pork: 'honey-mustard-glazed-pork-ribs.jpg',
  pizza: 'section-pizza.jpg',
  pasta: 'pasta-a-la-carbonara.jpg',
  asian: 'chicken-coconut-curry.jpg',
  chinese: 'sweet-and-sour-chicken.jpg',
  sizzlers: 'sizzler-beef-plate.jpg',
  'rice-noodles': 'chicken-fried-rice.jpg',
  accompaniments: 'masala-chips.jpg',
  desserts: 'chocolate-cake-slice.jpg'
};

const photos = {
  'Catch of the Day (Nile Perch)': 'nile-parch-catch-for-a-day.jpg',
  'Vegetable Spring Roll (1pc)': 'vegetable-spring-rolls.jpg',
  'Chicken Spring Roll (1pc)': 'chicken-spring-rolls.webp',
  'Pork Spring Roll (1pc)': 'pork-spring-roll.jpg',
  'Vegetable Wanton': 'vegetable-wonton.jpg',
  'Special Chicken Wings (1pc)': 'special-chicken-wings.webp',
  'Fried Wanton (Chicken or Beef)': 'fried-wonton-chicken.jpg',
  'Salty Chicken / Beef': 'salty-chicken.webp',
  'Fried Egg Rolled Chicken (Pair)': 'fried-eggs-rolled-chicken.jpg',
  'Crispy Chicken Legs': 'cripcy-chicken-legs.jpg',
  'Sauté Chicken Sichuan Style': 'saute-chicken-sichuan-style.jpg',
  'Chinese Cabbage Sichuan Style (Hot)': 'chinese-cabbage-sichuan-style.jpg',
  'Mixed Vegetables (Onions, Cabbage, Carrots, Pepper, Mushroom)':
    'mixed-vegetable-onions-cabbage-carrots-pepper-mushroom.jpg',
  'Shredded Beef with Onions': 'shredded-beef-with-vegetables.jpg',
  'Sauté Pork Sichuan Style (Hot)': 'saute-pork-sichuan-style.webp',
  'Special Mixed Vegetables & Sprouts': 'special-mixed-vegetables-and-sprout.jpg',
  'Fried Mixed Chicken, Beef & Goat Meat': 'fried-mixed-chicken-beef-and-goat-meet.jpg',
  'Fried Shredded Chicken with Bamboo Shoots': 'fried-shredded-chicken-with-baboo-shoots.jpg',
  'Sliced Pork with Mushroom and Bamboo Shoots': 'sliced-pork-and-mushroom-with-bamboo-shoots.jpg',
  'Fried Prawns with Cashew Nuts': 'fried-prawns-cashew-nuts.jpg',
  'Sauté Prawns with Black Bean Sauce': 'saute-prawns-with-black-bean-sauce.webp',
  'Fried Prawns with Chinese Black Beans': 'fried-prawns-with-chinese-black-bean.jpg',
  'Sizzler Shrimps / Prawns Plate': 'sizzler-shrimp-or-prawns-plate.jpg',
  'Egg Fried Rice': 'eggs-fried-rice.webp',
  'Extra Fried Egg': 'extra-fried-eggs.jpg',
  Croissant: 'croissants.jpg',
  'Beef / Chicken Pie': 'beef-or-chicken-pie.jpg',
  'Ice Cream (3 Scoops)': 'ice-cream-3-scoop.jpg',
  'Tropical Fruit Platter': 'tropical-fruits-platter.jpg',
  'Black Forest Cake (pc)': 'black-forest-cake.jpg'
};

const source = fs.readFileSync(FILE, 'utf8');
const eol = source.includes('\r\n') ? '\r\n' : '\n';
const lines = source.split(/\r?\n/);

let bannersFilled = 0;
let pendingSection = '';
for (let n = 0; n < lines.length; n++) {
  const key = lines[n].match(/^\s+key: '([^']+)',$/);
  if (key) pendingSection = key[1];
  if (pendingSection && /^\s+image: '',$/.test(lines[n]) && banners[pendingSection]) {
    lines[n] = lines[n].replace("''", "'" + banners[pendingSection] + "'");
    bannersFilled++;
    pendingSection = '';
  }
}

let photosFilled = 0;
const missing = [];
for (const [name, file] of Object.entries(photos)) {
  const hit = lines.findIndex(l => l.includes(`item('${name}'`) || l.includes(`item("${name}"`));
  if (hit < 0) {
    missing.push(name);
    continue;
  }
  const line = lines[hit];
  if (line.includes(`'${file}'`)) continue;
  const close = line.lastIndexOf(')');
  if (close < 0) continue;
  lines[hit] = line.slice(0, close) + `, '${file}'` + line.slice(close);
  photosFilled++;
}

fs.writeFileSync(FILE, lines.join(eol));
console.log(`section banners filled: ${bannersFilled}/${Object.keys(banners).length}`);
console.log(`dish photographs filled: ${photosFilled}/${Object.keys(photos).length}`);
if (missing.length) console.log('dishes not found in the file:\n  ' + missing.join('\n  '));
