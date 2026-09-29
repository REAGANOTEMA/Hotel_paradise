# Putting the hotel online: the phpMyAdmin route

Everything below is done in the hosting panel's **phpMyAdmin**, by pasting one
file at a time into the **SQL** tab and pressing **Go**. Five pastes, in this
order. Do not skip a step or reorder them; each one depends on the last.

> **On a machine you control, do not do this by hand.** Run
> `php tools/install-databases.php` instead. It does all five steps in the only
> order that works, reads the passwords from `backend-php/config.php` so there
> is nothing to copy and no way for the two to disagree, and finishes by
> connecting as the site does and saying so. It is safe to run again.
>
> The reason this page exists as a manual list is that the order is not
> optional. Step 2 grants rights on tables named inside `hotelpardise_system`,
> and a grant on a table that is not there yet is refused without a word. So
> running the grants before the schema looks like it worked, and then the site
> cannot sign in hours later for a reason that has nothing to do with the
> grants. `tools/install-databases.php` puts the schema first precisely so that
> trap cannot be stepped in.

## Before you start

You need the database names and passwords from the hosting panel. Open
**MySQL Databases** and write down exactly what it says. Most hosts prefix both
the database and the user with your account name, so the real name may be
`reagan_hotelpardise_system` rather than `hotelpardise_system`.

That prefix matters. If you change it anywhere, change it in **all** the files
below *and* in `backend-php/config.php`, or the site will connect to an empty
database and quietly show its built-in menu instead of your real one.

## Step 0 — check before you seed

Paste `database/00_CHECK_BEFORE_SEEDING.sql` and press **Go**, before anything
else.

It changes nothing. If the database is empty it says so, and you carry on. If
it is already installed it stops with a message telling you to leave it alone
and run `php tools/install-databases.php --check` instead.

Do not skip this. Step 3 is plain `INSERT` statements with no
`IF NOT EXISTS`, so pasting it into a database that already has the hotel in it
fails on its first line with

```
#1062 Duplicate entry 'hotel-paradise-on-the-nile' for key 'slug'
```

and that error is not a problem to be fixed. It means the seed was already
applied. Deleting the first row to get past it makes it worse, not better:
`rooms`, `guests` and `suppliers` have no unique key, so the rest of the file
would be inserted alongside the rows already there and come out **doubled**,
with the console showing 138 rooms and two of everything else.

## Step 1 — the hotel's tables

With `hotelpardise_system` selected in the left-hand list, paste
`database/01_LIVE_SYSTEM_SCHEMA.sql`.

You should get 32 tables. If you get an error saying a table already exists,
that is fine and harmless; the file asks before creating each one.

## Step 2 — the databases' users and rights

Back on the phpMyAdmin home page, open `database/05_HOSTING_INSTALL.sql` in a
text editor first and replace the two placeholders:

- `PASTE_THE_HOTEL_PASSWORD_HERE`
- `PASTE_THE_WEBSITE_PASSWORD_HERE`

with the two passwords you noted down, then paste the file into phpMyAdmin.

They are placeholders on purpose. The file lives in the repository, and a real
password inside a committed file is a password that has to be changed the moment
that file is shared. The passwords to use are the same two you will put in
`backend-php/config.php` in step 6.

This creates both databases, both users, and the rights each one has. It
changes nothing else, and it is safe to run again if you need to.

**This one must come after step 1, not before.** A grant on a named table only
takes if the table is already there, so running it first fails on the grants
near the end of the file — and those are the grants that matter.

It finishes by showing you the rights it granted. Check the last one reads
`hotelpardise_website` and that you can see it holds rights on named tables
only, **not** on the whole hotel database. If your host refuses one user being
given rights on two databases, delete the two lines granting
`hotelpardise_system` rights on `hotelpardise_website` and carry on.

## Step 3 — the hotel's starting data

With `hotelpardise_system` selected, paste `database/02_LIVE_SYSTEM_SEED.sql`.
This loads the hotel, the staff roles, the room types and a first menu.

## Step 4 — the full published menu

With `hotelpardise_system` selected, paste `database/07_FULL_MENU_SEED.sql`.

This loads all 15 sections and all 81 dishes exactly as the website shows them.
It finishes with five checks. Read them:

