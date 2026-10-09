-- ---------------------------------------------------------------------------
-- UPGRADE: customer contact details on website food orders
--
-- The public food-ordering form now collects the guest's full contact details
-- and delivery address. They are stored as real columns on `orders` rather
-- than being buried inside an order_items note, so the kitchen, the front desk,
-- the director's console and any future report can all read them.
--
-- Nothing existing is changed or dropped, and the API falls back gracefully if
-- this has not been run yet, so the site keeps working either way.
--
-- Safe to run more than once (MariaDB 10.4 supports ADD COLUMN IF NOT EXISTS).
-- ---------------------------------------------------------------------------

-- The live database used by the API and every dashboard.
USE `hotelpardise_system`;

ALTER TABLE `orders`
  ADD COLUMN IF NOT EXISTS `customer_name`    VARCHAR(160) NULL AFTER `room_id`,
  ADD COLUMN IF NOT EXISTS `customer_phone`   VARCHAR(40)  NULL AFTER `customer_name`,
  ADD COLUMN IF NOT EXISTS `customer_email`   VARCHAR(190) NULL AFTER `customer_phone`,
  ADD COLUMN IF NOT EXISTS `delivery_address` VARCHAR(255) NULL AFTER `customer_email`,
  ADD COLUMN IF NOT EXISTS `delivery_notes`   TEXT         NULL AFTER `delivery_address`;

-- The website database carries the same tables; keep them in step.
USE `hotelpardise_website`;

ALTER TABLE `orders`
  ADD COLUMN IF NOT EXISTS `customer_name`    VARCHAR(160) NULL AFTER `room_id`,
  ADD COLUMN IF NOT EXISTS `customer_phone`   VARCHAR(40)  NULL AFTER `customer_name`,
  ADD COLUMN IF NOT EXISTS `customer_email`   VARCHAR(190) NULL AFTER `customer_phone`,
  ADD COLUMN IF NOT EXISTS `delivery_address` VARCHAR(255) NULL AFTER `customer_email`,
  ADD COLUMN IF NOT EXISTS `delivery_notes`   TEXT         NULL AFTER `delivery_address`;
