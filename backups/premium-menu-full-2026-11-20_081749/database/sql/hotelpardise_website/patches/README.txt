Hotel Paradise on the Nile
Website database patches (hotelpardise_website)
===============================================

Everything in this folder is a patch for the WEBSITE database
(hotelpardise_website) ONLY. The management system lives in the main database
(hotelpardise_system); its patches are in ../../patches/.

The full website schema is installed from ../hotelpardise_website.sql. That
dump is the clean baseline. Every change after it is shipped here as a dated
patch, so an existing install can be brought up to date without re-importing.

Patches
-------
2026-10-25_website_tables.sql
    Makes sure the three website tables exist (website_settings,
    website_booking_requests, website_enquiries), that each id can take the
    next row, and that the contact details a page reads are seeded without
    overwriting a value the hotel has edited. The management system's health
    check opens this database, so the tables should be present even when the
    website itself is served as static pages.

How to run one
--------------
phpMyAdmin: open the website database, "Import", choose the .sql file, then Go.

Command line (XAMPP on Windows):

    C:\xampp\mysql\bin\mysql.exe -u <user> -p hotelpardise_website < <patch>.sql

Each patch is written to be safe to run more than once: it checks what is
already there before it changes anything, so a second run is a no-op.
