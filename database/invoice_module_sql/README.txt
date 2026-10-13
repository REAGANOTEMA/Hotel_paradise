Hotel Paradise on the Nile — Invoice & Pesapal module (RES-PESA-INV)
=====================================================================

WHAT THIS MODULE IS
-------------------
A hotel invoicing and online-payment engine. It turns work the hotel already
does (reservations, menu orders, front-desk charges) into numbered, printable
invoices that a guest can settle online through Pesapal, or at the desk, with a
quiet audit trail on every invoice: issue, void, discount, adjust.

Where it lives
--------------
  database/invoice_module_sql/        SQL for the MAIN system database
  backend-php/app/invoices.php        PHP engine (helpers, no pages)
  backend-php/modules/invoices.php    console page (issue / void / discount / pay)
  backend-php/api.php                 guest-facing endpoints (checkout, Pesapal)
  frontend-react/src/pay.tsx          the guest's pay page (already shipped)

Installation order
------------------
1. Run the three SQL files against the MAIN system database, in number order.
   The files carry no USE statement, so first CONNECT and select the database
   you are installing into. They use plain MariaDB DDL (ADD COLUMN IF NOT EXISTS
   / CREATE INDEX IF NOT EXISTS), so they run from the phpMyAdmin SQL box, the
   Import tab, or the mysql command line, and each one is safe to re-run.
       01_invoice_module_schema.sql      add columns + invoice_events table
       02_invoice_module_indexes.sql     the indexes the lookups lean on
       03_invoice_module_seed_data.sql   intentionally empty (see that file)
   Use phpMyAdmin (SQL box or Import while the database is selected) or:
     C:\xampp\mysql\bin\mysql.exe -u root -p hotelpardise_system < 01_invoice_module_schema.sql

2. Nothing else needs installing — the PHP layer detects the new columns the
   same way the rest of the codebase detects schema upgrades (hp_column_exists /
   hp_table_exists), so the console page and the pay page work before, during and
   after the SQL.

RULES THIS MODULE MUST NOT BREAK
--------------------------------
  * No payment is ever marked successful unless the SERVER has verified it with
    the payment gateway. The guest's browser never decides that.
  * Payment records are idempotent: a checkout_token is minted once per attempt
    and kept UNIQUE, so a doubled tap can never double-charge a guest.
  * No secret lives in client-side code. Gateway keys, credentials and secrets
    belong to the server only.
  * Every issue, void, discount and adjust is written to invoice_events by the
    logged-in user who performed it, before the invoice is shown again.
  * Payments always run against the Pesapal SANDBOX until the hotel switches the
    sandbox flag off in backend-php/app/invoices.php.
  * The SQL never drops, truncates or rewrites existing tables or rows.

How a payment flows
-------------------
  1. Guest taps Pay on pay.html?src=invoice&ref=INV-xxxx.
  2. The server reads the invoice, computes the balance still due from
     successful payments only, and mints a checkout_token (idempotent).
  3. The server registers a pending payment with Pesapal and returns the
     redirect URL. The browser is sent there.
  4. Pesapal calls the server's IPN/callback; the server contacts Pesapal back
     to verify the transaction before it writes successful to the payment row.
  5. Back on the hotel site, the pay page shows the server's own status.

Numbering
---------
Invoice numbers come from next_number() against a counter (the same scheme the
rest of the hotel uses), so INV-000123 follows INV-000122 with no gaps and no
collisions, even when two desks issue at the same moment.
