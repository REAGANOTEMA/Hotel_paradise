-- HOTEL PARADISE ON THE NILE - COMPLETE MENU SEED
-- Generated from frontend-react/src/menuData.ts by database/tools/build-menu-seed.mjs
-- Do not hand edit. Re-run the generator instead.
--
-- 15 sections, 81 dishes. A dish priced on request is stored
-- as NULL, which is what the website reads as "Priced on request".
--
-- Safe to run more than once: the dishes are matched on their name, so running
-- it again refreshes the menu instead of duplicating it.

USE `hotelpardise_system`;

DELETE FROM menu_items WHERE hotel_id = 1;
DELETE FROM menu_categories WHERE hotel_id = 1;

INSERT INTO menu_categories (id,hotel_id,outlet,name,eyebrow,blurb,image,sort_order) VALUES
(1,'restaurant','Starters','To begin','Warm soups, the sandwich corner and freshly dressed salads.','',1),
(2,'restaurant','Egg Dishes','From the pan','Classic egg plates finished to order.','',2),
(3,'restaurant','Burgers','The grill','Charcoal patties, regular or Cajun, in a soft toasted bun.','',3),
(4,'restaurant','Wraps and Rolex','Rolled fresh','Shredded fillings rolled warm in a soft tortilla.','',4),
(5,'restaurant','Snacks','Light bites','Served with a choice of rice or chips.','',5),
(6,'restaurant','Italian Special Pastas','From Napoli','Fresh pasta finished with melted cheese and a slice of toast.','',6),
(7,'restaurant','Fisherman''s Offer','Fresh from the Nile','Whole tilapia, fried, steamed or grilled. Oil free off the grill.','',7),
(8,'restaurant','Fish Fillets','The catch','Breaded, battered or simply grilled, with rice or chips.','',8),
(9,'restaurant','Chicken Lovers','Poultry','Marinated overnight, then grilled, pan fried or tossed in sauce.','',9),
(10,'restaurant','Paradise Hunter''s Delicacies','Steaks and grills','Prime beef fillet, skewers and the hunter''s favourites.','',10),
(11,'restaurant','Pork','Pork','Slow roasted, glazed and grilled to your liking.','',11),
(12,'restaurant','House Specials','For the table','Platters built for sharing, served with two accompaniments.','',12),
(13,'restaurant','Asian Delicacies','Far East','Mild creamy curries, biryani and coconut dishes with rice or chapatti.','',13),
(14,'restaurant','Desserts','Sweet finish','Fresh fruit, ice cream and a little sugar.','',14),
(15,'restaurant','Pizzeria Section','Pizza','Baked to order on a stone base, 12 inch.','',15);

