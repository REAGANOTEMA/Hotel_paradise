# FINAL HOTEL PARADISE ON THE NILE DATABASE PACKAGE

## Folders

### `system_sql/`
All hotel management-system SQL is kept here. The coverage map includes Reception,
Reservations, Rooms, Guests, Housekeeping, Restaurant, Kitchen, Bar, Room Service,
POS, Swimming Pool, Spa, Laundry, Store/Inventory, Procurement, Maintenance, Finance,
Cashier, Accounting, Auditor, HR, Events, Transport, Communication, Users/Security,
Reporting, EFRIS, Payments, Settings and Website Integration.

### `website_sql/`
All website-specific/integration SQL is kept here. The website shares the same hotel
database/API and should not create a competing operational database.

## Installation
For the current supplied project, use the canonical existing SQL files in `system_sql/`
in this order:
1. `01_SYSTEM_SCHEMA.sql`
2. `02_SYSTEM_SEED.sql`
3. `03_SYSTEM_MENU_ALACARTE.sql`
4. `05_SYSTEM_VERIFY.sql`

See `system_sql/00_COMPLETE_DEPARTMENT_SQL_MAP.md` and the manifests for the complete
file inventory.
