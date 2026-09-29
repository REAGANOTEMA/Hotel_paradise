-- ============================================================================
-- SUPERSEDED. DO NOT USE THIS FILE FOR A NEW INSTALL.
--
-- This is the old single-file installer. It is kept only for reference, and it
-- is no longer correct: it creates a menu of 15 dishes rather than the full 81,
-- and it predates the `published` column that now decides what the website
-- shows. An install made from it would serve a stale menu.
--
-- To install, follow database/HOSTING.md, which uses these five files in order:
--
--   05_HOSTING_INSTALL.sql                     databases, users and rights
--   01_LIVE_SYSTEM_SCHEMA.sql                  the 32 tables
--   02_LIVE_SYSTEM_SEED.sql                    the hotel, staff, rooms
--   07_FULL_MENU_SEED.sql                      all 15 sections and 81 dishes
--   website_sql/01_WEBSITE_INTEGRATION_SCHEMA.sql   the website's own table
--
-- Everything below is kept as it was, unchanged.
-- ============================================================================
-- HOTEL PARADISE ON THE NILE — LIVE INSTALLER
-- Designed by Reagansoft Innovation Limited

-- Hotel Paradise on the Nile - Full schema
CREATE DATABASE IF NOT EXISTS hotelpardise_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hotelpardise_system;

CREATE TABLE IF NOT EXISTS hotels (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(190) NOT NULL,
 slug VARCHAR(190) UNIQUE NOT NULL,
 city VARCHAR(100) DEFAULT 'Jinja',
 country VARCHAR(100) DEFAULT 'Uganda',
 currency CHAR(3) DEFAULT 'UGX',
 timezone VARCHAR(64) DEFAULT 'Africa/Kampala',
 created_at TIMESTAMP NULL,
 updated_at TIMESTAMP NULL
);

CREATE TABLE IF NOT EXISTS users (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NULL,
 name VARCHAR(190) NOT NULL,
 email VARCHAR(190) UNIQUE NULL,
 phone VARCHAR(50) UNIQUE NULL,
 password_hash VARCHAR(255) NOT NULL,
 status ENUM('pending','active','suspended') DEFAULT 'pending',
 created_at TIMESTAMP NULL,
 updated_at TIMESTAMP NULL,
 FOREIGN KEY (hotel_id) REFERENCES hotels(id)
);

