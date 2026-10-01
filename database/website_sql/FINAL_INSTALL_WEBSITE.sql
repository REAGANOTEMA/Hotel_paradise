-- HOTEL PARADISE ON THE NILE — WEBSITE DATABASE
CREATE DATABASE IF NOT EXISTS hotelpardise_website CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE hotelpardise_website;

CREATE TABLE IF NOT EXISTS website_settings (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 setting_key VARCHAR(120) NOT NULL UNIQUE,
 setting_value TEXT NULL,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS website_enquiries (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(190) NOT NULL,
 email VARCHAR(190) NULL,
 phone VARCHAR(60) NULL,
 subject VARCHAR(190) NULL,
 message TEXT NOT NULL,
 status ENUM('new','read','replied','closed') NOT NULL DEFAULT 'new',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 INDEX idx_enquiry_status(status),
 INDEX idx_enquiry_created(created_at)
);

CREATE TABLE IF NOT EXISTS website_booking_requests (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 guest_name VARCHAR(190) NOT NULL,
 email VARCHAR(190) NULL,
 phone VARCHAR(60) NULL,
 room_type VARCHAR(190) NULL,
 check_in DATE NULL,
 check_out DATE NULL,
 adults INT NOT NULL DEFAULT 1,
 children INT NOT NULL DEFAULT 0,
 status ENUM('new','processed','cancelled') NOT NULL DEFAULT 'new',
 system_reservation_id BIGINT UNSIGNED NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- The hotel's own details, written down once here so that the website, the
-- printed menu and the kitchen all quote the same address and the same two
-- telephone numbers. The web address is hotelparadiseonthenile.info: it is a
-- .info and must not be recorded anywhere as a .com.
INSERT INTO website_settings(setting_key,setting_value)
VALUES ('domain','https://hotelparadiseonthenile.info'),
       ('website','www.hotelparadiseonthenile.info'),
       ('hotel_name','Hotel Paradise on the Nile'),
       ('legal_name','Hotel Paradise on the Nile Ltd'),
       ('address','Plot 12, 19 & 25 Kiira Lane, Jinja, Uganda'),
       ('po_box','P.O. Box 1139, Jinja, Uganda'),
       ('phone_primary','+256 759 504 928'),
       ('phone_secondary','+256 773 565 668'),
       ('email','hotel@hotelparadiseonthenile.info'),
       ('certification','UNBS Certified (US 130:2017)'),
       ('designer','Reagansoft Innovation Limited'),
       ('system_path','/system/')
ON DUPLICATE KEY UPDATE setting_value=VALUES(setting_value);
