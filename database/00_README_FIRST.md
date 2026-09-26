# Hotel Paradise on the Nile — Database Installation

## LIVE website + PHP management system database

The **LIVE_MANAGEMENT_SYSTEM** in `backend-php/` uses the database schema in:

1. `01_LIVE_SYSTEM_SCHEMA.sql`
2. `02_LIVE_SYSTEM_SEED.sql`
3. `03_LIVE_MENU_ALACARTE.sql`

Database name: `hotel_paradise_nile`

### Recommended order

```text
01_LIVE_SYSTEM_SCHEMA.sql
        ↓
02_LIVE_SYSTEM_SEED.sql
        ↓
03_LIVE_MENU_ALACARTE.sql   (optional menu refresh)
```

Do not run the older `schema.sql` / `seed.sql` files if you are doing a clean installation.

`04_INSTALL_ALL.sql` is a convenience copy containing the same live schema + seed + menu in order.

## Expanded architecture

`../expanded-system-blueprint/database/` contains the broader department architecture requested for the future full hotel platform. It is included for reference and planning. It is **not** a drop-in replacement for the live PHP system schema because its table model uses a different property/group architecture.

This separation prevents accidentally mixing incompatible SQL schemas.
