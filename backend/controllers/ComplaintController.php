<?php
/**
 * CiviCore - Complaint Controller
 * 
 * Manages citizen complaints and grievances
 * Supports transparency in grievance redressal
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/auth.php';

class ComplaintController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    /**
     * Create complaint (Citizen)
     * POST /api/complaints
     * Supports both JSON and multipart/form-data (with photo)
     */
    public function createComplaint() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole(['citizen', 'admin']);

        // Handle multipart/form-data (with photo) or JSON
        $subject = null;
        $description = null;
        $photoPath = null;

        if ($_SERVER['CONTENT_TYPE'] && strpos($_SERVER['CONTENT_TYPE'], 'multipart/form-data') !== false) {
            // Handle multipart form data
            $subject = $_POST['subject'] ?? null;
            $description = $_POST['description'] ?? null;

            // Handle photo upload
            if (isset($_FILES['photo']) && $_FILES['photo']['error'] === UPLOAD_ERR_OK) {
                $uploadDir = __DIR__ . '/../uploads/complaints/';
                if (!file_exists($uploadDir)) {
                    mkdir($uploadDir, 0777, true);
                }

                $allowedTypes = ['image/jpeg', 'image/jpg', 'image/png'];
                $maxSize = 5 * 1024 * 1024; // 5MB

                $file = $_FILES['photo'];
                $finfo = finfo_open(FILEINFO_MIME_TYPE);
                $mimeType = finfo_file($finfo, $file['tmp_name']);
                finfo_close($finfo);

                if (in_array($mimeType, $allowedTypes) && $file['size'] <= $maxSize) {
                    $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
                    $filename = 'complaint_' . time() . '_' . uniqid() . '.' . $extension;
                    $filepath = $uploadDir . $filename;

                    if (move_uploaded_file($file['tmp_name'], $filepath)) {
                        $photoPath = 'uploads/complaints/' . $filename;
                    }
                }
            }
        } else {
            // Handle JSON data
            $data = json_decode(file_get_contents("php://input"), true);
            $subject = $data['subject'] ?? null;
            $description = $data['description'] ?? null;
        }

        if (empty($subject) || empty($description)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Subject and description are required']);
            return;
        }

        // Generate complaint number
        $complaintNumber = 'COMP' . date('Y') . str_pad(rand(1, 9999), 4, '0', STR_PAD_LEFT);

        // Check if photo_path column exists (for backward compatibility)
        $hasPhotoColumn = false;
        try {
            $checkStmt = $this->db->query("SHOW COLUMNS FROM complaints LIKE 'photo_path'");
            $hasPhotoColumn = $checkStmt->rowCount() > 0;
        } catch (Exception $e) {
            // Column doesn't exist, continue without it
        }

        try {
            if ($hasPhotoColumn) {
                $stmt = $this->db->prepare("
                    INSERT INTO complaints (complaint_number, citizen_id, subject, description, photo_path, status)
                    VALUES (?, ?, ?, ?, ?, 'open')
                ");
                $stmt->execute([
                    $complaintNumber,
                    $user['user_id'],
                    $subject,
                    $description,
                    $photoPath
                ]);
            } else {
                $stmt = $this->db->prepare("
                    INSERT INTO complaints (complaint_number, citizen_id, subject, description, status)
                    VALUES (?, ?, ?, ?, 'open')
                ");
                $stmt->execute([
                    $complaintNumber,
                    $user['user_id'],
                    $subject,
                    $description
                ]);
            }

            $complaintId = $this->db->lastInsertId();

            // Store photo path if uploaded (you may want to add a photo_path column to complaints table)
            // For now, we'll store it in a separate table or as part of description
            if ($photoPath) {
                // You can add a photo_path column to complaints table or store in a separate table
                // For now, we'll just log it
                error_log("Complaint photo uploaded: $photoPath for complaint ID: $complaintId");
            }

            // Log audit
            $this->logAudit($user['user_id'], 'CREATE_COMPLAINT', 'complaint', $complaintId, 'Created complaint: ' . $complaintNumber);

            http_response_code(201);
            echo json_encode([
                'success' => true,
                'message' => 'Complaint submitted successfully',
                'data' => [
                    'id' => $complaintId,
                    'complaint_number' => $complaintNumber,
                    'photo_uploaded' => $photoPath != null
                ]
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to submit complaint: ' . $e->getMessage()]);
        }
    }

    /**
     * Get my complaints (Citizen)
     * GET /api/complaints/my-complaints
     */
    public function getMyComplaints() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole(['citizen', 'admin']);

        // Check if photo_path column exists
        $hasPhotoColumn = false;
        try {
            $checkStmt = $this->db->query("SHOW COLUMNS FROM complaints LIKE 'photo_path'");
            $hasPhotoColumn = $checkStmt->rowCount() > 0;
        } catch (Exception $e) {
            // Column doesn't exist
        }

        $selectFields = $hasPhotoColumn 
            ? "id, complaint_number, subject, description, status, photo_path, created_at, updated_at, resolved_at"
            : "id, complaint_number, subject, description, status, created_at, updated_at, resolved_at";
        
        $stmt = $this->db->prepare("
            SELECT $selectFields
            FROM complaints
            WHERE citizen_id = ?
            ORDER BY created_at DESC
        ");
        $stmt->execute([$user['user_id']]);
        $complaints = $stmt->fetchAll();

        echo json_encode([
            'success' => true,
            'data' => $complaints
        ]);
    }

    /**
     * Get all complaints (Admin/Officer)
     * GET /api/complaints
     */
    public function getAllComplaints() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole(['officer', 'admin']);

        $status = $_GET['status'] ?? null;
        $whereClause = "";
        $params = [];

        if ($status) {
            $whereClause = "WHERE status = ?";
            $params[] = $status;
        }

        // Check if photo_path column exists
        $hasPhotoColumn = false;
        try {
            $checkStmt = $this->db->query("SHOW COLUMNS FROM complaints LIKE 'photo_path'");
            $hasPhotoColumn = $checkStmt->rowCount() > 0;
        } catch (Exception $e) {
            // Column doesn't exist
        }

        $selectFields = $hasPhotoColumn
            ? "c.id, c.complaint_number, c.subject, c.description, c.status, c.photo_path, 
               c.created_at, c.updated_at, c.resolved_at, c.resolution, c.assigned_to,
               u.full_name as citizen_name, u.email as citizen_email,
               o.full_name as assigned_officer_name"
            : "c.id, c.complaint_number, c.subject, c.description, c.status, 
               c.created_at, c.updated_at, c.resolved_at, c.resolution, c.assigned_to,
               u.full_name as citizen_name, u.email as citizen_email,
               o.full_name as assigned_officer_name";

        $stmt = $this->db->prepare("
            SELECT $selectFields
            FROM complaints c
            JOIN users u ON c.citizen_id = u.id
            LEFT JOIN users o ON c.assigned_to = o.id
            $whereClause
            ORDER BY c.created_at DESC
        ");
        $stmt->execute($params);
        $complaints = $stmt->fetchAll();

        echo json_encode([
            'success' => true,
            'data' => $complaints
        ]);
    }

    /**
     * Get complaint by ID
     * GET /api/complaints/{id}
     */
    public function getComplaint($id) {
        $auth = new AuthMiddleware();
        $user = $auth->requireAuth();

        // Check if photo_path column exists
        $hasPhotoColumn = false;
        try {
            $checkStmt = $this->db->query("SHOW COLUMNS FROM complaints LIKE 'photo_path'");
            $hasPhotoColumn = $checkStmt->rowCount() > 0;
        } catch (Exception $e) {
            // Column doesn't exist
        }

        $selectFields = $hasPhotoColumn
            ? "c.*, u.full_name as citizen_name, u.email as citizen_email,
               o.full_name as assigned_officer_name"
            : "c.*, u.full_name as citizen_name, u.email as citizen_email,
               o.full_name as assigned_officer_name";

        $stmt = $this->db->prepare("
            SELECT $selectFields
            FROM complaints c
            JOIN users u ON c.citizen_id = u.id
            LEFT JOIN users o ON c.assigned_to = o.id
            WHERE c.id = ?
        ");
        $stmt->execute([$id]);
        $complaint = $stmt->fetch();

        if (!$complaint) {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Complaint not found']);
            return;
        }

        // Check access
        if ($user['role'] === 'citizen' && $complaint['citizen_id'] != $user['user_id']) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            return;
        }

        echo json_encode([
            'success' => true,
            'data' => $complaint
        ]);
    }

    /**
     * Update complaint status (Officer/Admin)
     * PUT /api/complaints/{id}/status
     */
    public function updateComplaintStatus($id) {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole(['officer', 'admin']);

        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($data['status'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Status is required']);
            return;
        }

        $allowedStatuses = ['open', 'in_progress', 'resolved', 'closed'];
        if (!in_array($data['status'], $allowedStatuses)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Invalid status']);
            return;
        }

        $updateFields = ["status = ?"];
        $params = [$data['status']];

        if (isset($data['resolution'])) {
            $updateFields[] = "resolution = ?";
            $params[] = $data['resolution'];
        }

        if (isset($data['assigned_to'])) {
            $updateFields[] = "assigned_to = ?";
            $params[] = $data['assigned_to'];
        }

        if ($data['status'] === 'resolved') {
            $updateFields[] = "resolved_at = NOW()";
        }

        $params[] = $id;

        $sql = "UPDATE complaints SET " . implode(", ", $updateFields) . " WHERE id = ?";
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);

        $this->logAudit($user['user_id'], 'UPDATE_COMPLAINT', 'complaint', $id, 'Updated complaint status to ' . $data['status']);

        echo json_encode([
            'success' => true,
            'message' => 'Complaint status updated successfully'
        ]);
    }

    /**
     * Add response to complaint (Officer/Admin)
     * POST /api/complaints/{id}/response
     */
    public function addComplaintResponse($id) {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole(['officer', 'admin']);

        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($data['response'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Response text is required']);
            return;
        }

        // Check if complaint_responses table exists, if not create it
        try {
            $this->db->exec("
                CREATE TABLE IF NOT EXISTS complaint_responses (
                    id INT PRIMARY KEY AUTO_INCREMENT,
                    complaint_id INT NOT NULL,
                    user_id INT NOT NULL,
                    response TEXT NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (complaint_id) REFERENCES complaints(id) ON DELETE CASCADE,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT,
                    INDEX idx_complaint (complaint_id),
                    INDEX idx_user (user_id)
                ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
            ");
        } catch (Exception $e) {
            // Table might already exist
        }

        try {
            $stmt = $this->db->prepare("
                INSERT INTO complaint_responses (complaint_id, user_id, response)
                VALUES (?, ?, ?)
            ");
            $stmt->execute([$id, $user['user_id'], $data['response']]);

            // Update complaint status if provided
            if (isset($data['update_status'])) {
                $statusStmt = $this->db->prepare("UPDATE complaints SET status = ? WHERE id = ?");
                $statusStmt->execute([$data['update_status'], $id]);
            }

            // Auto-assign if not assigned
            $checkStmt = $this->db->prepare("SELECT assigned_to FROM complaints WHERE id = ?");
            $checkStmt->execute([$id]);
            $complaint = $checkStmt->fetch();
            if (!$complaint['assigned_to']) {
                $assignStmt = $this->db->prepare("UPDATE complaints SET assigned_to = ? WHERE id = ?");
                $assignStmt->execute([$user['user_id'], $id]);
            }

            $this->logAudit($user['user_id'], 'ADD_COMPLAINT_RESPONSE', 'complaint', $id, 'Added response to complaint');

            http_response_code(201);
            echo json_encode([
                'success' => true,
                'message' => 'Response added successfully'
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to add response: ' . $e->getMessage()]);
        }
    }

    /**
     * Get complaint responses
     * GET /api/complaints/{id}/responses
     */
    public function getComplaintResponses($id) {
        $auth = new AuthMiddleware();
        $user = $auth->requireAuth();

        // Check if complaint_responses table exists
        try {
            $checkStmt = $this->db->query("SHOW TABLES LIKE 'complaint_responses'");
            if ($checkStmt->rowCount() == 0) {
                echo json_encode(['success' => true, 'data' => []]);
                return;
            }
        } catch (Exception $e) {
            echo json_encode(['success' => true, 'data' => []]);
            return;
        }

        // Verify access to complaint
        $checkStmt = $this->db->prepare("SELECT citizen_id FROM complaints WHERE id = ?");
        $checkStmt->execute([$id]);
        $complaint = $checkStmt->fetch();

        if (!$complaint) {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Complaint not found']);
            return;
        }

        if ($user['role'] === 'citizen' && $complaint['citizen_id'] != $user['user_id']) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            return;
        }

        $stmt = $this->db->prepare("
            SELECT cr.*, u.full_name as user_name, u.role_id, r.name as role_name
            FROM complaint_responses cr
            JOIN users u ON cr.user_id = u.id
            JOIN roles r ON u.role_id = r.id
            WHERE cr.complaint_id = ?
            ORDER BY cr.created_at ASC
        ");
        $stmt->execute([$id]);
        $responses = $stmt->fetchAll();

        echo json_encode([
            'success' => true,
            'data' => $responses
        ]);
    }

    /**
     * Assign complaint to officer
     * PUT /api/complaints/{id}/assign
     */
    public function assignComplaint($id) {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole(['admin']);

        $data = json_decode(file_get_contents("php://input"), true);

        if (empty($data['assigned_to'])) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Officer ID is required']);
            return;
        }

        try {
            $stmt = $this->db->prepare("UPDATE complaints SET assigned_to = ? WHERE id = ?");
            $stmt->execute([$data['assigned_to'], $id]);

            $this->logAudit($user['user_id'], 'ASSIGN_COMPLAINT', 'complaint', $id, 'Assigned complaint to officer');

            echo json_encode([
                'success' => true,
                'message' => 'Complaint assigned successfully'
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to assign complaint: ' . $e->getMessage()]);
        }
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
