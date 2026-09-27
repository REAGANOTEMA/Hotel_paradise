-- HOTEL PARADISE ON THE NILE - COMPLETE MENU SEED
-- Generated from frontend-react/src/menuData.ts by database/tools/build-menu-seed.mjs
-- Do not hand edit. Re-run the generator instead.
--
-- 15 sections, 81 dishes for hotel 1. A dish priced on
-- request is stored as NULL, which is what the website reads as
-- "Priced on request".
--
-- Safe to run on a hotel that is already trading. Dishes are matched on their
-- name, so a reload updates the existing rows in place and keeps the ids that
-- past orders already reference. Nothing is deleted and nothing is deactivated:
-- this file only sets the published flag, which is the website's business
-- alone. The till's menu, the bar and room service are left exactly as they are.
--
-- Run it inside a transaction if you would rather see the whole result or none
-- of it.

USE `hotelpardise_system`;

-- Starters
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Starters','To begin','Warm soups, the sandwich corner and freshly dressed salads.',NULL,1,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters'),'Mushroom Soup','Soups','Creamy forest mushroom soup, homemade style, served with a bread roll.',12000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters'),'Clear Chicken and Beef Noodle Soup','Soups','Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.',15000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters'),'Classic BLT Sandwich','Sandwich Corner','Crisp bacon, lettuce and ripe tomato in a toasted roll.',25000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters'),'Three Decker Sandwich','Sandwich Corner','Three decker of bacon, lettuce and tomato, served with chips.',NULL,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters'),'Tuna Melt','Sandwich Corner','Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.',25000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters'),'Paradise Club Sandwich','Sandwich Corner','Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.',30000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters'),'Grilled Veggies Salad','Salads','Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.',18000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters'),'Grilled Chicken Salad','Salads','Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.',15000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Starters'),'Tuna Salad','Salads','Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.',20000,NULL,9,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Egg Dishes
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Egg Dishes','From the pan','Classic egg plates finished to order.',NULL,2,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Egg Dishes'),'Spanish Omelet','Egg Dishes','Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.',15000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Egg Dishes'),'Avocado with an Egg','Egg Dishes','Avocado and a fried egg on toasted bread with a garnish.',13000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Egg Dishes'),'Bacon and Cheese Omelet','Egg Dishes','Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.',NULL,NULL,3,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Burgers
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Burgers','The grill','Charcoal patties, regular or Cajun, in a soft toasted bun.',NULL,3,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers'),'Vegetable Burger','Burgers','Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.',20000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers'),'Chicken and Beef Burger','Burgers','Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.',NULL,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers'),'BBQ Beef and Chicken Patty','Burgers','Grilled beef or chicken patty finished in a tangy barbecue sauce.',NULL,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Burgers'),'Double Beef and Bacon Burger','Burgers','Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.',NULL,NULL,4,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Wraps and Rolex
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Wraps and Rolex','Rolled fresh','Shredded fillings rolled warm in a soft tortilla.',NULL,4,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Wraps and Rolex'),'Chicken Wrap','Wraps','Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.',20000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Wraps and Rolex'),'Crunchy Vegetable Wrap','Wraps','Sautéed vegetables with a touch of cheddar cheese, served plain.',14000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Wraps and Rolex'),'Chicken and Beef Rolex','Wraps','Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.',15000,NULL,3,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Snacks
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Snacks','Light bites','Served with a choice of rice or chips.',NULL,5,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Snacks'),'Chilli Beef and Veggie Chips','Snacks','Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.',NULL,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Snacks'),'Chicken Spring Rolls','Snacks','A pair of crisp chicken spring rolls.',6000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Snacks'),'Liver with Shredded Vegetables','Snacks','Flakes of liver tossed with shredded vegetables, served with rice or chips.',30000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Snacks'),'Fish Fingers with Chips','Snacks','Crisp breaded fish fingers with a portion of chips.',30000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Snacks'),'Chicken Wings with Chips','Snacks','Crispy chicken wings with a portion of chips.',28000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Snacks'),'Chicken Lollipops with Chips','Snacks','Chicken lollipops with a portion of chips.',30000,NULL,6,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Italian Special Pastas
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Italian Special Pastas','From Napoli','Fresh pasta finished with melted cheese and a slice of toast.',NULL,6,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Special Pastas'),'Pasta Arrabbiata','Pasta','Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.',20000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Special Pastas'),'Pasta Bolognese','Pasta','Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.',25000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Italian Special Pastas'),'Pasta Carbonara','Pasta','Pasta with egg and bacon cream sauce, topped with cheese and served with toast.',30000,NULL,3,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Fisherman's Offer
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Fisherman''s Offer','Fresh from the Nile','Whole tilapia, fried, steamed or grilled. Oil free off the grill.',NULL,7,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'Premium Whole Tilapia, Fried or Steamed','Whole Fish','Medium premium tilapia, fried or steamed, served with chips.',30000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'Premium Wet Fried Tilapia','Whole Fish','Premium tilapia in a seasoned wet fry.',38000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'Grilled Premium Tilapia','Whole Fish','Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.',NULL,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'Large Whole Tilapia, Fried or Steamed','Whole Fish','Large king tilapia, fried or steamed, served with chips.',40000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fisherman''s Offer'),'Grilled Tilapia Fillet, Spinach and Cheese','Whole Fish','Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.',43000,NULL,5,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Fish Fillets
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Fish Fillets','The catch','Breaded, battered or simply grilled, with rice or chips.',NULL,8,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fish Fillets'),'Paradise Rustica Fish','Fish Fillets','Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.',32000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fish Fillets'),'Mombasa Fish','Fish Fillets','Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.',32000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fish Fillets'),'Deep Fried or Pan Grilled Fillet','Fish Fillets','Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.',32000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Fish Fillets'),'Catch of the Day','Fish Fillets','Pan grilled Nile perch fillet served with rice or chips.',32000,NULL,4,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Chicken Lovers
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Chicken Lovers','Poultry','Marinated overnight, then grilled, pan fried or tossed in sauce.',NULL,9,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Lovers'),'Chicken Saute','Chicken Lovers','Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.',30000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Lovers'),'BBQ Chicken Drumstick','Chicken Lovers','Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.',30000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Lovers'),'Grilled Quarter Chicken Breast or Thigh','Chicken Lovers','Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.',45000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Lovers'),'Paradise Grilled Farm Chicken','Chicken Lovers','A well marinated chicken grilled to perfection with aromatic seasonings.',40000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Chicken Lovers'),'Pan Fried Boneless Chicken Breast','Chicken Lovers','Fresh pan fried boneless chicken breast resting in mushroom sauce.',43000,NULL,5,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Paradise Hunter's Delicacies
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Paradise Hunter''s Delicacies','Steaks and grills','Prime beef fillet, skewers and the hunter''s favourites.',NULL,10,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Paradise Hunter''s Delicacies'),'Beef Fillet Steak','Steaks','Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.',35000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Paradise Hunter''s Delicacies'),'King Steak','Steaks','Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.',40000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Paradise Hunter''s Delicacies'),'Beef Stroganoff','Steaks','Slow cooked beef in mushroom and red wine sauce, finished with cream.',15000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Paradise Hunter''s Delicacies'),'Beef Stir Fry','Steaks','Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.',35000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Paradise Hunter''s Delicacies'),'Paradise Mixed Grill','Steaks','A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.',47000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Paradise Hunter''s Delicacies'),'Honey Glazed Hawaiian Beef Skewers','Steaks','Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.',35000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Paradise Hunter''s Delicacies'),'Beef Wet Fry','Steaks','Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.',15000,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Paradise Hunter''s Delicacies'),'Goat Muchomo','Steaks','Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.',NULL,NULL,8,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Pork
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Pork','Pork','Slow roasted, glazed and grilled to your liking.',NULL,11,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork'),'Paradise Grilled Pork Chops','Pork','Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.',NULL,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork'),'Honey Mustard Glazed Pork Ribs','Pork','Tender juicy ribs of pork roasted in onion rings and honey.',NULL,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork'),'Pork Muchomo','Pork','Boneless chunks of pork roasted in aromatic vegetables, served with chips.',NULL,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork'),'Sweet and Sour Pork','Pork','Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.',NULL,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pork'),'Pork Muchomo and Chops Platter','Pork','A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.',35000,NULL,5,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- House Specials
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','House Specials','For the table','Platters built for sharing, served with two accompaniments.',NULL,12,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='House Specials'),'Paradise Lusaniya','House Specials','A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.',100000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='House Specials'),'Mixed Grill Platter','House Specials','A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.',80000,NULL,2,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Asian Delicacies
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Asian Delicacies','Far East','Mild creamy curries, biryani and coconut dishes with rice or chapatti.',NULL,13,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian Delicacies'),'Mixed Vegetable Curry','Curries','Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.',20000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian Delicacies'),'Vegetable Korma','Curries','Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.',25000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian Delicacies'),'Chicken Coconut Curry','Curries','Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.',32000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian Delicacies'),'Veggie Biryani','Biryani','Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.',25000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Asian Delicacies'),'Chicken, Fish or Goat Biryani','Biryani','Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.',32000,NULL,5,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Desserts
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Desserts','Sweet finish','Fresh fruit, ice cream and a little sugar.',NULL,14,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts'),'Fresh Fruit Platter','Desserts','A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.',NULL,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts'),'Fruit Salad','Desserts','A combination of diced fruits sprinkled with passion fruit syrup.',15000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts'),'Banana Crepe','Desserts','A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.',15000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts'),'Ice Cream','Desserts','Three scoops, chocolate, vanilla or strawberry.',9000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts'),'Cake of the Day','Desserts','A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.',7000,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts'),'Affogato Espresso Ice Cream','Desserts','Two scoops of ice cream of your choice with 60ml of espresso coffee.',15000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Desserts'),'Banana Split','Desserts','Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.',15000,NULL,7,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Pizzeria Section
INSERT INTO menu_categories (hotel_id,outlet,name,eyebrow,blurb,image,sort_order,published)
VALUES (1,'restaurant','Pizzeria Section','Pizza','Baked to order on a stone base, 12 inch.',NULL,15,1)
ON DUPLICATE KEY UPDATE
  eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), image=VALUES(image),
  sort_order=VALUES(sort_order), published=1;

