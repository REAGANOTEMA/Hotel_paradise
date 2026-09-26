/**
 * PROPOSED A LA CARTE MENU — JANUARY 2026
 * Hotel Paradise on the Nile, 19 Kiira Road, Jinja.
 *
 * This is the fallback dataset used when the kitchen database is unreachable.
 * database/menu_alacarte.sql holds the same menu for the live database.
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

export const MENU_REVISION = 'Proposed a la carte menu, January 2026';

export const menuSections: MenuSection[] = [
  {
    key: 'starters',
    name: 'Starters',
    eyebrow: 'To begin',
    blurb: 'Warm soups, the sandwich corner and freshly dressed salads.',
    image: '',
    groups: [
      {
        name: 'Soups',
        items: [
          item('Mushroom Soup', 'Creamy forest mushroom soup, homemade style, served with a bread roll.', 12000, 'Soups'),
          item('Clear Chicken and Beef Noodle Soup', 'Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.', 15000, 'Soups')
        ]
      },
      {
        name: 'Sandwich Corner',
        items: [
          item('Classic BLT Sandwich', 'Crisp bacon, lettuce and ripe tomato in a toasted roll.', 25000, 'Sandwich Corner'),
          item('Three Decker Sandwich', 'Three decker of bacon, lettuce and tomato, served with chips.', null, 'Sandwich Corner'),
          item('Tuna Melt', 'Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.', 25000, 'Sandwich Corner'),
          item('Paradise Club Sandwich', 'Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.', 30000, 'Sandwich Corner')
        ]
      },
      {
        name: 'Salads',
        items: [
          item('Grilled Veggies Salad', 'Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.', 18000, 'Salads'),
          item('Grilled Chicken Salad', 'Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.', 15000, 'Salads'),
          item('Tuna Salad', 'Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.', 20000, 'Salads')
        ]
      }
    ]
  },
  {
    key: 'eggs',
    name: 'Egg Dishes',
    eyebrow: 'From the pan',
    blurb: 'Classic egg plates finished to order.',
    image: '',
    groups: [
      {
        name: 'Egg Dishes',
        items: [
          item('Spanish Omelet', 'Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.', 15000, 'Egg Dishes'),
          item('Avocado with an Egg', 'Avocado and a fried egg on toasted bread with a garnish.', 13000, 'Egg Dishes'),
          item('Bacon and Cheese Omelet', 'Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.', null, 'Egg Dishes')
        ]
      }
    ]
  },
  {
    key: 'burgers',
    name: 'Burgers',
    eyebrow: 'The grill',
    blurb: 'Charcoal patties, regular or Cajun, in a soft toasted bun.',
    image: '',
    groups: [
      {
        name: 'Burgers',
        items: [
          item('Vegetable Burger', 'Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.', 20000, 'Burgers'),
          item('Chicken and Beef Burger', 'Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.', null, 'Burgers'),
          item('BBQ Beef and Chicken Patty', 'Grilled beef or chicken patty finished in a tangy barbecue sauce.', null, 'Burgers'),
          item('Double Beef and Bacon Burger', 'Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.', null, 'Burgers')
        ]
      }
    ]
  },
  {
    key: 'wraps',
    name: 'Wraps and Rolex',
    eyebrow: 'Rolled fresh',
    blurb: 'Shredded fillings rolled warm in a soft tortilla.',
    image: '',
    groups: [
      {
        name: 'Wraps',
        items: [
          item('Chicken Wrap', 'Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.', 20000, 'Wraps'),
          item('Crunchy Vegetable Wrap', 'Sautéed vegetables with a touch of cheddar cheese, served plain.', 14000, 'Wraps'),
          item('Chicken and Beef Rolex', 'Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.', 15000, 'Wraps')
        ]
      }
    ]
  },
  {
    key: 'snacks',
    name: 'Snacks',
    eyebrow: 'Light bites',
    blurb: 'Served with a choice of rice or chips.',
    image: '',
    groups: [
      {
        name: 'Snacks',
        items: [
          item('Chilli Beef and Veggie Chips', 'Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.', null, 'Snacks'),
          item('Chicken Spring Rolls', 'A pair of crisp chicken spring rolls.', 6000, 'Snacks'),
          item('Liver with Shredded Vegetables', 'Flakes of liver tossed with shredded vegetables, served with rice or chips.', 30000, 'Snacks'),
          item('Fish Fingers with Chips', 'Crisp breaded fish fingers with a portion of chips.', 30000, 'Snacks'),
          item('Chicken Wings with Chips', 'Crispy chicken wings with a portion of chips.', 28000, 'Snacks'),
          item('Chicken Lollipops with Chips', 'Chicken lollipops with a portion of chips.', 30000, 'Snacks')
        ]
      }
    ]
  },
  {
    key: 'pasta',
    name: 'Italian Special Pastas',
    eyebrow: 'From Napoli',
    blurb: 'Fresh pasta finished with melted cheese and a slice of toast.',
    image: '',
    groups: [
      {
        name: 'Pasta',
        items: [
          item('Pasta Arrabbiata', 'Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.', 20000, 'Pasta'),
          item('Pasta Bolognese', 'Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.', 25000, 'Pasta'),
          item('Pasta Carbonara', 'Pasta with egg and bacon cream sauce, topped with cheese and served with toast.', 30000, 'Pasta')
        ]
      }
    ]
  },
  {
    key: 'wholefish',
    name: "Fisherman's Offer",
    eyebrow: 'Fresh from the Nile',
    blurb: 'Whole tilapia, fried, steamed or grilled. Oil free off the grill.',
    image: '',
    groups: [
      {
        name: 'Whole Fish',
        items: [
          item('Premium Whole Tilapia, Fried or Steamed', 'Medium premium tilapia, fried or steamed, served with chips.', null, 'Whole Fish'),
          item('Premium Wet Fried Tilapia', 'Premium tilapia in a seasoned wet fry.', null, 'Whole Fish'),
          item('Grilled Premium Tilapia', 'Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.', null, 'Whole Fish'),
          item('Large Whole Tilapia, Fried or Steamed', 'Large king tilapia, fried or steamed, served with chips.', null, 'Whole Fish'),
          item('Grilled Tilapia Fillet, Spinach and Cheese', 'Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.', null, 'Whole Fish')
        ]
      }
    ]
  },
  {
    key: 'fillets',
    name: 'Fish Fillets',
    eyebrow: 'The catch',
    blurb: 'Breaded, battered or simply grilled, with rice or chips.',
    image: '',
    groups: [
      {
        name: 'Fish Fillets',
        items: [
          item('Paradise Rustica Fish', 'Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.', 32000, 'Fish Fillets'),
          item('Mombasa Fish', 'Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.', 32000, 'Fish Fillets'),
          item('Deep Fried or Pan Grilled Fillet', 'Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.', 32000, 'Fish Fillets'),
          item('Catch of the Day', 'Pan grilled Nile perch fillet served with rice or chips.', null, 'Fish Fillets')
        ]
      }
    ]
  },
  {
    key: 'chicken',
    name: 'Chicken Lovers',
    eyebrow: 'Poultry',
    blurb: 'Marinated overnight, then grilled, pan fried or tossed in sauce.',
    image: '',
    groups: [
      {
        name: 'Chicken Lovers',
        items: [
          item('Chicken Saute', 'Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.', 30000, 'Chicken Lovers'),
          item('BBQ Chicken Drumstick', 'Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.', 30000, 'Chicken Lovers'),
          item('Grilled Quarter Chicken Breast or Thigh', 'Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.', 45000, 'Chicken Lovers'),
          item('Paradise Grilled Farm Chicken', 'A well marinated chicken grilled to perfection with aromatic seasonings.', 40000, 'Chicken Lovers'),
          item('Pan Fried Boneless Chicken Breast', 'Fresh pan fried boneless chicken breast resting in mushroom sauce.', 43000, 'Chicken Lovers')
        ]
      }
    ]
  },
  {
    key: 'steaks',
    name: "Paradise Hunter's Delicacies",
    eyebrow: 'Steaks and grills',
    blurb: "Prime beef fillet, skewers and the hunter's favourites.",
    image: '',
    groups: [
      {
        name: 'Steaks',
        items: [
          item('Beef Fillet Steak', 'Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.', 35000, 'Steaks'),
          item('King Steak', 'Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.', 40000, 'Steaks'),
          item('Beef Stroganoff', 'Slow cooked beef in mushroom and red wine sauce, finished with cream.', 15000, 'Steaks'),
          item('Beef Stir Fry', 'Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.', 35000, 'Steaks'),
          item('Paradise Mixed Grill', 'A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.', 47000, 'Steaks'),
          item('Honey Glazed Hawaiian Beef Skewers', 'Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.', 35000, 'Steaks'),
          item('Beef Wet Fry', 'Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.', 15000, 'Steaks'),
          item('Goat Muchomo', 'Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.', null, 'Steaks')
        ]
      }
    ]
  },
  {
    key: 'pork',
    name: 'Pork',
    eyebrow: 'Pork',
    blurb: 'Slow roasted, glazed and grilled to your liking.',
    image: '',
    groups: [
      {
        name: 'Pork',
        items: [
          item('Paradise Grilled Pork Chops', 'Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.', null, 'Pork'),
          item('Honey Mustard Glazed Pork Ribs', 'Tender juicy ribs of pork roasted in onion rings and honey.', null, 'Pork'),
          item('Pork Muchomo', 'Boneless chunks of pork roasted in aromatic vegetables, served with chips.', null, 'Pork'),
          item('Sweet and Sour Pork', 'Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.', null, 'Pork'),
          item('Pork Muchomo and Chops Platter', 'A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.', 35000, 'Pork')
        ]
      }
    ]
  },
  {
    key: 'house',
    name: 'House Specials',
    eyebrow: 'For the table',
    blurb: 'Platters built for sharing, served with two accompaniments.',
    image: '',
    groups: [
      {
        name: 'House Specials',
        items: [
          item('Paradise Lusaniya', 'A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.', 100000, 'House Specials'),
          item('Mixed Grill Platter', 'A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.', 80000, 'House Specials')
        ]
      }
    ]
  },
  {
    key: 'asian',
    name: 'Asian Delicacies',
    eyebrow: 'Far East',
    blurb: 'Mild creamy curries, biryani and coconut dishes with rice or chapatti.',
    image: '',
    groups: [
      {
        name: 'Curries',
        items: [
          item('Mixed Vegetable Curry', 'Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.', 20000, 'Curries'),
          item('Vegetable Korma', 'Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.', 25000, 'Curries'),
          item('Chicken Coconut Curry', 'Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.', 32000, 'Curries')
        ]
      },
      {
        name: 'Biryani',
        items: [
          item('Veggie Biryani', 'Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.', 25000, 'Biryani'),
          item('Chicken, Fish or Goat Biryani', 'Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.', 32000, 'Biryani')
        ]
      }
    ]
  },
  {
    key: 'desserts',
    name: 'Desserts',
    eyebrow: 'Sweet finish',
    blurb: 'Fresh fruit, ice cream and a little sugar.',
    image: '',
    groups: [
      {
        name: 'Desserts',
        items: [
          item('Fresh Fruit Platter', 'A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.', null, 'Desserts'),
          item('Fruit Salad', 'A combination of diced fruits sprinkled with passion fruit syrup.', 15000, 'Desserts'),
          item('Banana Crepe', 'A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.', 15000, 'Desserts'),
          item('Ice Cream', 'Three scoops, chocolate, vanilla or strawberry.', 9000, 'Desserts'),
          item('Cake of the Day', 'A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.', 7000, 'Desserts'),
          item('Affogato Espresso Ice Cream', 'Two scoops of ice cream of your choice with 60ml of espresso coffee.', 15000, 'Desserts'),
          item('Banana Split', 'Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.', 15000, 'Desserts')
        ]
      }
    ]
  },
  {
    key: 'pizza',
    name: 'Pizzeria Section',
    eyebrow: 'Pizza',
    blurb: 'Baked to order on a stone base, 12 inch.',
    image: '',
    groups: [
      {
        name: 'Pizza',
        items: [
          item('Classic Margherita', 'Tomato, fresh basil, oregano and mozzarella.', 27000, 'Pizza'),
          item('Sweet Vegetarian', 'Red, yellow and green bell pepper, sweet corn and mozzarella.', 27000, 'Pizza'),
          item('Quattro Stagioni', 'Ham, olives, mushroom, artichokes and mozzarella.', 30000, 'Pizza'),
          item('Pepperoni', 'Tomato, green pepper, onion, pepperoni and mozzarella.', 30000, 'Pizza'),
          item('Hawaiian', 'Ham or bacon, pineapple and mozzarella.', null, 'Pizza'),
          item("Farmer's", 'Chicken, mushroom and mozzarella.', 30000, 'Pizza'),
          item('Tuna', 'Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.', null, 'Pizza'),
          item('Diavola', 'Tomato, chili salami and mozzarella.', 30000, 'Pizza'),
          item('Bolognese', 'Spicy minced meat, tomato and mozzarella.', null, 'Pizza'),
          item('Capricciosa', 'Salami, black olives, artichokes, capers, mushroom and mozzarella.', 30000, 'Pizza'),
          item('Assorted Meat and Salami', 'Assorted meat, salami, mushroom, green pepper, onion and mozzarella.', 35000, 'Pizza')
        ]
      },
      {
        name: 'Calzone',
        items: [
          item('Calzone', 'Minced meat, green pepper and capsicum rolled in a half moon of bread.', 30000, 'Calzone')
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
