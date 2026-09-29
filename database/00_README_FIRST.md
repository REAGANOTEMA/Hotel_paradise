# READ THIS FIRST — database installation

## The one command

From the project folder:

```
C:\xampp\php\php.exe tools\install-databases.php
```

It creates both databases, both MySQL accounts and their grants, and loads the
schema, the seed and the published menu, in the order that works. It is safe to
run again, and it prints nothing secret.

To check an install without changing anything:

```
C:\xampp\php\php.exe tools\install-databases.php --check
```

## Database names

| Purpose | Name |
|---|---|
| Management system (`backend-php/`) | `hotelpardise_system` |
| Public website | `hotelpardise_website` |

> An earlier version of this file gave the management system's database as
> `hotel_paradise_nile`. **That is wrong, and following it is what produces
> `#1062 Duplicate entry 'hotel-paradise-on-the-nile' for key 'slug'.** Every
> install file in this folder says `USE hotelpardise_system;`.
>
> `hotel_paradise_nile` was the original name. It may still exist on an older
> install, already populated, which is why seeding it collides with itself.
> Nothing in `backend-php/` ever connects to it.

## The files

In this folder, and in this order:

| Step | File |
|---|---|
| Schema | `01_LIVE_SYSTEM_SCHEMA.sql` |
| Seed | `02_LIVE_SYSTEM_SEED.sql` |
| Published menu | `07_FULL_MENU_SEED.sql` |
| Website | `website_sql/01_WEBSITE_INTEGRATION_SCHEMA.sql` |

> An earlier version of this file listed `03_LIVE_MENU_ALACARTE.sql` as the
> menu step. The installer uses `07_FULL_MENU_SEED.sql`, which is the same menu
> plus the `published` column the public site filters on. Running the
> `03_` file on its own leaves the public site's menu empty.

Do not run `schema.sql`, `seed.sql`, `seed_full.sql` or `menu_alacarte.sql`.
They are the original versions, kept only so the differences from the `_LIVE_`
files stay visible, and they are not re-runnable.

**Anything under `database/system_sql/` is archived and must not be run.** See
the README in that folder for what is still useful there.

## Hosting

`HOSTING.md` has the same steps as a phpMyAdmin list, plus what to do about
`#1227` (wrong account) and `#1062` (seed already applied).

## Expanded architecture

`../expanded-system-blueprint/database/` contains the broader department
architecture requested for the future full hotel platform. It is included for
reference and planning. It is **not** a drop-in replacement for the live PHP
system schema because its table model uses a different property/group
architecture.

This separation prevents accidentally mixing incompatible SQL schemas.
