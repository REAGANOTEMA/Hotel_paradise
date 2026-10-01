-- Hotel Paradise on the Nile
-- Reagansoft Innovation Limited
-- Website integration schema.
--
-- This file owns hotelpardise_website, the small database that belongs to the
-- public website alone.
--
-- The menu is the one deliberate exception. The dish a guest reads on the
-- website, the order the kitchen receives and the row the till settles all have
-- to be the same rows, so the menu and takeaway orders live in
-- hotelpardise_system with the rest of the hotel. Copying the menu into a
-- website-only database would leave the kitchen and the website quietly
-- disagreeing about what is on sale.
--
-- What lives here instead is the website's own material: settings, copy, media
-- and anything that has no meaning to the hotel system. It has no staff, no
-- guests, no rooms and no money in it, so it can be backed up, exported or
-- rebuilt without touching the hotel's books.
CREATE DATABASE IF NOT EXISTS hotelpardise_website
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hotelpardise_website;

CREATE TABLE IF NOT EXISTS website_settings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- The hotel's own details, written down once here so that the website, the
-- printed menu and the kitchen all quote the same address and the same two
-- telephone numbers. The web address is hotelparadiseonthenile.info: it is a
-- .info and must not be recorded anywhere as a .com.
INSERT INTO website_settings (setting_key, setting_value)
VALUES
('site_name', 'Hotel Paradise on the Nile'),
('legal_name', 'Hotel Paradise on the Nile Ltd'),
('address', 'Plot 12, 19 & 25 Kiira Lane, Jinja, Uganda'),
('po_box', 'P.O. Box 1139, Jinja, Uganda'),
('phone_primary', '+256 759 504 928'),
('phone_secondary', '+256 773 565 668'),
('email', 'hotel@hotelparadiseonthenile.info'),
('website', 'www.hotelparadiseonthenile.info'),
('certification', 'UNBS Certified (US 130:2017)'),
('management_system_path', '/system/'),
('designed_by', 'Reagansoft Innovation Limited')
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value);
