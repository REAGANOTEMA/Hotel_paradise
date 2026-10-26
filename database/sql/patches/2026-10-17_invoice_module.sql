-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-17_invoice_module.sql
-- Date: 2026-10-17
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- The billing desk needs three tables: invoices, invoice_items and
-- invoice_events, plus payments.invoice_id so a payment can settle an invoice.
-- An install made before the invoicing upgrade has none of them and the page
-- shows "Invoicing upgrade not installed".
--
-- The tables are created only when missing and every index is added by name, so
-- this file is safe to run more than once. It uses MariaDB's IF NOT EXISTS
-- clauses and never reads information_schema.
-- =============================================================================

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS invoices (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id BIGINT UNSIGNED NOT NULL,
  guest_id BIGINT UNSIGNED DEFAULT NULL,
  billing_name VARCHAR(190) DEFAULT NULL,
  billing_email VARCHAR(190) DEFAULT NULL,
  billing_phone VARCHAR(50) DEFAULT NULL,
  invoice_number VARCHAR(80) NOT NULL,
  subtotal DECIMAL(14,2) DEFAULT 0.00,
  tax DECIMAL(14,2) DEFAULT 0.00,
  discount DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  currency CHAR(3) NOT NULL DEFAULT 'UGX',
  notes TEXT DEFAULT NULL,
  total DECIMAL(14,2) DEFAULT 0.00,
  status ENUM('draft','issued','partially_paid','paid','cancelled','refunded') DEFAULT 'draft',
  due_date DATE DEFAULT NULL,
  issued_at DATETIME DEFAULT NULL,
  issued_by BIGINT UNSIGNED DEFAULT NULL,
  created_at TIMESTAMP NULL DEFAULT NULL,
  updated_at TIMESTAMP NULL DEFAULT NULL,
  deleted_at TIMESTAMP NULL DEFAULT NULL,
  deleted_by BIGINT UNSIGNED DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY invoice_number (invoice_number),
  KEY idx_invoices_guest (guest_id),
  KEY idx_invoices_open (hotel_id,status,issued_at),
  KEY idx_invoices_status (status),
  KEY idx_invoices_issued_at (issued_at),
  KEY idx_invoices_billing_name (billing_name),
  KEY idx_invoices_billing_email (billing_email)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE IF NOT EXISTS invoice_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  invoice_id BIGINT UNSIGNED NOT NULL,
  item_no INT NOT NULL DEFAULT 0,
  description VARCHAR(255) NOT NULL,
  quantity DECIMAL(14,3) DEFAULT 1.000,
  unit_price DECIMAL(14,2) DEFAULT 0.00,
  tax DECIMAL(14,2) DEFAULT 0.00,
  discount DECIMAL(14,2) DEFAULT 0.00,
  total DECIMAL(14,2) DEFAULT 0.00,
  PRIMARY KEY (id),
  KEY idx_invoice_items_no (invoice_id,item_no),
  CONSTRAINT fk_invoice_item_invoice FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE IF NOT EXISTS invoice_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  invoice_id BIGINT UNSIGNED NOT NULL,
  event ENUM('issue','void','discount','adjust','note') NOT NULL,
  amount DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  reason TEXT DEFAULT NULL,
  applier BIGINT UNSIGNED DEFAULT NULL,
  from_value TEXT DEFAULT NULL,
  to_value TEXT DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_invoice_events_invoice (invoice_id),
  KEY idx_invoice_events_created (created_at),
  CONSTRAINT fk_invoice_events_invoice FOREIGN KEY (invoice_id) REFERENCES invoices (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A partial install may have one of the tables without every later column.
ALTER TABLE invoices
  ADD COLUMN IF NOT EXISTS hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS guest_id BIGINT UNSIGNED DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS billing_name VARCHAR(190) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS billing_email VARCHAR(190) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS billing_phone VARCHAR(50) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS invoice_number VARCHAR(80) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS subtotal DECIMAL(14,2) DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS tax DECIMAL(14,2) DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS discount DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS currency CHAR(3) NOT NULL DEFAULT 'UGX',
  ADD COLUMN IF NOT EXISTS notes TEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS total DECIMAL(14,2) DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS status ENUM('draft','issued','partially_paid','paid','cancelled','refunded') DEFAULT 'draft',
  ADD COLUMN IF NOT EXISTS due_date DATE DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS issued_at DATETIME DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS issued_by BIGINT UNSIGNED DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS created_at TIMESTAMP NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED DEFAULT NULL;

ALTER TABLE invoice_items
  ADD COLUMN IF NOT EXISTS invoice_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS item_no INT NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS description VARCHAR(255) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS quantity DECIMAL(14,3) DEFAULT 1.000,
  ADD COLUMN IF NOT EXISTS unit_price DECIMAL(14,2) DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS tax DECIMAL(14,2) DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS discount DECIMAL(14,2) DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS total DECIMAL(14,2) DEFAULT 0.00;

ALTER TABLE invoice_events
  ADD COLUMN IF NOT EXISTS invoice_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS event ENUM('issue','void','discount','adjust','note') NOT NULL DEFAULT 'note',
  ADD COLUMN IF NOT EXISTS amount DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  ADD COLUMN IF NOT EXISTS reason TEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS applier BIGINT UNSIGNED DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS from_value TEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS to_value TEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE payments ADD COLUMN IF NOT EXISTS invoice_id BIGINT UNSIGNED DEFAULT NULL;

ALTER TABLE invoices ADD UNIQUE KEY IF NOT EXISTS invoice_number (invoice_number);
ALTER TABLE invoices ADD INDEX IF NOT EXISTS idx_invoices_guest (guest_id);
ALTER TABLE invoices ADD INDEX IF NOT EXISTS idx_invoices_open (hotel_id,status,issued_at);
ALTER TABLE invoices ADD INDEX IF NOT EXISTS idx_invoices_status (status);
ALTER TABLE invoices ADD INDEX IF NOT EXISTS idx_invoices_issued_at (issued_at);
ALTER TABLE invoices ADD INDEX IF NOT EXISTS idx_invoices_billing_name (billing_name);
ALTER TABLE invoices ADD INDEX IF NOT EXISTS idx_invoices_billing_email (billing_email);
ALTER TABLE invoice_items ADD INDEX IF NOT EXISTS idx_invoice_items_no (invoice_id,item_no);
ALTER TABLE invoice_events ADD INDEX IF NOT EXISTS idx_invoice_events_invoice (invoice_id);
ALTER TABLE invoice_events ADD INDEX IF NOT EXISTS idx_invoice_events_created (created_at);
ALTER TABLE payments ADD INDEX IF NOT EXISTS idx_payments_invoice (invoice_id);
ALTER TABLE payments ADD INDEX IF NOT EXISTS idx_pay_user (user_id);

-- Verification: the three tables should answer, and payments should carry the key.
SELECT COUNT(*) AS invoices FROM invoices;
SELECT COUNT(*) AS invoice_items FROM invoice_items;
SELECT COUNT(*) AS invoice_events FROM invoice_events;
SHOW COLUMNS FROM payments LIKE 'invoice_id';
