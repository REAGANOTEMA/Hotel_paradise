<?php
declare(strict_types=1);
require __DIR__."/app/bootstrap.php";

if (!current_user()) {
  http_response_code(401);
  exit("Unauthorized");
}

$type = $_GET["type"] ?? "";
$id = (int)($_GET["id"] ?? 0);

if ($type === "recording" && $id > 0) {
  if (!has_role("director") && !has_role("super_admin")) {
    http_response_code(403);
    exit("Forbidden - Director access only");
  }
  $rec = row("SELECT * FROM voice_recordings WHERE id=? AND hotel_id=1", [$id]);
  if (!$rec) {
    http_response_code(404);
    exit("Not found");
  }
  $filepath = __DIR__ . "/storage/recordings/" . $rec["filename"];
  if (!file_exists($filepath)) {
    http_response_code(404);
    exit("File not found");
  }
  $mime = $rec["mime_type"] ?: "audio/webm";
  header("Content-Type: " . $mime);
  header("Content-Length: " . filesize($filepath));
  header("X-Content-Type-Options: nosniff");
  header("Cache-Control: no-cache, must-revalidate");
  readfile($filepath);
  exit;
}

if ($type === "profile" && $id > 0) {
  $uid = (int)current_user()['id'] ?? 0;
  if ($uid !== $id && !has_role("director") && !has_role("super_admin") && !has_role("general_manager")) {
    http_response_code(403);
    exit("Forbidden");
  }
  $user = row("SELECT profile_image FROM users WHERE id=?", [$id]);
  if (!$user || !$user['profile_image']) {
    http_response_code(404);
    exit("Not found");
  }
  $filepath = __DIR__ . "/storage/profile/" . $user['profile_image'];
  if (!file_exists($filepath)) {
    http_response_code(404);
    exit("Not found");
  }
  $ext = strtolower(pathinfo($filepath, PATHINFO_EXTENSION));
  $mime = 'image/jpeg';
  if ($ext === 'png') $mime = 'image/png';
  if ($ext === 'gif') $mime = 'image/gif';
  if ($ext === 'webp') $mime = 'image/webp';
  header("Content-Type: " . $mime);
  header("Content-Length: " . filesize($filepath));
  header("X-Content-Type-Options: nosniff");
  readfile($filepath);
  exit;
}

if ($type === "integrity") {
  if (!has_role("director") && !has_role("super_admin") && !has_role("general_manager") && !has_role("auditor")) {
    http_response_code(403);
    exit("Forbidden - oversight access only");
  }
  $status = $_GET["status"] ?? "open_cleared";
  $where = "hotel_id=1";
  if ($status === "open") $where .= " AND status='open'";
  elseif ($status === "all") $where = "hotel_id=1";
  else $where .= " AND status IN('open','reviewed')";
  $rows = [];
  try {
    $rows = rows("SELECT id,seen_at,flag_type,severity,status,staff_name,guest_name,room_id,
      reservation_id,amount,expected,detail FROM integrity_flags WHERE $where
      ORDER BY FIELD(severity,'high','medium','low'),id DESC");
  } catch (\Throwable $e) { $rows = []; }

  header("Content-Type: text/csv; charset=utf-8");
  header("Content-Disposition: attachment; filename=integrity-".date("Ymd-His").".csv");
  header("X-Content-Type-Options: nosniff");
  $out = fopen("php://output", "w");
  fputs($out, "\xEF\xBB\xBF");
  fputcsv($out, ["ID","Found","Type","Severity","Status","Staff","Guest","Room","Reservation","Amount","Expected","Detail"]);
  foreach ($rows as $r) {
    fputcsv($out, [
      $r["id"], $r["seen_at"], $r["flag_type"], $r["severity"], $r["status"],
      $r["staff_name"], $r["guest_name"], $r["room_id"], $r["reservation_id"],
      $r["amount"], $r["expected"], $r["detail"],
    ]);
  }
  fclose($out);
  exit;
}

http_response_code(400);
exit("Invalid request");

