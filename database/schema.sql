CREATE DATABASE IF NOT EXISTS hotel_paradise_nile CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hotel_paradise_nile;

CREATE TABLE hotels (
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

CREATE TABLE users (
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

CREATE TABLE roles (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(80) UNIQUE NOT NULL
);

CREATE TABLE user_roles (
 user_id BIGINT UNSIGNED NOT NULL,
 role_id BIGINT UNSIGNED NOT NULL,
 PRIMARY KEY(user_id, role_id),
 FOREIGN KEY(user_id) REFERENCES users(id),
 FOREIGN KEY(role_id) REFERENCES roles(id)
);

CREATE TABLE room_types (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 name VARCHAR(120) NOT NULL,
 description TEXT,
 max_guests INT NOT NULL DEFAULT 1,
 base_rate DECIMAL(14,2) NOT NULL,
 active BOOLEAN NOT NULL DEFAULT TRUE,
 FOREIGN KEY(hotel_id) REFERENCES hotels(id)
);

CREATE TABLE rooms (
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

CREATE TABLE beds (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 room_id BIGINT UNSIGNED NOT NULL,
 name VARCHAR(80) NOT NULL,
 bed_type VARCHAR(80) NOT NULL,
 price DECIMAL(14,2) NULL,
 status ENUM('available','reserved','occupied','out_of_service') DEFAULT 'available',
 FOREIGN KEY(room_id) REFERENCES rooms(id)
);

CREATE TABLE guests (
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

CREATE TABLE reservations (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 guest_id BIGINT UNSIGNED NOT NULL,
 booking_number VARCHAR(60) UNIQUE NOT NULL,
 check_in DATETIME NOT NULL,
 check_out DATETIME NOT NULL,
 status ENUM('pending','confirmed','checked_in','checked_out','cancelled','no_show') DEFAULT 'pending',
 subtotal DECIMAL(14,2) NOT NULL DEFAULT 0,
 tax DECIMAL(14,2) NOT NULL DEFAULT 0,
 total DECIMAL(14,2) NOT NULL DEFAULT 0,
 created_at TIMESTAMP NULL,
 updated_at TIMESTAMP NULL,
 FOREIGN KEY(hotel_id) REFERENCES hotels(id),
 FOREIGN KEY(guest_id) REFERENCES guests(id)
);

CREATE TABLE reservation_rooms (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 reservation_id BIGINT UNSIGNED NOT NULL,
 room_id BIGINT UNSIGNED NOT NULL,
 nightly_rate DECIMAL(14,2) NOT NULL,
 FOREIGN KEY(reservation_id) REFERENCES reservations(id),
 FOREIGN KEY(room_id) REFERENCES rooms(id)
);

CREATE TABLE menu_categories (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  hotel_id BIGINT UNSIGNED NOT NULL,
  outlet ENUM('restaurant','bar','room_service') NOT NULL,
  name VARCHAR(120) NOT NULL,
  eyebrow VARCHAR(120) DEFAULT NULL,
  blurb TEXT DEFAULT NULL,
  image VARCHAR(190) DEFAULT NULL,
  sort_order INT NOT NULL DEFAULT 0
);

CREATE TABLE menu_items (
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

CREATE TABLE orders (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 user_id BIGINT UNSIGNED NOT NULL,
 order_number VARCHAR(60) UNIQUE NOT NULL,
 outlet ENUM('restaurant','bar','room_service') NOT NULL,
 order_type ENUM('table','room','takeaway','delivery') NOT NULL,
 room_id BIGINT UNSIGNED NULL,
 status ENUM('pending','accepted','preparing','ready','served','completed','cancelled') DEFAULT 'pending',
 subtotal DECIMAL(14,2) DEFAULT 0,
 tax DECIMAL(14,2) DEFAULT 0,
 total DECIMAL(14,2) DEFAULT 0,
 created_at TIMESTAMP NULL
);

CREATE TABLE order_items (
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

CREATE TABLE invoices (
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

CREATE TABLE payments (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 user_id BIGINT UNSIGNED NULL,
 invoice_id BIGINT UNSIGNED NULL,
 amount DECIMAL(14,2) NOT NULL,
 method VARCHAR(50) NOT NULL,
 provider VARCHAR(100),
 provider_reference VARCHAR(190),
 status ENUM('pending','successful','failed','refunded','reversed') DEFAULT 'pending',
 created_at TIMESTAMP NULL
);

CREATE TABLE efris_transactions (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 invoice_id BIGINT UNSIGNED NOT NULL,
 status ENUM('pending','submitted','fiscalized','failed','retrying') DEFAULT 'pending',
 request_reference VARCHAR(190),
 fdn VARCHAR(190),
 verification_code VARCHAR(190),
 qr_data TEXT,
 response_payload JSON NULL,
 created_at TIMESTAMP NULL,
 updated_at TIMESTAMP NULL
);

CREATE TABLE reception_records (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 hotel_id BIGINT UNSIGNED NOT NULL,
 created_by BIGINT UNSIGNED NOT NULL,
 category VARCHAR(80) NOT NULL,
 priority ENUM('low','normal','high','urgent') DEFAULT 'normal',
 guest_id BIGINT UNSIGNED NULL,
 room_id BIGINT UNSIGNED NULL,
 title VARCHAR(190) NOT NULL,
 description TEXT NOT NULL,
 status ENUM('open','acknowledged','assigned','resolved','closed') DEFAULT 'open',
 director_acknowledged_at TIMESTAMP NULL,
 created_at TIMESTAMP NULL,
 updated_at TIMESTAMP NULL
);

CREATE TABLE audit_logs (
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