CREATE TABLE IF NOT EXISTS roles (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(80) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS user_roles (
 user_id BIGINT UNSIGNED NOT NULL,
 role_id BIGINT UNSIGNED NOT NULL,
 PRIMARY KEY(user_id, role_id),
 FOREIGN KEY(user_id) REFERENCES users(id),
 FOREIGN KEY(role_id) REFERENCES roles(id)
);

CREATE TABLE IF NOT EXISTS departments (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(120) NOT NULL,
 code VARCHAR(30) UNIQUE,
 active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS room_types (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 name VARCHAR(120) NOT NULL,
 description TEXT,
 max_guests INT NOT NULL DEFAULT 1,
 base_rate DECIMAL(14,2) NOT NULL,
 active BOOLEAN NOT NULL DEFAULT TRUE,
 FOREIGN KEY(hotel_id) REFERENCES hotels(id)
);

CREATE TABLE IF NOT EXISTS rooms (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 room_type_id BIGINT UNSIGNED NOT NULL,
 room_number VARCHAR(30) NOT NULL,
 floor VARCHAR(30),
 status ENUM('available','reserved','occupied','dirty','cleaning','inspected','maintenance','out_of_service') DEFAULT 'available',
 FOREIGN KEY(hotel_id) REFERENCES hotels(id),
 FOREIGN KEY(room_type_id) REFERENCES room_types(id),
 UNIQUE(hotel_id, room_number)
);

CREATE TABLE IF NOT EXISTS guests (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NULL,
 hotel_id BIGINT UNSIGNED NOT NULL,
 full_name VARCHAR(190) NOT NULL,
 phone VARCHAR(50),
 email VARCHAR(190),
 nationality VARCHAR(100),
 id_type VARCHAR(50),
 id_number VARCHAR(100),
 created_at TIMESTAMP NULL,
 updated_at TIMESTAMP NULL,
 FOREIGN KEY(user_id) REFERENCES users(id),
 FOREIGN KEY(hotel_id) REFERENCES hotels(id)
);

CREATE TABLE IF NOT EXISTS reservations (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 guest_id BIGINT UNSIGNED NOT NULL,
 booking_number VARCHAR(60) UNIQUE NOT NULL,
 source ENUM('website','walk_in','phone','email','agent','other') DEFAULT 'walk_in',
 check_in DATETIME NOT NULL,
 check_out DATETIME NOT NULL,
 adults INT DEFAULT 1,
 children INT DEFAULT 0,
 status ENUM('pending','confirmed','checked_in','checked_out','cancelled','no_show') DEFAULT 'pending',
 room_rate DECIMAL(14,2) DEFAULT 0,
 nights INT DEFAULT 1,
 subtotal DECIMAL(14,2) NOT NULL DEFAULT 0,
 tax DECIMAL(14,2) NOT NULL DEFAULT 0,
 total DECIMAL(14,2) NOT NULL DEFAULT 0,
 paid DECIMAL(14,2) NOT NULL DEFAULT 0,
 notes TEXT,
 created_at TIMESTAMP NULL,
 updated_at TIMESTAMP NULL,
 FOREIGN KEY(hotel_id) REFERENCES hotels(id),
 FOREIGN KEY(guest_id) REFERENCES guests(id)
);

CREATE TABLE IF NOT EXISTS reservation_rooms (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 reservation_id BIGINT UNSIGNED NOT NULL,
 room_type_id BIGINT UNSIGNED NOT NULL,
 room_id BIGINT UNSIGNED NULL,
 quantity INT DEFAULT 1,
 nightly_rate DECIMAL(14,2) NOT NULL,
 FOREIGN KEY(reservation_id) REFERENCES reservations(id),
 FOREIGN KEY(room_type_id) REFERENCES room_types(id),
 FOREIGN KEY(room_id) REFERENCES rooms(id)
);

CREATE TABLE IF NOT EXISTS menu_categories (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  hotel_id BIGINT UNSIGNED NOT NULL,
  outlet ENUM('restaurant','bar','room_service') NOT NULL,
  name VARCHAR(120) NOT NULL,
  eyebrow VARCHAR(120) DEFAULT NULL,
  blurb TEXT DEFAULT NULL,
  image VARCHAR(190) DEFAULT NULL,
  sort_order INT NOT NULL DEFAULT 0
);

CREATE TABLE IF NOT EXISTS menu_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  hotel_id BIGINT UNSIGNED NOT NULL,
  category_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(190) NOT NULL,
  description TEXT,
  price DECIMAL(14,2) DEFAULT NULL,
  image VARCHAR(190) DEFAULT NULL,
  group_name VARCHAR(120) DEFAULT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  active BOOLEAN DEFAULT TRUE,
  stock_tracked BOOLEAN DEFAULT TRUE,
  FOREIGN KEY(category_id) REFERENCES menu_categories(id)
);

CREATE TABLE IF NOT EXISTS shifts (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 user_id BIGINT UNSIGNED NOT NULL,
 outlet ENUM('restaurant','bar','front_desk','kitchen','store') NOT NULL,
 opened_at DATETIME NOT NULL,
 closed_at DATETIME NULL,
 opening_cash DECIMAL(14,2) DEFAULT 0,
 expected_cash DECIMAL(14,2) DEFAULT 0,
 counted_cash DECIMAL(14,2) DEFAULT 0,
 variance DECIMAL(14,2) DEFAULT 0,
 status ENUM('open','closed') DEFAULT 'open',
 FOREIGN KEY(hotel_id) REFERENCES hotels(id),
 FOREIGN KEY(user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS orders (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 user_id BIGINT UNSIGNED NOT NULL,
 shift_id BIGINT UNSIGNED NULL,
 order_number VARCHAR(60) UNIQUE NOT NULL,
 outlet ENUM('restaurant','bar','room_service') NOT NULL,
 order_type ENUM('table','room','takeaway','delivery') NOT NULL,
 table_name VARCHAR(60),
 room_id BIGINT UNSIGNED NULL,
 status ENUM('pending','accepted','preparing','ready','served','partially_paid','paid','cancelled') DEFAULT 'pending',
 discount DECIMAL(14,2) DEFAULT 0,
 subtotal DECIMAL(14,2) DEFAULT 0,
 tax DECIMAL(14,2) DEFAULT 0,
 total DECIMAL(14,2) DEFAULT 0,
 created_at TIMESTAMP NULL,
 FOREIGN KEY(shift_id) REFERENCES shifts(id),
 FOREIGN KEY(room_id) REFERENCES rooms(id)
);

CREATE TABLE IF NOT EXISTS order_items (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 order_id BIGINT UNSIGNED NOT NULL,
 menu_item_id BIGINT UNSIGNED NOT NULL,
 quantity DECIMAL(12,2) NOT NULL,
 unit_price DECIMAL(14,2) NOT NULL,
 total DECIMAL(14,2) NOT NULL,
 notes TEXT,
 FOREIGN KEY(order_id) REFERENCES orders(id),
 FOREIGN KEY(menu_item_id) REFERENCES menu_items(id)
);

CREATE TABLE IF NOT EXISTS invoices (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 guest_id BIGINT UNSIGNED NULL,
 invoice_number VARCHAR(80) UNIQUE NOT NULL,
 subtotal DECIMAL(14,2) DEFAULT 0,
 tax DECIMAL(14,2) DEFAULT 0,
 total DECIMAL(14,2) DEFAULT 0,
 status ENUM('draft','issued','partially_paid','paid','cancelled','refunded') DEFAULT 'draft',
 created_at TIMESTAMP NULL
);

CREATE TABLE IF NOT EXISTS payments (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 user_id BIGINT UNSIGNED NULL,
 invoice_id BIGINT UNSIGNED NULL,
 order_id BIGINT UNSIGNED NULL,
 reservation_id BIGINT UNSIGNED NULL,
 amount DECIMAL(14,2) NOT NULL,
 method VARCHAR(50) NOT NULL,
 provider VARCHAR(100),
 provider_reference VARCHAR(190),
 status ENUM('pending','successful','failed','refunded','reversed') DEFAULT 'pending',
 created_at TIMESTAMP NULL
);

CREATE TABLE IF NOT EXISTS voids (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 ref_type ENUM('order','payment','invoice','reservation') NOT NULL,
 ref_id BIGINT UNSIGNED NOT NULL,
 reason VARCHAR(255) NOT NULL,
 amount DECIMAL(14,2) NOT NULL,
 user_id BIGINT UNSIGNED NOT NULL,
 approved_by BIGINT UNSIGNED NULL,
 created_at TIMESTAMP NULL
);

CREATE TABLE IF NOT EXISTS guest_folio_entries (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 reservation_id BIGINT UNSIGNED NOT NULL,
 entry_type ENUM('charge','payment','adjustment','refund') NOT NULL,
 description VARCHAR(255) NOT NULL,
 amount DECIMAL(14,2) NOT NULL,
 user_id BIGINT UNSIGNED NOT NULL,
 created_at TIMESTAMP NULL,
 FOREIGN KEY(reservation_id) REFERENCES reservations(id)
);

CREATE TABLE IF NOT EXISTS inventory_categories (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(120) NOT NULL UNIQUE,
 active BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS inventory_items (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 category_id BIGINT UNSIGNED NULL,
 code VARCHAR(40) UNIQUE,
 name VARCHAR(190) NOT NULL,
 unit VARCHAR(40) NOT NULL DEFAULT 'each',
 reorder_level DECIMAL(14,2) DEFAULT 0,
 active BOOLEAN DEFAULT TRUE,
 FOREIGN KEY(category_id) REFERENCES inventory_categories(id)
);

CREATE TABLE IF NOT EXISTS stock_levels (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 item_id BIGINT UNSIGNED NOT NULL,
 location VARCHAR(60) NOT NULL DEFAULT 'Main Store',
 quantity DECIMAL(14,2) NOT NULL DEFAULT 0,
 FOREIGN KEY(item_id) REFERENCES inventory_items(id),
 UNIQUE(item_id, location)
);

CREATE TABLE IF NOT EXISTS stock_movements (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 item_id BIGINT UNSIGNED NOT NULL,
 location VARCHAR(60) NOT NULL,
 type ENUM('purchase_in','issue','waste','transfer_in','transfer_out','count_adjust','opening') NOT NULL,
 quantity DECIMAL(14,2) NOT NULL,
 unit_cost DECIMAL(14,2) DEFAULT 0,
 reference_type VARCHAR(60),
 reference_id BIGINT UNSIGNED,
 note VARCHAR(255),
 user_id BIGINT UNSIGNED NOT NULL,
 created_at TIMESTAMP NULL,
 FOREIGN KEY(item_id) REFERENCES inventory_items(id)
);

CREATE TABLE IF NOT EXISTS stock_counts (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 count_number VARCHAR(40) UNIQUE NOT NULL,
 status ENUM('draft','final') DEFAULT 'draft',
 counted_by BIGINT UNSIGNED NOT NULL,
 counted_at DATETIME NULL,
 FOREIGN KEY(counted_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS stock_count_items (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 count_id BIGINT UNSIGNED NOT NULL,
 item_id BIGINT UNSIGNED NOT NULL,
 system_qty DECIMAL(14,2) NOT NULL,
 counted_qty DECIMAL(14,2) NOT NULL,
 variance DECIMAL(14,2) NOT NULL,
 FOREIGN KEY(count_id) REFERENCES stock_counts(id),
 FOREIGN KEY(item_id) REFERENCES inventory_items(id)
);

CREATE TABLE IF NOT EXISTS suppliers (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 name VARCHAR(190) NOT NULL,
 contact_person VARCHAR(120),
 phone VARCHAR(50),
 email VARCHAR(190),
 address VARCHAR(255),
 tax_id VARCHAR(80),
 active BOOLEAN DEFAULT TRUE,
 created_at TIMESTAMP NULL
);

CREATE TABLE IF NOT EXISTS purchase_requisitions (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 number VARCHAR(40) UNIQUE NOT NULL,
 department_id BIGINT UNSIGNED NOT NULL,
 requested_by BIGINT UNSIGNED NOT NULL,
 status ENUM('pending','approved','rejected') DEFAULT 'pending',
 approved_by BIGINT UNSIGNED NULL,
 approved_at DATETIME NULL,
 note TEXT,
 created_at TIMESTAMP NULL,
 FOREIGN KEY(department_id) REFERENCES departments(id),
 FOREIGN KEY(requested_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS purchase_requisition_items (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 requisition_id BIGINT UNSIGNED NOT NULL,
 item_id BIGINT UNSIGNED NOT NULL,
 requested_qty DECIMAL(14,2) NOT NULL,
 notes VARCHAR(255),
 FOREIGN KEY(requisition_id) REFERENCES purchase_requisitions(id),
 FOREIGN KEY(item_id) REFERENCES inventory_items(id)
);

CREATE TABLE IF NOT EXISTS purchase_orders (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 number VARCHAR(40) UNIQUE NOT NULL,
 supplier_id BIGINT UNSIGNED NOT NULL,
 requisition_id BIGINT UNSIGNED NULL,
 status ENUM('draft','sent','partially_received','received','cancelled') DEFAULT 'sent',
 expected_date DATE NULL,
 notes TEXT,
 created_by BIGINT UNSIGNED NOT NULL,
 created_at TIMESTAMP NULL,
 FOREIGN KEY(supplier_id) REFERENCES suppliers(id),
 FOREIGN KEY(requisition_id) REFERENCES purchase_requisitions(id),
 FOREIGN KEY(created_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS purchase_order_items (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 order_id BIGINT UNSIGNED NOT NULL,
 item_id BIGINT UNSIGNED NOT NULL,
 quantity DECIMAL(14,2) NOT NULL,
 unit_cost DECIMAL(14,2) NOT NULL,
 total DECIMAL(14,2) NOT NULL,
 received_qty DECIMAL(14,2) DEFAULT 0,
 FOREIGN KEY(order_id) REFERENCES purchase_orders(id),
 FOREIGN KEY(item_id) REFERENCES inventory_items(id)
);

CREATE TABLE IF NOT EXISTS expenses (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 number VARCHAR(40) UNIQUE NOT NULL,
 department_id BIGINT UNSIGNED NOT NULL,
 requested_by BIGINT UNSIGNED NOT NULL,
 category VARCHAR(80) NOT NULL,
 description TEXT NOT NULL,
 amount DECIMAL(14,2) NOT NULL,
 status ENUM('pending','approved','rejected','paid') DEFAULT 'pending',
 approved_by BIGINT UNSIGNED NULL,
 approved_at DATETIME NULL,
 paid_at DATETIME NULL,
 payment_method VARCHAR(50),
 references_txt VARCHAR(255),
 created_at TIMESTAMP NULL,
 FOREIGN KEY(department_id) REFERENCES departments(id),
 FOREIGN KEY(requested_by) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS audit_logs (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NULL,
 user_id BIGINT UNSIGNED NULL,
 action VARCHAR(120) NOT NULL,
 entity_type VARCHAR(120),
 entity_id BIGINT UNSIGNED NULL,
 old_values JSON NULL,
 new_values JSON NULL,
 ip_address VARCHAR(64),
 user_agent TEXT,
 created_at TIMESTAMP NULL
);

USE hotelpardise_system;

INSERT INTO hotels(name,slug,city,country,currency,timezone) VALUES
('Hotel Paradise on the Nile','hotel-paradise-on-the-nile','Jinja','Uganda','UGX','Africa/Kampala')
ON DUPLICATE KEY UPDATE
  name=VALUES(name), city=VALUES(city), country=VALUES(country),
  currency=VALUES(currency), timezone=VALUES(timezone);

INSERT INTO roles(name) VALUES
('super_admin'),('director'),('general_manager'),('accountant'),('cashier'),
('receptionist'),('waiter'),('bar_staff'),('kitchen'),('storekeeper'),
('procurement'),('housekeeping'),('maintenance'),('events_manager'),('marketing'),('auditor')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO departments(name,code) VALUES
('Front Desk','FD'),('Housekeeping','HK'),('Restaurant','RT'),('Bar','BB'),
('Kitchen','KC'),('Maintenance','MT'),('Events','EV'),('Administration','AD'),('Laundry','LD')
ON DUPLICATE KEY UPDATE name=VALUES(name), code=VALUES(code);

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
(1,'Internal Auditor','auditor@hotelparadiseonthenile.info','+256 774 000 012','$2y$10$2DcxWTLhv4yYgC/Zg6lvAuO8r.mnWKi6LnvJULMzgiTxAnRmWcJf2','active')
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), name=VALUES(name), email=VALUES(email), phone=VALUES(phone), password_hash=VALUES(password_hash), status=VALUES(status);

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
    ELSE 'super_admin' END)
ON DUPLICATE KEY UPDATE user_id=VALUES(user_id), role_id=VALUES(role_id);

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
(1,'room_service','Room Service')
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), outlet=VALUES(outlet), name=VALUES(name);

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
('Beverages'),('Kitchen'),('Housekeeping Supplies'),('Maintenance'),('Stationery')
ON DUPLICATE KEY UPDATE name=VALUES(name);

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
(1,4,'HPN-20260925-004','agent','2026-09-20 14:00','2026-09-23 11:00',2,0,'checked_out',314000,3,942000,0,942000,942000,'Family holiday',NOW())
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), guest_id=VALUES(guest_id), booking_number=VALUES(booking_number), source=VALUES(source), check_in=VALUES(check_in), check_out=VALUES(check_out), adults=VALUES(adults), children=VALUES(children), status=VALUES(status), room_rate=VALUES(room_rate), nights=VALUES(nights), subtotal=VALUES(subtotal), tax=VALUES(tax), total=VALUES(total), paid=VALUES(paid), notes=VALUES(notes), created_at=VALUES(created_at);

INSERT INTO reservation_rooms(reservation_id,room_type_id,room_id,quantity,nightly_rate)
SELECT r.id, rt.id, rn.id, 1, r.room_rate FROM reservations r JOIN room_types rt ON rt.name='Suite' JOIN rooms rn ON rn.room_type_id=rt.id AND rn.room_number='S101' WHERE r.guest_id=1;

INSERT INTO reservation_rooms(reservation_id,room_type_id,room_id,quantity,nightly_rate)
SELECT r.id, rt.id, rn.id, 1, r.room_rate FROM reservations r JOIN room_types rt ON rt.name='Executive Deluxe' JOIN rooms rn ON rn.room_type_id=rt.id AND rn.room_number='ED201' WHERE r.guest_id=2;

INSERT INTO reservation_rooms(reservation_id,room_type_id,room_id,quantity,nightly_rate)
SELECT r.id, rt.id, rn.id, 1, r.room_rate FROM reservations r JOIN room_types rt ON rt.name='Triple Room' JOIN rooms rn ON rn.room_type_id=rt.id AND rn.room_number='T201' WHERE r.guest_id=3;

INSERT INTO reservation_rooms(reservation_id,room_type_id,room_id,quantity,nightly_rate)
SELECT r.id, rt.id, rn.id, 1, r.room_rate FROM reservations r JOIN room_types rt ON rt.name='Family Room' JOIN rooms rn ON rn.room_type_id=rt.id AND rn.room_number='F101' WHERE r.guest_id=4;

INSERT INTO invoices(hotel_id,guest_id,invoice_number,subtotal,tax,total,status) VALUES
(1,1,'INV-HPN-20260925-0001',744000,0,744000,'paid')
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), guest_id=VALUES(guest_id), invoice_number=VALUES(invoice_number), subtotal=VALUES(subtotal), tax=VALUES(tax), total=VALUES(total), status=VALUES(status);

INSERT INTO payments(hotel_id,user_id,invoice_id,reservation_id,amount,method,status) VALUES
(1,6,1,1,744000,'cash','successful');

-- ============================================================================
-- HOTEL PARADISE ON THE NILE — PROPOSED A LA CARTE MENU, JANUARY 2026
-- ============================================================================
-- Run AFTER schema.sql and seed.sql.
--
--   mysql -u root hotelpardise_system < database/menu_alacarte.sql
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

USE hotelpardise_system;

-- Keep the old front of house menu out of the way, keep the bar.
UPDATE menu_items mi
  JOIN menu_categories mc ON mc.id = mi.category_id
  SET mi.active = 0
  WHERE mc.outlet = 'restaurant';

-- A category that still has a dish under it cannot be removed while
-- order_items points at that dish, and dropping the link would cost the
-- order history. Those are left in place, out of service.
DELETE mc FROM menu_categories mc
 WHERE mc.outlet = 'restaurant'
   AND NOT EXISTS (SELECT 1 FROM menu_items mi WHERE mi.category_id = mc.id);


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
(1,'restaurant','Pizzeria Section','PIZZA','Baked to order on a stone base, 12 inch.',150)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), outlet=VALUES(outlet), name=VALUES(name), eyebrow=VALUES(eyebrow), blurb=VALUES(blurb), sort_order=VALUES(sort_order);

-- ---------------------------------------------------------------------------
-- 2. ITEMS
--    (category name, group, item, description, price, suggested price, tracked)
-- ---------------------------------------------------------------------------

-- 2.1 Starters -----------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name = 'Starters' LIMIT 1),'Mushroom Soup','Soups','Creamy forest mushroom soup, homemade style, served with a bread roll.',12000,10,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Starters' LIMIT 1),'Clear Chicken and Beef Noodle Soup','Soups','Fresh aromatic clear soup of julienned chicken, zucchini, carrots, onions and fresh noodles.',15000,20,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Starters' LIMIT 1),'Classic BLT Sandwich','Sandwich Corner','Crisp bacon, lettuce and ripe tomato in a toasted roll.',25000,30,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Starters' LIMIT 1),'Three Decker Sandwich','Sandwich Corner','Three decker of bacon, lettuce and tomato, served with chips.',NULL, -- suggested 28000
 40,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Starters' LIMIT 1),'Tuna Melt','Sandwich Corner','Tuna chunks folded with mayonnaise, red onion, tomato and lettuce.',25000,50,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Starters' LIMIT 1),'Paradise Club Sandwich','Sandwich Corner','Triple decker of grilled beef, chicken breast, bacon, cheese, onions and mayo, served with chips.',30000,60,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Starters' LIMIT 1),'Grilled Veggies Salad','Salads','Assorted seasoned grilled vegetables with bell pepper, carrots, zucchini and onions, laced with cashew nut flakes and dots.',18000,70,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Starters' LIMIT 1),'Grilled Chicken Salad','Salads','Grilled boneless chicken strips married with onions, carrots, cucumber and tomato, garnished with black olives on a bed of lettuce.',15000,80,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Starters' LIMIT 1),'Tuna Salad','Salads','Tuna fish, red onion and tomato infused in fresh mayonnaise, layered on lettuce with avocado slices.',20000,90,0)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

-- 2.2 Egg Dishes ----------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name = 'Egg Dishes' LIMIT 1),'Spanish Omelet','Egg Dishes','Traditional eggs with red onion, mushroom, green pepper and tomato, served with chips.',15000,10,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Egg Dishes' LIMIT 1),'Avocado with an Egg','Egg Dishes','Avocado and a fried egg on toasted bread with a garnish.',13000,20,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Egg Dishes' LIMIT 1),'Bacon and Cheese Omelet','Egg Dishes','Crunchy bacon folded into eggs, infused with cheese and a touch of pepper sauce, served with fries.',NULL, -- suggested 18000
 30,0)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

