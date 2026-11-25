# Hotel Paradise on the Nile — Complete Enterprise Audit & Implementation Roadmap

**Audit date:** 25 November 2026
**Scope:** Public website, PHP management console, React source, SQL schema and patches, integrations, assets, security, reporting and responsiveness.
**Method:** Static inspection of the repository only. No development server was started, no live database was queried, and no destructive command was run. Findings below describe what the code is written to do; anything requiring live credentials is marked as unverified.

---

## 1. Architecture confirmed

| Area | Reality found |
|---|---|
| Public website | Deployed React/Vite output in root `*.html` + `assets/*.js`; source in `frontend-react/src/`. Multi-page build configured in `frontend-react/vite.config.ts`. |
| Management system | Server-rendered PHP, not React. Entry `backend-php/index.php`, router allowlist from `page_caps()`, modules loaded from `backend-php/modules/*.php`. |
| `system/` | Thin redirect to the PHP console login. `management-system.html` is a redirect shell. |
| Database | Two MySQL databases: `hotelpardise_system` (118 tables, operations) and `hotelpardise_website` (45 tables, website settings). Baseline dumps in `database/sql/`, additive patches in `database/sql/patches/`. |
| APIs | `backend-php/api.php` (public JSON), `backend-php/notify_api.php` (staff notifications), `backend-php/download.php` (auth-gated files). |
| Config/secrets | `backend-php/config.php`, `backend-php/vapid.php`, `backend-php/storage/pesapal.json` are gitignored and untracked. They were not read or changed. |
| Reference only | `expanded-system-blueprint/` and `python-services/main.py` are scaffolding/stubs, not the live platform. Do not treat them as implemented features. |

---

## 2. Phase Two — Missing-features report

Priority key: **P0** business-critical / risk, **P1** high, **P2** medium, **P3** polish.

### A. Features already implemented and working (code-verified)

1. **Public website (P0, working)**
   - Home, Rooms, Menu, Pay, Account, Events, Facilities, News, Talk to us, Terms, Privacy, Cookies, offline fallback: `index.html`, `rooms.html`, `menu.html`, `pay.html`, `account.html`, `events.html`, `facilities.html`, `news.html`, `talk.html`, `terms.html`, `privacy.html`, `cookies.html`, `offline.html`.
   - Live API calls confirmed in `frontend-react/src/`: `rooms.tsx` (`rooms`, `booking`, `account`), `menu.tsx` (`menu`, `order`), `pay.tsx` (`currencies`, `checkout`, `quote`, `payment`), `account.tsx` (`account`, `avatar`), `events.tsx` (`event`), `facilities.tsx` (`facility`), `news.tsx` (`news`, `news_react`, `news_comment`), `talk.tsx` (`testimonials`, `guest_message`).
   - PWA shell: `manifest.webmanifest`, `sw.js`, icons, `offline.html`. Service worker correctly skips API and media range requests.
   - Strong responsive CSS and accessibility primitives: `frontend-react/src/styles.css`, `shared.tsx`, `talk.tsx`.

2. **Management console (P0, working)**
   - Session login, role loading, module allowlist, CSRF on every POST, page permission checks: `backend-php/index.php:191-218`, `backend-php/app/bootstrap.php:605-664`.
   - Password hashing verified at login (`password_verify`), audit trail on login/logout.
   - 34 departmental modules present: reservations, rooms, guests, POS, cashier, shifts, inventory, suppliers, purchases, expenses, finance, approvals, audit, reports, users, accountant, auditor, invoices, kds, kitchen, restaurant, bar, room service, news, events, messages, testimonials, notifications, profile, trash, overview, integrity, dashboard.
   - Real CRUD found in the modules above; not just static screens.

3. **PMS core (P0, working)**
   - Reservations creation, status lifecycle (pending → confirmed → checked_in → checked_out), automatic room allocation, room release to dirty on checkout, folio charges and payments, no-show/cancel states: `backend-php/modules/reservations.php:33-148`.
   - Room types, tariff editing, status board, floor grouping, room status changes and out-of-service notifications: `backend-php/modules/rooms.php`.
   - Guest registry with identification fields and stay counts: `backend-php/modules/guests.php`.

