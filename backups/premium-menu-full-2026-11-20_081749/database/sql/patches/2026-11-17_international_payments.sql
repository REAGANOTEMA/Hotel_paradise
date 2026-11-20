SET NAMES utf8mb4;

DROP PROCEDURE IF EXISTS hp_add_col;
DELIMITER $$
CREATE PROCEDURE hp_add_col(IN p_table VARCHAR(64), IN p_col VARCHAR(64), IN p_def TEXT)
BEGIN
 IF NOT EXISTS (
  SELECT 1 FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_table AND COLUMN_NAME = p_col
 ) THEN
  SET @hp_sql = CONCAT('ALTER TABLE `', p_table, '` ADD COLUMN `', p_col, '` ', p_def);
  PREPARE hp_stmt FROM @hp_sql;
  EXECUTE hp_stmt;
  DEALLOCATE PREPARE hp_stmt;
 END IF;
END$$
DELIMITER ;

CALL hp_add_col('payments', 'base_currency', 'CHAR(3) DEFAULT NULL AFTER `amount`');
CALL hp_add_col('payments', 'base_amount', 'DECIMAL(14,2) DEFAULT NULL AFTER `base_currency`');
CALL hp_add_col('payments', 'currency', 'CHAR(3) DEFAULT NULL AFTER `base_amount`');
CALL hp_add_col('payments', 'fx_rate', 'DECIMAL(24,10) DEFAULT NULL AFTER `currency`');
CALL hp_add_col('payments', 'fx_source', 'VARCHAR(120) DEFAULT NULL AFTER `fx_rate`');
CALL hp_add_col('payments', 'fx_at', 'VARCHAR(60) DEFAULT NULL AFTER `fx_source`');
CALL hp_add_col('payments', 'charged_amount', 'DECIMAL(14,2) DEFAULT NULL AFTER `fx_at`');
CALL hp_add_col('payments', 'charged_currency', 'CHAR(3) DEFAULT NULL AFTER `charged_amount`');
CALL hp_add_col('payments', 'order_tracking_id', 'VARCHAR(120) DEFAULT NULL AFTER `provider_reference`');
CALL hp_add_col('payments', 'confirmation_code', 'VARCHAR(120) DEFAULT NULL AFTER `order_tracking_id`');
CALL hp_add_col('payments', 'gateway_payment_method', 'VARCHAR(100) DEFAULT NULL AFTER `confirmation_code`');
CALL hp_add_col('payments', 'settlement_status', "VARCHAR(30) NOT NULL DEFAULT 'not_settled' AFTER `status`");
CALL hp_add_col('payments', 'settlement_reference', 'VARCHAR(120) DEFAULT NULL AFTER `settlement_status`');
CALL hp_add_col('payments', 'gateway_fee', 'DECIMAL(14,2) DEFAULT NULL AFTER `settlement_reference`');
CALL hp_add_col('payments', 'verified_by', 'VARCHAR(30) DEFAULT NULL AFTER `verified_at`');
CALL hp_add_col('payments', 'verification_note', 'VARCHAR(255) DEFAULT NULL AFTER `verified_by`');

DROP PROCEDURE IF EXISTS hp_add_index;
DELIMITER $$
CREATE PROCEDURE hp_add_index(IN p_table VARCHAR(64), IN p_index VARCHAR(64), IN p_cols TEXT)
BEGIN
 IF NOT EXISTS (
  SELECT 1 FROM information_schema.STATISTICS
  WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = p_table AND INDEX_NAME = p_index
 ) THEN
  SET @hp_sql = CONCAT('ALTER TABLE `', p_table, '` ADD INDEX `', p_index, '` (', p_cols, ')');
  PREPARE hp_stmt FROM @hp_sql;
  EXECUTE hp_stmt;
  DEALLOCATE PREPARE hp_stmt;
 END IF;
END$$
DELIMITER ;

CALL hp_add_index('payments', 'idx_pay_tracking', '`order_tracking_id`');
CALL hp_add_index('payments', 'idx_pay_currency', '`currency`,`status`,`created_at`');

UPDATE payments
SET base_currency = 'UGX', base_amount = amount, currency = 'UGX',
 charged_amount = amount, charged_currency = 'UGX', fx_rate = 1
WHERE base_currency IS NULL;

CREATE TABLE IF NOT EXISTS payment_notifications (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 payment_id BIGINT UNSIGNED NOT NULL,
 channel ENUM('ipn','callback','manual') NOT NULL,
 order_tracking_id VARCHAR(120) NOT NULL,
 merchant_reference VARCHAR(190) NOT NULL,
 notification_type VARCHAR(60) DEFAULT NULL,
 payload_hash CHAR(64) NOT NULL,
 status VARCHAR(30) NOT NULL DEFAULT 'received',
 detail VARCHAR(255) DEFAULT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (id),
 UNIQUE KEY uq_payment_notification (payment_id,channel,order_tracking_id,payload_hash),
 KEY idx_payment_notification_payment (payment_id,created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS reservation_holds (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 reservation_id BIGINT UNSIGNED NOT NULL,
 room_type_id BIGINT UNSIGNED NOT NULL,
 room_id BIGINT UNSIGNED DEFAULT NULL,
 quantity INT NOT NULL DEFAULT 1,
 checkout_token VARCHAR(190) DEFAULT NULL,
 expires_at DATETIME NOT NULL,
 released_at DATETIME DEFAULT NULL,
 released_reason VARCHAR(60) DEFAULT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 PRIMARY KEY (id),
 KEY idx_hold_reservation (reservation_id),
 KEY idx_hold_expiry (released_at,expires_at),
 UNIQUE KEY uq_hold_checkout_token (checkout_token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

DROP PROCEDURE IF EXISTS hp_add_index;
DROP PROCEDURE IF EXISTS hp_add_col;
