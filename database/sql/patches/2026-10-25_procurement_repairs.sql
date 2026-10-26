-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-25_procurement_repairs.sql
-- Date: 2026-10-25
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- Purchases, Approvals and Inventory write to four procurement tables and read a
-- handful of later columns. An early install may be missing a table or a column,
-- which used to turn those pages into a 500. The console repairs them on first
-- use; this patch is the same repair for anyone who wants to run it by hand.
--
-- This version uses MariaDB's IF NOT EXISTS clauses, so it needs no stored
-- procedure and never reads information_schema. It creates only missing tables,
-- adds only missing columns, and adds each index once. Safe to run more than
-- once.
-- =============================================================================

SET NAMES utf8mb4;

-- -----------------------------------------------------------------------------
-- 1. The four tables, in their current shape.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS purchase_requisitions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  number VARCHAR(40) NOT NULL,
  department_id BIGINT UNSIGNED NOT NULL,
  requested_by BIGINT UNSIGNED NOT NULL,
  status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  approved_by BIGINT UNSIGNED DEFAULT NULL,
  approved_at DATETIME DEFAULT NULL,
  note TEXT DEFAULT NULL,
  created_at DATETIME DEFAULT NULL,
  deleted_at TIMESTAMP NULL DEFAULT NULL,
  deleted_by BIGINT UNSIGNED DEFAULT NULL,
  decision_reason VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY number (number),
  KEY department_id (department_id),
  KEY requested_by (requested_by),
  KEY idx_pr_status (status),
  KEY idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS purchase_requisition_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  requisition_id BIGINT UNSIGNED NOT NULL,
  item_id BIGINT UNSIGNED NOT NULL,
  requested_qty DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  notes VARCHAR(255) DEFAULT NULL,
  est_cost DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (id),
  KEY requisition_id (requisition_id),
  KEY item_id (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS purchase_orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  number VARCHAR(40) NOT NULL,
  supplier_id BIGINT UNSIGNED NOT NULL,
  requisition_id BIGINT UNSIGNED DEFAULT NULL,
  status ENUM('draft','sent','partially_received','received','cancelled') NOT NULL DEFAULT 'sent',
  expected_date DATE DEFAULT NULL,
  notes TEXT DEFAULT NULL,
  created_by BIGINT UNSIGNED NOT NULL,
  created_at DATETIME DEFAULT NULL,
  deleted_at TIMESTAMP NULL DEFAULT NULL,
  deleted_by BIGINT UNSIGNED DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY number (number),
  KEY supplier_id (supplier_id),
  KEY requisition_id (requisition_id),
  KEY created_by (created_by),
  KEY idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS purchase_order_items (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL,
  item_id BIGINT UNSIGNED NOT NULL,
  quantity DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  unit_cost DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  total DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  received_qty DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (id),
  KEY order_id (order_id),
  KEY item_id (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. Columns a later export added.
-- -----------------------------------------------------------------------------
ALTER TABLE inventory_items            ADD COLUMN IF NOT EXISTS unit            VARCHAR(40) NOT NULL DEFAULT 'pcs';
ALTER TABLE inventory_items            ADD COLUMN IF NOT EXISTS code            VARCHAR(60) NULL;
ALTER TABLE inventory_items            ADD COLUMN IF NOT EXISTS unit_cost       DECIMAL(14,2) NOT NULL DEFAULT 0.00;
ALTER TABLE purchase_requisitions      ADD COLUMN IF NOT EXISTS decision_reason VARCHAR(255) NULL;
ALTER TABLE purchase_requisition_items ADD COLUMN IF NOT EXISTS est_cost        DECIMAL(14,2) NOT NULL DEFAULT 0.00;
ALTER TABLE purchase_requisition_items ADD COLUMN IF NOT EXISTS notes           VARCHAR(255) NULL;
ALTER TABLE purchase_orders            ADD COLUMN IF NOT EXISTS requisition_id  BIGINT UNSIGNED NULL;
ALTER TABLE purchase_orders            ADD COLUMN IF NOT EXISTS hotel_id        BIGINT UNSIGNED NOT NULL DEFAULT 1;
ALTER TABLE purchase_order_items       ADD COLUMN IF NOT EXISTS received_qty    DECIMAL(14,2) NOT NULL DEFAULT 0.00;
ALTER TABLE payments                   ADD COLUMN IF NOT EXISTS user_id         BIGINT UNSIGNED NULL;

-- -----------------------------------------------------------------------------
-- 3. Queue indexes, by name, when missing.
-- -----------------------------------------------------------------------------
ALTER TABLE purchase_requisitions      ADD INDEX IF NOT EXISTS idx_pr_status   (status);
ALTER TABLE purchase_requisitions      ADD INDEX IF NOT EXISTS idx_deleted_at  (deleted_at);
ALTER TABLE purchase_requisitions      ADD INDEX IF NOT EXISTS hp_perf_requisition_status (status);
ALTER TABLE purchase_orders            ADD INDEX IF NOT EXISTS idx_deleted_at  (deleted_at);
ALTER TABLE purchase_requisition_items ADD INDEX IF NOT EXISTS requisition_id  (requisition_id);
ALTER TABLE purchase_order_items       ADD INDEX IF NOT EXISTS order_id        (order_id);

-- Verification: the four tables, the later columns, and a usable next id.
SHOW COLUMNS FROM inventory_items LIKE 'unit';
SHOW COLUMNS FROM inventory_items LIKE 'code';
SHOW COLUMNS FROM inventory_items LIKE 'unit_cost';
SHOW COLUMNS FROM purchase_requisitions LIKE 'decision_reason';
SHOW COLUMNS FROM purchase_requisition_items LIKE 'est_cost';
SHOW COLUMNS FROM purchase_requisition_items LIKE 'notes';
SHOW COLUMNS FROM purchase_orders LIKE 'requisition_id';
SHOW COLUMNS FROM purchase_orders LIKE 'hotel_id';
SHOW COLUMNS FROM purchase_order_items LIKE 'received_qty';
SHOW COLUMNS FROM payments LIKE 'user_id';
