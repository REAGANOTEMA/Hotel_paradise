SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS finance_cash_movements (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  shift_id BIGINT UNSIGNED DEFAULT NULL,
  outlet VARCHAR(40) DEFAULT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  movement_type ENUM('float','cash_in','cash_out','drop','payout','refund','correction') NOT NULL,
  direction ENUM('in','out') NOT NULL,
  amount DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  method VARCHAR(50) NOT NULL DEFAULT 'cash',
  reference VARCHAR(190) DEFAULT NULL,
  reason VARCHAR(500) NOT NULL,
  status ENUM('recorded','approved','rejected','reversed') NOT NULL DEFAULT 'recorded',
  approved_by BIGINT UNSIGNED DEFAULT NULL,
  approved_at DATETIME DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_fin_cash_shift (shift_id,created_at),
  KEY idx_fin_cash_status (status,created_at),
  KEY idx_fin_cash_type (movement_type,created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS finance_bank_accounts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(150) NOT NULL,
  bank_name VARCHAR(150) DEFAULT NULL,
  account_name VARCHAR(190) DEFAULT NULL,
  account_number_last4 VARCHAR(12) DEFAULT NULL,
  method VARCHAR(50) NOT NULL DEFAULT 'bank',
  account_type ENUM('bank','mobile_money','card','other') NOT NULL DEFAULT 'bank',
  currency VARCHAR(8) NOT NULL DEFAULT 'UGX',
  opening_balance DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_by BIGINT UNSIGNED DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_fin_bank_method (method,active),
  KEY idx_fin_bank_active (active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS finance_bank_transactions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  account_id BIGINT UNSIGNED NOT NULL,
  transaction_date DATE NOT NULL,
  direction ENUM('in','out') NOT NULL,
  amount DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  reference VARCHAR(190) DEFAULT NULL,
  description VARCHAR(255) NOT NULL,
  status ENUM('unmatched','matched','ignored') NOT NULL DEFAULT 'unmatched',
  matched_type VARCHAR(60) DEFAULT NULL,
  matched_id BIGINT UNSIGNED DEFAULT NULL,
  created_by BIGINT UNSIGNED DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_fin_bank_tx_account (account_id,transaction_date),
  KEY idx_fin_bank_tx_status (status,transaction_date),
  KEY idx_fin_bank_tx_ref (reference)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS finance_reconciliations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  account_id BIGINT UNSIGNED NOT NULL,
  period_start DATE NOT NULL,
  period_end DATE NOT NULL,
  opening_balance DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  statement_in DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  statement_out DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  statement_closing DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  book_balance DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  difference DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  status ENUM('draft','reviewed') NOT NULL DEFAULT 'draft',
  prepared_by BIGINT UNSIGNED NOT NULL,
  reviewed_by BIGINT UNSIGNED DEFAULT NULL,
  reviewed_at DATETIME DEFAULT NULL,
  notes VARCHAR(500) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_fin_recon_account (account_id,period_end),
  KEY idx_fin_recon_status (status,period_end)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='journal_entries' AND COLUMN_NAME='source_type')=0,
  'ALTER TABLE journal_entries ADD COLUMN source_type VARCHAR(60) DEFAULT NULL AFTER status', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='journal_entries' AND COLUMN_NAME='source_id')=0,
  'ALTER TABLE journal_entries ADD COLUMN source_id BIGINT UNSIGNED DEFAULT NULL AFTER source_type', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='journal_entries' AND COLUMN_NAME='posted_at')=0,
  'ALTER TABLE journal_entries ADD COLUMN posted_at DATETIME DEFAULT NULL AFTER posted_by', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='journal_entries' AND COLUMN_NAME='approved_by')=0,
  'ALTER TABLE journal_entries ADD COLUMN approved_by BIGINT UNSIGNED DEFAULT NULL AFTER posted_at', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='journal_entries' AND COLUMN_NAME='approved_at')=0,
  'ALTER TABLE journal_entries ADD COLUMN approved_at DATETIME DEFAULT NULL AFTER approved_by', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='journal_entries' AND COLUMN_NAME='reversal_of')=0,
  'ALTER TABLE journal_entries ADD COLUMN reversal_of BIGINT UNSIGNED DEFAULT NULL AFTER approved_at', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF((SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='journal_entries' AND COLUMN_NAME='reversal_reason')=0,
  'ALTER TABLE journal_entries ADD COLUMN reversal_reason VARCHAR(500) DEFAULT NULL AFTER reversal_of', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @sql := IF((SELECT COUNT(*) FROM information_schema.STATISTICS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='journal_entries' AND INDEX_NAME='idx_fin_journal_source')=0,
  'ALTER TABLE journal_entries ADD INDEX idx_fin_journal_source (source_type,source_id)', 'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;

SET @has_coa := (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='chart_of_accounts');
SET @sql := IF(@has_coa>0,
  'INSERT INTO chart_of_accounts(property_id,account_code,account_name,account_type,active)
   SELECT 1,x.account_code,x.account_name,x.account_type,1 FROM (
     SELECT ''1000'' AS account_code,''Cash on hand'' AS account_name,''asset'' AS account_type UNION ALL
     SELECT ''1010'',''Bank account'',''asset'' UNION ALL
     SELECT ''1020'',''Mobile money wallet'',''asset'' UNION ALL
     SELECT ''1030'',''Card settlement clearing'',''asset'' UNION ALL
     SELECT ''1100'',''Accounts receivable'',''asset'' UNION ALL
     SELECT ''1200'',''Inventory'',''asset'' UNION ALL
     SELECT ''2000'',''Accounts payable'',''liability'' UNION ALL
     SELECT ''2100'',''Tax and service charge payable'',''liability'' UNION ALL
     SELECT ''2200'',''Guest deposits'',''liability'' UNION ALL
     SELECT ''3000'',''Owner equity'',''equity'' UNION ALL
     SELECT ''3900'',''Retained earnings'',''equity'' UNION ALL
     SELECT ''4000'',''Room and venue revenue'',''income'' UNION ALL
     SELECT ''4100'',''Food and beverage revenue'',''income'' UNION ALL
     SELECT ''4200'',''Other operating revenue'',''income'' UNION ALL
     SELECT ''4900'',''Other income'',''income'' UNION ALL
     SELECT ''5000'',''Cost of sales'',''expense'' UNION ALL
     SELECT ''5100'',''Payroll and staff costs'',''expense'' UNION ALL
     SELECT ''5200'',''Utilities'',''expense'' UNION ALL
     SELECT ''5300'',''Repairs and maintenance'',''expense'' UNION ALL
     SELECT ''5400'',''Marketing'',''expense'' UNION ALL
     SELECT ''5500'',''Transport and travel'',''expense'' UNION ALL
     SELECT ''5600'',''Administration'',''expense''
   ) x
   WHERE NOT EXISTS (SELECT 1 FROM chart_of_accounts a WHERE a.account_code=x.account_code)',
  'SELECT 1');
PREPARE stmt FROM @sql; EXECUTE stmt; DEALLOCATE PREPARE stmt;