4. **Restaurant / F&B / KDS (P0, working)**
   - POS ordering, table/room/takeaway handling, settlement and shifts: `modules/pos.php`, `app/pos.php`.
   - KDS live feed, station routing, ticket printing/reprint, item status (queued/accepted/preparing/ready/served), priority and timers: `modules/kds.php`, `app/kds.php`, `kitchen_stations`, `kitchen_order_items`, `kds_print_queue`.
   - Restaurant, bar and room-service dashboards: `modules/restaurant.php`, `modules/bar.php`, `modules/room_service.php`, `modules/fnb.php`.
   - Receipt generation, emailing and auto-print hotel copy: `app/receipts.php`.

5. **Finance workspace (P0, working)**
   - Cashier, accountant, auditor, finance, invoices, expenses, approvals, audit trail, reports: `modules/cashier.php`, `accountant.php`, `auditor.php`, `finance.php`, `invoices.php`, `expenses.php`, `approvals.php`, `audit.php`, `reports.php` plus `app/finance.php` (65 KB).
   - Chart of accounts, journals, bank reconciliation tables, cash movements, financial periods and payment confirmation/reversal are present in schema and module code.

6. **Inventory & procurement (P1, working)**
   - Items, movements, stock levels, suppliers, requisitions, purchase orders, goods received and approvals: `modules/inventory.php`, `suppliers.php`, `purchases.php`, `approvals.php`.

7. **Reports (P1, working)**
   - Date-range operational report with bookings, room nights, occupancy, revenue by method/source, expenses by department, CSV export and print: `backend-php/modules/reports.php:6-77`.

8. **Premium design foundation (P1, working)**
   - Brand system in `docs/DESIGN_SYSTEM.md`, luxury admin CSS, collapsible nav, KPI cards, toast, assistant, voice welcome, mobile drawer, print styles.

---

### B. Features implemented but not fully functional

| Priority | Finding | Evidence |
|---|---|---|
| P0 | **Payment settlement is demo-capable.** `PAYMENT_DEMO_SETTLE = !pesapal_enabled()` means public payments can be marked `successful` when gateway keys are absent. | `backend-php/api.php` |
| P0 | **Three referenced patches are missing from disk**: `2026-10-14_customer_accounts.sql`, `2026-10-16_notifications_push.sql`, `2026-10-17_invoice_module.sql`. Code guards the missing tables, so those modules degrade rather than fail, but a clean install described in README cannot be reproduced from the patch folder alone. | `database/sql/patches/README.txt` vs folder listing |
| P0 | **Failed staff logins are not written to `login_attempts`.** Login success/failure is audited but the `login_attempts` table exists unused by console login; customer API does throttle. | `backend-php/index.php:20-42`, schema line 1730 |
| P1 | **Session ID is not regenerated on privilege change.** Session fixation hardening missing at sign-in. | `backend-php/index.php:29-34` |
| P1 | **Housekeeping is only a status dropdown plus "Shifts".** `housekeeping_tasks` table exists but no dedicated live board, checklist, linen, lost-and-found or supervisor approval screen. | `modules/rooms.php:88-96`, `modules/shifts.php` |
| P1 | **Maintenance has no module.** `maintenance_tickets`, `maintenance_assets` and `lost_property` tables exist but no console page uses them. | `page_caps()` and `nav_groups()` |
| P1 | **HR tables are mostly orphaned.** `staff_profiles`, `attendance`, `leave_requests` exist; no HR module for scheduling, payroll, training, documents or disciplinary records. | schema lines 50, 1712, 3714 |
| P1 | **Guest CRM is partial.** `guests.php` stores identity; `guest_messages`/`testimonials` collect feedback; no loyalty, preferences, follow-up, complaint or repeat-guest view. | `modules/guests.php`, `messages.php`, `testimonials.php` |
| P1 | **Occupancy uses check-in date only.** Reports count bookings by `DATE(check_in)`, not by nights within the selected period; ADR/RevPAR are absent. | `modules/reports.php:11-16` |
| P2 | **`admin.css` at repo root is empty.** All real styling is under `backend-php/assets/`. Harmless but confusing. | root `admin.css` |
| P2 | **`notify_api.php` has session checks but no CSRF check** for its POST endpoints. | `backend-php/notify_api.php` |
| P2 | **Public concierge is client-only** (speech UI, no API calls), so it cannot answer live availability or book. | `frontend-react/src/concierge.tsx` |
| P2 | **Home page has no API calls**; booking planner only forwards query values to `rooms.html`. | `frontend-react/src/main.tsx` |

