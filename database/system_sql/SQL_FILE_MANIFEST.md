# SYSTEM SQL FILE MANIFEST

Generated from the files in this folder. Sizes are the on-disk sizes.

SQL files: 47

- `00_CREATE_DATABASE_USERS.sql` — 8,634 bytes
- `01_LIVE_SYSTEM_SCHEMA.sql` — 14,294 bytes
- `01_owners.sql` — 249 bytes
- `01_SYSTEM_SCHEMA.sql` — 14,294 bytes
- `02_LIVE_SYSTEM_SEED.sql` — 18,275 bytes
- `02_reception.sql` — 257 bytes
- `02_SYSTEM_SEED.sql` — 18,275 bytes
- `03_LIVE_MENU_ALACARTE.sql` — 29,497 bytes
- `03_reservations.sql` — 241 bytes
- `03_SYSTEM_MENU_ALACARTE.sql` — 29,497 bytes
- `04_INSTALL_ALL.sql` — 60,814 bytes
- `04_rooms.sql` — 224 bytes
- `04_SYSTEM_INSTALL_ALL.sql` — 61,973 bytes
- `05_housekeeping.sql` — 246 bytes
- `05_SYSTEM_VERIFY.sql` — 576 bytes
- `06_kitchen.sql` — 242 bytes
- `07_restaurant.sql` — 246 bytes
- `08_bar.sql` — 217 bytes
- `09_room_service.sql` — 235 bytes
- `10_swimming_pool.sql` — 235 bytes
- `11_spa.sql` — 228 bytes
- `12_laundry.sql` — 233 bytes
- `13_store.sql` — 227 bytes
- `14_inventory.sql` — 240 bytes
- `15_procurement.sql` — 234 bytes
- `16_maintenance.sql` — 250 bytes
- `17_events.sql` — 225 bytes
- `18_transport.sql` — 232 bytes
- `19_finance.sql` — 235 bytes
- `20_cashier.sql` — 240 bytes
- `21_accounting.sql` — 240 bytes
- `22_auditor.sql` — 228 bytes
- `23_hr.sql` — 225 bytes
- `24_pos.sql` — 243 bytes
- `25_notifications.sql` — 255 bytes
- `26_communication.sql` — 259 bytes
- `27_authentication.sql` — 263 bytes
- `28_efris.sql` — 233 bytes
- `99_SYSTEM_MASTER_INSTALL.sql` — 812 bytes
- `FINAL_INSTALL_SYSTEM.sql` — 41,770 bytes
- `INSTALL.sql` — 57,803 bytes
- `menu_alacarte.sql` — 29,497 bytes
- `schema.sql` — 8,086 bytes
- `schema_full.sql` — 14,294 bytes
- `seed.sql` — 1,041 bytes
- `seed_full.sql` — 18,275 bytes
- `seed_SOURCE_2.sql` — 1,472 bytes

## The menu is not in this folder

Every file in this list that carries the a la carte menu is superseded and
now opens with a banner saying so. It is the old proposed menu: 15 sections
and 81 dishes, many of them with no rate. The kitchen has since filed the real
menu, 19 sections and 251 dishes, every one of them priced.

The menu you install is the generated seed, one folder up:

- `database/07_FULL_MENU_SEED.sql`

Do not take the menu from `03_LIVE_MENU_ALACARTE.sql`, `03_SYSTEM_MENU_ALACARTE.sql`,
`menu_alacarte.sql`, `04_INSTALL_ALL.sql`, `04_SYSTEM_INSTALL_ALL.sql`,
`FINAL_INSTALL_SYSTEM.sql` or `INSTALL.sql`. This folder keeps the schema and
the seed for reference and for archival only.

