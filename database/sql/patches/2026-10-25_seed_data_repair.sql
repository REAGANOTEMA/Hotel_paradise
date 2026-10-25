-- =============================================================================
-- Hotel Paradise on the Nile - system database patch
-- File: database/sql/patches/2026-10-25_seed_data_repair.sql
-- Date: 2026-10-25
-- Target: hotelpardise_system
--
-- WHY THIS EXISTS
-- The clean baseline dump (../hotelpardise_system/hotelpardise_system.sql)
-- contains nine identical copies of the seven room types (ids 1-63). The 69
-- physical rooms only point at the last copy (ids 57-63), while the seeded
-- reservations carry a reservation_rooms row for every duplicate copy. That
-- produced three visible faults:
--   * 63 room types in the rate editor instead of 7
--   * the same in-house guest listed nine times on the dashboard
--   * checked-in bookings whose allocated room was still "available"
--
-- This patch repairs an existing installation in place. It does NOT rewrite the
-- baseline dump. It is safe to run more than once.
--
-- HOW TO RUN
--   mysql -u <user> -p hotelpardise_system < 2026-10-25_seed_data_repair.sql
-- or phpMyAdmin: system database -> Import -> choose this file -> Go.
--
-- WHAT IT CHANGES
--   1. Works out the canonical room type id for each name: the highest id that
--      a physical room already uses. In the shipped seed that is 57-63.
--   2. Points every room and every reservation allocation at that canonical id.
--   3. Deletes duplicate allocation rows (same booking, same physical room).
--   4. Deletes the eight extra copies of every room type name, leaving the one
--      that rooms and bookings still reference.
--   5. Marks rooms occupied for checked-in bookings and reserved for current or
--      future confirmed/pending bookings.
--
-- WHAT IT DOES NOT TOUCH
--   Guests, reservations, payments, invoices, rooms and room numbers are never
--   deleted. Only duplicate room_types rows and duplicate reservation_rooms
--   rows are removed, after their references have been remapped.
-- =============================================================================

SET NAMES utf8mb4;
SET @OLD_SQL_SAFE_UPDATES = @@SQL_SAFE_UPDATES;
SET SQL_SAFE_UPDATES = 0;

START TRANSACTION;

-- -----------------------------------------------------------------------------
-- 1. Canonical room type per (hotel_id, name).
-- -----------------------------------------------------------------------------
DROP TEMPORARY TABLE IF EXISTS tmp_rt_referenced;
CREATE TEMPORARY TABLE tmp_rt_referenced (
  hotel_id BIGINT UNSIGNED NOT NULL,
  name     VARCHAR(190)    NOT NULL,
  keep_id  BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (hotel_id, name)
) ENGINE = InnoDB;

INSERT INTO tmp_rt_referenced (hotel_id, name, keep_id)
SELECT rt.hotel_id, rt.name, MAX(rt.id)
FROM rooms r
JOIN room_types rt ON rt.id = r.room_type_id
WHERE r.deleted_at IS NULL
GROUP BY rt.hotel_id, rt.name;

DROP TEMPORARY TABLE IF EXISTS tmp_rt_canon;
CREATE TEMPORARY TABLE tmp_rt_canon (
  hotel_id BIGINT UNSIGNED NOT NULL,
  name     VARCHAR(190)    NOT NULL,
  keep_id  BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (hotel_id, name)
) ENGINE = InnoDB;

INSERT INTO tmp_rt_canon (hotel_id, name, keep_id)
SELECT hotel_id, name, keep_id FROM tmp_rt_referenced;

-- A room type with no physical room still needs a canonical row.
INSERT INTO tmp_rt_canon (hotel_id, name, keep_id)
SELECT rt.hotel_id, rt.name, MAX(rt.id)
FROM room_types rt
LEFT JOIN tmp_rt_referenced ref
  ON ref.hotel_id = rt.hotel_id AND ref.name = rt.name
WHERE ref.keep_id IS NULL
GROUP BY rt.hotel_id, rt.name;

-- -----------------------------------------------------------------------------
-- 2. Point every physical room at the canonical id for its type name.
-- -----------------------------------------------------------------------------
UPDATE rooms r
JOIN room_types rt ON rt.id = r.room_type_id
JOIN tmp_rt_canon c ON c.hotel_id = rt.hotel_id AND c.name = rt.name
SET r.room_type_id = c.keep_id
WHERE r.room_type_id <> c.keep_id;

-- -----------------------------------------------------------------------------
-- 3. Remap reservation allocations. Allocated rows follow their physical room;
--    unallocated rows (room_id IS NULL) follow the type name.
-- -----------------------------------------------------------------------------
UPDATE reservation_rooms rr
JOIN rooms r ON r.id = rr.room_id
SET rr.room_type_id = r.room_type_id
WHERE rr.room_type_id <> r.room_type_id;

UPDATE reservation_rooms rr
JOIN room_types rt ON rt.id = rr.room_type_id
JOIN tmp_rt_canon c ON c.hotel_id = rt.hotel_id AND c.name = rt.name
SET rr.room_type_id = c.keep_id
WHERE rr.room_type_id <> c.keep_id;

