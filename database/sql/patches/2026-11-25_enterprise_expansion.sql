CREATE TABLE IF NOT EXISTS hp_sensitive_actions (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 action_type ENUM('refund','discount','cancellation','upgrade','void','payroll_approval','disciplinary_action','late_checkout') NOT NULL,
 entity_type VARCHAR(60) NOT NULL,
 entity_id BIGINT UNSIGNED NOT NULL,
 amount DECIMAL(14,2) NOT NULL DEFAULT 0.00,
 reason VARCHAR(500) NOT NULL,
 requested_by BIGINT UNSIGNED NOT NULL,
 authorized_by BIGINT UNSIGNED NULL,
 status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
 created_at DATETIME NOT NULL,
 decided_at DATETIME NULL,
 PRIMARY KEY(id),
 KEY idx_hp_sensitive_status(status),
 KEY idx_hp_sensitive_entity(entity_type,entity_id),
 KEY idx_hp_sensitive_requested(requested_by,created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_front_events (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 reservation_id BIGINT UNSIGNED NOT NULL,
 event_type ENUM('registration','allocation','check_in','check_out','early_check_in','late_check_out','extension','transfer','upgrade','cancellation','no_show','refund','deposit') NOT NULL,
 details VARCHAR(500) NULL,
 amount DECIMAL(14,2) NOT NULL DEFAULT 0.00,
 authorization_id BIGINT UNSIGNED NULL,
 created_by BIGINT UNSIGNED NOT NULL,
 created_at DATETIME NOT NULL,
 PRIMARY KEY(id),
 KEY idx_hp_front_reservation(reservation_id,created_at),
 KEY idx_hp_front_type(event_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_handovers (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 handover_date DATE NOT NULL,
 shift_label VARCHAR(80) NOT NULL,
 outgoing_user_id BIGINT UNSIGNED NOT NULL,
 incoming_user_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
 cash_expected DECIMAL(14,2) NOT NULL DEFAULT 0.00,
 cash_counted DECIMAL(14,2) NOT NULL DEFAULT 0.00,
 variance DECIMAL(14,2) NOT NULL DEFAULT 0.00,
 open_issues TEXT NULL,
 handover_notes TEXT NULL,
 created_by BIGINT UNSIGNED NOT NULL,
 created_at DATETIME NOT NULL,
 acknowledged_at DATETIME NULL,
 PRIMARY KEY(id),
 KEY idx_hp_handover_date(handover_date,shift_label)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_cleaning_checklists (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 task_id BIGINT UNSIGNED NOT NULL,
 room_id BIGINT UNSIGNED NOT NULL,
 item_name VARCHAR(120) NOT NULL,
 checked TINYINT(1) NOT NULL DEFAULT 0,
 checked_by BIGINT UNSIGNED NULL,
 checked_at DATETIME NULL,
 created_at DATETIME NOT NULL,
 PRIMARY KEY(id),
 KEY idx_hp_checklist_task(task_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_linen_stock (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 item_name VARCHAR(120) NOT NULL,
 location VARCHAR(80) NOT NULL DEFAULT 'Linen Store',
 quantity INT NOT NULL DEFAULT 0,
 reorder_level INT NOT NULL DEFAULT 0,
 PRIMARY KEY(id),
 UNIQUE KEY uniq_hp_linen(item_name,location)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_linen_movements (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 item_name VARCHAR(120) NOT NULL,
 location VARCHAR(80) NOT NULL DEFAULT 'Linen Store',
 movement_type ENUM('issued','returned','laundry_sent','laundry_received','wasted') NOT NULL,
 quantity INT NOT NULL,
 room_id BIGINT UNSIGNED NULL,
 user_id BIGINT UNSIGNED NOT NULL,
 notes VARCHAR(255) NULL,
 created_at DATETIME NOT NULL,
 PRIMARY KEY(id),
 KEY idx_hp_linen_item(item_name,created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_maintenance_costs (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 ticket_id BIGINT UNSIGNED NOT NULL,
 amount DECIMAL(14,2) NOT NULL,
 description VARCHAR(255) NOT NULL,
 recorded_by BIGINT UNSIGNED NOT NULL,
 created_at DATETIME NOT NULL,
 PRIMARY KEY(id),
 KEY idx_hp_maint_cost_ticket(ticket_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_preventive_schedules (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 asset_id BIGINT UNSIGNED NULL,
 title VARCHAR(190) NOT NULL,
 frequency ENUM('daily','weekly','monthly','quarterly','annually') NOT NULL,
 next_due DATE NOT NULL,
 last_done DATE NULL,
 active TINYINT(1) NOT NULL DEFAULT 1,
 created_by BIGINT UNSIGNED NOT NULL,
 created_at DATETIME NOT NULL,
 PRIMARY KEY(id),
 KEY idx_hp_preventive_due(next_due,active)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_staff_schedules (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 user_id BIGINT UNSIGNED NOT NULL,
 shift_date DATE NOT NULL,
 start_time TIME NOT NULL,
 end_time TIME NOT NULL,
 outlet VARCHAR(80) NOT NULL DEFAULT 'Front Desk',
  status ENUM('scheduled','clocked_in','clocked_out','cancelled') NOT NULL DEFAULT 'scheduled',
  clocked_in_at DATETIME NULL,
  clocked_out_at DATETIME NULL,
  created_by BIGINT UNSIGNED NOT NULL,
 created_at DATETIME NOT NULL,
 PRIMARY KEY(id),
 KEY idx_hp_rota_user_date(user_id,shift_date),
 KEY idx_hp_rota_date(shift_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_payroll_runs (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 period_start DATE NOT NULL,
 period_end DATE NOT NULL,
  status ENUM('draft','approved','paid') NOT NULL DEFAULT 'draft',
  created_by BIGINT UNSIGNED NOT NULL,
  created_at DATETIME NOT NULL,
  approved_by BIGINT UNSIGNED NULL,
  approved_at DATETIME NULL,
  authorization_id BIGINT UNSIGNED NULL,
 PRIMARY KEY(id),
 KEY idx_hp_payroll_period(period_start,period_end)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_payroll_lines (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 run_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  days_worked DECIMAL(8,2) NOT NULL DEFAULT 0.00,
  hours_worked DECIMAL(8,2) NOT NULL DEFAULT 0.00,
  hourly_rate DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  gross DECIMAL(14,2) NOT NULL DEFAULT 0.00,
 deductions DECIMAL(14,2) NOT NULL DEFAULT 0.00,
 net DECIMAL(14,2) NOT NULL DEFAULT 0.00,
 notes VARCHAR(255) NULL,
 PRIMARY KEY(id),
 UNIQUE KEY uniq_hp_payroll_line(run_id,user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_training_records (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 user_id BIGINT UNSIGNED NOT NULL,
 title VARCHAR(190) NOT NULL,
 provider VARCHAR(190) NULL,
 completed_on DATE NULL,
 expiry_date DATE NULL,
 status ENUM('planned','completed','certified') NOT NULL DEFAULT 'planned',
 score VARCHAR(40) NULL,
 notes TEXT NULL,
 created_by BIGINT UNSIGNED NOT NULL,
 created_at DATETIME NOT NULL,
 PRIMARY KEY(id),
 KEY idx_hp_training_user(user_id,status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_disciplinary_records (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 user_id BIGINT UNSIGNED NOT NULL,
 incident_date DATE NOT NULL,
 category VARCHAR(80) NOT NULL,
 severity ENUM('warning','suspension','termination','other') NOT NULL,
 description TEXT NOT NULL,
 action_taken TEXT NOT NULL,
 authorization_id BIGINT UNSIGNED NULL,
 recorded_by BIGINT UNSIGNED NOT NULL,
 created_at DATETIME NOT NULL,
 PRIMARY KEY(id),
 KEY idx_hp_discipline_user(user_id,incident_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_staff_documents (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 user_id BIGINT UNSIGNED NOT NULL,
 document_type VARCHAR(80) NOT NULL,
 document_number VARCHAR(120) NULL,
 file_path VARCHAR(255) NULL,
 expires_on DATE NULL,
 created_by BIGINT UNSIGNED NOT NULL,
 created_at DATETIME NOT NULL,
 PRIMARY KEY(id),
 KEY idx_hp_staff_doc_user(user_id,expires_on)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_guest_preferences (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 guest_id BIGINT UNSIGNED NOT NULL,
 preference_type ENUM('room','bed','floor','diet','celebration','communication','other') NOT NULL,
 preference_value VARCHAR(255) NOT NULL,
 notes VARCHAR(500) NULL,
 created_by BIGINT UNSIGNED NOT NULL,
 created_at DATETIME NOT NULL,
 PRIMARY KEY(id),
 KEY idx_hp_pref_guest(guest_id,preference_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_loyalty_accounts (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 guest_id BIGINT UNSIGNED NOT NULL,
 tier ENUM('silver','gold','platinum') NOT NULL DEFAULT 'silver',
 points INT NOT NULL DEFAULT 0,
 lifetime_stays INT NOT NULL DEFAULT 0,
 joined_at DATE NOT NULL,
 created_at DATETIME NOT NULL,
 PRIMARY KEY(id),
 UNIQUE KEY uniq_hp_loyalty_guest(guest_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_loyalty_transactions (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 guest_id BIGINT UNSIGNED NOT NULL,
 points INT NOT NULL,
 reason VARCHAR(190) NOT NULL,
 reservation_id BIGINT UNSIGNED NULL,
 created_by BIGINT UNSIGNED NOT NULL,
 created_at DATETIME NOT NULL,
 PRIMARY KEY(id),
 KEY idx_hp_loyalty_guest(guest_id,created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS hp_guest_followups (
 id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
 hotel_id BIGINT UNSIGNED NOT NULL DEFAULT 1,
 guest_id BIGINT UNSIGNED NOT NULL,
 channel ENUM('call','email','whatsapp','visit') NOT NULL,
 subject VARCHAR(190) NOT NULL,
 notes TEXT NULL,
 status ENUM('open','done') NOT NULL DEFAULT 'open',
 due_date DATE NULL,
 assigned_to BIGINT UNSIGNED NULL,
 created_by BIGINT UNSIGNED NOT NULL,
 created_at DATETIME NOT NULL,
 completed_at DATETIME NULL,
 PRIMARY KEY(id),
 KEY idx_hp_followup_status(status,due_date),
 KEY idx_hp_followup_guest(guest_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
