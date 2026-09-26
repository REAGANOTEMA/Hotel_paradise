# Module SQL policy

`../INSTALL.sql` is the single authoritative installer. The `modules/` folder documents ownership of tables by department. Do not create a second conflicting schema.

Every module is named after the dashboard/department that owns its operational records. Cross-department transactions use shared IDs and foreign keys in the main installer.

If you later split SQL for migrations, keep filenames in this pattern: `NN_department_name.sql` and update `MIGRATION_ORDER.md`.
