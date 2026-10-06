# Hotel Paradise on the Nile — Final System Delivery

**Designed by Reagansoft Innovation Limited**  
Hotel: Hotel Paradise on the Nile  
Location: Jinja, Uganda

## Architecture
- **PHP + MySQL**: core hotel API, authentication boundary, reservations, rooms, guests, POS, finance and audit workflows.
- **React + TypeScript**: responsive owner/director and department dashboards, desktop/tablet/mobile navigation.
- **Python + FastAPI**: integration adapter for approved payment gateways and official URA EFRIS integration. It does not bypass a payment provider or URA requirements.
- **PWA/mobile-ready frontend**: the React interface is responsive and can be packaged as a PWA/native shell later.

## Database
**There is no SQL in this folder any more.** `database/INSTALL.sql`,
`database/seed.sql` and `database/modules/*.sql` have been removed, so nothing
here can be run against a database. The blueprint is documentation and
reference only: the live site is installed from the two dumps under
`database/sql/` at the project root.

## Frontend
```bash
cd frontend
npm install
npm run dev
```

## PHP API
Copy `backend/config/env.example.php` to `backend/config/env.php`, set credentials, then:
```bash
php -S 127.0.0.1:8080 -t backend/public
```

## Python integration service
```bash
cd python-services
python -m venv .venv
# Windows: .venv\Scripts\activate
# Linux/macOS: source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload --port 8090
```

## Dashboards included in the architecture
Owners, Directors, Reception, Reservations, Rooms, Housekeeping, Restaurant, Kitchen, Bar, Room Service, Swimming Pool, Spa, Laundry, Store, Inventory, Procurement, Maintenance, Events/Conference, Transport, Finance, Cashier, Accounting, Auditor, HR, POS, Communication, System Administration.

## Important privacy/security boundary
Reception voice notes must be **visible, consent-based recordings** with a retention policy and access controls. The system should not secretly record staff or guests without appropriate notice/consent and legal basis.

## Payment/EFRIS
The integration service is an adapter boundary. Add the credentials and provider-specific implementation only after the hotel has the required merchant/payment and URA/EFRIS access. Do not attempt to bypass providers or fiscal controls.

## Production checklist
TLS, secure secrets, backups, least-privilege roles, owner approval for refunds/voids, audit logging, device/session management, 2FA, EFRIS certification/configuration, payment provider certification, and UAT with the hotel before go-live.
