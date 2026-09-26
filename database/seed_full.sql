USE hotel_paradise_nile;

INSERT INTO hotels(name,slug,city,country,currency,timezone) VALUES
('Hotel Paradise on the Nile','hotel-paradise-on-the-nile','Jinja','Uganda','UGX','Africa/Kampala');

INSERT INTO roles(name) VALUES
('super_admin'),('director'),('general_manager'),('accountant'),('cashier'),
('receptionist'),('waiter'),('bar_staff'),('kitchen'),('storekeeper'),
('procurement'),('housekeeping'),('maintenance'),('events_manager'),('marketing'),('auditor');

INSERT INTO departments(name,code) VALUES
('Front Desk','FD'),('Housekeeping','HK'),('Restaurant','RT'),('Bar','BB'),
('Kitchen','KC'),('Maintenance','MT'),('Events','EV'),('Administration','AD'),('Laundry','LD');

INSERT INTO users(hotel_id,name,email,phone,password_hash,status) VALUES
(1,'Reagan Otema (Administrator)','admin@hotelparadiseonthenile.info','0772 514 889','$2y$10$liAwR45r6zD/Vl8yzASI3ueZfJGKLnt3PSE2PRPjbL0vogo4Db5A2','active'),
(1,'Hotel Director','director@hotelparadiseonthenile.info','+256 774 000 001','$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2','active'),
(1,'General Manager','gm@hotelparadiseonthenile.info','+256 774 000 002','$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2','active'),
(1,'Finance Officer','accounts@hotelparadiseonthenile.info','+256 774 000 003','$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2','active'),
(1,'Cashier','cashier@hotelparadiseonthenile.info','+256 774 000 004','$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2','active'),
(1,'Front Desk Reception','frontdesk@hotelparadiseonthenile.info','+256 774 000 005','$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2','active'),
(1,'Restaurant Waiter','waiter@hotelparadiseonthenile.info','+256 774 000 006','$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2','active'),
(1,'Bar Staff','bar@hotelparadiseonthenile.info','+256 774 000 007','$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2','active'),
(1,'Kitchen','kitchen@hotelparadiseonthenile.info','+256 774 000 008','$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2','active'),
(1,'Storekeeper','store@hotelparadiseonthenile.info','+256 774 000 009','$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2','active'),
(1,'Procurement Officer','procurement@hotelparadiseonthenile.info','+256 774 000 010','$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2','active'),
(1,'Housekeeping','housekeeping@hotelparadiseonthenile.info','+256 774 000 011','$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2','active'),
(1,'Internal Auditor','auditor@hotelparadiseonthenile.info','+256 774 000 012','$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2','active');

INSERT INTO user_roles(user_id,role_id)
SELECT u.id,r.id FROM users u JOIN roles r ON r.name =
  (CASE u.email
    WHEN 'admin@hotelparadiseonthenile.info' THEN 'super_admin'
    WHEN 'director@hotelparadiseonthenile.info' THEN 'director'
    WHEN 'gm@hotelparadiseonthenile.info' THEN 'general_manager'
    WHEN 'accounts@hotelparadiseonthenile.info' THEN 'accountant'
    WHEN 'cashier@hotelparadiseonthenile.info' THEN 'cashier'
    WHEN 'frontdesk@hotelparadiseonthenile.info' THEN 'receptionist'
    WHEN 'waiter@hotelparadiseonthenile.info' THEN 'waiter'
    WHEN 'bar@hotelparadiseonthenile.info' THEN 'bar_staff'
    WHEN 'kitchen@hotelparadiseonthenile.info' THEN 'kitchen'
    WHEN 'store@hotelparadiseonthenile.info' THEN 'storekeeper'
    WHEN 'procurement@hotelparadiseonthenile.info' THEN 'procurement'
    WHEN 'housekeeping@hotelparadiseonthenile.info' THEN 'housekeeping'
    WHEN 'auditor@hotelparadiseonthenile.info' THEN 'auditor'
    ELSE 'super_admin' END);

