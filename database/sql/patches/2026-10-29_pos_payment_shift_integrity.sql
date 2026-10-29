-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-29_pos_payment_shift_integrity.sql
-- Date: 2026-10-29
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- The POS and F&B screens now settle an order as one transaction: the payment
-- row, the order total and the order status move together. This patch adds the
-- database pieces that make that work cleanly, and gives management readable
-- views for order balances, daily sales, payment mix, shift cash-up and data
-- integrity checks.
--
-- It is safe to run more than once. It uses MariaDB 10.4's IF NOT EXISTS
-- clauses, so it needs no stored procedure and never reads information_schema.
-- It does NOT edit the clean baseline dump or any earlier patch.
--
-- WHAT IT CHANGES
--   1. Adds payments.shift_id, so a payment belongs to the shift that took it.
--   2. Backfills shift_id on existing order payments from orders.shift_id.
--   3. Adds the indexes the POS, F&B, shift and reporting screens use.
--   4. Creates reporting views with the hp_ prefix.
--
-- HOW TO RUN
--   C:\xampp\mysql\bin\mysql.exe -u <user> -p hotelpardise_system < 2026-10-29_pos_payment_shift_integrity.sql
-- or phpMyAdmin: system database -> Import -> choose this file -> Go.
--
-- IMPORTANT
-- This patch does not change old order totals, old payments or old shift
-- expected-cash figures. It only links existing order payments to the shift
-- already recorded on their order, and adds read-only views for checking the
-- books.
-- =============================================================================

SET NAMES utf8mb4;

-- -----------------------------------------------------------------------------
-- 1. A payment can belong to the shift that received it.
-- -----------------------------------------------------------------------------
ALTER TABLE payments
  ADD COLUMN IF NOT EXISTS shift_id BIGINT UNSIGNED DEFAULT NULL AFTER order_id;

-- -----------------------------------------------------------------------------
-- 2. Link historical order payments to the shift recorded on the order.
--    Runs once for rows with no link and is harmless on a second run.
-- -----------------------------------------------------------------------------
UPDATE payments p
JOIN orders o ON o.id = p.order_id
SET p.shift_id = o.shift_id
WHERE p.shift_id IS NULL
  AND o.shift_id IS NOT NULL;

-- -----------------------------------------------------------------------------
-- 3. Indexes for the live POS, F&B, shift and reporting queries.
-- -----------------------------------------------------------------------------
ALTER TABLE payments      ADD INDEX IF NOT EXISTS hp_pos_pay_order_status (order_id, status);
ALTER TABLE payments      ADD INDEX IF NOT EXISTS hp_pos_pay_shift_cash   (shift_id, status, method, created_at);
ALTER TABLE payments      ADD INDEX IF NOT EXISTS hp_pos_pay_user_cash    (user_id, status, method, created_at);
ALTER TABLE payments      ADD INDEX IF NOT EXISTS hp_pos_pay_method_day   (status, method, created_at);

ALTER TABLE orders        ADD INDEX IF NOT EXISTS hp_pos_ord_shift_status (shift_id, status);
ALTER TABLE orders        ADD INDEX IF NOT EXISTS hp_pos_ord_day_outlet   (created_at, outlet, status);
ALTER TABLE orders        ADD INDEX IF NOT EXISTS hp_pos_ord_customer_phone (customer_phone);
ALTER TABLE orders        ADD INDEX IF NOT EXISTS hp_pos_ord_room_status  (room_id, status, created_at);

ALTER TABLE shifts        ADD INDEX IF NOT EXISTS hp_pos_shift_user_status (user_id, status, opened_at);
ALTER TABLE shifts        ADD INDEX IF NOT EXISTS hp_pos_shift_opened      (opened_at);

ALTER TABLE dining_tables ADD INDEX IF NOT EXISTS hp_pos_table_outlet_status (outlet_id, status);

ALTER TABLE voids         ADD INDEX IF NOT EXISTS hp_pos_void_ref         (ref_type, ref_id, created_at);

-- -----------------------------------------------------------------------------
-- 4. Read-only reporting views.
-- -----------------------------------------------------------------------------

-- One row per order with the money actually received and the balance.
CREATE OR REPLACE SQL SECURITY INVOKER VIEW hp_pos_order_balances AS
SELECT
  o.id,
  o.order_number,
  o.outlet,
  o.order_type,
  o.table_name,
  o.status,
  o.created_at,
  o.subtotal,
  o.tax,
  o.discount,
  o.total,
  COALESCE(p.paid, 0.00) AS paid,
  ROUND(GREATEST(o.total - COALESCE(p.paid, 0.00), 0.00), 2) AS due,
  CASE
    WHEN o.status = 'cancelled' THEN 'cancelled'
    WHEN COALESCE(p.paid, 0.00) <= 0.001 THEN 'unpaid'
    WHEN COALESCE(p.paid, 0.00) + 0.001 >= o.total THEN 'paid'
    ELSE 'partially_paid'
  END AS payment_state
