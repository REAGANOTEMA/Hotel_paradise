<?php
declare(strict_types=1);

/**
 * International currency support for Hotel Paradise on the Nile.
 *
 * The hotel quotes and settles in its own base currency (UGX). A guest may be
 * charged in another currency only when that currency is approved on the
 * merchant account and a real rate can be obtained. This file never invents a
 * rate: if the rate source cannot be reached, conversion fails and checkout
 * stays with the hotel's own currency rather than quoting a guess.
 *
 * The rate, its source and its timestamp travel with the payment so Finance can
 * show exactly what the guest was quoted and what Pesapal was asked to charge.
 */

/** Currencies this installation is allowed to present, from protected config. */
function intl_currencies(): array
{
    $cfg = function_exists('hp_config') ? hp_config() : [];
    $p = (isset($cfg['pesapal']) && is_array($cfg['pesapal'])) ? $cfg['pesapal'] : [];
    $list = $p['currencies'] ?? ['UGX', 'USD', 'EUR', 'GBP', 'KES', 'TZS'];
    if (!is_array($list)) return ['UGX'];
    $out = [];
    foreach ($list as $c) {
        $c = strtoupper(trim((string)$c));
        if (preg_match('/^[A-Z]{3}$/', $c)) $out[$c] = $c;
    }
    return $out === [] ? ['UGX'] : array_values($out);
}

/** The hotel's own quoted / settlement currency. */
function intl_base_currency(): string
{
    $cfg = function_exists('hp_config') ? hp_config() : [];
    $p = (isset($cfg['pesapal']) && is_array($cfg['pesapal'])) ? $cfg['pesapal'] : [];
    $c = strtoupper(trim((string)($p['base_currency'] ?? 'UGX')));
    return preg_match('/^[A-Z]{3}$/', $c) ? $c : 'UGX';
}

/** Whether a currency may be offered to a guest. */
function intl_currency_supported(string $currency): bool
{
    return in_array(strtoupper(trim($currency)), intl_currencies(), true);
}

/** Minor-unit precision. UGX has no minor unit; the others are quoted to cents. */
function intl_precision(string $currency): int
{
    return strtoupper(trim($currency)) === intl_base_currency() && intl_base_currency() === 'UGX' ? 0 : 2;
}

/** Round an amount the way this currency is actually displayed. */
function intl_round(float $amount, string $currency): float
{
    return round($amount, intl_precision($currency), PHP_ROUND_HALF_UP);
}

/** A human amount with the currency shown, so a guest is never unsure. */
function intl_money(float $amount, string $currency): string
{
    $c = strtoupper(trim($currency));
    return number_format($amount, intl_precision($c), '.', ',') . ' ' . $c;
}

/** A per-server signing key for rate quotes; generated once, never committed. */
function intl_quote_secret(): string
{
    $env = getenv('HP_QUOTE_SECRET');
    if (is_string($env) && $env !== '') return $env;
    $file = dirname(intl_storage_path()) . '/quote_secret.txt';
    if (is_file($file)) {
        $key = trim((string)@file_get_contents($file));
        if ($key !== '') return $key;
    }
    $key = bin2hex(random_bytes(32));
    @file_put_contents($file, $key, LOCK_EX);
    @chmod($file, 0600);
    return $key;
}

/** Sign a quote so the guest's approved amount cannot be altered later. */
function intl_quote_sign(array $quote): string
{
    $payload = rtrim(strtr(base64_encode(json_encode($quote, JSON_UNESCAPED_SLASHES) ?: ''), '+/', '-_'), '=');
    $sig = rtrim(strtr(base64_encode(hash_hmac('sha256', $payload, intl_quote_secret(), true)), '+/', '-_'), '=');
    return $payload . '.' . $sig;
}

/** Read a quote back, rejecting anything changed, stale or malformed. */
function intl_quote_read(string $token): array
{
    $parts = explode('.', $token, 2);
    if (count($parts) !== 2) return [];
    $expected = rtrim(strtr(base64_encode(hash_hmac('sha256', $parts[0], intl_quote_secret(), true)), '+/', '-_'), '=');
    if (!hash_equals($expected, $parts[1])) return [];
    $raw = base64_decode(strtr($parts[0], '-_', '+/'), true);
    if ($raw === false) return [];
    $quote = json_decode($raw, true);
    if (!is_array($quote)) return [];
    if ((int)($quote['exp'] ?? 0) < time()) return [];
    return $quote;
}

/** Scratch directory for the cached rate; never reachable from the web root. */
function intl_storage_path(): string
{
    $dir = __DIR__ . '/../storage';
    if (!is_dir($dir)) @mkdir($dir, 0775, true);
    $ht = $dir . '/.htaccess';
    if (!file_exists($ht)) @file_put_contents($ht, "Require all denied\nDeny from all\n");
    return $dir . '/fx.json';
}

/**
 * The live rate source. Public and keyless by default, overridable by the host
 * with HP_FX_URL so a hotel can point at its own contracted rate provider.
 * No key or secret is ever read from the browser or written to this file.
 */
function intl_fx_endpoint(string $base): string
{
    $configured = getenv('HP_FX_URL');
    if (is_string($configured) && $configured !== '') return $configured;
    return 'https://open.er-api.com/v6/latest/' . rawurlencode($base);
}

/**
 * Fetch, validate and cache one base rate.
 *
 * Returns ['ok','rate','source','as_of','error']. A missing, malformed, zero
 * or non-finite rate is always a failure. Nothing here substitutes a fallback
 * number: an honest failure is what keeps a wrong amount from being charged.
 */