INSERT INTO room_types(hotel_id,name,description,max_guests,base_rate,active) VALUES
(1,'Suite','The most spacious option at the hotel, ideal for a memorable stay.',3,248000,TRUE),
(1,'Family Room','A spacious room made for families travelling together.',4,314000,TRUE),
(1,'Triple Room','A comfortable setting for three guests.',3,213000,TRUE),
(1,'Executive Deluxe','An elevated stay with refined touches for business and leisure.',2,202000,TRUE),
(1,'Deluxe Double','Elegant double accommodation with a warm, private atmosphere.',2,178000,TRUE),
(1,'Standard Twin','A neatly kept room with two comfortable beds.',2,142000,TRUE),
(1,'Standard Single','A simple, well equipped single room.',1,128000,TRUE);

INSERT INTO rooms(hotel_id,room_type_id,room_number,floor,status)
SELECT 1, rt.id, CONCAT('S', num.n), CONCAT('Floor ', FLOOR(num.n/100)), 'available'
FROM room_types rt JOIN (
 SELECT 101 n UNION ALL SELECT 102 UNION ALL SELECT 103 UNION ALL SELECT 104 UNION ALL SELECT 105 UNION ALL SELECT 106
) num WHERE rt.name='Suite';

INSERT INTO rooms(hotel_id,room_type_id,room_number,floor,status)
SELECT 1, rt.id, CONCAT('F', num.n), CONCAT('Floor ', FLOOR(num.n/100)), 'available'
FROM room_types rt JOIN (
 SELECT 101 n UNION ALL SELECT 102 UNION ALL SELECT 103 UNION ALL SELECT 104 UNION ALL SELECT 105 UNION ALL SELECT 106 UNION ALL SELECT 107
) num WHERE rt.name='Family Room';

INSERT INTO rooms(hotel_id,room_type_id,room_number,floor,status)
SELECT 1, rt.id, CONCAT('T', num.n), CONCAT('Floor ', FLOOR(num.n/100)), 'available'
FROM room_types rt JOIN (
 SELECT 201 n UNION ALL SELECT 202 UNION ALL SELECT 203 UNION ALL SELECT 204 UNION ALL SELECT 205 UNION ALL SELECT 206 UNION ALL SELECT 207 UNION ALL SELECT 208 UNION ALL SELECT 209 UNION ALL SELECT 210 UNION ALL SELECT 211 UNION ALL SELECT 212
) num WHERE rt.name='Triple Room';

INSERT INTO rooms(hotel_id,room_type_id,room_number,floor,status)
SELECT 1, rt.id, CONCAT('ED', num.n), CONCAT('Floor ', FLOOR(num.n/100)), 'available'
FROM room_types rt JOIN (
 SELECT 201 n UNION ALL SELECT 202 UNION ALL SELECT 203 UNION ALL SELECT 204 UNION ALL SELECT 205 UNION ALL SELECT 206 UNION ALL SELECT 207 UNION ALL SELECT 208 UNION ALL SELECT 209 UNION ALL SELECT 210
) num WHERE rt.name='Executive Deluxe';

INSERT INTO rooms(hotel_id,room_type_id,room_number,floor,status)
SELECT 1, rt.id, CONCAT('DD', num.n), CONCAT('Floor ', FLOOR(num.n/100)), 'available'
FROM room_types rt JOIN (
 SELECT 301 n UNION ALL SELECT 302 UNION ALL SELECT 303 UNION ALL SELECT 304 UNION ALL SELECT 305 UNION ALL SELECT 306 UNION ALL SELECT 307 UNION ALL SELECT 308 UNION ALL SELECT 309 UNION ALL SELECT 310 UNION ALL SELECT 311 UNION ALL SELECT 312 UNION ALL SELECT 313 UNION ALL SELECT 314
) num WHERE rt.name='Deluxe Double';

