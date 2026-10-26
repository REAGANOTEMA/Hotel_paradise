-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-15_pesapal_gateway_fields.sql
-- Date: 2026-10-15
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- Online card and mobile-money payments through Pesapal need four fields on the
-- payments table: the checkout token, the server-owned verification stamp, the
-- raw gateway reply, and the payer's phone. They also need the checkout token to
-- be unique and the provider reference indexed.
--
-- This version uses MariaDB's IF NOT EXISTS clauses, so it needs no stored
-- procedure and never reads information_schema. It adds only what is missing,
-- so it is safe to run more than once.
-- =============================================================================

SET NAMES utf8mb4;

ALTER TABLE payments ADD COLUMN IF NOT EXISTS checkout_token VARCHAR(190) NULL;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS verified_at   DATETIME NULL;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS gateway_result TEXT NULL;
ALTER TABLE payments ADD COLUMN IF NOT EXISTS payer_phone    VARCHAR(50) NULL;

-- A unique checkout token, and the index the gateway reconciliation reads.
ALTER TABLE payments ADD UNIQUE KEY IF NOT EXISTS idx_payments_checkout_token (checkout_token);
ALTER TABLE payments ADD KEY IF NOT EXISTS idx_pay_provider_ref (provider_reference);

-- Verification: all four fields should be present.
SHOW COLUMNS FROM payments LIKE 'checkout_token';
SHOW COLUMNS FROM payments LIKE 'verified_at';
SHOW COLUMNS FROM payments LIKE 'gateway_result';
SHOW COLUMNS FROM payments LIKE 'payer_phone';
