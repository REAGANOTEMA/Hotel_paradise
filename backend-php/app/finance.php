<?php
declare(strict_types=1);

function finance_role_can(string $area='read'): bool
{
    $roles = roles_of();
    if (in_array('super_admin', $roles, true)) return true;
    $map = [
        'read' => ['director', 'general_manager', 'accountant', 'cashier', 'auditor'],
        'cash' => ['director', 'general_manager', 'accountant', 'cashier'],
        'manage' => ['director', 'general_manager', 'accountant'],
        'audit' => ['director', 'general_manager', 'auditor'],
    ];
    return (bool)array_intersect($roles, $map[$area] ?? []);
}

function finance_range(int $defaultDays=30): array
{
    $today = date('Y-m-d');
    $from = trim((string)($_GET['from'] ?? ''));
    $to = trim((string)($_GET['to'] ?? ''));
    if ($from === '') $from = $defaultDays === 0 ? $today : date('Y-m-d', strtotime('-'.max(0, $defaultDays - 1).' days'));
    if ($to === '') $to = $today;
    $ft = strtotime($from);
    $tt = strtotime($to);
    if ($ft === false || $tt === false) {
        $from = date('Y-m-d', strtotime('-'.max(0, $defaultDays - 1).' days'));
        $to = $today;
        $ft = strtotime($from);
        $tt = strtotime($to);
    }
    if ($tt < $ft) {
        $swap = $from;
        $from = $to;
        $to = $swap;
        $tt = strtotime($to);
    }
    if ($tt - $ft > 366 * 86400) {
        $from = date('Y-m-d', strtotime($to.' -366 days'));
    }
    return [
        'from' => $from,
        'to' => $to,
        'to_excl' => date('Y-m-d', strtotime($to.' +1 day')),
        'label' => fmtdate($from).' to '.fmtdate($to),
    ];
}

function finance_table_exists(string $table): bool
{
    return hp_table_exists($table);
}

function finance_column_exists(string $table, string $column): bool
{
    return hp_column_exists($table, $column);
}

function finance_method_label(string $method): string
{
    $methods = payment_methods();
    return $methods[$method] ?? ucfirst(str_replace('_', ' ', $method));
}

function finance_summary(string $from, string $toEx): array
{
    $pay = row(
        "SELECT COALESCE(SUM(CASE WHEN status='successful' THEN amount ELSE 0 END),0) received,
                COALESCE(SUM(CASE WHEN status='pending' THEN amount ELSE 0 END),0) pending_amount,
                COALESCE(SUM(CASE WHEN status='pending' THEN 1 ELSE 0 END),0) pending_count,
                COALESCE(SUM(CASE WHEN status IN('refunded','reversed') THEN amount ELSE 0 END),0) reversed,
                COALESCE(SUM(CASE WHEN status='successful' AND method='cash' THEN amount ELSE 0 END),0) cash,
                COALESCE(SUM(CASE WHEN status='successful' AND method<>'cash' THEN amount ELSE 0 END),0) noncash
         FROM payments WHERE created_at>=? AND created_at<?",
        [$from, $toEx]
    ) ?: [];
    $expenses = (float)val(
        "SELECT COALESCE(SUM(amount),0) FROM expenses
         WHERE deleted_at IS NULL AND status='paid' AND paid_at>=? AND paid_at<?",
        [$from, $toEx]
    );
    $voids = (float)val("SELECT COALESCE(SUM(amount),0) FROM voids WHERE created_at>=? AND created_at<?", [$from, $toEx]);
    $reservationDue = (float)val(
        "SELECT COALESCE(SUM(GREATEST(total-paid,0)),0) FROM reservations
         WHERE deleted_at IS NULL AND status IN('pending','confirmed','checked_in')",
        []
    );
    $invoiceDue = (float)val(
        "SELECT COALESCE(SUM(GREATEST(i.total-COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.invoice_id=i.id AND p.status='successful'),0),0)),0)
         FROM invoices i WHERE i.deleted_at IS NULL AND i.status IN('issued','partially_paid')",
        []
    );
    $orderDue = (float)val(
        "SELECT COALESCE(SUM(GREATEST(o.total-COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.order_id=o.id AND p.status='successful'),0),0)),0)
         FROM orders o WHERE o.deleted_at IS NULL AND o.status NOT IN('cancelled','paid')",
        []
    );
    $receivable = (float)($reservationDue + $invoiceDue + $orderDue);
    $payable = (float)val("SELECT COALESCE(SUM(amount),0) FROM expenses WHERE deleted_at IS NULL AND status='approved'");
    $openShifts = (int)val("SELECT COUNT(*) FROM shifts WHERE status='open'");
    return [
        'received' => (float)($pay['received'] ?? 0),
        'pending_amount' => (float)($pay['pending_amount'] ?? 0),
        'pending_count' => (int)($pay['pending_count'] ?? 0),
        'reversed' => (float)($pay['reversed'] ?? 0),
        'cash' => (float)($pay['cash'] ?? 0),
        'noncash' => (float)($pay['noncash'] ?? 0),
        'expenses' => $expenses,
        'voids' => $voids,
        'receivable' => $receivable,
        'payable' => $payable,
        'open_shifts' => $openShifts,
        'net' => (float)($pay['received'] ?? 0) - $expenses,
    ];
}

function finance_method_totals(string $from, string $toEx): array
{
    return rows(
        "SELECT method,
                COUNT(*) transactions,
                COALESCE(SUM(CASE WHEN status='successful' THEN amount ELSE 0 END),0) received,
                COALESCE(SUM(CASE WHEN status='pending' THEN amount ELSE 0 END),0) pending,
                COALESCE(SUM(CASE WHEN status IN('refunded','reversed') THEN amount ELSE 0 END),0) reversed
         FROM payments
         WHERE created_at>=? AND created_at<?
         GROUP BY method ORDER BY received DESC, method",
        [$from, $toEx]
    );
}

function finance_payment_rows(array $f): array
{
    $where = ['p.created_at>=?', 'p.created_at<?'];
    $args = [$f['from'], $f['to_excl']];
    if (($f['status'] ?? '') !== '') {
        $where[] = 'p.status=?';
        $args[] = $f['status'];
    }
    if (($f['method'] ?? '') !== '') {
        $where[] = 'p.method=?';
        $args[] = $f['method'];
    }
    if (($f['source'] ?? '') === 'order') $where[] = 'p.order_id IS NOT NULL';
    if (($f['source'] ?? '') === 'invoice') $where[] = 'p.invoice_id IS NOT NULL';
    if (($f['source'] ?? '') === 'reservation') $where[] = 'p.reservation_id IS NOT NULL';
    if (($f['source'] ?? '') === 'other') $where[] = 'p.order_id IS NULL AND p.invoice_id IS NULL AND p.reservation_id IS NULL';
    $search = trim((string)($f['q'] ?? ''));
    if ($search !== '') {
        $like = '%'.$search.'%';
        $where[] = '(u.name LIKE ? OR p.provider_reference LIKE ? OR o.order_number LIKE ? OR i.invoice_number LIKE ? OR r.booking_number LIKE ? OR p.payer_phone LIKE ?)';
        array_push($args, $like, $like, $like, $like, $like, $like);
    }
    $limit = max(1, min(5000, (int)($f['limit'] ?? 300)));
    $sql = "SELECT p.*,u.name recorded_by,
                   CASE WHEN p.invoice_id IS NOT NULL THEN 'invoice'
                        WHEN p.order_id IS NOT NULL THEN 'order'
                        WHEN p.reservation_id IS NOT NULL THEN 'reservation'
                        ELSE 'other' END source,
                   o.order_number,o.outlet,i.invoice_number,r.booking_number,
                   s.outlet shift_outlet
            FROM payments p
            LEFT JOIN users u ON u.id=p.user_id
            LEFT JOIN orders o ON o.id=p.order_id
            LEFT JOIN invoices i ON i.id=p.invoice_id
            LEFT JOIN reservations r ON r.id=p.reservation_id
            LEFT JOIN shifts s ON s.id=p.shift_id
            WHERE ".implode(' AND ', $where)."
            ORDER BY p.id DESC LIMIT ".$limit;
    return rows($sql, $args);
}

function finance_payment_totals(array $payments): array
{
    $out = ['successful' => 0.0, 'pending' => 0.0, 'reversed' => 0.0, 'count' => count($payments)];
    foreach ($payments as $p) {
        $amount = (float)$p['amount'];
        if ($p['status'] === 'successful') $out['successful'] += $amount;
        elseif ($p['status'] === 'pending') $out['pending'] += $amount;
        elseif (in_array($p['status'], ['refunded', 'reversed'], true)) $out['reversed'] += $amount;
    }
    return $out;
}