-- 2.3 Burgers -------------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name = 'Burgers' LIMIT 1),'Vegetable Burger','Burgers','Crumbed fried vegetable patty with tomato, lettuce, onion and chili sauce.',20000,10,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Burgers' LIMIT 1),'Chicken and Beef Burger','Burgers','Grilled chicken or beef patty, regular or Cajun, with lettuce, onion, tomato and chili mayo.',NULL, -- 75,000 in the draft, confirm before printing
 20,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Burgers' LIMIT 1),'BBQ Beef and Chicken Patty','Burgers','Grilled beef or chicken patty finished in a tangy barbecue sauce.',NULL, -- suggested 30000
 30,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Burgers' LIMIT 1),'Double Beef and Bacon Burger','Burgers','Double beef, bacon, cheese, caramelized lettuce, pickles and tomato.',NULL, -- suggested 32000
 40,1)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

-- 2.4 Wraps ---------------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name = 'Wraps and Rolex' LIMIT 1),'Chicken Wrap','Wraps','Shredded chicken, crispy lettuce, onion, tomato and avocado in mayo or sweet chili, rolled in a tortilla, served plain.',20000,10,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Wraps and Rolex' LIMIT 1),'Crunchy Vegetable Wrap','Wraps','Sautéed vegetables with a touch of cheddar cheese, served plain.',14000,20,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Wraps and Rolex' LIMIT 1),'Chicken and Beef Rolex','Wraps','Eggs, chicken or beef cubes, red onion, tomato and green pepper, served plain.',15000,30,0)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

