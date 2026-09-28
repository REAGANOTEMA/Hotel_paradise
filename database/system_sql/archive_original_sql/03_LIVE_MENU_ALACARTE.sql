-- ============================================================================
-- HOTEL PARADISE ON THE NILE — PROPOSED A LA CARTE MENU, JANUARY 2026
-- ============================================================================
-- Run AFTER schema.sql and seed.sql.
--
--   mysql -u root hotel_paradise_nile < database/menu_alacarte.sql
--
-- Notes for the rates team
-- -----------------------
-- 1. Every price is in Ugandan Shillings (UGX), whole shillings, no cents.
-- 2. Items with a NULL price are published on the site as "Price on request".
--    The suggested figure is written next to the INSERT as a SQL comment.
-- 3. Run the verification query at the bottom of this file before you print
--    the menu. It lists everything still waiting on a rate.
-- 4. This script removes the old a la carte categories only. Your bar,
--    room service and POS history are left untouched.
-- ============================================================================

USE hotel_paradise_nile;

-- Keep the old front of house menu out of the way, keep the bar.
DELETE mi FROM menu_items mi
  JOIN menu_categories mc ON mc.id = mi.category_id
  WHERE mc.outlet = 'restaurant';

DELETE FROM menu_categories WHERE outlet = 'restaurant';

-- ---------------------------------------------------------------------------
-- 1. SECTIONS
-- ---------------------------------------------------------------------------
INSERT INTO menu_categories(hotel_id,outlet,name,eyebrow,blurb,sort_order) VALUES
(1,'restaurant','Starters','TO BEGIN','Warm soups, the sandwich corner and freshly dressed salads.',10),
(1,'restaurant','Egg Dishes','FROM THE PAN','Classic egg plates finished to order.',20),
(1,'restaurant','Burgers','THE GRILL','Charcoal patties, regular or Cajun, in a soft toasted bun.',30),
(1,'restaurant','Wraps and Rolex','ROLLED FRESH','Shredded fillings rolled warm in a soft tortilla.',40),
(1,'restaurant','Snacks','LIGHT BITES','Served with a choice of rice or chips.',50),
(1,'restaurant','Italian Special Pastas','FROM NAPOLI','Fresh pasta finished with a melted cheese and a slice of toast.',60),
(1,'restaurant','Fisherman''s Offer','FRESH FROM THE NILE','Whole tilapia, fried, steamed or grilled, oil free on the grill.',70),
(1,'restaurant','Fish Fillets','THE CATCH','Breaded, battered or simply grilled, with rice or chips.',80),
(1,'restaurant','Chicken Lovers','POULTRY','Marinated overnight, grilled, pan fried or tossed in sauce.',90),
(1,'restaurant','Paradise Hunter''s Delicacies','STEAKS AND GRILLS','Prime beef fillet, skewers and the hunter''s favourites.',100),
(1,'restaurant','Pork','PORK','Slow roasted, glazed and grilled to your liking.',110),
(1,'restaurant','House Specials','FOR THE TABLE','Platters built for sharing, served with two accompaniments.',120),
(1,'restaurant','Asian Delicacies','FAR EAST','Mild creamy curries, biryani and coconut dishes with rice or chapatti.',130),
(1,'restaurant','Desserts','SWEET FINISH','Fresh fruit, ice cream and a little sugar.',140),
(1,'restaurant','Pizzeria Section','PIZZA','Baked to order on a stone base, 12 inch.',150);

-- ---------------------------------------------------------------------------
-- 2. ITEMS
--    (category name, group, item, description, price, suggested price, tracked)
-- ---------------------------------------------------------------------------

-- 2.1 Starters -----------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Starters'),'Mushroom Soup','Soups','Creamy forest mushroom soup, homemade style, served with a bread roll.',12000,10,0),
(1,(SELECT id FROM menu_categories WHERE name='Starters'),'Clear Chicken and Beef Noodle Soup','Soups','Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.',15000,20,0),
(1,(SELECT id FROM menu_categories WHERE name='Starters'),'Classic BLT Sandwich','Sandwich Corner','Crisp bacon, lettuce and ripe tomato in a toasted roll.',25000,30,0),
(1,(SELECT id FROM menu_categories WHERE name='Starters'),'Three Decker Sandwich','Sandwich Corner','Three decker of bacon, lettuce and tomato, served with chips.',NULL, -- suggested 28000
 40,0),
