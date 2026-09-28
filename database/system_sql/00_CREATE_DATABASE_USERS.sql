-- HOTEL PARADISE ON THE NILE — LOCAL MYSQL USERS
-- Run as a MySQL/phpMyAdmin account with CREATE USER/GRANT privileges.
CREATE DATABASE IF NOT EXISTS hotelpardise_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS hotelpardise_website CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'hotelpardise_system'@'localhost' IDENTIFIED BY 'vw^@u89U8]+F})1]';
ALTER USER 'hotelpardise_system'@'localhost' IDENTIFIED BY 'vw^@u89U8]+F})1]';
GRANT ALL PRIVILEGES ON hotelpardise_system.* TO 'hotelpardise_system'@'localhost';

CREATE USER IF NOT EXISTS 'hotelpardise_website'@'localhost' IDENTIFIED BY ';p_NcJ9D^,anKHyo';
ALTER USER 'hotelpardise_website'@'localhost' IDENTIFIED BY ';p_NcJ9D^,anKHyo';
GRANT ALL PRIVILEGES ON hotelpardise_website.* TO 'hotelpardise_website'@'localhost';

FLUSH PRIVILEGES;
