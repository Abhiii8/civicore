<?php
/**
 * Debug endpoint to test authentication
 * This helps diagnose authorization issues
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

require_once __DIR__ . '/config/jwt.php';
require_once __DIR__ . '/middleware/auth.php';

$auth = new AuthMiddleware();

// Get all headers
$headers = [];
if (function_exists('getallheaders')) {
    $headers = getallheaders();
}

$result = [
    'success' => true,
    'debug' => [
        'has_getallheaders' => function_exists('getallheaders'),
        'headers_from_getallheaders' => $headers,
        'HTTP_AUTHORIZATION' => $_SERVER['HTTP_AUTHORIZATION'] ?? 'NOT SET',
        'REDIRECT_HTTP_AUTHORIZATION' => $_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? 'NOT SET',
        'all_http_headers' => [],
    ],
    'auth_result' => null,
];

// Get all HTTP_ headers
foreach ($_SERVER as $key => $value) {
    if (strpos($key, 'HTTP_') === 0) {
        $result['debug']['all_http_headers'][$key] = $value;
    }
}

// Try to validate auth
$user = $auth->validateAuth();
if ($user) {
    $result['auth_result'] = [
        'authenticated' => true,
        'user_id' => $user['user_id'] ?? null,
        'email' => $user['email'] ?? null,
        'role' => $user['role'] ?? null,
    ];
} else {
    $result['auth_result'] = [
        'authenticated' => false,
        'message' => 'No valid token found',
    ];
}

echo json_encode($result, JSON_PRETTY_PRINT);