(1,(SELECT id FROM menu_categories WHERE name='Starters'),'Tuna Melt','Sandwich Corner','Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.',25000,50,0),
(1,(SELECT id FROM menu_categories WHERE name='Starters'),'Paradise Club Sandwich','Sandwich Corner','Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.',30000,60,0),
(1,(SELECT id FROM menu_categories WHERE name='Starters'),'Grilled Veggies Salad','Salads','Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.',18000,70,0),
(1,(SELECT id FROM menu_categories WHERE name='Starters'),'Grilled Chicken Salad','Salads','Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.',15000,80,0),
(1,(SELECT id FROM menu_categories WHERE name='Starters'),'Tuna Salad','Salads','Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.',20000,90,0);

-- 2.2 Egg Dishes ----------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Egg Dishes'),'Spanish Omelet','Egg Dishes','Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.',15000,10,0),
(1,(SELECT id FROM menu_categories WHERE name='Egg Dishes'),'Avocado with an Egg','Egg Dishes','Avocado and a fried egg on toasted bread with a garnish.',13000,20,0),
(1,(SELECT id FROM menu_categories WHERE name='Egg Dishes'),'Bacon and Cheese Omelet','Egg Dishes','Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.',NULL, -- suggested 18000
 30,0);

-- 2.3 Burgers -------------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Burgers'),'Vegetable Burger','Burgers','Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.',20000,10,0),
(1,(SELECT id FROM menu_categories WHERE name='Burgers'),'Chicken and Beef Burger','Burgers','Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.',NULL, -- 75,000 in the draft, confirm before printing
 20,1),
(1,(SELECT id FROM menu_categories WHERE name='Burgers'),'BBQ Beef and Chicken Patty','Burgers','Grilled beef or chicken patty finished in a tangy barbecue sauce.',NULL, -- suggested 30000
 30,1),
(1,(SELECT id FROM menu_categories WHERE name='Burgers'),'Double Beef and Bacon Burger','Burgers','Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.',NULL, -- suggested 32000
 40,1);

-- 2.4 Wraps ---------------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Wraps and Rolex'),'Chicken Wrap','Wraps','Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.',20000,10,0),
(1,(SELECT id FROM menu_categories WHERE name='Wraps and Rolex'),'Crunchy Vegetable Wrap','Wraps','Sautéed vegetables with a touch of cheddar cheese, served plain.',14000,20,0),
(1,(SELECT id FROM menu_categories WHERE name='Wraps and Rolex'),'Chicken and Beef Rolex','Wraps','Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.',15000,30,0);

-- 2.5 Snacks -------------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Snacks'),'Chilli Beef and Veggie Chips','Snacks','Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.',NULL, -- suggested 20000
 10,0),
(1,(SELECT id FROM menu_categories WHERE name='Snacks'),'Chicken Spring Rolls','Snacks','A pair of crisp chicken spring rolls.',6000,20,0),
(1,(SELECT id FROM menu_categories WHERE name='Snacks'),'Liver with Shredded Vegetables','Snacks','Flakes of liver tossed with shredded vegetables, served with rice or chips.',30000,30,0),
(1,(SELECT id FROM menu_categories WHERE name='Snacks'),'Fish Fingers with Chips','Snacks','Crisp breaded fish fingers with a portion of chips.',30000,40,1),
(1,(SELECT id FROM menu_categories WHERE name='Snacks'),'Chicken Wings with Chips','Snacks','Crispy chicken wings with a portion of chips.',28000,50,1),
(1,(SELECT id FROM menu_categories WHERE name='Snacks'),'Chicken Lollipops with Chips','Snacks','Chicken lollipops with a portion of chips.',30000,60,1);

-- 2.6 Italian Special Pastas -----------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Italian Special Pastas'),'Pasta Arrabbiata','Pasta','Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.',20000,10,0),
(1,(SELECT id FROM menu_categories WHERE name='Italian Special Pastas'),'Pasta Bolognese','Pasta','Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.',25000,20,0),
(1,(SELECT id FROM menu_categories WHERE name='Italian Special Pastas'),'Pasta Carbonara','Pasta','Pasta with egg and bacon cream sauce, topped with cheese and served with toast.',30000,30,0);

-- 2.7 Fisherman's Offer ---------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Fisherman''s Offer'),'Premium Whole Tilapia, Fried or Steamed','Whole Fish','Medium premium tilapia, fried or steamed, served with chips.',NULL, -- 8,000 in the draft, confirm the weight band and rate
 10,1),
(1,(SELECT id FROM menu_categories WHERE name='Fisherman''s Offer'),'Premium Wet Fried Tilapia','Whole Fish','Premium tilapia in a seasoned wet fry.',NULL, -- suggested 38000
 20,1),
(1,(SELECT id FROM menu_categories WHERE name='Fisherman''s Offer'),'Grilled Premium Tilapia','Whole Fish','Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.',NULL, -- suggested 42000
 30,1),
(1,(SELECT id FROM menu_categories WHERE name='Fisherman''s Offer'),'Large Whole Tilapia, Fried or Steamed','Whole Fish','Large king tilapia, fried or steamed, served with chips.',NULL, -- suggested 65000
 40,1),