INSERT INTO rooms(hotel_id,room_type_id,room_number,floor,status)
SELECT 1, rt.id, CONCAT('TW', num.n), CONCAT('Floor ', FLOOR(num.n/100)), 'available'
FROM room_types rt JOIN (
 SELECT 301 n UNION ALL SELECT 302 UNION ALL SELECT 303 UNION ALL SELECT 304 UNION ALL SELECT 305 UNION ALL SELECT 306 UNION ALL SELECT 307 UNION ALL SELECT 308 UNION ALL SELECT 309 UNION ALL SELECT 310 UNION ALL SELECT 311 UNION ALL SELECT 312
) num WHERE rt.name='Standard Twin';

INSERT INTO rooms(hotel_id,room_type_id,room_number,floor,status)
SELECT 1, rt.id, CONCAT('SG', num.n), CONCAT('Floor ', FLOOR(num.n/100)), 'available'
FROM room_types rt JOIN (
 SELECT 301 n UNION ALL SELECT 302 UNION ALL SELECT 303 UNION ALL SELECT 304 UNION ALL SELECT 305 UNION ALL SELECT 306 UNION ALL SELECT 307 UNION ALL SELECT 308
) num WHERE rt.name='Standard Single';

INSERT INTO menu_categories(hotel_id,outlet,name) VALUES
(1,'restaurant','Breakfast'),(1,'restaurant','Main Meals'),(1,'restaurant','Snacks'),
(1,'bar','Soft Drinks'),(1,'bar','Cocktails'),(1,'bar','Beers and Ciders'),(1,'bar','Wines and Spirits'),
(1,'room_service','Room Service');

INSERT INTO menu_items(hotel_id,category_id,name,description,price,stock_tracked)
SELECT 1, c.id, m.name, m.dsc, m.price, m.track FROM menu_categories c JOIN (
 SELECT 'Breakfast' cat,'Full Breakfast' name,'Eggs, sausages, toast, baked beans and tea or coffee' dsc,25000 price,0 track
 UNION ALL SELECT 'Breakfast','Continental Breakfast','Pastries, fresh fruit, juice and hot drink',20000,0
 UNION ALL SELECT 'Breakfast','Local Breakfast','Chapati, eggs and a hot local drink',22000,0
 UNION ALL SELECT 'Main Meals','Grilled Nile Perch','Fresh Nile perch fillet with rice and vegetables',45000,1
 UNION ALL SELECT 'Main Meals','Beef Stew and Rice','Slow cooked beef stew with steamed rice',35000,1
 UNION ALL SELECT 'Main Meals','Chicken and Chips','Grilled chicken with golden chips and salad',38000,1
 UNION ALL SELECT 'Main Meals','Buffet Plate','Daily buffet selection, meals from noon to 3pm and 7pm to 11pm',40000,1
 UNION ALL SELECT 'Main Meals','Chef Signature Plate','A seasonal chef special, ask the kitchen for today',45000,1
 UNION ALL SELECT 'Snacks','Fresh Juice','Seasonal fruit juice, made to order',12000,1
 UNION ALL SELECT 'Snacks','Samosas','Three vegetable or meat samosas',10000,1
 UNION ALL SELECT 'Snacks','Chips and Ketchup','A generous bowl of golden chips',12000,1
 UNION ALL SELECT 'Snacks','Chapati','Freshly rolled and griddled',5000,1
 UNION ALL SELECT 'Soft Drinks','Coca Cola 300ml','Ice cold bottle',3000,1
 UNION ALL SELECT 'Soft Drinks','Fanta 300ml','Orange or passion fruit',3000,1
 UNION ALL SELECT 'Soft Drinks','Mineral Water 500ml','Chilled bottled water',2000,1
 UNION ALL SELECT 'Cocktails','Paradise Sunset','House signature cocktail with a Nile twist',25000,1
 UNION ALL SELECT 'Cocktails','Nile Breeze','Light, refreshing cocktail of the house',25000,1
 UNION ALL SELECT 'Beers and Ciders','Nile Special','500ml bottle',5000,1
 UNION ALL SELECT 'Beers and Ciders','Club Pilsener','500ml bottle',5000,1
 UNION ALL SELECT 'Beers and Ciders','Bell Lager','500ml bottle',5000,1
 UNION ALL SELECT 'Wines and Spirits','House White Wine','Glass of the house white wine',20000,1
 UNION ALL SELECT 'Wines and Spirits','Local Spirit','Uganda Waragi or other local spirit',15000,1
 UNION ALL SELECT 'Room Service','Room Service Breakfast','Full breakfast delivered to your room',28000,1
 UNION ALL SELECT 'Room Service','Room Service Platter','Nile grilled selection delivered to your room',45000,1
) m ON m.cat=c.name;