-- 2.5 Snacks -------------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name = 'Snacks' LIMIT 1),'Chilli Beef and Veggie Chips','Snacks','Chips tossed in mild Indian spices, finished with tomato sauce and fresh coriander. Beef or vegetarian.',NULL, -- suggested 20000
 10,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Snacks' LIMIT 1),'Chicken Spring Rolls','Snacks','A pair of crisp chicken spring rolls.',6000,20,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Snacks' LIMIT 1),'Liver with Shredded Vegetables','Snacks','Flakes of liver tossed with shredded vegetables, served with rice or chips.',30000,30,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Snacks' LIMIT 1),'Fish Fingers with Chips','Snacks','Crisp breaded fish fingers with a portion of chips.',30000,40,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Snacks' LIMIT 1),'Chicken Wings with Chips','Snacks','Crispy chicken wings with a portion of chips.',28000,50,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Snacks' LIMIT 1),'Chicken Lollipops with Chips','Snacks','Chicken lollipops with a portion of chips.',30000,60,1)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

-- 2.6 Italian Special Pastas -----------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name = 'Italian Special Pastas' LIMIT 1),'Pasta Arrabbiata','Pasta','Pasta in tomato and fresh chili sauce, topped with melted cheese and served with toast.',20000,10,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Italian Special Pastas' LIMIT 1),'Pasta Bolognese','Pasta','Pasta with minced meat, garlic, tomato and red wine sauce, topped with melted cheese and served with toast.',25000,20,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Italian Special Pastas' LIMIT 1),'Pasta Carbonara','Pasta','Pasta with egg and bacon cream sauce, topped with cheese and served with toast.',30000,30,0)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

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
 50,1)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

