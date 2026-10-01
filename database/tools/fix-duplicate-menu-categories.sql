-- ===========================================================================
-- REPAIR DUPLICATE MENU SECTIONS
--
-- Read statement 1 first. It lists the duplicate section names, and returns no
-- rows when there is nothing to repair. If your live database already says
-- duplicate_section_names 0 (statement 6 of database/00_CHECK_BEFORE_SEEDING.sql),
-- you do not need this file.
--
-- WHEN YOU NEED IT
--   Two or more rows in menu_categories carry the same hotel_id, outlet and
--   name. One is enough. Two means the website lists the section once while the
--   till can hold two different sets of dishes under it, and adding the unique
--   key that prevents it becomes impossible.
--
--   Only database/01_LIVE_SYSTEM_SCHEMA.sql creates menu_categories with
--   UNIQUE KEY uq_menu_categories. Several older schema files create the table
--   without one, and the older menu files insert sections with a plain INSERT
--   and no ON DUPLICATE KEY UPDATE, so importing one of those twice leaves two
--   rows for every section. A database left over from the old name
--   hotel_paradise_nile, imported repeatedly, is the usual way this happens.
--
-- EVERY STATEMENT IS SELF-CONTAINED
--   Tables are named hotelpardise_system.something throughout, and the guarded
--   statements read their condition from information_schema, so any statement
--   can be pasted on its own into phpMyAdmin with whatever database selected,
--   and in any order. Two rules learned the hard way are built in:
--
--     * MySQL does not short-circuit CASE, so a branch naming a table that is
--       not there still errors. Existence is therefore always asked of
--       information_schema, which always exists.
--     * ALTER TABLE cannot be made conditional in plain SQL, so the key is
--       added by a prepared statement that tests information_schema first.
--       Without that, running this file twice fails with #1061.
--
-- WHAT IT CHANGES
--   Dishes are repointed to the oldest surviving section, so no dish and no past
--   order loses its section. Only then are duplicate rows that hold nothing
--   removed. Nothing is deleted that still holds a dish, and the till's active
--   and published flags are never touched.
--
-- Paths use forward slashes: MySQL eats a backslash inside a quoted string.
-- ===========================================================================

SET NAMES utf8mb4;

-- 1. What is duplicated, and how much sits under each copy. No rows means
--    there is nothing here to repair.
SELECT dup.name,
       COUNT(*) AS rows_found,
       GROUP_CONCAT(dup.id ORDER BY dup.id) AS ids,
       SUM((SELECT COUNT(*) FROM hotelpardise_system.menu_items i
             WHERE i.category_id = dup.id)) AS dishes_under_them
  FROM hotelpardise_system.menu_categories dup
 WHERE dup.name IN (
         SELECT name FROM hotelpardise_system.menu_categories
          WHERE hotel_id = 1 AND outlet = 'restaurant'
          GROUP BY name HAVING COUNT(*) > 1)
 GROUP BY dup.name
 ORDER BY dup.name;

-- 2. Repoint every dish to the oldest row of its section name. This is the
--    step that matters: run it before anything is deleted, or dishes are
--    orphaned. MIN(id) is the survivor, so the row a past order already points
--    at is the one that stays.
--
--    The aliases are c_old and c_keep rather than "old" and "keep" because OLD
--    is a reserved word in MySQL and MariaDB and the statement is refused with
--    #1064 if it is used as an identifier.
UPDATE hotelpardise_system.menu_items i
  JOIN hotelpardise_system.menu_categories c_old ON c_old.id = i.category_id
  JOIN hotelpardise_system.menu_categories c_keep
    ON c_keep.id = (SELECT MIN(k.id)
                      FROM hotelpardise_system.menu_categories k
                     WHERE k.hotel_id = c_old.hotel_id
                       AND k.outlet   = c_old.outlet
                       AND k.name     = c_old.name)
 WHERE i.category_id <> c_keep.id;

-- 3. Delete duplicate section rows, but only once they hold nothing, so this
--    cannot destroy a dish even if step 2 was edited or only partly applied.
DELETE dup
  FROM hotelpardise_system.menu_categories dup
  JOIN hotelpardise_system.menu_categories c_keep
    ON c_keep.hotel_id = dup.hotel_id
   AND c_keep.outlet   = dup.outlet
   AND c_keep.name     = dup.name
   AND c_keep.id      < dup.id
 WHERE NOT EXISTS (SELECT 1 FROM hotelpardise_system.menu_items i
                    WHERE i.category_id = dup.id);

-- 4. Add the key that stops this returning. Guarded, because a plain
--    ALTER TABLE ADD UNIQUE KEY fails with #1061 on the second run.
SET @has_key := (SELECT COUNT(*) FROM information_schema.statistics
                  WHERE table_schema = 'hotelpardise_system'
                    AND table_name   = 'menu_categories'
                    AND index_name   = 'uq_menu_categories');
SET @add_key := IF(@has_key = 0,
                   'ALTER TABLE hotelpardise_system.menu_categories
                      ADD UNIQUE KEY uq_menu_categories (hotel_id, outlet, name)',
                   'DO 0');
PREPARE add_uq FROM @add_key;
EXECUTE add_uq;
DEALLOCATE PREPARE add_uq;

-- 5. The key is now in place, or was already there. Both counts must be zero.
SELECT
  (SELECT COUNT(*) FROM (SELECT name FROM hotelpardise_system.menu_categories
                          WHERE hotel_id = 1 AND outlet = 'restaurant'
                          GROUP BY name HAVING COUNT(*) > 1) d)
    AS duplicate_section_names,
  (SELECT COUNT(*) FROM hotelpardise_system.menu_items i
    LEFT JOIN hotelpardise_system.menu_categories c ON c.id = i.category_id
   WHERE i.hotel_id = 1 AND i.published = 1
     AND (c.id IS NULL OR c.published = 0))
    AS published_dish_with_no_section,
  (SELECT COUNT(*) FROM information_schema.statistics
    WHERE table_schema = 'hotelpardise_system'
      AND table_name   = 'menu_categories'
      AND index_name   = 'uq_menu_categories') AS unique_key_columns;