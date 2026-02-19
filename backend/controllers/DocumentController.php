<?php
/**
 * CiviCore - Document Controller
 * 
 * Handles document uploads for applications
 * Ensures secure file handling and storage
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/auth.php';

class DocumentController {
    private $db;
    private $uploadDir = __DIR__ . '/../uploads/';

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
        
        // Create upload directory if it doesn't exist
        if (!file_exists($this->uploadDir)) {
            mkdir($this->uploadDir, 0777, true);
        }
    }

    /**
     * Upload document for application
     * POST /api/documents/upload
     */
    public function uploadDocument() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole(['citizen', 'admin']);

        if (!isset($_FILES['document']) || $_FILES['document']['error'] !== UPLOAD_ERR_OK) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'No file uploaded or upload error']);
            return;
        }

        $applicationId = $_POST['application_id'] ?? null;
        if (!$applicationId) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Application ID is required']);
            return;
        }

        // Verify application belongs to user (if citizen)
        if ($user['role'] === 'citizen') {
            $stmt = $this->db->prepare("SELECT citizen_id FROM applications WHERE id = ?");
            $stmt->execute([$applicationId]);
            $app = $stmt->fetch();
            if (!$app || $app['citizen_id'] != $user['user_id']) {
                http_response_code(403);
                echo json_encode(['success' => false, 'message' => 'Access denied']);
                return;
            }
        }

        $file = $_FILES['document'];
        $allowedTypes = ['application/pdf', 'image/jpeg', 'image/jpg', 'image/png'];
        $maxSize = 5 * 1024 * 1024; // 5MB

        // Validate file type
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);

        if (!in_array($mimeType, $allowedTypes)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Invalid file type. Only PDF, JPG, PNG allowed']);
            return;
        }

        // Validate file size
        if ($file['size'] > $maxSize) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'File size exceeds 5MB limit']);
            return;
        }

        // Generate unique filename
        $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = 'doc_' . $applicationId . '_' . time() . '_' . uniqid() . '.' . $extension;
        $filepath = $this->uploadDir . $filename;

        // Move uploaded file
        if (!move_uploaded_file($file['tmp_name'], $filepath)) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to save file']);
            return;
        }

        // Save to database
        $stmt = $this->db->prepare("
            INSERT INTO application_documents (application_id, document_name, file_path, file_type, file_size)
            VALUES (?, ?, ?, ?, ?)
        ");

        try {
            $stmt->execute([
                $applicationId,
                $file['name'],
                'uploads/' . $filename,
                $mimeType,
                $file['size']
            ]);

            $docId = $this->db->lastInsertId();

            // Log audit
            $this->logAudit($user['user_id'], 'UPLOAD_DOCUMENT', 'document', $docId, 'Uploaded document: ' . $file['name']);

            echo json_encode([
                'success' => true,
                'message' => 'Document uploaded successfully',
                'data' => [
                    'id' => $docId,
                    'file_path' => 'uploads/' . $filename
                ]
            ]);
        } catch (Exception $e) {
            // Delete file if database insert fails
            unlink($filepath);
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to save document: ' . $e->getMessage()]);
        }
    }

    /**
     * Get document
     * GET /api/documents/{id}
     */
    public function getDocument($id) {
        $auth = new AuthMiddleware();
        $user = $auth->requireAuth();

        $stmt = $this->db->prepare("
            SELECT ad.*, a.citizen_id, a.officer_id
            FROM application_documents ad
            JOIN applications a ON ad.application_id = a.id
            WHERE ad.id = ?
        ");
        $stmt->execute([$id]);
        $document = $stmt->fetch();

        if (!$document) {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Document not found']);
            return;
        }

        // Check access
        $hasAccess = false;
        if ($user['role'] === 'admin' || $user['role'] === 'officer') {
            $hasAccess = true;
        } elseif ($user['role'] === 'citizen' && $document['citizen_id'] == $user['user_id']) {
            $hasAccess = true;
        }

        if (!$hasAccess) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            return;
        }

        echo json_encode([
            'success' => true,
            'data' => $document
        ]);
    }

    /**
     * Download document file
     * GET /api/documents/{id}/download
     */
    public function downloadDocument($id) {
        $auth = new AuthMiddleware();
        $user = $auth->requireAuth();

        $stmt = $this->db->prepare("
            SELECT ad.*, a.citizen_id, a.officer_id
            FROM application_documents ad
            JOIN applications a ON ad.application_id = a.id
            WHERE ad.id = ?
        ");
        $stmt->execute([$id]);
        $document = $stmt->fetch();

        if (!$document) {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Document not found']);
            return;
        }

        // Check access
        $hasAccess = false;
        if ($user['role'] === 'admin' || $user['role'] === 'officer') {
            $hasAccess = true;
        } elseif ($user['role'] === 'citizen' && $document['citizen_id'] == $user['user_id']) {
            $hasAccess = true;
        }

        if (!$hasAccess) {
            http_response_code(403);
            echo json_encode(['success' => false, 'message' => 'Access denied']);
            return;
        }

        $filepath = __DIR__ . '/../' . $document['file_path'];
        if (!file_exists($filepath)) {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'File not found']);
            return;
        }

        header('Content-Type: ' . $document['file_type']);
        header('Content-Disposition: attachment; filename="' . $document['document_name'] . '"');
        header('Content-Length: ' . filesize($filepath));
        readfile($filepath);
        exit;
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
