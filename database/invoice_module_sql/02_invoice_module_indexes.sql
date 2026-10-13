-- Hotel Paradise on the Nile — Invoice & Pesapal module, step 2 of 3
-- File   : database/invoice_module_sql/02_invoice_module_indexes.sql
-- Run on : the MAIN database (hotelpardise_system), manually, once. Idempotent —
--          safe to re-run. No USE statement: connect first, then select the
--          database you are installing into. Every guard checks the CURRENT
--          database (DATABASE()) and the table's presence, so this file is a
--          harmless no-op if run against a database that lacks these tables.
--
-- These indexes serve the exact lookups the module performs:
--   * invoices ............... a guest's invoices (guest_id), the open ones
--                               (issued vs paid), and dedupe by number
--   * payments ............... what settled an invoice, and idempotent lookup
--                               by checkout token
--
-- MariaDB 10.x does not accept ADD INDEX IF NOT EXISTS, so each index is
-- guarded: if the same index already exists (or its table is absent) the
-- statement is a harmless no-op.

SET @has_invoices := (SELECT COUNT(*) FROM information_schema.TABLES
                      WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='invoices');
SET @has_payments := (SELECT COUNT(*) FROM information_schema.TABLES
                      WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='payments');

SET @guard := 0;
SET @sql   := 'SELECT 1';

SET @guard = (SELECT COUNT(*) FROM information_schema.STATISTICS
              WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='invoices'
                AND INDEX_NAME='idx_invoices_guest');
SET @sql = IF(@has_invoices = 0 OR @guard > 0,
  'SELECT 1',
  'ALTER TABLE `invoices` ADD INDEX `idx_invoices_guest` (`guest_id`)');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @guard = (SELECT COUNT(*) FROM information_schema.STATISTICS
              WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='invoices'
                AND INDEX_NAME='idx_invoices_open');
SET @sql = IF(@has_invoices = 0 OR @guard > 0,
  'SELECT 1',
  'ALTER TABLE `invoices` ADD INDEX `idx_invoices_open` (`hotel_id`,`status`,`issued_at`)');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @guard = (SELECT COUNT(*) FROM information_schema.STATISTICS
              WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='invoices'
                AND COLUMN_NAME='invoice_number'
                AND INDEX_NAME<>'PRIMARY' AND NON_UNIQUE=0);
SET @sql = IF(@has_invoices = 0 OR @guard > 0,
  'SELECT 1',
  'ALTER TABLE `invoices` ADD UNIQUE INDEX `uk_invoices_number` (`invoice_number`)');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @guard = (SELECT COUNT(*) FROM information_schema.STATISTICS
              WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='payments'
                AND INDEX_NAME='idx_payments_invoice');
SET @sql = IF(@has_payments = 0 OR @guard > 0,
  'SELECT 1',
  'ALTER TABLE `payments` ADD INDEX `idx_payments_invoice` (`invoice_id`)');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @guard = (SELECT COUNT(*) FROM information_schema.STATISTICS
              WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='payments'
                AND INDEX_NAME='idx_payments_checkout_token');
SET @sql = IF(@has_payments = 0 OR @guard > 0,
  'SELECT 1',
  'ALTER TABLE `payments` ADD UNIQUE INDEX `idx_payments_checkout_token` (`checkout_token`)');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
