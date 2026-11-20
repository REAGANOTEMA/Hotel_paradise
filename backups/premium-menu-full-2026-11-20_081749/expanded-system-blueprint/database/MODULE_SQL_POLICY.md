# SQL POLICY

There is **no executable SQL in this folder any more**: `INSTALL.sql` and
`database/modules/*.sql` have been removed, so this policy describes how the
files were arranged while they existed. The live site is installed from the two
dumps under `database/sql/` at the project root.

The module folders are organizational references. They should not be run independently
against production because hotel tables intentionally depend on one another.

Application code should use the same table names.

Recommended Laravel mapping:
- users -> User
- properties -> Property
- departments -> Department
- guests -> Guest
- rooms -> Room
- reservations -> Reservation
- orders -> Order
- pos_sales -> PosSale
- invoices -> Invoice
- payments -> Payment
- inventory_items -> InventoryItem
- audit_logs -> AuditLog
- department_messages -> DepartmentMessage
- efris_invoices -> EfrisInvoice
