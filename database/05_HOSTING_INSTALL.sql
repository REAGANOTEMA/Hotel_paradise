-- HOTEL PARADISE ON THE NILE - HOSTING INSTALLER
--
-- Creates the two databases and the two users the site needs, and grants each
-- user only what it should have.
--
--   hotelpardise_system   the hotel. Menu, rooms, guests, orders, staff.
--   hotelpardise_website  the website's own tables, such as website_settings.
--
-- The website's menu and takeaway orders are written to hotelpardise_system on
-- purpose: the dish the guest reads, the order the kitchen receives and the row
-- the till settles have to be the same rows. A separate copy of the menu would
-- quietly drift away from the one the restaurant actually serves.
--
-- ---------------------------------------------------------------------------
-- RUN THIS SECOND, NOT FIRST.
--
-- A grant on a named table only takes if that table already exists, so this file
-- has to follow database/01_LIVE_SYSTEM_SCHEMA.sql. Running it first fails with
-- "Table 'hotelpardise_system.menu_items' doesn't exist" on the grants near the
-- end, and those are the grants that matter. The order that works is:
--
--   1. database/01_LIVE_SYSTEM_SCHEMA.sql
--   2. database/05_HOSTING_INSTALL.sql          <- this file
--   3. database/02_LIVE_SYSTEM_SEED.sql
--   4. database/07_FULL_MENU_SEED.sql
--   5. database/website_sql/01_WEBSITE_INTEGRATION_SCHEMA.sql
-- ---------------------------------------------------------------------------
--
-- BEFORE RUNNING: many hosts prefix database and user names with your account
-- name, for example reagan_hotelpardise_system. If phpMyAdmin shows a prefix,
-- change every name in this file to match. The names must agree with
-- backend-php/config.php.
--
-- BEFORE RUNNING, PART TWO: replace both placeholder passwords below with the
-- real ones, using Find and Replace in phpMyAdmin or a text editor:
--
--   PASTE_THE_HOTEL_PASSWORD_HERE     the hotel user's password
--   PASTE_THE_WEBSITE_PASSWORD_HERE   the website user's password
--
-- They are left as placeholders on purpose. This file is in the repository, and
-- a real password written into a file that gets committed is a password that
-- has to be changed the moment the file is ever shared. Use the same two
-- passwords you put in backend-php/config.php.
--
-- A password containing a single quote must have it doubled, as in SQL. The two
-- passwords chosen for this hotel contain characters such as # ^ + ( , which are
-- all fine inside the quotes, but do not wrap the value in anything else.

CREATE DATABASE IF NOT EXISTS `hotelpardise_system`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `hotelpardise_website`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- The hotel user. Full rights on the hotel database, and read and write on the
-- website database so the public site can reach the settings it needs.
CREATE USER IF NOT EXISTS 'hotelpardise_system'@'localhost'
  IDENTIFIED BY 'PASTE_THE_HOTEL_PASSWORD_HERE';
CREATE USER IF NOT EXISTS 'hotelpardise_system'@'127.0.0.1'
  IDENTIFIED BY 'PASTE_THE_HOTEL_PASSWORD_HERE';

-- The website user is the account behind a public, unauthenticated endpoint, so
-- it is named table by table. It is never given rights over the whole hotel
-- database: a blanket grant there would also hand it the guest list, the
-- payments, and the staff table that holds password hashes.
CREATE USER IF NOT EXISTS 'hotelpardise_website'@'localhost'
  IDENTIFIED BY 'PASTE_THE_WEBSITE_PASSWORD_HERE';
CREATE USER IF NOT EXISTS 'hotelpardise_website'@'127.0.0.1'
  IDENTIFIED BY 'PASTE_THE_WEBSITE_PASSWORD_HERE';

GRANT ALL PRIVILEGES ON `hotelpardise_system`.*  TO 'hotelpardise_system'@'localhost';
GRANT ALL PRIVILEGES ON `hotelpardise_system`.*  TO 'hotelpardise_system'@'127.0.0.1';
GRANT ALL PRIVILEGES ON `hotelpardise_website`.* TO 'hotelpardise_system'@'localhost';
GRANT ALL PRIVILEGES ON `hotelpardise_website`.* TO 'hotelpardise_system'@'127.0.0.1';

