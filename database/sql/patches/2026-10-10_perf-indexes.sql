-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-10_perf-indexes.sql
-- Date: 2026-10-10
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- The console and the website API filter and sort by a handful of columns on
-- every page load. Without indexes those reads scan the whole table as records
-- accumulate. This patch adds the performance indexes the application expects.
--
-- This version uses MariaDB's ADD INDEX IF NOT EXISTS, so it needs no stored
-- procedure and never reads information_schema. That matters on shared hosting
-- where the database account is granted only its own database and cannot open
-- information_schema or create a routine. Run it more than once: an index that
-- already carries the name is left alone.
--
-- The purchase_requisitions index lives in the procurement patch, and the
-- payments.customer_id index lives in the customer accounts patch, because
-- those columns may not exist yet when this file is run on an old install.
-- =============================================================================

SET NAMES utf8mb4;

ALTER TABLE payments        ADD INDEX IF NOT EXISTS hp_perf_pay_order      (order_id);
ALTER TABLE payments        ADD INDEX IF NOT EXISTS hp_perf_pay_reservation (reservation_id);
ALTER TABLE payments        ADD INDEX IF NOT EXISTS hp_perf_pay_created    (created_at);

ALTER TABLE reservations    ADD INDEX IF NOT EXISTS hp_perf_res_status     (status);
ALTER TABLE reservations    ADD INDEX IF NOT EXISTS hp_perf_res_checkin    (check_in);
ALTER TABLE reservations    ADD INDEX IF NOT EXISTS hp_perf_res_checkout   (check_out);

ALTER TABLE orders          ADD INDEX IF NOT EXISTS hp_perf_ord_status     (status);
ALTER TABLE orders          ADD INDEX IF NOT EXISTS hp_perf_ord_outlet     (outlet);
ALTER TABLE orders          ADD INDEX IF NOT EXISTS hp_perf_ord_created    (created_at);

ALTER TABLE guests          ADD INDEX IF NOT EXISTS hp_perf_guest_email    (email);
ALTER TABLE guests          ADD INDEX IF NOT EXISTS hp_perf_guest_phone    (phone);

ALTER TABLE audit_logs      ADD INDEX IF NOT EXISTS hp_perf_audit_entity   (entity_type,entity_id);
ALTER TABLE audit_logs      ADD INDEX IF NOT EXISTS hp_perf_audit_created  (created_at);

ALTER TABLE expenses        ADD INDEX IF NOT EXISTS hp_perf_expense_status (status);
ALTER TABLE inventory_items ADD INDEX IF NOT EXISTS hp_perf_inventory_active (active);

-- Verification: run any of these by hand to see the indexes this patch owns.
-- SHOW INDEX FROM payments WHERE Key_name LIKE 'hp_perf_%';
-- SHOW INDEX FROM reservations WHERE Key_name LIKE 'hp_perf_%';
-- SHOW INDEX FROM orders WHERE Key_name LIKE 'hp_perf_%';
