-- ===========================================================================
-- STEP 0. RUN THIS BEFORE ANY SEED FILE.
--
-- It changes nothing and it cannot fail. It only reports, so it is safe to run
-- in phpMyAdmin, in phpMyAdmin's SQL box, from a command line, or pasted into
-- any tool that splits a file into single statements.
--
-- Read the last result set, result, before running anything else:
--
--   EMPTY       The database has no hotel and no schema tables. Start here:
--               01_LIVE_SYSTEM_SCHEMA.sql, then 02_LIVE_SYSTEM_SEED.sql,
--               then 07_FULL_MENU_SEED.sql.
--
--   INSTALLED   The hotel is already in place. Running the seed again adds
--               nothing: it stops on #1062 for the hotel slug, and if that is
--               worked around the guests, suppliers and rooms come out doubled.
--               Nothing is broken. To update the menu alone, run
--               07_FULL_MENU_SEED.sql and nothing else.
--
--   HALF_DONE   Some schema tables exist but the hotel row does not. That is an
--               interrupted install. Finish it rather than seeding on top:
--               C:/xampp/php/php.exe tools/install-databases.php
--
-- Why this file only reports, rather than refusing to run
--   The earlier version of this file raised a MySQL error to stop you, which
--   needed a stored procedure. Any client that splits a script on semicolons
--   cuts the procedure body in half and reports #1064 "syntax error near '' ",
--   which is a confusing way to learn that the database was never touched.
--   Reporting the same three answers in plain queries works everywhere.
--
-- Paths in the messages below use forward slashes on purpose. MySQL treats a
-- backslash inside a quoted string as an escape, so a Windows path would
-- otherwise arrive on screen with its separators eaten.
-- ===========================================================================

-- Which database this file is actually talking to. If database_name is not
-- hotelpardise_system, stop: the rest of this file is reporting on the wrong
-- database, and so would any seed file run from here.
SELECT DATABASE() AS database_name,
       DATABASE() = 'hotelpardise_system' AS is_the_right_database;

-- How many of the schema tables are present.
SELECT COUNT(*) AS schema_tables_present
  FROM information_schema.tables
 WHERE table_schema = 'hotelpardise_system'
   AND table_name IN ('users','rooms','menu_items','reservations','menu_categories');

-- The hotel row, if there is one.
SELECT COUNT(*) AS hotel_rows
  FROM information_schema.tables
 WHERE table_schema = 'hotelpardise_system' AND table_name = 'hotels';

-- The one line that decides what you do next.
SELECT CASE
         WHEN DATABASE() <> 'hotelpardise_system' THEN 'WRONG DATABASE - select hotelpardise_system and run this again'
         WHEN (SELECT COUNT(*) FROM hotels) > 0 THEN 'INSTALLED - do not seed. To update the menu run 07_FULL_MENU_SEED.sql alone'
         WHEN (SELECT COUNT(*) FROM information_schema.tables
                WHERE table_schema = 'hotelpardise_system'
                  AND table_name IN ('users','rooms','menu_items','reservations')) > 0
           THEN 'HALF_DONE - an install was interrupted. Run: C:/xampp/php/php.exe tools/install-databases.php'
         ELSE 'EMPTY - run 01_LIVE_SYSTEM_SCHEMA.sql, then 02_LIVE_SYSTEM_SEED.sql, then 07_FULL_MENU_SEED.sql'
       END AS result;

-- Where the website's menu currently stands. Safe to read at any time, and
-- useful after 07_FULL_MENU_SEED.sql: these are the numbers to check.
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