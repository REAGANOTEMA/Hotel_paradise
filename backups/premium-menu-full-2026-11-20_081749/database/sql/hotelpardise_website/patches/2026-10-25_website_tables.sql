-- =============================================================================
-- Hotel Paradise on the Nile - website database patch
-- File: database/sql/hotelpardise_website/patches/2026-10-25_website_tables.sql
-- Date: 2026-10-25
-- Target: hotelpardise_website
--
-- WHY THIS EXISTS
-- The management system's health check opens the website database. Its three
-- tables (website_settings, website_booking_requests and website_enquiries) must
-- exist even when the public site is served as static pages. The settings also
-- carry the contact details a page reads.
--
-- The patch creates only missing tables and seeds only missing settings, so a
-- value the hotel has edited is never overwritten. Safe to run more than once.
-- =============================================================================

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS website_settings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  setting_key VARCHAR(100) NOT NULL,
  setting_value TEXT DEFAULT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY setting_key (setting_key)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE IF NOT EXISTS website_booking_requests (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  guest_name VARCHAR(190) NOT NULL,
  email VARCHAR(190) DEFAULT NULL,
  phone VARCHAR(60) DEFAULT NULL,
  room_type VARCHAR(190) DEFAULT NULL,
  check_in DATE DEFAULT NULL,
  check_out DATE DEFAULT NULL,
  adults INT NOT NULL DEFAULT 1,
  children INT NOT NULL DEFAULT 0,
  status ENUM('new','processed','cancelled') NOT NULL DEFAULT 'new',
  system_reservation_id BIGINT UNSIGNED DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE IF NOT EXISTS website_enquiries (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(190) NOT NULL,
  email VARCHAR(190) DEFAULT NULL,
  phone VARCHAR(60) DEFAULT NULL,
  subject VARCHAR(190) DEFAULT NULL,
  message TEXT NOT NULL,
  status ENUM('new','read','replied','closed') NOT NULL DEFAULT 'new',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_enquiry_status (status),
  KEY idx_enquiry_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- Contact details. INSERT IGNORE means a setting the hotel has already edited
-- stays exactly as it is.
INSERT IGNORE INTO website_settings (setting_key, setting_value) VALUES
  ('site_name','Hotel Paradise on the Nile'),
  ('legal_name','Hotel Paradise on the Nile Ltd'),
  ('hotel_name','Hotel Paradise on the Nile'),
  ('address','Plot 12, 19 & 25 Kiira Lane, Jinja, Uganda'),
  ('po_box','P.O. Box 1139, Jinja, Uganda'),
  ('phone_primary','+256 759 504 928'),
  ('phone_secondary','+256 773 565 668'),
  ('email','frontdesk@hotelparadiseonthenile.info'),
  ('website','www.hotelparadiseonthenile.info'),
  ('domain','https://hotelparadiseonthenile.info'),
  ('certification','UNBS Certified (US 130:2017)'),
  ('management_system_path','/system/'),
  ('system_path','/system/'),
  ('designed_by','Reagansoft Innovation Limited'),
  ('designer','Reagansoft Innovation Limited');

-- Verification: three tables and the seeded settings. SHOW TABLES reads the
-- current database only, so it works for an account that cannot open
-- information_schema.
SHOW TABLES LIKE 'website_settings';
SHOW TABLES LIKE 'website_booking_requests';
SHOW TABLES LIKE 'website_enquiries';

SELECT setting_key, setting_value FROM website_settings ORDER BY setting_key;
