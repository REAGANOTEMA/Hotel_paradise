# HOTEL PARADISE ON THE NILE — WEBSITE + MANAGEMENT SYSTEM FINAL PACKAGE

Designed and built by **Reagansoft Innovation Limited**.

This package joins the uploaded Hotel Paradise on the Nile website with the existing PHP management system and keeps the hotel's shared branding/logo across both.

## LIVE WEBSITE
`frontend-react/`
- React/Vite website
- Responsive desktop/tablet/mobile design
- Luxury gold + deep navy + Nile blue visual system
- Shared Hotel Paradise on the Nile logo
- Rooms and booking flow
- Dining/menu and ordering flow
- Mobile hamburger navigation
- Uganda flag accent footer
- Reagansoft attribution
- **Management System** link in the main and mobile navigation

## LIVE MANAGEMENT SYSTEM
`backend-php/`

The website's Management System link opens:
`backend-php/index.php?page=dashboard`

Current PHP modules:
Dashboard, Reservations, Rooms, Guests, POS and Orders, Cashier Shifts, Inventory, Suppliers, Purchases, Expenses, Finance, Approvals, Audit Trail, Reports, and Users/Team.

The PHP management system uses the same Hotel Paradise on the Nile logo assets from `images/`.

## DATABASE
Two databases, both installed by one command from the project folder:

```
C:\xampp\php\php.exe tools\install-databases.php
```

| Purpose | Name |
|---|---|
| Management system | `hotelpardise_system` |
| Public website | `hotelpardise_website` |

The only SQL in the project is the pair of phpMyAdmin dumps under `database/sql/`
— one per database, each holding its schema and its data together. The installer
creates the databases, the two MySQL accounts and their grants, loads the dumps
in the only order that works, and finishes by connecting the way the site does.
Add `--check` to look at an install without changing anything.

For a host with no shell, `database/HOSTING.md` is the same install as a
phpMyAdmin list.

## EXPANDED HOTEL PLATFORM
`expanded-system-blueprint/`

This contains the broader Reagansoft architecture previously prepared for the full hotel platform, including department SQL modules, React management UI, PHP API foundation, Python service layer and documentation for Owners/Directors, Reception, Reservations, Rooms, Restaurant, Kitchen, Bar, Room Service, Swimming Pool, Spa, Housekeeping, Laundry, Store/Inventory, Procurement, Maintenance, Events, Transport, Finance, Cashier, Accounting, Auditor, HR, Communication, Notifications, POS, EFRIS integration boundary and Payment integration boundary.

**Important:** this expanded architecture is included as the next-stage platform reference. Its SQL model is different from the live PHP schema, so it is intentionally separated to prevent accidental database corruption.

## SHARED BRANDING
Luxury Gold, Deep Navy, Nile Blue, Nebula Blue, White/Ivory, plus the Ugandan black/yellow/red accent. Both website and management system use the same logo assets.

## DEPLOYMENT
For XAMPP:
1. Copy the `hotelparadiseonthenile` folder into `C:\xampp\htdocs\`.
2. Run `C:\xampp\php\php.exe tools\install-databases.php` from the project
   folder (or follow `database/HOSTING.md` in phpMyAdmin).
3. Check credentials in `backend-php/app/bootstrap.php`.
4. Open the website.
5. Select **Management System** from the website navigation.
6. Before production, change demo credentials, enable HTTPS, configure backups, and review permissions.

## PRODUCTION
Payment providers and URA/EFRIS must be connected using their official credentials/API specifications. Do not bypass payment providers or expose secrets in frontend code.

Reception/voice recording, where used, should be implemented transparently with appropriate consent, access control and retention policies.

## AUTHOR
**Reagansoft Innovation Limited**
https://reagansoftinnovation.com