| check | must read |
|---|---|
| `published_sections` | 15 |
| `published_dishes` | 81 |
| `sections_covered` | 15 |
| `published_dish_with_no_section` | 0 |
| `published_section_with_no_dish` | 0 |

The last two are the ones that matter. Anything above zero means a dish the
guest cannot reach, or a section that opens to nothing.

**Re-running this file is safe.** It matches dishes by name and updates them in
place, so you can run it again whenever the kitchen changes the menu. It never
deletes anything and never deactivates a dish, so past orders stay readable and
the bar and room service menus are left alone. A dish dropped from the website
is marked unpublished rather than removed, which is why the till still sells it.

## Step 5 — the website's own tables

Switch to `hotelpardise_website` in the left-hand list, then paste
`database/website_sql/01_WEBSITE_INTEGRATION_SCHEMA.sql`.

One table, `website_settings`. The menu and the orders are deliberately **not**
here: they live in `hotelpardise_system` with the rest of the hotel, so the dish
the guest reads, the order the kitchen receives and the row the till settles can
never be three different versions of the same thing.

## Step 6 — tell the site where the database is

`backend-php/config.php` is never committed, because it holds the passwords. You
must create it on the server yourself. Copy it across, then change:

- `port` — on most hosts leave this empty. This machine's XAMPP uses `3307`
  only because MariaDB already holds `3306` here.
- the database and user names, if your host prefixes them
- the two passwords, to the ones from your hosting panel

`host` stays `127.0.0.1` on almost all shared hosting. If your panel gives you a
MySQL hostname such as `mysql.yourhosting.com`, use that instead.

## Step 7 — check it works

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

`"menu_items"` of 81 under `hotel` on the health page, and 15 sections in the
menu response, means the database is installed correctly. If that number is
small, `database/07_FULL_MENU_SEED.sql` has not been run, or was run before the
schema gained the `published` column.

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

**`#1062 Duplicate entry 'hotel-paradise-on-the-nile' for key 'slug'`.**
The seed is being pasted into a database that already has the hotel in it. The
error is the seed doing its job, not a fault to be worked round.

Two things cause it, and they need opposite answers:

- *The site is already installed.* Stop. Nothing is broken. Run
  `php tools/install-databases.php --check`, and if it says the site is
  installed correctly, you are done. Do not run the seed.
- *You are installing onto a database that is not empty*, because it is left
  over from an earlier attempt or a different project. Either drop it and start
  again from step 0, or point the site at it deliberately.

**Do not delete the duplicate row to get past this.** `rooms`, `guests`,
`suppliers`, `reservation_rooms` and `payments` have no unique key, so once the
first statement is removed the rest of the seed is inserted alongside the rows
already there and the database ends up with 138 rooms, two of every guest and
two of every supplier. There is no error to stop it, because nothing about it
is wrong as far as MySQL is concerned. Step 0 exists to catch this before that
happens rather than after.

**A file that says `USE hotel_paradise_nile;`.** That is the original database
name, and it is wrong. Anything under `database/system_sql/` is archived and
must not be run; the live install files are the four in `database/`, and they
all say `USE hotelpardise_system;`. If phpMyAdmin is pointed at
`hotel_paradise_nile`, you are in a database the application never connects to,
and the seed will collide with itself there.

**Everything looks right but the menu is empty.** Check
`published_sections` from step 4. If it is 0, step 4 did not run against the
database you are looking at.

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

If the site is *already* installed correctly, none of this is needed. Run this
and stop:

```
C:\xampp\php\php.exe tools\install-databases.php --check
```

It changes nothing and reports whether both databases open with the passwords in
`config.php`. On a correctly installed XAMPP copy it answers *"the site is
installed correctly: both databases open, both accounts work"*, and the accounts
`hotelpardise_system` and `hotelpardise_website` already exist for both
`@localhost` and `@127.0.0.1` with every grant below already applied. Running
`database/system_sql/00_CREATE_DATABASE_USERS.sql` by hand in that situation
achieves nothing, and if its placeholders have not been replaced it actively
breaks the site by setting both passwords to the placeholder text.

**The management system will not sign in, and the health page is `"ok":true`.**
The database is fine and the problem is a password or a role, not a connection.
`--check` will say so explicitly.