function finance_open_shift(int $userId): ?array
{
    if ($userId <= 0) return null;
    $r = row("SELECT * FROM shifts WHERE user_id=? AND status='open' ORDER BY id DESC LIMIT 1", [$userId]);
    return $r ?: null;
}

function finance_shift_cash_sales(array $shift): float
{
    $from = (string)($shift['opened_at'] ?? '');
    $to = (string)($shift['closed_at'] ?? '');
    if ($from === '') return 0.0;
    if ($to === '') $to = now_s();
    $userId = (int)($shift['user_id'] ?? 0);
    $shiftId = (int)($shift['id'] ?? 0);
    if ($shiftId > 0 && finance_column_exists('payments', 'shift_id')) {
        return (float)val(
            "SELECT COALESCE(SUM(amount),0) FROM payments
             WHERE status='successful' AND method='cash'
               AND (shift_id=? OR (shift_id IS NULL AND user_id=? AND created_at BETWEEN ? AND ?))",
            [$shiftId, $userId, $from, $to]
        );
    }
    return (float)val(
        "SELECT COALESCE(SUM(amount),0) FROM payments
         WHERE user_id=? AND status='successful' AND method='cash' AND created_at BETWEEN ? AND ?",
        [$userId, $from, $to]
    );
}

function finance_shift_by_method(array $shift): array
{
    $from = (string)($shift['opened_at'] ?? '');
    $to = (string)($shift['closed_at'] ?? '');
    if ($from === '') return [];
    if ($to === '') $to = now_s();
    $userId = (int)($shift['user_id'] ?? 0);
    $shiftId = (int)($shift['id'] ?? 0);
    $hasShift = finance_column_exists('payments', 'shift_id');
    $shiftClause = $hasShift
        ? "(shift_id=? OR (shift_id IS NULL AND user_id=? AND created_at BETWEEN ? AND ?))"
        : "(user_id=? AND created_at BETWEEN ? AND ?)";
    $args = $hasShift ? [$shiftId, $userId, $from, $to] : [$userId, $from, $to];
    return rows(
        "SELECT method,COUNT(*) transactions,COALESCE(SUM(amount),0) amount
         FROM payments WHERE status='successful' AND ".$shiftClause."
         GROUP BY method ORDER BY amount DESC",
        $args
    );
}

function finance_shift_payments(array $shift, int $limit=300): array
{
    $from = (string)($shift['opened_at'] ?? '');
    $to = (string)($shift['closed_at'] ?? '');
    if ($from === '') return [];
    if ($to === '') $to = now_s();
    $userId = (int)($shift['user_id'] ?? 0);
    $shiftId = (int)($shift['id'] ?? 0);
    $hasShift = finance_column_exists('payments', 'shift_id');
    $where = $hasShift
        ? "(p.shift_id=? OR (p.shift_id IS NULL AND p.user_id=? AND p.created_at BETWEEN ? AND ?))"
        : "(p.user_id=? AND p.created_at BETWEEN ? AND ?)";
    $args = $hasShift ? [$shiftId, $userId, $from, $to] : [$userId, $from, $to];
    return rows(
        "SELECT p.*,u.name recorded_by,
                CASE WHEN p.invoice_id IS NOT NULL THEN 'invoice'
                     WHEN p.order_id IS NOT NULL THEN 'order'
                     WHEN p.reservation_id IS NOT NULL THEN 'reservation'
                     ELSE 'other' END source,
                o.order_number,o.outlet,i.invoice_number,r.booking_number
         FROM payments p
         LEFT JOIN users u ON u.id=p.user_id
         LEFT JOIN orders o ON o.id=p.order_id
         LEFT JOIN invoices i ON i.id=p.invoice_id
         LEFT JOIN reservations r ON r.id=p.reservation_id
         WHERE ".$where."
         ORDER BY p.id DESC LIMIT ".max(1, min(1000, $limit)),
        $args
    );
}

function finance_shift_movements(int $shiftId): array
{
    if ($shiftId <= 0 || !finance_table_exists('finance_cash_movements')) return [];
    return rows(
        "SELECT m.*,u.name recorded_by,a.name approved_name
         FROM finance_cash_movements m
         LEFT JOIN users u ON u.id=m.user_id
         LEFT JOIN users a ON a.id=m.approved_by
         WHERE m.shift_id=? ORDER BY m.id DESC",
        [$shiftId]
    );
}

function finance_shift_movement_total(int $shiftId): array
{
    $out = ['in' => 0.0, 'out' => 0.0];
    if ($shiftId <= 0 || !finance_table_exists('finance_cash_movements')) return $out;
    $r = row(
        "SELECT COALESCE(SUM(CASE WHEN direction='in' AND status IN('recorded','approved') THEN amount ELSE 0 END),0) cash_in,
                COALESCE(SUM(CASE WHEN direction='out' AND status IN('recorded','approved') THEN amount ELSE 0 END),0) cash_out
         FROM finance_cash_movements WHERE shift_id=?",
        [$shiftId]
    ) ?: [];
    $out['in'] = (float)($r['cash_in'] ?? 0);
    $out['out'] = (float)($r['cash_out'] ?? 0);
    return $out;
}

function finance_shift_expected_cash(array $shift): float
{
    $movement = finance_shift_movement_total((int)($shift['id'] ?? 0));
    return round((float)($shift['opening_cash'] ?? 0) + finance_shift_cash_sales($shift) + $movement['in'] - $movement['out'], 2);
}

function finance_shift_open(string $outlet, float $opening, int $userId): array
{
    $allowed = ['restaurant', 'bar', 'front_desk', 'kitchen', 'store'];
    if (!in_array($outlet, $allowed, true)) return ['ok' => false, 'error' => 'Choose a valid shift outlet.'];
    if (finance_open_shift($userId)) return ['ok' => false, 'error' => 'You already have an open shift.'];
    q('INSERT INTO shifts(hotel_id,user_id,outlet,opened_at,opening_cash) VALUES(1,?,?,NOW(),?)',
        [$userId, $outlet, round(max(0.0, $opening), 2)]);
    $id = (int)db()->lastInsertId();
    audit('open_shift', 'shift', $id, ['outlet' => $outlet, 'opening_cash' => $opening]);
    return ['ok' => true, 'id' => $id, 'error' => null];
}

function finance_shift_close(int $shiftId, int $userId, float $counted, bool $manager=false): array
{
    $shift = row("SELECT * FROM shifts WHERE id=? AND status='open'", [$shiftId]);
    if (!$shift) return ['ok' => false, 'error' => 'That open shift could not be found.'];
    if (!$manager && (int)$shift['user_id'] !== $userId) return ['ok' => false, 'error' => 'You may only close your own shift.'];
    $openDue = (float)val(
        "SELECT COALESCE(SUM(GREATEST(o.total-COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.order_id=o.id AND p.status='successful'),0),0)),0)
         FROM orders o WHERE o.shift_id=? AND o.status NOT IN('cancelled','paid') AND o.deleted_at IS NULL",
        [$shiftId]
    );
    if ($openDue > 0.009) {
        return ['ok' => false, 'error' => 'This shift still has unpaid orders totalling '.money($openDue).'. Settle or void them before closing.'];
    }
    $expected = finance_shift_expected_cash($shift);
    $counted = round(max(0.0, $counted), 2);
    $variance = round($counted - $expected, 2);
    q("UPDATE shifts SET closed_at=NOW(),expected_cash=?,counted_cash=?,variance=?,status='closed' WHERE id=?",
        [$expected, $counted, $variance, $shiftId]);
    audit('close_shift', 'shift', $shiftId, ['expected' => $expected, 'counted' => $counted, 'variance' => $variance]);
    $name = (string)(current_user()['name'] ?? 'A cashier');
    if (abs($variance) > 0.009) {
        notify_console('shift-variance:'.$shiftId, 'incident', 'Cash variance on '.ucfirst((string)$shift['outlet']).' shift',
            $name.' closed with a variance of '.($variance < 0 ? '-' : '').money(abs($variance)).' (expected '.money($expected).', counted '.money($counted).').',
            ['shift_id' => $shiftId], ['director', 'general_manager', 'accountant'], 'shift', $shiftId);
    }
    return ['ok' => true, 'expected' => $expected, 'variance' => $variance, 'error' => null];
}

