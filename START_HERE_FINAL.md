# HOTEL PARADISE ON THE NILE — FINAL REPAIRED PACKAGE

## XAMPP
Place this folder at:
`C:\xampp\htdocs\Hotel_paradise`

Website:
`http://localhost/Hotel_paradise/`

System:
`http://localhost/Hotel_paradise/backend-php/`

## Databases
System: `hotelpardise_system`
Website: `hotelpardise_website`

## SQL order
1. `database/system_sql/00_CREATE_DATABASE_USERS.sql` (optional if MySQL users already exist)
2. `database/system_sql/FINAL_INSTALL_SYSTEM.sql`
3. `database/website_sql/FINAL_INSTALL_WEBSITE.sql`

## Initial system account
Email: `staff@hotelparadiseonthenile.info`
Password: use the password supplied for the initial staff account.

The account is assigned all current application roles for initial setup. Change the password
immediately after first login in a real deployment.

## Important
The package was syntax-checked for PHP. Full runtime verification requires running Apache,
PHP, MySQL/MariaDB and the supplied credentials on the target machine.
