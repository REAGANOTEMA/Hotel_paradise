USE hotel_paradise_nile;

INSERT INTO hotels(name,slug,city,country,currency,timezone)
VALUES ('Hotel Paradise on the Nile','hotel-paradise-on-the-nile','Jinja','Uganda','UGX','Africa/Kampala')
ON DUPLICATE KEY UPDATE
  name=VALUES(name), city=VALUES(city), country=VALUES(country),
  currency=VALUES(currency), timezone=VALUES(timezone);

INSERT INTO roles(name) VALUES
('super_admin'),('director'),('general_manager'),('receptionist'),('cashier'),
('accountant'),('waiter'),('bar_staff'),('kitchen'),('housekeeping'),
('maintenance'),('inventory_manager'),('events_manager'),('marketing'),('guest')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO menu_categories(hotel_id,outlet,name) VALUES
(1,'restaurant','Breakfast'),
(1,'restaurant','Main Meals'),
(1,'restaurant','Snacks'),
(1,'bar','Soft Drinks'),
(1,'bar','Cocktails'),
(1,'bar','Beers & Ciders'),
(1,'bar','Wines & Spirits'),
(1,'room_service','Room Service')
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), outlet=VALUES(outlet), name=VALUES(name);
