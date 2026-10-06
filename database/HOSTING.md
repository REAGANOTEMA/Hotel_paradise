# Putting the hotel online: the phpMyAdmin route

Everything below is done in the hosting panel's **phpMyAdmin**, by importing one
file at a time. Four steps, in this order. Do not skip a step or reorder them.

> **On a machine you control, do not do this by hand.** Run
> `php tools/install-databases.php` instead. It does all four steps in the only
> order that works, reads the passwords from `backend-php/config.php` so there
> is nothing to copy and no way for the two to disagree, and finishes by
> connecting as the site does and saying so. It is safe to run again.
>
> The reason this page exists as a manual list is that the order is not
> optional. Step 4 grants rights on tables named inside `hotelpardise_system`,
> and a grant on a table that is not there yet is refused without a word. So
> running the grants before the dumps looks like it worked, and then the site
> cannot sign in hours later for a reason that has nothing to do with the
> grants. The dumps come first precisely so that trap cannot be stepped in.

## Before you start

You need the database names and passwords from the hosting panel. Open
**MySQL Databases** and write down exactly what it says. Most hosts prefix both
the database and the user with your account name, so the real name may be
`reagan_hotelpardise_system` rather than `hotelpardise_system`.

That prefix matters. If you change it anywhere, change it in **all** the steps
below *and* in `backend-php/config.php`, or the site will connect to an empty
database and quietly show its built-in menu instead of your real one.

Check first whether the site is already installed:

```
C:\xampp\php\php.exe tools\install-databases.php --check
```

It changes nothing. If it answers *"the site is installed correctly"*, stop:
there is nothing here to do.

## Step 1 — two empty databases

Create both, each with the same character set the dumps were taken with:

```sql
CREATE DATABASE `hotelpardise_system` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE `hotelpardise_website` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

Prefix the names if your host does.

Both must be **empty**. A dump of this kind has no `DROP TABLE` and no
`CREATE TABLE IF NOT EXISTS` in it: it can only be loaded into a database with
no tables at all. Loading it into a database that already has tables fails part
way through and leaves a half-built site, and a database that already has tables
is usually a site being used, whose rows are not yours to overwrite. If one is
not empty, either drop it — knowing that drops the site it holds — or leave it
alone.

## Step 2 — the hotel's data

In `hotelpardise_system`, open the **Import** tab and choose

```
database/sql/hotelpardise_system/hotelpardise_system.sql
```

Character set: `utf8mb4`. Press **Go**.

When it finishes you should have **102 tables**, and it should end without an
error. This file carries the tables *and* the rows together: the hotel, the
staff, the rooms, the reservations, and the whole menu — 1,932 dishes in 119
categories across the restaurant, the bar and room service, of which 644 are
active.

## Step 3 — the website's data

Switch to `hotelpardise_website` and import

```
database/sql/hotelpardise_website/hotelpardise_website.sql
```

**38 tables**, including `website_settings`, which holds the site's own
settings.

The menu the guest reads and the order the kitchen receives live in
`hotelpardise_system`, not here: the website account is granted read access to
those tables in the next step, so there is one copy of the menu rather than two
that can drift apart.

## Step 4 — the accounts and their rights

Back on the phpMyAdmin home page, so this runs against neither database in
particular. Copy the block below into a text editor and replace the
placeholders:

- `PASTE_THE_HOTEL_PASSWORD_HERE`
- `PASTE_THE_WEBSITE_PASSWORD_HERE`
- `hotelpardise_system` → your prefixed hotel database name, if it has one
- `hotelpardise_website` → your prefixed website database name, if it has one

```sql
-- The accounts, for both the socket and TCP, because MariaDB decides which
-- matches from the address in the connection.
CREATE USER IF NOT EXISTS 'hotelpardise_system'@'localhost'  IDENTIFIED BY 'PASTE_THE_HOTEL_PASSWORD_HERE';
CREATE USER IF NOT EXISTS 'hotelpardise_system'@'127.0.0.1'  IDENTIFIED BY 'PASTE_THE_HOTEL_PASSWORD_HERE';
CREATE USER IF NOT EXISTS 'hotelpardise_website'@'localhost' IDENTIFIED BY 'PASTE_THE_WEBSITE_PASSWORD_HERE';
CREATE USER IF NOT EXISTS 'hotelpardise_website'@'127.0.0.1' IDENTIFIED BY 'PASTE_THE_WEBSITE_PASSWORD_HERE';

GRANT ALL PRIVILEGES ON `hotelpardise_system`.* TO 'hotelpardise_system'@'localhost';
GRANT ALL PRIVILEGES ON `hotelpardise_system`.* TO 'hotelpardise_system'@'127.0.0.1';

-- The website reads the published menu and may take a booking. It is not
-- granted the hotel's money or guest documents.
GRANT SELECT, INSERT, UPDATE, DELETE ON `hotelpardise_website`.* TO 'hotelpardise_website'@'localhost';
GRANT SELECT, INSERT, UPDATE, DELETE ON `hotelpardise_website`.* TO 'hotelpardise_website'@'127.0.0.1';

GRANT SELECT ON `hotelpardise_system`.menu_categories TO 'hotelpardise_website'@'localhost';
GRANT SELECT ON `hotelpardise_system`.menu_items      TO 'hotelpardise_website'@'localhost';
GRANT SELECT ON `hotelpardise_system`.room_types      TO 'hotelpardise_website'@'localhost';
GRANT SELECT ON `hotelpardise_system`.rooms           TO 'hotelpardise_website'@'localhost';
GRANT SELECT ON `hotelpardise_system`.hotels          TO 'hotelpardise_website'@'localhost';
GRANT SELECT (id, phone, full_name) ON `hotelpardise_system`.guests       TO 'hotelpardise_website'@'localhost';
GRANT SELECT (booking_number)       ON `hotelpardise_system`.reservations TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON `hotelpardise_system`.guests           TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON `hotelpardise_system`.reservations     TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON `hotelpardise_system`.reservation_rooms TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON `hotelpardise_system`.orders           TO 'hotelpardise_website'@'localhost';
GRANT INSERT ON `hotelpardise_system`.order_items      TO 'hotelpardise_website'@'localhost';

