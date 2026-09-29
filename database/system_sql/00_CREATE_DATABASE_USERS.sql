-- ###########################################################################
-- #  READ THIS FIRST. YOU PROBABLY DO NOT NEED TO RUN THIS FILE.            #
-- ###########################################################################
--
-- On XAMPP, the installer has already done everything below. Both accounts
-- exist, both databases exist, and every grant in this file is already set.
-- Check that in one command, from the project folder, and stop there:
--
--     C:\xampp\php\php.exe tools\install-databases.php --check
--
-- It changes nothing and prints one line. If it says the site is installed
-- correctly, you are done, and pasting the SQL below is at best pointless.
--
-- IF YOU GET "#1227 Access denied; you need (at least one of) the CREATE USER
-- privilege(s)", the problem is not the hotel and not this file. It is the
-- account phpMyAdmin is logged in as. That account may have rights on a
-- database, which is not the right to create a user; only root has that on
-- XAMPP. Click "Log out" at the top of phpMyAdmin, log back in as root with an
-- empty password, and only then decide you actually need the SQL below.
--
-- IF YOU DO RUN IT, REPLACE BOTH PLACEHOLDERS FIRST. Left as they are, the
-- ALTER USER lines set the two passwords to the literal text
-- "PASTE_THE_SYSTEM_PASSWORD_HERE" and "PASTE_THE_WEBSITE_PASSWORD_HERE". The
-- site then cannot reach either database and every page returns a 503, and the
-- fix is to put the real values from backend-php/config.php back.
--
-- ###########################################################################
--
-- HOTEL PARADISE ON THE NILE - MYSQL DATABASES AND USERS
-- Reagansoft Innovation Limited
--
-- This file used to carry the two live MySQL passwords in plain text, in a
-- script that was committed to the repository. That is the one mistake in the
-- install that cannot be undone by editing the file afterwards: the passwords
-- are in the git history, so anyone who can read the repository can read them,
-- and they are the passwords the site's own config.php still uses.
--
-- The passwords are not written down here any more. They are not written down
-- anywhere outside backend-php/config.php, which is generated per machine and
-- is in .gitignore, and the installer below reads them from there. That is what
-- stops the two copies drifting apart, which is how a site ends up with an
-- account whose password is not the one its config file expects.
--
-- ---------------------------------------------------------------------------
-- THE NORMAL WAY
-- ---------------------------------------------------------------------------
--
--   php tools/install-databases.php
--
-- It creates both databases, both accounts at both host names, the grants, and
-- loads the schema, the seed and the published menu, in the one order that
-- works. It is safe to run again and it prints nothing secret.
--
-- It needs a MySQL account that may CREATE DATABASE, CREATE USER and GRANT. On
-- XAMPP that is root with an empty password. Where that is not available, give
-- it one through the environment rather than on the command line, so the
-- password does not end up in the shell history or in the process list:
--
--   HP_ADMIN_USER=root HP_ADMIN_PASS=... php tools/install-databases.php
--
-- ---------------------------------------------------------------------------
-- ONLY IF YOU MUST DO IT BY HAND, in phpMyAdmin
-- ---------------------------------------------------------------------------
--
-- Replace the two placeholders below with the values from
-- backend-php/config.php, then run it as one block. Keep the order: the grants
-- that name a table in hotelpardise_system cannot be granted before the schema
-- has created that table, which is why a hand-run that skips
-- database/01_LIVE_SYSTEM_SCHEMA.sql fails later and somewhere else.
--
-- If the passwords here are ever typed into a repository, a chat message or a
-- ticket, treat them as disclosed: change them with ALTER USER on both
-- '@localhost' and '@127.0.0.1', and change the matching value in config.php
-- in the same sitting.

CREATE DATABASE IF NOT EXISTS hotelpardise_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS hotelpardise_website CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- The management system owns its own database outright: every module reads and
-- writes it, and the audit trail is written on page loads as well as on changes.
-- An account is created for localhost and for 127.0.0.1 because MariaDB picks
-- which one matches from the address in the connection, and the site's DSN names
-- 127.0.0.1 explicitly.
CREATE USER IF NOT EXISTS 'hotelpardise_system'@'localhost' IDENTIFIED BY 'PASTE_THE_SYSTEM_PASSWORD_HERE';
ALTER USER 'hotelpardise_system'@'localhost' IDENTIFIED BY 'PASTE_THE_SYSTEM_PASSWORD_HERE';
CREATE USER IF NOT EXISTS 'hotelpardise_system'@'127.0.0.1' IDENTIFIED BY 'PASTE_THE_SYSTEM_PASSWORD_HERE';
ALTER USER 'hotelpardise_system'@'127.0.0.1' IDENTIFIED BY 'PASTE_THE_SYSTEM_PASSWORD_HERE';
GRANT ALL PRIVILEGES ON hotelpardise_system.* TO 'hotelpardise_system'@'localhost';
GRANT ALL PRIVILEGES ON hotelpardise_system.* TO 'hotelpardise_system'@'127.0.0.1';

