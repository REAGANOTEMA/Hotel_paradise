# HOTEL PARADISE ON THE NILE — SETTING IT UP ON XAMPP

## Where it lives

Place this folder at `C:\xampp\htdocs\Hotel_paradise`

- Website: <http://localhost/Hotel_paradise/>
- Management system: <http://localhost/Hotel_paradise/backend-php/>

## Databases

- Hotel system: `hotelpardise_system`
- Website: `hotelpardise_website`

## Install

One command, run from this folder. It creates both databases, both MySQL
accounts and their rights, and loads the two dumps in `database/sql/`, which
are the only SQL in the project:

```
C:\xampp\php\php.exe tools\install-databases.php
```

`php` is not on the PATH in a default XAMPP install, which is why the full path
is given. To check the install without changing anything:

```
C:\xampp\php\php.exe tools\install-databases.php --check
```

For hosting without a shell, `database/HOSTING.md` has the same install as a
phpMyAdmin list.

> An earlier version of this file told you to run
> `database/system_sql/FINAL_INSTALL_SYSTEM.sql`. **Do not, and you cannot:**
> that file, and every other SQL file the project used to carry, has been
> removed. The only SQL left is the two dumps under `database/sql/`, and the
> installer above is what loads them.

## Signing in

There is one sign-in page, at `http://localhost/Hotel_paradise/backend-php/`.
The public site has no login.

All 14 accounts below were verified through the actual web form, not just
against the database. Every one of them is `active` and holds the role shown.

| Email | Password | Role | Name |
|---|---|---|---|
| `admin@hotelparadiseonthenile.info` | `Admin@123` | Administrator — everything | Reagan Otema |
| `director@hotelparadiseonthenile.info` | `Paradise2026` | Director | Hotel Director |
| `gm@hotelparadiseonthenile.info` | `Paradise2026` | General Manager | General Manager |
| `accounts@hotelparadiseonthenile.info` | `Paradise2026` | Finance | Finance Officer |
| `cashier@hotelparadiseonthenile.info` | `Paradise2026` | Cashier | Cashier |
| `frontdesk@hotelparadiseonthenile.info` | `Paradise2026` | Front Desk | Front Desk Reception |
| `waiter@hotelparadiseonthenile.info` | `Paradise2026` | Waiter | Restaurant Waiter |
| `bar@hotelparadiseonthenile.info` | `Paradise2026` | Bar | Bar Staff |
| `kitchen@hotelparadiseonthenile.info` | `Paradise2026` | Kitchen | Kitchen |
| `store@hotelparadiseonthenile.info` | `Paradise2026` | Storekeeper | Storekeeper |
| `procurement@hotelparadiseonthenile.info` | `Paradise2026` | Procurement | Procurement Officer |
| `housekeeping@hotelparadiseonthenile.info` | `Paradise2026` | Housekeeping | Housekeeping |
| `auditor@hotelparadiseonthenile.info` | `Paradise2026` | Internal Auditor | Internal Auditor |
| `testkitchen@hotelparadiseonthenile.info` | `Paradise2026` | Kitchen | Test Kitchen Staff |

So: **the administrator is the only one with a different password.** Everything
else is `Paradise2026`.

`testkitchen` is a leftover from testing the kitchen module. It is a real
account with a real login and nothing distinguishes it on screen from
`kitchen`, so delete it under **Team and Users** unless you are deliberately
keeping a second kitchen login.

> An earlier version of this file named `staff@hotelparadiseonthenile.info` as
> the first account. **No such account is ever created by any seed or install
> script**, so signing in with it always failed with "Incorrect email or
> password" no matter what password was typed. The administrator above is the
> account to use.

Change passwords from **Team and Users** once signed in as the administrator.
If you are locked out before you ever get in, the console reset is no use
because it needs a session, so use the terminal instead:

```
C:\xampp\php\php.exe tools\set-password.php admin@hotelparadiseonthenile.info "NewPassword123"
```

Add `--list` to that command to print every account with its status and roles,
which is the fastest way to catch a mistyped address.

## Before going live

- Change every password, starting with the administrator's.
- Rotate both MySQL passwords. They were once committed to the repository in a
  SQL file under `database/system_sql/` (since removed), so treat them as
  known: use `ALTER USER` on `@localhost` and `@127.0.0.1`, then update
  `backend-php/config.php` to match.
- The sign-in page only prints the demo passwords when `HP_DEMO_LOGINS` is set,
  which XAMPP does locally. A hosting platform will never set it, so the live
  page shows nothing but the form.
