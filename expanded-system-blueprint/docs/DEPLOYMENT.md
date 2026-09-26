# Deployment

1. Create MySQL database and run `database/INSTALL.sql`.
2. Run `database/seed.sql`.
3. Configure PHP DB credentials.
4. Build React frontend and serve it behind HTTPS.
5. Run PHP API behind the same domain or `/api`.
6. Run Python adapter as an internal service, protected by network policy and secrets.
7. Configure backups and monitoring.
8. Connect official payment gateway and EFRIS credentials only after the required accounts are provisioned.
