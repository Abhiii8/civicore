<?php
/**
 * CiviCore - Authentication Middleware
 * 
 * Validates JWT tokens and ensures user is authenticated
 * Supports role-based access control (RBAC)
 */

require_once __DIR__ . '/../config/jwt.php';

class AuthMiddleware {
    private $jwt;

    public function __construct() {
        $this->jwt = new JWT();
    }

    /**
     * Validate authentication token
     * @return array|false User data or false if invalid
     */
    public function validateAuth() {
        $token = null;

        // Get token from Authorization header - try multiple methods for compatibility
        $authHeader = null;
        
        // Method 1: Try getallheaders() (works in Apache)
        if (function_exists('getallheaders')) {
            $headers = getallheaders();
            if (isset($headers['Authorization'])) {
                $authHeader = $headers['Authorization'];
            } elseif (isset($headers['authorization'])) {
                $authHeader = $headers['authorization'];
            }
        }
        
        // Method 2: Try $_SERVER (works in all environments)
        if (!$authHeader) {
            if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
                $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
            } elseif (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
                $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
            }
        }
        
        // Extract token from header
        if ($authHeader && preg_match('/Bearer\s+(.*)$/i', $authHeader, $matches)) {
            $token = trim($matches[1]);
        }

        if (!$token || empty($token)) {
            error_log("CiviCore Auth: No token found. Headers: " . json_encode($_SERVER));
            return false;
        }

        $payload = $this->jwt->validateToken($token);
        if (!$payload) {
            error_log("CiviCore Auth: Token validation failed for token: " . substr($token, 0, 20) . "...");
        }
        return $payload;
    }

    /**
     * Check if user has required role
     * @param array $user User payload from JWT
     * @param string|array $requiredRoles Required role(s)
     * @return bool
     */
    public function hasRole($user, $requiredRoles) {
        if (!isset($user['role'])) {
            return false;
        }

        // Normalize role to lowercase for comparison
        $userRole = strtolower($user['role']);

        if (is_array($requiredRoles)) {
            $normalizedRoles = array_map('strtolower', $requiredRoles);
            return in_array($userRole, $normalizedRoles);
        }

        return $userRole === strtolower($requiredRoles);
    }

    /**
     * Require authentication
     * @return array User data
     */
    public function requireAuth() {
        $user = $this->validateAuth();
        if (!$user) {
            http_response_code(401);
            echo json_encode(['success' => false, 'message' => 'Unauthorized']);
            exit;
        }
        return $user;
    }

    /**
     * Require specific role
     * @param string|array $requiredRoles
     * @return array User data
     */
    public function requireRole($requiredRoles) {
        $user = $this->requireAuth();
        if (!$this->hasRole($user, $requiredRoles)) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'Forbidden - Insufficient permissions']);
            exit;
        }
        return $user;
    }
}
