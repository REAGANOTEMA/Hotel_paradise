/**
 * A LA CARTE RESTAURANT MENU
 * Hotel Paradise on the Nile Ltd, Plot 12, 19 & 25 Kiira Lane, Jinja, Uganda.
 * UNBS Certified, US 130:2017.
 *
 * Nineteen sections, two hundred and twenty five dishes, exactly as the
 * kitchen filed them. Where the kitchen left a dish without copy the copy is
 * left empty here too, because inventing a description is worse than an
 * honest blank space.
 *
 * This is the fallback dataset used when the kitchen database is unreachable.
 * The database keeps its own copy of the menu and it is not generated from
 * this file any more; database/tools/check-menu.mjs compares the two and
 * reports anything that has drifted.
 *
 * PHOTOS
 * Drop a picture into /images/dishes/ named after the item, for example
 * mushroom-soup.jpg, and the framed photo slot picks it up automatically.
 * Section banners work the same way: section-starters.jpg.
 * Anything with no file shows an elegant reserved plate, never a broken image.
 */

export type MenuItem = {
  id: number;
  name: string;
  desc: string;
  /** Ugandan shillings. null means the rate is still being confirmed. */
  price: number | null;
  /** Overrides the auto generated file name, for example 'kalamari-01.jpg'. */
  image: string;
  group: string;
};

export type MenuGroup = {
  name: string;
  items: MenuItem[];
  /**
   * The heading to print above the group. tidySections sets this to an empty
   * string for a group whose name only repeats the section above it, so the
   * dishes stay on the page and the second copy of the word does not.
   */
  title?: string;
};

export type MenuSection = {
  key: string;
  name: string;
  eyebrow: string;
  blurb: string;
  image: string;
  groups: MenuGroup[];
};

let seq = 0;

const item = (name: string, desc: string, price: number | null, group: string, image = ''): MenuItem => ({
  id: ++seq,
  name,
  desc,
  price,
  image,
  group
});

export const MENU_REVISION = 'A la carte restaurant menu';

/* ------------------------------------------------------------------
   COMPANIONS AND SALADS

   The kitchen states the accompaniment once for the whole section rather
   than repeating it on every dish: omelets come with chips, sandwiches
   come with chips or salad, burgers may be served with chips and salad,
   pasta is offered in five shapes, and non veg curries come with a
   choice of one or two accompaniments. So the rule is held per section
   below, keyed on the section name, and the dish detail view offers
   exactly what its own section allows.

   One companion comes with the dish, which is the house standard, and is
   marked "included". Every list below therefore leads with a companion
   that costs nothing, so the plate a guest opens is never quietly dearer
   than the price printed on the card. Everything else is an upgrade and
   carries a small add on price. To make every accompaniment free, set
   ADD_ONS_INCLUDED to true below: the pickers stay, the totals do not
   move.
   ------------------------------------------------------------------ */

/** Set to true to price every companion and salad at no extra charge. */
export const ADD_ONS_INCLUDED = false;

export type Choice = {
  key: string;
  name: string;
  /** Ugandan shillings added to the dish price. 0 means it comes with it. */
  add: number;
  /** Shown under the name to explain the choice. */
  note: string;
};

export const COMPANIONS: Choice[] = [
  {key: 'chips', name: 'Chips', add: 0, note: 'House standard, included'},
  {key: 'rice', name: 'Steamed rice', add: 0, note: 'House standard, included'},
  {key: 'roll', name: 'Bread roll', add: 0, note: 'Comes with the dish'},
  {key: 'none', name: 'As it comes', add: 0, note: 'Nothing added, no charge'},
  {key: 'fries', name: 'French fries', add: 3000, note: 'Thick cut, salted'},
  {key: 'wedges', name: 'Potato wedges', add: 4000, note: 'Rosemary and garlic'},
  {key: 'pilau', name: 'Brown pilau rice', add: 4000, note: 'Cooked in spiced stock'},
  {key: 'matoke', name: 'Matoke', add: 4000, note: 'Simmered in groundnut'},
  {key: 'chapatti', name: 'Chapatti', add: 3000, note: 'Rolled by hand'},
  {key: 'ugali', name: 'Ugali', add: 3000, note: 'Cassava and maize flour'},
  {key: 'cassava', name: 'Cassava', add: 3000, note: 'Steamed, with tomato sauce'},
  {key: 'garlic', name: 'Garlic bread', add: 5000, note: 'Baked with parsley butter'},
  {key: 'naan', name: 'Naan', add: 5000, note: 'Tandoor baked'}
];

export const SALADS: Choice[] = [
  {key: 'coleslaw', name: 'Coleslaw', add: 5000, note: 'Cabbage, carrot and cream'},
  {key: 'green', name: 'Green salad', add: 5000, note: 'Lettuce, cucumber and tomato'},
  {key: 'cucumber', name: 'Cucumber and tomato', add: 5000, note: 'Onion, oregano and olive oil'},
  {key: 'caesar', name: 'Caesar salad', add: 9000, note: 'Parmesan, croutons, egg'},
  {key: 'russian', name: 'Russian salad', add: 8000, note: 'Potato, egg, carrot, mayonnaise'},
  {key: 'veggie', name: 'Grilled Veggies Salad', add: 18000, note: 'Pepper, zucchini, cashew flakes'},
  {key: 'tuna', name: 'Tuna Salad', add: 20000, note: 'Tuna, avocado on lettuce'}
];

const choice = (list: Choice[], keys: string[]): Choice[] =>
  keys.map(k => list.find(c => c.key === k)).filter((c): c is Choice => Boolean(c));

/** An empty picker, used for the dishes that are served as they are. */
export const NO_COMPANIONS: Choice[] = [];
export const NO_SALADS: Choice[] = [];

/** A dish with no photograph still needs a dish, not a table of starches. */
const servedPlain = /\b(served plain|as it comes|nothing added)\b/i;

/**
 * The accompaniments each section is allowed, keyed on the section name.
 * A section that is not named here is served as it comes, so the picker is
 * left off the dish altogether rather than filled with guesses.
 */