function finance_cash_movement(int $shiftId, int $userId, string $type, string $direction, float $amount, string $reason, string $reference='', bool $manager=false): array
{
    if (!finance_table_exists('finance_cash_movements')) {
        return ['ok' => false, 'error' => 'Run database/sql/patches/2026-10-30_finance_workspace.sql before recording drawer movements.'];
    }
    $types = ['float', 'cash_in', 'cash_out', 'drop', 'payout', 'refund', 'correction'];
    if (!in_array($type, $types, true)) return ['ok' => false, 'error' => 'Choose a valid drawer movement type.'];
    if (!in_array($direction, ['in', 'out'], true)) return ['ok' => false, 'error' => 'Choose whether the cash came in or went out.'];
    if ($amount <= 0) return ['ok' => false, 'error' => 'Enter a movement amount above zero.'];
    if (trim($reason) === '') return ['ok' => false, 'error' => 'A reason is required for every drawer movement.'];
    $shift = row("SELECT * FROM shifts WHERE id=? AND status='open'", [$shiftId]);
    if (!$shift) return ['ok' => false, 'error' => 'Open a shift before recording a drawer movement.'];
    if (!$manager && (int)$shift['user_id'] !== $userId) return ['ok' => false, 'error' => 'You may only record movements on your own shift.'];
    q('INSERT INTO finance_cash_movements(shift_id,outlet,user_id,movement_type,direction,amount,method,reference,reason,status,created_at)
       VALUES(?,?,?,?,?,?,?,?,?,?,NOW())',
        [$shiftId, $shift['outlet'], $userId, $type, $direction, round($amount, 2), 'cash', mb_substr(trim($reference), 0, 190), mb_substr(trim($reason), 0, 500), 'recorded']);
    $id = (int)db()->lastInsertId();
    audit('finance_cash_movement', 'finance_cash_movement', $id,
        [],
        ['shift_id' => $shiftId, 'type' => $type, 'direction' => $direction, 'amount' => $amount, 'reason' => $reason]);
    if ($direction === 'out' && $amount >= 100000) {
        notify_console('cash-out:'.$id, 'incident', 'Large cash movement recorded',
            money($amount).' left the drawer: '.$reason.'.',
            ['shift_id' => $shiftId, 'movement_id' => $id], ['director', 'general_manager', 'accountant'], 'shift', $shiftId);
    }
    return ['ok' => true, 'id' => $id, 'error' => null];
}

function finance_journal_ready(): bool
{
    return finance_table_exists('chart_of_accounts') && finance_table_exists('journal_entries') && finance_table_exists('journal_lines');
}

function finance_coa_accounts(bool $activeOnly=true): array
{
    if (!finance_table_exists('chart_of_accounts')) return [];
    return rows("SELECT * FROM chart_of_accounts".($activeOnly ? " WHERE active=1" : '')." ORDER BY account_code");
}

function finance_standard_accounts(): array
{
    return [
        ['1000', 'Cash on hand', 'asset'],
        ['1010', 'Bank account', 'asset'],
        ['1020', 'Mobile money wallet', 'asset'],
        ['1030', 'Card settlement clearing', 'asset'],
        ['1100', 'Accounts receivable', 'asset'],
        ['1200', 'Inventory', 'asset'],
        ['2000', 'Accounts payable', 'liability'],
        ['2100', 'Tax and service charge payable', 'liability'],
        ['2200', 'Guest deposits', 'liability'],
        ['3000', 'Owner equity', 'equity'],
        ['3900', 'Retained earnings', 'equity'],
        ['4000', 'Room and venue revenue', 'income'],
        ['4100', 'Food and beverage revenue', 'income'],
        ['4200', 'Other operating revenue', 'income'],
        ['4900', 'Other income', 'income'],
        ['5000', 'Cost of sales', 'expense'],
        ['5100', 'Payroll and staff costs', 'expense'],
        ['5200', 'Utilities', 'expense'],
        ['5300', 'Repairs and maintenance', 'expense'],
        ['5400', 'Marketing', 'expense'],
        ['5500', 'Transport and travel', 'expense'],
        ['5600', 'Administration', 'expense'],
    ];
}

function finance_seed_accounts(): int
{
    if (!finance_table_exists('chart_of_accounts')) return 0;
    $n = 0;
    foreach (finance_standard_accounts() as $a) {
        $exists = (int)val('SELECT COUNT(*) FROM chart_of_accounts WHERE account_code=?', [$a[0]]);
        if ($exists) continue;
        q('INSERT INTO chart_of_accounts(property_id,account_code,account_name,account_type,active) VALUES(1,?,?,?,1)',
            [$a[0], $a[1], $a[2]]);
        $n++;
    }
    if ($n > 0) audit('finance_seed_accounts', 'chart_of_accounts', null, [], ['created' => $n]);
    return $n;
}

function finance_account_by_code(string $code): ?array
{
    if (!finance_table_exists('chart_of_accounts')) return null;
    $r = row('SELECT * FROM chart_of_accounts WHERE account_code=? AND active=1', [$code]);
    return $r ?: null;
}

function finance_account_by_type(string $type): ?array
{
    if (!finance_table_exists('chart_of_accounts')) return null;
    $r = row('SELECT * FROM chart_of_accounts WHERE account_type=? AND active=1 ORDER BY account_code LIMIT 1', [$type]);
    return $r ?: null;
}

function finance_payment_asset_code(string $method): string
{
    return match ($method) {
        'cash' => '1000',
        'bank' => '1010',
        'mtn_momo', 'airtel_money' => '1020',
        'card' => '1030',
        default => '1000',
    };
}

function finance_expense_code(string $category): string
{
    $c = strtolower($category);
    if (str_contains($c, 'food') || str_contains($c, 'beverage') || str_contains($c, 'cost')) return '5000';
    if (str_contains($c, 'salary') || str_contains($c, 'wage') || str_contains($c, 'payroll') || str_contains($c, 'staff')) return '5100';
    if (str_contains($c, 'utility') || str_contains($c, 'electric') || str_contains($c, 'water') || str_contains($c, 'internet')) return '5200';
    if (str_contains($c, 'repair') || str_contains($c, 'maintenance')) return '5300';
    if (str_contains($c, 'market') || str_contains($c, 'advert')) return '5400';
    if (str_contains($c, 'transport') || str_contains($c, 'travel') || str_contains($c, 'fuel')) return '5500';
    if (str_contains($c, 'admin') || str_contains($c, 'stationery') || str_contains($c, 'cleaning')) return '5600';
    return '5600';
}

function finance_period_for_date(string $date): ?array
{
    if (!finance_table_exists('financial_periods')) return null;
    $r = row('SELECT * FROM financial_periods WHERE start_date<=? AND end_date>=? ORDER BY id DESC LIMIT 1', [$date, $date]);
    return $r ?: null;
}

function finance_date_is_closed(string $date): bool
{
    $p = finance_period_for_date($date);
    return $p !== null && $p['status'] === 'closed';
}

function finance_next_entry_number(string $prefix='JV'): string
{
    $day = date('Ymd');
    $base = $prefix.'-'.$day.'-';
    $max = (string)val('SELECT MAX(entry_number) FROM journal_entries WHERE entry_number LIKE ?', [$base.'%']);
    $n = (int)substr($max, strlen($base)) + 1;
    return $base.str_pad((string)$n, 3, '0', STR_PAD_LEFT);
}

function finance_insert_journal(string $date, string $description, array $lines, int $userId, bool $post=true, ?string $number=null): array
{
    if (!finance_journal_ready()) return ['ok' => false, 'error' => 'The accounting ledger is not installed.'];
    if (finance_date_is_closed($date)) return ['ok' => false, 'error' => 'That date falls in a closed financial period.'];
    $clean = [];
    $debit = 0.0;
    $credit = 0.0;
    foreach ($lines as $line) {
        $accountId = (int)($line['account_id'] ?? 0);
        $dr = round(max(0.0, (float)($line['debit'] ?? 0)), 2);
        $cr = round(max(0.0, (float)($line['credit'] ?? 0)), 2);
        if ($accountId <= 0) continue;
        if (($dr > 0 && $cr > 0) || ($dr <= 0 && $cr <= 0)) continue;
        $clean[] = ['account_id' => $accountId, 'debit' => $dr, 'credit' => $cr, 'memo' => mb_substr(trim((string)($line['memo'] ?? '')), 0, 500)];
        $debit += $dr;
        $credit += $cr;
    }
    if (count($clean) < 2) return ['ok' => false, 'error' => 'A journal entry needs at least two valid lines.'];
    if (abs($debit - $credit) > 0.009) return ['ok' => false, 'error' => 'Debits and credits must balance exactly.'];
    $period = finance_period_for_date($date);
    $cols = ['property_id', 'period_id', 'entry_number', 'entry_date', 'description', 'status', 'created_by'];
    $vals = [1, $period['id'] ?? null, $number ?: finance_next_entry_number(), $date, $description, $post ? 'posted' : 'draft', $userId];
    if (finance_column_exists('journal_entries', 'posted_at') && $post) {
        $cols[] = 'posted_at';
        $vals[] = now_s();
    }
    if (finance_column_exists('journal_entries', 'posted_by') && $post) {
        $cols[] = 'posted_by';
        $vals[] = $userId;
    }
    $pdo = db();
    try {
        $pdo->beginTransaction();
        q('INSERT INTO journal_entries('.implode(',', $cols).',created_at) VALUES('.implode(',', array_fill(0, count($cols), '?')).',NOW())', $vals);
        $id = (int)$pdo->lastInsertId();
        foreach ($clean as $line) {
            q('INSERT INTO journal_lines(journal_entry_id,account_id,debit,credit,memo) VALUES(?,?,?,?,?)',
                [$id, $line['account_id'], $line['debit'], $line['credit'], $line['memo']]);
        }
        $pdo->commit();
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        return ['ok' => false, 'error' => 'The journal entry could not be saved.'];
    }
    audit($post ? 'finance_journal_post' : 'finance_journal_draft', 'journal_entry', $id,
        [], ['description' => $description, 'debit' => $debit, 'credit' => $credit]);
    return ['ok' => true, 'id' => $id, 'error' => null];
}