function intl_fx_rate(string $from, string $to): array
{
    $from = strtoupper(trim($from));
    $to = strtoupper(trim($to));
    $fail = static fn(string $why): array => ['ok' => false, 'rate' => 0.0, 'source' => '', 'as_of' => '', 'error' => $why];
    if ($from === '' || $to === '') return $fail('No currency was supplied for the exchange rate.');
    if ($from === $to) return ['ok' => true, 'rate' => 1.0, 'source' => 'same currency', 'as_of' => gmdate('c'), 'error' => ''];

    $file = intl_storage_path();
    $key = $from . '_' . $to;
    $now = time();
    if (is_file($file)) {
        $cached = json_decode((string)@file_get_contents($file), true);
        if (is_array($cached) && isset($cached[$key]['rate'], $cached[$key]['fetched_at'])
            && is_numeric($cached[$key]['rate']) && (float)$cached[$key]['rate'] > 0
            && (int)$cached[$key]['fetched_at'] > $now - 3600) {
            return [
                'ok' => true,
                'rate' => (float)$cached[$key]['rate'],
                'source' => (string)($cached[$key]['source'] ?? ''),
                'as_of' => (string)($cached[$key]['as_of'] ?? ''),
                'error' => '',
            ];
        }
    }

    $url = intl_fx_endpoint($from);
    $raw = false;
    if (function_exists('curl_init')) {
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CONNECTTIMEOUT => 8,
            CURLOPT_TIMEOUT => 15,
            CURLOPT_SSL_VERIFYPEER => true,
            CURLOPT_SSL_VERIFYHOST => 2,
            CURLOPT_USERAGENT => 'HotelParadiseBooking/1.0',
        ]);
        $raw = curl_exec($ch);
        $code = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        if ($raw === false || $code < 200 || $code >= 300) {
            return $fail('A live exchange rate could not be obtained. The amount has not been changed.');
        }
    } else {
        $ctx = stream_context_create(['http' => ['timeout' => 15, 'ignore_errors' => true]]);
        $raw = @file_get_contents($url, false, $ctx);
        if ($raw === false) return $fail('A live exchange rate could not be obtained. The amount has not been changed.');
    }

    $json = json_decode((string)$raw, true);
    if (!is_array($json)) return $fail('The exchange rate service returned an unreadable answer.');

    // open.er-api.com shape: result="success", time_last_update_utc, rates{TO=x}.
    $rate = null;
    if (isset($json['rates']) && is_array($json['rates']) && isset($json['rates'][$to])) {
        $rate = $json['rates'][$to];
    } elseif (isset($json['rate'])) {
        $rate = $json['rate']; // host-provided endpoint returning a single rate
    }
    if (!is_numeric($rate) || (float)$rate <= 0 || !is_finite((float)$rate)) {
        return $fail('The exchange rate service did not supply a valid rate for ' . $to . '.');
    }

    $source = 'open.er-api.com';
    if (getenv('HP_FX_URL')) $source = 'merchant rate provider';
    $asOf = (string)($json['time_last_update_utc'] ?? $json['as_of'] ?? gmdate('c'));

    $store = is_file($file) ? json_decode((string)@file_get_contents($file), true) : [];
    if (!is_array($store)) $store = [];
    $store[$key] = ['rate' => (float)$rate, 'source' => $source, 'as_of' => $asOf, 'fetched_at' => $now];
    $tmp = $file . '.' . getmypid() . '.tmp';
    if (@file_put_contents($tmp, json_encode($store, JSON_PRETTY_PRINT), LOCK_EX) !== false) {
        if (!@rename($tmp, $file)) @unlink($tmp);
    }

    return ['ok' => true, 'rate' => (float)$rate, 'source' => $source, 'as_of' => $asOf, 'error' => ''];
}

/**
 * Convert the hotel's own price into the currency the guest chose.
 * Returns ['ok','amount','rate','source','as_of','error'].
 */
function intl_convert(float $baseAmount, string $base, string $target): array
{
    $base = strtoupper(trim($base));
    $target = strtoupper(trim($target));
    if (!intl_currency_supported($target)) {
        return ['ok' => false, 'amount' => 0.0, 'rate' => 0.0, 'source' => '', 'as_of' => '', 'error' => 'That currency is not accepted for payment here.'];
    }
    $fx = intl_fx_rate($base, $target);
    if (!$fx['ok']) {
        return ['ok' => false, 'amount' => 0.0, 'rate' => 0.0, 'source' => '', 'as_of' => '', 'error' => $fx['error']];
    }
    return [
        'ok' => true,
        'amount' => intl_round($baseAmount * $fx['rate'], $target),
        'rate' => $fx['rate'],
        'source' => $fx['source'],
        'as_of' => $fx['as_of'],
        'error' => '',
    ];
}

/**
 * Validate the identifiers a guest from any country is asked for.
 * Phone numbers are kept in E.164 form; nothing card-related is ever accepted.
 */
function intl_phone(string $phone): string
{
    $p = trim($phone);
    if ($p === '') return '';
    if ($p[0] !== '+') $p = '+' . ltrim($p, '+');
    $digits = preg_replace('/\D/', '', $p) ?? '';
    if (strlen($digits) === 10 && strpos($digits, '0') === 0) $digits = '256' . substr($digits, 1);
    if (strlen($digits) < 7 || strlen($digits) > 15) return '';
    return '+' . $digits;
}

/** ISO 3166-1 alpha-2, upper case, or an empty string. */
function intl_country(string $country): string
{
    $c = strtoupper(trim($country));
    return preg_match('/^[A-Z]{2}$/', $c) ? $c : '';
}