-- The website's own tables: settings, copy, media.
GRANT SELECT, INSERT, UPDATE, DELETE ON `hotelpardise_website`.* TO 'hotelpardise_website'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `hotelpardise_website`.* TO 'hotelpardise_website'@'127.0.0.1';

-- What the public site has to read to answer a guest: the published menu and
-- the room types it offers. Nothing else in the hotel is readable.
GRANT SELECT ON `hotelpardise_system`.menu_categories TO 'hotelpardise_website'@'localhost';
GRANT SELECT ON `hotelpardise_system`.menu_items      TO 'hotelpardise_website'@'localhost';
GRANT SELECT ON `hotelpardise_system`.room_types      TO 'hotelpardise_website'@'localhost';
GRANT SELECT ON `hotelpardise_system`.menu_categories TO 'hotelpardise_website'@'127.0.0.1';
GRANT SELECT ON `hotelpardise_system`.menu_items      TO 'hotelpardise_website'@'127.0.0.1';
GRANT SELECT ON `hotelpardise_system`.room_types      TO 'hotelpardise_website'@'127.0.0.1';

-- The rows a guest creates when they order or book. Insert only: a guest may
-- add a takeaway order and a reservation, and may correct their own mistakes,
-- but may not read the day's takings, alter a price, or touch anyone else's
-- booking.
GRANT INSERT ON `hotelpardise_system`.orders           TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON `hotelpardise_system`.order_items      TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON `hotelpardise_system`.guests           TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON `hotelpardise_system`.reservations     TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON `hotelpardise_system`.reservation_rooms TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON `hotelpardise_system`.orders           TO 'hotelpardise_website'@'127.0.0.1';
GRANT INSERT ON `hotelpardise_system`.order_items      TO 'hotelpardise_website'@'127.0.0.1';
GRANT INSERT ON `hotelpardise_system`.guests           TO 'hotelpardise_website'@'127.0.0.1';
GRANT INSERT ON `hotelpardise_system`.reservations     TO 'hotelpardise_website'@'127.0.0.1';
GRANT INSERT ON `hotelpardise_system`.reservation_rooms TO 'hotelpardise_website'@'127.0.0.1';

-- The reservation and booking code reads a guest back to reuse them rather than
-- creating a second record for the same person, and reads the last booking
-- number to issue the next one. Two columns, and nothing else.
--
-- KNOW WHAT THIS COSTS YOU: a grant cannot be limited to rows matching a
-- WHERE clause, so this account can read the name and phone of every guest in
-- the hotel, not just the one it is booking for. The email address and every
-- other column stay closed. If you would rather the public account could not
-- read the guest list at all, delete the two GRANT lines below and change
-- api.php so a website booking always creates a new guest row; the cost there
-- is a separate guest record per booking, which the hotel system can merge.
GRANT SELECT (`id`, `phone`, `full_name`) ON `hotelpardise_system`.guests TO 'hotelpardise_website'@'localhost';
GRANT SELECT (`id`, `phone`, `full_name`) ON `hotelpardise_system`.guests TO 'hotelpardise_website'@'127.0.0.1';
GRANT SELECT (`booking_number`) ON `hotelpardise_system`.reservations TO 'hotelpardise_website'@'localhost';
GRANT SELECT (`booking_number`) ON `hotelpardise_system`.reservations TO 'hotelpardise_website'@'127.0.0.1';

-- No FLUSH PRIVILEGES is needed: CREATE USER and GRANT take effect at once.

-- Prove it worked. SHOW GRANTS reads the grant table directly, so it cannot be
-- confused by a stale table count. Read it back and check that:
--   hotelpardise_system  has everything on both databases
--   hotelpardise_website has the website, plus only the named hotel tables
-- and above all that it does NOT hold a blanket grant on the hotel database.
SHOW GRANTS FOR 'hotelpardise_system'@'localhost';
SHOW GRANTS FOR 'hotelpardise_website'@'localhost';
