-- Hotel Paradise on the Nile
-- Reagansoft Innovation Limited
-- Website integration schema.
-- The public website is currently static and should share the hotel system database.
-- This file contains only website-side integration metadata; it does not create
-- a competing second hotel database.
CREATE DATABASE IF NOT EXISTS hotel_paradise_nile;
USE hotel_paradise_nile;

CREATE TABLE IF NOT EXISTS website_settings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO website_settings (setting_key, setting_value)
VALUES
('site_name', 'Hotel Paradise on the Nile'),
('management_system_path', '/system/'),
('designed_by', 'Reagansoft Innovation Limited')
ON DUPLICATE KEY UPDATE setting_value = VALUES(setting_value);
