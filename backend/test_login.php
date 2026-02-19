<?php
/**
 * Test Login Endpoint
 * Use this to verify password hashing and verification
 */

require_once __DIR__ . '/config/database.php';

header('Content-Type: application/json');

$database = new Database();
$db = $database->getConnection();

// Test password verification
$testPassword = 'admin123';
$testEmail = 'admin@civicore.gov';

// Get user from database
$stmt = $db->prepare("
    SELECT id, email, password, full_name, role_id, is_active 
    FROM users 
    WHERE email = ?
");
$stmt->execute([$testEmail]);
$user = $stmt->fetch();

if (!$user) {
    echo json_encode([
        'success' => false,
        'message' => 'User not found in database',
        'email' => $testEmail
    ]);
    exit;
}

// Test password verification
$passwordMatch = password_verify($testPassword, $user['password']);

// Generate new hash for comparison
$newHash = password_hash($testPassword, PASSWORD_BCRYPT);
$newHashMatch = password_verify($testPassword, $newHash);

echo json_encode([
    'success' => true,
    'user_found' => true,
    'user_id' => $user['id'],
    'email' => $user['email'],
    'full_name' => $user['full_name'],
    'is_active' => (bool)$user['is_active'],
    'role_id' => $user['role_id'],
    'current_hash' => $user['password'],
    'password_verify_current' => $passwordMatch,
    'new_hash' => $newHash,
    'password_verify_new' => $newHashMatch,
    'test_password' => $testPassword,
    'recommendation' => $passwordMatch ? 'Password is correct!' : 'Password hash needs update. Use the new_hash below.'
], JSON_PRETTY_PRINT);
