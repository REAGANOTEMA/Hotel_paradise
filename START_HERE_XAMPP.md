# Hotel Paradise on the Nile — Start Here (XAMPP)

## 1. Copy the folder

Copy `hotelparadiseonthenile` into:

`C:\xampp\htdocs\hotelparadiseonthenile`

## 2. Start XAMPP

Start **Apache** and **MySQL**.

## 3. Install the database

From this folder:

```
C:\xampp\php\php.exe tools\install-databases.php
```

It creates both databases, both MySQL accounts and their rights, and loads the
two dumps in `database/sql/`. Add `--check` to look without changing anything.

If you would rather do it by hand in phpMyAdmin, `database/HOSTING.md` is the
same install as a list.

## 4. Open the public website

`http://localhost/hotelparadiseonthenile/`

## 5. Open the management system

You no longer need to type the long PHP path.

`http://localhost/hotelparadiseonthenile/system/`

The easy entry point redirects to the management-system login.

## 6. If you see a 404

Confirm the folder is exactly:

`C:\xampp\htdocs\hotelparadiseonthenile`

and that Apache is running.