INSERT INTO inventory_categories(name) VALUES
('Beverages'),('Kitchen'),('Housekeeping Supplies'),('Maintenance'),('Stationery');

INSERT INTO inventory_items(hotel_id,category_id,code,name,unit,reorder_level,active)
SELECT 1,c.id,x.code,x.name,x.unit,x.reorder,1 FROM inventory_categories c JOIN (
 SELECT 'Beverages' cat,'NVG-BEV-001' code,'Nile Special Beer' name,'carton' unit,6 reorder
 UNION ALL SELECT 'Beverages','NVG-BEV-002','Coca Cola','crate',4
 UNION ALL SELECT 'Beverages','NVG-BEV-003','Bottled Water 500ml','carton',8
 UNION ALL SELECT 'Kitchen','NVG-KIT-001','Cooking Oil 6L','jerry',3
 UNION ALL SELECT 'Kitchen','NVG-KIT-002','Fresh Tomatoes','kg',10
 UNION ALL SELECT 'Kitchen','NVG-KIT-003','Beef','kg',12
 UNION ALL SELECT 'Kitchen','NVG-KIT-004','Mixing Flour 50kg','bag',2
 UNION ALL SELECT 'Kitchen','NVG-KIT-005','Fresh Eggs','tray',6
 UNION ALL SELECT 'Housekeeping Supplies','NVG-HSK-001','Laundry Bar Soap','bar',20
 UNION ALL SELECT 'Housekeeping Supplies','NVG-HSK-002','Toilet Paper','roll',60
 UNION ALL SELECT 'Housekeeping Supplies','NVG-HSK-003','All Purpose Cleaner','litre',8
 UNION ALL SELECT 'Maintenance','NVG-MNT-001','Electrical Tape','roll',4
 UNION ALL SELECT 'Maintenance','NVG-MNT-002','LED Bulb 9W','piece',10
 UNION ALL SELECT 'Stationery','NVG-STN-001','A4 Printer Paper','ream',5
 UNION ALL SELECT 'Stationery','NVG-STN-002','Receipt Roll 80mm','roll',20
) x ON x.cat=c.name;

INSERT INTO stock_levels(hotel_id,item_id,location,quantity)
SELECT 1, i.id, 'Main Store', s.qty FROM inventory_items i JOIN (
 SELECT code, qty FROM (
  SELECT 'NVG-BEV-001' code,20 qty UNION ALL SELECT 'NVG-BEV-002',15 UNION ALL SELECT 'NVG-BEV-003',30
  UNION ALL SELECT 'NVG-KIT-001',5 UNION ALL SELECT 'NVG-KIT-002',25 UNION ALL SELECT 'NVG-KIT-003',30
  UNION ALL SELECT 'NVG-KIT-004',3 UNION ALL SELECT 'NVG-KIT-005',8
  UNION ALL SELECT 'NVG-HSK-001',40 UNION ALL SELECT 'NVG-HSK-002',100 UNION ALL SELECT 'NVG-HSK-003',10
  UNION ALL SELECT 'NVG-MNT-001',6 UNION ALL SELECT 'NVG-MNT-002',15
  UNION ALL SELECT 'NVG-STN-001',8 UNION ALL SELECT 'NVG-STN-002',25
 ) t
) s ON s.code=i.code;

