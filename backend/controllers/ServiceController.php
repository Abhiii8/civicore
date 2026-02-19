<?php
/**
 * CiviCore - Service Controller
 * 
 * Manages government services available for application
 * Supports transparency in service delivery
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/auth.php';

class ServiceController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    /**
     * Get all active services
     * GET /api/services
     */
    public function getAllServices() {
        $stmt = $this->db->query("
            SELECT s.id, s.name, s.code, s.description, s.required_documents, 
                   s.processing_days, s.fee, d.name as department_name
            FROM services s
            JOIN departments d ON s.department_id = d.id
            WHERE s.is_active = TRUE
            ORDER BY s.name
        ");
        $services = $stmt->fetchAll();

        echo json_encode([
            'success' => true,
            'data' => $services
        ]);
    }

    /**
     * Get service by ID
     * GET /api/services/{id}
     */
    public function getService($id) {
        $stmt = $this->db->prepare("
            SELECT s.id, s.name, s.code, s.description, s.required_documents, 
                   s.processing_days, s.fee, d.name as department_name, d.id as department_id
            FROM services s
            JOIN departments d ON s.department_id = d.id
            WHERE s.id = ? AND s.is_active = TRUE
        ");
        $stmt->execute([$id]);
        $service = $stmt->fetch();

        if (!$service) {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Service not found']);
            return;
        }

        echo json_encode([
            'success' => true,
            'data' => $service
        ]);
    }

    /**
     * Create new service (Admin only)
     * POST /api/services
     */
    public function createService() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole('admin');

        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($data['name']) || empty($data['department_id'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Name and department are required']);
            return;
        }

        $stmt = $this->db->prepare("
            INSERT INTO services (department_id, name, code, description, required_documents, processing_days, fee)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        ");

        try {
            $stmt->execute([
                $data['department_id'],
                $data['name'],
                $data['code'] ?? null,
                $data['description'] ?? null,
                $data['required_documents'] ?? null,
                $data['processing_days'] ?? 7,
                $data['fee'] ?? 0.00
            ]);

            $serviceId = $this->db->lastInsertId();

            // Log audit
            $this->logAudit($user['user_id'], 'CREATE_SERVICE', 'service', $serviceId, 'Created service: ' . $data['name']);

            http_response_code(201);
            echo json_encode([
                'success' => true,
                'message' => 'Service created successfully',
                'data' => ['id' => $serviceId]
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to create service: ' . $e->getMessage()]);
        }
    }

    /**
     * Update service (Admin only)
     * PUT /api/services/{id}
     */
    public function updateService($id) {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole('admin');

        $data = json_decode(file_get_contents("php://input"), true);

        $fields = [];
        $values = [];

        if (isset($data['name'])) {
            $fields[] = "name = ?";
            $values[] = $data['name'];
        }
        if (isset($data['description'])) {
            $fields[] = "description = ?";
            $values[] = $data['description'];
        }
        if (isset($data['processing_days'])) {
            $fields[] = "processing_days = ?";
            $values[] = $data['processing_days'];
        }
        if (isset($data['fee'])) {
            $fields[] = "fee = ?";
            $values[] = $data['fee'];
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
        $sql = "UPDATE services SET " . implode(", ", $fields) . " WHERE id = ?";

        $stmt = $this->db->prepare($sql);
        $stmt->execute($values);

        $this->logAudit($user['user_id'], 'UPDATE_SERVICE', 'service', $id, 'Updated service');

        echo json_encode([
            'success' => true,
            'message' => 'Service updated successfully'
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