-- 2.8 Fish Fillets ---------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name = 'Fish Fillets' LIMIT 1),'Paradise Rustica Fish','Fish Fillets','Grilled tilapia fillet layered on guacamole and salsa with hot chili, served with rustica sauce, garnished with black olives.',32000,10,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Fish Fillets' LIMIT 1),'Mombasa Fish','Fish Fillets','Tilapia fillet crumbed in coconut and fried to your liking, served with chips or rice.',32000,20,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Fish Fillets' LIMIT 1),'Deep Fried or Pan Grilled Fillet','Fish Fillets','Coated tilapia fillet, deep fried or pan grilled, served with rice or chips.',32000,30,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Fish Fillets' LIMIT 1),'Catch of the Day','Fish Fillets','Pan grilled Nile perch fillet served with rice or chips.',NULL, -- suggested 38000
 40,1)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

-- 2.9 Chicken Lovers --------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name = 'Chicken Lovers' LIMIT 1),'Chicken Saute','Chicken Lovers','Sautéed chicken with brown mushroom and spring onion, served with mushroom sauce and an accompaniment of your choice.',30000,10,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Chicken Lovers' LIMIT 1),'BBQ Chicken Drumstick','Chicken Lovers','Three well marinated tender chicken drumsticks, fried and tossed in barbecue sauce with a touch of fresh coriander.',30000,20,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Chicken Lovers' LIMIT 1),'Grilled Quarter Chicken Breast or Thigh','Chicken Lovers','Well marinated charcoal or oven roasted tender chicken, served with chips or an accompaniment of your choice.',45000,30,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Chicken Lovers' LIMIT 1),'Paradise Grilled Farm Chicken','Chicken Lovers','A well marinated chicken grilled to perfection with aromatic seasonings.',40000,40,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Chicken Lovers' LIMIT 1),'Pan Fried Boneless Chicken Breast','Chicken Lovers','Fresh pan fried boneless chicken breast resting in mushroom sauce.',43000,50,1)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

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
 80,1)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

