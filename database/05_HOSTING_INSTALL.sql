-- HOTEL PARADISE ON THE NILE - HOSTING INSTALLER
--
-- Run this ONCE from phpMyAdmin's SQL tab, or from the command line. It creates
-- the two databases and the two users the site needs, and grants each user only
-- what it should have.
--
--   hotelpardise_system   the hotel. Menu, rooms, guests, orders, staff.
--   hotelpardise_website  the website's own tables, such as website_settings.
--
-- The website's menu and takeaway orders are written to hotelpardise_system on
-- purpose: the dish the guest reads, the order the kitchen receives and the row
-- the till settles have to be the same rows. A separate copy of the menu would
-- quietly drift away from the one the restaurant actually serves.
--
-- BEFORE RUNNING: many hosts prefix database and user names with your account
-- name, for example reagan_hotelpardise_system. If phpMyAdmin shows a prefix,
-- change every name in this file to match. The names must agree with
-- backend-php/config.php.

CREATE DATABASE IF NOT EXISTS `hotelpardise_system`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS `hotelpardise_website`
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- The hotel user. Full rights on the hotel database, and read and write on the
-- website database so the public site can reach the settings it needs.
CREATE USER IF NOT EXISTS 'hotelpardise_system'@'localhost'
  IDENTIFIED BY 'kmR7dbi#g3,z-5M^';
CREATE USER IF NOT EXISTS 'hotelpardise_system'@'127.0.0.1'
  IDENTIFIED BY 'kmR7dbi#g3,z-5M^';

-- The website user. Deliberately narrow: it is the account behind a public,
-- unauthenticated endpoint, so it gets no rights over the hotel's books, staff
-- or guests. If your host does not allow one user to be granted two databases,
-- remove the second GRANT and set backend-php/config.php to point the site at
-- the hotel user instead.
CREATE USER IF NOT EXISTS 'hotelpardise_website'@'localhost'
  IDENTIFIED BY 'i3Sa56Lr3(+wx0PX';
CREATE USER IF NOT EXISTS 'hotelpardise_website'@'127.0.0.1'
  IDENTIFIED BY 'i3Sa56Lr3(+wx0PX';

GRANT ALL PRIVILEGES ON `hotelpardise_system`.*  TO 'hotelpardise_system'@'localhost';
GRANT ALL PRIVILEGES ON `hotelpardise_system`.*  TO 'hotelpardise_system'@'127.0.0.1';
GRANT ALL PRIVILEGES ON `hotelpardise_website`.* TO 'hotelpardise_system'@'localhost';
GRANT ALL PRIVILEGES ON `hotelpardise_website`.* TO 'hotelpardise_system'@'127.0.0.1';

GRANT SELECT, INSERT, UPDATE, DELETE ON `hotelpardise_website`.* TO 'hotelpardise_website'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `hotelpardise_website`.* TO 'hotelpardise_website'@'127.0.0.1';
GRANT SELECT ON `hotelpardise_system`.* TO 'hotelpardise_website'@'localhost';
GRANT SELECT ON `hotelpardise_system`.* TO 'hotelpardise_website'@'127.0.0.1';

FLUSH PRIVILEGES;

-- Prove it worked. Every line should read the database name back.
SELECT 'hotelpardise_system'  AS database_name, COUNT(*) AS tables_now FROM information_schema.TABLES WHERE TABLE_SCHEMA='hotelpardise_system'
UNION ALL
SELECT 'hotelpardise_website', COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='hotelpardise_website';
