<?php
/**
 * CiviCore - Application Controller
 * 
 * Manages citizen applications for government services
 * Supports application tracking and status management
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/auth.php';

class ApplicationController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    /**
     * Create new application (Citizen)
     * POST /api/applications
     */
    public function createApplication() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole(['citizen', 'admin']);

        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($data['service_id'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Service ID is required']);
            return;
        }

        // Generate application number
        $applicationNumber = 'APP' . date('Y') . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);

        $stmt = $this->db->prepare("
            INSERT INTO applications (application_number, citizen_id, service_id, status)
            VALUES (?, ?, ?, 'pending')
        ");

        try {
            $stmt->execute([
                $applicationNumber,
                $user['user_id'],
                $data['service_id']
            ]);

            $applicationId = $this->db->lastInsertId();

            // Log application creation
            $this->logApplicationAction($applicationId, $user['user_id'], 'Application Submitted', null, 'pending', 'Citizen submitted application');

            // Log audit
            $this->logAudit($user['user_id'], 'CREATE_APPLICATION', 'application', $applicationId, 'Created application: ' . $applicationNumber);

            http_response_code(201);
            echo json_encode([
                'success' => true,
                'message' => 'Application created successfully',
                'data' => [
                    'id' => $applicationId,
                    'application_number' => $applicationNumber
                ]
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to create application: ' . $e->getMessage()]);
        }
    }

    /**
     * Get user's applications (Citizen)
     * GET /api/applications/my-applications
     */
    public function getMyApplications() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole(['citizen', 'admin']);

        $stmt = $this->db->prepare("
            SELECT a.id, a.application_number, a.status, a.applied_date, a.reviewed_date, a.approved_date,
                   a.remarks, a.rejection_reason, a.certificate_path,
                   s.name as service_name, s.code as service_code,
                   d.name as department_name
            FROM applications a
            JOIN services s ON a.service_id = s.id
            JOIN departments d ON s.department_id = d.id
            WHERE a.citizen_id = ?
            ORDER BY a.applied_date DESC
        ");
        $stmt->execute([$user['user_id']]);
        $applications = $stmt->fetchAll();

        echo json_encode([
            'success' => true,
            'data' => $applications
        ]);
    }

    /**
     * Get application by ID
     * GET /api/applications/{id}
     */
    public function getApplication($id) {
        $auth = new AuthMiddleware();
        $user = $auth->requireAuth();

        $stmt = $this->db->prepare("
            SELECT a.*, a.service_id, s.name as service_name, s.code as service_code,
                   d.name as department_name,
                   u.full_name as citizen_name, u.email as citizen_email,
                   o.full_name as officer_name
            FROM applications a
            JOIN services s ON a.service_id = s.id
            JOIN departments d ON s.department_id = d.id
            JOIN users u ON a.citizen_id = u.id
            LEFT JOIN users o ON a.officer_id = o.id
            WHERE a.id = ?
        ");
        $stmt->execute([$id]);
        $application = $stmt->fetch();

        if (!$application) {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Application not found']);
            return;
        }

        // Check access: Citizen can only see their own, Officer/Admin can see all
        if ($user['role'] === 'citizen' && $application['citizen_id'] != $user['user_id']) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            return;
        }

        // Get documents
        $docStmt = $this->db->prepare("
            SELECT id, document_name, file_path, file_type, file_size, uploaded_at
            FROM application_documents
            WHERE application_id = ?
        ");
        $docStmt->execute([$id]);
        $application['documents'] = $docStmt->fetchAll();

        // Get logs
        $logStmt = $this->db->prepare("
            SELECT al.*, u.full_name as user_name
            FROM application_logs al
            LEFT JOIN users u ON al.user_id = u.id
            WHERE al.application_id = ?
            ORDER BY al.created_at ASC
        ");
        $logStmt->execute([$id]);
        $application['logs'] = $logStmt->fetchAll();

        echo json_encode([
            'success' => true,
            'data' => $application
        ]);
    }

    /**
     * Get assigned applications (Officer)
     * GET /api/applications/assigned
     */
    public function getAssignedApplications() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole(['officer', 'admin']);

        $status = $_GET['status'] ?? null;
        $whereClause = "WHERE a.officer_id = ?";
        $params = [$user['user_id']];

        if ($status) {
            $whereClause .= " AND a.status = ?";
            $params[] = $status;
        }

        $stmt = $this->db->prepare("
            SELECT a.id, a.application_number, a.status, a.applied_date, a.reviewed_date,
                   s.name as service_name, s.code as service_code,
                   u.full_name as citizen_name, u.email as citizen_email
            FROM applications a
            JOIN services s ON a.service_id = s.id
            JOIN users u ON a.citizen_id = u.id
            $whereClause
            ORDER BY a.applied_date DESC
        ");
        $stmt->execute($params);
        $applications = $stmt->fetchAll();

        echo json_encode([
            'success' => true,
            'data' => $applications
        ]);
    }

    /**
     * Get all applications (Admin/Officer)
     * GET /api/applications
     */
    public function getAllApplications() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole(['officer', 'admin']);

        $status = $_GET['status'] ?? null;
        $whereClause = "";
        $params = [];

        if ($status) {
            $whereClause = "WHERE a.status = ?";
            $params[] = $status;
        }

        $stmt = $this->db->prepare("
            SELECT a.id, a.application_number, a.status, a.applied_date, a.reviewed_date, a.approved_date,
                   s.name as service_name, s.code as service_code,
                   u.full_name as citizen_name, u.email as citizen_email,
                   o.full_name as officer_name
            FROM applications a
            JOIN services s ON a.service_id = s.id
            JOIN users u ON a.citizen_id = u.id
            LEFT JOIN users o ON a.officer_id = o.id
            $whereClause
            ORDER BY a.applied_date DESC
        ");
        $stmt->execute($params);
        $applications = $stmt->fetchAll();

        echo json_encode([
            'success' => true,
            'data' => $applications
        ]);
    }

    /**
     * Assign application to officer (Admin)
     * POST /api/applications/{id}/assign
     */
    public function assignApplication($id) {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole('admin');

        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($data['officer_id'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Officer ID is required']);
            return;
        }

        // Get current application
        $stmt = $this->db->prepare("SELECT status, officer_id FROM applications WHERE id = ?");
        $stmt->execute([$id]);
        $application = $stmt->fetch();

        if (!$application) {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Application not found']);
            return;
        }

        $oldStatus = $application['status'];
        $newStatus = 'under_review';

        // Update application
        $updateStmt = $this->db->prepare("
            UPDATE applications 
            SET officer_id = ?, status = ?, reviewed_date = NOW()
            WHERE id = ?
        ");
        $updateStmt->execute([$data['officer_id'], $newStatus, $id]);

        // Log action
        $this->logApplicationAction($id, $user['user_id'], 'Application Assigned', $oldStatus, $newStatus, 'Assigned to officer');

        $this->logAudit($user['user_id'], 'ASSIGN_APPLICATION', 'application', $id, 'Assigned application to officer');

        echo json_encode([
            'success' => true,
            'message' => 'Application assigned successfully'
        ]);
    }

    /**
     * Approve application (Officer)
     * POST /api/applications/{id}/approve
     */
    public function approveApplication($id) {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole(['officer', 'admin']);

        $data = json_decode(file_get_contents("php://input"), true);

        // Get current application
        $stmt = $this->db->prepare("SELECT status, officer_id, citizen_id FROM applications WHERE id = ?");
        $stmt->execute([$id]);
        $application = $stmt->fetch();

        if (!$application) {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Application not found']);
            return;
        }

        // Check if officer is assigned (unless admin)
        if ($user['role'] === 'officer' && $application['officer_id'] != $user['user_id']) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'You are not assigned to this application']);
            return;
        }

        $oldStatus = $application['status'];
        $newStatus = 'approved';

        // Generate certificate path (placeholder - in production, generate actual PDF)
        $certificatePath = 'certificates/' . $id . '_' . time() . '.pdf';

        // Get certificate type and value if provided
        $certificateType = $data['certificate_type'] ?? null;
        $certificateValue = $data['certificate_value'] ?? null;

        // Update application
        $updateStmt = $this->db->prepare("
            UPDATE applications 
            SET status = ?, approved_date = NOW(), remarks = ?, certificate_path = ?, certificate_type = ?, certificate_value = ?
            WHERE id = ?
        ");
        $updateStmt->execute([
            $newStatus,
            $data['remarks'] ?? 'Application approved',
            $certificatePath,
            $certificateType,
            $certificateValue,
            $id
        ]);

        // Log action
        $this->logApplicationAction($id, $user['user_id'], 'Application Approved', $oldStatus, $newStatus, $data['remarks'] ?? 'Application approved');

        $this->logAudit($user['user_id'], 'APPROVE_APPLICATION', 'application', $id, 'Approved application');

        echo json_encode([
            'success' => true,
            'message' => 'Application approved successfully',
            'data' => ['certificate_path' => $certificatePath]
        ]);
    }

    /**
     * Reject application (Officer)
     * POST /api/applications/{id}/reject
     */
    public function rejectApplication($id) {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole(['officer', 'admin']);

        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($data['rejection_reason'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Rejection reason is required']);
            return;
        }

        // Get current application
        $stmt = $this->db->prepare("SELECT status, officer_id FROM applications WHERE id = ?");
        $stmt->execute([$id]);
        $application = $stmt->fetch();

        if (!$application) {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Application not found']);
            return;
        }

        // Check if officer is assigned (unless admin)
        if ($user['role'] === 'officer' && $application['officer_id'] != $user['user_id']) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'You are not assigned to this application']);
            return;
        }

        $oldStatus = $application['status'];
        $newStatus = 'rejected';

        // Update application
        $updateStmt = $this->db->prepare("
            UPDATE applications 
            SET status = ?, reviewed_date = NOW(), rejection_reason = ?, remarks = ?
            WHERE id = ?
        ");
        $updateStmt->execute([
            $newStatus,
            $data['rejection_reason'],
            $data['remarks'] ?? null,
            $id
        ]);

        // Log action
        $this->logApplicationAction($id, $user['user_id'], 'Application Rejected', $oldStatus, $newStatus, $data['rejection_reason']);

        $this->logAudit($user['user_id'], 'REJECT_APPLICATION', 'application', $id, 'Rejected application');

        echo json_encode([
            'success' => true,
            'message' => 'Application rejected'
        ]);
    }

    /**
     * Log application action
     */
    private function logApplicationAction($applicationId, $userId, $action, $oldStatus, $newStatus, $remarks) {
        $stmt = $this->db->prepare("
            INSERT INTO application_logs (application_id, user_id, action, old_status, new_status, remarks)
            VALUES (?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([$applicationId, $userId, $action, $oldStatus, $newStatus, $remarks]);
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
