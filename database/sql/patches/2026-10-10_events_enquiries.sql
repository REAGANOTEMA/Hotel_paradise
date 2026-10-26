-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-10_events_enquiries.sql
-- Date: 2026-10-10
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- The website's "Plan an event" and "Facilities" forms write straight into
-- event_requests and facility_enquiries. An install made before those tables
-- existed had no way to accept the enquiry, and the Events & Enquiries screen
-- had nothing to read. This patch creates both tables and their indexes.
--
-- The API and the console also create the tables on first use, so a site that
-- never ran this file still works. This is the explicit, repeatable version.
-- It uses MariaDB's IF NOT EXISTS clauses and never reads information_schema.
-- =============================================================================

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS event_requests (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  request_number VARCHAR(24) NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  phone VARCHAR(40) NOT NULL,
  email VARCHAR(160) DEFAULT NULL,
  event_type VARCHAR(80) NOT NULL,
  event_date DATE DEFAULT NULL,
  guests INT UNSIGNED DEFAULT NULL,
  venue VARCHAR(80) DEFAULT NULL,
  message TEXT DEFAULT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'new',
  created_at DATETIME NOT NULL,
  updated_at DATETIME DEFAULT NULL,
  deleted_at TIMESTAMP NULL DEFAULT NULL,
  deleted_by BIGINT UNSIGNED DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_event_number (request_number),
  KEY idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS facility_enquiries (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  enquiry_number VARCHAR(24) NOT NULL,
  full_name VARCHAR(120) NOT NULL,
  phone VARCHAR(40) NOT NULL,
  email VARCHAR(160) DEFAULT NULL,
  facility VARCHAR(80) DEFAULT NULL,
  preferred_date DATE DEFAULT NULL,
  guests INT UNSIGNED DEFAULT NULL,
  message TEXT DEFAULT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'new',
  created_at DATETIME NOT NULL,
  updated_at DATETIME DEFAULT NULL,
  deleted_at TIMESTAMP NULL DEFAULT NULL,
  deleted_by BIGINT UNSIGNED DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_enquiry_number (enquiry_number),
  KEY idx_deleted_at (deleted_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- An older copy of either table may carry the rows but not every column.
ALTER TABLE event_requests
  ADD COLUMN IF NOT EXISTS hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS request_number VARCHAR(24) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS full_name VARCHAR(120) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS phone VARCHAR(40) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS email VARCHAR(160) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS event_type VARCHAR(80) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS event_date DATE DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS guests INT UNSIGNED DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS venue VARCHAR(80) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS message TEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'new',
  ADD COLUMN IF NOT EXISTS created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS updated_at DATETIME DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED DEFAULT NULL;

ALTER TABLE facility_enquiries
  ADD COLUMN IF NOT EXISTS hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS enquiry_number VARCHAR(24) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS full_name VARCHAR(120) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS phone VARCHAR(40) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS email VARCHAR(160) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS facility VARCHAR(80) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS preferred_date DATE DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS guests INT UNSIGNED DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS message TEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'new',
  ADD COLUMN IF NOT EXISTS created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS updated_at DATETIME DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED DEFAULT NULL;

ALTER TABLE event_requests      ADD INDEX IF NOT EXISTS idx_deleted_at (deleted_at);
ALTER TABLE facility_enquiries  ADD INDEX IF NOT EXISTS idx_deleted_at (deleted_at);

-- Verification: both tables should answer with a row count and their columns.
SELECT COUNT(*) AS event_requests FROM event_requests;
SELECT COUNT(*) AS facility_enquiries FROM facility_enquiries;
