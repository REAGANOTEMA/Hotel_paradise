# Module SQL policy

**The SQL is gone.** `../INSTALL.sql` and every `NN_department.sql` in this
folder have been removed, so there is nothing here to run. What is left is the
map of which department owns which tables, kept for planning. The live site is
installed from the two dumps under `database/sql/` at the project root. Do not
create a second schema alongside them.

Every module is named after the dashboard/department that owns its operational records. Cross-department transactions use shared IDs and foreign keys in the main installer.

If you later split SQL for migrations, keep filenames in this pattern: `NN_department_name.sql` and update `MIGRATION_ORDER.md`.
