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
2026-10-10_events_enquiries.sql
    Creates event_requests and facility_enquiries, the two tables behind the
    website's "Plan an event" and "Facilities" forms and the console's Events &
    Enquiries screen. Also adds columns an older partial copy may be missing.

2026-10-10_perf-indexes.sql
    Performance indexes for the console and the website API: payments by order,
    reservation or customer; reservations by status and by check-in/check-out;
    orders by status, outlet or day; guests by email or phone; the audit trail
    by entity or day; expenses and active inventory. The requisition index lives
    in the procurement patch because that table may not exist yet.

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

2026-10-12_guest_messages.sql
    Creates guest_messages, the one table behind Guest Messages and Guest
    Experiences, and adds the indexes the inbox reads. An older partial table
    gains the columns it is missing.

2026-10-13_soft_delete_columns.sql
    Makes sure every table the console lists or trashes carries deleted_at and
    deleted_by. A few of those tables are built by the modules themselves on
    first use, and the earliest installs were made before the pair was part of
    that definition, which left some lists failing with
    "Unknown column 'deleted_at' in 'where clause'". The console repairs the
    column on its own when it is missing, and this patch is the same repair made
    explicit for anyone who would rather run it by hand. The two procurement
    tables are handled by the procurement patch.

2026-10-14_customer_accounts.sql
    Creates customers, customer_tokens, customer_addresses, customer_documents
    and customer_signin_attempts, so a guest can create an account on the
    website, sign in, keep addresses and documents, and reset a password. The
    API guards the missing table, but this is the explicit repair.

2026-10-15_pesapal_gateway_fields.sql
    Adds the Pesapal fields to the payments table that an earlier install may
    be missing: checkout_token (unique, one per checkout), verified_at (the
    server-owned confirmation stamp), gateway_result (the raw status body Pesapal
    returned) and payer_phone, plus the provider_reference index. The API guards
    each of these, so a missing column only loses the gateway detail rather than
    failing; this patch makes them explicit. Run it once the Pesapal merchant
    keys are filled in, so every online payment stores its full trail.

2026-10-16_notifications_push.sql
    Creates the five notification tables: notification_events,
    notification_deliveries, notifications, notification_devices and
    notification_preferences. Without them the header bell and the
    Notifications page report that the upgrade is not installed.

2026-10-17_invoice_module.sql
    Creates invoices, invoice_items and invoice_events, and adds
    payments.invoice_id, so the billing desk can issue, void and settle an
    invoice. Without it the Invoices page shows "Invoicing upgrade not
    installed".

2026-10-25_seed_data_repair.sql
    Repairs the room types copied nine times in the baseline dump (ids 1-63 for
    seven names). Remaps every room and reservation allocation to the canonical
    copy (the one the physical rooms use, ids 57-63), removes the duplicate
    allocations and the eight extra copies of each type, then marks rooms
    occupied for checked-in bookings and reserved for current or future
    confirmed/pending bookings. Without it the rate editor lists 63 room types
    and the dashboard repeats the in-house guest once per duplicate copy.

2026-10-25_procurement_repairs.sql
    Creates any of the four procurement tables an early install is missing
    (purchase_requisitions, purchase_requisition_items, purchase_orders,
    purchase_order_items) and adds the later columns the Approvals, Purchases
    and Inventory screens read, including inventory unit/code and payments.user_id.
    It also makes sure each id can take the next row and adds the queue indexes.
    Approvals now guards each queue, so a missing table no longer turns the page
    into a 500; this patch is the explicit repair for anyone who would rather
    run it by hand.

2026-10-26_role_seed_repair.sql
    Adds any role name the console uses but the roles table is missing, such as
    bar_staff, inventory_manager or human_resource. It never changes user_roles,
    so nobody gains a duty.

2026-10-26_user_password_repair.sql
    Repairs the seeded team accounts whose password hash did not match the
    documented seed password, including four accounts that carried a 48-
    character value that is not a valid bcrypt hash at all. Only the known seed
    hash, the broken value, and missing or invalid hashes are touched, so a
    password a member has already changed is never overwritten. The repaired
    accounts sign in with Paradise2026 and should change it from My Profile.

How to run one
--------------
phpMyAdmin: open the system database, "Import", choose the .sql file, then Go.

Command line (XAMPP on Windows):

    C:\xampp\mysql\bin\mysql.exe -u <user> -p hotelpardise_system < <patch>.sql

Each patch is written to be safe to run more than once: it checks what is
already there before it changes anything, so a second run is a no-op.

Why the patches no longer use stored procedures
-----------------------------------------------
The earlier versions created a temporary procedure and asked
information_schema which columns and indexes existed. Shared hosting often
grants an account only its own database, and some hosts deny both CREATE ROUTINE
and access to information_schema. That produced:

    #1044 - Access denied for user ... to database 'information_schema'

These patches now use MariaDB's own IF NOT EXISTS / IF EXISTS clauses
(ALTER TABLE ... ADD COLUMN IF NOT EXISTS, ADD INDEX IF NOT EXISTS,
DROP INDEX IF EXISTS) and verify with SHOW COLUMNS / SHOW INDEX. Neither needs a
stored procedure and neither opens information_schema. XAMPP ships MariaDB
10.4, which supports all of them.

If your host runs MySQL rather than MariaDB and refuses an IF NOT EXISTS clause,
ask the host to run the patch, or use the one-command installer on a machine you
control. Do not re-add the procedure form: it is what caused the information_schema
error in the first place.
