-- ===========================================================================
-- STEP 0. RUN THIS BEFORE ANY SEED FILE.
--
-- It changes nothing and it cannot fail. Read the result, result, first.
--
-- EVERY table below is named as hotelpardise_system.something, and every
-- question about a table is asked of information_schema rather than of the
-- table itself. Both are deliberate, and both were needed to make this file
-- survive being run one statement at a time:
--
--   Qualified names. phpMyAdmin holds one database at a time. If you have
--   hotelpardise_website open, an unqualified "FROM hotels" is answered out of
--   the website database, which has no hotels table, and stops with #1146. A
--   qualified name says which database is meant no matter what is selected.
--
--   information_schema for existence. MySQL does not short-circuit CASE: a WHEN
--   branch that names a table which is not there is still prepared, so
--   "CASE WHEN ... ELSE (SELECT COUNT(*) FROM hotels)" raises #1109 on a
--   database where the table has not been created yet, which is exactly the
--   moment this file most needs to answer. Asking information_schema whether
--   the table exists cannot fail, because information_schema always does.
--
-- So any statement from this file can be pasted on its own, in any order,
-- into any database, and it will report rather than error.
--
--   EMPTY       No hotel and no schema tables. Start here:
--               01_LIVE_SYSTEM_SCHEMA.sql, then 02_LIVE_SYSTEM_SEED.sql,
--               then 07_FULL_MENU_SEED.sql.
--
--   INSTALLED   The hotel is already in place. Running the seed again adds
--               nothing: it stops on #1062 for the hotel slug, and if that is
--               worked around the guests, suppliers and rooms come out doubled.
--               Nothing is broken. To publish a changed menu, run
--               07_FULL_MENU_SEED.sql and nothing else.
--
--   HALF_DONE   Some schema tables exist but the hotel row does not. An install
--               was interrupted. Finish it rather than seeding on top:
--               C:/xampp/php/php.exe tools/install-databases.php
--
--   WRONG       You are looking at hotelpardise_website, which holds only the
--               three website_* tables. The menu lives in hotelpardise_system.
--
-- Why this file only reports, rather than refusing to run
--   An earlier version raised a MySQL error to stop you, which needed a stored
--   procedure. Any tool that splits a script on semicolons cuts the procedure
--   body in half and reports #1064 "syntax error near ''", which is a
--   confusing way to learn that nothing had been touched. Plain queries that
--   always return something work in every tool.
--
-- Paths use forward slashes on purpose. MySQL treats a backslash inside a
-- quoted string as an escape, so a Windows path would arrive with its
-- separators eaten.
-- ===========================================================================

-- 1. Which database is phpMyAdmin holding open? is_the_right_database must be 1
--    before the rest of this file means anything.
SELECT DATABASE() AS selected_database,
       DATABASE() = 'hotelpardise_system' AS is_the_right_database;

-- 2. Which of the tables this project needs actually exist, and in which
--    database. Both columns are read from information_schema, so neither can
--    fail whatever is selected.
SELECT table_name,
       table_schema,
       CASE table_schema WHEN 'hotelpardise_system' THEN 'in the right database'
                         ELSE 'elsewhere' END AS where_it_is
  FROM information_schema.tables
 WHERE table_name IN ('hotels','users','rooms','menu_categories','menu_items','reservations')
 ORDER BY table_name, table_schema;

-- 3. The hotel row, read through the information_schema row estimate so that
--    this statement is safe even on a database where hotels has not been
--    created. Approximate by nature; statement 4 gives the exact figure once
--    the table is known to be there.
SELECT table_schema,
       table_rows AS hotel_rows_estimate,
       table_rows > 0 AS looks_installed
  FROM information_schema.tables
 WHERE table_name = 'hotels'
 ORDER BY table_schema;

-- 4. The exact hotel count, and the exact count of the schema tables, from the
--    right database only. If this statement is refused with #1146 then
--    hotelpardise_system has not been created at all, which is the EMPTY case
--    below.
SELECT
  (SELECT COUNT(*) FROM hotelpardise_system.hotels) AS hotel_rows,
  (SELECT COUNT(*) FROM information_schema.tables
    WHERE table_schema = 'hotelpardise_system'
      AND table_name IN ('users','rooms','menu_items','reservations','menu_categories'))
    AS schema_tables_present;

-- 5. The one line that decides what you do next.
SELECT CASE
         WHEN DATABASE() = 'hotelpardise_website' OR DATABASE() IS NULL
           THEN 'WRONG DATABASE - select hotelpardise_system in phpMyAdmin and run this again'
         WHEN (SELECT COUNT(*) FROM information_schema.tables
                WHERE table_schema='hotelpardise_system' AND table_name='hotels') = 0
           THEN 'EMPTY - run 01_LIVE_SYSTEM_SCHEMA.sql, then 02_LIVE_SYSTEM_SEED.sql, then 07_FULL_MENU_SEED.sql'
         WHEN (SELECT COUNT(*) FROM hotelpardise_system.hotels) > 0
           THEN 'INSTALLED - do not seed. To publish a changed menu run 07_FULL_MENU_SEED.sql alone'
         WHEN (SELECT COUNT(*) FROM information_schema.tables
                WHERE table_schema='hotelpardise_system'
                  AND table_name IN ('users','rooms','menu_items','reservations')) > 0
           THEN 'HALF_DONE - an install was interrupted. Run: C:/xampp/php/php.exe tools/install-databases.php'
         ELSE 'EMPTY - run 01_LIVE_SYSTEM_SCHEMA.sql, then 02_LIVE_SYSTEM_SEED.sql, then 07_FULL_MENU_SEED.sql'
       END AS result;

-- 6. Where the published menu stands, and the duplicate check. Every table is
--    named in full, so this is correct whichever database phpMyAdmin is
--    holding. Expect 19 sections, 251 dishes, 0 unpriced and no duplicates.
--    duplicate_section_names must be 0: anything else means two rows are
--    fighting over one section, and see tools/fix-duplicate-menu-categories.sql.
SELECT
  (SELECT COUNT(*) FROM hotelpardise_system.menu_categories
    WHERE hotel_id = 1 AND published = 1) AS published_sections,
  (SELECT COUNT(*) FROM hotelpardise_system.menu_items
    WHERE hotel_id = 1 AND published = 1) AS published_dishes,
  (SELECT COUNT(*) FROM hotelpardise_system.menu_items
    WHERE hotel_id = 1 AND published = 1 AND price IS NULL) AS priced_on_request,
  (SELECT COUNT(*) FROM hotelpardise_system.menu_items i
    LEFT JOIN hotelpardise_system.menu_categories c ON c.id = i.category_id
   WHERE i.hotel_id = 1 AND i.published = 1
     AND (c.id IS NULL OR c.published = 0)) AS published_dish_with_no_section,
  (SELECT COUNT(*) FROM (SELECT name FROM hotelpardise_system.menu_categories
                          WHERE hotel_id = 1 AND outlet = 'restaurant'
                          GROUP BY name HAVING COUNT(*) > 1) d)
    AS duplicate_section_names;

-- 7. Must be zero. Text holding the bytes for the characters "Ã" or "Â" has been
--    encoded, read as latin1 and encoded again, which is what an import without
--    SET NAMES utf8mb4 does. Compared on HEX because a LIKE pattern containing
--    those characters is mangled by whichever client sends it, and reports a
--    clean database as dirty. See tools/repair-accented-dish-names.sql.
SELECT COUNT(*) AS mojibake_names
  FROM hotelpardise_system.menu_items
 WHERE hotel_id = 1 AND published = 1
   AND HEX(name) REGEXP 'C383|C382|C3A2E282AC';