FROM orders o
LEFT JOIN (
  SELECT order_id, SUM(amount) AS paid
  FROM payments
  WHERE status = 'successful' AND order_id IS NOT NULL
  GROUP BY order_id
) p ON p.order_id = o.id
WHERE o.deleted_at IS NULL;

-- Sales and collections by trading day and outlet.
CREATE OR REPLACE SQL SECURITY INVOKER VIEW hp_pos_daily_sales AS
SELECT
  DATE(o.created_at) AS sale_date,
  o.outlet,
  COUNT(*) AS orders_count,
  ROUND(SUM(o.subtotal), 2) AS subtotal,
  ROUND(SUM(o.tax), 2) AS service_charge,
  ROUND(SUM(o.discount), 2) AS discounts,
  ROUND(SUM(o.total), 2) AS order_total,
  ROUND(SUM(CASE WHEN o.status = 'cancelled' THEN 0 ELSE o.total END), 2) AS net_sales,
  ROUND(COALESCE(SUM(p.paid), 0.00), 2) AS collected,
  ROUND(COALESCE(SUM(CASE WHEN o.status = 'cancelled' THEN 0 ELSE GREATEST(o.total - COALESCE(p.paid, 0.00), 0.00) END), 0.00), 2) AS outstanding
FROM orders o
LEFT JOIN (
  SELECT order_id, SUM(amount) AS paid
  FROM payments
  WHERE status = 'successful' AND order_id IS NOT NULL
  GROUP BY order_id
) p ON p.order_id = o.id
WHERE o.deleted_at IS NULL
GROUP BY DATE(o.created_at), o.outlet;

-- Successful payments by day, method and source.
CREATE OR REPLACE SQL SECURITY INVOKER VIEW hp_payment_mix_daily AS
SELECT
  DATE(created_at) AS payment_date,
  method,
  CASE
    WHEN order_id IS NOT NULL THEN 'pos_order'
    WHEN reservation_id IS NOT NULL THEN 'reservation'
    WHEN invoice_id IS NOT NULL THEN 'invoice'
    ELSE 'other'
  END AS source,
  COUNT(*) AS payments_count,
  ROUND(SUM(amount), 2) AS amount
FROM payments
WHERE status = 'successful'
GROUP BY DATE(created_at), method, source;

-- Cash-up: what the till should hold, what was counted and the variance.
CREATE OR REPLACE SQL SECURITY INVOKER VIEW hp_shift_reconciliation AS
SELECT
  s.id AS shift_id,
  s.user_id,
  u.name AS cashier,
  s.outlet,
  s.status,
  s.opened_at,
  s.closed_at,
  s.opening_cash,
  s.expected_cash AS recorded_expected,
  s.counted_cash,
  s.variance,
  ROUND(COALESCE(SUM(CASE WHEN p.method = 'cash' THEN p.amount ELSE 0 END), 0.00), 2) AS cash_taken,
  ROUND(COALESCE(SUM(CASE WHEN p.method <> 'cash' THEN p.amount ELSE 0 END), 0.00), 2) AS other_taken,
  COUNT(p.id) AS payments_count,
  ROUND(s.opening_cash + COALESCE(SUM(CASE WHEN p.method = 'cash' THEN p.amount ELSE 0 END), 0.00), 2) AS live_expected_cash
FROM shifts s
LEFT JOIN users u ON u.id = s.user_id
LEFT JOIN payments p
  ON p.status = 'successful'
 AND (
      p.shift_id = s.id
      OR (
        p.shift_id IS NULL
        AND p.user_id = s.user_id
        AND p.created_at >= s.opened_at
        AND p.created_at <= COALESCE(s.closed_at, NOW())
      )
 )
GROUP BY
  s.id, s.user_id, u.name, s.outlet, s.status, s.opened_at, s.closed_at,
  s.opening_cash, s.expected_cash, s.counted_cash, s.variance;

-- Problems a manager should see before closing the books. Read-only.
CREATE OR REPLACE SQL SECURITY INVOKER VIEW hp_pos_integrity_issues AS
SELECT
  'order_total_mismatch' AS issue,
  o.id AS ref_id,
  o.order_number AS reference,
  CONCAT('Total ', o.total, ' does not equal subtotal ', o.subtotal, ' + service ', o.tax, ' - discount ', o.discount) AS detail
