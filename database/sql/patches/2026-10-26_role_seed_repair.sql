-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-26_role_seed_repair.sql
-- Date: 2026-10-26
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- The console names roles by their string name. An install whose roles table
-- was seeded before a department existed can be missing one of them, and a
-- member can then never be given that duty - the role is not in the checklist.
-- The Bar dashboard, Stock Requests and the newsroom are the usual symptoms.
--
-- This adds only the names that are missing. A name already present is left
-- exactly as it is, including a name the hotel renamed by hand. Safe to run
-- more than once. It does not touch user_roles, so nobody gains a duty.
-- =============================================================================

SET NAMES utf8mb4;

INSERT INTO roles (name)
SELECT r.name FROM (
  SELECT 'super_admin' AS name UNION ALL
  SELECT 'director' UNION ALL
  SELECT 'general_manager' UNION ALL
  SELECT 'accountant' UNION ALL
  SELECT 'cashier' UNION ALL
  SELECT 'receptionist' UNION ALL
  SELECT 'waiter' UNION ALL
  SELECT 'bar_staff' UNION ALL
  SELECT 'kitchen' UNION ALL
  SELECT 'storekeeper' UNION ALL
  SELECT 'procurement' UNION ALL
  SELECT 'inventory_manager' UNION ALL
  SELECT 'housekeeping' UNION ALL
  SELECT 'maintenance' UNION ALL
  SELECT 'events_manager' UNION ALL
  SELECT 'marketing' UNION ALL
  SELECT 'auditor' UNION ALL
  SELECT 'human_resource' UNION ALL
  SELECT 'guest'
) r
WHERE NOT EXISTS (SELECT 1 FROM roles x WHERE x.name = r.name);

-- Verification: every name should be present exactly once.
SELECT name, COUNT(*) AS copies FROM roles GROUP BY name ORDER BY name;
