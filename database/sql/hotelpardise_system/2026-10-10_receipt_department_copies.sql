-- Hotel Paradise on the Nile
-- System database patch: receipt copies for the department and the director
-- 2026-10-10
--
-- A settled payment already emails the guest their own receipt. It now also
-- emails the department that took the money - the cashier and the kitchen for
-- an order, the front desk and the accounts office for a room payment - and the
-- director, who oversees every receipt the hotel issues.
--
-- That needs two small changes to the receipt log, written here as a patch of
-- their own rather than inside the main dump:
--
--   1. the channel gains a "staff" value, next to "email" and "print", so a copy
--      to the hotel's own people is never confused with the guest's copy;
--   2. the one-row-per-payment rule becomes one row per payment, channel and
--      recipient, so a guest, a department and the director can each be logged
--      against the same settled payment.
--
-- A receipt is still only ever produced for a payment whose status is exactly
-- "successful". Nothing is emailed or printed before the money is recorded.
--
-- The application also makes these changes by itself the first time a receipt
-- is sent, so an installation that never runs this file still works. Running it
-- is the clean way to prepare a database ahead of time. It is safe to run more
-- than once: the channel change is a no-op when already applied, and the key is
-- always dropped and re-created with the same name.

ALTER TABLE `receipt_deliveries`
  MODIFY `channel` ENUM('email','print','staff') NOT NULL DEFAULT 'email';

ALTER TABLE `receipt_deliveries`
  DROP INDEX `uq_receipt_payment_channel`;

ALTER TABLE `receipt_deliveries`
  ADD UNIQUE KEY `uq_receipt_payment_channel` (`payment_id`,`channel`,`recipient`(160));
