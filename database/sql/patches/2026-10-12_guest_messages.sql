-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-12_guest_messages.sql
-- Date: 2026-10-12
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- Guest Messages and Guest Experiences share one table, guest_messages. The
-- website writes an enquiry or a stay review into it, and the console reads and
-- answers it. An install that predates the feature has no table, which leaves
-- both screens with their "upgrade not installed" notice.
--
-- The API also creates the table on first contact, so a live site never loses a
-- message. This is the explicit migration, safe to run more than once and free
-- of information_schema and stored procedures.
-- =============================================================================

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS guest_messages (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id INT UNSIGNED NOT NULL DEFAULT 1,
  reference VARCHAR(40) NOT NULL,
  source ENUM('website','in_stay') NOT NULL DEFAULT 'website',
  kind ENUM('message','experience') NOT NULL DEFAULT 'message',
  full_name VARCHAR(120) NOT NULL,
  phone VARCHAR(40) DEFAULT NULL,
  email VARCHAR(160) DEFAULT NULL,
  department ENUM('front_office','kitchen') NOT NULL DEFAULT 'front_office',
  room_number VARCHAR(20) DEFAULT NULL,
  subject VARCHAR(160) DEFAULT NULL,
  message TEXT NOT NULL,
  rating TINYINT UNSIGNED DEFAULT NULL,
  status ENUM('new','assigned','resolved','featured') NOT NULL DEFAULT 'new',
  assigned_to INT UNSIGNED DEFAULT NULL,
  reply TEXT DEFAULT NULL,
  replied_by INT UNSIGNED DEFAULT NULL,
  replied_at DATETIME DEFAULT NULL,
  created_at DATETIME NOT NULL,
  updated_at DATETIME DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_gm_reference (reference),
  KEY idx_gm_status (status),
  KEY idx_gm_dept_status (department,status),
  KEY idx_gm_kind_status (kind,status),
  KEY idx_gm_assigned (assigned_to),
  KEY idx_gm_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- An older copy may be missing a column the console reads.
ALTER TABLE guest_messages
  ADD COLUMN IF NOT EXISTS hotel_id INT UNSIGNED NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS reference VARCHAR(40) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS source ENUM('website','in_stay') NOT NULL DEFAULT 'website',
  ADD COLUMN IF NOT EXISTS kind ENUM('message','experience') NOT NULL DEFAULT 'message',
  ADD COLUMN IF NOT EXISTS full_name VARCHAR(120) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS phone VARCHAR(40) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS email VARCHAR(160) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS department ENUM('front_office','kitchen') NOT NULL DEFAULT 'front_office',
  ADD COLUMN IF NOT EXISTS room_number VARCHAR(20) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS subject VARCHAR(160) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS message TEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS rating TINYINT UNSIGNED DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS status ENUM('new','assigned','resolved','featured') NOT NULL DEFAULT 'new',
  ADD COLUMN IF NOT EXISTS assigned_to INT UNSIGNED DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS reply TEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS replied_by INT UNSIGNED DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS replied_at DATETIME DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS updated_at DATETIME DEFAULT NULL;

ALTER TABLE guest_messages ADD INDEX IF NOT EXISTS idx_gm_status      (status);
ALTER TABLE guest_messages ADD INDEX IF NOT EXISTS idx_gm_dept_status (department,status);
ALTER TABLE guest_messages ADD INDEX IF NOT EXISTS idx_gm_kind_status (kind,status);
ALTER TABLE guest_messages ADD INDEX IF NOT EXISTS idx_gm_assigned    (assigned_to);
ALTER TABLE guest_messages ADD INDEX IF NOT EXISTS idx_gm_created     (created_at);

-- Verification: the table exists and its columns are present.
SELECT COUNT(*) AS guest_messages FROM guest_messages;
SHOW COLUMNS FROM guest_messages LIKE 'kind';
SHOW COLUMNS FROM guest_messages LIKE 'status';