---

### C. Features that exist visually but are disconnected from the backend

| Priority | Finding | Evidence |
|---|---|---|
| P1 | **Expanded blueprint dashboards are mock scaffolding.** `/api/health`, `/api/dashboard/summary`; everything else returns "Endpoint not implemented yet." | `expanded-system-blueprint/backend/routes/api.php` |
| P1 | **Python service is a stub.** Only `/health` and `/events`. | `python-services/main.py` |
| P2 | **Staff-access directory is a static mockup**, not linked to real roles. | `mockups/staff-access-directory/index.html` |
| P2 | **Root `main.tsx`, `shared.tsx`, `styles.css`, `check_js.js` are legacy source copies**; deployed shells load `assets/*.js`. Editing them has no effect until rebuilt and copied. | root `*.html` script tags vs `frontend-react/src/` |
| P2 | **Google sign-in returns 501 without client ID**, and is presented as a normal account option. | `backend-php/api.php` account/google action |

---

### D. Important missing hotel modules

| Priority | Module | What is missing today |
|---|---|---|
| P0 | Front Office operations desk | Live arrival/departure board, occupancy monitor, room allocation from one screen, early check-in / late checkout, extension, upgrade, transfer, cancellation and refund with approval, printable registration card, shift handover, outstanding-payment alerts. |
| P0 | Housekeeping operations | Live cleaning board using `housekeeping_tasks`, attendant assignment, cleaning checklist, inspection and supervisor sign-off, linen movement, lost and found, maintenance reporting, two-way room-status sync. |
| P0 | Engineering / Maintenance | Ticket register, preventive schedule, asset records, assignment, repair cost, room restriction, completion approval, history. |
| P1 | Human Resource | Staff profile view, attendance, rota, leave approval, payroll preparation, training, documents, disciplinary records with restricted access, staff announcements. |
| P1 | Guest Relations / CRM | Guest 360, preferences, loyalty points, complaints, special requests, satisfaction, birthday/anniversary, follow-up log. |
| P1 | Executive analytics | ADR, RevPAR, occupancy by night, departmental revenue, booking trend, staff/department performance, cash-flow view. Existing dashboards show KPI cards but no plotted trend or ADR/RevPAR. |
| P1 | Security & Access Control | Login history page, failed login monitoring, permission matrix view, sensitive-action authorization queue, session hardening. |
| P2 | Stores control layer | Expiry batches, stock valuation, inter-location transfers and consumption view built on existing `stock_levels`/`stock_movements`. Inventory module already covers core stock. |
| P2 | Enterprise report centre | Daily/weekly/monthly/annual packs, F&B, inventory, payroll, tax and audit exports with print/PDF and Excel-compatible CSV. Existing Reports covers only operational summary. |

---

### E. Missing integrations

| Priority | Integration | Verified status |
|---|---|---|
| P0 | Pesapal | Code present, credentials live in gitignored `storage/pesapal.json`. **Not verified**: no gateway call was made, no callback/IPN was exercised. Demo settlement is active when keys are absent — must be disabled in production. |
| P0 | URA / EFRIS | Tables `efris_transactions`, `efris_attempts`, `efris_invoices` exist. **No verified credential or approved API spec found.** Do not claim live tax integration. |
| P1 | Email / SMTP | `app/mailer.php` present; config is gitignored. Delivery not tested. |
| P1 | Web Push | `app/webpush.php`, VAPID config and device tables present; returns 503 if schema missing. Not verified on a device. |
| P1 | Google Identity | Returns 501 unless client ID configured. Missing credential. |
| P1 | Bank reconciliation import | Tables and UI guards exist; no bank feed/import integration verified. |
| P2 | Payment QR | `qr/` generated codes exist; no dynamic payment QR workflow connected to a live invoice. |
| P2 | Python analytics adapter | Stub only; no event publisher connected to the PHP console. |

