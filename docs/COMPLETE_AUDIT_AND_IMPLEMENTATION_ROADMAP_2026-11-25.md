# HOTEL PARADISE ON THE NILE — COMPLETE AUDIT AND IMPLEMENTATION ROADMAP

Date: 2026-11-25  
Scope: `C:\xampp\htdocs\Hotel_paradise`  
Method: read-only static inspection of source, built assets, SQL dumps, PHP modules, docs and local logs. No dev server was started and no database command was executed during the audit.

## 0. Preservation position

Nothing in this audit authorises deleting existing pages, sections, dashboards, modules, components, records, configurations or credentials. The platform already contains substantial work. Every recommendation below is additive or a targeted repair. SQL changes must be new migration files under `database/sql/patches/`; the main dumps must not be edited.

## 1. Complete public website inventory

| Page / route | Source | Deployed shell | Sections and functionality | Hero / approved imagery | Notes |
|---|---|---|---|---|---|
| Home | `frontend-react/src/main.tsx` | `index.html` | Cinematic hero carousel, availability search, welcome, featured rooms, dining, facilities, testimonials, offers, location, footer; booking links to rooms/pay | `images/hero/pool-1920.webp`, `view-1920.webp`, `bed-suite-1920.webp`, `hotel-1920.webp`, Jinja night bridge, food and breakfast frames | Design intent is Playfair Display + Inter, navy/gold/ivory |
| Rooms | `frontend-react/src/rooms.tsx` | `rooms.html` | Room catalogue, filters/tabs, galleries, rates, facilities, booking handoff | `images/rooms/**`, `images/beds-*/*`, `images/DSC_5418-768x512.webp` | One manifest path mismatch for Family Room |
| Menu / dining | `frontend-react/src/menu.tsx` | `menu.html` | Categories, search, dish detail, tray, order submission, account gating | `images/dishes/**`, `images/food/**`, approved food hero frames | Visible replacement-character defect at `menu.tsx:1328` |
| Pay | `frontend-react/src/pay.tsx` | `pay.html` | Signed quote, currency selection, Pesapal handoff, status polling, receipt/print | Brand-led editorial layout | Settlement safety is environment-dependent |
| Account | `frontend-react/src/account.tsx` | `account.html` | Sign in/up, Google sign-in boundary, profile, activity, avatar, preferences | Brand-led layout | Google sign-in requires client ID |
| Events | `frontend-react/src/events.tsx` | `events.html` | Event enquiry form, event presentations, API submission | Approved conference/wedding imagery | Labels need programmatic association |
| Facilities | `frontend-react/src/facilities.tsx` | `facilities.html` | Facility enquiry form, facility cards, API submission | `images/facilities/**`, pool hero | Labels need programmatic association |
| News | `frontend-react/src/news.tsx` | `news.html` | Published articles, reactions, comments, category filters, visitor identity | Approved site/news imagery | Tab semantics incomplete |
| Talk to us | `frontend-react/src/talk.tsx` | `talk.html` | Guest messages, testimonials, rating picker, API submission | Editorial split | Tab/rating semantics incomplete |
| Privacy | `frontend-react/src/privacy.tsx` | `privacy.html` | Legal content | Editorial legal intro | Consistent print/typography present in source |
| Terms | `frontend-react/src/terms.tsx` | `terms.html` | Legal content | Editorial legal intro | Consistent print/typography present in source |
| Cookies | `frontend-react/src/cookies.tsx` | `cookies.html` | Cookie policy | Editorial legal intro | Consistent print/typography present in source |
| Offline | `frontend-react/public/offline.html` | `offline.html` | PWA offline shell | Logo/brand | Service worker version `hpn-2026-18-video-range-fix` |
| Management system link | `frontend-react/src/shared.tsx` | all pages | Links to `backend-php/index.php?page=dashboard` | Shared logo | Navigation preserved |
| QR landing | `qr/index.html` | `qr/` | QR entry point | Logo | Not part of main React route set |