INSERT INTO suppliers(hotel_id,name,contact_person,phone,email,address,tax_id) VALUES
(1,'Nile Distributors Ltd','Charles Okello','+256 771 220 001','orders@niledistributors.ug','Nasser Road, Jinja','NP-0001'),
(1,'Jinja Fresh Produce','Fatuma Nakato','+256 772 220 002','fatuma@jinfresh.ug','Main Market, Jinja','JF-2200'),
(1,'Uganda Breweries Supply','David Ssewanyana','+256 773 220 003','supply@brewug.ug','Kampala','UB-3388'),
(1,'Super Clean Supplies','Rita Atim','+256 774 220 004','rt@superclean.ug','Madhivani Road, Jinja','SC-1144'),
(1,'Kampala Paper Mart','Paul Mugisha','+256 775 220 005','pm@kpmar.ug','Kampala Road, Kampala','KM-7789');

INSERT INTO guests(hotel_id,full_name,phone,email,nationality,id_type,id_number) VALUES
(1,'Grace Akello','+256 770 111 001','grace.akello@example.com','Ugandan','National ID','CM11-8890'),
(1,'John Mukasa','+256 770 111 002','john.mukasa@example.com','Ugandan','Passport','UG-P-4471'),
(1,'Sarah Namuli','+256 770 111 003','sarah.namuli@example.com','Ugandan','National ID','CM22-0317'),
(1,'David Okello','+256 770 111 004','david.okello@example.com','Kenyan','Passport','KE-A-9012'),
(1,'Amelia Turner','+256 770 111 005','amelia.turner@example.com','British','Passport','GB-5522');

INSERT INTO reservations(hotel_id,guest_id,booking_number,source,check_in,check_out,adults,children,status,room_rate,nights,subtotal,tax,total,paid,notes,created_at) VALUES
(1,1,'HPN-20260925-001','phone','2026-09-25 14:00','2026-09-28 11:00',2,0,'checked_in',248000,3,744000,0,744000,744000,'Birthday weekend by the Nile',NOW()),
(1,2,'HPN-20260925-002','website','2026-10-02 14:00','2026-10-04 11:00',2,1,'confirmed',202000,2,404000,0,404000,0,'',NOW()),
(1,3,'HPN-20260925-003','walk_in','2026-10-05 14:00','2026-10-07 11:00',3,0,'confirmed',213000,2,426000,0,426000,0,'',NOW()),
(1,4,'HPN-20260925-004','agent','2026-09-20 14:00','2026-09-23 11:00',2,0,'checked_out',314000,3,942000,0,942000,942000,'Family holiday',NOW());

INSERT INTO reservation_rooms(reservation_id,room_type_id,room_id,quantity,nightly_rate)
SELECT r.id, rt.id, rn.id, 1, r.room_rate FROM reservations r JOIN room_types rt ON rt.name='Suite' JOIN rooms rn ON rn.room_type_id=rt.id AND rn.room_number='S101' WHERE r.guest_id=1;

INSERT INTO reservation_rooms(reservation_id,room_type_id,room_id,quantity,nightly_rate)
SELECT r.id, rt.id, rn.id, 1, r.room_rate FROM reservations r JOIN room_types rt ON rt.name='Executive Deluxe' JOIN rooms rn ON rn.room_type_id=rt.id AND rn.room_number='ED201' WHERE r.guest_id=2;

INSERT INTO reservation_rooms(reservation_id,room_type_id,room_id,quantity,nightly_rate)
SELECT r.id, rt.id, rn.id, 1, r.room_rate FROM reservations r JOIN room_types rt ON rt.name='Triple Room' JOIN rooms rn ON rn.room_type_id=rt.id AND rn.room_number='T201' WHERE r.guest_id=3;

INSERT INTO reservation_rooms(reservation_id,room_type_id,room_id,quantity,nightly_rate)
SELECT r.id, rt.id, rn.id, 1, r.room_rate FROM reservations r JOIN room_types rt ON rt.name='Family Room' JOIN rooms rn ON rn.room_type_id=rt.id AND rn.room_number='F101' WHERE r.guest_id=4;

INSERT INTO invoices(hotel_id,guest_id,invoice_number,subtotal,tax,total,status) VALUES
(1,1,'INV-HPN-20260925-0001',744000,0,744000,'paid');

INSERT INTO payments(hotel_id,user_id,invoice_id,reservation_id,amount,method,status) VALUES
(1,6,1,1,744000,'cash','successful');