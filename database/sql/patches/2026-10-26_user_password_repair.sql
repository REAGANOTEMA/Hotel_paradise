-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-26_user_password_repair.sql
-- Date: 2026-10-26
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- The seeded team accounts were shipped with a password hash that does not
-- match the documented password (Paradise2026), and four accounts carried a
-- 48-character value that is not a valid bcrypt hash at all:
--
--   bar@..., store@..., auditor@..., staff@...
--
-- The result was that only the administrator could sign in. This patch repairs
-- those seed accounts so every department can reach its own dashboard.
--
-- It deliberately changes only accounts whose hash is the known seed hash, the
-- known broken value, or is missing/invalid. A password that a real member has
-- already changed is never overwritten.
--
-- HOW TO RUN
--   mysql -u <user> -p hotelpardise_system < 2026-10-26_user_password_repair.sql
-- or phpMyAdmin: system database -> Import -> choose this file -> Go.
--
-- AFTER RUNNING
-- The repaired accounts sign in with Paradise2026. Ask each member to change it
-- from My Profile on first use.
-- =============================================================================

SET NAMES utf8mb4;

-- The documented seed password: Paradise2026
SET @seed_password = '$2y$10$amjhbQVGYO9E6iSdJ5QhJ.bq/WFPSjb5MzXunbUNMEigs31Kp6fyu';
-- The old seed hash (valid bcrypt, but not for Paradise2026)
SET @known_seed_hash = '$2y$10$6YEDHEW7dXnvZ.QLpjahnei3/G0.i6vtahIyDWyv8bpQ9w2QorL4m';
-- The 48-character broken value (hex literal avoids backslash-escaping rules)
SET @broken_hash = 0x5c2f7849367472627a4d524d4f545641757a736c735074427a324a626f384367342e426a36684d463743494d6f485643;

UPDATE users
SET password_hash = @seed_password,
    password_changed_at = NOW()
WHERE email IN (
  'admin@hotelparadiseonthenile.info',
  'director@hotelparadiseonthenile.info',
  'gm@hotelparadiseonthenile.info',
  'accounts@hotelparadiseonthenile.info',
  'cashier@hotelparadiseonthenile.info',
  'frontdesk@hotelparadiseonthenile.info',
  'waiter@hotelparadiseonthenile.info',
  'bar@hotelparadiseonthenile.info',
  'kitchen@hotelparadiseonthenile.info',
  'store@hotelparadiseonthenile.info',
  'procurement@hotelparadiseonthenile.info',
  'housekeeping@hotelparadiseonthenile.info',
  'auditor@hotelparadiseonthenile.info',
  'staff@hotelparadiseonthenile.info'
)
AND (
  password_hash = @known_seed_hash
  OR password_hash = @broken_hash
  OR password_hash IS NULL
  OR password_hash = ''
  OR CHAR_LENGTH(password_hash) <> 60
);

-- Verification: every active seeded account should now carry a 60-character
-- bcrypt hash. The administrator's own hash may be different if it was changed;
-- that is expected and is why the count below is informational.
SELECT id, email, LENGTH(password_hash) AS hash_length
FROM users
WHERE email LIKE '%@hotelparadiseonthenile.info'
ORDER BY id;
