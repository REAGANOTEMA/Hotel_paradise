-- ===========================================================================
-- STEP 0. RUN THIS BEFORE ANY SEED FILE, IN phpMyAdmin.
--
-- It changes nothing. It either says the database is empty and the seed is
-- safe to run, or it stops with the reason, before a single row has been
-- half-written.
--
-- Why bother, when the seed's own first statement already fails on a populated
-- database: because "#1062 Duplicate entry 'hotel-paradise-on-the-nile' for
-- key 'slug'" is the symptom of running the seed twice, and the two halves of
-- that are very different problems.
--
--   The database is already installed, and the seed was run by mistake.
--       Nothing is broken. The fix is to stop, and to run this:
--         C:/xampp/php/php.exe tools/install-databases.php --check
--
--   The database is empty and empty is what you wanted.
--       The fix is to carry on with 01_LIVE_SYSTEM_SCHEMA.sql, then this seed.
--
-- phpMyAdmin sends this whole block to the server in one go, which is why the
-- procedure below has no DELIMITER line. Running it from a command line
-- instead needs one, because the mysql client splits statements on semicolons
-- and would cut the body in half:
--
--   mysql> DELIMITER //
--   (then paste the CREATE PROCEDURE and CALL lines, then DELIMITER ;)
--
-- Paths in the messages below are written with forward slashes on purpose.
-- MySQL treats a backslash inside SIGNAL MESSAGE_TEXT as an escape, so a
-- Windows path arrives on screen as C:xamppphpphp.exe.
-- ===========================================================================

USE hotelpardise_system;

DROP PROCEDURE IF EXISTS hp_seed_preflight;

CREATE PROCEDURE hp_seed_preflight()
BEGIN
  IF EXISTS (SELECT 1 FROM hotels) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
      'STOP. This database already contains a hotel record, so the seed files have already been applied to it. Running them again will not add anything: it stops with #1062 on the first line, and if that is worked around the guests, suppliers and rooms come out doubled. Nothing is wrong with the database. Leave it alone, and run: C:/xampp/php/php.exe tools/install-databases.php --check';
  END IF;

  IF EXISTS (SELECT 1 FROM information_schema.tables
             WHERE table_schema = 'hotelpardise_system'
               AND table_name IN ('users','rooms','menu_items','reservations')) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT =
      'STOP. Some of the schema tables exist but the hotel row does not, so this is a half-finished install, not a clean one. Finish it with: C:/xampp/php/php.exe tools/install-databases.php';
  END IF;

  SELECT 'OK. The database is empty. Run 01_LIVE_SYSTEM_SCHEMA.sql first, then 02_LIVE_SYSTEM_SEED.sql, then 07_FULL_MENU_SEED.sql.' AS result;
END;

CALL hp_seed_preflight();

-- Only the check is wanted here. Keeping the procedure would leave an object
-- in the database that the schema does not describe.
DROP PROCEDURE hp_seed_preflight;
