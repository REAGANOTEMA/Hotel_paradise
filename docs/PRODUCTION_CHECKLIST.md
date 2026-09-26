# PRODUCTION CHECKLIST

## Website
- SEO metadata
- OpenGraph
- schema.org hotel/room data where appropriate
- optimized WebP/AVIF images
- sitemap
- robots
- accessibility
- responsive testing
- booking conversion tracking

## Booking
- account creation/login required
- email/phone verification where enabled
- availability transaction locking
- booking expiry/hold rules
- payment verification by server webhook
- confirmation notification
- cancellation/refund rules

## POS
- unique order IDs
- cashier shifts
- terminal IDs
- immutable financial audit
- controlled discounts
- controlled voids
- refund approval
- cash reconciliation
- stock reconciliation

## Security
- HTTPS
- secure cookies
- CSRF
- rate limiting
- validation
- authorization policies
- secrets outside source code
- database backups
- restore test
- audit logging
- least privilege

## Uganda
- payment provider integration tested
- URA/EFRIS integration tested against current official specification
- fiscal identifiers stored securely
- invoice/receipt workflow validated
- tax configuration reviewed by hotel/accounting team