-- -----------------------------------------------------------------------------
-- 4. Remove duplicate allocations: same reservation, same physical room.
--    Unallocated rows are left alone - they represent requested quantity.
-- -----------------------------------------------------------------------------
DELETE dup
FROM reservation_rooms dup
JOIN reservation_rooms keep
  ON keep.reservation_id = dup.reservation_id
 AND keep.room_id = dup.room_id
 AND keep.id < dup.id
WHERE dup.room_id IS NOT NULL;

-- -----------------------------------------------------------------------------
-- 5. Delete duplicate / orphan room types. Anything still referenced is kept,
--    so this removes only the eight extra copies of each of the seven names.
-- -----------------------------------------------------------------------------
DELETE rt
FROM room_types rt
JOIN tmp_rt_canon c
  ON c.hotel_id = rt.hotel_id AND c.name = rt.name AND c.keep_id <> rt.id
LEFT JOIN rooms r ON r.room_type_id = rt.id
LEFT JOIN reservation_rooms rr ON rr.room_type_id = rt.id
WHERE r.id IS NULL AND rr.id IS NULL;

-- -----------------------------------------------------------------------------
-- 6. Make room status agree with the bookings.
-- -----------------------------------------------------------------------------
-- Rooms belonging to a checked-in booking are occupied.
UPDATE rooms r
JOIN reservation_rooms rr ON rr.room_id = r.id
JOIN reservations v ON v.id = rr.reservation_id
SET r.status = 'occupied'
WHERE v.status = 'checked_in'
  AND v.deleted_at IS NULL
  AND r.status <> 'occupied';

-- Rooms held by a current or future confirmed/pending booking are reserved.
-- Never overwrites a dirty, cleaning, maintenance or occupied room.
UPDATE rooms r
JOIN reservation_rooms rr ON rr.room_id = r.id
JOIN reservations v ON v.id = rr.reservation_id
SET r.status = 'reserved'
WHERE v.status IN ('confirmed', 'pending')
  AND v.deleted_at IS NULL
  AND v.check_in >= CURDATE()
  AND r.status = 'available';

DROP TEMPORARY TABLE IF EXISTS tmp_rt_referenced;
DROP TEMPORARY TABLE IF EXISTS tmp_rt_canon;

COMMIT;

SET SQL_SAFE_UPDATES = @OLD_SQL_SAFE_UPDATES;

-- =============================================================================
-- VERIFICATION
-- The expected result is shown beside each block. Anything else means the patch
-- did not finish; do not keep running other patches until it is understood.
-- =============================================================================

-- Expected: room_types=7, rooms=69, reservations=12, reservation_rooms=12 on
-- the shipped seed (reservation/room counts reflect whatever the database holds).
SELECT 'room_types' AS check_name, COUNT(*) AS value FROM room_types
UNION ALL SELECT 'rooms', COUNT(*) FROM rooms
UNION ALL SELECT 'reservations', COUNT(*) FROM reservations
UNION ALL SELECT 'reservation_rooms', COUNT(*) FROM reservation_rooms;

-- Expected: no rows. Duplicate type names.
SELECT hotel_id, name, COUNT(*) AS copies
FROM room_types
GROUP BY hotel_id, name
HAVING copies > 1;

-- Expected: no rows. Duplicate allocations of one room to one booking.
SELECT reservation_id, room_id, COUNT(*) AS copies
FROM reservation_rooms
WHERE room_id IS NOT NULL
GROUP BY reservation_id, room_id
HAVING copies > 1;

-- Expected: 0. Allocations pointing at a room type that no longer exists.
SELECT COUNT(*) AS orphan_allocation_types
FROM reservation_rooms rr
LEFT JOIN room_types rt ON rt.id = rr.room_type_id
WHERE rt.id IS NULL;

-- Expected: 0. Allocation type disagrees with the physical room's type.
SELECT COUNT(*) AS allocation_type_mismatches
FROM reservation_rooms rr
JOIN rooms r ON r.id = rr.room_id
WHERE rr.room_type_id <> r.room_type_id;

-- Expected: 0. Checked-in booking whose room is not occupied.
SELECT COUNT(*) AS checked_in_rooms_not_occupied
FROM reservation_rooms rr
JOIN reservations v ON v.id = rr.reservation_id
JOIN rooms r ON r.id = rr.room_id
WHERE v.status = 'checked_in'
  AND v.deleted_at IS NULL
  AND r.status <> 'occupied';

-- Expected: one row (Grace Akello, Suite S101, occupied) on the shipped seed.
SELECT v.booking_number, g.full_name, rt.name AS room_type, r.room_number, r.status
FROM reservations v
JOIN guests g ON g.id = v.guest_id
JOIN reservation_rooms rr ON rr.reservation_id = v.id
JOIN rooms r ON r.id = rr.room_id
JOIN room_types rt ON rt.id = rr.room_type_id
WHERE v.status = 'checked_in' AND v.deleted_at IS NULL;
