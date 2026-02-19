<?php
/**
 * CiviCore - Main API Router
 * 
 * RESTful API endpoint router
 * Handles all API requests and routes to appropriate controllers
 * 
 * Governance Principles:
 * - Transparency: All actions are logged
 * - Accountability: Role-based access control
 * - Efficiency: RESTful design for fast responses
 * - Paperless: Digital document management
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Load configuration and controllers
require_once __DIR__ . '/config/database.php';
require_once __DIR__ . '/config/jwt.php';
require_once __DIR__ . '/middleware/auth.php';
require_once __DIR__ . '/controllers/AuthController.php';
require_once __DIR__ . '/controllers/ServiceController.php';
require_once __DIR__ . '/controllers/ApplicationController.php';
require_once __DIR__ . '/controllers/DocumentController.php';
require_once __DIR__ . '/controllers/ComplaintController.php';
require_once __DIR__ . '/controllers/AdminController.php';
require_once __DIR__ . '/controllers/UserController.php';
require_once __DIR__ . '/controllers/CertificateTemplateController.php';

// Get request method and URI
$method = $_SERVER['REQUEST_METHOD'];
$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Handle query parameter routing (if .htaccess doesn't work)
if (isset($_GET['route'])) {
    $uri = $_GET['route'];
} else {
    // Remove path prefixes - handle various formats
    $uri = preg_replace('#^/civicore/backend#', '', $uri);
    $uri = preg_replace('#^/backend#', '', $uri);
    $uri = preg_replace('#^/index\.php#', '', $uri);
}

$uri = rtrim($uri, '/');
if (empty($uri)) {
    $uri = '/';
}

// Debug: Log the URI for troubleshooting
error_log("CiviCore API: Method=$method, URI=$uri, Full REQUEST_URI=" . ($_SERVER['REQUEST_URI'] ?? 'N/A'));

// Route handling
try {
    // Debug endpoint - remove in production
    if ($uri === '/api/debug' || $uri === '/debug') {
        echo json_encode([
            'success' => true,
            'method' => $method,
            'uri' => $uri,
            'request_uri' => $_SERVER['REQUEST_URI'] ?? 'N/A',
            'query_string' => $_SERVER['QUERY_STRING'] ?? 'N/A',
            'get_params' => $_GET,
            'post_data' => $_POST,
        ]);
        exit;
    }
    
    // Authentication routes
    if ($uri === '/api/auth/register' && $method === 'POST') {
        $controller = new AuthController();
        $controller->register();
    }
    elseif ($uri === '/api/auth/login' && $method === 'POST') {
        $controller = new AuthController();
        $controller->login();
    }
    
    // Service routes
    elseif ($uri === '/api/services' && $method === 'GET') {
        $controller = new ServiceController();
        $controller->getAllServices();
    }
    elseif (preg_match('/^\/api\/services\/(\d+)$/', $uri, $matches) && $method === 'GET') {
        $controller = new ServiceController();
        $controller->getService($matches[1]);
    }
    elseif ($uri === '/api/services' && $method === 'POST') {
        $controller = new ServiceController();
        $controller->createService();
    }
    elseif (preg_match('/^\/api\/services\/(\d+)$/', $uri, $matches) && $method === 'PUT') {
        $controller = new ServiceController();
        $controller->updateService($matches[1]);
    }
    
    // Application routes
    elseif ($uri === '/api/applications' && $method === 'GET') {
        $controller = new ApplicationController();
        $controller->getAllApplications();
    }
    elseif ($uri === '/api/applications/my-applications' && $method === 'GET') {
        $controller = new ApplicationController();
        $controller->getMyApplications();
    }
    elseif ($uri === '/api/applications/assigned' && $method === 'GET') {
        $controller = new ApplicationController();
        $controller->getAssignedApplications();
    }
    elseif (preg_match('/^\/api\/applications\/(\d+)$/', $uri, $matches) && $method === 'GET') {
        $controller = new ApplicationController();
        $controller->getApplication($matches[1]);
    }
    elseif ($uri === '/api/applications' && $method === 'POST') {
        $controller = new ApplicationController();
        $controller->createApplication();
    }
    elseif (preg_match('/^\/api\/applications\/(\d+)\/assign$/', $uri, $matches) && $method === 'POST') {
        $controller = new ApplicationController();
        $controller->assignApplication($matches[1]);
    }
    elseif (preg_match('/^\/api\/applications\/(\d+)\/approve$/', $uri, $matches) && $method === 'POST') {
        $controller = new ApplicationController();
        $controller->approveApplication($matches[1]);
    }
    elseif (preg_match('/^\/api\/applications\/(\d+)\/reject$/', $uri, $matches) && $method === 'POST') {
        $controller = new ApplicationController();
        $controller->rejectApplication($matches[1]);
    }
    
    // Document routes
    elseif ($uri === '/api/documents/upload' && $method === 'POST') {
        $controller = new DocumentController();
        $controller->uploadDocument();
    }
    elseif (preg_match('/^\/api\/documents\/(\d+)$/', $uri, $matches) && $method === 'GET') {
        $controller = new DocumentController();
        $controller->getDocument($matches[1]);
    }
    elseif (preg_match('/^\/api\/documents\/(\d+)\/download$/', $uri, $matches) && $method === 'GET') {
        $controller = new DocumentController();
        $controller->downloadDocument($matches[1]);
    }
    
    // Complaint routes
    elseif ($uri === '/api/complaints' && $method === 'GET') {
        $controller = new ComplaintController();
        $controller->getAllComplaints();
    }
    elseif ($uri === '/api/complaints/my-complaints' && $method === 'GET') {
        $controller = new ComplaintController();
        $controller->getMyComplaints();
    }
    elseif (preg_match('/^\/api\/complaints\/(\d+)$/', $uri, $matches) && $method === 'GET') {
        $controller = new ComplaintController();
        $controller->getComplaint($matches[1]);
    }
    elseif ($uri === '/api/complaints' && $method === 'POST') {
        $controller = new ComplaintController();
        $controller->createComplaint();
    }
    elseif (preg_match('/^\/api\/complaints\/(\d+)\/status$/', $uri, $matches) && $method === 'PUT') {
        $controller = new ComplaintController();
        $controller->updateComplaintStatus($matches[1]);
    }
    elseif (preg_match('/^\/api\/complaints\/(\d+)\/response$/', $uri, $matches) && $method === 'POST') {
        $controller = new ComplaintController();
        $controller->addComplaintResponse($matches[1]);
    }
    elseif (preg_match('/^\/api\/complaints\/(\d+)\/responses$/', $uri, $matches) && $method === 'GET') {
        $controller = new ComplaintController();
        $controller->getComplaintResponses($matches[1]);
    }
    elseif (preg_match('/^\/api\/complaints\/(\d+)\/assign$/', $uri, $matches) && $method === 'PUT') {
        $controller = new ComplaintController();
        $controller->assignComplaint($matches[1]);
    }
    
    // Admin routes
    elseif ($uri === '/api/admin/dashboard' && $method === 'GET') {
        $controller = new AdminController();
        $controller->getDashboard();
    }
    elseif ($uri === '/api/admin/departments' && $method === 'GET') {
        $controller = new AdminController();
        $controller->getDepartments();
    }
    elseif ($uri === '/api/admin/departments' && $method === 'POST') {
        $controller = new AdminController();
        $controller->createDepartment();
    }
    elseif ($uri === '/api/admin/users' && $method === 'GET') {
        $controller = new AdminController();
        $controller->getUsers();
    }
    elseif ($uri === '/api/admin/users' && $method === 'POST') {
        $controller = new AdminController();
        $controller->createUser();
    }
    elseif (preg_match('/^\/api\/admin\/users\/(\d+)$/', $uri, $matches) && $method === 'PUT') {
        $controller = new AdminController();
        $controller->updateUser($matches[1]);
    }
    elseif ($uri === '/api/admin/audit-logs' && $method === 'GET') {
        $controller = new AdminController();
        $controller->getAuditLogs();
    }
    elseif ($uri === '/api/admin/certificate-templates' && $method === 'GET') {
        $controller = new CertificateTemplateController();
        $controller->getTemplates();
    }
    elseif ($uri === '/api/admin/certificate-templates' && $method === 'POST') {
        $controller = new CertificateTemplateController();
        $controller->uploadTemplate();
    }
    
    // User profile routes
    elseif ($uri === '/api/user/profile' && $method === 'GET') {
        $controller = new UserController();
        $controller->getProfile();
    }
    elseif ($uri === '/api/user/profile' && $method === 'POST') {
        $controller = new UserController();
        $controller->updateProfile();
    }
    
    // 404 - Route not found
    else {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Endpoint not found']);
    }
    
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Internal server error',
        'error' => $e->getMessage()
    ]);
}