Shared components: `shared.tsx`, `SmartImage.tsx`, `menuData.ts`, `buttonShake.ts`. Shared styling: `frontend-react/src/styles.css` (3,294 lines). The source already defines Playfair Display headings, Inter body/controls, `--hp-gold`, `--hp-navy`, `--hp-ivory`, `--paper`, responsive breakpoints at 1120/900/640/390px, print styles and reduced-motion support.

### Hero image preservation

Approved hero images already in use must remain the first choice: `pool-1920.webp`, `view-1920.webp`, `bed-suite-1920.webp`, `hotel-1920.webp`, `jinja-main-bridge-view-from-hotel-at-night.webp`, `food-pizza-two-1920.webp`, `food-breakfast-1920.webp`, `bed-executive-1920.webp`, `pork-bbq.webp`, and `hotel-view-poster.jpg`. No unrelated or generated replacement photographs are required.

## 2. Management system inventory

Entry point: `backend-php/index.php`. Routing, login, CSRF, role checks and module loading are centralised there. Helpers live in `backend-php/app/`; 41 modules live in `backend-php/modules/`.

Present modules: dashboard, overview, analytics, integrity, reservations, frontdesk, rooms, guests, news, events, messages, guest_relations, testimonials, restaurant, bar, pos, fnb, kitchen, kds, room_service, shifts, housekeeping, maintenance, inventory, suppliers, purchases, cashier, accountant, auditor, finance, invoices, expenses, approvals, reports, audit, security, users, hr, notifications, trash, profile.

### Department coverage already implemented

- **PMS / front office:** reservations, room allocation, check-in/out, transfers, upgrades, early/late requests, extensions, cancellation and refund authorization, deposits, folios, registration-card printing, live arrival/departure lists, occupancy, requests and shift handovers.
- **Restaurant / F&B:** POS, menu sync, table/outlet ordering, waiter order flow, bar, restaurant dashboard, KDS, room service, bill handling, receipts and daily sales reporting.
- **Kitchen:** live KDS feed, station routing, preparation statuses, bump/recall, print queue and kitchen tickets.
- **Housekeeping:** cleaning board, task lifecycle, checklists, stock/linen, supervision, maintenance reporting and reception synchronisation.
- **Inventory / stores:** stock, suppliers, purchases, requisitions, movements, expiry and valuation workflows.
- **Finance:** cashier/accountant/auditor workspaces, journals, trial balance, income statement, balance sheet, period close, bank reconciliation, invoices, expenses, approvals and audit trail.
- **Executive:** owner/director/GM overview, ADR, RevPAR, occupancy, revenue mix, departmental performance and CSV export.
- **HR:** staff records, schedules, attendance/clocking, payroll runs, training, discipline, documents and approvals.
- **Guest relations:** preferences, loyalty accounts, awards/redemption, follow-ups and feedback.
- **Security:** role-gated pages, login history, failed sign-ins, sensitive-action approval queue, audit export, lost property and activity logs.

## 3. Database and integration state

- `database/sql/hotelpardise_system/hotelpardise_system.sql`: 150 tables.
- `database/sql/hotelpardise_website/hotelpardise_website.sql`: 54 tables.
- `database/sql/patches/` contains 5 dated patch files, but its README lists 19 older files that are no longer on disk. The current dumps already include many of those patch features. Documentation must be reconciled; dumps must not be edited.
- `tools/install-databases.php` still expects old table counts (118/45) and safely skips populated databases.
- Public API actions in `backend-php/api.php` cover rooms, booking, checkout, quotes, currencies, payment callbacks, account, menu, orders, news, reactions, comments, testimonials, guest messages, events, facilities and health.
- Pesapal is wired at the API level but keys are blank in local config; no live settlement was verified. Demo settlement currently activates when gateway keys are absent.
- EFRIS/URA is internal readiness/reporting only; no verified outbound tax API integration exists.
- Google sign-in is implemented but returns 501 without a configured client ID.
- SMTP/mailer exists; delivery was not runtime-tested.
- Python service (`python-services/main.py`) is a reference stub with health/events endpoints only.
- `expanded-system-blueprint/` is a separate reference architecture, deliberately not connected to the live schema.

