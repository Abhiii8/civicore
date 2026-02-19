<?php
/**
 * CiviCore - User Controller
 * 
 * Manages user profile operations
 * Supports user data management and profile picture upload
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../middleware/auth.php';

class UserController {
    private $db;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
    }

    /**
     * Get user profile
     * GET /api/user/profile
     */
    public function getProfile() {
        $auth = new AuthMiddleware();
        $user = $auth->requireAuth();

        $stmt = $this->db->prepare("
            SELECT u.id, u.email, u.full_name, u.phone, u.profile_picture, 
                   r.name as role_name, d.name as department_name
            FROM users u
            LEFT JOIN roles r ON u.role_id = r.id
            LEFT JOIN departments d ON u.department_id = d.id
            WHERE u.id = ?
        ");
        $stmt->execute([$user['user_id']]);
        $profile = $stmt->fetch(PDO::FETCH_ASSOC);

        if ($profile) {
            echo json_encode([
                'success' => true,
                'data' => [
                    'id' => (int)$profile['id'],
                    'email' => $profile['email'],
                    'full_name' => $profile['full_name'],
                    'phone' => $profile['phone'],
                    'profile_picture' => $profile['profile_picture'],
                    'role' => $profile['role_name'],
                    'department' => $profile['department_name'],
                ]
            ]);
        } else {
            http_response_code(404);
            echo json_encode(['success' => false, 'message' => 'Profile not found']);
        }
    }

    /**
     * Update user profile
     * POST /api/user/profile
     * Supports multipart/form-data for profile picture upload
     */
    public function updateProfile() {
        $auth = new AuthMiddleware();
        $user = $auth->requireAuth();

        $fullName = null;
        $phone = null;
        $profilePicturePath = null;

        // Handle multipart/form-data (with profile picture) or JSON
        if ($_SERVER['CONTENT_TYPE'] && strpos($_SERVER['CONTENT_TYPE'], 'multipart/form-data') !== false) {
            // Handle multipart form data
            $fullName = $_POST['full_name'] ?? null;
            $phone = $_POST['phone'] ?? null;

            // Handle profile picture upload
            if (isset($_FILES['profile_picture']) && $_FILES['profile_picture']['error'] === UPLOAD_ERR_OK) {
                $uploadDir = __DIR__ . '/../uploads/profiles/';
                if (!file_exists($uploadDir)) {
                    mkdir($uploadDir, 0777, true);
                }

                $allowedTypes = ['image/jpeg', 'image/jpg', 'image/png'];
                $maxSize = 5 * 1024 * 1024; // 5MB

                $file = $_FILES['profile_picture'];
                $finfo = finfo_open(FILEINFO_MIME_TYPE);
                $mimeType = finfo_file($finfo, $file['tmp_name']);
                finfo_close($finfo);

                if (in_array($mimeType, $allowedTypes) && $file['size'] <= $maxSize) {
                    $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
                    $filename = 'profile_' . $user['user_id'] . '_' . time() . '.' . $extension;
                    $filepath = $uploadDir . $filename;

                    if (move_uploaded_file($file['tmp_name'], $filepath)) {
                        $profilePicturePath = 'uploads/profiles/' . $filename;
                        
                        // Delete old profile picture if exists
                        $oldStmt = $this->db->prepare("SELECT profile_picture FROM users WHERE id = ?");
                        $oldStmt->execute([$user['user_id']]);
                        $oldProfile = $oldStmt->fetch(PDO::FETCH_ASSOC);
                        if ($oldProfile && $oldProfile['profile_picture']) {
                            $oldPath = __DIR__ . '/../' . $oldProfile['profile_picture'];
                            if (file_exists($oldPath)) {
                                unlink($oldPath);
                            }
                        }
                    }
                }
            }
        } else {
            // Handle JSON data
            $data = json_decode(file_get_contents("php://input"), true);
            $fullName = $data['full_name'] ?? null;
            $phone = $data['phone'] ?? null;
        }

        // Build update query
        $fields = [];
        $values = [];

        if ($fullName !== null) {
            $fields[] = "full_name = ?";
            $values[] = $fullName;
        }

        if ($phone !== null) {
            $fields[] = "phone = ?";
            $values[] = $phone;
        }

        if ($profilePicturePath !== null) {
            $fields[] = "profile_picture = ?";
            $values[] = $profilePicturePath;
        }

        if (empty($fields)) {
            http_response_code(400);
            echo json_encode(['success' => false, 'message' => 'No fields to update']);
            return;
        }

        $values[] = $user['user_id'];
        $sql = "UPDATE users SET " . implode(", ", $fields) . " WHERE id = ?";

        try {
            $stmt = $this->db->prepare($sql);
            $stmt->execute($values);

            // Log audit
            $this->logAudit($user['user_id'], 'UPDATE_PROFILE', 'user', $user['user_id'], 'Updated profile');

            echo json_encode([
                'success' => true,
                'message' => 'Profile updated successfully',
                'data' => [
                    'profile_picture' => $profilePicturePath
                ]
            ]);
        } catch (Exception $e) {
            http_response_code(500);
            echo json_encode(['success' => false, 'message' => 'Failed to update profile: ' . $e->getMessage()]);
        }
    }

    /**
     * Log audit trail
     */
    private function logAudit($userId, $action, $entityType, $entityId, $description) {
        try {
            $stmt = $this->db->prepare("
                INSERT INTO audit_logs (user_id, action, entity_type, entity_id, description)
                VALUES (?, ?, ?, ?, ?)
            ");
            $stmt->execute([$userId, $action, $entityType, $entityId, $description]);
        } catch (Exception $e) {
            // Silently fail audit logging
            error_log("Audit log failed: " . $e->getMessage());
        }
    }
}
