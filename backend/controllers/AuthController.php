<?php
/**
 * CiviCore - Authentication Controller
 * 
 * Handles user registration and login
 * Implements secure password hashing and JWT token generation
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../config/jwt.php';

class AuthController {
    private $db;
    private $jwt;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
        $this->jwt = new JWT();
    }

    /**
     * User Registration
     * POST /api/auth/register
     */
    public function register() {
        $data = json_decode(file_get_contents("php://input"), true);

        // Validation
        if (empty($data['email']) || empty($data['password']) || empty($data['full_name'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Email, password, and full name are required']);
            return;
        }

        // Check if email exists
        $stmt = $this->db->prepare("SELECT id FROM users WHERE email = ?");
        $stmt->execute([$data['email']]);
        if ($stmt->fetch()) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Email already registered']);
            return;
        }

        // Hash password
        $hashedPassword = password_hash($data['password'], PASSWORD_BCRYPT);

        // Default role is citizen (role_id = 1)
        $roleId = 1;

        // Insert user
        $stmt = $this->db->prepare("
            INSERT INTO users (role_id, email, password, full_name, phone, aadhaar_number, address, date_of_birth, is_active, email_verified)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, TRUE, FALSE)
        ");

        try {
            $stmt->execute([
                $roleId,
                $data['email'],
                $hashedPassword,
                $data['full_name'],
                $data['phone'] ?? null,
                $data['aadhaar_number'] ?? null,
                $data['address'] ?? null,
                $data['date_of_birth'] ?? null
            ]);

            $userId = $this->db->lastInsertId();

            // Log audit
            $this->logAudit($userId, 'REGISTER', 'user', $userId, 'User registered');

            // Generate token
            $token = $this->jwt->generateToken([
                'user_id' => $userId,
                'email' => $data['email'],
                'role' => 'citizen',
                'role_id' => $roleId
            ]);

            http_response_code(201);
            echo json_encode([
                'success' => true,
                'message' => 'Registration successful',
                'token' => $token,
                'user' => [
                    'id' => $userId,
                    'email' => $data['email'],
                    'full_name' => $data['full_name'],
                    'role' => 'citizen'
                ]
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Registration failed: ' . $e->getMessage()]);
        }
    }

    /**
     * User Login
     * POST /api/auth/login
     */
    public function login() {
        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($data['email']) || empty($data['password'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Email and password are required']);
            return;
        }

        // Get user with role
        $stmt = $this->db->prepare("
            SELECT u.id, u.email, u.password, u.full_name, u.role_id, u.is_active, r.name as role_name
            FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.email = ?
        ");
        $stmt->execute([$data['email']]);
        $user = $stmt->fetch();

        if (!$user) {
            http_response_code(401);
            echo json_encode(['success' => false, 'message' => 'Invalid credentials - User not found']);
            return;
        }

        // Verify password
        $passwordValid = password_verify($data['password'], $user['password']);
        
        if (!$passwordValid) {
            // If password doesn't match, try to update with new hash (for migration)
            // This helps if old hash format was used
            $newHash = password_hash($data['password'], PASSWORD_BCRYPT);
            if (password_verify($data['password'], $newHash)) {
                // Update password in database
                $updateStmt = $this->db->prepare("UPDATE users SET password = ? WHERE email = ?");
                $updateStmt->execute([$newHash, $data['email']]);
                // Retry verification
                $passwordValid = password_verify($data['password'], $newHash);
            }
        }

        if (!$passwordValid) {
            http_response_code(401);
            echo json_encode(['success' => false, 'message' => 'Invalid credentials - Password incorrect']);
            return;
        }

        if (!$user['is_active']) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'Account is deactivated']);
            return;
        }

        // Generate token - normalize role to lowercase
        $roleName = strtolower($user['role_name']);
        $token = $this->jwt->generateToken([
            'user_id' => $user['id'],
            'email' => $user['email'],
            'role' => $roleName,
            'role_id' => $user['role_id']
        ]);

        // Log audit
        $this->logAudit($user['id'], 'LOGIN', 'user', $user['id'], 'User logged in');

        // Get department if officer
        $department = null;
        if ($user['role_id'] == 2) {
            $deptStmt = $this->db->prepare("SELECT id, name FROM departments WHERE id = (SELECT department_id FROM users WHERE id = ?)");
            $deptStmt->execute([$user['id']]);
            $department = $deptStmt->fetch();
        }

            echo json_encode([
                'success' => true,
                'message' => 'Login successful',
                'token' => $token,
                'user' => [
                    'id' => $user['id'],
                    'email' => $user['email'],
                    'full_name' => $user['full_name'],
                    'role' => $roleName,
                    'department' => $department
                ]
            ]);
    }

    /**
     * Log audit action
     */
    private function logAudit($userId, $action, $entityType, $entityId, $details) {
        $ip = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'unknown';
        
        $stmt = $this->db->prepare("
            INSERT INTO audit_logs (user_id, action, entity_type, entity_id, details, ip_address, user_agent)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([$userId, $action, $entityType, $entityId, $details, $ip, $userAgent]);
    }
}