---

### F. Missing security features

| Priority | Finding |
|---|---|
| P0 | No failed staff-login recording in `login_attempts`; no lockout or alerting for staff accounts. |
| P0 | Sensitive operations (refund, discount, cancellation, upgrade, payroll approval, disciplinary action) have no dedicated authorization record tying requester, approver, amount and reason. |
| P1 | Session ID not regenerated at privilege elevation. |
| P1 | `notify_api.php` POSTs lack CSRF verification. |
| P1 | `tools/set-password.php` takes the password as a CLI argument (visible in process list/history). |
| P1 | Upload validation is inconsistent: `modules/profile.php` checks extension only; `modules/overview.php` accepts audio by extension; `download.php` serves a client-supplied MIME with `nosniff` present but no server-side MIME re-validation. |
| P2 | No role-permission matrix screen; permissions exist in schema but the console relies on hard-coded `page_caps()`. |
| P2 | Error logs exist in the working tree (`debug_error.log`, `backend-php/php_errors.log`, `backend-php/php_fatal.log`); ensure they are excluded from deployment. |

---

### G. Missing operational workflows

| Priority | Workflow |
|---|---|
| P0 | Check-in → registration card → ID verification → room allocation → folio → checkout → inspection → room release as one visible chain. Current chain is split across Reservations, Rooms and Shifts. |
| P0 | Refund / cancellation / no-show with reason, approval and audit-linked reversal. Current status buttons have no approval or reversal record. |
| P0 | Room transfer and upgrade with rate recalculation and receipt/folio adjustment. |
| P1 | Guest request lifecycle: request → assignment → acknowledgement → completion → guest feedback. `reception_records` exists but has no desk UI. |
| P1 | Shift handover with cash count, open issues and incoming acknowledgement. |
| P1 | Housekeeping → reception synchronization: dirty → cleaning → inspected → available, driven by a task record rather than a manual dropdown. |
| P1 | Maintenance → room restriction → completion approval → room back in inventory. |
| P1 | Leave request → approval → rota adjustment → payroll line. |
| P2 | Preventive maintenance due-date generation. |
| P2 | Loyalty accrual on stay completion and redemption history. |

---

### H. Missing reports and financial controls

| Priority | Finding |
|---|---|
| P0 | No refund register or authorization register for sensitive finance actions. |
| P1 | No ADR, RevPAR, occupancy-by-night, departmental revenue, cash-flow, budget-vs-actual or tax report. |
| P1 | No dedicated payroll, housekeeping, maintenance or inventory valuation report. |
| P1 | Export is CSV only on Reports; no dedicated print/PDF pack layout beyond ad-hoc `window.print()`. CSV opens in Excel but is not `.xlsx`. |
| P1 | Daily revenue currently sums `payments`, which can include demo-settled amounts; production settlement must be verified before relying on it. |
| P2 | Trial balance / P&L / balance sheet logic exists in `app/finance.php` but should be checked against live journals before being called production-ready. |

---

### I. Missing premium design elements

| Priority | Finding |
|---|---|
| P2 | No chart library; executive screens use KPI cards and CSS bars, not trend/area/bar charts. |
| P2 | No unified print stylesheet spanning registration cards, kitchen tickets, folios, rota and inventory valuation. |
| P2 | No 3D/tour element on room pages despite premium positioning. |
| P2 | Empty root `admin.css` suggests an unfinished stubbing point. |
| P3 | No skeleton loading states on API-driven website pages; failures fall back to static catalogue on Menu. |

---

### J. Missing mobile functionality