-- 2.11 Pork ---------------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name = 'Pork' LIMIT 1),'Paradise Grilled Pork Chops','Pork','Perfectly marinated tender pork chops grilled to your liking, served with an accompaniment of your choice.',NULL, -- suggested 35000
 10,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Pork' LIMIT 1),'Honey Mustard Glazed Pork Ribs','Pork','Tender juicy ribs of pork roasted in onion rings and honey.',NULL, -- suggested 38000
 20,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Pork' LIMIT 1),'Pork Muchomo','Pork','Boneless chunks of pork roasted in aromatic vegetables, served with chips.',NULL, -- suggested 28000
 30,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Pork' LIMIT 1),'Sweet and Sour Pork','Pork','Well seasoned chunks of pork glazed in a tangy sweet and sour sauce, sprinkled with spring onion, served with an accompaniment of your choice.',NULL, -- suggested 30000
 40,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Pork' LIMIT 1),'Pork Muchomo and Chops Platter','Pork','A combination of pork muchomo and pork chops on a single platter, served with an accompaniment of your choice.',35000,50,1)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

-- 2.12 House Specials -----------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name = 'House Specials' LIMIT 1),'Paradise Lusaniya','House Specials','A family platter for three to four, with grilled chicken, beef steak and goat muchomo, served with brown pilau, matoke or potato wedges.',100000,10,1),
(1,(SELECT id FROM menu_categories WHERE name = 'House Specials' LIMIT 1),'Mixed Grill Platter','House Specials','A platter for two with grilled chicken, beef muchomo and roasted goat, served with two accompaniments of your choice.',80000,20,1)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

