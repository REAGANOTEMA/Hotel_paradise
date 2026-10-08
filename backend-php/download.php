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
  readfile($filepath);
  exit;
}

http_response_code(400);
exit("Invalid request");

