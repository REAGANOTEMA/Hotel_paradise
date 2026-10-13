-- Hotel Paradise on the Nile
-- Patch: 2026-10-13_soft_delete_columns
-- Database: hotelpardise_system (MAIN system only)
--
-- Makes sure every table the console lists or trashes carries deleted_at and
-- deleted_by. A few of those tables are built by the modules themselves on
-- first use, and the earliest installs were made before the pair was part of
-- that definition, which left some lists failing with
-- "Unknown column 'deleted_at' in 'where clause'".
--
-- The console repairs the column on its own when it is missing, and this patch
-- is the same repair made explicit for anyone who would rather run it by hand.
-- It only ever adds a missing column and never changes a table that already
-- has it, so running it again is a no-op.

USE hotelpardise_system;

SET @tables := 'guests,suppliers,users,inventory_items,inventory_categories,expenses,
 event_requests,facility_enquiries,news_posts,reservations,purchase_requisitions,
 purchase_orders,rooms,room_types,customers,orders';

SET SESSION group_concat_max_len = 20000;

SET @sql := (
  SELECT GROUP_CONCAT(
    CONCAT(
      'ALTER TABLE `', TABLE_NAME,
      '` ADD COLUMN IF NOT EXISTS `deleted_at` TIMESTAMP NULL DEFAULT NULL, ',
      'ADD COLUMN IF NOT EXISTS `deleted_by` BIGINT UNSIGNED NULL'
    ) SEPARATOR '; '
  )
  FROM information_schema.COLUMNS
  WHERE TABLE_SCHEMA = DATABASE()
    AND FIND_IN_SET(TABLE_NAME, @tables)
  GROUP BY TABLE_NAME
);

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Verify the pair now exists on every table it is meant to.
SELECT TABLE_NAME,
       SUM(COLUMN_NAME = 'deleted_at') AS has_deleted_at,
       SUM(COLUMN_NAME = 'deleted_by') AS has_deleted_by
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND FIND_IN_SET(TABLE_NAME, @tables)
GROUP BY TABLE_NAME
ORDER BY TABLE_NAME;