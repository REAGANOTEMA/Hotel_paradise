<?php
declare(strict_types=1);
$u = current_user();
$uid = (int)($u["id"] ?? 0);

if ($_SERVER["REQUEST_METHOD"] === "POST") {
  $act = $_GET["act"] ?? "";
  if ($act === "update") {
    $name = trim($_POST["name"] ?? "");
    $phone = trim($_POST["phone"] ?? "");
    if ($name === "") {
      flash("Name is required.", "bad");
      go("profile");
    }
    q("UPDATE users SET name=?, phone=?, updated_at=NOW() WHERE id=?", [$name, $phone, $uid]);
    audit("update_profile", "user", $uid);
    flash("Profile updated successfully.");
    go("profile");
  } elseif ($act === "changepass") {
    $current = $_POST["current"] ?? "";
    $new = $_POST["new"] ?? "";
    $confirm = $_POST["confirm"] ?? "";
    if ($new !== $confirm) {
      flash("New passwords do not match.", "bad");
      go("profile");
    }
    if (strlen($new) < 8) {
      flash("Password must be at least 8 characters.", "bad");
      go("profile");
    }
    $cu = row("SELECT password_hash FROM users WHERE id=? AND status=\"active\"", [$uid]);
    if (!$cu || !password_verify($current, $cu["password_hash"])) {
      flash("Current password is incorrect.", "bad");
      go("profile");
    }
    q("UPDATE users SET password_hash=?, password_changed_at=NOW() WHERE id=?", [password_hash($new, PASSWORD_DEFAULT), $uid]);
    audit("change_password", "user", $uid);
    flash("Password changed successfully.");
    go("profile");
  }
}

$me = row("SELECT * FROM users WHERE id=?", [$uid]);

page_head("My Profile", "dashboard", "Manage your account settings");
echo "<div class=\"twoCol\">";
echo "<div class=\"panel\">";
echo "<h2>Personal Information</h2>";
echo "<p class=\"hint\">Update your name and phone number.</p>";
form_open("profile", "update");
echo "<div class=\"field\"><label>Full Name</label><input name=\"name\" value=\"" . e($me["name"] ?? "") . "\" required></div>";
echo "<div class=\"field\"><label>Email</label><input value=\"" . e($me["email"] ?? "") . "\" readonly style=\"background:#f8f9fa;cursor:not-allowed\"></div>";
echo "<div class=\"field\"><label>Phone</label><input name=\"phone\" value=\"" . e($me["phone"] ?? "") . "\"></div>";
echo "<button class=\"btn\">Update Profile</button>";
form_close();
echo "</div>";
echo "</div>";
echo "<div>";
echo "<div class=\"panel\">";
echo "<h2>Change Password</h2>";
echo "<p class=\"hint\">Set a new secure password for your account.</p>";
form_open("profile", "changepass");
echo "<div class=\"field\"><label>Current Password</label><input type=\"password\" name=\"current\" required autocomplete=\"current-password\"></div>";
echo "<div class=\"field\"><label>New Password</label><input type=\"password\" name=\"new\" required autocomplete=\"new-password\" minlength=\"8\"></div>";
echo "<div class=\"field\"><label>Confirm New Password</label><input type=\"password\" name=\"confirm\" required autocomplete=\"new-password\" minlength=\"8\"></div>";
echo "<button class=\"btn\">Change Password</button>";
form_close();
echo "</div>";
echo "</div>";
echo "</div>";
page_foot();