-- 2.13 Asian Delicacies ----------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name = 'Asian Delicacies' LIMIT 1),'Mixed Vegetable Curry','Curries','Assorted vegetables in a creamy sauce, served with white rice or mashed potatoes.',20000,10,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Asian Delicacies' LIMIT 1),'Vegetable Korma','Curries','Mixed vegetables cooked in a mild creamy almond and cashew nut sauce, served with rice or chapatti.',25000,20,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Asian Delicacies' LIMIT 1),'Veggie Biryani','Biryani','Spiced diced mixed vegetables cooked in a creamy sauce and mixed with rice.',25000,30,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Asian Delicacies' LIMIT 1),'Chicken, Fish or Goat Biryani','Biryani','Cubes of chicken, fish or goat cooked in a creamy sauce and mixed with rice.',32000,40,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Asian Delicacies' LIMIT 1),'Chicken Coconut Curry','Curries','Grilled and cubed boneless chicken in a golden sauce infused with coconut, served with rice or chapatti.',32000,50,1)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

-- 2.14 Desserts -----------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name = 'Desserts' LIMIT 1),'Fresh Fruit Platter','Desserts','A generous and visually appealing presentation of seasonal fruit such as mango, papaya, melon, orange, grapes and passion fruit.',NULL, -- suggested 20000
 10,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Desserts' LIMIT 1),'Fruit Salad','Desserts','A combination of diced fruits sprinkled with passion fruit syrup.',15000,20,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Desserts' LIMIT 1),'Banana Crepe','Desserts','A very thin pancake filled with sliced banana and chocolate syrup, garnished with orange slices.',15000,30,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Desserts' LIMIT 1),'Ice Cream','Desserts','Three scoops, chocolate, vanilla or strawberry.',9000,40,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Desserts' LIMIT 1),'Cake of the Day','Desserts','A slice of the cake of the day, chocolate, marble, lemon, banana, red velvet and more.',7000,50,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Desserts' LIMIT 1),'Affogato Espresso Ice Cream','Desserts','Two scoops of ice cream of your choice with 60ml of espresso coffee.',15000,60,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Desserts' LIMIT 1),'Banana Split','Desserts','Banana and ice cream garnished with chocolate sauce, whipped cream, flaked almonds and cherries.',15000,70,0)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

