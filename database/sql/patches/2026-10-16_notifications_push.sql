-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-16_notifications_push.sql
-- Date: 2026-10-16
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- The console bell, the in-app list, per-member preferences and browser push
-- need five tables: notification_events, notification_deliveries, notifications,
-- notification_devices and notification_preferences. Without them the header
-- bell and the Notifications page report that the upgrade is not installed.
--
-- The tables are created only when missing and every index is added by name, so
-- this file is safe to run more than once. It uses MariaDB's IF NOT EXISTS
-- clauses and never reads information_schema.
-- =============================================================================

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS notification_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  event_key VARCHAR(190) NOT NULL,
  event_type VARCHAR(100) NOT NULL,
  entity_type VARCHAR(60) DEFAULT NULL,
  entity_id BIGINT UNSIGNED DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_event_key (event_key),
  KEY idx_event_entity (entity_type,entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notification_deliveries (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  notification_id BIGINT UNSIGNED DEFAULT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  device_id BIGINT UNSIGNED DEFAULT NULL,
  channel ENUM('web_push','fcm','apns','in_app') NOT NULL DEFAULT 'web_push',
  status ENUM('queued','accepted','delivered','failed','read') NOT NULL DEFAULT 'queued',
  provider_message_id VARCHAR(190) DEFAULT NULL,
  attempts INT UNSIGNED NOT NULL DEFAULT 0,
  last_error VARCHAR(500) DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_delivery_once (notification_id,device_id),
  KEY idx_delivery_user (user_id),
  KEY idx_delivery_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS notifications (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  type VARCHAR(100) NOT NULL,
  title VARCHAR(190) NOT NULL,
  body TEXT NOT NULL,
  data LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  read_at DATETIME DEFAULT NULL,
  created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY fk_notification_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE IF NOT EXISTS notification_devices (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  platform ENUM('web','android','ios','other') NOT NULL,
  push_token VARCHAR(500) NOT NULL,
  p256dh VARCHAR(255) DEFAULT NULL,
  auth VARCHAR(255) DEFAULT NULL,
  active TINYINT(1) DEFAULT 1,
  user_agent VARCHAR(255) DEFAULT NULL,
  last_seen_at DATETIME DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_push_token (push_token(191)),
  KEY fk_nd_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

CREATE TABLE IF NOT EXISTS notification_preferences (
  user_id BIGINT UNSIGNED NOT NULL,
  booking_alerts TINYINT(1) NOT NULL DEFAULT 1,
  order_alerts TINYINT(1) NOT NULL DEFAULT 1,
  payment_alerts TINYINT(1) NOT NULL DEFAULT 1,
  communication_alerts TINYINT(1) NOT NULL DEFAULT 1,
  incident_alerts TINYINT(1) NOT NULL DEFAULT 1,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE notification_deliveries ADD UNIQUE KEY IF NOT EXISTS uq_delivery_once (notification_id,device_id);
ALTER TABLE notification_deliveries ADD INDEX IF NOT EXISTS idx_delivery_user (user_id);
ALTER TABLE notification_deliveries ADD INDEX IF NOT EXISTS idx_delivery_status (status);
ALTER TABLE notifications ADD INDEX IF NOT EXISTS fk_notification_user (user_id);
ALTER TABLE notification_devices ADD UNIQUE KEY IF NOT EXISTS uq_push_token (push_token(191));
ALTER TABLE notification_devices ADD INDEX IF NOT EXISTS fk_nd_user (user_id);

-- Verification: all five tables should answer, and the bell is ready when
-- notify_ready() sees each of them.
SELECT COUNT(*) AS notification_events FROM notification_events;
SELECT COUNT(*) AS notification_deliveries FROM notification_deliveries;
SELECT COUNT(*) AS notifications FROM notifications;
SELECT COUNT(*) AS notification_devices FROM notification_devices;
SELECT COUNT(*) AS notification_preferences FROM notification_preferences;
