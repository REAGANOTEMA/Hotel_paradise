# Deployment

1. Install the live databases at the project root: `tools/install-databases.php`,
   or `database/HOSTING.md` by hand. The blueprint carries no SQL of its own.
2. Configure PHP DB credentials.
3. Build React frontend and serve it behind HTTPS.
4. Run PHP API behind the same domain or `/api`.
5. Run Python adapter as an internal service, protected by network policy and secrets.
6. Configure backups and monitoring.
7. Connect official payment gateway and EFRIS credentials only after the required accounts are provisioned.