(1,(SELECT id FROM menu_categories WHERE name='Fisherman''s Offer'),'Grilled Tilapia Fillet, Spinach and Cheese','Whole Fish','Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.',NULL, -- suggested 40000
 50,1);

-- 2.8 Fish Fillets ---------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Fish Fillets'),'Paradise Rustica Fish','Fish Fillets','Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.',32000,10,1),
(1,(SELECT id FROM menu_categories WHERE name='Fish Fillets'),'Mombasa Fish','Fish Fillets','Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.',32000,20,1),
(1,(SELECT id FROM menu_categories WHERE name='Fish Fillets'),'Deep Fried or Pan Grilled Fillet','Fish Fillets','Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.',32000,30,1),
(1,(SELECT id FROM menu_categories WHERE name='Fish Fillets'),'Catch of the Day','Fish Fillets','Pan grilled Nile perch fillet served with rice or chips.',NULL, -- suggested 38000
 40,1);

-- 2.9 Chicken Lovers --------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Chicken Lovers'),'Chicken Saute','Chicken Lovers','Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.',30000,10,1),
(1,(SELECT id FROM menu_categories WHERE name='Chicken Lovers'),'BBQ Chicken Drumstick','Chicken Lovers','Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.',30000,20,1),
(1,(SELECT id FROM menu_categories WHERE name='Chicken Lovers'),'Grilled Quarter Chicken Breast or Thigh','Chicken Lovers','Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.',45000,30,1),
(1,(SELECT id FROM menu_categories WHERE name='Chicken Lovers'),'Paradise Grilled Farm Chicken','Chicken Lovers','A well marinated chicken grilled to perfection with aromatic seasonings.',40000,40,1),
(1,(SELECT id FROM menu_categories WHERE name='Chicken Lovers'),'Pan Fried Boneless Chicken Breast','Chicken Lovers','Fresh pan fried boneless chicken breast resting in mushroom sauce.',43000,50,1);

-- 2.10 Steaks and Grills -----------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Paradise Hunter''s Delicacies'),'Beef Fillet Steak','Steaks','Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.',35000,10,1),
(1,(SELECT id FROM menu_categories WHERE name='Paradise Hunter''s Delicacies'),'King Steak','Steaks','Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.',40000,20,1),
(1,(SELECT id FROM menu_categories WHERE name='Paradise Hunter''s Delicacies'),'Beef Stroganoff','Steaks','Slow cooked beef in mushroom and red wine sauce, finished with cream.',15000,30,1),
(1,(SELECT id FROM menu_categories WHERE name='Paradise Hunter''s Delicacies'),'Beef Stir Fry','Steaks','Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.',35000,40,1),
(1,(SELECT id FROM menu_categories WHERE name='Paradise Hunter''s Delicacies'),'Paradise Mixed Grill','Steaks','A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.',47000,50,1),
(1,(SELECT id FROM menu_categories WHERE name='Paradise Hunter''s Delicacies'),'Honey Glazed Hawaiian Beef Skewers','Steaks','Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.',35000,60,1),
(1,(SELECT id FROM menu_categories WHERE name='Paradise Hunter''s Delicacies'),'Beef Wet Fry','Steaks','Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.',15000,70,1),
(1,(SELECT id FROM menu_categories WHERE name='Paradise Hunter''s Delicacies'),'Goat Muchomo','Steaks','Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.',NULL, -- suggested 32000
 80,1);

-- 2.11 Pork ---------------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Pork'),'Paradise Grilled Pork Chops','Pork','Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.',NULL, -- suggested 35000
 10,1),
(1,(SELECT id FROM menu_categories WHERE name='Pork'),'Honey Mustard Glazed Pork Ribs','Pork','Tender juicy ribs of pork roasted in onion rings and honey.',NULL, -- suggested 38000
 20,1),
(1,(SELECT id FROM menu_categories WHERE name='Pork'),'Pork Muchomo','Pork','Boneless chunks of pork roasted in aromatic vegetables, served with chips.',NULL, -- suggested 28000
 30,1),
(1,(SELECT id FROM menu_categories WHERE name='Pork'),'Sweet and Sour Pork','Pork','Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.',NULL, -- suggested 30000
 40,1),
(1,(SELECT id FROM menu_categories WHERE name='Pork'),'Pork Muchomo and Chops Platter','Pork','A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.',35000,50,1);

-- 2.12 House Specials -----------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='House Specials'),'Paradise Lusaniya','House Specials','A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.',100000,10,1),
(1,(SELECT id FROM menu_categories WHERE name='House Specials'),'Mixed Grill Platter','House Specials','A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.',80000,20,1);