function finance_reverse_journal(int $id, string $reason, int $userId): array
{
    if (!finance_journal_ready()) return ['ok' => false, 'error' => 'The accounting ledger is not installed.'];
    if (trim($reason) === '') return ['ok' => false, 'error' => 'A reversal reason is required.'];
    $entry = row("SELECT * FROM journal_entries WHERE id=? AND status='posted'", [$id]);
    if (!$entry) return ['ok' => false, 'error' => 'Only a posted journal can be reversed.'];
    $lines = rows('SELECT account_id,debit,credit,memo FROM journal_lines WHERE journal_entry_id=?', [$id]);
    if (!$lines) return ['ok' => false, 'error' => 'The journal has no lines to reverse.'];
    $swapped = [];
    foreach ($lines as $line) {
        $swapped[] = [
            'account_id' => (int)$line['account_id'],
            'debit' => (float)$line['credit'],
            'credit' => (float)$line['debit'],
            'memo' => 'Reversal: '.$line['memo'],
        ];
    }
    $number = finance_next_entry_number('REV');
    $res = finance_insert_journal(date('Y-m-d'), 'Reversal of '.$entry['entry_number'].': '.$reason, $swapped, $userId, true, $number);
    if (!$res['ok']) return $res;
    q("UPDATE journal_entries SET status='reversed' WHERE id=?", [$id]);
    if (finance_column_exists('journal_entries', 'reversal_of')) {
        q('UPDATE journal_entries SET reversal_of=?,reversal_reason=? WHERE id=?', [$id, mb_substr($reason, 0, 500), $res['id']]);
    }
    audit('finance_journal_reverse', 'journal_entry', $id, ['entry_number' => $entry['entry_number']], ['reversal_id' => $res['id'], 'reason' => $reason]);
    return $res;
}

function finance_post_auto(string $from, string $toEx, int $userId): array
{
    if (!finance_journal_ready()) return ['ok' => false, 'error' => 'The accounting ledger is not installed.', 'posted' => 0, 'skipped' => 0];
    $accounts = [];
    foreach (finance_coa_accounts() as $a) $accounts[$a['account_code']] = $a;
    if (!$accounts) return ['ok' => false, 'error' => 'Create the chart of accounts before posting.', 'posted' => 0, 'skipped' => 0];
    $payments = rows("SELECT * FROM payments WHERE status='successful' AND created_at>=? AND created_at<? ORDER BY id", [$from, $toEx]);
    $expenses = rows("SELECT * FROM expenses WHERE deleted_at IS NULL AND status='paid' AND paid_at>=? AND paid_at<? ORDER BY id", [$from, $toEx]);
    $posted = 0;
    $skipped = 0;
    $errors = [];
    foreach ($payments as $p) {
        $num = 'AUTO-PAY-'.(int)$p['id'];
        if ((int)val('SELECT COUNT(*) FROM journal_entries WHERE entry_number=?', [$num]) > 0) {
            $skipped++;
            continue;
        }
        $assetCode = finance_payment_asset_code((string)$p['method']);
        $asset = $accounts[$assetCode] ?? null;
        $income = $accounts['4000'] ?? null;
        if (!$asset || !$income) {
            $errors[] = 'Payment #'.(int)$p['id'].' cannot post: missing asset or revenue account.';
            continue;
        }
        $date = substr((string)$p['created_at'], 0, 10);
        if (finance_date_is_closed($date)) {
            $skipped++;
            continue;
        }
        $description = 'Payment #'.(int)$p['id'].' via '.finance_method_label((string)$p['method']);
        if (!empty($p['provider_reference'])) $description .= ' ref '.$p['provider_reference'];
        $res = finance_insert_journal($date, $description, [
            ['account_id' => (int)$asset['id'], 'debit' => (float)$p['amount'], 'credit' => 0, 'memo' => $description],
            ['account_id' => (int)$income['id'], 'debit' => 0, 'credit' => (float)$p['amount'], 'memo' => $description],
        ], $userId, true, $num);
        if ($res['ok']) $posted++;
        else $errors[] = 'Payment #'.(int)$p['id'].': '.$res['error'];
    }
    foreach ($expenses as $e) {
        $num = 'AUTO-EXP-'.(int)$e['id'];
        if ((int)val('SELECT COUNT(*) FROM journal_entries WHERE entry_number=?', [$num]) > 0) {
            $skipped++;
            continue;
        }
        $expenseCode = finance_expense_code((string)$e['category']);
        $expenseAccount = $accounts[$expenseCode] ?? ($accounts['5600'] ?? null);
        $creditCode = finance_payment_asset_code((string)($e['payment_method'] ?: 'cash'));
        $creditAccount = $accounts[$creditCode] ?? ($accounts['1000'] ?? null);
        if (!$expenseAccount || !$creditAccount) {
            $errors[] = 'Expense '.$e['number'].' cannot post: missing expense or payment account.';
            continue;
        }
        $date = substr((string)$e['paid_at'], 0, 10);
        if (finance_date_is_closed($date)) {
            $skipped++;
            continue;
        }
        $description = 'Expense '.$e['number'].' - '.$e['category'];
        $res = finance_insert_journal($date, $description, [
            ['account_id' => (int)$expenseAccount['id'], 'debit' => (float)$e['amount'], 'credit' => 0, 'memo' => $description],
            ['account_id' => (int)$creditAccount['id'], 'debit' => 0, 'credit' => (float)$e['amount'], 'memo' => $description],
        ], $userId, true, $num);
        if ($res['ok']) $posted++;
        else $errors[] = 'Expense '.$e['number'].': '.$res['error'];
    }
    return ['ok' => $errors === [], 'posted' => $posted, 'skipped' => $skipped, 'errors' => $errors, 'error' => $errors ? implode(' ', array_slice($errors, 0, 4)) : null];
}

function finance_trial_balance(string $from, string $toEx): array
{
    if (!finance_journal_ready()) return [];
    return rows(
        "SELECT a.id,a.account_code,a.account_name,a.account_type,
                COALESCE(SUM(l.debit),0) debit,COALESCE(SUM(l.credit),0) credit
         FROM chart_of_accounts a
         JOIN journal_lines l ON l.account_id=a.id
         JOIN journal_entries e ON e.id=l.journal_entry_id
         WHERE e.status='posted' AND e.entry_date>=? AND e.entry_date<?
         GROUP BY a.id,a.account_code,a.account_name,a.account_type
         HAVING ABS(SUM(l.debit)-SUM(l.credit))>0.001 OR SUM(l.debit)>0
         ORDER BY a.account_code",
        [$from, $toEx]
    );
}

function finance_account_totals(string $from, string $toEx, ?string $type=null, bool $asOf=false): array
{
    if (!finance_journal_ready()) return [];
    $where = ["e.status='posted'"];
    $args = [];
    if ($asOf) {
        $where[] = 'e.entry_date<=?';
        $args[] = $toEx;
    } else {
        $where[] = 'e.entry_date>=?';
        $where[] = 'e.entry_date<?';
        $args[] = $from;
        $args[] = $toEx;
    }
    if ($type !== null) {
        $where[] = 'a.account_type=?';
        $args[] = $type;
    }
    return rows(
        'SELECT a.id,a.account_code,a.account_name,a.account_type,
                COALESCE(SUM(l.debit),0) debit,COALESCE(SUM(l.credit),0) credit
         FROM chart_of_accounts a
         JOIN journal_lines l ON l.account_id=a.id
         JOIN journal_entries e ON e.id=l.journal_entry_id
         WHERE '.implode(' AND ', $where).'
         GROUP BY a.id,a.account_code,a.account_name,a.account_type
         ORDER BY a.account_code',
        $args
    );
}

