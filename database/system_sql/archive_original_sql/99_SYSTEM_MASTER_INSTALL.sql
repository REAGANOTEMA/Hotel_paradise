-- HOTEL PARADISE ON THE NILE
-- Reagansoft Innovation Limited
-- MASTER SYSTEM INSTALLER
-- Run this file in MySQL 8+.
-- It includes the authoritative schema/seed/menu files that exist in this package.
CREATE DATABASE IF NOT EXISTS hotel_paradise_nile;
USE hotel_paradise_nile;

-- MySQL does not support SOURCE inside all GUI import modes consistently.
-- Therefore use the following order in phpMyAdmin/MySQL client:
-- 1) 01_SYSTEM_SCHEMA.sql
-- 2) 02_SYSTEM_SEED.sql
-- 3) 03_SYSTEM_MENU_ALACARTE.sql
-- Then run 05_SYSTEM_VERIFY.sql.
-- This master file documents the canonical order and database target.
SELECT DATABASE() AS active_database;
SELECT 'Install order: 01_SYSTEM_SCHEMA.sql -> 02_SYSTEM_SEED.sql -> 03_SYSTEM_MENU_ALACARTE.sql -> 05_SYSTEM_VERIFY.sql' AS installation_order;