| Priority | Finding |
|---|---|
| P1 | Management console is responsive, but no native/mobile-first departmental screens for housekeeping, maintenance or room service staff on a phone. |
| P1 | No offline queue for housekeeping/KDS actions when Wi-Fi drops. |
| P2 | Concierge uses browser speech APIs, which behave inconsistently on iOS. |
| P2 | No push-deep-link to a specific reservation/task from a notification tap (push opens the notifications page). |

---

### K. Missing automation opportunities

| Priority | Opportunity |
|---|---|
| P0 | Auto-release room to `inspected`/`available` after supervisor verification, with reception notification. |
| P0 | Auto-create refund authorization when a cancellation refunds a settled payment. |
| P1 | Auto-create housekeeping task on checkout; auto-create maintenance ticket when a room is set `maintenance`. |
| P1 | Auto-expire reservation holds (schema exists; confirm cron/request hook). |
| P1 | Auto-accrue loyalty points on checkout and auto-flag repeat guests. |
| P1 | Auto-raise low-stock and expiry alerts. |
| P2 | Auto-generate preventive-maintenance tickets from due dates. |
| P2 | Auto-email follow-up on complaint resolution. |

---

## 3. Phase Three — Implementation roadmap

### Stage 1 — Safety foundation (P0)
1. Add dated additive migration `database/sql/patches/2026-11-25_enterprise_expansion.sql` using only `CREATE TABLE IF NOT EXISTS`; no `DROP`, `TRUNCATE`, mass `DELETE`, or change to baseline dumps.
2. Register new pages in `page_caps()` and navigation in `app/layout.php`; no existing page is removed or renamed.
3. Add session regeneration and staff failed-login recording to the existing login flow; keep hash verification and CSRF unchanged.
4. Add sensitive-action authorization records to refund/cancel/upgrade/discount workflows in the new Front Office desk.

### Stage 2 — Core operations (P0)
5. `modules/frontdesk.php`: live arrivals/departures, occupancy, outstanding balances, room allocation, registration card print, handover, extension, transfer, upgrade, cancellation/refund requests.
6. `modules/housekeeping.php`: live board, assignment, checklist, inspection, linen, lost and found, maintenance reporting, reception sync.
7. `modules/maintenance.php`: tickets, assets, preventive schedule, costs, restriction, approval, history.

### Stage 3 — People, guest and insight (P1)
8. `modules/hr.php`: profiles, attendance, rota, leave, payroll draft, training, documents, disciplinary (restricted).
9. `modules/guest_relations.php`: guest 360, preferences, loyalty, complaints, follow-ups, repeat recognition.
10. `modules/analytics.php`: occupancy, ADR, RevPAR, departmental revenue, trends, outstanding payments, CSV and print.
11. `modules/security.php`: login history, failed logins, role matrix, sensitive-action queue.

### Stage 4 — Quality and verification (P0)
12. `php -l` on all changed/new PHP files.
13. Static checks for SQL placeholders, CSRF coverage and page allowlist consistency.
14. Manual browser smoke test by the hotel team against a staging database (not run during this audit, per instruction).

### Stage 5 — External credentials and acceptance (blocked where credentials are missing)
15. Disable demo payment settlement before go-live; verify Pesapal IPN with real keys.
16. Obtain and configure URA/EFRIS credentials and approved API specification before claiming integration.
17. Configure SMTP, Google OAuth client and Web Push VAPID on the production host.
18. Acceptance test on phone and desktop, including print layouts for registration card, folio, kitchen ticket and handover sheet.

---

## 4. What will NOT be done

- No existing page, module, dashboard, component, relationship or working feature will be deleted.
- No baseline SQL dump will be edited.
- No `DROP TABLE`, `TRUNCATE`, mass `DELETE`, database reset or credential change will be executed.
- No placeholder/demo records will be inserted as a substitute for operational data; new tables start empty and fill only from real user actions.
- The blueprint and Python stub will remain reference scaffolding, not be represented as production integrations.

---

## 5. Implementation status of this roadmap

Stage 1 and Stage 2 are implemented in this pass, together with Stage 3 modules for HR, Guest Relations, Analytics and Security. Stage 4 PHP syntax verification is included. Stage 5 remains dependent on hotel-owned credentials and approvals and is explicitly not claimed as complete.
