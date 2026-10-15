Hotel Paradise on the Nile
System database patches (hotelpardise_system)
=============================================

Everything in this folder is a patch for the MAIN system database
(hotelpardise_system) ONLY.

The hotel website's own database (hotelpardise_website) is separate. The public
menu, the takeaway order and the till all read and write the system database,
and the website database is only checked by the health check, so no website
patch is needed here.

The full schema is installed from ../hotelpardise_system/hotelpardise_system.sql.
That dump is kept as a clean baseline. Every change made after it is shipped as
its own dated patch in this folder, so an existing installation can be brought
up to date by running the patches in date order, without re-importing the whole
schema.

Patches
-------
2026-10-10_perf-indexes.sql
    Performance indexes for the console and the website API: payments by order,
    reservation or customer; reservations by status and by check-in/check-out;
    orders by status, outlet or day; guests by email or phone; the audit trail
    by entity or day; expenses and requisitions by status; active inventory.

2026-10-10_receipt_department_copies.sql
    A settled payment can now also email a receipt to the department that took
    the money and to the director. This adds the "staff" value to the receipt
    channel and widens the one-row-per-payment rule to one row per payment,
    channel and recipient.

2026-10-11_news_careers.sql
    News & Careers. Makes sure the news_posts table and its indexes are present
    and that the human_resource role exists, so Human Resource can publish
    vacancies and the employee of the month, and so the website newsroom
    (news.html, read through the API) has something to read. Also seeds a few
    opening posts with INSERT IGNORE, so an edit is never overwritten.

2026-10-13_soft_delete_columns.sql
    Makes sure every table the console lists or trashes carries deleted_at and
    deleted_by. A few of those tables are built by the modules themselves on
    first use, and the earliest installs were made before the pair was part of
    that definition, which left some lists failing with
    "Unknown column 'deleted_at' in 'where clause'". The console repairs the
    column on its own when it is missing, and this patch is the same repair made
    explicit for anyone who would rather run it by hand. It only ever adds a
    missing column and never changes a table that already has it.

2026-10-15_pesapal_gateway_fields.sql
    Adds the Pesapal fields to the payments table that an earlier install may
    be missing: checkout_token (unique, one per checkout), verified_at (the
    server-owned confirmation stamp), gateway_result (the raw status body Pesapal
    returned) and payer_phone, plus the provider_reference index. The API guards
    each of these, so a missing column only loses the gateway detail rather than
    failing; this patch makes them explicit. Run it once the Pesapal merchant
    keys are filled in, so every online payment stores its full trail.

How to run one
--------------
phpMyAdmin: open the system database, "Import", choose the .sql file, then Go.

Command line (XAMPP on Windows):

    C:\xampp\mysql\bin\mysql.exe -u <user> -p hotelpardise_system < <patch>.sql

Each patch is written to be safe to run more than once: it checks what is
already there before it changes anything, so a second run is a no-op.
