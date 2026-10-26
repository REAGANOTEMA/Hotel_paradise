-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-13_soft_delete_columns.sql
-- Date: 2026-10-13
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- Every list the console shows or moves to Trash filters on deleted_at and
-- records deleted_by. A table built by an early module may predate those columns,
-- which made the list fail with "Unknown column 'deleted_at' in 'where clause'".
--
-- This version uses MariaDB's ADD COLUMN IF NOT EXISTS, so it needs no stored
-- procedure and never reads information_schema. It adds the pair only where a
-- table exists and the column is missing, so it is safe to run more than once.
-- The console performs the same repair on first use, so this file is for anyone
-- who prefers to run it by hand.
--
-- The tables that only exist on newer installs (event_requests,
-- facility_enquiries, news_posts, customers) are created with the pair by their
-- own patches, which run earlier in date order. purchase_requisitions and
-- purchase_orders are handled the same way by the procurement patch.
-- =============================================================================

SET NAMES utf8mb4;

ALTER TABLE guests               ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL;
ALTER TABLE guests               ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED NULL;
ALTER TABLE suppliers            ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL;
ALTER TABLE suppliers            ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED NULL;
ALTER TABLE users                ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL;
ALTER TABLE users                ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED NULL;
ALTER TABLE inventory_items      ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL;
ALTER TABLE inventory_items      ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED NULL;
ALTER TABLE inventory_categories ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL;
ALTER TABLE inventory_categories ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED NULL;
ALTER TABLE expenses             ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL;
ALTER TABLE expenses             ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED NULL;
ALTER TABLE reservations         ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL;
ALTER TABLE reservations         ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED NULL;
ALTER TABLE rooms                ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL;
ALTER TABLE rooms                ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED NULL;
ALTER TABLE room_types           ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL;
ALTER TABLE room_types           ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED NULL;
ALTER TABLE orders               ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL;
ALTER TABLE orders               ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED NULL;

-- Verification: each of these should return the two rows (one per column).
-- SHOW COLUMNS FROM guests LIKE 'deleted_%';
-- SHOW COLUMNS FROM news_posts LIKE 'deleted_%';
