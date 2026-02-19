/// CiviCore - API Constants
/// 
/// Centralized API endpoint configuration
/// Supports easy environment switching (dev/prod)

class ApiConstants {
  // Base URL - Update this to your backend URL
  // For Android Emulator: use http://10.0.2.2 (maps to host's localhost)
  // For Physical Device: use http://YOUR_COMPUTER_IP (e.g., http://192.168.1.100)
  // For Windows Desktop: use http://localhost
  static const String baseUrl = 'http://10.0.2.2/civicore/backend';
  
  // API Endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  
  static const String services = '/api/services';
  static const String serviceById = '/api/services'; // Append /{id}
  
  static const String applications = '/api/applications';
  static const String myApplications = '/api/applications/my-applications';
  static const String assignedApplications = '/api/applications/assigned';
  static const String applicationById = '/api/applications'; // Append /{id}
  static const String assignApplication = '/api/applications'; // Append /{id}/assign
  static const String approveApplication = '/api/applications'; // Append /{id}/approve
  static const String rejectApplication = '/api/applications'; // Append /{id}/reject
  
  static const String uploadDocument = '/api/documents/upload';
  static const String documentById = '/api/documents'; // Append /{id}
  static const String downloadDocument = '/api/documents'; // Append /{id}/download
  
  static const String complaints = '/api/complaints';
  static const String myComplaints = '/api/complaints/my-complaints';
  static const String complaintById = '/api/complaints'; // Append /{id}
  static const String updateComplaintStatus = '/api/complaints'; // Append /{id}/status
  static const String complaintResponse = '/api/complaints'; // Append /{id}/response
  static const String complaintResponses = '/api/complaints'; // Append /{id}/responses
  static const String assignComplaint = '/api/complaints'; // Append /{id}/assign
  
  static const String adminDashboard = '/api/admin/dashboard';
  static const String adminDepartments = '/api/admin/departments';
  static const String adminUsers = '/api/admin/users';
  static const String adminAuditLogs = '/api/admin/audit-logs';
  
  static const String getProfile = '/api/user/profile';
  static const String updateProfile = '/api/user/profile';
  
  static const String certificateTemplates = '/api/admin/certificate-templates';
  
  // Helper method to build full URL
  static String getUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
