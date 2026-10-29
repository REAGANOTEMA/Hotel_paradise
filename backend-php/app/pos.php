<?php
declare(strict_types=1);

const POS_SERVICE_RATE = 0.035;

function pos_service_charge(float $amount): float
{
    return round(max(0.0, $amount) * POS_SERVICE_RATE, 2);
}

function pos_order_totals(float $subtotal, float $discount = 0.0): array
{
    $subtotal = round(max(0.0, $subtotal), 2);
    $tax = pos_service_charge($subtotal);
    $beforeDiscount = round($subtotal + $tax, 2);
    $discount = round(min(max(0.0, $discount), $beforeDiscount), 2);
    $total = round($beforeDiscount - $discount, 2);

    return [
        'subtotal' => $subtotal,
        'tax' => $tax,
        'discount' => $discount,
        'total' => $total,
    ];
}

function pos_order_paid(int $orderId): float
{
    return round((float)val(
        "SELECT COALESCE(SUM(amount),0) FROM payments WHERE order_id=? AND status='successful'",
        [$orderId]
    ), 2);
}

function pos_payment_method(string $method): ?string
{
    $method = trim($method);
    return array_key_exists($method, payment_methods()) ? $method : null;
}

function pos_payments_have_shift_id(): bool
{
    static $has = null;
    if ($has === null) {
        try {
            $has = val("SHOW COLUMNS FROM payments LIKE 'shift_id'") !== null;
        } catch (Throwable $e) {
            $has = false;
        }
    }
    return $has;
}

function pos_open_shift_id(int $userId): ?int
{
    if ($userId <= 0 || !hp_table_exists('shifts')) return null;
    $id = (int)val(
        "SELECT id FROM shifts WHERE user_id=? AND status='open' ORDER BY id DESC LIMIT 1",
        [$userId]
    );
    return $id > 0 ? $id : null;
}

function pos_settle_order(array $order, float $amount, string $method, float $discount, int $userId, array $meta = []): array
{
    $orderId = (int)($order['id'] ?? 0);
    $method = (string)(pos_payment_method($method) ?? '');
    $amount = round($amount, 2);
    $discount = round(max(0.0, $discount), 2);
    $reference = mb_substr(trim((string)($meta['reference'] ?? '')), 0, 190);
    $payerPhone = mb_substr(trim((string)($meta['payer_phone'] ?? '')), 0, 50);

    if ($orderId <= 0) return ['ok' => false, 'error' => 'That order could not be found.'];
    if ($method === '') return ['ok' => false, 'error' => 'Choose a valid payment method.'];
    if ($amount <= 0) return ['ok' => false, 'error' => 'Enter the amount collected.'];

    $pdo = db();

    try {
        $pdo->beginTransaction();
        $locked = row('SELECT * FROM orders WHERE id=? FOR UPDATE', [$orderId]);
        if (!$locked) {
            $pdo->rollBack();
            return ['ok' => false, 'error' => 'That order could not be found.'];
        }
        if ((string)$locked['status'] === 'cancelled') {
            $pdo->rollBack();
            return ['ok' => false, 'error' => 'A cancelled order cannot take a payment.'];
        }

        $subtotal = round(max(0.0, (float)($locked['subtotal'] ?? 0)), 2);
        $existingDiscount = round(max(0.0, (float)($locked['discount'] ?? 0)), 2);
        $paid = pos_order_paid($orderId);

        if ($paid > 0.001 && $discount > 0) {
            $pdo->rollBack();
            return ['ok' => false, 'error' => 'A discount must be applied before the first payment.'];
        }

        $effectiveDiscount = $discount > 0 ? $discount : $existingDiscount;
        $totals = pos_order_totals($subtotal, $effectiveDiscount);
        $due = round(max(0.0, $totals['total'] - $paid), 2);

        if ($due <= 0.001) {
            $pdo->rollBack();
            return ['ok' => false, 'error' => 'This order is already fully paid.'];
        }
        if ($amount > $due + 0.001) {
            $pdo->rollBack();
            return ['ok' => false, 'error' => 'The amount collected is more than the balance of '.money($due).'.'];
        }

        $paymentShiftId = pos_open_shift_id($userId);
        $payCols = ['hotel_id', 'user_id', 'order_id'];
        $payVals = [1, $userId, $orderId];
        if (pos_payments_have_shift_id()) {
            $payCols[] = 'shift_id';
            $payVals[] = $paymentShiftId;
        }
        $payCols = array_merge($payCols, ['amount', 'method', 'provider_reference', 'payer_phone', 'status']);
        $payVals = array_merge($payVals, [
            $amount,
            $method,
            $reference !== '' ? $reference : null,
            $payerPhone !== '' ? $payerPhone : null,
            'successful',
        ]);
        $payPlaceholders = implode(',', array_fill(0, count($payCols), '?'));
        q('INSERT INTO payments('.implode(',', $payCols).',created_at) VALUES('.$payPlaceholders.',NOW())', $payVals);
        $paymentId = (int)$pdo->lastInsertId();
        $newPaid = round($paid + $amount, 2);
        $newStatus = $newPaid + 0.001 >= $totals['total'] ? 'paid' : 'partially_paid';

        q('UPDATE orders SET discount=?,subtotal=?,tax=?,total=?,status=? WHERE id=?',
            [$totals['discount'], $totals['subtotal'], $totals['tax'], $totals['total'], $newStatus, $orderId]);
        $pdo->commit();
    } catch (Throwable $e) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        error_log('[hotel pos] payment failed for order '.$orderId.': '.$e->getMessage());
        return ['ok' => false, 'error' => 'The payment could not be recorded. Please try again.'];
    }

    audit('payment', 'order', $orderId, [
        'amount' => $amount,
        'method' => $method,
        'reference' => $reference,
        'payer_phone' => $payerPhone,
        'discount' => $totals['discount'],
        'total' => $totals['total'],
    ]);

    return [
        'ok' => true,
        'error' => null,
        'payment_id' => $paymentId,
        'amount' => $amount,
        'method' => $method,
        'reference' => $reference,
        'payer_phone' => $payerPhone,
        'paid' => $newPaid,
        'due' => round(max(0.0, $totals['total'] - $newPaid), 2),
        'status' => $newStatus,
        'totals' => $totals,
    ];
}

