<?php
/**
 * Generate password hash for admin123
 * Run this once to get the correct hash
 */

$password = 'admin123';
$hash = password_hash($password, PASSWORD_BCRYPT);

echo "Password: $password\n";
echo "Hash: $hash\n";
echo "\n";
echo "Verification: " . (password_verify($password, $hash) ? 'SUCCESS' : 'FAILED') . "\n";
echo "\n";
echo "SQL Update:\n";
echo "UPDATE users SET password = '$hash' WHERE email = 'admin@civicore.gov';\n";
