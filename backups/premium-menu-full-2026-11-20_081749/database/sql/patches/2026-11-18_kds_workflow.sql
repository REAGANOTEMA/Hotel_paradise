DROP PROCEDURE IF EXISTS hp_kds_patch;
DELIMITER //
CREATE PROCEDURE hp_kds_patch()
BEGIN
 DECLARE c INT DEFAULT 0;

 CREATE TABLE IF NOT EXISTS kitchen_stations(
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  property_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(20) NOT NULL,
  name VARCHAR(120) NOT NULL,
  color VARCHAR(20) NOT NULL DEFAULT '#0B5D78',
  printer_key VARCHAR(80) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY(id), UNIQUE KEY uniq_kds_station_code(hotel_id,code)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

 CREATE TABLE IF NOT EXISTS kitchen_order_items(
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_item_id BIGINT UNSIGNED NOT NULL,
  station_id BIGINT UNSIGNED NULL,
  status ENUM('queued','accepted','preparing','ready','served','cancelled') NOT NULL DEFAULT 'queued',
  course VARCHAR(40) NULL,
  priority ENUM('normal','rush','vip') NOT NULL DEFAULT 'normal',
  note VARCHAR(500) NULL,
  accepted_at DATETIME NULL,
  started_at DATETIME NULL,
  ready_at DATETIME NULL,
  served_at DATETIME NULL,
  served_by BIGINT UNSIGNED NULL,
  started_by BIGINT UNSIGNED NULL,
  ready_by BIGINT UNSIGNED NULL,
  recall_count INT NOT NULL DEFAULT 0,
  fire_at DATETIME NULL,
  created_at DATETIME NULL,
  updated_at DATETIME NULL,
  PRIMARY KEY(id), UNIQUE KEY uniq_kds_item(order_item_id), KEY idx_kds_status(status), KEY idx_kds_station(station_id)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

 CREATE TABLE IF NOT EXISTS kds_print_queue(
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
  ticket_key VARCHAR(120) NOT NULL,
  kind VARCHAR(40) NOT NULL,
  order_id BIGINT UNSIGNED NULL,
  station_id BIGINT UNSIGNED NULL,
  target VARCHAR(120) NULL,
  payload LONGTEXT NULL,
  status ENUM('queued','printed','failed') NOT NULL DEFAULT 'queued',
  attempts INT NOT NULL DEFAULT 0,
  last_error VARCHAR(500) NULL,
  created_at DATETIME NULL,
  printed_at DATETIME NULL,
  PRIMARY KEY(id), UNIQUE KEY uniq_kds_ticket(hotel_id,ticket_key), KEY idx_kds_print_status(status)
 ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_stations' AND COLUMN_NAME='hotel_id';
 IF c=0 THEN ALTER TABLE kitchen_stations ADD COLUMN hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_stations' AND COLUMN_NAME='code';
 IF c=0 THEN ALTER TABLE kitchen_stations ADD COLUMN code VARCHAR(20) NOT NULL DEFAULT 'HOT'; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_stations' AND COLUMN_NAME='color';
 IF c=0 THEN ALTER TABLE kitchen_stations ADD COLUMN color VARCHAR(20) NOT NULL DEFAULT '#0B5D78'; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_stations' AND COLUMN_NAME='printer_key';
 IF c=0 THEN ALTER TABLE kitchen_stations ADD COLUMN printer_key VARCHAR(80) NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_stations' AND COLUMN_NAME='sort_order';
 IF c=0 THEN ALTER TABLE kitchen_stations ADD COLUMN sort_order INT NOT NULL DEFAULT 0; END IF;

 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='course';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN course VARCHAR(40) NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='priority';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN priority ENUM('normal','rush','vip') NOT NULL DEFAULT 'normal'; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='note';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN note VARCHAR(500) NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='accepted_at';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN accepted_at DATETIME NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='started_at';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN started_at DATETIME NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='ready_at';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN ready_at DATETIME NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='served_at';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN served_at DATETIME NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='served_by';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN served_by BIGINT UNSIGNED NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='started_by';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN started_by BIGINT UNSIGNED NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='ready_by';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN ready_by BIGINT UNSIGNED NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='recall_count';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN recall_count INT NOT NULL DEFAULT 0; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='fire_at';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN fire_at DATETIME NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='created_at';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN created_at DATETIME NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='kitchen_order_items' AND COLUMN_NAME='updated_at';
 IF c=0 THEN ALTER TABLE kitchen_order_items ADD COLUMN updated_at DATETIME NULL; END IF;

 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='orders' AND COLUMN_NAME='kds_runner';
 IF c=0 THEN ALTER TABLE orders ADD COLUMN kds_runner VARCHAR(80) NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='orders' AND COLUMN_NAME='kds_eta';
 IF c=0 THEN ALTER TABLE orders ADD COLUMN kds_eta DATETIME NULL; END IF;
 SELECT COUNT(*) INTO c FROM information_schema.COLUMNS WHERE TABLE_SCHEMA=DATABASE() AND TABLE_NAME='orders' AND COLUMN_NAME='kds_dispatched_at';
 IF c=0 THEN ALTER TABLE orders ADD COLUMN kds_dispatched_at DATETIME NULL; END IF;

 UPDATE kitchen_stations SET hotel_id=1 WHERE hotel_id IS NULL OR hotel_id=0;

 INSERT INTO kitchen_stations(property_id,hotel_id,code,name,color,sort_order,active)
 SELECT 1,1,'HOT','Hot Kitchen','#c62828',0,1 WHERE NOT EXISTS(SELECT 1 FROM kitchen_stations WHERE code='HOT');
 INSERT INTO kitchen_stations(property_id,hotel_id,code,name,color,sort_order,active)
 SELECT 1,1,'COLD','Cold Kitchen','#0B5D78',1,1 WHERE NOT EXISTS(SELECT 1 FROM kitchen_stations WHERE code='COLD');
 INSERT INTO kitchen_stations(property_id,hotel_id,code,name,color,sort_order,active)
 SELECT 1,1,'BAR','Bar & Drinks','#7b1fa2',2,1 WHERE NOT EXISTS(SELECT 1 FROM kitchen_stations WHERE code='BAR');
 INSERT INTO kitchen_stations(property_id,hotel_id,code,name,color,sort_order,active)
 SELECT 1,1,'PASTRY','Pastry & Desserts','#b26a00',3,1 WHERE NOT EXISTS(SELECT 1 FROM kitchen_stations WHERE code='PASTRY');
 INSERT INTO kitchen_stations(property_id,hotel_id,code,name,color,sort_order,active)
 SELECT 1,1,'ROOM','Room Service','#2e7d32',4,1 WHERE NOT EXISTS(SELECT 1 FROM kitchen_stations WHERE code='ROOM');
END//
DELIMITER ;

CALL hp_kds_patch();
DROP PROCEDURE IF EXISTS hp_kds_patch;