function finance_income_statement(string $from, string $toEx): array
{
    $income = finance_account_totals($from, $toEx, 'income');
    $expense = finance_account_totals($from, $toEx, 'expense');
    $sumIncome = 0.0;
    $sumExpense = 0.0;
    foreach ($income as $r) $sumIncome += (float)$r['credit'] - (float)$r['debit'];
    foreach ($expense as $r) $sumExpense += (float)$r['debit'] - (float)$r['credit'];
    return ['income' => $income, 'expense' => $expense, 'total_income' => $sumIncome, 'total_expense' => $sumExpense, 'net' => $sumIncome - $sumExpense];
}

function finance_balance_sheet(string $asOf): array
{
    $assets = finance_account_totals('', $asOf, 'asset', true);
    $liabilities = finance_account_totals('', $asOf, 'liability', true);
    $equity = finance_account_totals('', $asOf, 'equity', true);
    $income = finance_account_totals('', $asOf, 'income', true);
    $expense = finance_account_totals('', $asOf, 'expense', true);
    $total = static function(array $rows, bool $debitNormal): float {
        $n = 0.0;
        foreach ($rows as $r) {
            $n += $debitNormal ? ((float)$r['debit'] - (float)$r['credit']) : ((float)$r['credit'] - (float)$r['debit']);
        }
        return $n;
    };
    $net = $total($income, false) - $total($expense, true);
    return [
        'assets' => $assets,
        'liabilities' => $liabilities,
        'equity' => $equity,
        'total_assets' => $total($assets, true),
        'total_liabilities' => $total($liabilities, false),
        'total_equity' => $total($equity, false),
        'net_income' => $net,
    ];
}

function finance_ledger(int $accountId, string $from, string $toEx): array
{
    if (!finance_journal_ready() || $accountId <= 0) return [];
    return rows(
        "SELECT e.id,e.entry_number,e.entry_date,e.description,e.status,
                l.debit,l.credit,l.memo
         FROM journal_lines l JOIN journal_entries e ON e.id=l.journal_entry_id
         WHERE l.account_id=? AND e.status='posted' AND e.entry_date>=? AND e.entry_date<?
         ORDER BY e.entry_date,e.id,l.id",
        [$accountId, $from, $toEx]
    );
}

function finance_journal_rows(string $from, string $toEx, string $q='', int $limit=300): array
{
    if (!finance_journal_ready()) return [];
    $where = ['e.entry_date>=?', 'e.entry_date<?'];
    $args = [$from, $toEx];
    if (trim($q) !== '') {
        $where[] = '(e.entry_number LIKE ? OR e.description LIKE ?)';
        $args[] = '%'.trim($q).'%';
        $args[] = '%'.trim($q).'%';
    }
    return rows(
        'SELECT e.*,u.name created_name,p.name posted_name,
                COALESCE((SELECT SUM(l.debit) FROM journal_lines l WHERE l.journal_entry_id=e.id),0) total
         FROM journal_entries e
         LEFT JOIN users u ON u.id=e.created_by
         LEFT JOIN users p ON p.id=e.posted_by
         WHERE '.implode(' AND ', $where).'
         ORDER BY e.entry_date DESC,e.id DESC LIMIT '.max(1, min(1000, $limit)),
        $args
    );
}

function finance_journal_lines(int $id): array
{
    if (!finance_journal_ready() || $id <= 0) return [];
    return rows(
        'SELECT l.*,a.account_code,a.account_name
         FROM journal_lines l JOIN chart_of_accounts a ON a.id=l.account_id
         WHERE l.journal_entry_id=? ORDER BY l.id',
        [$id]
    );
}

function finance_periods(): array
{
    if (!finance_table_exists('financial_periods')) return [];
    return rows('SELECT * FROM financial_periods ORDER BY start_date DESC,id DESC');
}

function finance_period_create(string $name, string $start, string $end, int $userId): array
{
    if (!finance_table_exists('financial_periods')) return ['ok' => false, 'error' => 'Financial periods are not installed.'];
    if ($name === '' || $start === '' || $end === '' || $end < $start) return ['ok' => false, 'error' => 'Enter a period name and a valid start and end date.'];
    $overlap = (int)val('SELECT COUNT(*) FROM financial_periods WHERE start_date<=? AND end_date>=?', [$end, $start]);
    if ($overlap > 0) return ['ok' => false, 'error' => 'That period overlaps an existing financial period.'];
    q("INSERT INTO financial_periods(property_id,period_name,start_date,end_date,status) VALUES(1,?,?,?,'open')",
        [mb_substr($name, 0, 50), $start, $end]);
    $id = (int)db()->lastInsertId();
    audit('finance_period_create', 'financial_period', $id, [], ['name' => $name, 'start' => $start, 'end' => $end]);
    return ['ok' => true, 'id' => $id, 'error' => null];
}

function finance_period_close(int $id, int $userId): array
{
    $p = row('SELECT * FROM financial_periods WHERE id=?', [$id]);
    if (!$p) return ['ok' => false, 'error' => 'Financial period not found.'];
    $drafts = (int)val("SELECT COUNT(*) FROM journal_entries WHERE status='draft' AND entry_date BETWEEN ? AND ?", [$p['start_date'], $p['end_date']]);
    if ($drafts > 0) return ['ok' => false, 'error' => 'Post or remove the '.$drafts.' draft journal(s) in this period before closing it.'];
    q("UPDATE financial_periods SET status='closed' WHERE id=?", [$id]);
    audit('finance_period_close', 'financial_period', $id, ['status' => $p['status']], ['status' => 'closed']);
    return ['ok' => true, 'error' => null];
}

function finance_period_reopen(int $id, int $userId): array
{
    $p = row('SELECT * FROM financial_periods WHERE id=?', [$id]);
    if (!$p) return ['ok' => false, 'error' => 'Financial period not found.'];
    q("UPDATE financial_periods SET status='open' WHERE id=?", [$id]);
    audit('finance_period_reopen', 'financial_period', $id, ['status' => $p['status']], ['status' => 'open']);
    return ['ok' => true, 'error' => null];
}

function finance_receivables(): array
{
    $invoices = rows(
        "SELECT i.id,i.invoice_number,i.billing_name,i.status,i.total,i.due_date,
                COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.invoice_id=i.id AND p.status='successful'),0) paid
         FROM invoices i WHERE i.deleted_at IS NULL AND i.status IN('issued','partially_paid')
         ORDER BY i.due_date,i.id LIMIT 300"
    );
    $reservations = rows(
        "SELECT r.id,r.booking_number,g.full_name,r.status,r.total,r.paid,r.check_out
         FROM reservations r LEFT JOIN guests g ON g.id=r.guest_id
         WHERE r.deleted_at IS NULL AND r.status IN('pending','confirmed','checked_in') AND r.total>r.paid
         ORDER BY r.check_out,r.id LIMIT 300"
    );
    $orders = rows(
        "SELECT o.id,o.order_number,o.customer_name,o.status,o.total,o.created_at,
                COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.order_id=o.id AND p.status='successful'),0) paid
         FROM orders o WHERE o.deleted_at IS NULL AND o.status NOT IN('cancelled','paid')
           AND o.total>COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.order_id=o.id AND p.status='successful'),0)
         ORDER BY o.id DESC LIMIT 300"
    );
    return ['invoices' => $invoices, 'reservations' => $reservations, 'orders' => $orders];
}

function finance_payables(): array
{
    return rows(
        "SELECT e.id,e.number,e.category,e.description,e.amount,e.status,e.created_at,d.name department
         FROM expenses e LEFT JOIN departments d ON d.id=e.department_id
         WHERE e.deleted_at IS NULL AND e.status IN('approved','paid')
         ORDER BY FIELD(e.status,'approved','paid'),e.id DESC LIMIT 300"
    );
}

function finance_tax_summary(string $from, string $toEx): array
{
    $orders = row(
        "SELECT COUNT(*) orders,COALESCE(SUM(subtotal),0) subtotal,COALESCE(SUM(tax),0) tax,COALESCE(SUM(discount),0) discount,COALESCE(SUM(total),0) total
         FROM orders WHERE deleted_at IS NULL AND status<>'cancelled' AND created_at>=? AND created_at<?",
        [$from, $toEx]
    ) ?: [];
    $invoices = row(
        "SELECT COUNT(*) invoices,COALESCE(SUM(subtotal),0) subtotal,COALESCE(SUM(tax),0) tax,COALESCE(SUM(discount),0) discount,COALESCE(SUM(total),0) total
         FROM invoices WHERE deleted_at IS NULL AND status NOT IN('draft','cancelled') AND created_at>=? AND created_at<?",
        [$from, $toEx]
    ) ?: [];
    return ['orders' => $orders, 'invoices' => $invoices];
}

