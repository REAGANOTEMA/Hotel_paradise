-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-29_pos_custom_items.sql
-- Date: 2026-10-29
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- A guest sometimes asks the bar or the restaurant for something that is not
-- on the printed menu: a local dish, a special cocktail, a simple request the
-- kitchen can make. The POS must be able to add that line without first
-- inventing a permanent menu item, while the kitchen, F&B till, receipts and
-- reports must still read the same order.
--
-- WHAT IT CHANGES
--   1. Adds order_items.custom_name, the name written on the till.
--   2. Makes order_items.menu_item_id nullable, because a custom line has no
--      menu item behind it. Existing rows keep their menu_item_id unchanged.
--   3. Adds an index for looking up custom lines by name.
--
-- WHAT IT DOES NOT DO
--   It does not edit the clean baseline dump, any earlier patch, or any
--   existing order, payment or menu item. It does not create menu items.
--
-- HOW TO RUN
--   C:\xampp\mysql\bin\mysql.exe -u <user> -p hotelpardise_system < 2026-10-29_pos_custom_items.sql
-- or phpMyAdmin: system database -> Import -> choose this file -> Go.
--
-- It is safe to run more than once. The column is added only if missing, the
-- nullable definition is idempotent, and the index is added only if missing.
-- =============================================================================

SET NAMES utf8mb4;

-- -----------------------------------------------------------------------------
-- 1. A line can carry the name the guest asked for.
-- -----------------------------------------------------------------------------
ALTER TABLE order_items
  ADD COLUMN IF NOT EXISTS custom_name VARCHAR(190) DEFAULT NULL AFTER menu_item_id;

-- -----------------------------------------------------------------------------
-- 2. A custom line has no menu item. Existing menu lines keep their link.
-- -----------------------------------------------------------------------------
ALTER TABLE order_items
  MODIFY menu_item_id BIGINT UNSIGNED NULL DEFAULT NULL;

-- -----------------------------------------------------------------------------
-- 3. Index for reporting and for finding a custom request by name.
-- -----------------------------------------------------------------------------
ALTER TABLE order_items
  ADD INDEX IF NOT EXISTS hp_order_items_custom_name (custom_name);

-- Verification: custom_name exists and menu_item_id can be NULL.
SHOW COLUMNS FROM order_items LIKE 'custom_name';
SHOW COLUMNS FROM order_items LIKE 'menu_item_id';
