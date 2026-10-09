-- ============================================================================
--  Receipts by email
--  Run this on the MAIN system database: hotelpardise_system
--
--  The management system already creates this table the first time a payment
--  settles (see backend-php/app/receipts.php), so this file is not required for
--  the feature to work. It is the durable copy of the same definition, for a
--  database that was installed before the feature existed and would rather be
--  patched by hand than by request.
--
--  It is safe to run more than once.
-- ============================================================================

CREATE TABLE IF NOT EXISTS `receipt_deliveries` (
  `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `payment_id` BIGINT(20) UNSIGNED NOT NULL,
  `hotel_id` BIGINT(20) UNSIGNED NOT NULL DEFAULT 1,
  `source` VARCHAR(20) NOT NULL DEFAULT '',
  `reference` VARCHAR(120) NOT NULL DEFAULT '',
  `channel` ENUM('email','print') NOT NULL DEFAULT 'email',
  `recipient` VARCHAR(190) NOT NULL DEFAULT '',
  `status` ENUM('sent','failed') NOT NULL DEFAULT 'failed',
  `attempts` INT(10) UNSIGNED NOT NULL DEFAULT 0,
  `last_error` VARCHAR(500) DEFAULT NULL,
  `provider_message_id` VARCHAR(190) DEFAULT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_receipt_payment_channel` (`payment_id`, `channel`),
  KEY `idx_receipt_source` (`source`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