function finance_efris_summary(): array
{
    $out = ['ready' => finance_table_exists('efris_invoices'), 'counts' => [], 'settings' => []];
    if ($out['ready']) {
        $out['counts'] = rows('SELECT status,COUNT(*) total FROM efris_invoices GROUP BY status ORDER BY status');
    }
    if (finance_table_exists('system_settings')) {
        $out['settings'] = rows("SELECT setting_key,setting_value FROM system_settings WHERE setting_key LIKE 'efris%' ORDER BY setting_key");
    }
    return $out;
}

function finance_bank_ready(): bool
{
    return finance_table_exists('finance_bank_accounts') && finance_table_exists('finance_bank_transactions');
}

function finance_bank_accounts(bool $activeOnly=true): array
{
    if (!finance_bank_ready()) return [];
    return rows('SELECT * FROM finance_bank_accounts'.($activeOnly ? ' WHERE active=1' : '').' ORDER BY name');
}

function finance_bank_transactions(int $accountId, string $from, string $toEx, int $limit=300): array
{
    if (!finance_bank_ready() || $accountId <= 0) return [];
    return rows(
        'SELECT t.*,u.name created_name FROM finance_bank_transactions t LEFT JOIN users u ON u.id=t.created_by
         WHERE t.account_id=? AND t.transaction_date>=? AND t.transaction_date<?
         ORDER BY t.transaction_date DESC,t.id DESC LIMIT '.max(1, min(1000, $limit)),
        [$accountId, $from, $toEx]
    );
}

function finance_bank_book_balance(array $account, string $from, string $toEx): float
{
    $method = (string)($account['method'] ?? 'bank');
    $in = (float)val("SELECT COALESCE(SUM(amount),0) FROM payments WHERE status='successful' AND method=? AND created_at>=? AND created_at<?", [$method, $from, $toEx]);
    $out = (float)val("SELECT COALESCE(SUM(amount),0) FROM expenses WHERE deleted_at IS NULL AND status='paid' AND payment_method=? AND paid_at>=? AND paid_at<?", [$method, $from, $toEx]);
    return round((float)($account['opening_balance'] ?? 0) + $in - $out, 2);
}

function finance_bank_statement_balance(array $account, string $from, string $toEx): float
{
    $tx = rows(
        "SELECT COALESCE(SUM(CASE WHEN direction='in' THEN amount ELSE 0 END),0) cash_in,
                COALESCE(SUM(CASE WHEN direction='out' THEN amount ELSE 0 END),0) cash_out
         FROM finance_bank_transactions WHERE account_id=? AND transaction_date>=? AND transaction_date<? AND status<>'ignored'",
        [(int)$account['id'], $from, $toEx]
    );
    $r = $tx[0] ?? [];
    return round((float)($account['opening_balance'] ?? 0) + (float)($r['cash_in'] ?? 0) - (float)($r['cash_out'] ?? 0), 2);
}

function finance_bank_account_create(array $d, int $userId): array
{
    if (!finance_bank_ready()) return ['ok' => false, 'error' => 'Bank reconciliation tables are not installed.'];
    $name = trim((string)($d['name'] ?? ''));
    $method = trim((string)($d['method'] ?? 'bank'));
    if ($name === '') return ['ok' => false, 'error' => 'Enter an account name.'];
    if (!array_key_exists($method, payment_methods())) return ['ok' => false, 'error' => 'Choose a valid payment method.'];
    $type = match ($method) {
        'mtn_momo', 'airtel_money' => 'mobile_money',
        'card' => 'card',
        'bank' => 'bank',
        default => 'other',
    };
    q('INSERT INTO finance_bank_accounts(name,bank_name,account_name,account_number_last4,method,account_type,currency,opening_balance,active,created_by)
       VALUES(?,?,?,?,?,?,?,?,1,?)', [
        mb_substr($name, 0, 150),
        mb_substr(trim((string)($d['bank_name'] ?? '')), 0, 150),
        mb_substr(trim((string)($d['account_name'] ?? '')), 0, 190),
        mb_substr(trim((string)($d['last4'] ?? '')), 0, 12),
        $method,
        $type,
        mb_substr(trim((string)($d['currency'] ?? 'UGX')), 0, 8) ?: 'UGX',
        round((float)($d['opening_balance'] ?? 0), 2),
        $userId,
    ]);
    $id = (int)db()->lastInsertId();
    audit('finance_bank_account_create', 'finance_bank_account', $id, [], ['name' => $name, 'method' => $method]);
    return ['ok' => true, 'id' => $id, 'error' => null];
}