INSERT INTO menu_items (id,hotel_id,category_id,name,group_name,description,price,image,sort_order,active) VALUES
(1,1,'Mushroom Soup','Soups','Creamy forest mushroom soup, homemade style, served with a bread roll.',12000,'',1),
(2,1,'Clear Chicken and Beef Noodle Soup','Soups','Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.',15000,'',2),
(3,1,'Classic BLT Sandwich','Sandwich Corner','Crisp bacon, lettuce and ripe tomato in a toasted roll.',25000,'',3),
(4,1,'Three Decker Sandwich','Sandwich Corner','Three decker of bacon, lettuce and tomato, served with chips.',NULL,'',4),
(5,1,'Tuna Melt','Sandwich Corner','Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.',25000,'',5),
(6,1,'Paradise Club Sandwich','Sandwich Corner','Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.',30000,'',6),
(7,1,'Grilled Veggies Salad','Salads','Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.',18000,'',7),
(8,1,'Grilled Chicken Salad','Salads','Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.',15000,'',8),
(9,1,'Tuna Salad','Salads','Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.',20000,'',9),
(10,2,'Spanish Omelet','Egg Dishes','Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.',15000,'',10),
(11,2,'Avocado with an Egg','Egg Dishes','Avocado and a fried egg on toasted bread with a garnish.',13000,'',11),
(12,2,'Bacon and Cheese Omelet','Egg Dishes','Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.',NULL,'',12),
(13,3,'Vegetable Burger','Burgers','Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.',20000,'',13),
(14,3,'Chicken and Beef Burger','Burgers','Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.',NULL,'',14),
(15,3,'BBQ Beef and Chicken Patty','Burgers','Grilled beef or chicken patty finished in a tangy barbecue sauce.',NULL,'',15),
(16,3,'Double Beef and Bacon Burger','Burgers','Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.',NULL,'',16),
(17,4,'Chicken Wrap','Wraps','Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.',20000,'',17),
(18,4,'Crunchy Vegetable Wrap','Wraps','Sautéed vegetables with a touch of cheddar cheese, served plain.',14000,'',18),
(19,4,'Chicken and Beef Rolex','Wraps','Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.',15000,'',19),
(20,5,'Chilli Beef and Veggie Chips','Snacks','Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.',NULL,'',20),
(21,5,'Chicken Spring Rolls','Snacks','A pair of crisp chicken spring rolls.',6000,'',21),
(22,5,'Liver with Shredded Vegetables','Snacks','Flakes of liver tossed with shredded vegetables, served with rice or chips.',30000,'',22),
(23,5,'Fish Fingers with Chips','Snacks','Crisp breaded fish fingers with a portion of chips.',30000,'',23),
(24,5,'Chicken Wings with Chips','Snacks','Crispy chicken wings with a portion of chips.',28000,'',24),
(25,5,'Chicken Lollipops with Chips','Snacks','Chicken lollipops with a portion of chips.',30000,'',25),
(26,6,'Pasta Arrabbiata','Pasta','Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.',20000,'',26),
(27,6,'Pasta Bolognese','Pasta','Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.',25000,'',27),
(28,6,'Pasta Carbonara','Pasta','Pasta with egg and bacon cream sauce, topped with cheese and served with toast.',30000,'',28),
(29,7,'Premium Whole Tilapia, Fried or Steamed','Whole Fish','Medium premium tilapia, fried or steamed, served with chips.',NULL,'',29),
(30,7,'Premium Wet Fried Tilapia','Whole Fish','Premium tilapia in a seasoned wet fry.',NULL,'',30),
(31,7,'Grilled Premium Tilapia','Whole Fish','Whole oven grilled, oil free, premium tilapia, with an accompaniment of your choice.',NULL,'',31),
(32,7,'Large Whole Tilapia, Fried or Steamed','Whole Fish','Large king tilapia, fried or steamed, served with chips.',NULL,'',32),
(33,7,'Grilled Tilapia Fillet, Spinach and Cheese','Whole Fish','Grilled tilapia fillet in a creamy spinach and cheese sauce, with an accompaniment of your choice.',NULL,'',33),
(34,8,'Paradise Rustica Fish','Fish Fillets','Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.',32000,'',34),
(35,8,'Mombasa Fish','Fish Fillets','Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.',32000,'',35),
(36,8,'Deep Fried or Pan Grilled Fillet','Fish Fillets','Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.',32000,'',36),
(37,8,'Catch of the Day','Fish Fillets','Pan grilled Nile perch fillet served with rice or chips.',NULL,'',37),
(38,9,'Chicken Saute','Chicken Lovers','Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.',30000,'',38),
(39,9,'BBQ Chicken Drumstick','Chicken Lovers','Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.',30000,'',39),
(40,9,'Grilled Quarter Chicken Breast or Thigh','Chicken Lovers','Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.',45000,'',40),
(41,9,'Paradise Grilled Farm Chicken','Chicken Lovers','A well marinated chicken grilled to perfection with aromatic seasonings.',40000,'',41),
(42,9,'Pan Fried Boneless Chicken Breast','Chicken Lovers','Fresh pan fried boneless chicken breast resting in mushroom sauce.',43000,'',42),
(43,10,'Beef Fillet Steak','Steaks','Beef fillet steak, choose pepper, mushroom or dry onion sauce, served with an accompaniment of your choice.',35000,'',43),
(44,10,'King Steak','Steaks','Apportioned beef fillet, pan fried to your preference, topped with a fried egg and served with an accompaniment of your choice.',40000,'',44),
(45,10,'Beef Stroganoff','Steaks','Slow cooked beef in mushroom and red wine sauce, finished with cream.',15000,'',45),
(46,10,'Beef Stir Fry','Steaks','Tender beef strips grilled to perfection with aromatised vegetables and a hint of tomato sauce.',35000,'',46),
(47,10,'Paradise Mixed Grill','Steaks','A mixture of grills, chicken, steak and fish fillet, topped with a fried egg and served with chips.',47000,'',47),
(48,10,'Honey Glazed Hawaiian Beef Skewers','Steaks','Three skewered beef sticks with pineapple and vegetable condiments, laced with natural honey, served with chips.',35000,'',48),
(49,10,'Beef Wet Fry','Steaks','Tender well seasoned beef fillet infused in a flavoured black peppercorn sauce, served with rice.',15000,'',49),
(50,10,'Goat Muchomo','Steaks','Well marinated chunks of goat roasted in organic fresh vegetables with a touch of tomato and barbecue sauce.',NULL,'',50),
(51,11,'Paradise Grilled Pork Chops','Pork','Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.',NULL,'',51),
(52,11,'Honey Mustard Glazed Pork Ribs','Pork','Tender juicy ribs of pork roasted in onion rings and honey.',NULL,'',52),
(53,11,'Pork Muchomo','Pork','Boneless chunks of pork roasted in aromatic vegetables, served with chips.',NULL,'',53),
(54,11,'Sweet and Sour Pork','Pork','Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.',NULL,'',54),
(55,11,'Pork Muchomo and Chops Platter','Pork','A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.',35000,'',55),
(56,12,'Paradise Lusaniya','House Specials','A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.',100000,'',56),
(57,12,'Mixed Grill Platter','House Specials','A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.',80000,'',57),
(58,13,'Mixed Vegetable Curry','Curries','Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.',20000,'',58),
(59,13,'Vegetable Korma','Curries','Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.',25000,'',59),
(60,13,'Chicken Coconut Curry','Curries','Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.',32000,'',60),
(61,13,'Veggie Biryani','Biryani','Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.',25000,'',61),
(62,13,'Chicken, Fish or Goat Biryani','Biryani','Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.',32000,'',62),
(63,14,'Fresh Fruit Platter','Desserts','A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.',NULL,'',63),
(64,14,'Fruit Salad','Desserts','A combination of diced fruits sprinkled with passion fruit syrup.',15000,'',64),
(65,14,'Banana Crepe','Desserts','A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.',15000,'',65),
(66,14,'Ice Cream','Desserts','Three scoops, chocolate, vanilla or strawberry.',9000,'',66),
(67,14,'Cake of the Day','Desserts','A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.',7000,'',67),
(68,14,'Affogato Espresso Ice Cream','Desserts','Two scoops of ice cream of your choice with 60ml of espresso coffee.',15000,'',68),
(69,14,'Banana Split','Desserts','Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.',15000,'',69),
(70,15,'Classic Margherita','Pizza','Tomato, fresh basil, oregano and mozzarella.',27000,'',70),
(71,15,'Sweet Vegetarian','Pizza','Red, yellow and green bell pepper, sweet corn and mozzarella.',27000,'',71),
(72,15,'Quattro Stagioni','Pizza','Ham, olives, mushroom, artichokes and mozzarella.',30000,'',72),
(73,15,'Pepperoni','Pizza','Tomato, green pepper, onion, pepperoni and mozzarella.',30000,'',73),
(74,15,'Hawaiian','Pizza','Ham or bacon, pineapple and mozzarella.',NULL,'',74),
(75,15,'Farmer''s','Pizza','Chicken, mushroom and mozzarella.',30000,'',75),
(76,15,'Tuna','Pizza','Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.',NULL,'',76),
(77,15,'Diavola','Pizza','Tomato, chili salami and mozzarella.',30000,'',77),
(78,15,'Bolognese','Pizza','Spicy minced meat, tomato and mozzarella.',NULL,'',78),
(79,15,'Capricciosa','Pizza','Salami, black olives, artichokes, capers, mushroom and mozzarella.',30000,'',79),
(80,15,'Assorted Meat and Salami','Pizza','Assorted meat, salami, mushroom, green pepper, onion and mozzarella.',35000,'',80),
(81,15,'Calzone','Calzone','Minced meat, green pepper and capsicum rolled in a half moon of bread.',30000,'',81);

SELECT COUNT(*) AS sections FROM menu_categories WHERE hotel_id = 1;
SELECT COUNT(*) AS dishes, SUM(price IS NULL) AS priced_on_request FROM menu_items WHERE hotel_id = 1 AND active = 1;
