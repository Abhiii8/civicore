<?php
/**
 * Test endpoint to verify backend is accessible
 */
header('Content-Type: application/json');
echo json_encode([
    'success' => true,
    'message' => 'Backend is working!',
    'uri' => $_SERVER['REQUEST_URI'] ?? 'unknown',
    'method' => $_SERVER['REQUEST_METHOD'] ?? 'unknown',
]);