function finance_bank_transaction_add(array $d, int $userId): array
{
    if (!finance_bank_ready()) return ['ok' => false, 'error' => 'Bank reconciliation tables are not installed.'];
    $accountId = (int)($d['account_id'] ?? 0);
    $date = (string)($d['transaction_date'] ?? '');
    $direction = (string)($d['direction'] ?? '');
    $amount = (float)($d['amount'] ?? 0);
    $description = trim((string)($d['description'] ?? ''));
    if ($accountId <= 0) return ['ok' => false, 'error' => 'Choose a bank account.'];
    if ($date === '' || strtotime($date) === false) return ['ok' => false, 'error' => 'Enter a valid statement date.'];
    if (!in_array($direction, ['in', 'out'], true)) return ['ok' => false, 'error' => 'Choose money in or money out.'];
    if ($amount <= 0) return ['ok' => false, 'error' => 'Enter an amount above zero.'];
    if ($description === '') return ['ok' => false, 'error' => 'Enter a statement description.'];
    $account = row('SELECT * FROM finance_bank_accounts WHERE id=? AND active=1', [$accountId]);
    if (!$account) return ['ok' => false, 'error' => 'That bank account is not active.'];
    q('INSERT INTO finance_bank_transactions(account_id,transaction_date,direction,amount,reference,description,status,created_by)
       VALUES(?,?,?,?,?,?,\'unmatched\',?)', [
        $accountId,
        $date,
        $direction,
        round($amount, 2),
        mb_substr(trim((string)($d['reference'] ?? '')), 0, 190),
        mb_substr($description, 0, 255),
        $userId,
    ]);
    $id = (int)db()->lastInsertId();
    audit('finance_bank_transaction_add', 'finance_bank_transaction', $id, [], ['account_id' => $accountId, 'direction' => $direction, 'amount' => $amount]);
    return ['ok' => true, 'id' => $id, 'error' => null];
}

function finance_reconciliation_save(int $accountId, string $start, string $end, float $statementIn, float $statementOut, float $statementClosing, string $notes, int $userId): array
{
    if (!finance_table_exists('finance_reconciliations')) return ['ok' => false, 'error' => 'Bank reconciliation tables are not installed.'];
    if (strtotime($start) === false || strtotime($end) === false || $end < $start) return ['ok' => false, 'error' => 'Enter a valid reconciliation period.'];
    $account = row('SELECT * FROM finance_bank_accounts WHERE id=? AND active=1', [$accountId]);
    if (!$account) return ['ok' => false, 'error' => 'Choose an active bank account.'];
    $book = finance_bank_book_balance($account, '1970-01-01', date('Y-m-d', strtotime($end.' +1 day')));
    $difference = round($statementClosing - $book, 2);
    q('INSERT INTO finance_reconciliations(account_id,period_start,period_end,opening_balance,statement_in,statement_out,statement_closing,book_balance,difference,status,prepared_by,notes)
       VALUES(?,?,?,?,?,?,?,?,?,\'draft\',?,?)', [
        $accountId,
        $start,
        $end,
        (float)$account['opening_balance'],
        round($statementIn, 2),
        round($statementOut, 2),
        round($statementClosing, 2),
        $book,
        $difference,
        $userId,
        mb_substr(trim($notes), 0, 500),
    ]);
    $id = (int)db()->lastInsertId();
    audit('finance_reconciliation_prepare', 'finance_reconciliation', $id, [], ['account_id' => $accountId, 'difference' => $difference]);
    return ['ok' => true, 'id' => $id, 'difference' => $difference, 'error' => null];
}

function finance_reconciliation_review(int $id, int $userId): array
{
    if (!finance_table_exists('finance_reconciliations')) return ['ok' => false, 'error' => 'Bank reconciliation tables are not installed.'];
    $r = row("SELECT * FROM finance_reconciliations WHERE id=? AND status='draft'", [$id]);
    if (!$r) return ['ok' => false, 'error' => 'Only a draft reconciliation can be reviewed.'];
    if ((int)$r['prepared_by'] === $userId) return ['ok' => false, 'error' => 'A reconciliation must be reviewed by someone other than its preparer.'];
    q("UPDATE finance_reconciliations SET status='reviewed',reviewed_by=?,reviewed_at=NOW() WHERE id=?", [$userId, $id]);
    audit('finance_reconciliation_review', 'finance_reconciliation', $id, ['status' => 'draft'], ['status' => 'reviewed']);
    return ['ok' => true, 'error' => null];
}

function finance_reconciliations(int $accountId=0, int $limit=100): array
{
    if (!finance_table_exists('finance_reconciliations')) return [];
    $where = $accountId > 0 ? 'WHERE r.account_id=?' : '';
    $args = $accountId > 0 ? [$accountId] : [];
    return rows(
        'SELECT r.*,a.name account_name,p.name prepared_name,v.name reviewed_name
         FROM finance_reconciliations r
         LEFT JOIN finance_bank_accounts a ON a.id=r.account_id
         LEFT JOIN users p ON p.id=r.prepared_by
         LEFT JOIN users v ON v.id=r.reviewed_by
         '.$where.' ORDER BY r.period_end DESC,r.id DESC LIMIT '.max(1, min(500, $limit)),
        $args
    );
}

function finance_daily_series(string $from, string $to): array
{
    return rows(
        "SELECT DATE(created_at) day,COALESCE(SUM(CASE WHEN status='successful' THEN amount ELSE 0 END),0) received,
                COALESCE(SUM(CASE WHEN status='pending' THEN amount ELSE 0 END),0) pending
         FROM payments WHERE created_at>=? AND created_at<? GROUP BY DATE(created_at) ORDER BY day",
        [$from, date('Y-m-d', strtotime($to.' +1 day'))]
    );
}

function finance_outlet_totals(string $from, string $toEx): array
{
    return rows(
        "SELECT o.outlet,COUNT(*) orders,COALESCE(SUM(o.subtotal),0) subtotal,COALESCE(SUM(o.tax),0) tax,
                COALESCE(SUM(o.discount),0) discount,COALESCE(SUM(o.total),0) total
         FROM orders o WHERE o.deleted_at IS NULL AND o.status<>'cancelled' AND o.created_at>=? AND o.created_at<?
         GROUP BY o.outlet ORDER BY total DESC",
        [$from, $toEx]
    );
}

function finance_expense_totals(string $from, string $toEx): array
{
    return rows(
        "SELECT e.category,COUNT(*) requests,COALESCE(SUM(e.amount),0) amount
         FROM expenses e WHERE e.deleted_at IS NULL AND e.status IN('approved','paid') AND e.created_at>=? AND e.created_at<?
         GROUP BY e.category ORDER BY amount DESC",
        [$from, $toEx]
    );
}

function finance_finding(string $type, string $severity, string $key, string $title, string $detail, array $extra=[]): array
{
    return array_merge([
        'type' => $type,
        'severity' => $severity,
        'key' => $key,
        'title' => $title,
        'detail' => $detail,
        'ref_type' => '',
        'ref_id' => null,
        'amount' => null,
        'expected' => null,
        'status' => 'open',
    ], $extra);
}

function finance_findings(string $from, string $toEx, int $limit=250): array
{
    $out = [];
    $stored = [];
    if (finance_table_exists('integrity_flags')) {
        foreach (rows("SELECT id,flag_key,status FROM integrity_flags WHERE flag_type LIKE 'finance_%'") as $r) {
            $stored[$r['flag_key']] = ['id' => (int)$r['id'], 'status' => $r['status']];
        }
    }
    $add = static function(array $f) use (&$out, $stored): void {
        if (isset($stored[$f['key']])) {
            $f['id'] = $stored[$f['key']]['id'];
            $f['status'] = $stored[$f['key']]['status'];
        }
        $out[] = $f;
    };

    $noDate = (int)val('SELECT COUNT(*) FROM payments WHERE created_at IS NULL');
    if ($noDate > 0) $add(finance_finding('data_quality', 'medium', 'finance:payments:missing-date',
        'Payments without a timestamp', $noDate.' payment record(s) have no created_at value, so they cannot be placed reliably in a shift or period.', ['amount' => null]));

    $zero = rows("SELECT id,amount,method,created_at FROM payments WHERE status='successful' AND amount<=0 LIMIT 50");
    foreach ($zero as $p) $add(finance_finding('payment_integrity', 'high', 'finance:payment:zero:'.(int)$p['id'],
        'Successful payment with no value', 'Payment #'.(int)$p['id'].' is marked successful but its amount is zero or negative.',
        ['ref_type' => 'payment', 'ref_id' => (int)$p['id'], 'amount' => (float)$p['amount']]));

    $fullyPaid = rows(
        "SELECT o.id,o.order_number,o.status,o.total,
                COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.order_id=o.id AND p.status='successful'),0) paid
         FROM orders o WHERE o.deleted_at IS NULL AND o.status NOT IN('paid','cancelled')
           AND COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.order_id=o.id AND p.status='successful'),0)+0.009>=o.total
         ORDER BY o.id DESC LIMIT 50"
    );
    foreach ($fullyPaid as $o) $add(finance_finding('order_status', 'medium', 'finance:order:paid-not-marked:'.(int)$o['id'],
        'Paid order still open', 'Order '.$o['order_number'].' is fully paid but its status is '.$o['status'].'.',
        ['ref_type' => 'order', 'ref_id' => (int)$o['id'], 'amount' => (float)$o['paid'], 'expected' => (float)$o['total']]));

    $underPaid = rows(
        "SELECT o.id,o.order_number,o.status,o.total,
                COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.order_id=o.id AND p.status='successful'),0) paid
         FROM orders o WHERE o.deleted_at IS NULL AND o.status='paid'
           AND COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.order_id=o.id AND p.status='successful'),0)+0.009<o.total
         ORDER BY o.id DESC LIMIT 50"
    );
    foreach ($underPaid as $o) $add(finance_finding('order_status', 'high', 'finance:order:short-paid:'.(int)$o['id'],
        'Order marked paid below its total', 'Order '.$o['order_number'].' is marked paid but successful payments total '.money($o['paid']).' against '.money($o['total']).'.',
        ['ref_type' => 'order', 'ref_id' => (int)$o['id'], 'amount' => (float)$o['paid'], 'expected' => (float)$o['total']]));

    $dupes = rows(
        "SELECT provider_reference,COUNT(*) n,SUM(amount) total,MIN(id) first_id
         FROM payments WHERE status='successful' AND provider_reference IS NOT NULL AND provider_reference<>''
         GROUP BY provider_reference HAVING COUNT(*)>1 ORDER BY n DESC LIMIT 50"
    );
    foreach ($dupes as $d) $add(finance_finding('duplicate_reference', 'high', 'finance:payment:duplicate-ref:'.$d['provider_reference'],
        'Duplicate successful reference', 'Reference '.$d['provider_reference'].' appears on '.$d['n'].' successful payments totalling '.money($d['total']).'.',
        ['ref_type' => 'payment', 'ref_id' => (int)$d['first_id'], 'amount' => (float)$d['total']]));

    $cashNoShift = rows(
        "SELECT id,amount,created_at,user_id FROM payments
         WHERE status='successful' AND method='cash' AND created_at>=? AND created_at<? AND shift_id IS NULL
         ORDER BY id DESC LIMIT 50",
        [$from, $toEx]
    );
    foreach ($cashNoShift as $p) $add(finance_finding('shift_integrity', 'low', 'finance:payment:no-shift:'.(int)$p['id'],
        'Cash payment not linked to a shift', 'Payment #'.(int)$p['id'].' ('.money($p['amount']).') has no shift reference.', 
        ['ref_type' => 'payment', 'ref_id' => (int)$p['id'], 'amount' => (float)$p['amount']]));

    $invoiceShort = rows(
        "SELECT i.id,i.invoice_number,i.total,i.status,
                COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.invoice_id=i.id AND p.status='successful'),0) paid
         FROM invoices i WHERE i.deleted_at IS NULL AND i.status='paid'
           AND COALESCE((SELECT SUM(p.amount) FROM payments p WHERE p.invoice_id=i.id AND p.status='successful'),0)+0.009<i.total
         LIMIT 50"
    );
    foreach ($invoiceShort as $i) $add(finance_finding('invoice_integrity', 'high', 'finance:invoice:short-paid:'.(int)$i['id'],
        'Invoice marked paid below its total', 'Invoice '.$i['invoice_number'].' is paid but only '.money($i['paid']).' of '.money($i['total']).' has been received.',
        ['ref_type' => 'invoice', 'ref_id' => (int)$i['id'], 'amount' => (float)$i['paid'], 'expected' => (float)$i['total']]));

    $expenseNoDate = rows("SELECT id,number,amount FROM expenses WHERE status='paid' AND paid_at IS NULL LIMIT 50");
    foreach ($expenseNoDate as $e) $add(finance_finding('expense_integrity', 'medium', 'finance:expense:no-paid-date:'.(int)$e['id'],
        'Paid expense without payment date', 'Expense '.$e['number'].' is marked paid but has no paid_at timestamp.',
        ['ref_type' => 'expense', 'ref_id' => (int)$e['id'], 'amount' => (float)$e['amount']]));

    if (finance_journal_ready()) {
        $unbalanced = rows(
            "SELECT e.id,e.entry_number,e.entry_date,SUM(l.debit) debit,SUM(l.credit) credit
             FROM journal_entries e JOIN journal_lines l ON l.journal_entry_id=e.id
             WHERE e.status='posted' GROUP BY e.id,e.entry_number,e.entry_date
             HAVING ABS(SUM(l.debit)-SUM(l.credit))>0.009 LIMIT 50"
        );
        foreach ($unbalanced as $j) $add(finance_finding('journal_integrity', 'high', 'finance:journal:unbalanced:'.(int)$j['id'],
            'Unbalanced posted journal', 'Journal '.$j['entry_number'].' has debits of '.money($j['debit']).' and credits of '.money($j['credit']).'.',
            ['ref_type' => 'journal_entry', 'ref_id' => (int)$j['id'], 'amount' => (float)$j['debit'], 'expected' => (float)$j['credit']]));
    }

    $closed = rows(
        "SELECT id,outlet,expected_cash,counted_cash,variance,closed_at FROM shifts
         WHERE status='closed' AND ABS(variance)>0.009 AND closed_at>=? AND closed_at<?
         ORDER BY ABS(variance) DESC LIMIT 50",
        [$from, $toEx]
    );
    foreach ($closed as $s) $add(finance_finding('shift_variance', 'medium', 'finance:shift:variance:'.(int)$s['id'],
        'Closed shift with a cash variance', ucfirst($s['outlet']).' shift closed '.fmtdt($s['closed_at']).' with a variance of '.($s['variance'] < 0 ? '-' : '').money(abs((float)$s['variance'])).'.',
        ['ref_type' => 'shift', 'ref_id' => (int)$s['id'], 'amount' => (float)$s['counted_cash'], 'expected' => (float)$s['expected_cash']]));

    $oldOpen = rows("SELECT id,outlet,opened_at,user_id FROM shifts WHERE status='open' AND opened_at<? ORDER BY opened_at LIMIT 50", [date('Y-m-d H:i:s', time() - 86400)]);
    foreach ($oldOpen as $s) $add(finance_finding('open_shift', 'medium', 'finance:shift:old-open:'.(int)$s['id'],
        'Shift open for more than a day', ucfirst($s['outlet']).' shift opened '.fmtdt($s['opened_at']).' is still open.',
        ['ref_type' => 'shift', 'ref_id' => (int)$s['id']]));

    if (finance_table_exists('efris_invoices')) {
        $failed = rows("SELECT id,invoice_id,status,last_error FROM efris_invoices WHERE status IN('failed','retrying') LIMIT 50");
        foreach ($failed as $e) $add(finance_finding('efris', 'high', 'finance:efris:failed:'.(int)$e['id'],
            'eFRIS submission needs attention', 'Invoice #'.(int)$e['invoice_id'].' is '.$e['status'].'. '.mb_substr((string)$e['last_error'], 0, 220),
            ['ref_type' => 'invoice', 'ref_id' => (int)$e['invoice_id']]));
    }

    if (finance_table_exists('finance_cash_movements')) {
        $large = rows(
            "SELECT id,shift_id,amount,direction,reason,created_at FROM finance_cash_movements
             WHERE amount>=500000 AND status='recorded' AND created_at>=? AND created_at<? ORDER BY amount DESC LIMIT 50",
            [$from, $toEx]
        );
        foreach ($large as $m) $add(finance_finding('cash_movement', 'medium', 'finance:cash:large:'.(int)$m['id'],
            'Large unreviewed drawer movement', money($m['amount']).' '.($m['direction'] === 'in' ? 'into' : 'out of').' the drawer: '.$m['reason'].'.',
            ['ref_type' => 'shift', 'ref_id' => (int)$m['shift_id'], 'amount' => (float)$m['amount']]));
    }

    usort($out, static fn(array $a, array $b): int => $a['status'] === 'open' && $b['status'] !== 'open' ? -1 : ($a['status'] !== 'open' && $b['status'] === 'open' ? 1 : ((['high' => 0, 'medium' => 1, 'low' => 2][$a['severity']] ?? 3) <=> (['high' => 0, 'medium' => 1, 'low' => 2][$b['severity']] ?? 3))));
    return array_slice($out, 0, $limit);
}