-- 2.15 Pizzeria ------------------------------------------------------------------
INSERT INTO menu_items(hotel_id,category_id,name,group_name,description,price,sort_order,stock_tracked) VALUES
(1,(SELECT id FROM menu_categories WHERE name = 'Pizzeria Section' LIMIT 1),'Classic Margherita','Pizza','Tomato, fresh basil, oregano and mozzarella.',27000,10,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Pizzeria Section' LIMIT 1),'Sweet Vegetarian','Pizza','Red, yellow and green bell pepper, sweet corn and mozzarella.',27000,20,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Pizzeria Section' LIMIT 1),'Quattro Stagioni','Pizza','Ham, olives, mushroom, artichokes and mozzarella.',30000,30,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Pizzeria Section' LIMIT 1),'Pepperoni','Pizza','Tomato, green pepper, onion, pepperoni and mozzarella.',30000,40,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Pizzeria Section' LIMIT 1),'Hawaiian','Pizza','Ham or bacon, pineapple and mozzarella.',NULL, -- suggested 32000
 50,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Pizzeria Section' LIMIT 1),'Farmer''s','Pizza','Chicken, mushroom and mozzarella.',30000,60,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Pizzeria Section' LIMIT 1),'Tuna','Pizza','Tuna fillet, tomato, green pepper and mozzarella, topped with a boiled egg.',NULL, -- suggested 34000
 70,1),
(1,(SELECT id FROM menu_categories WHERE name = 'Pizzeria Section' LIMIT 1),'Diavola','Pizza','Tomato, chili salami and mozzarella.',30000,80,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Pizzeria Section' LIMIT 1),'Bolognese','Pizza','Spicy minced meat, tomato and mozzarella.',NULL, -- 10,000 in the draft, confirm
 90,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Pizzeria Section' LIMIT 1),'Capricciosa','Pizza','Salami, black olives, artichokes, capers, mushroom and mozzarella.',30000,100,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Pizzeria Section' LIMIT 1),'Calzone','Calzone','Minced meat, green pepper and capsicum rolled in a half moon of bread.',30000,110,0),
(1,(SELECT id FROM menu_categories WHERE name = 'Pizzeria Section' LIMIT 1),'Assorted Meat and Salami','Pizza','Assorted meat, salami, mushroom, green pepper, onion and mozzarella.',35000,120,0)
ON DUPLICATE KEY UPDATE hotel_id=VALUES(hotel_id), category_id=VALUES(category_id), name=VALUES(name), group_name=VALUES(group_name), description=VALUES(description), price=VALUES(price), sort_order=VALUES(sort_order), stock_tracked=VALUES(stock_tracked);

-- ---------------------------------------------------------------------------
-- 3. VERIFICATION — everything still waiting on a rate
-- ---------------------------------------------------------------------------
SELECT mc.name AS section, mi.name AS item
  FROM menu_items mi
  JOIN menu_categories mc ON mc.id = mi.category_id
 WHERE mi.price IS NULL
   AND mc.outlet = 'restaurant'
 ORDER BY mc.sort_order, mi.sort_order;
