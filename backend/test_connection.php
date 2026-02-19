<?php
/**
 * Connection Test Endpoint
 * 
 * Use this to verify backend is accessible from Flutter app
 * URL: http://localhost/civicore/backend/test_connection.php
 * Or: http://10.0.2.2/civicore/backend/test_connection.php (from Android emulator)
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$response = [
    'success' => true,
    'message' => 'Backend connection successful!',
    'timestamp' => date('Y-m-d H:i:s'),
    'server' => $_SERVER['SERVER_NAME'] ?? 'unknown',
    'method' => $_SERVER['REQUEST_METHOD'] ?? 'unknown',
    'uri' => $_SERVER['REQUEST_URI'] ?? 'unknown',
    'php_version' => phpversion(),
    'apache_running' => function_exists('apache_get_version'),
];

// Test database connection
try {
    require_once __DIR__ . '/config/database.php';
    $database = new Database();
    $db = $database->getConnection();
    $response['database'] = 'Connected';
} catch (Exception $e) {
    $response['database'] = 'Error: ' . $e->getMessage();
}

echo json_encode($response, JSON_PRETTY_PRINT);