-- 2.13 Asian Delicacies ----------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Asian Delicacies'),'Mixed Vegetable Curry','Curries','Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.',20000,10,0),
(1,(SELECT id FROM menu_categories WHERE name='Asian Delicacies'),'Vegetable Korma','Curries','Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.',25000,20,0),
(1,(SELECT id FROM menu_categories WHERE name='Asian Delicacies'),'Veggie Biryani','Biryani','Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.',25000,30,0),
(1,(SELECT id FROM menu_categories WHERE name='Asian Delicacies'),'Chicken, Fish or Goat Biryani','Biryani','Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.',32000,40,1),
(1,(SELECT id FROM menu_categories WHERE name='Asian Delicacies'),'Chicken Coconut Curry','Curries','Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.',32000,50,1);

-- 2.14 Desserts -----------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Desserts'),'Fresh Fruit Platter','Desserts','A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.',NULL, -- suggested 20000
 10,0),
(1,(SELECT id FROM menu_categories WHERE name='Desserts'),'Fruit Salad','Desserts','A combination of diced fruits sprinkled with passion fruit syrup.',15000,20,0),
(1,(SELECT id FROM menu_categories WHERE name='Desserts'),'Banana Crepe','Desserts','A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.',15000,30,0),
(1,(SELECT id FROM menu_categories WHERE name='Desserts'),'Ice Cream','Desserts','Three scoops, chocolate, vanilla or strawberry.',9000,40,0),
(1,(SELECT id FROM menu_categories WHERE name='Desserts'),'Cake of the Day','Desserts','A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.',7000,50,0),
(1,(SELECT id FROM menu_categories WHERE name='Desserts'),'Affogato Espresso Ice Cream','Desserts','Two scoops of ice cream of your choice with 60ml of espresso coffee.',15000,60,0),
(1,(SELECT id FROM menu_categories WHERE name='Desserts'),'Banana Split','Desserts','Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.',15000,70,0);

-- 2.15 Pizzeria ------------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name='Pizzeria Section'),'Classic Margherita','Pizza','Tomato, fresh basil, oregano and mozzarella.',27000,10,0),
(1,(SELECT id FROM menu_categories WHERE name='Pizzeria Section'),'Sweet Vegetarian','Pizza','Red, yellow and green bell pepper, sweet corn and mozzarella.',27000,20,0),
(1,(SELECT id FROM menu_categories WHERE name='Pizzeria Section'),'Quattro Stagioni','Pizza','Ham, olives, mushroom, artichokes and mozzarella.',30000,30,0),
(1,(SELECT id FROM menu_categories WHERE name='Pizzeria Section'),'Pepperoni','Pizza','Tomato, green pepper, onion, pepperoni and mozzarella.',30000,40,0),
(1,(SELECT id FROM menu_categories WHERE name='Pizzeria Section'),'Hawaiian','Pizza','Ham or bacon, pineapple and mozzarella.',NULL, -- suggested 32000
 50,0),
(1,(SELECT id FROM menu_categories WHERE name='Pizzeria Section'),'Farmer''s','Pizza','Chicken, mushroom and mozzarella.',30000,60,0),
(1,(SELECT id FROM menu_categories WHERE name='Pizzeria Section'),'Tuna','Pizza','Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.',NULL, -- suggested 34000
 70,1),
(1,(SELECT id FROM menu_categories WHERE name='Pizzeria Section'),'Diavola','Pizza','Tomato, chili salami and mozzarella.',30000,80,0),
(1,(SELECT id FROM menu_categories WHERE name='Pizzeria Section'),'Bolognese','Pizza','Spicy minced meat, tomato and mozzarella.',NULL, -- 10,000 in the draft, confirm
 90,0),
(1,(SELECT id FROM menu_categories WHERE name='Pizzeria Section'),'Capricciosa','Pizza','Salami, black olives, artichokes, capers, mushroom and mozzarella.',30000,100,0),
(1,(SELECT id FROM menu_categories WHERE name='Pizzeria Section'),'Calzone','Calzone','Minced meat, green pepper and capsicum rolled in a half moon of bread.',30000,110,0),
(1,(SELECT id FROM menu_categories WHERE name='Pizzeria Section'),'Assorted Meat and Salami','Pizza','Assorted meat, salami, mushroom, green pepper, onion and mozzarella.',35000,120,0);

-- ---------------------------------------------------------------------------
-- 3. VERIFICATION — everything still waiting on a rate
-- ---------------------------------------------------------------------------
SELECT mc.name AS section, mi.name AS item
  FROM menu_items mi
  JOIN menu_categories mc ON mc.id = mi.category_id
 WHERE mi.price IS NULL
   AND mc.outlet = 'restaurant'
 ORDER BY mc.sort_order, mi.sort_order;
