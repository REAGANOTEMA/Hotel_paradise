# ARCHIVED — do not run anything in this folder

These files are kept for reference and for the department blueprint. They are
**not** the install path, and running them will not do what the file names
suggest.

Two specific traps in here, both of which have been hit in practice:

**1. They point at the wrong database.** The install files in this folder say
`USE hotel_paradise_nile;`. That was the original database name. The live
database is `hotelpardise_system`, and it is the only one the PHP application
in `backend-php/` ever connects to. `hotel_paradise_nile` still exists on an
older install and is already fully populated, so running these files against it
stops at the first statement:

```
#1062 Duplicate entry 'hotel-paradise-on-the-nile' for key 'slug'
```

and, for a file that got further before the error, leaves the rest of its
INSERTs to be attempted against a database nobody reads.

**2. They are not re-runnable.** They are plain `INSERT` statements with no
`IF NOT EXISTS` and no `ON DUPLICATE KEY UPDATE`, so a second run collides with
its own first run. Neither is avoidable by retrying; the answer is not to run
them.

## The install path

One command, from the project folder. It creates the databases, the accounts and
the grants, loads the schema, the seed and the published menu, in the order
that works, and is safe to run again:

```
C:\xampp\php\php.exe tools\install-databases.php
```

To check an existing install without changing anything:

```
C:\xampp\php\php.exe tools\install-databases.php --check
```

The files it loads are the ones in `database/`, not in this folder:

| Step | File |
|---|---|
| Schema | `database/01_LIVE_SYSTEM_SCHEMA.sql` |
| Seed | `database/02_LIVE_SYSTEM_SEED.sql` |
| Published menu | `database/07_FULL_MENU_SEED.sql` |
| Website | `database/website_sql/01_WEBSITE_INTEGRATION_SCHEMA.sql` |

For hosting panels with no shell, `database/HOSTING.md` has the same four steps
as a phpMyAdmin list.

## What is actually still useful here

- `DEPARTMENT_SQL_INDEX.md` and `00_COMPLETE_DEPARTMENT_SQL_MAP.md` — the
  department-by-department plan, with the numbered files (`02_reception.sql`,
  `14_inventory.sql`, `19_finance.sql` and so on) as its detail. They are
  design notes for the wider platform, not part of the install.
- `schema_full.sql` and the `archive_original_sql/` folder — the original
  schema as it was first written, kept so the differences from
  `01_LIVE_SYSTEM_SCHEMA.sql` stay visible.
