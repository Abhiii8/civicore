<?php
/**
 * CiviCore - Certificate Template Controller
 * 
 * Manages certificate template uploads and configuration
 * Supports transparency in certificate generation
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/auth.php';

class CertificateTemplateController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    /**
     * Upload certificate template (Admin only)
     * POST /api/admin/certificate-templates
     */
    public function uploadTemplate() {
        $auth = new AuthMiddleware();
        $user = $auth->requireRole('admin');

        if (!isset($_FILES['template']) || $_FILES['template']['error'] !== UPLOAD_ERR_OK) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Template file is required']);
            return;
        }

        $uploadDir = __DIR__ . '/../uploads/templates/';
        if (!file_exists($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        $allowedTypes = ['image/png', 'image/jpeg', 'image/jpg', 'image/svg+xml'];
        $maxSize = 10 * 1024 * 1024; // 10MB

        $file = $_FILES['template'];
        $finfo = finfo_open(FILEINFO_MIME_TYPE);
        $mimeType = finfo_file($finfo, $file['tmp_name']);
        finfo_close($finfo);

        if (!in_array($mimeType, $allowedTypes) || $file['size'] > $maxSize) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'Invalid file type or size']);
            return;
        }

        $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
        $filename = 'template_' . time() . '_' . uniqid() . '.' . $extension;
        $filepath = $uploadDir . $filename;

        if (move_uploaded_file($file['tmp_name'], $filepath)) {
            $templatePath = 'uploads/templates/' . $filename;
            
            // Get additional data
            $name = $_POST['name'] ?? 'Untitled Template';
            $serviceId = !empty($_POST['service_id']) ? (int)$_POST['service_id'] : null;
            $fieldConfig = !empty($_POST['field_config']) ? $_POST['field_config'] : null;
            
            // Decode field config if it's a JSON string
            if ($fieldConfig && is_string($fieldConfig)) {
                $fieldConfig = json_decode($fieldConfig, true);
            }

            // Store template metadata in a JSON file for now
            // TODO: Create certificate_templates table in database
            $metadataFile = $uploadDir . pathinfo($filename, PATHINFO_FILENAME) . '_metadata.json';
            $metadata = [
                'name' => $name,
                'service_id' => $serviceId,
                'template_path' => $templatePath,
                'field_config' => $fieldConfig,
                'uploaded_at' => date('Y-m-d H:i:s'),
                'uploaded_by' => $user['user_id'],
            ];
            file_put_contents($metadataFile, json_encode($metadata, JSON_PRETTY_PRINT));

            $this->logAudit($user['user_id'], 'UPLOAD_TEMPLATE', 'template', 0, 'Uploaded template: ' . $name);

            http_response_code(201);
            echo json_encode([
                'success' => true,
                'message' => 'Template uploaded successfully',
                'data' => [
                    'name' => $name,
                    'service_id' => $serviceId,
                    'template_path' => $templatePath,
                    'template_url' => $templatePath, // Relative URL
                    'field_config' => $fieldConfig,
                ]
            ]);
        } else {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to upload template']);
        }
    }

    /**
     * Get all templates
     * GET /api/admin/certificate-templates?service_id=1 (optional)
     * For certificate generation, any authenticated user can access
     */
    public function getTemplates() {
        $auth = new AuthMiddleware();
        $user = $auth->requireAuth(); // Any authenticated user can fetch templates for certificate generation

        $serviceId = !empty($_GET['service_id']) ? (int)$_GET['service_id'] : null;

        // Load templates from directory and metadata files
        $templateDir = __DIR__ . '/../uploads/templates/';
        $templates = [];

        if (file_exists($templateDir)) {
            $files = scandir($templateDir);
            foreach ($files as $file) {
                if ($file !== '.' && $file !== '..' && preg_match('/\.(png|jpg|jpeg|svg)$/i', $file)) {
                    // Try to load metadata
                    $metadataFile = $templateDir . pathinfo($file, PATHINFO_FILENAME) . '_metadata.json';
                    $templateData = [
                        'name' => $file,
                        'path' => 'uploads/templates/' . $file,
                        'url' => 'uploads/templates/' . $file,
                        'template_path' => 'uploads/templates/' . $file,
                        'service_id' => null,
                        'field_config' => null,
                    ];
                    
                    if (file_exists($metadataFile)) {
                        $metadata = json_decode(file_get_contents($metadataFile), true);
                        if ($metadata) {
                            $templateData['name'] = $metadata['name'] ?? $file;
                            $templateData['service_id'] = $metadata['service_id'] ?? null;
                            $templateData['field_config'] = $metadata['field_config'] ?? null;
                        }
                    }
                    
                    // If service_id filter is provided, only return matching templates
                    if ($serviceId === null || $templateData['service_id'] == $serviceId || ($serviceId !== null && $templateData['service_id'] === null)) {
                        $templates[] = $templateData;
                    }
                }
            }
        }

        // If service_id filter, prioritize specific templates, then defaults
        if ($serviceId !== null) {
            usort($templates, function($a, $b) use ($serviceId) {
                if ($a['service_id'] == $serviceId && $b['service_id'] != $serviceId) return -1;
                if ($a['service_id'] != $serviceId && $b['service_id'] == $serviceId) return 1;
                if ($a['service_id'] === null && $b['service_id'] !== null) return 1;
                if ($a['service_id'] !== null && $b['service_id'] === null) return -1;
                return 0;
            });
        }

        echo json_encode([
            'success' => true,
            'data' => $templates
        ]);
    }

    /**
     * Log audit action
     */
    private function logAudit($userId, $action, $entityType, $entityId, $description) {
        try {
            $stmt = $this->db->prepare("
                INSERT INTO audit_logs (user_id, action, entity_type, entity_id, description)
                VALUES (?, ?, ?, ?, ?)
            ");
            $stmt->execute([$userId, $action, $entityType, $entityId, $description]);
        } catch (Exception $e) {
            error_log("Audit log failed: " . $e->getMessage());
        }
    }
}
