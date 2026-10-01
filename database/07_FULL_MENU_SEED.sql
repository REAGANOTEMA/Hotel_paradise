-- HOTEL PARADISE ON THE NILE - COMPLETE MENU SEED
-- Generated from frontend-react/src/menuData.ts by database/tools/build-menu-seed.mjs
-- Do not hand edit. Re-run the generator instead.
--
-- 19 sections, 225 dishes for hotel 1, every one of them carrying a rate
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads'),'Mixed Garden Salad','Starters & Salads','Mixed lettuce, cucumber, tomatoes, onions and avocado.',12000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads'),'Greek Salad','Starters & Salads','Tomatoes, red onions, cucumber, lettuce, feta cheese, black olives and red cabbage.',15000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads'),'Avocado & Lettuce Salad','Starters & Salads','A well designed platter of lettuce, avocado, onions, cherry tomatoes and carrot shavings, finished with 1,000 Island dressing.',15000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads'),'Tuna Salad','Starters & Salads','White tuna with mayo, boiled eggs, cucumber, celery and tomatoes on a bed of fresh lettuce.',20000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads'),'Chicken Oriental Salad','Starters & Salads','Chicken with mayo, cucumber, pineapple, celery and tomatoes.',20000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads'),'Caesar Salad','Starters & Salads','Grilled chicken cubes, avocado, carrot, lettuce, tomato, croutons and Parmesan cheese shavings.',22000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters & Salads'),'Chef Salad','Starters & Salads','Crunchy lettuce, chicken flakes, beef strips, tomatoes, onions and bell peppers, topped with boiled Irish potatoes and a hard boiled egg.',22000,NULL,7,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Soups'),'Mushroom Soup','Soups','Creamy or clear freshly made forest mushroom, homemade style. Served with a bread roll.',12000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Soups'),'Clear Vegetable Broth','Soups','Fresh homemade vegetable soup, served with a garlic bread roll.',12000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Soups'),'Cream of Tomato Soup','Soups','A puree of tomatoes finished with dairy cream, accompanied with croutons.',12000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Soups'),'Ginger Carrot Soup','Soups','A creamy soup with a hint of ginger and dairy cream, accompanied with toast.',12000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Soups'),'Beef / Chicken Broth','Soups','Clear chicken or beef simmered in aromatic vegetables. Served with a bread roll or toast.',15000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Soups'),'Chicken Noodle Soup','Soups','Aromatic clear soup with julienne chicken, zucchini, carrots, onions and fresh noodles.',15000,NULL,6,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'French Cinnamon Toast','Omelets & Snacks','Garnished with mini fruit.',12000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Eggs and Toast','Omelets & Snacks','Two eggs cooked to your style with home fries.',12000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Mushroom and Cheese Omelet','Omelets & Snacks','Savory mushroom and cheddar, topped with a grilled tomato.',15000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Mexican Omelet','Omelets & Snacks','Mushroom, green pepper, cheese, tomato and green chili.',15000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Spanish Omelet','Omelets & Snacks','Traditional egg with red onion, mushroom, green pepper and tomatoes.',15000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Bacon Cheese Omelet','Omelets & Snacks','Crunchy bacon in three eggs, infused with cheese and a touch of pepper spice.',17000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Yummy Chicken Omelet','Omelets & Snacks','Diced chicken with a hint of cheese, infused with onions and tomatoes.',17000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Chicken Gizzards','Omelets & Snacks','Boiled, fried and finished in homemade tomato sauce. Served with chips.',18000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Fish Fingers','Omelets & Snacks','Tender breaded fish, served with tartar sauce.',25000,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Chicken Wings / Lollipops','Omelets & Snacks','Eight fried winglets in tomato sauce, with your choice of side.',28000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Liver Princess','Omelets & Snacks','Flakes of liver sautéed with shredded vegetables. Served with rice, chips or matooke.',25000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Mushroom Fries','Omelets & Snacks','Crispy chips tossed in brown mushroom sauce.',12000,NULL,12,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Masala Chips','Omelets & Snacks','Chips tossed in hot or mild Indian spices, tomato sauce and coriander leaves.',14000,NULL,13,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Bacon Cheese Fries','Omelets & Snacks','Diced bacon, spring onions and tomato sauce, tossed with chips and finished with cheese.',22000,NULL,14,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Vegetable Spring Rolls (Set)','Omelets & Snacks',NULL,3000,NULL,15,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Beef / Vegetable Samosas (Set)','Omelets & Snacks',NULL,4000,NULL,16,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Chicken Samosas (Pair)','Omelets & Snacks',NULL,5000,NULL,17,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Omelets & Snacks'),'Chicken Spring Rolls (Pair)','Omelets & Snacks',NULL,5000,NULL,18,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches'),'Tomato, Cheese & Avocado Sandwich','Sandwiches','Grated cheddar cheese, tomatoes, lettuce and avocado on whole wheat, white bread or French loaf.',18000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches'),'Pulled Pork Sandwich','Sandwiches','Pork flakes in mayo or sweet chili sauce, lettuce, brown onions, tomatoes and cucumber pickles.',24000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches'),'Chicken Salad Sandwich','Sandwiches','Chicken with mayo, lettuce, onions, celery and tomatoes on a three decker toast.',24000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches'),'Classic BLT Sandwich','Sandwiches','A three decker bacon, lettuce and tomato sandwich.',25000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches'),'Steak Cheese Sandwich','Sandwiches','Tender steak with cheese, tomato and lettuce.',25000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches'),'BBQ Beef Sandwich','Sandwiches','Beef strips sautéed with vegetables, onions, bell pepper and mushroom in tangy BBQ sauce.',25000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches'),'Tuna Melt Sandwich','Sandwiches','Tuna chunks with mayo, red onions, tomatoes and lettuce.',25000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sandwiches'),'Paradise Club Sandwich','Sandwiches','A triple decker sandwich with sliced grilled beef, chicken breast, bacon, cheese, onions and mayo.',27000,NULL,8,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers'),'BBQ Burger','Burgers','A grilled beef or chicken patty finished in a tangy BBQ sauce.',18000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers'),'Chicken Burger','Burgers','A grilled regular or Cajun chicken patty with lettuce, onions, tomatoes and chili mayo.',20000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers'),'Vegetable Burger','Burgers','A crumbed fried vegetable patty with tomatoes, lettuce, onions and chili mayo.',20000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers'),'Mushroom & Cheese Burger','Burgers','A grilled beef patty topped with melted cheese and a creamy mushroom sauce.',22000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers'),'King Burger','Burgers','A double patty with bacon, cheese, caramelized onions, lettuce, pickles and tomato.',27000,NULL,5,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos'),'Crunchy Vegetable Wrap','Rolex Wraps & Burritos','Sautéed vegetables and lettuce with cheddar cheese, wrapped in a plain tortilla.',12000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos'),'Beef Rolex','Rolex Wraps & Burritos','A combination of eggs, beef, red onions, tomatoes and green pepper.',13000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos'),'Chicken Rolex','Rolex Wraps & Burritos','A combination of three eggs, grilled chicken cubes, red onions, tomatoes and green pepper.',14000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos'),'Chicken Wrap','Rolex Wraps & Burritos','Crispy lettuce, shredded chicken, onions, tomatoes and avocado, in mayo or sweet chili, wrapped in a tortilla.',17000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos'),'Classic BLT Wrap','Rolex Wraps & Burritos','Crispy bacon, lettuce and tomatoes in a tortilla.',17000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos'),'Chicken / Beef Burrito','Rolex Wraps & Burritos','Grilled tender strips with white onions wrapped in a tortilla, topped with cheese and served with guacamole.',27000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rolex Wraps & Burritos'),'Fajita Chicken / Beef','Rolex Wraps & Burritos','Sautéed with coriander, onions and oyster sauce. Your choice of tortilla or sizzler plate, served with rice.',30000,NULL,7,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'Fish Florentine','Fisherman''s Offer','Grilled tilapia fillet with creamy spinach and cheese.',30000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'Poached Fish','Fisherman''s Offer','Tilapia fillet gently cooked in rich fish stock with fresh mushrooms and potatoes.',30000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'Mombasa Fish','Fisherman''s Offer','Tilapia fillet crumbed with coconut and fried.',30000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'Catch of the Day (Nile Perch)','Fisherman''s Offer','Fresh Nile perch fillet, grilled to perfection.',30000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'Paradise Rustica Fish','Fisherman''s Offer','Grilled tilapia fillet layered on guacamole and salsa with hot chili, rustica sauce and black olives.',32000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'Premium Whole Fish','Fisherman''s Offer','Steamed or fried whole fish.',37000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'King Size Whole Fish','Fisherman''s Offer','A fish fillet, English, grilled or crumbed, on spinach drizzled with mushroom sauce.',42000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'Fried King Prawns','Fisherman''s Offer','King prawns prepared in a seasoned butter sauce.',45000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'Golden Grilled Salmon','Fisherman''s Offer','Grilled salmon on a bed of spinach, laced with white mushroom sauce.',45000,NULL,9,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='House Specials & Platters'),'Mixed Grill Platter (2 Pax)','House Specials & Platters','A platter for two with grilled chicken, beef muchomo, roasted goat, a pair of sausages and a choice of side.',80000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='House Specials & Platters'),'Paradise Lusaniya (3-4 Pax)','House Specials & Platters','A family platter for three to four: grilled chicken, beef steak, goat muchomo, brown pilau, matooke or wedges.',100000,NULL,2,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Dishes'),'Chicken Sauté','Chicken Dishes','Sautéed chicken with brown mushroom and spring onions, served with mushroom sauce.',27000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Dishes'),'BBQ Chicken Drumsticks','Chicken Dishes','Three marinated chicken drumsticks, fried and tossed in BBQ sauce with fresh Dania.',27000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Dishes'),'Grilled Quarter Chicken','Chicken Dishes','Marinated charcoal grilled tender chicken.',27000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Dishes'),'Mushroom Chicken','Chicken Dishes','Pan fried chicken cubes infused in a creamy white mushroom sauce and spring onions.',27000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Dishes'),'Supreme Chicken','Chicken Dishes','Fresh pan fried chicken breast in mushroom sauce.',28000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Dishes'),'Paradise 1/2 Grilled Farm Chicken','Chicken Dishes','Half a chicken grilled with aromatic seasonings.',40000,NULL,6,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses'),'Goat Sizzler','Beef & Goat Main Courses','Stir fried dry goat flakes with vegetables and rosemary.',27000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses'),'Goat Muchomo','Beef & Goat Main Courses','Marinated goat chunks roasted and tossed in fresh vegetables, tomato and BBQ sauce.',27000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses'),'Beef Stir Fry','Beef & Goat Main Courses','Beef strips grilled with vegetables and tomato sauce.',30000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses'),'Beef Wet Fry','Beef & Goat Main Courses','Seasoned diced beef with assorted vegetables.',30000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses'),'Honey Glazed Hawaiian Beef Skewers','Beef & Goat Main Courses','Three beef skewers with pineapple, vegetables, natural honey and organic herbs.',30000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses'),'Beef Stroganoff','Beef & Goat Main Courses','Slow cooked beef in a mushroom and red wine sauce, finished with fresh cream.',30000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses'),'Beef in Guinness','Beef & Goat Main Courses','Steak simmered in Guinness beer and a creamy sauce.',30000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses'),'Goat Rack Tender','Beef & Goat Main Courses','Pan fried rib rack.',32000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses'),'Mushroom Steak','Beef & Goat Main Courses','Marinated tender beef steak infused in a creamy brown mushroom sauce.',32000,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses'),'Pepper Steak','Beef & Goat Main Courses','Tenderloin of beef fillet infused in black peppercorn sauce.',32000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses'),'King Steak','Beef & Goat Main Courses','Beef fillet pan fried to preference, topped with a fried egg.',32000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Beef & Goat Main Courses'),'Paradise Mixed Grill','Beef & Goat Main Courses','A mixture of grills: chicken, steak and fish fillet, topped with a fried egg.',45000,NULL,12,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork Courses'),'Pork Muchomo','Pork Courses','Boneless pork chunks roasted and tossed in aromatic vegetables.',27000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork Courses'),'Paradise Grilled Pork Chop','Pork Courses','Marinated pork chops, grilled to perfection.',32000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork Courses'),'Honey Mustard Glazed Pork Ribs','Pork Courses','Pork ribs tossed in onion rings and honey.',32000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork Courses'),'Sweet and Sour Pork Chops','Pork Courses','Pork chunks glazed in a sweet and sour sauce with spring onions and a side.',38000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork Courses'),'Trio of Pork Platter','Pork Courses','A combination of pork ribs, pork muchomo and pork chops with a side.',45000,NULL,5,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Classico e Margherita','Pizzeria','Tomato, fresh basil, oregano and mozzarella.',24000,'classic-margherita.jpg',1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Sweet Vegetarian','Pizzeria','Red, yellow and green bell pepper, sweet corn and mozzarella.',24000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Pugliese','Pizzeria','Tomato, black olives, oregano and cheese.',24000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Pata','Pizzeria','Chips, tomato and cheese.',26000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Diavola','Pizzeria','Tomato, chili, salami and mozzarella.',26000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Salami','Pizzeria','Tomato, cheese and salami.',26000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Quattro Stagioni','Pizzeria','Ham, olives, mushroom, artichokes and mozzarella.',26000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Prosciutto Funghi','Pizzeria','Ham, mushroom and cheese.',26000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Prosciutto','Pizzeria','Cooked ham, tomato and mozzarella.',27000,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Bolognaise','Pizzeria','Spicy minced meat, mozzarella and tomato.',27000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Capricciosa','Pizzeria','Black olives, artichokes, capers, mushroom and salad.',27000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Pepperoni','Pizzeria','Tomato, green pepper, onions, pepperoni and mozzarella.',27000,NULL,12,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Hawaiian','Pizzeria','Ham or bacon, pineapple and mozzarella.',27000,NULL,13,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Pollo Pizza','Pizzeria','Italian chicken pizza with green pepper, onions and mushroom.',27000,NULL,14,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Tuna','Pizzeria','Tuna, tomato, onions, green pepper and mozzarella, topped with a boiled egg.',28000,NULL,15,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Calzone Pizza','Pizzeria','Minced meat, carrots and green pepper, folded into a semi circular bread shape.',30000,NULL,16,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Farmer''s Pizza','Pizzeria','Chicken and mushroom.',30000,NULL,17,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria'),'Paradise Special Pizza','Pizzeria','Minced meat, salami, ham, mushroom, green pepper and onions.',35000,NULL,18,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Pastas'),'Pasta a la Arrabiata','Italian Pastas','Pasta in tomato and fresh chili sauce.',18000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Pastas'),'Pasta a la Napolitana','Italian Pastas','Pasta in herby tomato and cheese sauce.',18000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Pastas'),'Pasta Genovese','Italian Pastas','Pasta in pesto sauce.',22000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Pastas'),'Pasta a la Carbonara','Italian Pastas','Pasta with egg and bacon in a creamy sauce.',22000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Pastas'),'Pasta ala Cavolfiore e Salsiccia','Italian Pastas','Pasta with cauliflower and sausage in an egg and bacon creamy sauce.',22000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Pastas'),'Pasta a la Contadina','Italian Pastas','Pasta in chicken, garlic, coriander, white wine and a creamy coconut sauce.',25000,NULL,6,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Aloo Mutter','Asian & Indian Curries','Diced potatoes and cowpeas prepared in a creamy sauce.',18000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Mixed Vegetable Curry','Asian & Indian Curries','Assorted vegetables in a creamy sauce, served with white rice or mash.',20000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Veggie Biryani','Asian & Indian Curries','Diced mixed vegetables in a creamy curry sauce, mixed with rice.',20000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Vegetable Chow Mein','Asian & Indian Curries','Noodles with oyster and soy sauce, tossed with fresh vegetables.',20000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Vegetable Korma','Asian & Indian Curries','Mixed vegetables in a mild creamy almond and cashew nut sauce.',20000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Chicken Tikka','Asian & Indian Curries',NULL,28000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Chili Chicken','Asian & Indian Curries',NULL,28000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Chicken / Fish / Mutton Biryani','Asian & Indian Curries','Chicken, fish or mutton cooked in a creamy sauce, mixed with rice.',30000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Coconut Chicken Curry','Asian & Indian Curries','Grilled boneless chicken in a golden sauce infused with coconut.',30000,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Chicken Tikka Masala','Asian & Indian Curries',NULL,30000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Chicken Makhani','Asian & Indian Curries','Boneless tandoori marinated chicken cooked in butter and tomato gravy.',30000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Fish Curry Diamond','Asian & Indian Curries',NULL,30000,NULL,12,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Fish Tikka','Asian & Indian Curries',NULL,30000,NULL,13,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Fish Tikka Masala','Asian & Indian Curries',NULL,32000,NULL,14,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Half Tandoori Chicken','Asian & Indian Curries','Chicken marinated with yogurt, ginger, garlic and spices, roasted in a clay oven.',37000,NULL,15,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian & Indian Curries'),'Full Tandoori Chicken','Asian & Indian Curries','A full chicken marinated with yogurt, ginger, garlic and spices, roasted in a clay oven.',47000,NULL,16,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Vegetable Spring Roll (1pc)','Chinese Corner',NULL,1000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Chicken Spring Roll (1pc)','Chinese Corner',NULL,2500,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Pork Spring Roll (1pc)','Chinese Corner',NULL,2500,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Vegetable Wanton','Chinese Corner',NULL,5000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Special Chicken Wings (1pc)','Chinese Corner',NULL,7000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried Wanton (Chicken or Beef)','Chinese Corner',NULL,8000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Golden Fried Cauliflower','Chinese Corner',NULL,10000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried Chips Plain','Chinese Corner',NULL,10000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Special Beef Simsim','Chinese Corner',NULL,15000,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Smoked Fish','Chinese Corner',NULL,15000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Salty Chicken / Beef','Chinese Corner',NULL,15000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Foil Wrapped Chicken','Chinese Corner',NULL,15000,NULL,12,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'French Fries with Garlic Sauce','Chinese Corner',NULL,15000,NULL,13,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried Egg Rolled Chicken (Pair)','Chinese Corner',NULL,18000,NULL,14,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried Chicken Wings','Chinese Corner',NULL,20000,NULL,15,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Crispy Chicken Legs','Chinese Corner',NULL,20000,NULL,16,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Golden Fried Prawns','Chinese Corner',NULL,20000,NULL,17,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried Baby Corn with Cashew Nuts','Chinese Corner',NULL,20000,NULL,18,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried Summary Chicken','Chinese Corner',NULL,25000,NULL,19,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sauté Chicken Sichuan Style','Chinese Corner',NULL,25000,NULL,20,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Chicken Curry','Chinese Corner',NULL,25000,NULL,21,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried French Beans with Garlic Sauce','Chinese Corner',NULL,25000,NULL,22,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Chinese Cabbage Sichuan Style (Hot)','Chinese Corner',NULL,25000,NULL,23,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Mixed Vegetables (Onions, Cabbage, Carrots, Pepper, Mushroom)','Chinese Corner',NULL,25000,NULL,24,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Stir-Fried Chicken with Cashew Nuts','Chinese Corner',NULL,30000,NULL,25,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Spicy Half Chicken with Vegetables','Chinese Corner',NULL,30000,NULL,26,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried Chicken with Chinese Black Bean Sauce','Chinese Corner',NULL,30000,NULL,27,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sweet and Sour Chicken','Chinese Corner',NULL,30000,NULL,28,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sliced Chicken with Garlic Sauce','Chinese Corner',NULL,30000,NULL,29,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sliced Beef with Chinese Cabbage','Chinese Corner',NULL,30000,NULL,30,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Shredded Beef with Onions','Chinese Corner',NULL,30000,NULL,31,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sweet and Sour Beef','Chinese Corner',NULL,30000,NULL,32,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sliced Beef in Oyster Sauce','Chinese Corner',NULL,30000,NULL,33,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Shredded Beef with Vegetables','Chinese Corner',NULL,30000,NULL,34,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sliced Beef with Pineapple Sauce','Chinese Corner',NULL,30000,NULL,35,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Beef Curry','Chinese Corner',NULL,30000,NULL,36,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sweet and Sour Pork','Chinese Corner',NULL,30000,NULL,37,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Shredded Pork with Green Pepper','Chinese Corner',NULL,30000,NULL,38,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sauté Pork Sichuan Style (Hot)','Chinese Corner',NULL,30000,NULL,39,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Spicy Pork with Garlic Sauce','Chinese Corner',NULL,30000,NULL,40,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sweet and Sour Fish Finger','Chinese Corner',NULL,30000,NULL,41,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Spicy Fish with Ginger & Garlic Sauce','Chinese Corner',NULL,30000,NULL,42,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sliced Fish with Vegetables','Chinese Corner',NULL,30000,NULL,43,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sliced Fish in Special Hot Sweet & Sour Sauce','Chinese Corner',NULL,30000,NULL,44,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Special Mixed Vegetables & Sprouts','Chinese Corner',NULL,30000,NULL,45,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried Mixed Chicken, Beef & Goat Meat','Chinese Corner',NULL,35000,NULL,46,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried Shredded Chicken with Bamboo Shoots','Chinese Corner',NULL,35000,NULL,47,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sliced Pork with Mushroom and Bamboo Shoots','Chinese Corner',NULL,35000,NULL,48,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried Beijing Duck with Vegetables','Chinese Corner',NULL,35000,NULL,49,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried Duck with Bamboo Shoots','Chinese Corner',NULL,35000,NULL,50,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried Prawns with Cashew Nuts','Chinese Corner',NULL,45000,NULL,51,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Sauté Prawns with Black Bean Sauce','Chinese Corner',NULL,45000,NULL,52,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Fried Prawns with Chinese Black Beans','Chinese Corner',NULL,50000,NULL,53,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chinese Corner'),'Beijing Roasted Duck (Whole)','Chinese Corner',NULL,100000,NULL,54,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sizzler Hot Plates'),'Sizzler Vegetables Plate','Sizzler Hot Plates',NULL,30000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sizzler Hot Plates'),'Sizzler Pork Plate','Sizzler Hot Plates',NULL,35000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sizzler Hot Plates'),'Sizzler Beef Plate','Sizzler Hot Plates',NULL,35000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sizzler Hot Plates'),'Sizzler Chicken Plate','Sizzler Hot Plates',NULL,35000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Sizzler Hot Plates'),'Sizzler Shrimps / Prawns Plate','Sizzler Hot Plates',NULL,50000,NULL,5,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles'),'Steamed Rice','Rice & Noodles',NULL,8000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles'),'Fried Rice','Rice & Noodles',NULL,8000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles'),'Ginger Fried Rice','Rice & Noodles',NULL,8000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles'),'Vegetable Fried Rice','Rice & Noodles',NULL,10000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles'),'Vegetable Fried Noodles','Rice & Noodles',NULL,12000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles'),'Egg Fried Rice','Rice & Noodles',NULL,15000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles'),'Chicken Fried Rice','Rice & Noodles',NULL,25000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Rice & Noodles'),'Chicken / Beef / Pork Fried Noodles','Rice & Noodles',NULL,25000,NULL,8,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Accompaniments & Extras'),'Mushroom Extra','Accompaniments & Extras',NULL,4000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Accompaniments & Extras'),'Avocado Extra','Accompaniments & Extras',NULL,4000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Accompaniments & Extras'),'Fried Egg Extra','Accompaniments & Extras',NULL,4000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Accompaniments & Extras'),'Bacon Extra','Accompaniments & Extras',NULL,7000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Accompaniments & Extras'),'Cheese Extra','Accompaniments & Extras',NULL,7000,NULL,5,1,1)
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
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Cookies','Desserts & Bakery',NULL,1000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Croissant','Desserts & Bakery',NULL,2000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Beef / Chicken Pie','Desserts & Bakery',NULL,5000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Sausage Roll','Desserts & Bakery',NULL,5000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Bread Loaf','Desserts & Bakery',NULL,6000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Marble Cake Slice','Desserts & Bakery',NULL,7000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Chocolate Cake Slice','Desserts & Bakery',NULL,7000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Strawberry Cake Slice','Desserts & Bakery',NULL,7000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Lemon Cake Slice','Desserts & Bakery',NULL,7000,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Vanilla Cake Slice','Desserts & Bakery',NULL,7000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Butter Bread','Desserts & Bakery',NULL,7000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'French Bread','Desserts & Bakery',NULL,7000,NULL,12,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Cinnamon Roll','Desserts & Bakery',NULL,8000,NULL,13,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Golden Fried Banana','Desserts & Bakery',NULL,10000,NULL,14,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Banana Crepe','Desserts & Bakery',NULL,12000,NULL,15,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Special Banana with Honey Sauce','Desserts & Bakery',NULL,12000,NULL,16,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Pineapple Upside-Down Cake','Desserts & Bakery',NULL,14000,NULL,17,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Tropical Fruit Platter','Desserts & Bakery',NULL,15000,NULL,18,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Tropical Fruit Salad','Desserts & Bakery',NULL,15000,NULL,19,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Lemon Tart','Desserts & Bakery',NULL,15000,NULL,20,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Banana Split','Desserts & Bakery',NULL,15000,NULL,21,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Mango Tart','Desserts & Bakery',NULL,16000,NULL,22,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'White Forest Cake','Desserts & Bakery',NULL,16000,NULL,23,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Profiteroles','Desserts & Bakery',NULL,16000,NULL,24,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Chocolate Fudge Slice','Desserts & Bakery',NULL,17000,NULL,25,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Black Forest Cake (pc)','Desserts & Bakery',NULL,17000,NULL,26,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Classic Carrot Cake','Desserts & Bakery',NULL,19000,NULL,27,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts & Bakery'),'Chocolate Mousse','Desserts & Bakery',NULL,20000,NULL,28,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Restaurant rows this file used to publish and no longer does. Only the
-- restaurant outlet is touched: the bar and room service menus are the
-- hotel's own and are left alone.
UPDATE menu_items SET published = 0
WHERE hotel_id = 1 AND published = 1 AND name NOT IN ('Mixed Garden Salad','Greek Salad','Avocado & Lettuce Salad','Tuna Salad','Chicken Oriental Salad','Caesar Salad','Chef Salad','Mushroom Soup','Clear Vegetable Broth','Cream of Tomato Soup','Ginger Carrot Soup','Beef / Chicken Broth','Chicken Noodle Soup','French Cinnamon Toast','Eggs and Toast','Mushroom and Cheese Omelet','Mexican Omelet','Spanish Omelet','Bacon Cheese Omelet','Yummy Chicken Omelet','Chicken Gizzards','Fish Fingers','Chicken Wings / Lollipops','Liver Princess','Mushroom Fries','Masala Chips','Bacon Cheese Fries','Vegetable Spring Rolls (Set)','Beef / Vegetable Samosas (Set)','Chicken Samosas (Pair)','Chicken Spring Rolls (Pair)','Tomato, Cheese & Avocado Sandwich','Pulled Pork Sandwich','Chicken Salad Sandwich','Classic BLT Sandwich','Steak Cheese Sandwich','BBQ Beef Sandwich','Tuna Melt Sandwich','Paradise Club Sandwich','BBQ Burger','Chicken Burger','Vegetable Burger','Mushroom & Cheese Burger','King Burger','Crunchy Vegetable Wrap','Beef Rolex','Chicken Rolex','Chicken Wrap','Classic BLT Wrap','Chicken / Beef Burrito','Fajita Chicken / Beef','Fish Florentine','Poached Fish','Mombasa Fish','Catch of the Day (Nile Perch)','Paradise Rustica Fish','Premium Whole Fish','King Size Whole Fish','Fried King Prawns','Golden Grilled Salmon','Mixed Grill Platter (2 Pax)','Paradise Lusaniya (3-4 Pax)','Chicken Sauté','BBQ Chicken Drumsticks','Grilled Quarter Chicken','Mushroom Chicken','Supreme Chicken','Paradise 1/2 Grilled Farm Chicken','Goat Sizzler','Goat Muchomo','Beef Stir Fry','Beef Wet Fry','Honey Glazed Hawaiian Beef Skewers','Beef Stroganoff','Beef in Guinness','Goat Rack Tender','Mushroom Steak','Pepper Steak','King Steak','Paradise Mixed Grill','Pork Muchomo','Paradise Grilled Pork Chop','Honey Mustard Glazed Pork Ribs','Sweet and Sour Pork Chops','Trio of Pork Platter','Classico e Margherita','Sweet Vegetarian','Pugliese','Pata','Diavola','Salami','Quattro Stagioni','Prosciutto Funghi','Prosciutto','Bolognaise','Capricciosa','Pepperoni','Hawaiian','Pollo Pizza','Tuna','Calzone Pizza','Farmer''s Pizza','Paradise Special Pizza','Pasta a la Arrabiata','Pasta a la Napolitana','Pasta Genovese','Pasta a la Carbonara','Pasta ala Cavolfiore e Salsiccia','Pasta a la Contadina','Aloo Mutter','Mixed Vegetable Curry','Veggie Biryani','Vegetable Chow Mein','Vegetable Korma','Chicken Tikka','Chili Chicken','Chicken / Fish / Mutton Biryani','Coconut Chicken Curry','Chicken Tikka Masala','Chicken Makhani','Fish Curry Diamond','Fish Tikka','Fish Tikka Masala','Half Tandoori Chicken','Full Tandoori Chicken','Vegetable Spring Roll (1pc)','Chicken Spring Roll (1pc)','Pork Spring Roll (1pc)','Vegetable Wanton','Special Chicken Wings (1pc)','Fried Wanton (Chicken or Beef)','Golden Fried Cauliflower','Fried Chips Plain','Special Beef Simsim','Smoked Fish','Salty Chicken / Beef','Foil Wrapped Chicken','French Fries with Garlic Sauce','Fried Egg Rolled Chicken (Pair)','Fried Chicken Wings','Crispy Chicken Legs','Golden Fried Prawns','Fried Baby Corn with Cashew Nuts','Fried Summary Chicken','Sauté Chicken Sichuan Style','Chicken Curry','Fried French Beans with Garlic Sauce','Chinese Cabbage Sichuan Style (Hot)','Mixed Vegetables (Onions, Cabbage, Carrots, Pepper, Mushroom)','Stir-Fried Chicken with Cashew Nuts','Spicy Half Chicken with Vegetables','Fried Chicken with Chinese Black Bean Sauce','Sweet and Sour Chicken','Sliced Chicken with Garlic Sauce','Sliced Beef with Chinese Cabbage','Shredded Beef with Onions','Sweet and Sour Beef','Sliced Beef in Oyster Sauce','Shredded Beef with Vegetables','Sliced Beef with Pineapple Sauce','Beef Curry','Sweet and Sour Pork','Shredded Pork with Green Pepper','Sauté Pork Sichuan Style (Hot)','Spicy Pork with Garlic Sauce','Sweet and Sour Fish Finger','Spicy Fish with Ginger & Garlic Sauce','Sliced Fish with Vegetables','Sliced Fish in Special Hot Sweet & Sour Sauce','Special Mixed Vegetables & Sprouts','Fried Mixed Chicken, Beef & Goat Meat','Fried Shredded Chicken with Bamboo Shoots','Sliced Pork with Mushroom and Bamboo Shoots','Fried Beijing Duck with Vegetables','Fried Duck with Bamboo Shoots','Fried Prawns with Cashew Nuts','Sauté Prawns with Black Bean Sauce','Fried Prawns with Chinese Black Beans','Beijing Roasted Duck (Whole)','Sizzler Vegetables Plate','Sizzler Pork Plate','Sizzler Beef Plate','Sizzler Chicken Plate','Sizzler Shrimps / Prawns Plate','Steamed Rice','Fried Rice','Ginger Fried Rice','Vegetable Fried Rice','Vegetable Fried Noodles','Egg Fried Rice','Chicken Fried Rice','Chicken / Beef / Pork Fried Noodles','Mushroom Extra','Avocado Extra','Fried Egg Extra','Bacon Extra','Cheese Extra','Cookies','Croissant','Beef / Chicken Pie','Sausage Roll','Bread Loaf','Marble Cake Slice','Chocolate Cake Slice','Strawberry Cake Slice','Lemon Cake Slice','Vanilla Cake Slice','Butter Bread','French Bread','Cinnamon Roll','Golden Fried Banana','Banana Crepe','Special Banana with Honey Sauce','Pineapple Upside-Down Cake','Tropical Fruit Platter','Tropical Fruit Salad','Lemon Tart','Banana Split','Mango Tart','White Forest Cake','Profiteroles','Chocolate Fudge Slice','Black Forest Cake (pc)','Classic Carrot Cake','Chocolate Mousse')
  AND category_id IN (SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant');

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
