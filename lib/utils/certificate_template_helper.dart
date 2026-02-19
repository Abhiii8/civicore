/// CiviCore - Certificate Template Helper
/// 
/// Helper functions for common certificate template configurations
/// Pre-configured templates for different certificate types

class CertificateTemplateHelper {
  // Get template configuration for Birth Certificate
  static Map<String, Map<String, dynamic>> getBirthCertificateFields({
    double nameX = 200.0,
    double nameY = 300.0,
    double numberX = 200.0,
    double numberY = 350.0,
    double dateX = 200.0,
    double dateY = 400.0,
  }) {
    return {
      'applicant_name': {
        'position': {'x': nameX, 'y': nameY},
        'fontSize': 18.0,
        'fontWeight': 'bold',
        'color': [0, 0, 0], // Black
      },
      'application_number': {
        'position': {'x': numberX, 'y': numberY},
        'fontSize': 12.0,
        'fontWeight': 'normal',
        'color': [0, 0, 0],
      },
      'date_of_issue': {
        'position': {'x': dateX, 'y': dateY},
        'fontSize': 12.0,
        'fontWeight': 'normal',
        'color': [0, 0, 0],
      },
    };
  }

  // Get template configuration for Income Certificate
  static Map<String, Map<String, dynamic>> getIncomeCertificateFields({
    double nameX = 200.0,
    double nameY = 280.0,
    double numberX = 200.0,
    double numberY = 330.0,
    double dateX = 200.0,
    double dateY = 380.0,
  }) {
    return {
      'applicant_name': {
        'position': {'x': nameX, 'y': nameY},
        'fontSize': 16.0,
        'fontWeight': 'bold',
        'color': [0, 0, 0],
      },
      'application_number': {
        'position': {'x': numberX, 'y': numberY},
        'fontSize': 11.0,
        'fontWeight': 'normal',
        'color': [0, 0, 0],
      },
      'date_of_issue': {
        'position': {'x': dateX, 'y': dateY},
        'fontSize': 11.0,
        'fontWeight': 'normal',
        'color': [0, 0, 0],
      },
      'department': {
        'position': {'x': dateX, 'y': dateY + 30},
        'fontSize': 11.0,
        'fontWeight': 'normal',
        'color': [0, 0, 0],
      },
    };
  }

  // Get template URL for a service
  // You can customize this to return template URLs based on service type
  static String? getTemplateUrlForService(String serviceName) {
    // Map service names to template URLs
    final templateMap = {
      'birth certificate': 'http://10.0.2.2/civicore/backend/uploads/templates/birth_certificate.png',
      'income certificate': 'http://10.0.2.2/civicore/backend/uploads/templates/income_certificate.png',
      'residence certificate': 'http://10.0.2.2/civicore/backend/uploads/templates/residence_certificate.png',
    };

    return templateMap[serviceName.toLowerCase()];
  }

  // Get default template configuration
  static Map<String, Map<String, dynamic>> getDefaultFields() {
    return {
      'applicant_name': {
        'position': {'x': 150.0, 'y': 200.0},
        'fontSize': 18.0,
        'fontWeight': 'bold',
        'color': [0, 0, 0],
      },
      'application_number': {
        'position': {'x': 150.0, 'y': 250.0},
        'fontSize': 12.0,
        'fontWeight': 'normal',
        'color': [0, 0, 0],
      },
      'service_name': {
        'position': {'x': 150.0, 'y': 280.0},
        'fontSize': 14.0,
        'fontWeight': 'bold',
        'color': [0, 0, 0],
      },
      'date_of_issue': {
        'position': {'x': 150.0, 'y': 320.0},
        'fontSize': 12.0,
        'fontWeight': 'normal',
        'color': [0, 0, 0],
      },
      'department': {
        'position': {'x': 150.0, 'y': 350.0},
        'fontSize': 12.0,
        'fontWeight': 'normal',
        'color': [0, 0, 0],
      },
    };
  }
}
