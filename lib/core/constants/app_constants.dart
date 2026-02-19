/// CiviCore - Application Constants
/// 
/// App-wide constants for configuration

class AppConstants {
  // App Information
  static const String appName = 'CiviCore';
  static const String appVersion = '1.0.0';
  
  // User Roles
  static const String roleCitizen = 'citizen';
  static const String roleOfficer = 'officer';
  static const String roleAdmin = 'admin';
  
  // Application Status
  static const String statusPending = 'pending';
  static const String statusUnderReview = 'under_review';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  
  // Complaint Status
  static const String complaintOpen = 'open';
  static const String complaintInProgress = 'in_progress';
  static const String complaintResolved = 'resolved';
  static const String complaintClosed = 'closed';
  
  // Storage Keys
  static const String keyToken = 'auth_token';
  static const String keyUser = 'user_data';
  static const String keyTheme = 'theme_mode';
  
  // File Upload
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedFileTypes = ['pdf', 'jpg', 'jpeg', 'png'];
}
