-- Hotel Paradise on the Nile — System Verification
-- Run after 04_SYSTEM_INSTALL_ALL.sql
USE hotel_paradise_nile;

SELECT 'hotels' AS table_name, COUNT(*) AS rows_count FROM hotels
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'roles', COUNT(*) FROM roles
UNION ALL SELECT 'departments', COUNT(*) FROM departments
UNION ALL SELECT 'rooms', COUNT(*) FROM rooms
UNION ALL SELECT 'reservations', COUNT(*) FROM reservations
UNION ALL SELECT 'menu_categories', COUNT(*) FROM menu_categories
UNION ALL SELECT 'menu_items', COUNT(*) FROM menu_items;