-- The public website's account. It reads the published menu and the rooms a
-- guest may book, and it may take a booking or a takeaway order. It is not given
-- the hotel database: it cannot read a guest's passport number, an invoice or a
-- payment, so a compromise of the public site does not become a compromise of
-- the hotel's books. The guest and reservation columns are named one by one for
-- the same reason.
CREATE USER IF NOT EXISTS 'hotelpardise_website'@'localhost' IDENTIFIED BY 'PASTE_THE_WEBSITE_PASSWORD_HERE';
ALTER USER 'hotelpardise_website'@'localhost' IDENTIFIED BY 'PASTE_THE_WEBSITE_PASSWORD_HERE';
CREATE USER IF NOT EXISTS 'hotelpardise_website'@'127.0.0.1' IDENTIFIED BY 'PASTE_THE_WEBSITE_PASSWORD_HERE';
ALTER USER 'hotelpardise_website'@'127.0.0.1' IDENTIFIED BY 'PASTE_THE_WEBSITE_PASSWORD_HERE';
GRANT SELECT, INSERT, UPDATE, DELETE ON hotelpardise_website.* TO 'hotelpardise_website'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON hotelpardise_website.* TO 'hotelpardise_website'@'127.0.0.1';

-- Run this half again, after database/01_LIVE_SYSTEM_SCHEMA.sql.
GRANT SELECT ON hotelpardise_system.hotels          TO 'hotelpardise_website'@'localhost';
GRANT SELECT ON hotelpardise_system.room_types      TO 'hotelpardise_website'@'localhost';
GRANT SELECT ON hotelpardise_system.rooms           TO 'hotelpardise_website'@'localhost';
GRANT SELECT ON hotelpardise_system.menu_categories TO 'hotelpardise_website'@'localhost';
GRANT SELECT ON hotelpardise_system.menu_items     TO 'hotelpardise_website'@'localhost';
GRANT SELECT (id, phone, full_name)  ON hotelpardise_system.guests      TO 'hotelpardise_website'@'localhost';
GRANT SELECT (booking_number)        ON hotelpardise_system.reservations TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON hotelpardise_system.guests            TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON hotelpardise_system.reservations      TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON hotelpardise_system.reservation_rooms TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON hotelpardise_system.orders            TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON hotelpardise_system.order_items       TO 'hotelpardise_website'@'localhost';

GRANT SELECT ON hotelpardise_system.hotels          TO 'hotelpardise_website'@'127.0.0.1';
GRANT SELECT ON hotelpardise_system.room_types      TO 'hotelpardise_website'@'127.0.0.1';
GRANT SELECT ON hotelpardise_system.rooms           TO 'hotelpardise_website'@'127.0.0.1';
GRANT SELECT ON hotelpardise_system.menu_categories TO 'hotelpardise_website'@'127.0.0.1';
GRANT SELECT ON hotelpardise_system.menu_items     TO 'hotelpardise_website'@'127.0.0.1';
GRANT SELECT (id, phone, full_name)  ON hotelpardise_system.guests      TO 'hotelpardise_website'@'127.0.0.1';
GRANT SELECT (booking_number)        ON hotelpardise_system.reservations TO 'hotelpardise_website'@'127.0.0.1';
GRANT INSERT ON hotelpardise_system.guests            TO 'hotelpardise_website'@'127.0.0.1';
GRANT INSERT ON hotelpardise_system.reservations      TO 'hotelpardise_website'@'127.0.0.1';
GRANT INSERT ON hotelpardise_system.reservation_rooms TO 'hotelpardise_website'@'127.0.0.1';
GRANT INSERT ON hotelpardise_system.orders            TO 'hotelpardise_website'@'127.0.0.1';
GRANT INSERT ON hotelpardise_system.order_items       TO 'hotelpardise_website'@'127.0.0.1';

FLUSH PRIVILEGES;
