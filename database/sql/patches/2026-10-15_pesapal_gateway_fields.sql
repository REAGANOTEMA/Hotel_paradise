-- =====================================================================
-- Hotel Paradise on the Nile
-- Patch: Pesapal gateway fields on `payments` (hotelpardise_system)
-- Date:  2026-10-15
-- =====================================================================
--
-- The website checkout writes a few extra fields onto a payment once the
-- Pesapal merchant keys are live. The baseline dump already carries them, but
-- an installation imported from an earlier build has a `payments` table without
-- them, and the API guards every one of these with an information_schema check,
-- so a missing column makes the gateway store less than it should rather than
-- fail. This patch makes them explicit.
--
--   checkout_token ... one random token per checkout, so a doubled tap cannot
--                      mint the same payment twice. Unique.
--   verified_at ...... the server-owned stamp written the moment the gateway
--                      confirms a transaction. Never set from the browser.
--   gateway_result ... the raw status body Pesapal returned, kept for the
--                      front desk and for reconciling a dispute.
--   payer_phone ...... the number the guest paid from, for the receipt.
--
-- It only ever adds what is missing, so running it twice changes nothing.
-- Run it with:

--   C:\xampp\mysql\bin\mysql.exe -u <user> -p hotelpardise_system < 2026-10-15_pesapal_gateway_fields.sql

DROP PROCEDURE IF EXISTS hp_add_column;
DROP PROCEDURE IF EXISTS hp_add_index;

DELIMITER //

CREATE PROCEDURE hp_add_column(IN tbl VARCHAR(64), IN col VARCHAR(64), IN ddl TEXT)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = tbl AND COLUMN_NAME = col
  ) THEN
    SET @ddl = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN ', ddl);
    PREPARE stmt FROM @ddl;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END IF;
END //

CREATE PROCEDURE hp_add_index(IN tbl VARCHAR(64), IN idx VARCHAR(64), IN ddl TEXT)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = tbl AND INDEX_NAME = idx
  ) THEN
    SET @ddl = CONCAT('ALTER TABLE `', tbl, '` ADD ', ddl);
    PREPARE stmt FROM @ddl;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
  END IF;
END //

DELIMITER ;

CALL hp_add_column('payments', 'checkout_token', '`checkout_token` varchar(190) DEFAULT NULL');
CALL hp_add_column('payments', 'verified_at',    '`verified_at` datetime DEFAULT NULL');
CALL hp_add_column('payments', 'gateway_result', '`gateway_result` text DEFAULT NULL');
CALL hp_add_column('payments', 'payer_phone',    '`payer_phone` varchar(50) DEFAULT NULL');

CALL hp_add_index('payments', 'idx_payments_checkout_token', 'UNIQUE KEY `idx_payments_checkout_token` (`checkout_token`)');
CALL hp_add_index('payments', 'idx_pay_provider_ref',        'KEY `idx_pay_provider_ref` (`provider_reference`)');

DROP PROCEDURE IF EXISTS hp_add_column;
DROP PROCEDURE IF EXISTS hp_add_index;