const CATEGORY_COMPANIONS: Record<string, string[]> = {
  Soups: ['roll', 'garlic'],
  'Omelets & Snacks': ['chips', 'fries', 'wedges', 'matoke'],
  Sandwiches: ['chips', 'fries', 'wedges', 'matoke'],
  Burgers: ['chips', 'fries', 'wedges', 'matoke'],
  'Rolex Wraps & Burritos': ['none', 'chips', 'fries', 'wedges'],
  "Fisherman's Offer": ['chips', 'rice', 'fries', 'wedges', 'matoke', 'pilau'],
  'House Specials & Platters': ['chips', 'rice', 'fries', 'wedges', 'pilau', 'matoke'],
  'Chicken Dishes': ['chips', 'rice', 'fries', 'wedges', 'pilau', 'matoke', 'chapatti'],
  'Beef & Goat Main Courses': ['chips', 'rice', 'fries', 'wedges', 'pilau', 'matoke', 'chapatti'],
  'Pork Courses': ['chips', 'rice', 'fries', 'wedges', 'pilau', 'matoke', 'chapatti'],
  Pizzeria: ['none', 'garlic'],
  'Italian Pastas': ['none', 'garlic', 'roll'],
  'Asian & Indian Curries': ['rice', 'naan', 'chapatti', 'ugali', 'cassava', 'matoke'],
  'Chinese Corner': ['none', 'rice', 'chips', 'fries', 'wedges'],
  'Sizzler Hot Plates': ['rice', 'chips', 'fries', 'wedges']
};

/**
 * The sections a salad may be added to. A salad is a plate in its own right,
 * so it is offered with anything that arrives on a starch or a plate, and
 * never with a soup, with a rice dish, with the extras themselves, nor with
 * the salads in the first section, which are already salads.
 */
const CATEGORY_SALADS: string[] = [
  'Omelets & Snacks',
  'Sandwiches',
  'Burgers',
  'Rolex Wraps & Burritos',
  "Fisherman's Offer",
  'House Specials & Platters',
  'Chicken Dishes',
  'Beef & Goat Main Courses',
  'Pork Courses',
  'Pizzeria',
  'Italian Pastas',
  'Asian & Indian Curries',
  'Chinese Corner',
  'Sizzler Hot Plates'
];

/**
 * A few dishes name more than one accompaniment in their own copy, and those
 * are the ones that come with the plate. They are held at the card price here
 * and in backend-php/app/menu_extras.php, which must be kept in step.
 */
export const SERVED_WITH: Record<string, string[]> = {
  'Paradise Lusaniya': ['pilau', 'matoke', 'wedges'],
  'Liver Princess': ['rice', 'chips', 'matoke'],
  'Mixed Grill Platter': ['chips', 'rice', 'fries', 'wedges']
};

/** The accompaniments a dish is given with, whether by name or by its section. */
function includedKeysFor(dish: MenuItem): string[] {
  const byName = SERVED_WITH[dish.name] || [];
  const byCopy = /served with rice, chips, or matooke/i.test(dish.desc || '') ? ['rice', 'chips', 'matoke'] : [];
  return [...new Set([...byName, ...byCopy])];
}

/**
 * Applies a dish's own included list to the choices it may be ordered with,
 * adding any accompaniment the dish names in its own copy but its section
 * did not offer, so the guest is never quoted for something already served.
 */
function withIncluded(dish: MenuItem, list: Choice[]): Choice[] {
  // Keyed on the dish's name, because that is what identifies a dish here and
  // what MENU_SERVED_WITH in backend-php/app/menu_extras.php is keyed on too.
  // The two lists must be kept in step, or the guest is shown one price and
  // charged another.
  const free = includedKeysFor(dish);
  if (!free.length) return list;
  const kept = list.map(c => (free.includes(c.key) && c.add ? {...c, add: 0} : c));
  const named = free
    .filter(k => !list.some(c => c.key === k))
    .map(k => COMPANIONS.find(c => c.key === k))
    .filter((c): c is Choice => Boolean(c))
    .map(c => (c.add ? {...c, add: 0} : c));
  return [...kept, ...named];
}

/**
 * Which accompaniments a dish may be ordered with, taken from its section.
 * Every list leads with something that comes with the dish, so the plate a
 * guest opens is never quietly dearer than the price printed on the card.
 */
export function companionsFor(dish: MenuItem): Choice[] {
  const d = dish.desc || '';
  if (servedPlain.test(d)) return NO_COMPANIONS;
  const keys = CATEGORY_COMPANIONS[dish.group];
  if (!keys) return NO_COMPANIONS;
  return withIncluded(dish, choice(COMPANIONS, keys));
}

/** What the detail view starts on: the first accompaniment that is included. */
export function defaultCompanion(dish: MenuItem): Choice | null {
  const list = companionsFor(dish);
  return list.find(c => addOnPrice(c) === 0) ?? list[0] ?? null;
}

/**
 * A salad is a plate in its own right, so it is offered with anything that
 * arrives on a starch or a plate, and never with a soup, with a rice dish,
 * with the extras themselves, nor with the salads in the first section.
 */
export function saladsFor(dish: MenuItem): Choice[] {
  const d = dish.desc || '';
  if (servedPlain.test(d)) return NO_SALADS;
  if (companionsFor(dish).length) return CATEGORY_SALADS.includes(dish.group) ? SALADS : NO_SALADS;
  return NO_SALADS;
}

/** The money an add on contributes, which is nothing when they are all free. */
export const addOnPrice = (c: Choice): number => (ADD_ONS_INCLUDED ? 0 : c.add);

/** What one serving of this dish comes to once the guest has chosen. */
export const linePrice = (dish: MenuItem, companion: Choice | null, salads: Choice[]): number => {
  const base = dish.price ?? 0;
  const sides = (companion ? addOnPrice(companion) : 0) + salads.reduce((sum, s) => sum + addOnPrice(s), 0);
  return base + sides;
};

