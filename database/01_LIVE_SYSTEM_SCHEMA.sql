-- Hotel Paradise on the Nile - Full schema
CREATE DATABASE IF NOT EXISTS hotel_paradise_nile CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hotel_paradise_nile;

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