INSERT INTO menu_items (hotel_id,category_id,name,group_name,description,price,image,sort_order,active,published)
VALUES
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria Section'),'Classic Margherita','Pizza','Tomato, fresh basil, oregano and mozzarella.',27000,NULL,1,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria Section'),'Sweet Vegetarian','Pizza','Red, yellow and green bell pepper, sweet corn and mozzarella.',27000,NULL,2,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria Section'),'Quattro Stagioni','Pizza','Ham, olives, mushroom, artichokes and mozzarella.',30000,NULL,3,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria Section'),'Pepperoni','Pizza','Tomato, green pepper, onion, pepperoni and mozzarella.',30000,NULL,4,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria Section'),'Hawaiian','Pizza','Ham or bacon, pineapple and mozzarella.',NULL,NULL,5,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria Section'),'Farmer''s','Pizza','Chicken, mushroom and mozzarella.',30000,NULL,6,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria Section'),'Tuna','Pizza','Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.',NULL,NULL,7,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria Section'),'Diavola','Pizza','Tomato, chili salami and mozzarella.',30000,NULL,8,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria Section'),'Bolognese','Pizza','Spicy minced meat, tomato and mozzarella.',NULL,NULL,9,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria Section'),'Capricciosa','Pizza','Salami, black olives, artichokes, capers, mushroom and mozzarella.',30000,NULL,10,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria Section'),'Assorted Meat and Salami','Pizza','Assorted meat, salami, mushroom, green pepper, onion and mozzarella.',35000,NULL,11,1,1),
  (1,(SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant' AND name='Pizzeria Section'),'Calzone','Calzone','Minced meat, green pepper and capsicum rolled in a half moon of bread.',30000,NULL,12,1,1)
ON DUPLICATE KEY UPDATE
  category_id=VALUES(category_id), group_name=VALUES(group_name), description=VALUES(description),
  price=VALUES(price), image=VALUES(image), sort_order=VALUES(sort_order), active=1, published=1;

-- Restaurant rows this file used to publish and no longer does. Only the
-- restaurant outlet is touched: the bar and room service menus are the
-- hotel's own and are left alone.
UPDATE menu_items SET published = 0
WHERE hotel_id = 1 AND published = 1 AND name NOT IN ('Mushroom Soup','Clear Chicken and Beef Noodle Soup','Classic BLT Sandwich','Three Decker Sandwich','Tuna Melt','Paradise Club Sandwich','Grilled Veggies Salad','Grilled Chicken Salad','Tuna Salad','Spanish Omelet','Avocado with an Egg','Bacon and Cheese Omelet','Vegetable Burger','Chicken and Beef Burger','BBQ Beef and Chicken Patty','Double Beef and Bacon Burger','Chicken Wrap','Crunchy Vegetable Wrap','Chicken and Beef Rolex','Chilli Beef and Veggie Chips','Chicken Spring Rolls','Liver with Shredded Vegetables','Fish Fingers with Chips','Chicken Wings with Chips','Chicken Lollipops with Chips','Pasta Arrabbiata','Pasta Bolognese','Pasta Carbonara','Premium Whole Tilapia, Fried or Steamed','Premium Wet Fried Tilapia','Grilled Premium Tilapia','Large Whole Tilapia, Fried or Steamed','Grilled Tilapia Fillet, Spinach and Cheese','Paradise Rustica Fish','Mombasa Fish','Deep Fried or Pan Grilled Fillet','Catch of the Day','Chicken Saute','BBQ Chicken Drumstick','Grilled Quarter Chicken Breast or Thigh','Paradise Grilled Farm Chicken','Pan Fried Boneless Chicken Breast','Beef Fillet Steak','King Steak','Beef Stroganoff','Beef Stir Fry','Paradise Mixed Grill','Honey Glazed Hawaiian Beef Skewers','Beef Wet Fry','Goat Muchomo','Paradise Grilled Pork Chops','Honey Mustard Glazed Pork Ribs','Pork Muchomo','Sweet and Sour Pork','Pork Muchomo and Chops Platter','Paradise Lusaniya','Mixed Grill Platter','Mixed Vegetable Curry','Vegetable Korma','Chicken Coconut Curry','Veggie Biryani','Chicken, Fish or Goat Biryani','Fresh Fruit Platter','Fruit Salad','Banana Crepe','Ice Cream','Cake of the Day','Affogato Espresso Ice Cream','Banana Split','Classic Margherita','Sweet Vegetarian','Quattro Stagioni','Pepperoni','Hawaiian','Farmer''s','Tuna','Diavola','Bolognese','Capricciosa','Assorted Meat and Salami','Calzone')
  AND category_id IN (SELECT id FROM menu_categories WHERE hotel_id=1 AND outlet='restaurant');

UPDATE menu_categories SET published = 0
WHERE hotel_id = 1 AND outlet='restaurant' AND published = 1 AND name NOT IN ('Starters','Egg Dishes','Burgers','Wraps and Rolex','Snacks','Italian Special Pastas','Fisherman''s Offer','Fish Fillets','Chicken Lovers','Paradise Hunter''s Delicacies','Pork','House Specials','Asian Delicacies','Desserts','Pizzeria Section');

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