export const menuSections: MenuSection[] = [
  {
    key: 'starters',
    name: 'Starters & Salads',
    eyebrow: 'To begin',
    blurb: 'Fresh greens, tossed to order and dressed at the table.',
    image: 'caesar-salad.jpg',
    groups: [
      {
        name: 'Starters & Salads',
        items: [
          item('Mixed Garden Salad', 'Mixed lettuce, cucumber, tomatoes, onions and avocado.', 12000, 'Starters & Salads'),
          item('Greek Salad', 'Tomatoes, red onions, cucumber, lettuce, feta cheese, black olives and red cabbage.', 15000, 'Starters & Salads'),
          item('Avocado & Lettuce Salad', 'A well designed platter of lettuce, avocado, onions, cherry tomatoes and carrot shavings, finished with 1,000 Island dressing.', 15000, 'Starters & Salads'),
          item('Tuna Salad', 'Tuna fish, red onion and tomatoes infused in fresh mayonnaise, layered on a base of lettuce with avocado slices.', 20000, 'Starters & Salads'),
          item('Chicken Oriental Salad', 'Chicken with mayo, cucumber, pineapple, celery and tomatoes.', 20000, 'Starters & Salads'),
          item('Caesar Salad', 'Grilled chicken cubes, avocado, carrot, lettuce, tomato, croutons and Parmesan cheese shavings.', 22000, 'Starters & Salads'),
          item('Chef Salad', 'Crunchy lettuce, chicken flakes, beef strips, tomatoes, onions and bell peppers, topped with boiled Irish potatoes and a hard boiled egg.', 22000, 'Starters & Salads'),
          item('Grilled Vegetables Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dates.', 18000, 'Starters & Salads'),
          item('Grilled Chicken Salad', 'Grilled boneless chicken strips with onions, carrots, cucumber and tomatoes, garnished with black olives on a bed of lettuce.', 20000, 'Starters & Salads')
        ]
      }
    ]
  },
  {
    key: 'soups',
    name: 'Soups',
    eyebrow: 'Warmed through',
    blurb: 'Made fresh every morning and served with bread.',
    image: 'mushroom-soup.jpg',
    groups: [
      {
        name: 'Soups',
        items: [
          item('Mushroom Soup', 'Creamy or clear freshly made forest mushroom, homemade style. Served with a bread roll.', 12000, 'Soups'),
          item('Clear Vegetable Broth', 'Fresh homemade vegetable soup, served with a garlic bread roll.', 12000, 'Soups'),
          item('Cream of Tomato Soup', 'A puree of tomatoes finished with dairy cream, accompanied with croutons.', 12000, 'Soups'),
          item('Ginger Carrot Soup', 'A creamy soup with a hint of ginger and dairy cream, accompanied with toast.', 12000, 'Soups'),
          item('Clear Beef Noodle Soup', 'Fresh aromatic clear soup comprising julienne of beef, zucchini, carrots, onions and fresh noodles.', 15000, 'Soups'),
          item('Clear Chicken Noodle Soup', 'Fresh aromatic clear soup comprising julienne of chicken, zucchini, carrots, onions and fresh noodles.', 15000, 'Soups')
        ]
      }
    ]
  },
  {
    key: 'omelets',
    name: 'Omelets & Snacks',
    eyebrow: 'From the pan',
    blurb: 'All omelets are served with chips.',
    image: 'spanish-omelet.jpg',
    groups: [
      {
        name: 'Omelets & Snacks',
        items: [
          item('French Cinnamon Toast', 'Garnished with mini fruit.', 12000, 'Omelets & Snacks'),
          item('Eggs and Toast', 'Two eggs cooked to your style with home fries.', 12000, 'Omelets & Snacks'),
          item('Mushroom and Cheese Omelet', 'Savory mushroom and cheddar, topped with a grilled tomato.', 15000, 'Omelets & Snacks'),
          item('Mexican Omelet', 'Mushroom, green pepper, cheese, tomato and green chili.', 15000, 'Omelets & Snacks'),
          item('Spanish Omelet', 'Traditional egg with red onion, mushroom, green pepper and tomatoes.', 15000, 'Omelets & Snacks'),
          item('Bacon Cheese Omelet', 'Crunchy bacon in three eggs, infused with cheese and a touch of pepper spice.', 18000, 'Omelets & Snacks'),
          item('Avocado with an Egg', 'Avocado with an egg and toasted bread, with a garnish.', 15000, 'Omelets & Snacks'),
          item('Yummy Chicken Omelet', 'Diced chicken with a hint of cheese, infused with onions and tomatoes.', 17000, 'Omelets & Snacks'),
          item('Chicken Gizzards', 'Boiled, fried and finished in homemade tomato sauce. Served with chips.', 18000, 'Omelets & Snacks'),
          item('Fish Fingers', 'Tender breaded fish, served with tartar sauce.', 25000, 'Omelets & Snacks'),
          item('Chicken Wings with Chips', 'Eight fried winglets tossed in tomato sauce, served with chips.', 28000, 'Omelets & Snacks'),
          item('Chicken Lollipops with Chips', 'Crispy fried chicken lollipops, served with chips.', 30000, 'Omelets & Snacks'),
          item('Mushroom Fries', 'Crispy chips tossed in brown mushroom sauce.', 12000, 'Omelets & Snacks'),
          item('Plain Chips with Garnish', 'Plain chips with a garnish.', 10000, 'Omelets & Snacks'),
          item('Masala Chips', 'Chips tossed in hot or mild Indian spices, tomato sauce and coriander leaves.', 15000, 'Omelets & Snacks'),
          item('Bacon Cheese Fries', 'Diced bacon, spring onions and tomato sauce, tossed with chips and finished with cheese.', 22000, 'Omelets & Snacks'),
          item('Chapatti Plain', 'A plain hand rolled chapatti.', 6000, 'Omelets & Snacks'),
          item('Vegetable Spring Rolls', 'Vegetable spring rolls.', 5000, 'Omelets & Snacks'),
          item('Pair of Chicken Spring Rolls', 'Two chicken spring rolls.', 6000, 'Omelets & Snacks'),
          item('Trio of Samosas (Beef)', 'Three pieces of beef samosas.', 5000, 'Omelets & Snacks'),
          item('Trio of Samosas (Vegetable)', 'Three pieces of vegetable samosas.', 5000, 'Omelets & Snacks'),
          item('Chicken Samosas (Pair)', '', 5000, 'Omelets & Snacks')
        ]
      }
    ]
  },
  {
    key: 'sandwiches',
    name: 'Sandwiches',
    eyebrow: 'The sandwich corner',
    blurb: 'All sandwiches come with chips or salad.',
    image: 'classic-blt-sandwich.jpg',
    groups: [
      {
        name: 'Sandwiches',
        items: [
          item('Tomato, Cheese & Avocado Sandwich', 'Grated cheddar cheese, tomatoes, lettuce and avocado on whole wheat, white bread or French loaf.', 18000, 'Sandwiches'),
          item('Pulled Pork Sandwich', 'Pork flakes in mayo or sweet chili sauce, lettuce, brown onions, tomatoes and cucumber pickles.', 24000, 'Sandwiches'),
          item('Chicken Salad Sandwich', 'Chicken with mayo, lettuce, onions, celery and tomatoes on a three decker toast.', 24000, 'Sandwiches'),
          item('Classic BLT Sandwich', 'A three decker bacon, lettuce and tomato sandwich.', 25000, 'Sandwiches'),
          item('Steak Cheese Sandwich', 'Tender steak with cheese, tomato and lettuce.', 25000, 'Sandwiches'),
          item('BBQ Beef Sandwich', 'Beef strips sautéed with vegetables, onions, bell pepper and mushroom in tangy BBQ sauce.', 25000, 'Sandwiches'),
          item('Tuna Melt Sandwich', 'Tuna chunks with mayo, red onions, tomatoes and lettuce.', 25000, 'Sandwiches'),
          item('Paradise Club Sandwich', 'A triple decker sandwich with sliced grilled beef, chicken breast, bacon, cheese, onions and mayo.', 30000, 'Sandwiches')
        ]
      }
    ]
  },
  {
    key: 'burgers',
    name: 'Burgers',
    eyebrow: 'The grill',
    blurb: 'Burgers can be served with chips and salad.',
    image: 'king-burger.jpg',
    groups: [
      {
        name: 'Burgers',
        items: [
          item('BBQ Burger', 'A grilled beef or chicken patty finished in a tangy BBQ sauce.', 27000, 'Burgers'),
          item('Chicken Burger', 'A grilled regular or Cajun chicken patty with lettuce, onions, tomatoes and chili mayo.', 25000, 'Burgers'),
          item('Beef Burger', 'A grilled regular or Cajun beef patty with lettuce, onions, tomatoes and chili mayo.', 25000, 'Burgers'),
          item('Vegetable Burger', 'A crumbed fried vegetable patty with tomatoes, lettuce, onions and chili mayo.', 20000, 'Burgers'),
          item('Mushroom & Cheese Burger', 'A grilled beef patty topped with melted cheese and a creamy mushroom sauce.', 22000, 'Burgers'),
          item('King Burger', 'A double patty with bacon, cheese, caramelized onions, lettuce, pickles and tomato.', 35000, 'Burgers')
        ]
      }
    ]
  },
  {
    key: 'wraps',
    name: 'Rolex Wraps & Burritos',
    eyebrow: 'Rolled to order',
    blurb: 'Warm tortillas, filled as you like them.',
    image: 'beef-rolex.jpg',
    groups: [
      {
        name: 'Rolex Wraps & Burritos',
        items: [
          item('Crunchy Vegetable Wrap', 'Sautéed vegetables and lettuce with cheddar cheese, wrapped in a plain tortilla.', 14000, 'Rolex Wraps & Burritos'),
          item('Beef Rolex', 'A combination of eggs, beef, red onions, tomatoes and green pepper.', 15000, 'Rolex Wraps & Burritos'),
          item('Chicken Rolex', 'A combination of three eggs, grilled chicken cubes, red onions, tomatoes and green pepper.', 15000, 'Rolex Wraps & Burritos'),
          item('Chicken Wrap', 'Crispy lettuce, shredded chicken, onions, tomatoes and avocado, in mayo or sweet chili, wrapped in a tortilla.', 20000, 'Rolex Wraps & Burritos'),
          item('Classic BLT Wrap', 'Crispy bacon, lettuce and tomatoes in a tortilla.', 17000, 'Rolex Wraps & Burritos'),
          item('Chicken / Beef Burrito', 'Grilled tender strips with white onions wrapped in a tortilla, topped with cheese and served with guacamole.', 27000, 'Rolex Wraps & Burritos'),
          item('Fajita Chicken / Beef', 'Sautéed with coriander, onions and oyster sauce. Your choice of tortilla or sizzler plate, served with rice.', 30000, 'Rolex Wraps & Burritos')
        ]
      }
    ]
  },
  {
    key: 'seafood',
    name: "Fisherman's Offer",
    eyebrow: 'Fresh from the Nile',
    blurb: 'Tilapia and Nile perch, grilled, poached, crumbed or steamed.',
    image: 'grilled-king-fish.jpg',
    groups: [
      {
        name: "Fisherman's Offer",
        items: [
          item('Fish Florentine', 'Grilled tilapia fillet with creamy spinach and cheese.', 32000, "Fisherman's Offer"),
          item('Poached Fish', 'Tilapia fillet gently cooked in rich fish stock with fresh mushrooms and potatoes.', 30000, "Fisherman's Offer"),
          item('Mombasa Fish', 'A tilapia fillet crumbed with coconut and fried to perfection.', 32000, "Fisherman's Offer"),
          item('Catch of the Day (Nile Perch)', 'Pan grilled Nile perch fillet.', 32000, "Fisherman's Offer", 'nile-parch-catch-for-a-day.jpg'),
          item('Deep Fried Fish Fillet', 'A coated tilapia fish fillet.', 32000, "Fisherman's Offer"),
          item('Pan Grilled Fish Fillet', 'A coated tilapia fish fillet.', 32000, "Fisherman's Offer"),
          item('Fish Fingers with Chips', 'Fish fingers served with chips.', 30000, "Fisherman's Offer"),
          item('Paradise Rustica Fish', 'Grilled tilapia fillet layered on guacamole and salsa with hot chili, rustica sauce and black olives.', 32000, "Fisherman's Offer"),
          item('Medium Fried Tilapia', 'Medium fried tilapia served with chips.', 38000, "Fisherman's Offer"),
          item('Medium Steamed Tilapia', 'Medium steamed tilapia served with chips.', 38000, "Fisherman's Offer"),
          item('Premium Wet Fried Tilapia', 'Premium wet fried tilapia.', 40000, "Fisherman's Offer"),
          item('Premium Whole Fish', 'Steamed or fried whole fish.', 37000, "Fisherman's Offer"),
          item('Grilled Premium Fish', 'Whole oven grilled oil free premium tilapia.', 43000, "Fisherman's Offer"),
          item('Large Fried Tilapia', 'Large fried tilapia served with chips.', 43000, "Fisherman's Offer"),
          item('Large Steamed Tilapia', 'Large steamed tilapia served with chips.', 43000, "Fisherman's Offer"),
          item('King Wet Fried Tilapia', 'King wet fried tilapia.', 45000, "Fisherman's Offer"),
          item('King Size Whole Fish', 'A fish fillet, English, grilled or crumbed, on spinach drizzled with mushroom sauce.', 42000, "Fisherman's Offer"),
          item('Grilled King Fish', 'Whole oven grilled oil free king tilapia.', 48000, "Fisherman's Offer"),
          item('Fried King Prawns', 'King prawns prepared in a seasoned butter sauce.', 45000, "Fisherman's Offer"),
          item('Golden Grilled Salmon', 'Grilled salmon on a bed of spinach, laced with white mushroom sauce.', 45000, "Fisherman's Offer")
        ]
      }
    ]
  },
  {
    key: 'house',
    name: 'House Specials & Platters',
    eyebrow: 'For the table',
    blurb: 'Platters built for sharing, with a side of your choice.',
    image: 'mixed-grill-platter.jpg',
    groups: [
      {
        name: 'House Specials & Platters',
        items: [
          item('Mixed Grill Platter', 'A platter for two with grilled chicken, beef muchomo, roasted goat, a pair of sausages and a choice of side.', 80000, 'House Specials & Platters'),
          item('Paradise Lusaniya', 'A family platter for three to four: grilled chicken, beef steak, goat muchomo, brown pilau, matooke or wedges.', 100000, 'House Specials & Platters')
        ]
      }
    ]
  },
  {
    key: 'chicken',
    name: 'Chicken Dishes',
    eyebrow: 'Poultry',
    blurb: 'Marinated overnight, then grilled, pan fried or tossed in sauce.',
    image: 'bbq-chicken-drumstick.jpg',
    groups: [
      {
        name: 'Chicken Dishes',
        items: [
item('Chicken Sauté', 'Sautéed chicken with brown mushroom and spring onions, served with mushroom sauce.', 30000, 'Chicken Dishes'),
          item('BBQ Chicken Drumstick', 'Three well marinated chicken drumsticks, fried and tossed in BBQ sauce with fresh Dania.', 30000, 'Chicken Dishes'),
          item('Grilled Quarter Chicken (Breast)', 'Well marinated charcoal or oven roasted tender chicken breast.', 30000, 'Chicken Dishes'),
          item('Grilled Quarter Chicken (Thigh)', 'Well marinated charcoal or oven roasted tender chicken thigh.', 30000, 'Chicken Dishes'),
          item('Mushroom Chicken', 'Pan fried chicken cubes infused in a creamy white mushroom sauce and spring onions.', 32000, 'Chicken Dishes'),
          item('Supreme Chicken', 'Fresh pan fried boneless chicken breast in mushroom sauce.', 32000, 'Chicken Dishes'),
          item('Paradise Grilled Farm Chicken', 'A well marinated chicken grilled to perfection with aromatic seasonings.', 45000, 'Chicken Dishes')
        ]
      }
    ]
  },
  {
    key: 'beef',
    name: 'Beef & Goat Main Courses',
    eyebrow: 'Steaks and grills',
    blurb: 'Prime beef fillet, tender goat and the hunter’s favourites.',
    image: 'king-steak.jpg',
    groups: [
      {
        name: 'Beef & Goat Main Courses',
        items: [
          item('Goat Sizzler', 'Stir fried dry goat flakes with vegetables and rosemary.', 27000, 'Beef & Goat Main Courses'),
          item('Goat Muchomo', 'Well marinated chunks of goat roasted and tossed in fresh vegetables, tomato and BBQ sauce.', 30000, 'Beef & Goat Main Courses'),
          item('Beef Stir Fry', 'Tender beef strips grilled with vegetables and a hint of tomato sauce.', 35000, 'Beef & Goat Main Courses'),
          item('Beef Wet Fry', 'Tender well seasoned beef fillet infused in a black peppercorn sauce.', 35000, 'Beef & Goat Main Courses'),
          item('Honey Glazed Hawaiian Beef Skewers', 'Three beef skewers with pineapple, vegetables, natural honey and organic herbs.', 35000, 'Beef & Goat Main Courses'),
          item('Beef Stroganoff', 'Slow cooked beef in a mushroom and red wine sauce, finished with fresh cream.', 35000, 'Beef & Goat Main Courses'),
          item('Beef in Guinness', 'Steak simmered in Guinness beer and a creamy sauce.', 30000, 'Beef & Goat Main Courses'),
          item('Goat Rack Tender', 'Pan fried rib rack.', 32000, 'Beef & Goat Main Courses'),
          item('Liver Princess', 'Flakes of liver toasted with shredded vegetables.', 30000, 'Beef & Goat Main Courses'),
          item('Beef Fillet Steak (Pepper Sauce)', 'Beef fillet steak in a black peppercorn sauce.', 35000, 'Beef & Goat Main Courses'),
          item('Beef Fillet Steak (Mushroom Sauce)', 'Beef fillet steak in a creamy brown mushroom sauce.', 35000, 'Beef & Goat Main Courses'),
          item('Beef Fillet Steak (Dry Onion)', 'Beef fillet steak with dry onion.', 35000, 'Beef & Goat Main Courses'),
          item('King Steak', 'Apportioned beef fillet pan fried to preference, topped with a fried egg.', 40000, 'Beef & Goat Main Courses'),
          item('Paradise Mixed Grill', 'A mixture of grills: chicken, steak and fish fillet, topped with a fried egg.', 47000, 'Beef & Goat Main Courses')
        ]
      }
    ]
  },
  {
    key: 'pork',
    name: 'Pork Courses',
    eyebrow: 'Pork',
    blurb: 'Slow roasted, glazed and grilled to your liking.',
    image: 'honey-mustard-glazed-pork-ribs.jpg',
    groups: [
      {
        name: 'Pork Courses',
        items: [
          item('Pork Muchomo', 'Boneless pork chunks roasted and tossed in aromatic vegetables.', 30000, 'Pork Courses'),
          item('Paradise Grilled Pork Chops', 'Perfectly marinated tender pork chops, grilled to satisfaction.', 35000, 'Pork Courses'),
          item('Honey Mustard Glazed Pork Ribs', 'Tender and juicy pork ribs tossed in onion rings and honey.', 35000, 'Pork Courses'),
          item('Sweet and Sour Pork', 'Well seasoned pork chunks glazed in a tangy sweet and sour sauce with spring onions.', 38000, 'Pork Courses'),
          item('Trio of Pork', 'A combination of pork ribs, pork muchomo and pork chops on a single platter.', 45000, 'Pork Courses')
        ]
      }
    ]
  },
  {
    key: 'pizza',
    name: 'Pizzeria',
    eyebrow: 'Pizza',
    blurb: 'Baked to order on a stone base. A whole meal on its own, add garlic bread or a salad.',
    image: 'section-pizza.jpg',
    groups: [
      {
        name: 'Pizzeria',
        items: [
          item('Classico e Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 24000, 'Pizzeria', 'classic-margherita.jpg'),
          item('Sweet Vegetarian', 'Red, yellow and green bell pepper, sweet corn and mozzarella.', 24000, 'Pizzeria'),
          item('Pugliese', 'Tomato, black olives, oregano and cheese.', 24000, 'Pizzeria'),
          item('Pata', 'Chips, tomato and cheese.', 26000, 'Pizzeria'),
          item('Diavola', 'Tomato, chili, salami and mozzarella.', 26000, 'Pizzeria'),
          item('Salami', 'Tomato, cheese and salami.', 26000, 'Pizzeria'),
          item('Quattro Stagioni', 'Ham, olives, mushroom, artichokes and mozzarella.', 26000, 'Pizzeria'),
          item('Prosciutto Funghi', 'Ham, mushroom and cheese.', 26000, 'Pizzeria'),
          item('Prosciutto', 'Cooked ham, tomato and mozzarella.', 27000, 'Pizzeria'),
          item('Bolognaise', 'Spicy minced meat, mozzarella and tomato.', 27000, 'Pizzeria'),
          item('Capricciosa', 'Black olives, artichokes, capers, mushroom and salad.', 27000, 'Pizzeria'),
          item('Pepperoni', 'Tomato, green pepper, onions, pepperoni and mozzarella.', 27000, 'Pizzeria'),
          item('Hawaiian', 'Ham or bacon, pineapple and mozzarella.', 27000, 'Pizzeria'),
          item('Pollo Pizza', 'Italian chicken pizza with green pepper, onions and mushroom.', 27000, 'Pizzeria'),
          item('Tuna', 'Tuna, tomato, onions, green pepper and mozzarella, topped with a boiled egg.', 28000, 'Pizzeria'),
          item('Calzone Pizza', 'Minced meat, carrots and green pepper, folded into a semi circular bread shape.', 30000, 'Pizzeria'),
          item("Farmer's Pizza", 'Chicken and mushroom.', 30000, 'Pizzeria'),
          item('Paradise Special Pizza', 'Minced meat, salami, ham, mushroom, green pepper and onions.', 35000, 'Pizzeria')
        ]
      }
    ]
  },
  {
    key: 'pasta',
    name: 'Italian Pastas',
    eyebrow: 'From Napoli',
    blurb: 'Pasta choices: spaghetti, penne, fettuccine, farfalle or spirulina.',
    image: 'pasta-a-la-carbonara.jpg',
    groups: [
      {
        name: 'Italian Pastas',
        items: [
          item('Pasta Arabiata', 'Pasta in a tomato and fresh chili sauce, topped with cheese.', 20000, 'Italian Pastas'),
          item('Pasta a la Napolitana', 'Pasta in herby tomato and cheese sauce.', 18000, 'Italian Pastas'),
          item('Pasta Genovese', 'Pasta in pesto sauce.', 22000, 'Italian Pastas'),
          item('Pasta a la Carbonara', 'Pasta with egg and bacon in a creamy sauce, topped with cheese.', 25000, 'Italian Pastas'),
          item('Pasta Classic Bolognaise', 'Pasta in a minced meat, garlic, tomato and red wine sauce, topped with cheese.', 25000, 'Italian Pastas'),
          item('Pasta ala Cavolfiore e Salsiccia', 'Pasta with cauliflower and sausage in an egg and bacon creamy sauce.', 22000, 'Italian Pastas'),
          item('Pasta a la Contadina', 'Pasta in chicken, garlic, coriander, white wine and a creamy coconut sauce.', 25000, 'Italian Pastas')
        ]
      }
    ]
  },
  {
    key: 'asian',
    name: 'Asian & Indian Curries',
    eyebrow: 'Far East and sub continent',
    blurb: 'Non veg curries are served with a choice of 1 or 2 accompaniments.',
    image: 'chicken-coconut-curry.jpg',
    groups: [
      {
        name: 'Asian & Indian Curries',
        items: [
          item('Aloo Mutter', 'Diced potatoes and cowpeas prepared in a creamy sauce.', 18000, 'Asian & Indian Curries'),
          item('Mixed Vegetable Curry', 'Assorted vegetables in a creamy sauce, served with white rice or mash.', 20000, 'Asian & Indian Curries'),
          item('Veggie Biryani', 'Diced mixed vegetables in a creamy curry sauce, mixed with rice.', 25000, 'Asian & Indian Curries'),
          item('Vegetable Chow Mein', 'Noodles with oyster and soy sauce, tossed with fresh vegetables.', 20000, 'Asian & Indian Curries'),
          item('Vegetable Korma', 'Mixed vegetables in a mild creamy almond and cashew nut sauce.', 25000, 'Asian & Indian Curries'),
          item('Chicken Tikka', '', 28000, 'Asian & Indian Curries'),
          item('Chili Chicken', '', 28000, 'Asian & Indian Curries'),
          item('Chicken Biryani', 'Cubes of chicken cooked in a creamy sauce, mixed with rice.', 32000, 'Asian & Indian Curries'),
          item('Fish Biryani', 'Cubes of fish cooked in a creamy sauce, mixed with rice.', 32000, 'Asian & Indian Curries'),
          item('Goat Biryani', 'Cubes of goat cooked in a creamy sauce, mixed with rice.', 32000, 'Asian & Indian Curries'),
          item('Chicken Coconut Curry', 'Grilled and cubed boneless chicken in a golden sauce infused with coconut.', 32000, 'Asian & Indian Curries'),
          item('Chicken Tikka Masala', '', 30000, 'Asian & Indian Curries'),
          item('Chicken Makhani', 'Boneless tandoori marinated chicken cooked in butter and tomato gravy.', 30000, 'Asian & Indian Curries'),
          item('Fish Curry Diamond', '', 30000, 'Asian & Indian Curries'),
          item('Fish Tikka', '', 30000, 'Asian & Indian Curries'),
          item('Fish Tikka Masala', '', 32000, 'Asian & Indian Curries'),
          item('Half Tandoori Chicken', 'Chicken marinated with yogurt, ginger, garlic and spices, roasted in a clay oven.', 37000, 'Asian & Indian Curries'),
          item('Full Tandoori Chicken', 'A full chicken marinated with yogurt, ginger, garlic and spices, roasted in a clay oven.', 47000, 'Asian & Indian Curries')
        ]
      }
    ]
  },
  {
    key: 'chinese',
    name: 'Chinese Corner',
    eyebrow: 'Wok and steam',
    blurb: 'Sizzling plates, deep fried bites and the full sweet and sour house.',
    image: 'sweet-and-sour-chicken.jpg',
    groups: [
      {
        name: 'Chinese Corner',
        items: [
          item('Vegetable Spring Roll (1pc)', '', 1000, 'Chinese Corner', 'vegetable-spring-rolls.jpg'),
          item('Chicken Spring Roll (1pc)', '', 2500, 'Chinese Corner', 'chicken-spring-rolls.webp'),
          item('Pork Spring Roll (1pc)', '', 2500, 'Chinese Corner', 'pork-spring-roll.jpg'),
          item('Vegetable Wanton', '', 5000, 'Chinese Corner', 'vegetable-wonton.jpg'),
          item('Special Chicken Wings (1pc)', '', 7000, 'Chinese Corner', 'special-chicken-wings.webp'),
          item('Fried Wanton (Chicken or Beef)', '', 8000, 'Chinese Corner', 'fried-wonton-chicken.jpg'),
          item('Golden Fried Cauliflower', '', 10000, 'Chinese Corner'),
          item('Fried Chips Plain', '', 10000, 'Chinese Corner'),
          item('Special Beef Simsim', '', 15000, 'Chinese Corner'),
          item('Smoked Fish', '', 15000, 'Chinese Corner'),
          item('Salty Chicken / Beef', '', 15000, 'Chinese Corner', 'salty-chicken.webp'),
          item('Foil Wrapped Chicken', '', 15000, 'Chinese Corner'),
          item('French Fries with Garlic Sauce', '', 15000, 'Chinese Corner'),
          item('Fried Egg Rolled Chicken (Pair)', '', 18000, 'Chinese Corner', 'fried-eggs-rolled-chicken.jpg'),
          item('Fried Chicken Wings', '', 20000, 'Chinese Corner'),
          item('Crispy Chicken Legs', '', 20000, 'Chinese Corner', 'cripcy-chicken-legs.jpg'),
          item('Golden Fried Prawns', '', 20000, 'Chinese Corner'),
          item('Fried Baby Corn with Cashew Nuts', '', 20000, 'Chinese Corner'),
          item('Fried Summary Chicken', '', 25000, 'Chinese Corner'),
          item('Sauté Chicken Sichuan Style', '', 25000, 'Chinese Corner', 'saute-chicken-sichuan-style.jpg'),
          item('Chicken Curry', '', 25000, 'Chinese Corner'),
          item('Fried French Beans with Garlic Sauce', '', 25000, 'Chinese Corner'),
          item('Chinese Cabbage Sichuan Style (Hot)', '', 25000, 'Chinese Corner', 'chinese-cabbage-sichuan-style.jpg'),
          item('Mixed Vegetables (Onions, Cabbage, Carrots, Pepper, Mushroom)', '', 25000, 'Chinese Corner', 'mixed-vegetable-onions-cabbage-carrots-pepper-mushroom.jpg'),
          item('Stir-Fried Chicken with Cashew Nuts', '', 30000, 'Chinese Corner'),
          item('Spicy Half Chicken with Vegetables', '', 30000, 'Chinese Corner'),
          item('Fried Chicken with Chinese Black Bean Sauce', '', 30000, 'Chinese Corner'),
          item('Sweet and Sour Chicken', '', 30000, 'Chinese Corner'),
          item('Sliced Chicken with Garlic Sauce', '', 30000, 'Chinese Corner'),
          item('Sliced Beef with Chinese Cabbage', '', 30000, 'Chinese Corner'),
          item('Shredded Beef with Onions', '', 30000, 'Chinese Corner', 'shredded-beef-with-vegetables.jpg'),
          item('Sweet and Sour Beef', '', 30000, 'Chinese Corner'),
          item('Sliced Beef in Oyster Sauce', '', 30000, 'Chinese Corner'),
          item('Shredded Beef with Vegetables', '', 30000, 'Chinese Corner'),
          item('Sliced Beef with Pineapple Sauce', '', 30000, 'Chinese Corner'),
          item('Beef Curry', '', 30000, 'Chinese Corner'),
          item('Sweet and Sour Pork (Chinese)', '', 30000, 'Chinese Corner'),
          item('Shredded Pork with Green Pepper', '', 30000, 'Chinese Corner'),
          item('Sauté Pork Sichuan Style (Hot)', '', 30000, 'Chinese Corner', 'saute-pork-sichuan-style.webp'),
          item('Spicy Pork with Garlic Sauce', '', 30000, 'Chinese Corner'),
          item('Sweet and Sour Fish Finger', '', 30000, 'Chinese Corner'),
          item('Spicy Fish with Ginger & Garlic Sauce', '', 30000, 'Chinese Corner'),
          item('Sliced Fish with Vegetables', '', 30000, 'Chinese Corner'),
          item('Sliced Fish in Special Hot Sweet & Sour Sauce', '', 30000, 'Chinese Corner'),
          item('Special Mixed Vegetables & Sprouts', '', 30000, 'Chinese Corner', 'special-mixed-vegetables-and-sprout.jpg'),
          item('Fried Mixed Chicken, Beef & Goat Meat', '', 35000, 'Chinese Corner', 'fried-mixed-chicken-beef-and-goat-meet.jpg'),
          item('Fried Shredded Chicken with Bamboo Shoots', '', 35000, 'Chinese Corner', 'fried-shredded-chicken-with-baboo-shoots.jpg'),
          item('Sliced Pork with Mushroom and Bamboo Shoots', '', 35000, 'Chinese Corner', 'sliced-pork-and-mushroom-with-bamboo-shoots.jpg'),
          item('Fried Beijing Duck with Vegetables', '', 35000, 'Chinese Corner'),
          item('Fried Duck with Bamboo Shoots', '', 35000, 'Chinese Corner'),
          item('Fried Prawns with Cashew Nuts', '', 45000, 'Chinese Corner', 'fried-prawns-cashew-nuts.jpg'),
          item('Sauté Prawns with Black Bean Sauce', '', 45000, 'Chinese Corner', 'saute-prawns-with-black-bean-sauce.webp'),
          item('Fried Prawns with Chinese Black Beans', '', 50000, 'Chinese Corner', 'fried-prawns-with-chinese-black-bean.jpg'),
          item('Beijing Roasted Duck (Whole)', '', 100000, 'Chinese Corner')
        ]
      }
    ]
  },
  {
    key: 'sizzlers',
    name: 'Sizzler Hot Plates',
    eyebrow: 'On a hot plate',
    blurb: 'Brought to the table on a sizzling iron, with rice.',
    image: 'sizzler-beef-plate.jpg',
    groups: [
      {
        name: 'Sizzler Hot Plates',
        items: [
          item('Sizzler Vegetables Plate', '', 30000, 'Sizzler Hot Plates'),
          item('Sizzler Pork Plate', '', 35000, 'Sizzler Hot Plates'),
          item('Sizzler Beef Plate', '', 35000, 'Sizzler Hot Plates'),
          item('Sizzler Chicken Plate', '', 35000, 'Sizzler Hot Plates'),
          item('Sizzler Shrimps / Prawns Plate', '', 50000, 'Sizzler Hot Plates', 'sizzler-shrimp-or-prawns-plate.jpg')
        ]
      }
    ]
  },
  {
    key: 'rice-noodles',
    name: 'Rice & Noodles',
    eyebrow: 'Side options',
    blurb: 'Everything to round off a main course.',
    image: 'chicken-fried-rice.jpg',
    groups: [
      {
        name: 'Rice & Noodles',
        items: [
          item('Steamed Rice', '', 8000, 'Rice & Noodles'),
          item('Fried Rice', '', 8000, 'Rice & Noodles'),
          item('Ginger Fried Rice', '', 8000, 'Rice & Noodles'),
          item('Vegetable Fried Rice', '', 10000, 'Rice & Noodles'),
          item('Vegetable Fried Noodles', '', 12000, 'Rice & Noodles'),
          item('Egg Fried Rice', '', 15000, 'Rice & Noodles', 'eggs-fried-rice.webp'),
          item('Chicken Fried Rice', '', 25000, 'Rice & Noodles'),
          item('Chicken / Beef / Pork Fried Noodles', '', 25000, 'Rice & Noodles')
        ]
      }
    ]
  },
  {
    key: 'accompaniments',
    name: 'Accompaniments & Extras',
    eyebrow: 'Side add ons',
    blurb: 'Added to any main course, priced per portion.',
    image: 'masala-chips.jpg',
    groups: [
      {
        name: 'Accompaniments & Extras',
        items: [
          item('Extra Mushroom', '', 4000, 'Accompaniments & Extras'),
          item('Extra Avocado', '', 4000, 'Accompaniments & Extras'),
          item('Extra Fried Egg', '', 4000, 'Accompaniments & Extras', 'extra-fried-eggs.jpg'),
          item('Extra Bacon', '', 7000, 'Accompaniments & Extras'),
          item('Extra Cheese', '', 7000, 'Accompaniments & Extras')
        ]
      }
    ]
  },
  {
    key: 'desserts',
    name: 'Desserts & Bakery',
    eyebrow: 'Sweet finish',
    blurb: 'Cakes, pastries and fruit from our own bakery.',
    image: 'chocolate-cake-slice.jpg',
    groups: [
      {
        name: 'Desserts & Bakery',
        items: [
          item('Cookies', '', 1000, 'Desserts & Bakery'),
          item('Croissant', '', 2000, 'Desserts & Bakery', 'croissants.jpg'),
          item('Beef / Chicken Pie', '', 5000, 'Desserts & Bakery', 'beef-or-chicken-pie.jpg'),
          item('Sausage Roll', '', 5000, 'Desserts & Bakery'),
          item('Bread Loaf', '', 6000, 'Desserts & Bakery'),
          item('Marble Cake Slice', '', 7000, 'Desserts & Bakery'),
          item('Chocolate Cake Slice', '', 7000, 'Desserts & Bakery'),
          item('Strawberry Cake Slice', '', 7000, 'Desserts & Bakery'),
          item('Lemon Cake Slice', '', 7000, 'Desserts & Bakery'),
          item('Vanilla Cake Slice', '', 7000, 'Desserts & Bakery'),
          item('Butter Bread', '', 7000, 'Desserts & Bakery'),
          item('French Bread', '', 7000, 'Desserts & Bakery'),
          item('Cinnamon Roll', '', 8000, 'Desserts & Bakery'),
          item('Ice Cream (3 Scoops)', 'A bowl of three scoops, with a choice of chocolate, vanilla or strawberry.', 9000, 'Desserts & Bakery', 'ice-cream-3-scoop.jpg'),
          item('Golden Fried Banana', '', 10000, 'Desserts & Bakery'),
          item('Banana Crepe', 'A thin pancake filled with sliced bananas and chocolate syrup, garnished with orange slices.', 15000, 'Desserts & Bakery'),
          item('Affogato / Espresso Ice Cream', 'Two scoops of ice cream of choice served with 60ml of espresso coffee.', 15000, 'Desserts & Bakery'),
          item('Special Banana with Honey Sauce', '', 12000, 'Desserts & Bakery'),
          item('Pineapple Upside-Down Cake', '', 14000, 'Desserts & Bakery'),
          item('Tropical Fruit Platter', 'A presentation of fresh seasonal fruit: mango, pineapple, melon, orange, grapes and passion fruit.', 15000, 'Desserts & Bakery', 'tropical-fruits-platter.jpg'),
          item('Fruit Salad', 'A combination of cubed fresh fruit sprinkled with passion fruit syrup.', 15000, 'Desserts & Bakery'),
          item('Lemon Tart', '', 15000, 'Desserts & Bakery'),
          item('Banana Split', 'Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.', 15000, 'Desserts & Bakery'),
          item('Mango Tart', '', 16000, 'Desserts & Bakery'),
          item('White Forest Cake', '', 16000, 'Desserts & Bakery'),
          item('Profiteroles', '', 16000, 'Desserts & Bakery'),
          item('Chocolate Fudge Slice', '', 17000, 'Desserts & Bakery'),
          item('Black Forest Cake (pc)', '', 17000, 'Desserts & Bakery', 'black-forest-cake.jpg'),
          item('Classic Carrot Cake', '', 19000, 'Desserts & Bakery'),
          item('Chocolate Mousse', '', 20000, 'Desserts & Bakery')
        ]
      }
    ]
  }
];

/** Cheap kebab of a dish name, used to guess the photo file name. */
export const slugify = (s: string): string =>
  s.toLowerCase().replace(/&/g, 'and').replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');

export const DISH_IMAGE_DIR = './images/dishes/';
export const SECTION_IMAGE_DIR = './images/dishes/';

export const dishImage = (i: MenuItem): string => i.image || slugify(i.name) + '.jpg';
export const sectionImage = (s: MenuSection): string => s.image || 'section-' + s.key + '.jpg';

export const totalDishes = (list: MenuSection[]): number =>
  list.reduce((n, s) => n + s.groups.reduce((m, g) => m + g.items.length, 0), 0);

/* ------------------------------------------------------------------
   THE ARRANGEMENT

   The kitchen groups a section by its dishes rather than by a second
   layer of headings, so the printed menu repeats itself: Burgers above
   Burgers, Desserts above Desserts, a Calzone group holding one
   Calzone. Two headings that say the same thing are noise, so they are
   lifted away here, once, for the whole menu, rather than one page at
   a time.

   The data is left exactly as the kitchen filed it. tidySections only
   decides what is worth printing, and a section with nothing left in it
   simply does not appear.
   ------------------------------------------------------------------ */

const sameWords = (a: string, b: string): boolean =>
  slugify(a) === slugify(b);

/** A heading that only repeats the section above it, or names its one dish. */
const headingIsNoise = (section: MenuSection, group: MenuGroup): boolean => {
  if (sameWords(group.name, section.name)) return true;
  if (section.eyebrow && slugify(group.name) === slugify(section.eyebrow)) return true;
  if (group.items.length === 1 && sameWords(group.items[0].name, group.name)) return true;
  return false;
};

/**
 * The menu as it should be read: one section banner, then only the headings
 * underneath it that tell the guest something they cannot already see. A
 * heading that repeats the banner is dropped, and the dishes beneath it are
 * left exactly where they are, so nothing is ever lost off the page.
 *
 * Applied to the live menu from the kitchen as well as to the fallback, so
 * the two always read the same way.
 */
export function tidySections(list: MenuSection[]): MenuSection[] {
  return list
    .map(section => ({
      ...section,
      groups: section.groups
        .filter(g => g.items.length)
        .map(g => ({...g, title: headingIsNoise(section, g) ? '' : g.name}))
    }))
    .filter(section => section.groups.length);
}