## 4. Missing-feature report (A–K)

### A. Implemented and working (statically verified)

1. Login with CSRF, password verification, session regeneration, login audit and failed-login logging.
2. Role-gated module loading through `page_caps()` / `page_allowed()`; 41 whitelisted pages.
3. Reservations, rooms, guests and front office workflows with real SQL writes.
4. Restaurant POS, bar, kitchen/KDS and room-service workflows.
5. Housekeeping, maintenance, inventory, suppliers and purchases.
6. Cashier, accountant, auditor, finance, invoices, expenses, approvals, reports and audit trail.
7. HR, guest relations, security, analytics, notifications and web push.
8. Public website pages, shared branding, PWA assets, API action coverage and print CSS.
9. CSV, PDF and print output in several modules.

### B. Implemented but not fully functional / needs verification

1. **New reservation guest entry:** existing-guest selection is mandatory in the UI even though new guest fields exist. Unnamed clients cannot be created. This is the user-reported P0 bug.
2. **Reservation search:** only guest name and booking number are searched; phone/email/ID are not searchable, so provisional guests are hard to find.
3. **Guest edit:** `guests.php:12` does not update `full_name`, so a provisional name cannot be corrected.
4. **POS order creation:** `modules/pos.php:103` requires `app/kds.php` from the wrong directory (`modules/app/kds.php`), likely fatal on order creation.
5. **Public orders to KDS:** `api.php` order action does not visibly call `kds_sync_order()`; web orders may not reach the kitchen display.
6. **Occupancy reporting:** grouped by `DATE(check_in)` rather than stay-nights; ADR/RevPAR exist but nightly occupancy accuracy needs review.
7. **Payment settlement:** demo settlement is active when Pesapal keys are absent; production behaviour must be explicitly controlled.
8. **Notification API:** no CSRF validation on JSON POST endpoints.
9. **Dashboard guest labels:** blank `full_name` values render as empty across several screens.

### C. Exists visually but disconnected / hard to reach

1. `kds` and `room_service` are allowed by permissions but absent from the sidebar navigation.
2. `services` / `settings` pages referenced in older docs do not exist; no module named `settings.php` is present.
3. Expanded blueprint dashboards and Python services are not connected to live data.
4. Some public form labels are not programmatically associated with controls.
5. Talk/news/menu tab patterns are incomplete ARIA tabs.
6. Home hero has dots but no explicit pause/arrow controls.

### D. Important missing hotel modules or gaps

1. No editable role-permission matrix UI; `page_caps()` is the single hard-coded source of truth.
2. No dedicated newsletter/campaign subscriber module; only a `marketing_opt_in` profile field exists.
3. No unified print/PDF pack spanning registration card, folio, rota, KDS ticket, inventory valuation and audit.
4. No bank-feed import integration; reconciliation is manual.
5. No verified tax/EFRIS submission path.
6. No dedicated group/corporate booking workspace beyond notes and general reservations.
7. No dedicated room-inventory calendar UI; availability is inferred from room statuses and reservations.

### E. Missing integrations

1. Pesapal live credentials and verified callback/IPN in production.
2. URA/EFRIS official credentials and API specification.
3. Google Identity client ID for public sign-in.
4. SMTP delivery verification.
5. Bank feed / reconciliation import.
6. Python event/analytics bridge (currently reference only).

### F. Missing security features / hardening

1. CSRF on `notify_api.php` POST endpoints.
2. Explicit session cookie policy (`SameSite`, `Secure`, `HttpOnly`) review.
3. MIME revalidation on downloads; profile image validation is extension-only.
4. Local plaintext config/VAPID material and error logs must never be deployed.
5. `tools/set-password.php` accepts the password as a CLI argument; interactive input would be safer.

### G. Missing operational workflows

