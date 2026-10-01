-- HOTEL PARADISE ON THE NILE - REPAIR ACCENTED DISH NAMES
--
-- Run this once, against hotelpardise_system.
--
-- WHY THIS EXISTS
--   The seed file opens with SET NAMES utf8mb4, and that line is what makes
--   "Sauté" survive an import. Proved on this server with one accent row:
--     with SET NAMES utf8mb4        -> 5A5A20436166C3A9       "ZZ Café"
--     without it                    -> 5A5A20436166E2949CC2AE  mojibake
--     --default-character-set=utf8mb4 on the client does NOT help. Only the
--     in-file SET NAMES does, which is why importing through phpMyAdmin needs
--     the file sent whole rather than pasted line by line.
--
--   An import ran without it. Four rows were created with the characters "Ã"
--   and "©" where "é" belonged, all four published:
--     id 2802  "Chicken SautÃ©"                        30000  Chicken Dishes
--     id 2871  "SautÃ© Chicken Sichuan Style"         25000  Chinese Corner
--     id 2872  "SautÃ© Pork Sichuan Style (Hot)"      30000  Chinese Corner
--     id 2873  "SautÃ© Prawns with Black Bean Sauce"  45000  Chinese Corner
--
--   At the same time the three correctly spelled dishes were unpublished, for
--   the same reason a name that cannot be matched looks like a dish that has
--   been withdrawn:
--     id 1570  "Sauté Chicken Sichuan Style"          25000
--     id 1588  "Sauté Pork Sichuan Style (Hot)"       30000
--     id 1601  "Sauté Prawns with Black Bean Sauce"   45000
--   and "Chicken Sauté" survived only as id 62, unaccented and unpublished.
--
--   The guest saw four misnamed dishes on the menu and could not order the
--   three that were correctly named.
--
-- WHAT IT DOES
--   1. Retires the four bad rows under an ASCII name. They are not deleted, so
--      a past order that referenced one would still resolve.
--   2. Publishes the four correct rows: id 62 and the three Chinese Corner ids.
--   3. Reports, so the result is checked rather than trusted.
--
--   order_items holds no row for any of these ids, so nothing is rewritten.
--
-- NOTHING IS DELETED. No price, section or till flag is changed. Rows are
-- matched on id, which is unambiguous, rather than on a name, which is exactly
-- what went wrong.
--
-- Note for whoever reads this next: name is utf8mb4_unicode_ci, which is
-- ACCENT-INSENSITIVE. "Sauté" and "Saute" are the same key, and so are
-- "Sauté" and "SautÃ©". Correcting a name in place can therefore fail with
-- #1062 against a row that looks nothing like it. That is why the bad rows are
-- renamed out of the way first.
--
-- Run it with SET NAMES in force, which this file sets itself:
--   SOURCE database/tools/repair-accented-dish-names.sql;
-- or paste it into phpMyAdmin whole, which sends it in one request.

SET NAMES utf8mb4;

USE `hotelpardise_system`;

-- 1. Before: show what is there now, so the change can be compared.
SELECT id, name, HEX(name) AS hex, published
  FROM menu_items
 WHERE id IN (62, 1570, 1588, 1601, 2802, 2871, 2872, 2873)
 ORDER BY id;

-- 2. Rename the four bad rows out of the way first. name is utf8mb4_unicode_ci,
--    which is accent-insensitive, so "SautÃ©" occupies the same key as
--    "Sauté" and correcting a name in place fails with #1062 against a row
--    that looks nothing like it. These temporary names are plain ASCII so
--    this statement cannot itself be the thing that breaks.
UPDATE menu_items
   SET name = CONCAT('ZZ RETIRED ', id,
                     ' - mojibake name, correct dish is id ',
                     CASE id WHEN 2802 THEN '62' ELSE '1570, 1588 or 1601' END),
       published = 0
 WHERE id IN (2802, 2871, 2872, 2873) AND hotel_id = 1;

-- 3. Put the correct accent on id 62, the row the till has always sold, and
--    publish it. Written with HEX and CONVERT because an unprintable byte in a
--    SQL file is the failure this file exists to undo:
--    436869636B656E2053617574C3A9 is "Chicken Sauté" in utf8mb4.
UPDATE menu_items
   SET name = CONVERT(UNHEX('436869636B656E2053617574C3A9') USING utf8mb4),
       published = 1
 WHERE id = 62 AND hotel_id = 1;

-- 4. Republish the three Chinese Corner dishes. Their names were already
--    correct and are left exactly as they are.
UPDATE menu_items SET published = 1
 WHERE hotel_id = 1 AND id IN (1570, 1588, 1601);

-- 6. After. 62, 1570, 1588 and 1601 must be published with clean names. The
--    four retired rows must all read "ZZ RETIRED" and be unpublished.
SELECT id, name, HEX(name) AS hex, published, price, category_id
  FROM menu_items
 WHERE id IN (62, 1570, 1588, 1601, 2802, 2871, 2872, 2873)
 ORDER BY id;

-- 7. The numbers that decide whether the menu is whole. Expect 19, 251, 0, 0.
SELECT
  (SELECT COUNT(*) FROM menu_categories
    WHERE hotel_id = 1 AND published = 1) AS published_sections,
  (SELECT COUNT(*) FROM menu_items
    WHERE hotel_id = 1 AND published = 1) AS published_dishes,
  (SELECT COUNT(*) FROM menu_items
    WHERE hotel_id = 1 AND published = 1 AND price IS NULL) AS priced_on_request,
  (SELECT COUNT(*) FROM menu_items i
    LEFT JOIN menu_categories c ON c.id = i.category_id
   WHERE i.hotel_id = 1 AND i.published = 1
     AND (c.id IS NULL OR c.published = 0)) AS published_dish_with_no_section;

-- 8. Must be zero. A name holding the bytes for the characters "Ã" or "Â" is
--    mojibake: it means text was encoded, read as latin1 and encoded again.
--    Compared on HEX rather than LIKE, because a LIKE pattern containing those
--    characters is itself mangled by whichever client sends it, which reports
--    a clean database as dirty.
SELECT COUNT(*) AS mojibake_names
  FROM menu_items
 WHERE hotel_id = 1 AND published = 1
   AND HEX(name) REGEXP 'C383|C382|C3A2E282AC';