# SQL POLICY

`INSTALL.sql` is the authoritative executable database installer.

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
