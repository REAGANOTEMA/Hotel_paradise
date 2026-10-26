-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-10_receipt_department_copies.sql
-- Date: 2026-10-10
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- A settled payment sends the guest a receipt. The hotel also keeps a copy for
-- the department that took the money and for the director. That needs a third
-- value in receipt_deliveries.channel ('staff') and a delivery key that allows
-- one row per payment, channel and recipient instead of one row per payment and
-- channel.
--
-- This version uses MariaDB's IF NOT EXISTS / IF EXISTS clauses, so it needs no
-- stored procedure and never reads information_schema. It is safe to run more
-- than once. The application also repairs this table on first use.
-- =============================================================================

SET NAMES utf8mb4;

-- -----------------------------------------------------------------------------
-- 1. The delivery log itself, for an install that predates it.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS receipt_deliveries (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  payment_id BIGINT UNSIGNED NOT NULL,
  hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  source VARCHAR(20) NOT NULL DEFAULT '',
  reference VARCHAR(120) NOT NULL DEFAULT '',
  channel ENUM('email','print','staff') NOT NULL DEFAULT 'email',
  recipient VARCHAR(190) NOT NULL DEFAULT '',
  status ENUM('sent','failed') NOT NULL DEFAULT 'failed',
  attempts INT UNSIGNED NOT NULL DEFAULT 0,
  last_error VARCHAR(500) DEFAULT NULL,
  provider_message_id VARCHAR(190) DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_receipt_payment_channel (payment_id, channel, recipient(160)),
  KEY idx_receipt_source (source)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- -----------------------------------------------------------------------------
-- 2. Channel gains 'staff'. The column is narrowed to a known enum on purpose:
--    an unexpected value can never be written.
-- -----------------------------------------------------------------------------
ALTER TABLE receipt_deliveries
  MODIFY COLUMN IF EXISTS channel ENUM('email','print','staff') NOT NULL DEFAULT 'email';

-- -----------------------------------------------------------------------------
-- 3. One row per payment, channel and recipient. The old key may be present but
--    narrower, so it is dropped when there and rebuilt with the three columns.
--    Dropping also covers an install that has no key at all.
-- -----------------------------------------------------------------------------
ALTER TABLE receipt_deliveries DROP INDEX IF EXISTS uq_receipt_payment_channel;
ALTER TABLE receipt_deliveries ADD UNIQUE KEY IF NOT EXISTS uq_receipt_payment_channel
  (payment_id, channel, recipient(160));

-- Verification: channel should include staff and the key should have 3 columns.
SHOW COLUMNS FROM receipt_deliveries LIKE 'channel';
SHOW INDEX FROM receipt_deliveries WHERE Key_name='uq_receipt_payment_channel';
