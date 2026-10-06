-- =====================================================================
--  RESET BEFORE RE-IMPORT
--  Run this FIRST, alone, in phpMyAdmin's SQL tab. Then import the dumps.
--
--  Fixes:  #1050 - Table 'approvals' already exists
--          (and the same error for ANY other table)
--
--  Importing the exported dump into a database that already has tables
--  always fails, because the dump creates tables but never drops them.
--  This script makes that import idempotent: it drops and recreates the
--  two databases the dumps load into, so there is nothing left to clash
--  with. Any data currently in them is lost on purpose - the dumps are
--  the master copy.
--
--  After this has run:
--    1. Select the  hotelpardise_system  database in phpMyAdmin and import
--         database\sql\hotelpardise_system\hotelpardise_system.sql
--    2. Select the  hotelpardise_website  database in phpMyAdmin and import
--         database\sql\hotelpardise_website\hotelpardise_website.sql
--
--  The dumps themselves are NOT modified - nothing is added to either of
--  them. This script is its own file on purpose.
-- =====================================================================

DROP DATABASE IF EXISTS `hotelpardise_system`;
CREATE DATABASE `hotelpardise_system` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

DROP DATABASE IF EXISTS `hotelpardise_website`;
CREATE DATABASE `hotelpardise_website` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;