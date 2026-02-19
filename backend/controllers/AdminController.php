<?php
/**
 * CiviCore - Admin Controller
 * 
 * Administrative functions for system management
 * Supports efficient governance and accountability
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/auth.php';

class AdminController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    /**
     * Get dashboard statistics
     * GET /api/admin/dashboard
     */
    public function getDashboard() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole('admin');

        // Total applications by status
        $stmt = $this->db->query("
            SELECT status, COUNT(*) as count
            FROM applications
            GROUP BY status
        ");
        $applicationStats = [];
        while ($row = $stmt->fetch()) {
            $applicationStats[$row['status']] = (int)$row['count'];
        }

        // Total users by role
        $stmt = $this->db->query("
            SELECT r.name as role, COUNT(*) as count
            FROM users u
            JOIN roles r ON u.role_id = r.id
            WHERE u.is_active = TRUE
            GROUP BY r.name
        ");
        $userStats = [];
        while ($row = $stmt->fetch()) {
            $userStats[$row['role']] = (int)$row['count'];
        }

        // Recent applications
        $stmt = $this->db->query("
            SELECT a.id, a.application_number, a.status, a.applied_date,
                   s.name as service_name, u.full_name as citizen_name
            FROM applications a
            JOIN services s ON a.service_id = s.id
            JOIN users u ON a.citizen_id = u.id
            ORDER BY a.applied_date DESC
            LIMIT 10
        ");
        $recentApplications = $stmt->fetchAll();

        // Total complaints by status
        $stmt = $this->db->query("
            SELECT status, COUNT(*) as count
            FROM complaints
            GROUP BY status
        ");
        $complaintStats = [];
        while ($row = $stmt->fetch()) {
            $complaintStats[$row['status']] = (int)$row['count'];
        }

        echo json_encode([
            'success' => true,
            'data' => [
                'applications' => $applicationStats,
                'users' => $userStats,
                'complaints' => $complaintStats,
                'recent_applications' => $recentApplications
            ]
        ]);
    }

    /**
     * Get all departments
     * GET /api/admin/departments
     */
    public function getDepartments() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole('admin');

        $stmt = $this->db->query("
            SELECT d.*, COUNT(DISTINCT u.id) as officer_count, COUNT(DISTINCT s.id) as service_count
            FROM departments d
            LEFT JOIN users u ON d.id = u.department_id AND u.role_id = 2
            LEFT JOIN services s ON d.id = s.department_id
            GROUP BY d.id
            ORDER BY d.name
        ");
        $departments = $stmt->fetchAll();

        echo json_encode([
            'success' => true,
            'data' => $departments
        ]);
    }

    /**
     * Create department
     * POST /api/admin/departments
     */
    public function createDepartment() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole('admin');

        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($data['name'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Department name is required']);
            return;
        }

        $stmt = $this->db->prepare("
            INSERT INTO departments (name, code, description, is_active)
            VALUES (?, ?, ?, TRUE)
        ");

        try {
            $stmt->execute([
                $data['name'],
                $data['code'] ?? null,
                $data['description'] ?? null
            ]);

            $deptId = $this->db->lastInsertId();
            $this->logAudit($user['user_id'], 'CREATE_DEPARTMENT', 'department', $deptId, 'Created department: ' . $data['name']);

            http_response_code(201);
            echo json_encode([
                'success' => true,
                'message' => 'Department created successfully',
                'data' => ['id' => $deptId]
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to create department: ' . $e->getMessage()]);
        }
    }

    /**
     * Get all users
     * GET /api/admin/users
     */
    public function getUsers() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole('admin');

        $role = $_GET['role'] ?? null;
        $whereClause = "";
        $params = [];

        if ($role) {
            $whereClause = "WHERE r.name = ?";
            $params[] = $role;
        }

        $stmt = $this->db->prepare("
            SELECT u.id, u.email, u.full_name, u.phone, u.is_active, u.created_at,
                   r.name as role_name, d.name as department_name
            FROM users u
            JOIN roles r ON u.role_id = r.id
            LEFT JOIN departments d ON u.department_id = d.id
            $whereClause
            ORDER BY u.created_at DESC
        ");
        $stmt->execute($params);
        $users = $stmt->fetchAll();

        echo json_encode([
            'success' => true,
            'data' => $users
        ]);
    }

    /**
     * Create user (Officer)
     * POST /api/admin/users
     */
    public function createUser() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole('admin');

        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($data['email']) || empty($data['password']) || empty($data['full_name']) || empty($data['role_id'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Email, password, full name, and role are required']);
            return;
        }

        // Check if email exists
        $stmt = $this->db->prepare("SELECT id FROM users WHERE email = ?");
        $stmt->execute([$data['email']]);
        if ($stmt->fetch()) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Email already exists']);
            return;
        }

        $hashedPassword = password_hash($data['password'], PASSWORD_BCRYPT);

        $stmt = $this->db->prepare("
            INSERT INTO users (role_id, department_id, email, password, full_name, phone, is_active, email_verified)
            VALUES (?, ?, ?, ?, ?, ?, TRUE, TRUE)
        ");

        try {
            $stmt->execute([
                $data['role_id'],
                $data['department_id'] ?? null,
                $data['email'],
                $hashedPassword,
                $data['full_name'],
                $data['phone'] ?? null
            ]);

            $userId = $this->db->lastInsertId();
            $this->logAudit($user['user_id'], 'CREATE_USER', 'user', $userId, 'Created user: ' . $data['email']);

            http_response_code(201);
            echo json_encode([
                'success' => true,
                'message' => 'User created successfully',
                'data' => ['id' => $userId]
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to create user: ' . $e->getMessage()]);
        }
    }

    /**
     * Update user
     * PUT /api/admin/users/{id}
     */
    public function updateUser($id) {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole('admin');

        $data = json_decode(file_get_contents("php://input"), true);

        $fields = [];
        $values = [];

        if (isset($data['full_name'])) {
            $fields[] = "full_name = ?";
            $values[] = $data['full_name'];
        }
        if (isset($data['phone'])) {
            $fields[] = "phone = ?";
            $values[] = $data['phone'];
        }
        if (isset($data['department_id'])) {
            $fields[] = "department_id = ?";
            $values[] = $data['department_id'];
        }
        if (isset($data['is_active'])) {
            $fields[] = "is_active = ?";
            $values[] = $data['is_active'];
        }

        if (empty($fields)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'No fields to update']);
            return;
        }

        $values[] = $id;
        $sql = "UPDATE users SET " . implode(", ", $fields) . " WHERE id = ?";

        $stmt = $this->db->prepare($sql);
        $stmt->execute($values);

        $this->logAudit($user['user_id'], 'UPDATE_USER', 'user', $id, 'Updated user');

        echo json_encode([
            'success' => true,
            'message' => 'User updated successfully'
        ]);
    }

    /**
     * Get audit logs
     * GET /api/admin/audit-logs
     */
    public function getAuditLogs() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole('admin');

        $limit = $_GET['limit'] ?? 100;
        $offset = $_GET['offset'] ?? 0;

        $stmt = $this->db->prepare("
            SELECT al.*, u.full_name as user_name, u.email as user_email
            FROM audit_logs al
            LEFT JOIN users u ON al.user_id = u.id
            ORDER BY al.created_at DESC
            LIMIT ? OFFSET ?
        ");
        $stmt->execute([$limit, $offset]);
        $logs = $stmt->fetchAll();

        echo json_encode([
            'success' => true,
            'data' => $logs
        ]);
    }

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