1. Provisional/unnamed guest creation and later naming.
2. Reservation search by phone/email/ID.
3. Public web-order KDS synchronisation verification.
4. End-to-end check-in → housekeeping → reception state verification.
5. Financial period close approval evidence and audit pack.
6. Unified department-head dashboard links for every allowed department.

### H. Missing reports and financial controls

1. Accurate stay-night occupancy report.
2. Unified operational/export pack with PDF and Excel-friendly CSV.
3. Department-head performance dashboard for every department.
4. Verified bank reconciliation import and EFRIS submission status.
5. Explicit production flag for demo payment settlement.

### I. Missing premium design elements

1. Root deployment uses stale assets; the editorial redesign exists in `frontend-react/dist` but not in root `assets/`.
2. `docs/PUBLIC_SITE_DESIGN_AUDIT_AND_PLAN.md` is stale and names classes not implemented.
3. Family Room manifest path mismatch (`dsc-5418-768x512` vs `DSC_5418-768x512`).
4. Menu replacement character at `frontend-react/src/menu.tsx:1328`.
5. Form-label and tab-semantics accessibility polish.

### J. Missing mobile functionality

1. Source has responsive CSS, but stale root assets prevent mobile users from receiving it.
2. Touch targets and label associations need verification after assets are deployed.
3. No runtime mobile pass was performed in this audit.

### K. Automation opportunities

1. Deploy build assets through a repeatable script instead of manual copying.
2. Add a static preflight check for manifest image paths.
3. Add PHP lint to CI for all modules/app files.
4. Add API action coverage test for public actions.
5. Add database patch inventory check so docs cannot drift from disk again.

## 5. Prioritised implementation roadmap

### Stage 0 — report and preservation baseline (complete)

This document is the requested audit and roadmap. No destructive change was made.

### Stage 1 — P0 repairs (do now)

1. Remove mandatory existing-guest selection from New reservation; allow new clients with no name; assign a provisional `Guest #ID` label automatically so every dashboard remains readable.
2. Allow the provisional guest name to be corrected later in the guest registry, and update `full_name` on edit.
3. Add phone/email/ID to reservation search.
4. Fix `modules/pos.php:103` KDS include path.
5. Add CSRF validation to `notify_api.php` and send the token from the notification UI.
6. Rebuild and deploy current `frontend-react/dist/assets` to root `assets/` without deleting the extra root logo file.
7. Fix Family Room image manifest path and menu replacement character.
8. Verify with PHP lint, TypeScript typecheck and static checks.

### Stage 2 — dashboard and department integrity

1. Add `kds` and `room_service` to navigation for allowed roles.
2. Verify all role gates against `page_caps()` and test each department login.
3. Add explicit production flag for demo payment settlement, defaulting safely for live deployment while preserving local development.
4. Reconcile patch README, installer table counts and audit docs with current dumps.
5. Add stay-night occupancy reporting.

### Stage 3 — operational completeness

1. Verify public order → KDS synchronisation.
2. Add group/corporate booking fields/workflow.
3. Add role-permission matrix view.
4. Add unified print/PDF pack.
5. Add newsletter/campaign module only if an approved email provider is configured.

### Stage 4 — integrations and production readiness

1. Configure and verify Pesapal with real credentials.
2. Configure and verify Google Identity.
3. Configure and verify SMTP.
4. Obtain URA/EFRIS specification and implement real submission with audit records.
5. Configure bank feed import if the hotel provides an approved source.

### Stage 5 — final page-by-page inspection

Inspect every public page and every dashboard at desktop, tablet and mobile widths; verify links, forms, images, labels, keyboard access, print output and no horizontal overflow. Produce a final verified report with remaining external dependencies.

## 6. Immediate implementation decision

The user-reported room/client problem is in `backend-php/modules/reservations.php`, not `rooms.php`. The next safe increment is to remove the existing-guest dropdown requirement entirely, always create a new guest record from the form, allow the name field to be blank, generate a readable provisional label when no name is supplied, allow later renaming in `guests.php`, and make reservation search find provisional guests by their other details. This requires no SQL migration and preserves all existing reservation, check-in, folio and room-status workflows.
