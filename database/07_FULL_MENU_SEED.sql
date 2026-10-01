-- HOTEL PARADISE ON THE NILE - COMPLETE MENU SEED
-- Generated from frontend-react/src/menuData.ts by database/tools/build-menu-seed.mjs
-- Do not hand edit. Re-run the generator instead.
--
-- 19 sections, 251 dishes for hotel 1, every one of them carrying a rate
-- in Ugandan shillings. A dish with no rate is stored as NULL, which is what
-- the website reads as "Priced on request"; there are 0 of those.
--
-- Safe to run on a hotel that is already trading. Dishes are matched on their
-- name, so a reload updates the existing rows in place and keeps the ids that
-- past orders already reference. Nothing is deleted and nothing is deactivated:
-- this file only sets the published flag, which is the website's business
-- alone. The till's menu, the bar and room service are left exactly as they are.
--
-- Run it inside a transaction if you would rather see the whole result or none
-- of it.
--
-- Sauté and Sautéed carry an accent, and the dishes are matched on their name.
-- The line below tells the client to read this file as UTF-8; without it a
-- client that defaults to latin1 will store a mangled name, fail to match the
-- existing row on a reload, and quietly publish the same dish twice.

SET NAMES utf8mb4;

USE `hotelpardise_system`;

-- Starters & Salads
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Starters & Salads','To begin','Fresh greens, tossed to order and dressed at the table.',NULL,1,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads' ORDER BY id LIMIT 1),'Mixed Garden Salad','Starters & Salads','Mixed lettuce, cucumber, tomatoes, onions and avocado.',12000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads' ORDER BY id LIMIT 1),'Greek Salad','Starters & Salads','Tomatoes, red onions, cucumber, lettuce, feta cheese, black olives and red cabbage.',15000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads' ORDER BY id LIMIT 1),'Avocado & Lettuce Salad','Starters & Salads','A well designed platter of lettuce, avocado, onions, cherry tomatoes and carrot shavings, finished with 1,000 Island dressing.',15000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads' ORDER BY id LIMIT 1),'Tuna Salad','Starters & Salads','Tuna fish, red onion and tomatoes infused in fresh mayonnaise, layered on a base of lettuce with avocado slices.',20000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads' ORDER BY id LIMIT 1),'Chicken Oriental Salad','Starters & Salads','Chicken with mayo, cucumber, pineapple, celery and tomatoes.',20000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads' ORDER BY id LIMIT 1),'Caesar Salad','Starters & Salads','Grilled chicken cubes, avocado, carrot, lettuce, tomato, croutons and Parmesan cheese shavings.',22000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads' ORDER BY id LIMIT 1),'Chef Salad','Starters & Salads','Crunchy lettuce, chicken flakes, beef strips, tomatoes, onions and bell peppers, topped with boiled Irish potatoes and a hard boiled egg.',22000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads' ORDER BY id LIMIT 1),'Grilled Vegetables Salad','Starters & Salads','Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dates.',18000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads' ORDER BY id LIMIT 1),'Grilled Chicken Salad','Starters & Salads','Grilled boneless chicken strips with onions, carrots, cucumber and tomatoes, garnished with black olives on a bed of lettuce.',20000,NULL,9,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Soups
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Soups','Warmed through','Made fresh every morning and served with bread.',NULL,2,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Soups' ORDER BY id LIMIT 1),'Mushroom Soup','Soups','Creamy or clear freshly made forest mushroom, homemade style. Served with a bread roll.',12000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Soups' ORDER BY id LIMIT 1),'Clear Vegetable Broth','Soups','Fresh homemade vegetable soup, served with a garlic bread roll.',12000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Soups' ORDER BY id LIMIT 1),'Cream of Tomato Soup','Soups','A puree of tomatoes finished with dairy cream, accompanied with croutons.',12000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Soups' ORDER BY id LIMIT 1),'Ginger Carrot Soup','Soups','A creamy soup with a hint of ginger and dairy cream, accompanied with toast.',12000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Soups' ORDER BY id LIMIT 1),'Clear Beef Noodle Soup','Soups','Fresh aromatic clear soup comprising julienne of beef, zucchini, carrots, onions and fresh noodles.',15000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Soups' ORDER BY id LIMIT 1),'Clear Chicken Noodle Soup','Soups','Fresh aromatic clear soup comprising julienne of chicken, zucchini, carrots, onions and fresh noodles.',15000,NULL,6,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Omelets & Snacks
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Omelets & Snacks','From the pan','All omelets are served with chips.',NULL,3,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'French Cinnamon Toast','Omelets & Snacks','Garnished with mini fruit.',12000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Eggs and Toast','Omelets & Snacks','Two eggs cooked to your style with home fries.',12000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Mushroom and Cheese Omelet','Omelets & Snacks','Savory mushroom and cheddar, topped with a grilled tomato.',15000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Mexican Omelet','Omelets & Snacks','Mushroom, green pepper, cheese, tomato and green chili.',15000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Spanish Omelet','Omelets & Snacks','Traditional egg with red onion, mushroom, green pepper and tomatoes.',15000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Bacon Cheese Omelet','Omelets & Snacks','Crunchy bacon in three eggs, infused with cheese and a touch of pepper spice.',18000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Avocado with an Egg','Omelets & Snacks','Avocado with an egg and toasted bread, with a garnish.',15000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Yummy Chicken Omelet','Omelets & Snacks','Diced chicken with a hint of cheese, infused with onions and tomatoes.',17000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Chicken Gizzards','Omelets & Snacks','Boiled, fried and finished in homemade tomato sauce. Served with chips.',18000,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Fish Fingers','Omelets & Snacks','Tender breaded fish, served with tartar sauce.',25000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Chicken Wings with Chips','Omelets & Snacks','Eight fried winglets tossed in tomato sauce, served with chips.',28000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Chicken Lollipops with Chips','Omelets & Snacks','Crispy fried chicken lollipops, served with chips.',30000,NULL,12,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Mushroom Fries','Omelets & Snacks','Crispy chips tossed in brown mushroom sauce.',12000,NULL,13,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Plain Chips with Garnish','Omelets & Snacks','Plain chips with a garnish.',10000,NULL,14,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Masala Chips','Omelets & Snacks','Chips tossed in hot or mild Indian spices, tomato sauce and coriander leaves.',15000,NULL,15,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Bacon Cheese Fries','Omelets & Snacks','Diced bacon, spring onions and tomato sauce, tossed with chips and finished with cheese.',22000,NULL,16,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Chapatti Plain','Omelets & Snacks','A plain hand rolled chapatti.',6000,NULL,17,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Vegetable Spring Rolls','Omelets & Snacks','Vegetable spring rolls.',5000,NULL,18,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Pair of Chicken Spring Rolls','Omelets & Snacks','Two chicken spring rolls.',6000,NULL,19,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Trio of Samosas (Beef)','Omelets & Snacks','Three pieces of beef samosas.',5000,NULL,20,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Trio of Samosas (Vegetable)','Omelets & Snacks','Three pieces of vegetable samosas.',5000,NULL,21,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks' ORDER BY id LIMIT 1),'Chicken Samosas (Pair)','Omelets & Snacks',NULL,5000,NULL,22,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Sandwiches
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Sandwiches','The sandwich corner','All sandwiches come with chips or salad.',NULL,4,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches' ORDER BY id LIMIT 1),'Tomato, Cheese & Avocado Sandwich','Sandwiches','Grated cheddar cheese, tomatoes, lettuce and avocado on whole wheat, white bread or French loaf.',18000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches' ORDER BY id LIMIT 1),'Pulled Pork Sandwich','Sandwiches','Pork flakes in mayo or sweet chili sauce, lettuce, brown onions, tomatoes and cucumber pickles.',24000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches' ORDER BY id LIMIT 1),'Chicken Salad Sandwich','Sandwiches','Chicken with mayo, lettuce, onions, celery and tomatoes on a three decker toast.',24000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches' ORDER BY id LIMIT 1),'Classic BLT Sandwich','Sandwiches','A three decker bacon, lettuce and tomato sandwich.',25000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches' ORDER BY id LIMIT 1),'Steak Cheese Sandwich','Sandwiches','Tender steak with cheese, tomato and lettuce.',25000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches' ORDER BY id LIMIT 1),'BBQ Beef Sandwich','Sandwiches','Beef strips sautéed with vegetables, onions, bell pepper and mushroom in tangy BBQ sauce.',25000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches' ORDER BY id LIMIT 1),'Tuna Melt Sandwich','Sandwiches','Tuna chunks with mayo, red onions, tomatoes and lettuce.',25000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches' ORDER BY id LIMIT 1),'Paradise Club Sandwich','Sandwiches','A triple decker sandwich with sliced grilled beef, chicken breast, bacon, cheese, onions and mayo.',30000,NULL,8,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Burgers
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Burgers','The grill','Burgers can be served with chips and salad.',NULL,5,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers' ORDER BY id LIMIT 1),'BBQ Burger','Burgers','A grilled beef or chicken patty finished in a tangy BBQ sauce.',27000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers' ORDER BY id LIMIT 1),'Chicken Burger','Burgers','A grilled regular or Cajun chicken patty with lettuce, onions, tomatoes and chili mayo.',25000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers' ORDER BY id LIMIT 1),'Beef Burger','Burgers','A grilled regular or Cajun beef patty with lettuce, onions, tomatoes and chili mayo.',25000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers' ORDER BY id LIMIT 1),'Vegetable Burger','Burgers','A crumbed fried vegetable patty with tomatoes, lettuce, onions and chili mayo.',20000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers' ORDER BY id LIMIT 1),'Mushroom & Cheese Burger','Burgers','A grilled beef patty topped with melted cheese and a creamy mushroom sauce.',22000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers' ORDER BY id LIMIT 1),'King Burger','Burgers','A double patty with bacon, cheese, caramelized onions, lettuce, pickles and tomato.',35000,NULL,6,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Rolex Wraps & Burritos
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Rolex Wraps & Burritos','Rolled to order','Warm tortillas, filled as you like them.',NULL,6,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos' ORDER BY id LIMIT 1),'Crunchy Vegetable Wrap','Rolex Wraps & Burritos','Sautéed vegetables and lettuce with cheddar cheese, wrapped in a plain tortilla.',14000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos' ORDER BY id LIMIT 1),'Beef Rolex','Rolex Wraps & Burritos','A combination of eggs, beef, red onions, tomatoes and green pepper.',15000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos' ORDER BY id LIMIT 1),'Chicken Rolex','Rolex Wraps & Burritos','A combination of three eggs, grilled chicken cubes, red onions, tomatoes and green pepper.',15000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos' ORDER BY id LIMIT 1),'Chicken Wrap','Rolex Wraps & Burritos','Crispy lettuce, shredded chicken, onions, tomatoes and avocado, in mayo or sweet chili, wrapped in a tortilla.',20000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos' ORDER BY id LIMIT 1),'Classic BLT Wrap','Rolex Wraps & Burritos','Crispy bacon, lettuce and tomatoes in a tortilla.',17000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos' ORDER BY id LIMIT 1),'Chicken / Beef Burrito','Rolex Wraps & Burritos','Grilled tender strips with white onions wrapped in a tortilla, topped with cheese and served with guacamole.',27000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos' ORDER BY id LIMIT 1),'Fajita Chicken / Beef','Rolex Wraps & Burritos','Sautéed with coriander, onions and oyster sauce. Your choice of tortilla or sizzler plate, served with rice.',30000,NULL,7,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Fisherman's Offer
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Fisherman''s Offer','Fresh from the Nile','Tilapia and Nile perch, grilled, poached, crumbed or steamed.',NULL,7,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Fish Florentine','Fisherman''s Offer','Grilled tilapia fillet with creamy spinach and cheese.',32000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Poached Fish','Fisherman''s Offer','Tilapia fillet gently cooked in rich fish stock with fresh mushrooms and potatoes.',30000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Mombasa Fish','Fisherman''s Offer','A tilapia fillet crumbed with coconut and fried to perfection.',32000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Catch of the Day (Nile Perch)','Fisherman''s Offer','Pan grilled Nile perch fillet.',32000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Deep Fried Fish Fillet','Fisherman''s Offer','A coated tilapia fish fillet.',32000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Pan Grilled Fish Fillet','Fisherman''s Offer','A coated tilapia fish fillet.',32000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Fish Fingers with Chips','Fisherman''s Offer','Fish fingers served with chips.',30000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Paradise Rustica Fish','Fisherman''s Offer','Grilled tilapia fillet layered on guacamole and salsa with hot chili, rustica sauce and black olives.',32000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Medium Fried Tilapia','Fisherman''s Offer','Medium fried tilapia served with chips.',38000,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Medium Steamed Tilapia','Fisherman''s Offer','Medium steamed tilapia served with chips.',38000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Premium Wet Fried Tilapia','Fisherman''s Offer','Premium wet fried tilapia.',40000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Premium Whole Fish','Fisherman''s Offer','Steamed or fried whole fish.',37000,NULL,12,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Grilled Premium Fish','Fisherman''s Offer','Whole oven grilled oil free premium tilapia.',43000,NULL,13,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Large Fried Tilapia','Fisherman''s Offer','Large fried tilapia served with chips.',43000,NULL,14,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Large Steamed Tilapia','Fisherman''s Offer','Large steamed tilapia served with chips.',43000,NULL,15,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'King Wet Fried Tilapia','Fisherman''s Offer','King wet fried tilapia.',45000,NULL,16,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'King Size Whole Fish','Fisherman''s Offer','A fish fillet, English, grilled or crumbed, on spinach drizzled with mushroom sauce.',42000,NULL,17,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Grilled King Fish','Fisherman''s Offer','Whole oven grilled oil free king tilapia.',48000,NULL,18,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Fried King Prawns','Fisherman''s Offer','King prawns prepared in a seasoned butter sauce.',45000,NULL,19,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer' ORDER BY id LIMIT 1),'Golden Grilled Salmon','Fisherman''s Offer','Grilled salmon on a bed of spinach, laced with white mushroom sauce.',45000,NULL,20,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- House Specials & Platters
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','House Specials & Platters','For the table','Platters built for sharing, with a side of your choice.',NULL,8,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='House Specials & Platters' ORDER BY id LIMIT 1),'Mixed Grill Platter','House Specials & Platters','A platter for two with grilled chicken, beef muchomo, roasted goat, a pair of sausages and a choice of side.',80000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='House Specials & Platters' ORDER BY id LIMIT 1),'Paradise Lusaniya','House Specials & Platters','A family platter for three to four: grilled chicken, beef steak, goat muchomo, brown pilau, matooke or wedges.',100000,NULL,2,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Chicken Dishes
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Chicken Dishes','Poultry','Marinated overnight, then grilled, pan fried or tossed in sauce.',NULL,9,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Dishes' ORDER BY id LIMIT 1),'Chicken Sauté','Chicken Dishes','Sautéed chicken with brown mushroom and spring onions, served with mushroom sauce.',30000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Dishes' ORDER BY id LIMIT 1),'BBQ Chicken Drumstick','Chicken Dishes','Three well marinated chicken drumsticks, fried and tossed in BBQ sauce with fresh Dania.',30000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Dishes' ORDER BY id LIMIT 1),'Grilled Quarter Chicken (Breast)','Chicken Dishes','Well marinated charcoal or oven roasted tender chicken breast.',30000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Dishes' ORDER BY id LIMIT 1),'Grilled Quarter Chicken (Thigh)','Chicken Dishes','Well marinated charcoal or oven roasted tender chicken thigh.',30000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Dishes' ORDER BY id LIMIT 1),'Mushroom Chicken','Chicken Dishes','Pan fried chicken cubes infused in a creamy white mushroom sauce and spring onions.',32000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Dishes' ORDER BY id LIMIT 1),'Supreme Chicken','Chicken Dishes','Fresh pan fried boneless chicken breast in mushroom sauce.',32000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Dishes' ORDER BY id LIMIT 1),'Paradise Grilled Farm Chicken','Chicken Dishes','A well marinated chicken grilled to perfection with aromatic seasonings.',45000,NULL,7,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Beef & Goat Main Courses
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Beef & Goat Main Courses','Steaks and grills','Prime beef fillet, tender goat and the hunter’s favourites.',NULL,10,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'Goat Sizzler','Beef & Goat Main Courses','Stir fried dry goat flakes with vegetables and rosemary.',27000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'Goat Muchomo','Beef & Goat Main Courses','Well marinated chunks of goat roasted and tossed in fresh vegetables, tomato and BBQ sauce.',30000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'Beef Stir Fry','Beef & Goat Main Courses','Tender beef strips grilled with vegetables and a hint of tomato sauce.',35000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'Beef Wet Fry','Beef & Goat Main Courses','Tender well seasoned beef fillet infused in a black peppercorn sauce.',35000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'Honey Glazed Hawaiian Beef Skewers','Beef & Goat Main Courses','Three beef skewers with pineapple, vegetables, natural honey and organic herbs.',35000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'Beef Stroganoff','Beef & Goat Main Courses','Slow cooked beef in a mushroom and red wine sauce, finished with fresh cream.',35000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'Beef in Guinness','Beef & Goat Main Courses','Steak simmered in Guinness beer and a creamy sauce.',30000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'Goat Rack Tender','Beef & Goat Main Courses','Pan fried rib rack.',32000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'Liver Princess','Beef & Goat Main Courses','Flakes of liver toasted with shredded vegetables.',30000,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'Beef Fillet Steak (Pepper Sauce)','Beef & Goat Main Courses','Beef fillet steak in a black peppercorn sauce.',35000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'Beef Fillet Steak (Mushroom Sauce)','Beef & Goat Main Courses','Beef fillet steak in a creamy brown mushroom sauce.',35000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'Beef Fillet Steak (Dry Onion)','Beef & Goat Main Courses','Beef fillet steak with dry onion.',35000,NULL,12,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'King Steak','Beef & Goat Main Courses','Apportioned beef fillet pan fried to preference, topped with a fried egg.',40000,NULL,13,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses' ORDER BY id LIMIT 1),'Paradise Mixed Grill','Beef & Goat Main Courses','A mixture of grills: chicken, steak and fish fillet, topped with a fried egg.',47000,NULL,14,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Pork Courses
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Pork Courses','Pork','Slow roasted, glazed and grilled to your liking.',NULL,11,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork Courses' ORDER BY id LIMIT 1),'Pork Muchomo','Pork Courses','Boneless pork chunks roasted and tossed in aromatic vegetables.',30000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork Courses' ORDER BY id LIMIT 1),'Paradise Grilled Pork Chops','Pork Courses','Perfectly marinated tender pork chops, grilled to satisfaction.',35000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork Courses' ORDER BY id LIMIT 1),'Honey Mustard Glazed Pork Ribs','Pork Courses','Tender and juicy pork ribs tossed in onion rings and honey.',35000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork Courses' ORDER BY id LIMIT 1),'Sweet and Sour Pork','Pork Courses','Well seasoned pork chunks glazed in a tangy sweet and sour sauce with spring onions.',38000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork Courses' ORDER BY id LIMIT 1),'Trio of Pork','Pork Courses','A combination of pork ribs, pork muchomo and pork chops on a single platter.',45000,NULL,5,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Pizzeria
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Pizzeria','Pizza','Baked to order on a stone base. A whole meal on its own, add garlic bread or a salad.',NULL,12,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Classico e Margherita','Pizzeria','Tomato, fresh basil, oregano and mozzarella.',24000,'classic-margherita.jpg',1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Sweet Vegetarian','Pizzeria','Red, yellow and green bell pepper, sweet corn and mozzarella.',24000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Pugliese','Pizzeria','Tomato, black olives, oregano and cheese.',24000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Pata','Pizzeria','Chips, tomato and cheese.',26000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Diavola','Pizzeria','Tomato, chili, salami and mozzarella.',26000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Salami','Pizzeria','Tomato, cheese and salami.',26000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Quattro Stagioni','Pizzeria','Ham, olives, mushroom, artichokes and mozzarella.',26000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Prosciutto Funghi','Pizzeria','Ham, mushroom and cheese.',26000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Prosciutto','Pizzeria','Cooked ham, tomato and mozzarella.',27000,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Bolognaise','Pizzeria','Spicy minced meat, mozzarella and tomato.',27000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Capricciosa','Pizzeria','Black olives, artichokes, capers, mushroom and salad.',27000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Pepperoni','Pizzeria','Tomato, green pepper, onions, pepperoni and mozzarella.',27000,NULL,12,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Hawaiian','Pizzeria','Ham or bacon, pineapple and mozzarella.',27000,NULL,13,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Pollo Pizza','Pizzeria','Italian chicken pizza with green pepper, onions and mushroom.',27000,NULL,14,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Tuna','Pizzeria','Tuna, tomato, onions, green pepper and mozzarella, topped with a boiled egg.',28000,NULL,15,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Calzone Pizza','Pizzeria','Minced meat, carrots and green pepper, folded into a semi circular bread shape.',30000,NULL,16,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Farmer''s Pizza','Pizzeria','Chicken and mushroom.',30000,NULL,17,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria' ORDER BY id LIMIT 1),'Paradise Special Pizza','Pizzeria','Minced meat, salami, ham, mushroom, green pepper and onions.',35000,NULL,18,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Italian Pastas
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Italian Pastas','From Napoli','Pasta choices: spaghetti, penne, fettuccine, farfalle or spirulina.',NULL,13,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Pastas' ORDER BY id LIMIT 1),'Pasta Arabiata','Italian Pastas','Pasta in a tomato and fresh chili sauce, topped with cheese.',20000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Pastas' ORDER BY id LIMIT 1),'Pasta a la Napolitana','Italian Pastas','Pasta in herby tomato and cheese sauce.',18000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Pastas' ORDER BY id LIMIT 1),'Pasta Genovese','Italian Pastas','Pasta in pesto sauce.',22000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Pastas' ORDER BY id LIMIT 1),'Pasta a la Carbonara','Italian Pastas','Pasta with egg and bacon in a creamy sauce, topped with cheese.',25000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Pastas' ORDER BY id LIMIT 1),'Pasta Classic Bolognaise','Italian Pastas','Pasta in a minced meat, garlic, tomato and red wine sauce, topped with cheese.',25000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Pastas' ORDER BY id LIMIT 1),'Pasta ala Cavolfiore e Salsiccia','Italian Pastas','Pasta with cauliflower and sausage in an egg and bacon creamy sauce.',22000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Pastas' ORDER BY id LIMIT 1),'Pasta a la Contadina','Italian Pastas','Pasta in chicken, garlic, coriander, white wine and a creamy coconut sauce.',25000,NULL,7,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Asian & Indian Curries
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Asian & Indian Curries','Far East and sub continent','Non veg curries are served with a choice of 1 or 2 accompaniments.',NULL,14,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Aloo Mutter','Asian & Indian Curries','Diced potatoes and cowpeas prepared in a creamy sauce.',18000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Mixed Vegetable Curry','Asian & Indian Curries','Assorted vegetables in a creamy sauce, served with white rice or mash.',20000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Veggie Biryani','Asian & Indian Curries','Diced mixed vegetables in a creamy curry sauce, mixed with rice.',25000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Vegetable Chow Mein','Asian & Indian Curries','Noodles with oyster and soy sauce, tossed with fresh vegetables.',20000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Vegetable Korma','Asian & Indian Curries','Mixed vegetables in a mild creamy almond and cashew nut sauce.',25000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Chicken Tikka','Asian & Indian Curries',NULL,28000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Chili Chicken','Asian & Indian Curries',NULL,28000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Chicken Biryani','Asian & Indian Curries','Cubes of chicken cooked in a creamy sauce, mixed with rice.',32000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Fish Biryani','Asian & Indian Curries','Cubes of fish cooked in a creamy sauce, mixed with rice.',32000,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Goat Biryani','Asian & Indian Curries','Cubes of goat cooked in a creamy sauce, mixed with rice.',32000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Chicken Coconut Curry','Asian & Indian Curries','Grilled and cubed boneless chicken in a golden sauce infused with coconut.',32000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Chicken Tikka Masala','Asian & Indian Curries',NULL,30000,NULL,12,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Chicken Makhani','Asian & Indian Curries','Boneless tandoori marinated chicken cooked in butter and tomato gravy.',30000,NULL,13,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Fish Curry Diamond','Asian & Indian Curries',NULL,30000,NULL,14,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Fish Tikka','Asian & Indian Curries',NULL,30000,NULL,15,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Fish Tikka Masala','Asian & Indian Curries',NULL,32000,NULL,16,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Half Tandoori Chicken','Asian & Indian Curries','Chicken marinated with yogurt, ginger, garlic and spices, roasted in a clay oven.',37000,NULL,17,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries' ORDER BY id LIMIT 1),'Full Tandoori Chicken','Asian & Indian Curries','A full chicken marinated with yogurt, ginger, garlic and spices, roasted in a clay oven.',47000,NULL,18,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Chinese Corner
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Chinese Corner','Wok and steam','Sizzling plates, deep fried bites and the full sweet and sour house.',NULL,15,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Vegetable Spring Roll (1pc)','Chinese Corner',NULL,1000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Chicken Spring Roll (1pc)','Chinese Corner',NULL,2500,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Pork Spring Roll (1pc)','Chinese Corner',NULL,2500,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Vegetable Wanton','Chinese Corner',NULL,5000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Special Chicken Wings (1pc)','Chinese Corner',NULL,7000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried Wanton (Chicken or Beef)','Chinese Corner',NULL,8000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Golden Fried Cauliflower','Chinese Corner',NULL,10000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried Chips Plain','Chinese Corner',NULL,10000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Special Beef Simsim','Chinese Corner',NULL,15000,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Smoked Fish','Chinese Corner',NULL,15000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Salty Chicken / Beef','Chinese Corner',NULL,15000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Foil Wrapped Chicken','Chinese Corner',NULL,15000,NULL,12,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'French Fries with Garlic Sauce','Chinese Corner',NULL,15000,NULL,13,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried Egg Rolled Chicken (Pair)','Chinese Corner',NULL,18000,NULL,14,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried Chicken Wings','Chinese Corner',NULL,20000,NULL,15,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Crispy Chicken Legs','Chinese Corner',NULL,20000,NULL,16,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Golden Fried Prawns','Chinese Corner',NULL,20000,NULL,17,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried Baby Corn with Cashew Nuts','Chinese Corner',NULL,20000,NULL,18,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried Summary Chicken','Chinese Corner',NULL,25000,NULL,19,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sauté Chicken Sichuan Style','Chinese Corner',NULL,25000,NULL,20,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Chicken Curry','Chinese Corner',NULL,25000,NULL,21,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried French Beans with Garlic Sauce','Chinese Corner',NULL,25000,NULL,22,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Chinese Cabbage Sichuan Style (Hot)','Chinese Corner',NULL,25000,NULL,23,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Mixed Vegetables (Onions, Cabbage, Carrots, Pepper, Mushroom)','Chinese Corner',NULL,25000,NULL,24,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Stir-Fried Chicken with Cashew Nuts','Chinese Corner',NULL,30000,NULL,25,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Spicy Half Chicken with Vegetables','Chinese Corner',NULL,30000,NULL,26,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried Chicken with Chinese Black Bean Sauce','Chinese Corner',NULL,30000,NULL,27,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sweet and Sour Chicken','Chinese Corner',NULL,30000,NULL,28,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sliced Chicken with Garlic Sauce','Chinese Corner',NULL,30000,NULL,29,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sliced Beef with Chinese Cabbage','Chinese Corner',NULL,30000,NULL,30,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Shredded Beef with Onions','Chinese Corner',NULL,30000,NULL,31,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sweet and Sour Beef','Chinese Corner',NULL,30000,NULL,32,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sliced Beef in Oyster Sauce','Chinese Corner',NULL,30000,NULL,33,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Shredded Beef with Vegetables','Chinese Corner',NULL,30000,NULL,34,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sliced Beef with Pineapple Sauce','Chinese Corner',NULL,30000,NULL,35,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Beef Curry','Chinese Corner',NULL,30000,NULL,36,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sweet and Sour Pork (Chinese)','Chinese Corner',NULL,30000,NULL,37,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Shredded Pork with Green Pepper','Chinese Corner',NULL,30000,NULL,38,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sauté Pork Sichuan Style (Hot)','Chinese Corner',NULL,30000,NULL,39,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Spicy Pork with Garlic Sauce','Chinese Corner',NULL,30000,NULL,40,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sweet and Sour Fish Finger','Chinese Corner',NULL,30000,NULL,41,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Spicy Fish with Ginger & Garlic Sauce','Chinese Corner',NULL,30000,NULL,42,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sliced Fish with Vegetables','Chinese Corner',NULL,30000,NULL,43,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sliced Fish in Special Hot Sweet & Sour Sauce','Chinese Corner',NULL,30000,NULL,44,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Special Mixed Vegetables & Sprouts','Chinese Corner',NULL,30000,NULL,45,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried Mixed Chicken, Beef & Goat Meat','Chinese Corner',NULL,35000,NULL,46,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried Shredded Chicken with Bamboo Shoots','Chinese Corner',NULL,35000,NULL,47,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sliced Pork with Mushroom and Bamboo Shoots','Chinese Corner',NULL,35000,NULL,48,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried Beijing Duck with Vegetables','Chinese Corner',NULL,35000,NULL,49,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried Duck with Bamboo Shoots','Chinese Corner',NULL,35000,NULL,50,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried Prawns with Cashew Nuts','Chinese Corner',NULL,45000,NULL,51,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Sauté Prawns with Black Bean Sauce','Chinese Corner',NULL,45000,NULL,52,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Fried Prawns with Chinese Black Beans','Chinese Corner',NULL,50000,NULL,53,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner' ORDER BY id LIMIT 1),'Beijing Roasted Duck (Whole)','Chinese Corner',NULL,100000,NULL,54,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Sizzler Hot Plates
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Sizzler Hot Plates','On a hot plate','Brought to the table on a sizzling iron, with rice.',NULL,16,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sizzler Hot Plates' ORDER BY id LIMIT 1),'Sizzler Vegetables Plate','Sizzler Hot Plates',NULL,30000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sizzler Hot Plates' ORDER BY id LIMIT 1),'Sizzler Pork Plate','Sizzler Hot Plates',NULL,35000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sizzler Hot Plates' ORDER BY id LIMIT 1),'Sizzler Beef Plate','Sizzler Hot Plates',NULL,35000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sizzler Hot Plates' ORDER BY id LIMIT 1),'Sizzler Chicken Plate','Sizzler Hot Plates',NULL,35000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sizzler Hot Plates' ORDER BY id LIMIT 1),'Sizzler Shrimps / Prawns Plate','Sizzler Hot Plates',NULL,50000,NULL,5,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Rice & Noodles
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Rice & Noodles','Side options','Everything to round off a main course.',NULL,17,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles' ORDER BY id LIMIT 1),'Steamed Rice','Rice & Noodles',NULL,8000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles' ORDER BY id LIMIT 1),'Fried Rice','Rice & Noodles',NULL,8000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles' ORDER BY id LIMIT 1),'Ginger Fried Rice','Rice & Noodles',NULL,8000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles' ORDER BY id LIMIT 1),'Vegetable Fried Rice','Rice & Noodles',NULL,10000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles' ORDER BY id LIMIT 1),'Vegetable Fried Noodles','Rice & Noodles',NULL,12000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles' ORDER BY id LIMIT 1),'Egg Fried Rice','Rice & Noodles',NULL,15000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles' ORDER BY id LIMIT 1),'Chicken Fried Rice','Rice & Noodles',NULL,25000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles' ORDER BY id LIMIT 1),'Chicken / Beef / Pork Fried Noodles','Rice & Noodles',NULL,25000,NULL,8,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Accompaniments & Extras
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Accompaniments & Extras','Side add ons','Added to any main course, priced per portion.',NULL,18,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Accompaniments & Extras' ORDER BY id LIMIT 1),'Extra Mushroom','Accompaniments & Extras',NULL,4000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Accompaniments & Extras' ORDER BY id LIMIT 1),'Extra Avocado','Accompaniments & Extras',NULL,4000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Accompaniments & Extras' ORDER BY id LIMIT 1),'Extra Fried Egg','Accompaniments & Extras',NULL,4000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Accompaniments & Extras' ORDER BY id LIMIT 1),'Extra Bacon','Accompaniments & Extras',NULL,7000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Accompaniments & Extras' ORDER BY id LIMIT 1),'Extra Cheese','Accompaniments & Extras',NULL,7000,NULL,5,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Desserts & Bakery
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Desserts & Bakery','Sweet finish','Cakes, pastries and fruit from our own bakery.',NULL,19,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Cookies','Desserts & Bakery',NULL,1000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Croissant','Desserts & Bakery',NULL,2000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Beef / Chicken Pie','Desserts & Bakery',NULL,5000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Sausage Roll','Desserts & Bakery',NULL,5000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Bread Loaf','Desserts & Bakery',NULL,6000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Marble Cake Slice','Desserts & Bakery',NULL,7000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Chocolate Cake Slice','Desserts & Bakery',NULL,7000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Strawberry Cake Slice','Desserts & Bakery',NULL,7000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Lemon Cake Slice','Desserts & Bakery',NULL,7000,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Vanilla Cake Slice','Desserts & Bakery',NULL,7000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Butter Bread','Desserts & Bakery',NULL,7000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'French Bread','Desserts & Bakery',NULL,7000,NULL,12,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Cinnamon Roll','Desserts & Bakery',NULL,8000,NULL,13,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Ice Cream (3 Scoops)','Desserts & Bakery','A bowl of three scoops, with a choice of chocolate, vanilla or strawberry.',9000,NULL,14,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Golden Fried Banana','Desserts & Bakery',NULL,10000,NULL,15,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Banana Crepe','Desserts & Bakery','A thin pancake filled with sliced bananas and chocolate syrup, garnished with orange slices.',15000,NULL,16,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Affogato / Espresso Ice Cream','Desserts & Bakery','Two scoops of ice cream of choice served with 60ml of espresso coffee.',15000,NULL,17,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Special Banana with Honey Sauce','Desserts & Bakery',NULL,12000,NULL,18,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Pineapple Upside-Down Cake','Desserts & Bakery',NULL,14000,NULL,19,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Tropical Fruit Platter','Desserts & Bakery','A presentation of fresh seasonal fruit: mango, pineapple, melon, orange, grapes and passion fruit.',15000,NULL,20,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Fruit Salad','Desserts & Bakery','A combination of cubed fresh fruit sprinkled with passion fruit syrup.',15000,NULL,21,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Lemon Tart','Desserts & Bakery',NULL,15000,NULL,22,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Banana Split','Desserts & Bakery','Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.',15000,NULL,23,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Mango Tart','Desserts & Bakery',NULL,16000,NULL,24,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'White Forest Cake','Desserts & Bakery',NULL,16000,NULL,25,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Profiteroles','Desserts & Bakery',NULL,16000,NULL,26,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Chocolate Fudge Slice','Desserts & Bakery',NULL,17000,NULL,27,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Black Forest Cake (pc)','Desserts & Bakery',NULL,17000,NULL,28,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Classic Carrot Cake','Desserts & Bakery',NULL,19000,NULL,29,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery' ORDER BY id LIMIT 1),'Chocolate Mousse','Desserts & Bakery',NULL,20000,NULL,30,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Restaurant rows this file used to publish and no longer does. Only the
-- restaurant outlet is touched: the bar and room service menus are the
-- hotel's own and are left alone.
UPDATE menu_items SET published = 0
WHERE hotel_id = 1 AND published = 1 AND name NOT IN ('Mixed Garden Salad','Greek Salad','Avocado & Lettuce Salad','Tuna Salad','Chicken Oriental Salad','Caesar Salad','Chef Salad','Grilled Vegetables Salad','Grilled Chicken Salad','Mushroom Soup','Clear Vegetable Broth','Cream of Tomato Soup','Ginger Carrot Soup','Clear Beef Noodle Soup','Clear Chicken Noodle Soup','French Cinnamon Toast','Eggs and Toast','Mushroom and Cheese Omelet','Mexican Omelet','Spanish Omelet','Bacon Cheese Omelet','Avocado with an Egg','Yummy Chicken Omelet','Chicken Gizzards','Fish Fingers','Chicken Wings with Chips','Chicken Lollipops with Chips','Mushroom Fries','Plain Chips with Garnish','Masala Chips','Bacon Cheese Fries','Chapatti Plain','Vegetable Spring Rolls','Pair of Chicken Spring Rolls','Trio of Samosas (Beef)','Trio of Samosas (Vegetable)','Chicken Samosas (Pair)','Tomato, Cheese & Avocado Sandwich','Pulled Pork Sandwich','Chicken Salad Sandwich','Classic BLT Sandwich','Steak Cheese Sandwich','BBQ Beef Sandwich','Tuna Melt Sandwich','Paradise Club Sandwich','BBQ Burger','Chicken Burger','Beef Burger','Vegetable Burger','Mushroom & Cheese Burger','King Burger','Crunchy Vegetable Wrap','Beef Rolex','Chicken Rolex','Chicken Wrap','Classic BLT Wrap','Chicken / Beef Burrito','Fajita Chicken / Beef','Fish Florentine','Poached Fish','Mombasa Fish','Catch of the Day (Nile Perch)','Deep Fried Fish Fillet','Pan Grilled Fish Fillet','Fish Fingers with Chips','Paradise Rustica Fish','Medium Fried Tilapia','Medium Steamed Tilapia','Premium Wet Fried Tilapia','Premium Whole Fish','Grilled Premium Fish','Large Fried Tilapia','Large Steamed Tilapia','King Wet Fried Tilapia','King Size Whole Fish','Grilled King Fish','Fried King Prawns','Golden Grilled Salmon','Mixed Grill Platter','Paradise Lusaniya','Chicken Sauté','BBQ Chicken Drumstick','Grilled Quarter Chicken (Breast)','Grilled Quarter Chicken (Thigh)','Mushroom Chicken','Supreme Chicken','Paradise Grilled Farm Chicken','Goat Sizzler','Goat Muchomo','Beef Stir Fry','Beef Wet Fry','Honey Glazed Hawaiian Beef Skewers','Beef Stroganoff','Beef in Guinness','Goat Rack Tender','Liver Princess','Beef Fillet Steak (Pepper Sauce)','Beef Fillet Steak (Mushroom Sauce)','Beef Fillet Steak (Dry Onion)','King Steak','Paradise Mixed Grill','Pork Muchomo','Paradise Grilled Pork Chops','Honey Mustard Glazed Pork Ribs','Sweet and Sour Pork','Trio of Pork','Classico e Margherita','Sweet Vegetarian','Pugliese','Pata','Diavola','Salami','Quattro Stagioni','Prosciutto Funghi','Prosciutto','Bolognaise','Capricciosa','Pepperoni','Hawaiian','Pollo Pizza','Tuna','Calzone Pizza','Farmer''s Pizza','Paradise Special Pizza','Pasta Arabiata','Pasta a la Napolitana','Pasta Genovese','Pasta a la Carbonara','Pasta Classic Bolognaise','Pasta ala Cavolfiore e Salsiccia','Pasta a la Contadina','Aloo Mutter','Mixed Vegetable Curry','Veggie Biryani','Vegetable Chow Mein','Vegetable Korma','Chicken Tikka','Chili Chicken','Chicken Biryani','Fish Biryani','Goat Biryani','Chicken Coconut Curry','Chicken Tikka Masala','Chicken Makhani','Fish Curry Diamond','Fish Tikka','Fish Tikka Masala','Half Tandoori Chicken','Full Tandoori Chicken','Vegetable Spring Roll (1pc)','Chicken Spring Roll (1pc)','Pork Spring Roll (1pc)','Vegetable Wanton','Special Chicken Wings (1pc)','Fried Wanton (Chicken or Beef)','Golden Fried Cauliflower','Fried Chips Plain','Special Beef Simsim','Smoked Fish','Salty Chicken / Beef','Foil Wrapped Chicken','French Fries with Garlic Sauce','Fried Egg Rolled Chicken (Pair)','Fried Chicken Wings','Crispy Chicken Legs','Golden Fried Prawns','Fried Baby Corn with Cashew Nuts','Fried Summary Chicken','Sauté Chicken Sichuan Style','Chicken Curry','Fried French Beans with Garlic Sauce','Chinese Cabbage Sichuan Style (Hot)','Mixed Vegetables (Onions, Cabbage, Carrots, Pepper, Mushroom)','Stir-Fried Chicken with Cashew Nuts','Spicy Half Chicken with Vegetables','Fried Chicken with Chinese Black Bean Sauce','Sweet and Sour Chicken','Sliced Chicken with Garlic Sauce','Sliced Beef with Chinese Cabbage','Shredded Beef with Onions','Sweet and Sour Beef','Sliced Beef in Oyster Sauce','Shredded Beef with Vegetables','Sliced Beef with Pineapple Sauce','Beef Curry','Sweet and Sour Pork (Chinese)','Shredded Pork with Green Pepper','Sauté Pork Sichuan Style (Hot)','Spicy Pork with Garlic Sauce','Sweet and Sour Fish Finger','Spicy Fish with Ginger & Garlic Sauce','Sliced Fish with Vegetables','Sliced Fish in Special Hot Sweet & Sour Sauce','Special Mixed Vegetables & Sprouts','Fried Mixed Chicken, Beef & Goat Meat','Fried Shredded Chicken with Bamboo Shoots','Sliced Pork with Mushroom and Bamboo Shoots','Fried Beijing Duck with Vegetables','Fried Duck with Bamboo Shoots','Fried Prawns with Cashew Nuts','Sauté Prawns with Black Bean Sauce','Fried Prawns with Chinese Black Beans','Beijing Roasted Duck (Whole)','Sizzler Vegetables Plate','Sizzler Pork Plate','Sizzler Beef Plate','Sizzler Chicken Plate','Sizzler Shrimps / Prawns Plate','Steamed Rice','Fried Rice','Ginger Fried Rice','Vegetable Fried Rice','Vegetable Fried Noodles','Egg Fried Rice','Chicken Fried Rice','Chicken / Beef / Pork Fried Noodles','Extra Mushroom','Extra Avocado','Extra Fried Egg','Extra Bacon','Extra Cheese','Cookies','Croissant','Beef / Chicken Pie','Sausage Roll','Bread Loaf','Marble Cake Slice','Chocolate Cake Slice','Strawberry Cake Slice','Lemon Cake Slice','Vanilla Cake Slice','Butter Bread','French Bread','Cinnamon Roll','Ice Cream (3 Scoops)','Golden Fried Banana','Banana Crepe','Affogato / Espresso Ice Cream','Special Banana with Honey Sauce','Pineapple Upside-Down Cake','Tropical Fruit Platter','Fruit Salad','Lemon Tart','Banana Split','Mango Tart','White Forest Cake','Profiteroles','Chocolate Fudge Slice','Black Forest Cake (pc)','Classic Carrot Cake','Chocolate Mousse')
  AND category_id IN (SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' ORDER BY id LIMIT 1);

UPDATE menu_categories SET published = 0
WHERE hotel_id = 1 AND outlet='restaurant' AND published = 1 AND name NOT IN ('Starters & Salads','Soups','Omelets & Snacks','Sandwiches','Burgers','Rolex Wraps & Burritos','Fisherman''s Offer','House Specials & Platters','Chicken Dishes','Beef & Goat Main Courses','Pork Courses','Pizzeria','Italian Pastas','Asian & Indian Curries','Chinese Corner','Sizzler Hot Plates','Rice & Noodles','Accompaniments & Extras','Desserts & Bakery');

-- What the website will now publish. These are the numbers that matter: a
-- section the guest can open but not order from, or a dish published under no
-- section at all, is a broken menu and shows up here.
SELECT COUNT(*) AS published_sections
  FROM menu_categories c
 WHERE c.hotel_id = 1 AND c.published = 1
   AND EXISTS (SELECT 1 FROM menu_items i WHERE i.category_id = c.id AND i.published = 1);

SELECT COUNT(*) AS published_dishes,
       SUM(price IS NULL) AS priced_on_request,
       COUNT(DISTINCT category_id) AS sections_covered
  FROM menu_items WHERE hotel_id = 1 AND published = 1;

-- Must both be zero. A published dish in no published section cannot be ordered.
SELECT COUNT(*) AS published_dish_with_no_section
  FROM menu_items i
  LEFT JOIN menu_categories c ON c.id = i.category_id
 WHERE i.hotel_id = 1 AND i.published = 1
   AND (c.id IS NULL OR c.published = 0);

-- Must be zero. A published section with nothing in it opens to a blank list.
SELECT COUNT(*) AS published_section_with_no_dish
  FROM menu_categories c
 WHERE c.hotel_id = 1 AND c.published = 1
   AND NOT EXISTS (SELECT 1 FROM menu_items i WHERE i.category_id = c.id AND i.published = 1);

-- The till's view is untouched by this file. If this changes, the seed has gone
-- outside its own business and taken the hotel's menu with it.
SELECT outlet, SUM(i.active = 1) AS sellable, SUM(i.published = 1) AS on_website
  FROM menu_items i JOIN menu_categories c ON c.id = i.category_id
 WHERE i.hotel_id = 1 GROUP BY outlet;

-- Must be zero. A section name that appears twice means two rows are fighting
-- over one section: the website shows the section, but a dish added under one
-- row is invisible under the other. Only database/01_LIVE_SYSTEM_SCHEMA.sql
-- creates menu_categories with a UNIQUE key, so importing one of the older menu
-- files twice will quietly produce these. Every lookup in this file is written
-- to survive it, but the duplicates themselves still need database/
-- tools/fix-duplicate-menu-categories.sql to clear them.
SELECT name, COUNT(*) AS rows_found
  FROM menu_categories
 WHERE hotel_id = 1 AND outlet = 'restaurant'
 GROUP BY name HAVING COUNT(*) > 1;