function pos_shift_expected_cash(array $shift): float
{
    $from = (string)($shift['opened_at'] ?? '');
    $to = (string)($shift['closed_at'] ?? '');
    if ($from === '') return round((float)($shift['opening_cash'] ?? 0), 2);
    if ($to === '') $to = now_s();

    $userId = (int)($shift['user_id'] ?? 0);
    $shiftId = (int)($shift['id'] ?? 0);

    if ($shiftId > 0 && pos_payments_have_shift_id()) {
        $cash = (float)val(
            "SELECT COALESCE(SUM(amount),0) FROM payments"
            ." WHERE status='successful' AND method='cash'"
            ." AND (shift_id=? OR (shift_id IS NULL AND user_id=? AND created_at BETWEEN ? AND ?))",
            [$shiftId, $userId, $from, $to]
        );
    } else {
        $cash = (float)val(
            "SELECT COALESCE(SUM(amount),0) FROM payments"
            ." WHERE user_id=? AND status='successful' AND method='cash' AND created_at BETWEEN ? AND ?",
            [$userId, $from, $to]
        );
    }

    $movementsIn = 0.0;
    $movementsOut = 0.0;
    if ($shiftId > 0 && hp_table_exists('finance_cash_movements')) {
        $movement = row(
            "SELECT COALESCE(SUM(CASE WHEN direction='in' AND status IN('recorded','approved') THEN amount ELSE 0 END),0) cash_in,
                    COALESCE(SUM(CASE WHEN direction='out' AND status IN('recorded','approved') THEN amount ELSE 0 END),0) cash_out
             FROM finance_cash_movements WHERE shift_id=?",
            [$shiftId]
        ) ?: [];
        $movementsIn = (float)($movement['cash_in'] ?? 0);
        $movementsOut = (float)($movement['cash_out'] ?? 0);
    }

    return round((float)($shift['opening_cash'] ?? 0) + $cash + $movementsIn - $movementsOut, 2);
}
