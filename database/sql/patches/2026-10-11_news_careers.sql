-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-11_news_careers.sql
-- Date: 2026-10-11
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- News & Careers is the newsroom the console writes and the website API reads.
-- It needs the news_posts table and its indexes, the human_resource role so the
-- HR desk can publish vacancies and the employee of the month, and a few opening
-- posts so a fresh website newsroom is never blank.
--
-- Seeds use INSERT IGNORE so an edited post is never overwritten. Safe to run
-- more than once.
-- =============================================================================

SET NAMES utf8mb4;

CREATE TABLE IF NOT EXISTS news_posts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  slug VARCHAR(180) NOT NULL,
  title VARCHAR(200) NOT NULL,
  category VARCHAR(20) NOT NULL DEFAULT 'news',
  excerpt VARCHAR(320) NOT NULL DEFAULT '',
  body MEDIUMTEXT DEFAULT NULL,
  image VARCHAR(255) DEFAULT NULL,
  department VARCHAR(120) DEFAULT NULL,
  location VARCHAR(120) DEFAULT NULL,
  employment_type VARCHAR(60) DEFAULT NULL,
  salary VARCHAR(120) DEFAULT NULL,
  deadline DATE DEFAULT NULL,
  apply_email VARCHAR(160) DEFAULT NULL,
  apply_url VARCHAR(300) DEFAULT NULL,
  author_name VARCHAR(120) DEFAULT NULL,
  author_role VARCHAR(120) DEFAULT NULL,
  created_by BIGINT UNSIGNED DEFAULT NULL,
  pinned TINYINT(1) NOT NULL DEFAULT 0,
  status VARCHAR(20) NOT NULL DEFAULT 'published',
  publish_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  views INT UNSIGNED NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT NULL,
  deleted_at TIMESTAMP NULL DEFAULT NULL,
  deleted_by BIGINT UNSIGNED DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_news_slug (slug),
  KEY idx_news_cat (category),
  KEY idx_news_status (status, publish_at),
  KEY idx_news_pinned (pinned, publish_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- A partial copy from an early install may have the table without the later
-- columns. Add only what is missing so the seeds below can run.
ALTER TABLE news_posts
  ADD COLUMN IF NOT EXISTS hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS slug VARCHAR(180) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS title VARCHAR(200) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS category VARCHAR(20) NOT NULL DEFAULT 'news',
  ADD COLUMN IF NOT EXISTS excerpt VARCHAR(320) NOT NULL DEFAULT '',
  ADD COLUMN IF NOT EXISTS body MEDIUMTEXT DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS image VARCHAR(255) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS department VARCHAR(120) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS location VARCHAR(120) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS employment_type VARCHAR(60) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS salary VARCHAR(120) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deadline DATE DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS apply_email VARCHAR(160) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS apply_url VARCHAR(300) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS author_name VARCHAR(120) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS author_role VARCHAR(120) DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS created_by BIGINT UNSIGNED DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS pinned TINYINT(1) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'published',
  ADD COLUMN IF NOT EXISTS publish_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS views INT UNSIGNED NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ADD COLUMN IF NOT EXISTS updated_at DATETIME DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMP NULL DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS deleted_by BIGINT UNSIGNED DEFAULT NULL;

ALTER TABLE news_posts ADD UNIQUE KEY IF NOT EXISTS uq_news_slug (slug);
ALTER TABLE news_posts ADD INDEX IF NOT EXISTS idx_news_cat (category);
ALTER TABLE news_posts ADD INDEX IF NOT EXISTS idx_news_status (status,publish_at);
ALTER TABLE news_posts ADD INDEX IF NOT EXISTS idx_news_pinned (pinned,publish_at);

-- The HR role is part of the newsroom's owner tier. Its name is the key the
-- application uses; the id is left to the server when the row is new.
INSERT INTO roles (name)
SELECT 'human_resource'
WHERE NOT EXISTS (SELECT 1 FROM roles WHERE name='human_resource');

-- Opening posts. Slugs are unique, so a repeat run changes nothing.
INSERT IGNORE INTO news_posts
  (hotel_id, slug, title, category, excerpt, body, department, author_name, author_role,
   status, publish_at, created_at)
VALUES
  (1, 'welcome-to-the-paradise-newsroom', 'Welcome to the Paradise newsroom', 'news',
   'Stories, service updates and opportunities from Hotel Paradise on the Nile.',
   'Welcome to our newsroom. This is where the hotel shares what is happening on the Nile: new services, team news, seasonal offers and the people who make a stay at Paradise memorable.\n\nCheck back for updates, or follow the links on the website to plan your next visit.',
   'Management', 'Hotel Paradise on the Nile', 'Management', 'published', NOW(), NOW()),
  (1, 'join-the-paradise-team', 'Join the Paradise team', 'recruitment',
   'We are always looking for warm, careful people to join the hotel.',
   'Hotel Paradise on the Nile is built on people who care about the small details. We welcome applications from experienced hospitality professionals and from people starting their first role in the industry.\n\nSend your application to the front desk or use the contact details on the website. Please tell us the role you are interested in and a little about yourself.',
   'Human Resource', 'Hotel Paradise on the Nile', 'Human Resource', 'published', NOW(), NOW()),
  (1, 'employee-of-the-month', 'Employee of the month', 'employee',
   'Celebrating the member of the team who went the extra mile.',
   'Every month the hotel recognises a member of the team whose care, craft and kindness stood out. Their name is shared here and at the staff briefing.\n\nCongratulations to this month''s winner, and thank you to everyone who makes Paradise feel like home.',
   'Human Resource', 'Hotel Paradise on the Nile', 'Human Resource', 'published', NOW(), NOW());

-- Verification: the table and role exist, and the opening posts are present.
SELECT COUNT(*) AS news_posts FROM news_posts;
SELECT name AS human_resource_role FROM roles WHERE name='human_resource';
SELECT slug, title, category, status FROM news_posts ORDER BY id;
