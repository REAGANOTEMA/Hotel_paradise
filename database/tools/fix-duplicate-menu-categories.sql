-- HOTEL PARADISE ON THE NILE - REPAIR DUPLICATE MENU SECTIONS
--
-- What this is for
--   Error 1242, "Subquery returns more than 1 row", on a menu import.
--
-- What causes it
--   Only database/01_LIVE_SYSTEM_SCHEMA.sql creates menu_categories with
--   UNIQUE KEY uq_menu_categories (hotel_id, outlet, name). The other fifteen
--   schema files in this repository create the table without one, and the older
--   menu files insert sections with a plain INSERT and no ON DUPLICATE KEY. So
--   importing an older menu file twice, or importing two different menu files,
--   leaves two rows for every section name.
--
--   The old menu files then failed on the two sections whose name contains an
--   apostrophe, because those two subqueries alone were written without the
--   LIMIT 1 that the sixty-eight lookups beside them carried:
--       (SELECT id FROM menu_categories WHERE name='Fisherman''s Offer')
--   Two rows matched, the subquery returned more than one row, and the import
--   aborted with 1242. All of those lookups now carry LIMIT 1, so the import
--   completes either way, but the duplicate rows are still wrong to leave.
--
-- Why duplicates must be cleared rather than tolerated
--   07_FULL_MENU_SEED.sql is written to survive a duplicated table: every
--   lookup takes the lowest id, so the import completes and the website works.
--   But the duplicates are still wrong. Two rows for "Pizzeria" means the
--   website lists the section once while the till can hold two different
--   dishes under it, and the moment the unique key is added the second row
--   cannot be inserted at all.
--
-- Read this first
--   Run the SELECT at the bottom of this file before the repair. It lists only
--   the duplicate names, so you can see what you are about to change. If it
--   returns no rows, there is nothing to fix here and error 1242 came from
--   something else.
--
-- What it changes
--   menu_items rows are repointed to the oldest surviving section, so no dish
--   and no past order loses its section. Only then are the empty duplicate rows
--   removed. Nothing is deleted that still holds a dish, and the till's active
--   and published flags are not touched.

USE `hotelpardise_system`;

SET NAMES utf8mb4;

-- 1. What is duplicated, and how much would be repointed.
SELECT c.name,
       COUNT(*) AS rows_found,
       GROUP_CONCAT(c.id ORDER BY c.id) AS ids,
       SUM((SELECT COUNT(*) FROM menu_items i WHERE i.category_id = c.id)) AS dishes_under_them
  FROM menu_categories c
 WHERE c.name IN (
         SELECT name FROM menu_categories
          WHERE hotel_id = 1 AND outlet = 'restaurant'
          GROUP BY name HAVING COUNT(*) > 1)
 GROUP BY c.name
 ORDER BY c.name;

-- 2. Repoint every dish to the oldest row of its section name. This is the
--    step that matters: do it before deleting anything, or dishes are orphaned.
--    MIN(id) is the survivor, so the row any past order already points at is
--    the one that stays.
UPDATE menu_items i
  JOIN menu_categories old ON old.id = i.category_id
  JOIN menu_categories keep
    ON keep.id = (SELECT MIN(k.id)
                    FROM menu_categories k
                   WHERE k.hotel_id = old.hotel_id
                     AND k.outlet   = old.outlet
                     AND k.name     = old.name)
 WHERE i.category_id <> keep.id;

-- 3. Delete duplicate section rows, but only once they hold nothing, so this
--    cannot destroy a dish even if step 2 was edited or partially applied.
DELETE c
  FROM menu_categories c
  JOIN menu_categories keep
    ON keep.hotel_id = c.hotel_id AND keep.outlet = c.outlet AND keep.name = c.name
   AND keep.id < c.id
 WHERE NOT EXISTS (SELECT 1 FROM menu_items i WHERE i.category_id = c.id);

-- 4. Add the key that stops this happening again. Safe to run twice; MySQL
--    names the duplicate index and skips it. This fails if step 3 left a
--    duplicate behind, which is the point: it refuses to let the problem
--    settle back in.
ALTER TABLE menu_categories
  ADD UNIQUE KEY uq_menu_categories (hotel_id, outlet, name);

-- 5. Confirm. Both counts must be zero.
SELECT COUNT(*) AS duplicate_section_names
  FROM (SELECT name FROM menu_categories
         WHERE hotel_id = 1 AND outlet = 'restaurant'
         GROUP BY name HAVING COUNT(*) > 1) d;

-- The sections themselves, oldest id first, so the duplicate rows are visible
-- rather than merely counted.
SELECT c.id, c.name, c.outlet, c.published, c.sort_order,
       (SELECT COUNT(*) FROM menu_items i WHERE i.category_id = c.id) AS dishes_under
  FROM menu_categories c
 WHERE c.hotel_id = 1 AND c.outlet = 'restaurant'
   AND c.name IN (SELECT d.name FROM (
         SELECT name FROM menu_categories
          WHERE hotel_id = 1 AND outlet = 'restaurant'
          GROUP BY name HAVING COUNT(*) > 1) d)
 ORDER BY c.name, c.id;

SELECT COUNT(*) AS published_dish_with_no_section
  FROM menu_items i
  LEFT JOIN menu_categories c ON c.id = i.category_id
 WHERE i.hotel_id = 1 AND i.published = 1
   AND (c.id IS NULL OR c.published = 0);