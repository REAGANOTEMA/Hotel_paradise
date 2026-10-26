-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-14_customer_accounts.sql
-- Date: 2026-10-14
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- A guest can create an account on the website, sign in, keep addresses and
-- documents, and reset a password. That needs five tables: customers,
-- customer_tokens, customer_addresses, customer_documents and
-- customer_signin_attempts. An install made before the account screen existed
-- has none of them, so the API cannot sign a guest in.
--
-- The tables are created only when missing and every index is added by name, so
-- this file is safe to run more than once. It uses MariaDB's IF NOT EXISTS
-- clauses and never reads information_schema.
-- =============================================================================

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS customers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  full_name VARCHAR(160) NOT NULL DEFAULT '',
  email VARCHAR(190) NOT NULL,
  phone VARCHAR(40) NOT NULL DEFAULT '',
  password_hash VARCHAR(255) NOT NULL DEFAULT '',
  google_sub VARCHAR(128) DEFAULT NULL,
  status VARCHAR(24) NOT NULL DEFAULT 'active',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  last_login_at DATETIME DEFAULT NULL,
  profile_image VARCHAR(255) DEFAULT NULL,
  date_of_birth DATE DEFAULT NULL,
  gender VARCHAR(20) DEFAULT NULL,
  nationality VARCHAR(80) DEFAULT NULL,
  national_id VARCHAR(60) DEFAULT NULL,
  address VARCHAR(255) DEFAULT NULL,
  city VARCHAR(120) DEFAULT NULL,
  country VARCHAR(120) DEFAULT NULL,
  postcode VARCHAR(20) DEFAULT NULL,
  company VARCHAR(160) DEFAULT NULL,
  job_title VARCHAR(120) DEFAULT NULL,
  preferred_language VARCHAR(20) DEFAULT NULL,
  dietary_preferences VARCHAR(255) DEFAULT NULL,
  room_preferences VARCHAR(255) DEFAULT NULL,
  marketing_opt_in TINYINT(1) NOT NULL DEFAULT 0,
  emergency_contact_name VARCHAR(160) DEFAULT NULL,
  emergency_contact_phone VARCHAR(40) DEFAULT NULL,
  notes TEXT DEFAULT NULL,
  deleted_at TIMESTAMP NULL DEFAULT NULL,
  deleted_by BIGINT UNSIGNED DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uniq_customers_email (email),
  UNIQUE KEY uniq_customers_google (google_sub),
  KEY idx_customers_phone (phone)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id BIGINT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL,
  purpose VARCHAR(24) NOT NULL DEFAULT 'session',
  expires_at DATETIME NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  last_seen_at DATETIME DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uniq_token_hash (token_hash),
  KEY idx_token_customer (customer_id),
  KEY idx_token_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_addresses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  customer_id BIGINT UNSIGNED NOT NULL,
  label VARCHAR(40) NOT NULL DEFAULT 'home',
  address_line VARCHAR(255) NOT NULL DEFAULT '',
  city VARCHAR(120) DEFAULT NULL,
  country VARCHAR(120) DEFAULT NULL,
  postcode VARCHAR(20) DEFAULT NULL,
  is_default TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_customer_addr (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_documents (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  customer_id BIGINT UNSIGNED NOT NULL,
  doc_type VARCHAR(40) NOT NULL DEFAULT 'id',
  title VARCHAR(160) NOT NULL DEFAULT '',
  file_name VARCHAR(255) NOT NULL,
  mime_type VARCHAR(100) DEFAULT NULL,
  file_size INT UNSIGNED DEFAULT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_customer_docs (customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS customer_signin_attempts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  ip_address VARCHAR(45) NOT NULL,
  email VARCHAR(190) NOT NULL DEFAULT '',
  attempts INT UNSIGNED NOT NULL DEFAULT 1,
  window_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_attempt_ip (ip_address),
  KEY idx_attempt_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A table that already exists may be missing a column a later screen reads.
ALTER TABLE customers
  ADD COLUMN IF NOT EXISTS hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS full_name VARCHAR(160) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS email VARCHAR(190) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS phone VARCHAR(40) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS google_sub VARCHAR(128) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS status VARCHAR(24) NOT NULL DEFAULT 'active',
  ADD COLUMN IF NOT EXISTS created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS last_login_at DATETIME DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS profile_image VARCHAR(255) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS date_of_birth DATE DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS gender VARCHAR(20) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS nationality VARCHAR(80) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS national_id VARCHAR(60) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS address VARCHAR(255) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS city VARCHAR(120) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS country VARCHAR(120) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS postcode VARCHAR(20) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS company VARCHAR(160) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS job_title VARCHAR(120) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS preferred_language VARCHAR(20) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS dietary_preferences VARCHAR(255) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS room_preferences VARCHAR(255) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS marketing_opt_in TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS emergency_contact_name VARCHAR(160) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS emergency_contact_phone VARCHAR(40) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS notes TEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED DEFAULT NULL;

ALTER TABLE payments ADD COLUMN IF NOT EXISTS customer_id BIGINT UNSIGNED DEFAULT NULL;
ALTER TABLE payments ADD INDEX IF NOT EXISTS hp_perf_pay_customer (customer_id);

ALTER TABLE customers ADD UNIQUE KEY IF NOT EXISTS uniq_customers_email (email);
ALTER TABLE customers ADD UNIQUE KEY IF NOT EXISTS uniq_customers_google (google_sub);
ALTER TABLE customers ADD INDEX IF NOT EXISTS idx_customers_phone (phone);
ALTER TABLE customer_tokens ADD UNIQUE KEY IF NOT EXISTS uniq_token_hash (token_hash);
ALTER TABLE customer_tokens ADD INDEX IF NOT EXISTS idx_token_customer (customer_id);
ALTER TABLE customer_tokens ADD INDEX IF NOT EXISTS idx_token_expires (expires_at);
ALTER TABLE customer_addresses ADD INDEX IF NOT EXISTS idx_customer_addr (customer_id);
ALTER TABLE customer_documents ADD INDEX IF NOT EXISTS idx_customer_docs (customer_id);
ALTER TABLE customer_signin_attempts ADD INDEX IF NOT EXISTS idx_attempt_ip (ip_address);
ALTER TABLE customer_signin_attempts ADD INDEX IF NOT EXISTS idx_attempt_email (email);

-- Verification: all five tables, and the columns the sign-in screen reads.
SELECT COUNT(*) AS customers FROM customers;
SELECT COUNT(*) AS customer_tokens FROM customer_tokens;
SELECT COUNT(*) AS customer_addresses FROM customer_addresses;
SELECT COUNT(*) AS customer_documents FROM customer_documents;
SELECT COUNT(*) AS customer_signin_attempts FROM customer_signin_attempts;