FLUSH PRIVILEGES;
```

Repeat every `hotelpardise_website` grant for `'hotelpardise_website'@'127.0.0.1'`
as well, or copy the block twice and change the host — whichever is less error
prone by hand.

They are placeholders on purpose. The passwords you are about to put in are the
same two you will put in `backend-php/config.php`, and a real password inside a
committed file is a password that has to be changed the moment that file is
shared.

**This step must come after steps 2 and 3, not before.** A grant on a named
table only takes if the table is already there, so running it first fails on the
grants — and those are the grants that matter.

When it finishes, show the rights for `hotelpardise_website` and check it holds
rights on named tables only, **not** on the whole hotel database. If your host
refuses one user being given rights on two databases, that is the step to hand
to them: ask for `SELECT` on `menu_categories`, `menu_items`, `room_types`,
`rooms` and `hotels`, plus `INSERT` on `guests`, `reservations`,
`reservation_rooms`, `orders` and `order_items`.

## Step 5 — tell the site where the database is

`backend-php/config.php` is never committed, because it holds the passwords. You
must create it on the server yourself. Copy it across, then change:

- `port` — on most hosts leave this empty. This machine's XAMPP uses `3306`.
- the database and user names, if your host prefixes them
- the two passwords, to the ones from your hosting panel

`host` stays `127.0.0.1` on almost all shared hosting. If your panel gives you a
MySQL hostname such as `mysql.yourhosting.com`, use that instead.

## Step 6 — check it works

Visit, in the browser:

```
https://your-domain/backend-php/api.php?act=health
```

You are looking for `"ok":true`, and for both databases to show
`"connected":true`. If it says `"ok":false`, the message under `hotel` or
`website` says why, in plain words. The same answer is what the management
system itself shows now, as a page rather than as a PHP error, if it cannot
reach the database at all.

Then the menu:

```
https://your-domain/backend-php/api.php?act=menu
```

`"menu_items"` of 644 under `hotel` on the health page, and 63 categories in
the menu response, means the database is installed correctly. A zero under
`website` is normal: the website's own database holds the settings, not the
menu.

## Where the files go

The pages and `backend-php/` must sit in the same folder, because the site
finds its API relative to wherever it is installed. Both layouts work:

```
public_html/                  <- the site is the whole domain
    index.html
    menu.html
    backend-php/

public_html/hotelparadiseonthenile/   <- the site is in a subfolder
    index.html
    menu.html
    backend-php/
```

The site tries both by itself, so it does not matter which you were given. It
also still works from the project folder on this machine, which is how the
whole thing was tested.

## If something goes wrong

**The website shows a menu but the prices are the old ones, or a dish you
changed in phpMyAdmin does not appear.** The site could not reach the database
and fell back to the copy it carries. Check `?act=health` and look for a
password error; the most common cause is a database name with your host's
prefix that was not written into `config.php`.

**`Access denied for user ...` in the health output.** The name or password in
`config.php` does not match what the host created. Copy them again from the
hosting panel.

**`Unknown database 'hotelpardise_system'`.** The prefix issue above. The
database is really called something like `reagan_hotelpardise_system`.

**The import stopped part way through with `#1062 Duplicate entry ...`.** The
database was not empty when the dump went in, so the dump hit rows that were
already there. The tables it had already created are still there, and the ones
it had not reached are missing. Dropping only the offending row does not fix
this: the rest of the file then inserts alongside the rows already present and
you end up with everything doubled, with no error to say so. The answer is to
drop the database and import into an empty one, or to leave the existing one
alone. Step 1 exists so this is decided before the import rather than after it.

**A file that says `USE hotel_paradise_nile;`.** That is the original database
name. Nothing in this project uses it or creates it, and nothing in this
project's SQL names any database at all — the loader selects the database first
and then runs the file. If phpMyAdmin is pointed at `hotel_paradise_nile`, you
are in a database the application never connects to.

**Everything looks right but the menu is empty.** Check that step 2 imported
into the database `config.php` actually names, and that the health page reports
`"menu_items"` above zero.

**`#1227 Access denied; you need (at least one of) the CREATE USER privilege(s)`.**
The account being used cannot create MySQL accounts. This is not a problem with
the hotel: it is the account. MySQL gives out `GRANT ALL` on a *single* database
to hosting accounts and to this project's own `hotelpardise_system` user, and
that is not the same thing as the right to create a user, which lives on `*.*`.

Seen in phpMyAdmin, it almost always means the session is logged in as some
other project's account. This server holds accounts for several sites, and the
one phpMyAdmin signed in with has rights on *its* database, not on `*.*`. The
fix is the logout link at the top of phpMyAdmin, then sign in again as `root`
with an empty password, which is what XAMPP's root has.

On hosting, where you are never root, create the two users in the panel instead
and use the panel's names and passwords in `config.php`; only the cross-database
grants in step 4 need an account that has rights on `*.*`, which is the one thing
to ask the host for.

If the site is *already* installed correctly, none of this is needed. Run this
and stop:

```
C:\xampp\php\php.exe tools\install-databases.php --check
```

It changes nothing and reports whether both databases open with the passwords in
`config.php`.

**The management system will not sign in, and the health page is `"ok":true`.**
The database is fine and the problem is a password or a role, not a connection.
`--check` will say so explicitly.
