-- News reactions and comments for the public newsroom.
-- Run once against the hotel database (hotelpardise_system).
-- Safe to run again: every statement only creates a table when it is absent.

CREATE TABLE IF NOT EXISTS `news_reactions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `news_id` BIGINT UNSIGNED NOT NULL,
  `reaction` VARCHAR(16) NOT NULL,
  `visitor_hash` CHAR(64) NOT NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_news_reaction` (`news_id`, `visitor_hash`),
  KEY `idx_news_reaction_news` (`news_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `news_comments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `news_id` BIGINT UNSIGNED NOT NULL,
  `parent_id` BIGINT UNSIGNED NULL,
  `name` VARCHAR(80) NOT NULL,
  `email` VARCHAR(160) NULL,
  `body` TEXT NOT NULL,
  `visitor_hash` CHAR(64) NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'published',
  `ip_hash` CHAR(64) NULL,
  `created_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_news_comments_news` (`news_id`, `status`, `created_at`),
  KEY `idx_news_comments_parent` (`parent_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
