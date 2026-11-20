# The database

The two SQL files below are the clean installs. Everything else in the folder is
either documentation about them or a dated upgrade patch:

| File | Database | Holds |
|---|---|---|
| `sql/hotelpardise_system/hotelpardise_system.sql` | `hotelpardise_system` | the hotel and its management system: 118 tables, schema and data together |
| `sql/hotelpardise_website/hotelpardise_website.sql` | `hotelpardise_website` | the public site: 45 tables, schema and data together |

Changes made after those dumps were cut live in `sql/patches/` (system database)
and `sql/hotelpardise_website/patches/` (website database). The system patch list
and run order are in `sql/patches/README.txt`.

Both are plain phpMyAdmin dumps. Neither one says which database it belongs to,
so whichever tool loads them has to point the connection at the right one first.

## Installing

One command, from the project folder:

```
C:\xampp\php\php.exe tools\install-databases.php
```

It creates the databases, the two MySQL accounts and their grants, loads both
dumps, and finishes by connecting the way the site does and saying so. To check
an existing install without changing anything, add `--check`.

`HOSTING.md` is the same install as a phpMyAdmin list, for a host where there
is no shell.

`00_README_FIRST.md` answers the questions that come up before an install.

## What is not here

There is no separate schema file, seed file or menu file: a dump carries its own
schema and its own rows, so loading one twice would duplicate the rows rather
than update them. The installer refuses to load a dump into a database that
already has tables in it for exactly that reason.

## tools/

`check-menu.mjs` compares the menu in `frontend-react/src/menuData.ts` with the
kitchen's own JSON, item by item and price by price, and reports anything
missing, extra, renamed or repriced. It reads files and prints a report; it
does not write SQL and it does not touch the database.

```bash
node database/tools/check-menu.mjs . database/tools/kitchen-menu-source.json
```
