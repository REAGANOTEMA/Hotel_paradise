USE hotel_paradise_nile;

INSERT INTO hotel_groups (name) SELECT 'Hotel Paradise on the Nile Group' WHERE NOT EXISTS (SELECT 1 FROM hotel_groups WHERE name='Hotel Paradise on the Nile Group');
INSERT INTO properties (hotel_group_id,name,city,country,currency,timezone) SELECT id,'Hotel Paradise on the Nile','Jinja','Uganda','UGX','Africa/Kampala' FROM hotel_groups WHERE name='Hotel Paradise on the Nile Group' AND NOT EXISTS (SELECT 1 FROM properties WHERE name='Hotel Paradise on the Nile');

-- Department catalogue (application can map these to role IDs in the installed schema).
CREATE TABLE IF NOT EXISTS system_departments (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, code VARCHAR(60) UNIQUE NOT NULL, name VARCHAR(120) NOT NULL, active BOOLEAN DEFAULT TRUE);
INSERT IGNORE INTO system_departments(code,name) VALUES
('OWNERS','Owners'),('DIRECTORS','Directors'),('RECEPTION','Reception'),('RESERVATIONS','Reservations'),('HOUSEKEEPING','Housekeeping'),('RESTAURANT','Restaurant'),('KITCHEN','Kitchen'),('BAR','Bar'),('ROOM_SERVICE','Room Service'),('POOL','Swimming Pool'),('SPA','Spa'),('LAUNDRY','Laundry'),('STORE','Store'),('INVENTORY','Inventory'),('PROCUREMENT','Procurement'),('MAINTENANCE','Maintenance'),('EVENTS','Events & Conference'),('TRANSPORT','Transport'),('FINANCE','Finance'),('CASHIER','Cashier'),('ACCOUNTING','Accounting'),('AUDITOR','Auditor'),('HR','Human Resources'),('POS','Point of Sale'),('IT','IT / System Administration');
