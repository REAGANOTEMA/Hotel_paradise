-- ------------------------------------------------------------------------
-- Hotel Paradise on the Nile - website upgrade
-- --------------------------------------------
--
-- One file, run once, safe to run again: every statement below checks
-- before it writes, so a second run changes nothing.
--
-- WHAT IT DOES
--   1. The customer account tables (sign up by email, then mobile number,
--      or sign in with Google) and the column that ties a payment to the
--      customer who made it.
--   2. The menu: every section was imported a dozen times over. Sections
--      that share an outlet and a name are merged into one, and each dish
--      is kept once per section. Nothing a guest can see today is lost.
--   3. A photograph for every dish the menu can match to a file in
--      /images/dishes or /images/food, and a banner for the sections that
--      have a photograph worth showing.
--   4. The photographs filed after the last pass: the drinks, the room
--      service plates, the burgers and the desserts, plus a banner for
--      each bar section.
--
-- WHERE TO RUN IT
--   phpMyAdmin (http://localhost/phpmyadmin): pick hotelpardise_system in
--   the left column, open the SQL tab, paste this file, press Go. Or from
--   a terminal:  C:\xampp\mysql\bin\mysql.exe -uroot hotelpardise_system < database/sql/upgrade/hotelpardise_upgrade.sql
--   It needs MariaDB (XAMPP ships it), because of ADD COLUMN IF NOT EXISTS.
--
-- ------------------------------------------------------------------------
-- 1. Customer accounts
-- --------------------
CREATE TABLE IF NOT EXISTS customers (
  id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id      BIGINT UNSIGNED NOT NULL DEFAULT 1,
  full_name     VARCHAR(160)    NOT NULL DEFAULT '',
  email         VARCHAR(190)    NOT NULL,
  phone         VARCHAR(40)     NOT NULL DEFAULT '',
  password_hash VARCHAR(255)    NOT NULL DEFAULT '',
  google_sub    VARCHAR(128)    NULL DEFAULT NULL,
  status        VARCHAR(24)     NOT NULL DEFAULT 'active',
  created_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login_at DATETIME        NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uniq_customers_email (email),
  UNIQUE KEY uniq_customers_google (google_sub),
  KEY idx_customers_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_tokens (
  id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id  BIGINT UNSIGNED NOT NULL,
  token_hash   CHAR(64)        NOT NULL,
  purpose      VARCHAR(24)     NOT NULL DEFAULT 'session',
  expires_at   DATETIME        NOT NULL,
  created_at   DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_seen_at DATETIME        NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uniq_token_hash (token_hash),
  KEY idx_token_customer (customer_id),
  KEY idx_token_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_signin_attempts (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  ip_address VARCHAR(45)     NOT NULL,
  email      VARCHAR(190)    NOT NULL DEFAULT '',
  attempts   INT UNSIGNED    NOT NULL DEFAULT 1,
  window_at  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_attempt_ip (ip_address),
  KEY idx_attempt_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE payments ADD COLUMN IF NOT EXISTS customer_id BIGINT UNSIGNED NULL DEFAULT NULL AFTER user_id;
-- ------------------------------------------------------------------------
-- 2. The menu: merge the sections that were imported more than once
-- -----------------------------------------------------------------
-- Items first move onto the one section that will survive, then the
-- surviving section takes the eyebrow, blurb and banner any of its copies
-- had, then the extra section rows are deleted. MIN(id) keeps the section
-- where it already sits in the order of the page.
UPDATE menu_items i
JOIN (SELECT outlet, name, MIN(id) AS keep, GROUP_CONCAT(id ORDER BY id) AS ids
      FROM menu_categories GROUP BY outlet, name HAVING COUNT(*) > 1) g
  ON FIND_IN_SET(i.category_id, g.ids) > 0 AND i.category_id <> g.keep
SET i.category_id = g.keep;

UPDATE menu_categories k
JOIN (SELECT outlet, name, MIN(id) AS keep,
             MAX(COALESCE(NULLIF(eyebrow,''),'')) AS eyebrow,
             MAX(COALESCE(NULLIF(blurb,''),'')) AS blurb,
             MAX(COALESCE(NULLIF(image,''),'')) AS image
      FROM menu_categories GROUP BY outlet, name HAVING COUNT(*) > 1) g ON g.keep = k.id
SET k.eyebrow = CASE WHEN COALESCE(k.eyebrow,'') = '' THEN NULLIF(g.eyebrow,'') ELSE k.eyebrow END,
    k.blurb   = CASE WHEN COALESCE(k.blurb,'')   = '' THEN NULLIF(g.blurb,'')   ELSE k.blurb END,
    k.image   = CASE WHEN COALESCE(k.image,'')   = '' THEN NULLIF(g.image,'')   ELSE k.image END;

DELETE d FROM menu_categories d
JOIN (SELECT outlet, name, MIN(id) AS keep, GROUP_CONCAT(id ORDER BY id) AS ids
      FROM menu_categories GROUP BY outlet, name HAVING COUNT(*) > 1) g
  ON FIND_IN_SET(d.id, g.ids) > 0 AND d.id <> g.keep;

-- One copy of each dish per section. The copy the site can sell wins over
-- the copy it cannot, and where both agree the older row stays.
DELETE d FROM menu_items d
JOIN menu_items k ON k.category_id = d.category_id AND k.name = d.name
 AND (k.active > d.active OR (k.active = d.active AND k.id < d.id));
-- ------------------------------------------------------------------------
-- 3. A photograph for every dish the library can answer for
-- ---------------------------------------------------------
-- menu_items.image is the file the menu card shows. Leaving it empty makes
-- the card guess the name of the file, which only works when the dish and
-- the file happen to be spelled the same way.
UPDATE menu_items SET image = 'avocado-with-an-egg.jpg' WHERE name IN ('Avocado with an Egg');
UPDATE menu_items SET image = 'bacon-cheese-omelet.jpg' WHERE name IN ('Bacon and Cheese Omelet');
UPDATE menu_items SET image = 'bbq-chicken-drumstick.jpg' WHERE name IN ('BBQ Chicken Drumstick');
UPDATE menu_items SET image = 'beef-fillet-steak-mushroom-sauce.jpg' WHERE name IN ('Beef Fillet Steak');
UPDATE menu_items SET image = 'beef-stir-fry.jpg' WHERE name IN ('Beef Stir Fry');
UPDATE menu_items SET image = 'beef-stroganoff.jpg' WHERE name IN ('Beef Stroganoff');
UPDATE menu_items SET image = 'beef-wet-fry.jpg' WHERE name IN ('Beef Wet Fry');
UPDATE menu_items SET image = 'bolognese.jpg' WHERE name IN ('Bolognese');
UPDATE menu_items SET image = 'calzone-pizza.jpg' WHERE name IN ('Calzone');
UPDATE menu_items SET image = 'capricciosa.jpg' WHERE name IN ('Capricciosa');
UPDATE menu_items SET image = 'chicken-biryani.jpg' WHERE name IN ('Chicken, Fish or Goat Biryani');
UPDATE menu_items SET image = 'chicken-burger.jpg' WHERE name IN ('Chicken and Beef Burger');
UPDATE menu_items SET image = 'chicken-coconut-curry.jpg' WHERE name IN ('Chicken Coconut Curry');
UPDATE menu_items SET image = 'chicken-lollipops-with-chips.jpg' WHERE name IN ('Chicken Lollipops with Chips');
UPDATE menu_items SET image = 'chicken-rolex.jpg' WHERE name IN ('Chicken and Beef Rolex');
UPDATE menu_items SET image = 'chicken-samosas-pair.jpg' WHERE name IN ('Samosas');
UPDATE menu_items SET image = 'chicken-saute.jpg' WHERE name IN ('Chicken Saute');
UPDATE menu_items SET image = 'chicken-wings-with-chips.jpg' WHERE name IN ('Chicken and Chips', 'Chicken Wings with Chips');
UPDATE menu_items SET image = 'chicken-wrap.jpg' WHERE name IN ('Chicken Wrap');
UPDATE menu_items SET image = 'classic-blt-sandwich.jpg' WHERE name IN ('Classic BLT Sandwich');
UPDATE menu_items SET image = 'classic-margherita.jpg' WHERE name IN ('Classic Margherita');
UPDATE menu_items SET image = 'clear-chicken-noodle-soup.jpg' WHERE name IN ('Clear Chicken and Beef Noodle Soup');
UPDATE menu_items SET image = 'crunchy-vegetable-wrap.jpg' WHERE name IN ('Crunchy Vegetable Wrap');
UPDATE menu_items SET image = 'deep-fried-fish-fillet.jpg' WHERE name IN ('Deep Fried or Pan Grilled Fillet');
UPDATE menu_items SET image = 'diavola.jpg' WHERE name IN ('Diavola');
UPDATE menu_items SET image = 'farmer-s-pizza.jpg' WHERE name IN ('Farmer\'s');
UPDATE menu_items SET image = 'fish-fingers-with-chips.jpg' WHERE name IN ('Fish Fingers with Chips');
UPDATE menu_items SET image = 'fruits.jpg' WHERE name IN ('Fresh Fruit Platter');
UPDATE menu_items SET image = 'fruits-image.jpg' WHERE name IN ('Fruit Salad');
UPDATE menu_items SET image = 'goat-muchomo.jpg' WHERE name IN ('Goat Muchomo');
UPDATE menu_items SET image = 'grilled-chicken-salad.jpg' WHERE name IN ('Grilled Chicken Salad');
UPDATE menu_items SET image = 'grilled-king-fish.jpg' WHERE name IN ('Grilled King Tilapia');
UPDATE menu_items SET image = 'grilled-premium-fish.jpg' WHERE name IN ('Grilled Premium Tilapia');
UPDATE menu_items SET image = 'grilled-quarter-chicken-breast.jpg' WHERE name IN ('Grilled Quarter Chicken Breast or Thigh');
UPDATE menu_items SET image = 'grilled-vegetables-salad.jpg' WHERE name IN ('Grilled Veggies Salad');
UPDATE menu_items SET image = 'hawaiian.jpg' WHERE name IN ('Hawaiian');
UPDATE menu_items SET image = 'honey-glazed-hawaiian-beef-skewers.jpg' WHERE name IN ('Honey Glazed Hawaiian Beef Skewers');
UPDATE menu_items SET image = 'honey-mustard-glazed-pork-ribs.jpg' WHERE name IN ('Honey Mustard Glazed Pork Ribs');
UPDATE menu_items SET image = 'king-steak.jpg' WHERE name IN ('King Steak');
UPDATE menu_items SET image = 'large-fried-tilapia.jpg' WHERE name IN ('Large Whole Tilapia, Fried or Steamed');
UPDATE menu_items SET image = 'mixed-grill-platter.jpg' WHERE name IN ('Mixed Grill Platter');
UPDATE menu_items SET image = 'mixed-vegetable-curry.jpg' WHERE name IN ('Mixed Vegetable Curry');
UPDATE menu_items SET image = 'mombasa-fish.jpg' WHERE name IN ('Mombasa Fish');
UPDATE menu_items SET image = 'mushroom-chicken.jpg' WHERE name IN ('Mushroom Chicken');
UPDATE menu_items SET image = 'mushroom-soup.jpg' WHERE name IN ('Mushroom Soup');
UPDATE menu_items SET image = 'nile-parch-catch-for-a-day.jpg' WHERE name IN ('Catch of the Day');
UPDATE menu_items SET image = 'pair-of-chicken-spring-rolls.jpg' WHERE name IN ('Chicken Spring Rolls');
UPDATE menu_items SET image = 'pan-grilled-fish-fillet.jpg' WHERE name IN ('Grilled Tilapia Fillet, Spinach and Cheese');
UPDATE menu_items SET image = 'paradise-club-sandwich.jpg' WHERE name IN ('Paradise Club Sandwich');
UPDATE menu_items SET image = 'paradise-grilled-farm-chicken.jpg' WHERE name IN ('Paradise Grilled Farm Chicken');
UPDATE menu_items SET image = 'paradise-grilled-pork-chops.jpg' WHERE name IN ('Paradise Grilled Pork Chops');
UPDATE menu_items SET image = 'paradise-lusaniya.jpg' WHERE name IN ('Paradise Lusaniya');
UPDATE menu_items SET image = 'paradise-mixed-grill.jpg' WHERE name IN ('Paradise Mixed Grill');
UPDATE menu_items SET image = 'paradise-rustica-fish.jpg' WHERE name IN ('Paradise Rustica Fish');
UPDATE menu_items SET image = 'pasta-a-la-carbonara.jpg' WHERE name IN ('Pasta Carbonara');
UPDATE menu_items SET image = 'pasta-arabiata.jpg' WHERE name IN ('Pasta Arrabbiata');
UPDATE menu_items SET image = 'pasta-classic-bolognaise.jpg' WHERE name IN ('Pasta Bolognese');
UPDATE menu_items SET image = 'pepperoni.jpg' WHERE name IN ('Pepperoni');
UPDATE menu_items SET image = 'pork-muchomo.jpg' WHERE name IN ('Pork Muchomo');
UPDATE menu_items SET image = 'premium-wet-fried-tilapia.jpg' WHERE name IN ('Premium Wet Fried Tilapia');
UPDATE menu_items SET image = 'premium-whole-fried.jpg' WHERE name IN ('Premium Whole Tilapia, Fried or Steamed');
UPDATE menu_items SET image = 'quattro-stagioni.jpg' WHERE name IN ('Quattro Stagioni');
UPDATE menu_items SET image = 'spanish-omelet.jpg' WHERE name IN ('Spanish Omelet');
UPDATE menu_items SET image = 'sweet-and-sour-pork.jpg' WHERE name IN ('Sweet and Sour Pork');
UPDATE menu_items SET image = 'sweet-vegetarian.jpg' WHERE name IN ('Sweet Vegetarian');
UPDATE menu_items SET image = 'tuna.jpg' WHERE name IN ('Tuna');
UPDATE menu_items SET image = 'tuna-melt-sandwich.jpg' WHERE name IN ('Tuna Melt');
UPDATE menu_items SET image = 'tuna-salad.jpg' WHERE name IN ('Tuna Salad');
UPDATE menu_items SET image = 'vegetable-burger.jpg' WHERE name IN ('Vegetable Burger');
UPDATE menu_items SET image = 'vegetable-korma.jpg' WHERE name IN ('Vegetable Korma');
UPDATE menu_items SET image = 'veggie-biryani.jpg' WHERE name IN ('Veggie Biryani');

-- Section banners. Sections left out here show the designed letter panel
-- until a photograph is filed as images/dishes/section-<section-name>.jpg,
-- which the menu picks up with no database change at all.
UPDATE menu_categories SET image = 'eggs-and-toast.jpg' WHERE outlet = 'restaurant' AND name = 'Breakfast';
UPDATE menu_categories SET image = 'paradise-rustica-fish.jpg' WHERE outlet = 'restaurant' AND name = 'Main Meals';
UPDATE menu_categories SET image = 'masala-chips.jpg' WHERE outlet = 'restaurant' AND name = 'Snacks';
UPDATE menu_categories SET image = 'caesar-salad.jpg' WHERE outlet = 'restaurant' AND name = 'Starters';
UPDATE menu_categories SET image = 'spanish-omelet.jpg' WHERE outlet = 'restaurant' AND name = 'Egg Dishes';
UPDATE menu_categories SET image = 'king-burger.jpg' WHERE outlet = 'restaurant' AND name = 'Burgers';
UPDATE menu_categories SET image = 'beef-rolex.jpg' WHERE outlet = 'restaurant' AND name = 'Wraps and Rolex';
UPDATE menu_categories SET image = 'pasta-a-la-carbonara.jpg' WHERE outlet = 'restaurant' AND name = 'Italian Special Pastas';
UPDATE menu_categories SET image = 'grilled-king-fish.jpg' WHERE outlet = 'restaurant' AND name = 'Fisherman''s Offer';
UPDATE menu_categories SET image = 'pan-grilled-fish-fillet.jpg' WHERE outlet = 'restaurant' AND name = 'Fish Fillets';
UPDATE menu_categories SET image = 'bbq-chicken-drumstick.jpg' WHERE outlet = 'restaurant' AND name = 'Chicken Lovers';
UPDATE menu_categories SET image = 'paradise-mixed-grill.jpg' WHERE outlet = 'restaurant' AND name = 'Paradise Hunter''s Delicacies';
UPDATE menu_categories SET image = 'honey-mustard-glazed-pork-ribs.jpg' WHERE outlet = 'restaurant' AND name = 'Pork';
UPDATE menu_categories SET image = 'mixed-grill-platter.jpg' WHERE outlet = 'restaurant' AND name = 'House Specials';
UPDATE menu_categories SET image = 'chicken-coconut-curry.jpg' WHERE outlet = 'restaurant' AND name = 'Asian Delicacies';
UPDATE menu_categories SET image = 'fruits-image.jpg' WHERE outlet = 'restaurant' AND name = 'Desserts';
UPDATE menu_categories SET image = 'section-pizza.jpg' WHERE outlet = 'restaurant' AND name = 'Pizzeria Section';
UPDATE menu_categories SET image = 'food-on-table-hero3-use-it-on-menu-page.jpg' WHERE outlet = 'room_service' AND name = 'Room Service';
-- ------------------------------------------------------------------------
-- 4. The photographs filed after the last pass
-- --------------------------------------------
-- Every dish below was left with no photograph when the file had not yet
-- been dropped into /images/food. The section is named in the join so a
-- dish that later appears twice cannot be dressed twice.
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'chilli-beef-and-veggie-chips.jpg' WHERE c.outlet = 'restaurant' AND c.name = 'Snacks' AND i.name = 'Chilli Beef and Veggie Chips';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'liver-with-shredded-vegetables.jpg' WHERE c.outlet = 'restaurant' AND c.name = 'Snacks' AND i.name = 'Liver with Shredded Vegetables';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'coca-cola-300ml.jpg' WHERE c.outlet = 'bar' AND c.name = 'Soft Drinks' AND i.name = 'Coca Cola 300ml';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'fanta-300ml.jpg' WHERE c.outlet = 'bar' AND c.name = 'Soft Drinks' AND i.name = 'Fanta 300ml';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'mineral-water-500ml.webp' WHERE c.outlet = 'bar' AND c.name = 'Soft Drinks' AND i.name = 'Mineral Water 500ml';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'paradise-sunset.jpg' WHERE c.outlet = 'bar' AND c.name = 'Cocktails' AND i.name = 'Paradise Sunset';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'nile-breeze.jpg' WHERE c.outlet = 'bar' AND c.name = 'Cocktails' AND i.name = 'Nile Breeze';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'nile-special.jpg' WHERE c.outlet = 'bar' AND c.name = 'Beers and Ciders' AND i.name = 'Nile Special';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'club-pilsener.jpg' WHERE c.outlet = 'bar' AND c.name = 'Beers and Ciders' AND i.name = 'Club Pilsener';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'bell-lager.jpg' WHERE c.outlet = 'bar' AND c.name = 'Beers and Ciders' AND i.name = 'Bell Lager';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'house-white-wine.jpg' WHERE c.outlet = 'bar' AND c.name = 'Wines and Spirits' AND i.name = 'House White Wine';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'local-spirit.jpg' WHERE c.outlet = 'bar' AND c.name = 'Wines and Spirits' AND i.name = 'Local Spirit';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'room-service-breakfast.jpg' WHERE c.outlet = 'room_service' AND c.name = 'Room Service' AND i.name = 'Room Service Breakfast';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'room-service-platter.jpg' WHERE c.outlet = 'room_service' AND c.name = 'Room Service' AND i.name = 'Room Service Platter';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'three-decker-sandwich.webp' WHERE c.outlet = 'restaurant' AND c.name = 'Starters' AND i.name = 'Three Decker Sandwich';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'bbq-beef-and-chicken-patty.jpg' WHERE c.outlet = 'restaurant' AND c.name = 'Burgers' AND i.name = 'BBQ Beef and Chicken Patty';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'double-beef-and-bacon-burger.jpg' WHERE c.outlet = 'restaurant' AND c.name = 'Burgers' AND i.name = 'Double Beef and Bacon Burger';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'pan-fried-boneless-chicken-breast.jpg' WHERE c.outlet = 'restaurant' AND c.name = 'Chicken Lovers' AND i.name = 'Pan Fried Boneless Chicken Breast';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'pork-muchomo-and-chops-platter.jpg' WHERE c.outlet = 'restaurant' AND c.name = 'Pork' AND i.name = 'Pork Muchomo and Chops Platter';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'banana-crepe.webp' WHERE c.outlet = 'restaurant' AND c.name = 'Desserts' AND i.name = 'Banana Crepe';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'ice-cream.jpg' WHERE c.outlet = 'restaurant' AND c.name = 'Desserts' AND i.name = 'Ice Cream';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'cake-of-the-day.jpg' WHERE c.outlet = 'restaurant' AND c.name = 'Desserts' AND i.name = 'Cake of the Day';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'affogato-espresso-ice-cream.webp' WHERE c.outlet = 'restaurant' AND c.name = 'Desserts' AND i.name = 'Affogato Espresso Ice Cream';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'banana-split.jpg' WHERE c.outlet = 'restaurant' AND c.name = 'Desserts' AND i.name = 'Banana Split';
UPDATE menu_items i JOIN menu_categories c ON c.id = i.category_id SET i.image = 'assorted-meat-and-salami.webp' WHERE c.outlet = 'restaurant' AND c.name = 'Pizzeria Section' AND i.name = 'Assorted Meat and Salami';

-- Bar banners. The restaurant sections carry a photograph of the plate they
-- sell; the four bar sections never had one, so they showed the letter panel.
UPDATE menu_categories SET image = 'coca-cola-300ml.jpg' WHERE outlet = 'bar' AND name = 'Soft Drinks';
UPDATE menu_categories SET image = 'paradise-sunset.jpg' WHERE outlet = 'bar' AND name = 'Cocktails';
UPDATE menu_categories SET image = 'bell-lager.jpg' WHERE outlet = 'bar' AND name = 'Beers and Ciders';
UPDATE menu_categories SET image = 'house-white-wine.jpg' WHERE outlet = 'bar' AND name = 'Wines and Spirits';
-- ------------------------------------------------------------------------
-- That is everything
-- ------------------