function finance_store_findings(array $findings, int $userId): int
{
    if (!finance_table_exists('integrity_flags')) return 0;
    $n = 0;
    foreach ($findings as $f) {
        $refType = (string)($f['ref_type'] ?? '');
        q(
            "INSERT INTO integrity_flags(hotel_id,flag_key,flag_type,severity,ref_type,ref_id,amount,expected,detail,status,seen_at,created_at)
             VALUES(1,?,?,?,?,?,?,?,?,'open',NOW(),NOW())
             ON DUPLICATE KEY UPDATE severity=VALUES(severity),ref_type=VALUES(ref_type),ref_id=VALUES(ref_id),
               amount=VALUES(amount),expected=VALUES(expected),detail=VALUES(detail),seen_at=NOW(),updated_at=NOW()",
            [$f['key'], 'finance_'.$f['type'], $f['severity'], $refType, $f['ref_id'], $f['amount'], $f['expected'], mb_substr($f['title'].'. '.$f['detail'], 0, 500)]
        );
        $n++;
    }
    audit('finance_findings_scan', 'integrity_flags', null, [], ['findings' => $n, 'user' => $userId]);
    return $n;
}

function finance_review_finding(int $id, string $status, string $reason, int $userId): array
{
    if (!finance_table_exists('integrity_flags')) return ['ok' => false, 'error' => 'The findings register is not installed.'];
    $allowed = ['open', 'reviewed', 'cleared'];
    if (!in_array($status, $allowed, true)) return ['ok' => false, 'error' => 'Invalid finding status.'];
    $f = row("SELECT * FROM integrity_flags WHERE id=? AND flag_type LIKE 'finance_%'", [$id]);
    if (!$f) return ['ok' => false, 'error' => 'Finance finding not found.'];
    q('UPDATE integrity_flags SET status=?,resolved_by=?,resolved_at=?,updated_at=NOW() WHERE id=?',
        [$status, $status === 'open' ? null : $userId, $status === 'open' ? null : now_s(), $id]);
    audit('finance_finding_'.$status, 'integrity_flag', $id, ['status' => $f['status'], 'reason' => $reason], ['status' => $status]);
    return ['ok' => true, 'error' => null];
}

function finance_csv_safe($value)
{
    if (!is_string($value)) return $value;
    if ($value !== '' && in_array($value[0], ['=', '+', '-', '@'], true)) return "'".$value;
    return $value;
}

function finance_csv_download(string $filename, array $headers, array $rows): void
{
    $name = preg_replace('/[^A-Za-z0-9._-]+/', '-', $filename) ?: 'finance-export.csv';
    if (!headers_sent()) {
        header('Content-Type: text/csv; charset=utf-8');
        header('Content-Disposition: attachment; filename="'.$name.'"');
        header('Cache-Control: no-store, no-cache, must-revalidate');
    }
    $out = fopen('php://output', 'w');
    if ($out === false) exit;
    fwrite($out, "\xEF\xBB\xBF");
    fputcsv($out, array_map('finance_csv_safe', $headers));
    foreach ($rows as $row) fputcsv($out, array_map('finance_csv_safe', array_values($row)));
    fclose($out);
    exit;
}

function finance_export_url(string $page, array $params=[]): string
{
    return BASE.'/index.php?'.http_build_query(array_merge(['page' => $page], $params, ['export' => 'csv']));
}

function finance_page_link(string $page, array $params=[]): string
{
    return BASE.'/index.php?'.http_build_query(array_merge(['page' => $page], $params));
}