FROM orders o
WHERE o.deleted_at IS NULL
  AND ABS(o.total - (o.subtotal + o.tax - o.discount)) > 0.01

UNION ALL

SELECT
  'order_paid_above_total' AS issue,
  o.id AS ref_id,
  o.order_number AS reference,
  CONCAT('Successful payments ', p.paid, ' exceed order total ', o.total) AS detail
FROM orders o
JOIN (
  SELECT order_id, SUM(amount) AS paid
  FROM payments
  WHERE status = 'successful' AND order_id IS NOT NULL
  GROUP BY order_id
) p ON p.order_id = o.id
WHERE o.deleted_at IS NULL
  AND p.paid > o.total + 0.01

UNION ALL

SELECT
  'cancelled_order_with_payments' AS issue,
  o.id AS ref_id,
  o.order_number AS reference,
  CONCAT('Cancelled order still has successful payments totalling ', p.paid) AS detail
FROM orders o
JOIN (
  SELECT order_id, SUM(amount) AS paid
  FROM payments
  WHERE status = 'successful' AND order_id IS NOT NULL
  GROUP BY order_id
) p ON p.order_id = o.id
WHERE o.deleted_at IS NULL
  AND o.status = 'cancelled'

UNION ALL

SELECT
  'unpaid_status_with_payments' AS issue,
  o.id AS ref_id,
  o.order_number AS reference,
  CONCAT('Status is ', o.status, ' but successful payments already total ', p.paid) AS detail
FROM orders o
JOIN (
  SELECT order_id, SUM(amount) AS paid
  FROM payments
  WHERE status = 'successful' AND order_id IS NOT NULL
  GROUP BY order_id
) p ON p.order_id = o.id
WHERE o.deleted_at IS NULL
  AND o.status NOT IN ('paid', 'partially_paid', 'cancelled')
  AND p.paid > 0.001

UNION ALL

SELECT
  'paid_status_mismatch' AS issue,
  o.id AS ref_id,
  o.order_number AS reference,
  CONCAT('Status is ', o.status, ' but payments total ', p.paid, ' of ', o.total) AS detail
FROM orders o
JOIN (
  SELECT order_id, SUM(amount) AS paid
  FROM payments
  WHERE status = 'successful' AND order_id IS NOT NULL
  GROUP BY order_id
) p ON p.order_id = o.id
WHERE o.deleted_at IS NULL
  AND o.status IN ('paid', 'partially_paid')
  AND (
    (o.status = 'paid' AND p.paid + 0.001 < o.total)
    OR (o.status = 'partially_paid' AND (p.paid <= 0.001 OR p.paid + 0.001 >= o.total))
  )

UNION ALL

SELECT
  'order_lines_total_mismatch' AS issue,
  o.id AS ref_id,
  o.order_number AS reference,
  CONCAT('Order lines total ', COALESCE(i.lines_total, 0), ' does not equal subtotal ', o.subtotal) AS detail
FROM orders o
LEFT JOIN (
  SELECT order_id, SUM(total) AS lines_total
  FROM order_items
  GROUP BY order_id
) i ON i.order_id = o.id
WHERE o.deleted_at IS NULL
  AND ABS(o.subtotal - COALESCE(i.lines_total, 0)) > 0.01

UNION ALL

SELECT
  'negative_payment' AS issue,
  p.id AS ref_id,
  COALESCE(p.provider_reference, CONCAT('payment-', p.id)) AS reference,
  CONCAT('Successful payment has a negative amount ', p.amount) AS detail
FROM payments p
WHERE p.status = 'successful'
  AND p.amount < 0

UNION ALL

SELECT
  'payment_missing_created_at' AS issue,
  p.id AS ref_id,
  COALESCE(p.provider_reference, CONCAT('payment-', p.id)) AS reference,
  CONCAT('Successful payment of ', p.amount, ' has no created_at, so it cannot be placed in a shift or day') AS detail
FROM payments p
WHERE p.status = 'successful'
  AND p.created_at IS NULL

UNION ALL

SELECT
  'closed_shift_cash_mismatch' AS issue,
  r.shift_id AS ref_id,
  CONCAT('shift-', r.shift_id) AS reference,
  CONCAT('Stored expected ', r.recorded_expected, ' but linked cash gives ', r.live_expected_cash) AS detail
FROM hp_shift_reconciliation r
WHERE r.status = 'closed'
  AND ABS(r.recorded_expected - r.live_expected_cash) > 0.01;

SELECT 'POS payment, shift and reporting patch complete.' AS result;
