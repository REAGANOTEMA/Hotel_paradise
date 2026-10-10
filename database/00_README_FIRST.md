# READ THIS FIRST — database installation

## The one command

From the project folder:

```
C:\xampp\php\php.exe tools\install-databases.php
```

It creates both databases, both MySQL accounts and their grants, loads both
dumps, and checks the result the way the site checks it. It is safe to run
again, and it prints nothing secret.

To check an install without changing anything:

```
C:\xampp\php\php.exe tools\install-databases.php --check
```

## Database names

| Purpose | Name |
|---|---|
| Management system (`backend-php/`) | `hotelpardise_system` |
| Public website | `hotelpardise_website` |

> `hotel_paradise_nile` was the original name of the management system's
> database. Nothing in this project connects to it, and nothing in this project
> creates it. If it still exists on a machine, it is left over from an older
> install; do not point anything at it, and do not paste anything into it.

## The files

Two, and they are the only SQL in the project:

| Step | File | Database | Tables |
|---|---|---|---|
| Hotel | `sql/hotelpardise_system/hotelpardise_system.sql` | `hotelpardise_system` | 102 |
| Website | `sql/hotelpardise_website/hotelpardise_website.sql` | `hotelpardise_website` | 38 |

Each dump carries its schema and its data together, and neither one names the
database it belongs to — the loader selects the database first and then runs the
file. Neither has a `DROP TABLE` or a `CREATE DATABASE` in it either, so a dump
can only be loaded into an **empty** database. A database that already has
tables is a site being used, and its rows are not this install's to touch; the
installer says so and stops rather than doubling everything.

New features that arrive after a fresh install are small standalone patches in
`sql/hotelpardise_system/` (named by date, e.g.
`2026-10-10_events_enquiries.sql`). Each is `CREATE TABLE IF NOT EXISTS`-safe to
re-run, never edits existing tables, and does not belong in the dumps — the
dumps are the blank slate, the patches are the upgrades shipped on top.

Order still matters, and not because of the dumps: the accounts and the grants
are not in them, and a `GRANT` naming a table cannot be granted before that
table exists. Databases, dumps, accounts, grants — any other order fails
silently, and the only symptom is the site refusing to connect hours later.

## Hosting

`HOSTING.md` has the same steps as a phpMyAdmin list, plus what to do about
`#1227` (wrong account) and a load that stops half way.

## Expanded architecture

`../expanded-system-blueprint/` contains the broader department architecture
requested for the future full hotel platform. It is included for reference and
planning. It is **not** a drop-in replacement for the live PHP system schema
because its table model uses a different property/group architecture.
