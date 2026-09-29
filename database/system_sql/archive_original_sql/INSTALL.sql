-- ============================================================
-- HOTEL PARADISE ON THE NILE
-- Production database installer
-- Designed by Reagansoft Innovation Limited
-- Target: MySQL 8.0+
-- Currency: UGX
-- Timezone: Africa/Kampala
-- ============================================================

CREATE DATABASE IF NOT EXISTS hotel_paradise_nile
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hotel_paradise_nile;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ---------- ORGANIZATION ----------
CREATE TABLE IF NOT EXISTS hotel_groups (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(190) NOT NULL,
  legal_name VARCHAR(190) NULL,
  tax_number VARCHAR(100) NULL,
  phone VARCHAR(50) NULL,
  email VARCHAR(190) NULL,
  address TEXT NULL,
  website VARCHAR(255) NULL,
  logo_path VARCHAR(255) NULL,
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS properties (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  hotel_group_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(190) NOT NULL,
  code VARCHAR(50) NOT NULL,
  city VARCHAR(100) DEFAULT 'Jinja',
  country VARCHAR(100) DEFAULT 'Uganda',
  address TEXT NULL,
  phone VARCHAR(50) NULL,
  email VARCHAR(190) NULL,
  currency CHAR(3) NOT NULL DEFAULT 'UGX',
  timezone VARCHAR(64) NOT NULL DEFAULT 'Africa/Kampala',
  check_in_time TIME DEFAULT '14:00:00',
  check_out_time TIME DEFAULT '11:00:00',
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_property_code (code),
  CONSTRAINT fk_property_group FOREIGN KEY (hotel_group_id) REFERENCES hotel_groups(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS departments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  code VARCHAR(60) NOT NULL,
  description TEXT NULL,
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_department (property_id, code),
  CONSTRAINT fk_department_property FOREIGN KEY (property_id) REFERENCES properties(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS outlets (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NULL,
  name VARCHAR(150) NOT NULL,
  code VARCHAR(60) NOT NULL,
  outlet_type ENUM('restaurant','bar','pool','spa','room_service','laundry','shop','other') NOT NULL DEFAULT 'other',
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_outlet (property_id, code),
  CONSTRAINT fk_outlet_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_outlet_department FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

-- ---------- IDENTITY / SECURITY ----------
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(190) NOT NULL,
  email VARCHAR(190) NULL,
  phone VARCHAR(50) NULL,
  password_hash VARCHAR(255) NOT NULL,
  status ENUM('pending','active','suspended','locked') NOT NULL DEFAULT 'pending',
  last_login_at DATETIME NULL,
  last_login_ip VARCHAR(64) NULL,
  password_changed_at DATETIME NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_user_email (email),
  UNIQUE KEY uq_user_phone (phone)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS roles (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  display_name VARCHAR(150) NOT NULL,
  description TEXT NULL,
  UNIQUE KEY uq_role_name (name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS permissions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  display_name VARCHAR(190) NOT NULL,
  UNIQUE KEY uq_permission_name (name)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_roles (
  user_id BIGINT UNSIGNED NOT NULL,
  role_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS role_permissions (
  role_id BIGINT UNSIGNED NOT NULL,
  permission_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (role_id, permission_id),
  CONSTRAINT fk_rp_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
  CONSTRAINT fk_rp_permission FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_property_access (
  user_id BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, property_id),
  CONSTRAINT fk_upa_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_upa_property FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS user_department_access (
  user_id BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (user_id, department_id),
  CONSTRAINT fk_uda_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_uda_department FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sessions (
  id VARCHAR(128) PRIMARY KEY,
  user_id BIGINT UNSIGNED NULL,
  ip_address VARCHAR(64) NULL,
  user_agent TEXT NULL,
  payload MEDIUMTEXT NULL,
  last_activity INT UNSIGNED NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_session_user (user_id),
  CONSTRAINT fk_session_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash VARCHAR(255) NOT NULL,
  expires_at DATETIME NOT NULL,
  used_at DATETIME NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_prt_user (user_id),
  INDEX idx_prt_expires (expires_at),
  CONSTRAINT fk_prt_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS login_attempts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NULL,
  identifier VARCHAR(190) NULL,
  ip_address VARCHAR(64) NULL,
  successful TINYINT(1) NOT NULL DEFAULT 0,
  failure_reason VARCHAR(190) NULL,
  attempted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_login_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS two_factor_settings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  enabled TINYINT(1) NOT NULL DEFAULT 0,
  secret_encrypted TEXT NULL,
  recovery_codes_encrypted TEXT NULL,
  enabled_at DATETIME NULL,
  UNIQUE KEY uq_2fa_user (user_id),
  CONSTRAINT fk_2fa_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- STAFF / HR ----------
CREATE TABLE IF NOT EXISTS staff_profiles (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  property_id BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NULL,
  staff_number VARCHAR(80) NOT NULL,
  job_title VARCHAR(150) NULL,
  employment_type VARCHAR(80) NULL,
  hire_date DATE NULL,
  national_id VARCHAR(100) NULL,
  emergency_contact VARCHAR(190) NULL,
  emergency_phone VARCHAR(50) NULL,
  active TINYINT(1) NOT NULL DEFAULT 1,
  UNIQUE KEY uq_staff_number (property_id, staff_number),
  CONSTRAINT fk_staff_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_staff_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_staff_department FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS attendance (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  staff_id BIGINT UNSIGNED NOT NULL,
  clock_in DATETIME NULL,
  clock_out DATETIME NULL,
  method VARCHAR(50) NULL,
  notes TEXT NULL,
  CONSTRAINT fk_att_staff FOREIGN KEY (staff_id) REFERENCES staff_profiles(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS leave_requests (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  staff_id BIGINT UNSIGNED NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  leave_type VARCHAR(80) NOT NULL,
  reason TEXT NULL,
  status ENUM('pending','approved','rejected','cancelled') DEFAULT 'pending',
  approved_by BIGINT UNSIGNED NULL,
  approved_at DATETIME NULL,
  CONSTRAINT fk_leave_staff FOREIGN KEY (staff_id) REFERENCES staff_profiles(id),
  CONSTRAINT fk_leave_approver FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------- GUESTS / CRM ----------
CREATE TABLE IF NOT EXISTS guest_accounts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  marketing_opt_in TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_guest_account_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS guests (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NULL,
  full_name VARCHAR(190) NOT NULL,
  phone VARCHAR(50) NULL,
  email VARCHAR(190) NULL,
  nationality VARCHAR(100) NULL,
  id_type VARCHAR(50) NULL,
  id_number VARCHAR(100) NULL,
  date_of_birth DATE NULL,
  address TEXT NULL,
  notes TEXT NULL,
  vip_level VARCHAR(50) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX idx_guest_phone (phone),
  INDEX idx_guest_email (email),
  CONSTRAINT fk_guest_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS guest_documents (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  guest_id BIGINT UNSIGNED NOT NULL,
  document_type VARCHAR(80) NOT NULL,
  document_number VARCHAR(120) NULL,
  file_path VARCHAR(255) NULL,
  expires_on DATE NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_guest_doc_guest FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- ROOMS ----------
CREATE TABLE IF NOT EXISTS room_types (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  code VARCHAR(60) NOT NULL,
  description TEXT NULL,
  max_guests INT NOT NULL DEFAULT 1,
  base_rate DECIMAL(14,2) NOT NULL DEFAULT 0,
  active TINYINT(1) DEFAULT 1,
  UNIQUE KEY uq_room_type (property_id, code),
  CONSTRAINT fk_roomtype_property FOREIGN KEY (property_id) REFERENCES properties(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS rooms (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  room_type_id BIGINT UNSIGNED NOT NULL,
  room_number VARCHAR(40) NOT NULL,
  floor VARCHAR(40) NULL,
  bed_type VARCHAR(80) NULL,
  status ENUM('available','reserved','occupied','dirty','cleaning','inspected','maintenance','out_of_service') DEFAULT 'available',
  notes TEXT NULL,
  UNIQUE KEY uq_room_number (property_id, room_number),
  CONSTRAINT fk_room_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_room_type FOREIGN KEY (room_type_id) REFERENCES room_types(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS room_status_history (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  room_id BIGINT UNSIGNED NOT NULL,
  old_status VARCHAR(50) NULL,
  new_status VARCHAR(50) NOT NULL,
  changed_by BIGINT UNSIGNED NULL,
  reason TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_rsh_room FOREIGN KEY (room_id) REFERENCES rooms(id),
  CONSTRAINT fk_rsh_user FOREIGN KEY (changed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------- RESERVATIONS / FOLIO ----------
CREATE TABLE IF NOT EXISTS reservations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  guest_id BIGINT UNSIGNED NOT NULL,
  booking_number VARCHAR(80) NOT NULL,
  source VARCHAR(80) DEFAULT 'direct',
  check_in DATETIME NOT NULL,
  check_out DATETIME NOT NULL,
  adults INT DEFAULT 1,
  children INT DEFAULT 0,
  status ENUM('pending','confirmed','checked_in','checked_out','cancelled','no_show') DEFAULT 'pending',
  special_requests TEXT NULL,
  subtotal DECIMAL(14,2) DEFAULT 0,
  tax DECIMAL(14,2) DEFAULT 0,
  total DECIMAL(14,2) DEFAULT 0,
  deposit_required DECIMAL(14,2) DEFAULT 0,
  created_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_booking_number (booking_number),
  CONSTRAINT fk_res_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_res_guest FOREIGN KEY (guest_id) REFERENCES guests(id),
  CONSTRAINT fk_res_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS reservation_rooms (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  reservation_id BIGINT UNSIGNED NOT NULL,
  room_id BIGINT UNSIGNED NOT NULL,
  nightly_rate DECIMAL(14,2) NOT NULL DEFAULT 0,
  adults INT DEFAULT 1,
  children INT DEFAULT 0,
  CONSTRAINT fk_rr_res FOREIGN KEY (reservation_id) REFERENCES reservations(id) ON DELETE CASCADE,
  CONSTRAINT fk_rr_room FOREIGN KEY (room_id) REFERENCES rooms(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS folios (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  guest_id BIGINT UNSIGNED NULL,
  reservation_id BIGINT UNSIGNED NULL,
  folio_number VARCHAR(80) NOT NULL,
  status ENUM('open','closed') DEFAULT 'open',
  total DECIMAL(14,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_folio_number (folio_number),
  CONSTRAINT fk_folio_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_folio_guest FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL,
  CONSTRAINT fk_folio_res FOREIGN KEY (reservation_id) REFERENCES reservations(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS folio_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  folio_id BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NULL,
  description VARCHAR(255) NOT NULL,
  reference_type VARCHAR(80) NULL,
  reference_id BIGINT UNSIGNED NULL,
  quantity DECIMAL(14,3) DEFAULT 1,
  unit_price DECIMAL(14,2) DEFAULT 0,
  tax DECIMAL(14,2) DEFAULT 0,
  discount DECIMAL(14,2) DEFAULT 0,
  total DECIMAL(14,2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_folio_item_folio FOREIGN KEY (folio_id) REFERENCES folios(id) ON DELETE CASCADE,
  CONSTRAINT fk_folio_item_dept FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------- MENU / FOOD / BAR ----------
CREATE TABLE IF NOT EXISTS menu_categories (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  outlet_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  display_order INT DEFAULT 0,
  active TINYINT(1) DEFAULT 1,
  CONSTRAINT fk_mc_outlet FOREIGN KEY (outlet_id) REFERENCES outlets(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS menu_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  category_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(190) NOT NULL,
  description TEXT NULL,
  sku VARCHAR(80) NULL,
  price DECIMAL(14,2) NOT NULL DEFAULT 0,
  tax_rate DECIMAL(7,4) DEFAULT 0,
  cost_price DECIMAL(14,2) DEFAULT 0,
  image_path VARCHAR(255) NULL,
  active TINYINT(1) DEFAULT 1,
  CONSTRAINT fk_menu_category FOREIGN KEY (category_id) REFERENCES menu_categories(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS dining_tables (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  outlet_id BIGINT UNSIGNED NOT NULL,
  table_number VARCHAR(50) NOT NULL,
  seats INT DEFAULT 2,
  status ENUM('available','occupied','reserved','cleaning','out_of_service') DEFAULT 'available',
  UNIQUE KEY uq_dining_table (outlet_id, table_number),
  CONSTRAINT fk_table_outlet FOREIGN KEY (outlet_id) REFERENCES outlets(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS orders (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  outlet_id BIGINT UNSIGNED NULL,
  department_id BIGINT UNSIGNED NOT NULL,
  terminal_id BIGINT UNSIGNED NULL,
  guest_id BIGINT UNSIGNED NULL,
  room_id BIGINT UNSIGNED NULL,
  table_id BIGINT UNSIGNED NULL,
  order_number VARCHAR(80) NOT NULL,
  order_type ENUM('table','room','takeaway','pool','spa','counter','other') DEFAULT 'counter',
  status ENUM('pending','accepted','preparing','ready','served','completed','cancelled') DEFAULT 'pending',
  subtotal DECIMAL(14,2) DEFAULT 0,
  tax DECIMAL(14,2) DEFAULT 0,
  discount DECIMAL(14,2) DEFAULT 0,
  total DECIMAL(14,2) DEFAULT 0,
  created_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_order_number (order_number),
  CONSTRAINT fk_order_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_order_outlet FOREIGN KEY (outlet_id) REFERENCES outlets(id) ON DELETE SET NULL,
  CONSTRAINT fk_order_dept FOREIGN KEY (department_id) REFERENCES departments(id),
  CONSTRAINT fk_order_guest FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL,
  CONSTRAINT fk_order_room FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL,
  CONSTRAINT fk_order_table FOREIGN KEY (table_id) REFERENCES dining_tables(id) ON DELETE SET NULL,
  CONSTRAINT fk_order_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS order_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT UNSIGNED NOT NULL,
  menu_item_id BIGINT UNSIGNED NOT NULL,
  quantity DECIMAL(14,3) NOT NULL DEFAULT 1,
  unit_price DECIMAL(14,2) NOT NULL DEFAULT 0,
  tax DECIMAL(14,2) DEFAULT 0,
  discount DECIMAL(14,2) DEFAULT 0,
  total DECIMAL(14,2) DEFAULT 0,
  notes TEXT NULL,
  CONSTRAINT fk_oi_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_oi_menu FOREIGN KEY (menu_item_id) REFERENCES menu_items(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS kitchen_stations (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  active TINYINT(1) DEFAULT 1,
  CONSTRAINT fk_ks_property FOREIGN KEY (property_id) REFERENCES properties(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS kitchen_order_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  order_item_id BIGINT UNSIGNED NOT NULL,
  station_id BIGINT UNSIGNED NULL,
  status ENUM('queued','accepted','preparing','ready','served','cancelled') DEFAULT 'queued',
  started_at DATETIME NULL,
  completed_at DATETIME NULL,
  CONSTRAINT fk_koi_order_item FOREIGN KEY (order_item_id) REFERENCES order_items(id) ON DELETE CASCADE,
  CONSTRAINT fk_koi_station FOREIGN KEY (station_id) REFERENCES kitchen_stations(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------- POS ----------
CREATE TABLE IF NOT EXISTS pos_terminals (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  outlet_id BIGINT UNSIGNED NULL,
  terminal_code VARCHAR(80) NOT NULL,
  name VARCHAR(120) NOT NULL,
  device_identifier VARCHAR(190) NULL,
  active TINYINT(1) DEFAULT 1,
  UNIQUE KEY uq_pos_terminal (property_id, terminal_code),
  CONSTRAINT fk_pos_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_pos_outlet FOREIGN KEY (outlet_id) REFERENCES outlets(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS cashier_shifts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  terminal_id BIGINT UNSIGNED NOT NULL,
  opened_by BIGINT UNSIGNED NOT NULL,
  closed_by BIGINT UNSIGNED NULL,
  opening_float DECIMAL(14,2) DEFAULT 0,
  expected_total DECIMAL(14,2) DEFAULT 0,
  actual_total DECIMAL(14,2) DEFAULT 0,
  variance DECIMAL(14,2) DEFAULT 0,
  status ENUM('open','closed','reconciled') DEFAULT 'open',
  opened_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  closed_at DATETIME NULL,
  CONSTRAINT fk_shift_terminal FOREIGN KEY (terminal_id) REFERENCES pos_terminals(id),
  CONSTRAINT fk_shift_opened FOREIGN KEY (opened_by) REFERENCES users(id),
  CONSTRAINT fk_shift_closed FOREIGN KEY (closed_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pos_sales (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  outlet_id BIGINT UNSIGNED NULL,
  terminal_id BIGINT UNSIGNED NOT NULL,
  shift_id BIGINT UNSIGNED NULL,
  order_id BIGINT UNSIGNED NULL,
  receipt_number VARCHAR(100) NOT NULL,
  subtotal DECIMAL(14,2) DEFAULT 0,
  tax DECIMAL(14,2) DEFAULT 0,
  discount DECIMAL(14,2) DEFAULT 0,
  total DECIMAL(14,2) DEFAULT 0,
  status ENUM('completed','voided','refunded','partially_refunded') DEFAULT 'completed',
  sold_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_receipt_number (receipt_number),
  CONSTRAINT fk_sale_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_sale_outlet FOREIGN KEY (outlet_id) REFERENCES outlets(id) ON DELETE SET NULL,
  CONSTRAINT fk_sale_terminal FOREIGN KEY (terminal_id) REFERENCES pos_terminals(id),
  CONSTRAINT fk_sale_shift FOREIGN KEY (shift_id) REFERENCES cashier_shifts(id) ON DELETE SET NULL,
  CONSTRAINT fk_sale_order FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE SET NULL,
  CONSTRAINT fk_sale_user FOREIGN KEY (sold_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pos_sale_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sale_id BIGINT UNSIGNED NOT NULL,
  menu_item_id BIGINT UNSIGNED NULL,
  description VARCHAR(255) NOT NULL,
  quantity DECIMAL(14,3) DEFAULT 1,
  unit_price DECIMAL(14,2) DEFAULT 0,
  tax DECIMAL(14,2) DEFAULT 0,
  discount DECIMAL(14,2) DEFAULT 0,
  total DECIMAL(14,2) DEFAULT 0,
  CONSTRAINT fk_sale_item_sale FOREIGN KEY (sale_id) REFERENCES pos_sales(id) ON DELETE CASCADE,
  CONSTRAINT fk_sale_item_menu FOREIGN KEY (menu_item_id) REFERENCES menu_items(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pos_payments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sale_id BIGINT UNSIGNED NOT NULL,
  payment_method ENUM('cash','card','mobile_money','bank_transfer','room_charge','other') NOT NULL,
  provider VARCHAR(120) NULL,
  provider_reference VARCHAR(190) NULL,
  amount DECIMAL(14,2) NOT NULL,
  status ENUM('pending','successful','failed','refunded','reversed') DEFAULT 'successful',
  paid_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_pos_payment_sale FOREIGN KEY (sale_id) REFERENCES pos_sales(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS pos_voids_refunds (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  sale_id BIGINT UNSIGNED NOT NULL,
  type ENUM('void','refund') NOT NULL,
  amount DECIMAL(14,2) NOT NULL,
  reason TEXT NOT NULL,
  requested_by BIGINT UNSIGNED NOT NULL,
  approved_by BIGINT UNSIGNED NULL,
  status ENUM('requested','approved','rejected','completed') DEFAULT 'requested',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_vr_sale FOREIGN KEY (sale_id) REFERENCES pos_sales(id),
  CONSTRAINT fk_vr_requester FOREIGN KEY (requested_by) REFERENCES users(id),
  CONSTRAINT fk_vr_approver FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------- FINANCE / ACCOUNTING ----------
CREATE TABLE IF NOT EXISTS invoices (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  guest_id BIGINT UNSIGNED NULL,
  folio_id BIGINT UNSIGNED NULL,
  invoice_number VARCHAR(100) NOT NULL,
  invoice_date DATE NOT NULL,
  due_date DATE NULL,
  subtotal DECIMAL(14,2) DEFAULT 0,
  tax DECIMAL(14,2) DEFAULT 0,
  discount DECIMAL(14,2) DEFAULT 0,
  total DECIMAL(14,2) DEFAULT 0,
  status ENUM('draft','issued','partially_paid','paid','cancelled','refunded') DEFAULT 'draft',
  created_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_invoice_number (invoice_number),
  CONSTRAINT fk_invoice_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_invoice_guest FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL,
  CONSTRAINT fk_invoice_folio FOREIGN KEY (folio_id) REFERENCES folios(id) ON DELETE SET NULL,
  CONSTRAINT fk_invoice_user FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS invoice_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  invoice_id BIGINT UNSIGNED NOT NULL,
  description VARCHAR(255) NOT NULL,
  quantity DECIMAL(14,3) DEFAULT 1,
  unit_price DECIMAL(14,2) DEFAULT 0,
  tax DECIMAL(14,2) DEFAULT 0,
  discount DECIMAL(14,2) DEFAULT 0,
  total DECIMAL(14,2) DEFAULT 0,
  CONSTRAINT fk_invoice_item_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  invoice_id BIGINT UNSIGNED NULL,
  folio_id BIGINT UNSIGNED NULL,
  amount DECIMAL(14,2) NOT NULL,
  method ENUM('cash','card','mobile_money','bank_transfer','room_charge','other') NOT NULL,
  provider VARCHAR(120) NULL,
  provider_reference VARCHAR(190) NULL,
  status ENUM('pending','successful','failed','refunded','reversed') DEFAULT 'successful',
  received_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_payment_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_payment_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE SET NULL,
  CONSTRAINT fk_payment_folio FOREIGN KEY (folio_id) REFERENCES folios(id) ON DELETE SET NULL,
  CONSTRAINT fk_payment_user FOREIGN KEY (received_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS expenses (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NULL,
  supplier_name VARCHAR(190) NULL,
  description VARCHAR(255) NOT NULL,
  amount DECIMAL(14,2) NOT NULL,
  payment_method VARCHAR(60) NULL,
  expense_date DATE NOT NULL,
  status ENUM('pending','approved','paid','rejected') DEFAULT 'pending',
  requested_by BIGINT UNSIGNED NULL,
  approved_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_expense_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_expense_department FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
  CONSTRAINT fk_expense_requester FOREIGN KEY (requested_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_expense_approver FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS chart_of_accounts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  account_code VARCHAR(30) NOT NULL,
  account_name VARCHAR(190) NOT NULL,
  account_type ENUM('asset','liability','equity','income','expense') NOT NULL,
  parent_id BIGINT UNSIGNED NULL,
  active TINYINT(1) DEFAULT 1,
  UNIQUE KEY uq_account_code (property_id, account_code),
  CONSTRAINT fk_coa_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_coa_parent FOREIGN KEY (parent_id) REFERENCES chart_of_accounts(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS financial_periods (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  period_name VARCHAR(50) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  status ENUM('open','closed') DEFAULT 'open',
  UNIQUE KEY uq_period (property_id, start_date, end_date),
  CONSTRAINT fk_period_property FOREIGN KEY (property_id) REFERENCES properties(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS journal_entries (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  period_id BIGINT UNSIGNED NULL,
  entry_number VARCHAR(80) NOT NULL,
  entry_date DATE NOT NULL,
  description TEXT NOT NULL,
  status ENUM('draft','posted','reversed') DEFAULT 'draft',
  created_by BIGINT UNSIGNED NULL,
  posted_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uq_entry_number (entry_number),
  CONSTRAINT fk_je_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_je_period FOREIGN KEY (period_id) REFERENCES financial_periods(id) ON DELETE SET NULL,
  CONSTRAINT fk_je_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_je_poster FOREIGN KEY (posted_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS journal_lines (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  journal_entry_id BIGINT UNSIGNED NOT NULL,
  account_id BIGINT UNSIGNED NOT NULL,
  debit DECIMAL(14,2) DEFAULT 0,
  credit DECIMAL(14,2) DEFAULT 0,
  memo TEXT NULL,
  CONSTRAINT fk_jl_entry FOREIGN KEY (journal_entry_id) REFERENCES journal_entries(id) ON DELETE CASCADE,
  CONSTRAINT fk_jl_account FOREIGN KEY (account_id) REFERENCES chart_of_accounts(id)
) ENGINE=InnoDB;

-- ---------- INVENTORY / PROCUREMENT ----------
CREATE TABLE IF NOT EXISTS suppliers (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(190) NOT NULL,
  contact_person VARCHAR(190) NULL,
  phone VARCHAR(50) NULL,
  email VARCHAR(190) NULL,
  tax_number VARCHAR(100) NULL,
  address TEXT NULL,
  active TINYINT(1) DEFAULT 1,
  CONSTRAINT fk_supplier_property FOREIGN KEY (property_id) REFERENCES properties(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_categories (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(120) NOT NULL,
  UNIQUE KEY uq_inventory_category (property_id, name),
  CONSTRAINT fk_ic_property FOREIGN KEY (property_id) REFERENCES properties(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  category_id BIGINT UNSIGNED NULL,
  sku VARCHAR(80) NULL,
  name VARCHAR(190) NOT NULL,
  unit VARCHAR(50) NOT NULL,
  reorder_level DECIMAL(14,3) DEFAULT 0,
  current_quantity DECIMAL(14,3) DEFAULT 0,
  average_cost DECIMAL(14,2) DEFAULT 0,
  active TINYINT(1) DEFAULT 1,
  UNIQUE KEY uq_inventory_sku (property_id, sku),
  CONSTRAINT fk_ii_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_ii_category FOREIGN KEY (category_id) REFERENCES inventory_categories(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS inventory_movements (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  item_id BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NULL,
  movement_type ENUM('purchase','transfer_in','transfer_out','sale','consumption','wastage','adjustment','return') NOT NULL,
  quantity DECIMAL(14,3) NOT NULL,
  unit_cost DECIMAL(14,2) DEFAULT 0,
  reference_type VARCHAR(80) NULL,
  reference_id BIGINT UNSIGNED NULL,
  reason TEXT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_im_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_im_item FOREIGN KEY (item_id) REFERENCES inventory_items(id),
  CONSTRAINT fk_im_department FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
  CONSTRAINT fk_im_user FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS purchase_orders (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  supplier_id BIGINT UNSIGNED NOT NULL,
  po_number VARCHAR(80) NOT NULL,
  order_date DATE NOT NULL,
  status ENUM('draft','submitted','approved','partially_received','received','cancelled') DEFAULT 'draft',
  subtotal DECIMAL(14,2) DEFAULT 0,
  tax DECIMAL(14,2) DEFAULT 0,
  total DECIMAL(14,2) DEFAULT 0,
  created_by BIGINT UNSIGNED NULL,
  approved_by BIGINT UNSIGNED NULL,
  UNIQUE KEY uq_po_number (po_number),
  CONSTRAINT fk_po_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_po_supplier FOREIGN KEY (supplier_id) REFERENCES suppliers(id),
  CONSTRAINT fk_po_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_po_approver FOREIGN KEY (approved_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS purchase_order_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  purchase_order_id BIGINT UNSIGNED NOT NULL,
  inventory_item_id BIGINT UNSIGNED NOT NULL,
  quantity DECIMAL(14,3) NOT NULL,
  unit_cost DECIMAL(14,2) NOT NULL,
  total DECIMAL(14,2) NOT NULL,
  CONSTRAINT fk_poi_po FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id) ON DELETE CASCADE,
  CONSTRAINT fk_poi_item FOREIGN KEY (inventory_item_id) REFERENCES inventory_items(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS goods_received (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  purchase_order_id BIGINT UNSIGNED NULL,
  property_id BIGINT UNSIGNED NOT NULL,
  grn_number VARCHAR(80) NOT NULL,
  received_by BIGINT UNSIGNED NOT NULL,
  received_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  notes TEXT NULL,
  UNIQUE KEY uq_grn_number (grn_number),
  CONSTRAINT fk_grn_po FOREIGN KEY (purchase_order_id) REFERENCES purchase_orders(id) ON DELETE SET NULL,
  CONSTRAINT fk_grn_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_grn_user FOREIGN KEY (received_by) REFERENCES users(id)
) ENGINE=InnoDB;

-- ---------- HOUSEKEEPING / MAINTENANCE ----------
CREATE TABLE IF NOT EXISTS housekeeping_tasks (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  room_id BIGINT UNSIGNED NULL,
  assigned_to BIGINT UNSIGNED NULL,
  task_type ENUM('cleaning','inspection','turn_down','deep_clean','other') DEFAULT 'cleaning',
  priority ENUM('low','normal','high','urgent') DEFAULT 'normal',
  status ENUM('pending','assigned','in_progress','completed','verified','cancelled') DEFAULT 'pending',
  notes TEXT NULL,
  completed_at DATETIME NULL,
  verified_by BIGINT UNSIGNED NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_hk_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_hk_room FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL,
  CONSTRAINT fk_hk_assignee FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_hk_verifier FOREIGN KEY (verified_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS lost_property (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  room_id BIGINT UNSIGNED NULL,
  guest_id BIGINT UNSIGNED NULL,
  found_by BIGINT UNSIGNED NULL,
  description TEXT NOT NULL,
  found_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  status ENUM('stored','claimed','returned','disposed') DEFAULT 'stored',
  released_to VARCHAR(190) NULL,
  released_at DATETIME NULL,
  CONSTRAINT fk_lp_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_lp_room FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL,
  CONSTRAINT fk_lp_guest FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL,
  CONSTRAINT fk_lp_finder FOREIGN KEY (found_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS maintenance_assets (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(190) NOT NULL,
  asset_code VARCHAR(80) NULL,
  location VARCHAR(190) NULL,
  status VARCHAR(80) DEFAULT 'active',
  purchase_date DATE NULL,
  warranty_end DATE NULL,
  UNIQUE KEY uq_asset_code (property_id, asset_code),
  CONSTRAINT fk_asset_property FOREIGN KEY (property_id) REFERENCES properties(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS maintenance_tickets (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NULL,
  room_id BIGINT UNSIGNED NULL,
  asset_id BIGINT UNSIGNED NULL,
  reported_by BIGINT UNSIGNED NOT NULL,
  assigned_to BIGINT UNSIGNED NULL,
  title VARCHAR(190) NOT NULL,
  description TEXT NOT NULL,
  priority ENUM('low','normal','high','urgent') DEFAULT 'normal',
  status ENUM('open','assigned','in_progress','waiting_parts','resolved','closed') DEFAULT 'open',
  resolved_at DATETIME NULL,
  CONSTRAINT fk_mt_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_mt_department FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
  CONSTRAINT fk_mt_room FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL,
  CONSTRAINT fk_mt_asset FOREIGN KEY (asset_id) REFERENCES maintenance_assets(id) ON DELETE SET NULL,
  CONSTRAINT fk_mt_reporter FOREIGN KEY (reported_by) REFERENCES users(id),
  CONSTRAINT fk_mt_assignee FOREIGN KEY (assigned_to) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------- POOL / SPA / LAUNDRY ----------
CREATE TABLE IF NOT EXISTS pool_visits (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  guest_id BIGINT UNSIGNED NULL,
  visitor_name VARCHAR(190) NULL,
  entry_time DATETIME DEFAULT CURRENT_TIMESTAMP,
  exit_time DATETIME NULL,
  fee DECIMAL(14,2) DEFAULT 0,
  payment_status ENUM('unpaid','paid','waived') DEFAULT 'unpaid',
  recorded_by BIGINT UNSIGNED NULL,
  CONSTRAINT fk_pool_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_pool_guest FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL,
  CONSTRAINT fk_pool_user FOREIGN KEY (recorded_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS spa_services (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(190) NOT NULL,
  duration_minutes INT DEFAULT 60,
  price DECIMAL(14,2) DEFAULT 0,
  active TINYINT(1) DEFAULT 1,
  CONSTRAINT fk_spas_property FOREIGN KEY (property_id) REFERENCES properties(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS spa_appointments (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  guest_id BIGINT UNSIGNED NULL,
  service_id BIGINT UNSIGNED NOT NULL,
  therapist_id BIGINT UNSIGNED NULL,
  start_at DATETIME NOT NULL,
  end_at DATETIME NULL,
  status ENUM('booked','checked_in','in_progress','completed','cancelled','no_show') DEFAULT 'booked',
  notes TEXT NULL,
  CONSTRAINT fk_spaa_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_spaa_guest FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL,
  CONSTRAINT fk_spaa_service FOREIGN KEY (service_id) REFERENCES spa_services(id),
  CONSTRAINT fk_spaa_therapist FOREIGN KEY (therapist_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS laundry_orders (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  guest_id BIGINT UNSIGNED NULL,
  room_id BIGINT UNSIGNED NULL,
  order_number VARCHAR(80) NOT NULL,
  status ENUM('received','processing','ready','delivered','cancelled') DEFAULT 'received',
  total DECIMAL(14,2) DEFAULT 0,
  received_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  delivered_at DATETIME NULL,
  UNIQUE KEY uq_laundry_order (order_number),
  CONSTRAINT fk_laundry_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_laundry_guest FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL,
  CONSTRAINT fk_laundry_room FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS laundry_items (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  laundry_order_id BIGINT UNSIGNED NOT NULL,
  item_name VARCHAR(190) NOT NULL,
  quantity DECIMAL(14,3) DEFAULT 1,
  unit_price DECIMAL(14,2) DEFAULT 0,
  total DECIMAL(14,2) DEFAULT 0,
  CONSTRAINT fk_li_order FOREIGN KEY (laundry_order_id) REFERENCES laundry_orders(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- EVENTS / TRANSPORT ----------
CREATE TABLE IF NOT EXISTS events (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  name VARCHAR(190) NOT NULL,
  event_type VARCHAR(100) NULL,
  start_at DATETIME NOT NULL,
  end_at DATETIME NULL,
  expected_guests INT DEFAULT 0,
  status ENUM('planned','confirmed','in_progress','completed','cancelled') DEFAULT 'planned',
  notes TEXT NULL,
  CONSTRAINT fk_event_property FOREIGN KEY (property_id) REFERENCES properties(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS event_bookings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  event_id BIGINT UNSIGNED NOT NULL,
  guest_id BIGINT UNSIGNED NULL,
  service_description VARCHAR(255) NOT NULL,
  quantity DECIMAL(14,3) DEFAULT 1,
  unit_price DECIMAL(14,2) DEFAULT 0,
  total DECIMAL(14,2) DEFAULT 0,
  CONSTRAINT fk_event_booking_event FOREIGN KEY (event_id) REFERENCES events(id) ON DELETE CASCADE,
  CONSTRAINT fk_event_booking_guest FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS vehicles (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  registration_number VARCHAR(50) NOT NULL,
  vehicle_name VARCHAR(120) NOT NULL,
  driver_user_id BIGINT UNSIGNED NULL,
  status ENUM('available','on_trip','maintenance','inactive') DEFAULT 'available',
  UNIQUE KEY uq_vehicle_reg (property_id, registration_number),
  CONSTRAINT fk_vehicle_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_vehicle_driver FOREIGN KEY (driver_user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS transport_requests (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  guest_id BIGINT UNSIGNED NULL,
  vehicle_id BIGINT UNSIGNED NULL,
  pickup_location VARCHAR(255) NOT NULL,
  destination VARCHAR(255) NOT NULL,
  pickup_at DATETIME NOT NULL,
  status ENUM('requested','assigned','in_progress','completed','cancelled') DEFAULT 'requested',
  fee DECIMAL(14,2) DEFAULT 0,
  created_by BIGINT UNSIGNED NULL,
  CONSTRAINT fk_tr_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_tr_guest FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL,
  CONSTRAINT fk_tr_vehicle FOREIGN KEY (vehicle_id) REFERENCES vehicles(id) ON DELETE SET NULL,
  CONSTRAINT fk_tr_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------- RECEPTION / INCIDENTS ----------
CREATE TABLE IF NOT EXISTS reception_records (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NOT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  guest_id BIGINT UNSIGNED NULL,
  room_id BIGINT UNSIGNED NULL,
  category VARCHAR(100) NOT NULL,
  priority ENUM('low','normal','high','urgent') DEFAULT 'normal',
  title VARCHAR(190) NOT NULL,
  description TEXT NOT NULL,
  status ENUM('open','acknowledged','assigned','resolved','closed') DEFAULT 'open',
  owner_acknowledged_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_rec_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_rec_department FOREIGN KEY (department_id) REFERENCES departments(id),
  CONSTRAINT fk_rec_creator FOREIGN KEY (created_by) REFERENCES users(id),
  CONSTRAINT fk_rec_guest FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE SET NULL,
  CONSTRAINT fk_rec_room FOREIGN KEY (room_id) REFERENCES rooms(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------- COMMUNICATION ----------
CREATE TABLE IF NOT EXISTS department_threads (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  department_id BIGINT UNSIGNED NULL,
  title VARCHAR(190) NOT NULL,
  thread_type ENUM('department','group','direct','management') DEFAULT 'department',
  created_by BIGINT UNSIGNED NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_thread_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_thread_department FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL,
  CONSTRAINT fk_thread_creator FOREIGN KEY (created_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS thread_members (
  thread_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (thread_id,user_id),
  CONSTRAINT fk_tm_thread FOREIGN KEY (thread_id) REFERENCES department_threads(id) ON DELETE CASCADE,
  CONSTRAINT fk_tm_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS department_messages (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  thread_id BIGINT UNSIGNED NOT NULL,
  sender_id BIGINT UNSIGNED NOT NULL,
  message TEXT NOT NULL,
  priority ENUM('normal','urgent') DEFAULT 'normal',
  attachment_path VARCHAR(255) NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  edited_at DATETIME NULL,
  deleted_at DATETIME NULL,
  CONSTRAINT fk_msg_thread FOREIGN KEY (thread_id) REFERENCES department_threads(id) ON DELETE CASCADE,
  CONSTRAINT fk_msg_sender FOREIGN KEY (sender_id) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS message_reads (
  message_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  read_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (message_id,user_id),
  CONSTRAINT fk_mr_message FOREIGN KEY (message_id) REFERENCES department_messages(id) ON DELETE CASCADE,
  CONSTRAINT fk_mr_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS call_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  caller_id BIGINT UNSIGNED NULL,
  callee_id BIGINT UNSIGNED NULL,
  provider VARCHAR(120) NULL,
  provider_call_id VARCHAR(190) NULL,
  call_type ENUM('voice','video') NOT NULL,
  started_at DATETIME NULL,
  ended_at DATETIME NULL,
  duration_seconds INT DEFAULT 0,
  status VARCHAR(60) NULL,
  CONSTRAINT fk_call_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_call_caller FOREIGN KEY (caller_id) REFERENCES users(id) ON DELETE SET NULL,
  CONSTRAINT fk_call_callee FOREIGN KEY (callee_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------- NOTIFICATIONS ----------
CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  type VARCHAR(100) NOT NULL,
  title VARCHAR(190) NOT NULL,
  body TEXT NOT NULL,
  data JSON NULL,
  read_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_notification_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS notification_devices (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  platform ENUM('web','android','ios','other') NOT NULL,
  push_token VARCHAR(500) NOT NULL,
  active TINYINT(1) DEFAULT 1,
  last_seen_at DATETIME NULL,
  UNIQUE KEY uq_push_token (push_token(191)),
  CONSTRAINT fk_nd_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- EFRIS / TAX ADAPTER ----------
CREATE TABLE IF NOT EXISTS efris_invoices (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  invoice_id BIGINT UNSIGNED NOT NULL,
  status ENUM('pending','queued','submitted','fiscalized','failed','retrying') DEFAULT 'pending',
  request_reference VARCHAR(190) NULL,
  fdn VARCHAR(190) NULL,
  verification_code VARCHAR(190) NULL,
  qr_data TEXT NULL,
  response_payload JSON NULL,
  last_error TEXT NULL,
  attempts INT DEFAULT 0,
  submitted_at DATETIME NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_efris_invoice FOREIGN KEY (invoice_id) REFERENCES invoices(id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS efris_attempts (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  efris_invoice_id BIGINT UNSIGNED NOT NULL,
  attempt_number INT NOT NULL,
  request_payload JSON NULL,
  response_payload JSON NULL,
  status VARCHAR(60) NOT NULL,
  error_message TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_efris_attempt_invoice FOREIGN KEY (efris_invoice_id) REFERENCES efris_invoices(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- AUDIT / APPROVALS ----------
CREATE TABLE IF NOT EXISTS approvals (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NOT NULL,
  entity_type VARCHAR(120) NOT NULL,
  entity_id BIGINT UNSIGNED NOT NULL,
  requested_by BIGINT UNSIGNED NOT NULL,
  approver_id BIGINT UNSIGNED NULL,
  approval_level INT DEFAULT 1,
  status ENUM('pending','approved','rejected','cancelled') DEFAULT 'pending',
  reason TEXT NULL,
  requested_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  decided_at DATETIME NULL,
  CONSTRAINT fk_approval_property FOREIGN KEY (property_id) REFERENCES properties(id),
  CONSTRAINT fk_approval_requester FOREIGN KEY (requested_by) REFERENCES users(id),
  CONSTRAINT fk_approval_approver FOREIGN KEY (approver_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS audit_logs (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NULL,
  user_id BIGINT UNSIGNED NULL,
  action VARCHAR(150) NOT NULL,
  entity_type VARCHAR(150) NULL,
  entity_id BIGINT UNSIGNED NULL,
  old_values JSON NULL,
  new_values JSON NULL,
  ip_address VARCHAR(64) NULL,
  user_agent TEXT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_audit_entity (entity_type,entity_id),
  INDEX idx_audit_user (user_id),
  INDEX idx_audit_created (created_at),
  CONSTRAINT fk_audit_property FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE SET NULL,
  CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------- SETTINGS ----------
CREATE TABLE IF NOT EXISTS system_settings (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  property_id BIGINT UNSIGNED NULL,
  setting_key VARCHAR(190) NOT NULL,
  setting_value TEXT NULL,
  is_encrypted TINYINT(1) DEFAULT 0,
  UNIQUE KEY uq_setting (property_id, setting_key),
  CONSTRAINT fk_setting_property FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- SEED MASTER DATA ----------
INSERT INTO hotel_groups (id,name,legal_name) VALUES
(1,'Hotel Paradise on the Nile Group','Hotel Paradise on the Nile')
ON DUPLICATE KEY UPDATE name=VALUES(name), legal_name=VALUES(legal_name);

INSERT INTO properties (id,hotel_group_id,name,code,city,country,currency,timezone)
VALUES (1,1,'Hotel Paradise on the Nile','HPN-JINJA','Jinja','Uganda','UGX','Africa/Kampala')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO departments (property_id,name,code) VALUES
(1,'Owners','OWNERS'),
(1,'General Management','GENERAL_MANAGEMENT'),
(1,'Reception','RECEPTION'),
(1,'Reservations','RESERVATIONS'),
(1,'Rooms','ROOMS'),
(1,'Housekeeping','HOUSEKEEPING'),
(1,'Kitchen','KITCHEN'),
(1,'Restaurant','RESTAURANT'),
(1,'Bar','BAR'),
(1,'Room Service','ROOM_SERVICE'),
(1,'Swimming Pool','SWIMMING_POOL'),
(1,'Spa','SPA'),
(1,'Laundry','LAUNDRY'),
(1,'Store','STORE'),
(1,'Inventory','INVENTORY'),
(1,'Procurement','PROCUREMENT'),
(1,'Maintenance','MAINTENANCE'),
(1,'Events & Conference','EVENTS'),
(1,'Transport','TRANSPORT'),
(1,'Finance','FINANCE'),
(1,'Cashier','CASHIER'),
(1,'Accounting','ACCOUNTING'),
(1,'Audit','AUDIT'),
(1,'Human Resources','HR'),
(1,'POS','POS'),
(1,'IT & Administration','IT')
ON DUPLICATE KEY UPDATE name=VALUES(name);

INSERT INTO roles(name,display_name,description) VALUES
('owner_mama','Owner - Mama','Full owner command access subject to configured approval policy'),
('owner_muzee','Owner - Muzee','Full owner command access subject to configured approval policy'),
('general_manager','General Manager','Hotel-wide management operations'),
('reception','Reception','Front office and guest operations'),
('reservations','Reservations','Booking management'),
('housekeeping','Housekeeping','Rooms cleaning and inspection'),
('kitchen','Kitchen','Kitchen production/KDS'),
('restaurant','Restaurant','Restaurant operations and POS'),
('bar','Bar','Bar operations and POS'),
('room_service','Room Service','In-room dining'),
('pool','Swimming Pool','Pool operations'),
('spa','Spa','Spa operations'),
('laundry','Laundry','Laundry operations'),
('store','Store','Store operations'),
('inventory','Inventory','Stock control'),
('procurement','Procurement','Purchasing and suppliers'),
('maintenance','Maintenance','Maintenance and assets'),
('events','Events','Events and conference operations'),
('transport','Transport','Transport operations'),
('cashier','Cashier','Cashier and shift operations'),
('accounting','Accounting','Accounting and journals'),
('auditor','Auditor','Read-only audit and review'),
('hr','Human Resources','Staff administration'),
('pos_manager','POS Manager','POS administration'),
('it_admin','IT Administrator','Technical administration')
ON DUPLICATE KEY UPDATE display_name=VALUES(display_name);

INSERT INTO permissions(name,display_name) VALUES
('dashboard.view','View dashboard'),
('reservations.manage','Manage reservations'),
('rooms.manage','Manage rooms'),
('guests.manage','Manage guests'),
('housekeeping.manage','Manage housekeeping'),
('kitchen.manage','Manage kitchen'),
('restaurant.manage','Manage restaurant'),
('bar.manage','Manage bar'),
('room_service.manage','Manage room service'),
('pool.manage','Manage swimming pool'),
('spa.manage','Manage spa'),
('laundry.manage','Manage laundry'),
('inventory.manage','Manage inventory'),
('procurement.manage','Manage procurement'),
('maintenance.manage','Manage maintenance'),
('events.manage','Manage events'),
('transport.manage','Manage transport'),
('pos.sell','Make POS sales'),
('pos.void','Void/refund POS sales'),
('finance.view','View finance'),
('finance.manage','Manage finance'),
('accounting.manage','Manage accounting'),
('audit.view','View audit'),
('hr.manage','Manage HR'),
('communication.use','Use communication'),
('communication.manage','Manage communication'),
('users.manage','Manage users'),
('settings.manage','Manage settings'),
('efris.manage','Manage EFRIS integration'),
('approvals.manage','Manage approvals')
ON DUPLICATE KEY UPDATE display_name=VALUES(display_name);

-- Owners get all current permissions. This makes the owner role usable immediately
-- after the first application-level owner account is created.
INSERT IGNORE INTO role_permissions(role_id,permission_id)
SELECT r.id,p.id FROM roles r CROSS JOIN permissions p
WHERE r.name IN ('owner_mama','owner_muzee');

-- Default property access for owner roles (actual owner user accounts are created
-- securely by the application installer; no default password is placed in SQL).
-- A first-run application command should create the owner users with Argon2id/bcrypt.

SET FOREIGN_KEY_CHECKS = 1;

-- ---------- VERIFICATION ----------
SELECT 'hotel_paradise_nile database ready' AS status;
SELECT COUNT(*) AS departments_created FROM departments WHERE property_id=1;
SELECT COUNT(*) AS roles_created FROM roles;
SELECT COUNT(*) AS permissions_created FROM permissions;
