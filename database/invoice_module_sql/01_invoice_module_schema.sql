-- Hotel Paradise on the Nile — Invoice & Pesapal module, step 1 of 3
-- File   : database/invoice_module_sql/01_invoice_module_schema.sql
-- Run on : the MAIN database (hotelpardise_system), manually, once. Idempotent —
--          safe to re-run. No USE statement: connect first, then select the
--          database you are installing into. Each change is guarded against the
--          CURRENT database (DATABASE()), so running this against a database
--          that lacks a table is a harmless no-op.
--
-- What this adds
--   * invoices ................ billing identity, due date, issue trail, discount,
--                               currency, notes, updated/deleted stamps
--   * invoice_items .......... an "item_no" so a receipt keeps printed order
--   * payments ............... checkout token (idempotency), verified stamp,
--                               gateway result, payer phone
--   * invoice_events ......... the per-invoice audit trail for issue / void /
--                               discount / adjust, so a printed page and the
--                               console read the same history without touching
--                               the system-wide audit_logs table
--
-- Nothing is dropped, truncated or rewritten. No seed data is fabricated.

SET @has_invoices      := (SELECT COUNT(*) FROM information_schema.TABLES
                           WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='invoices');
SET @has_invoice_items := (SELECT COUNT(*) FROM information_schema.TABLES
                           WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='invoice_items');
SET @has_payments      := (SELECT COUNT(*) FROM information_schema.TABLES
                           WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='payments');

-- ---------------------------------------------------------------------------
-- invoices — what the hotel needs to bill and settle one.
-- ---------------------------------------------------------------------------
SET @sql := IF(@has_invoices = 0, 'SELECT 1', '
ALTER TABLE `invoices`
  ADD COLUMN IF NOT EXISTS `billing_name`  varchar(190) NULL                AFTER `guest_id`,
  ADD COLUMN IF NOT EXISTS `billing_email` varchar(190) NULL                AFTER `billing_name`,
  ADD COLUMN IF NOT EXISTS `billing_phone` varchar(50)  NULL                AFTER `billing_email`,
  ADD COLUMN IF NOT EXISTS `due_date`      date         NULL                AFTER `status`,
  ADD COLUMN IF NOT EXISTS `issued_at`     datetime     NULL                AFTER `due_date`,
  ADD COLUMN IF NOT EXISTS `issued_by`     bigint(20) unsigned NULL         AFTER `issued_at`,
  ADD COLUMN IF NOT EXISTS `discount`      decimal(14,2) NOT NULL DEFAULT 0.00 AFTER `tax`,
  ADD COLUMN IF NOT EXISTS `currency`      char(3)      NOT NULL DEFAULT ''UGX'' AFTER `discount`,
  ADD COLUMN IF NOT EXISTS `notes`         text         NULL                AFTER `currency`,
  ADD COLUMN IF NOT EXISTS `updated_at`    timestamp    NULL DEFAULT NULL   AFTER `created_at`,
  ADD COLUMN IF NOT EXISTS `deleted_at`    timestamp    NULL DEFAULT NULL   AFTER `updated_at`,
  ADD COLUMN IF NOT EXISTS `deleted_by`    bigint(20) unsigned NULL         AFTER `deleted_at`');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------------------
-- invoice_items — keep printed line order stable on re-issue.
-- ---------------------------------------------------------------------------
SET @sql := IF(@has_invoice_items = 0, 'SELECT 1', '
ALTER TABLE `invoice_items`
  ADD COLUMN IF NOT EXISTS `item_no` int(11) NOT NULL DEFAULT 0 AFTER `invoice_id`');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------------------
-- payments — idempotent, verifiable payment records.
--   checkout_token  unique per checkout so a doubled tap can never double-charge
--   verified_at     server stamp: only set once the gateway result is confirmed
--   payer_phone     the number the payment was confirmed on
-- ---------------------------------------------------------------------------
SET @sql := IF(@has_payments = 0, 'SELECT 1', '
ALTER TABLE `payments`
  ADD COLUMN IF NOT EXISTS `checkout_token` varchar(190) NULL               AFTER `provider_reference`,
  ADD COLUMN IF NOT EXISTS `verified_at`    datetime     NULL               AFTER `status`,
  ADD COLUMN IF NOT EXISTS `gateway_result` text         NULL               AFTER `verified_at`,
  ADD COLUMN IF NOT EXISTS `payer_phone`    varchar(50)  NULL               AFTER `gateway_result`');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

-- ---------------------------------------------------------------------------
-- invoice_events — the audit trail kept on the invoice itself.
--   event        issue | void | discount | adjust | note
--   amount       the money moved by that event (0 for issue / void)
--   applier      which console user did it
--   from_value / to_value — snapshots around the change (void reason, old/new
--               totals), kept as readable text so a printed page and the console
--               read the same history
-- Created only where `invoices` exists, because of the foreign key below.
-- ---------------------------------------------------------------------------
SET @sql := IF(@has_invoices = 0, 'SELECT 1', '
CREATE TABLE IF NOT EXISTS `invoice_events` (
  `id`          bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `invoice_id`  bigint(20) unsigned NOT NULL,
  `event`       enum(''issue'',''void'',''discount'',''adjust'',''note'') NOT NULL,
  `amount`      decimal(14,2) NOT NULL DEFAULT 0.00,
  `reason`      text NULL,
  `applier`     bigint(20) unsigned NULL,
  `from_value`  text NULL,
  `to_value`    text NULL,
  `created_at`  datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_invoice_events_invoice` (`invoice_id`),
  KEY `idx_invoice_events_created` (`created_at`),
  CONSTRAINT `fk_invoice_events_invoice` FOREIGN KEY (`invoice_id`)
    REFERENCES `invoices` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
