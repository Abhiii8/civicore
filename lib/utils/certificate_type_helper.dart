/// CiviCore - Certificate Type Helper
/// 
/// Provides certificate type options based on service type
/// For example: Income types for Income Certificate

class CertificateTypeHelper {
  // Get available certificate types for a service
  static List<String> getCertificateTypes(String serviceCode, String serviceName) {
    // Convert to lowercase for case-insensitive matching
    final code = serviceCode.toLowerCase();
    final name = serviceName.toLowerCase();
    
    // Income Certificate types
    if (code.contains('ic') || code.contains('income') || name.contains('income')) {
      return [
        'Below Poverty Line (BPL)',
        'Above Poverty Line (APL)',
        'Annual Income: ₹0 - ₹1,00,000',
        'Annual Income: ₹1,00,001 - ₹2,50,000',
        'Annual Income: ₹2,50,001 - ₹5,00,000',
        'Annual Income: ₹5,00,001 - ₹10,00,000',
        'Annual Income: Above ₹10,00,000',
        'Economically Weaker Section (EWS)',
        'Lower Income Group (LIG)',
        'Middle Income Group (MIG)',
        'Higher Income Group (HIG)',
      ];
    }
    
    // Birth Certificate types
    if (code.contains('bc') || code.contains('birth') || name.contains('birth')) {
      return [
        'Normal Delivery',
        'Caesarean Section (C-Section)',
        'Premature Birth',
        'Home Delivery',
        'Hospital Delivery',
        'Multiple Birth (Twins/Triplets)',
      ];
    }
    
    // Residence Certificate types
    if (code.contains('rc') || code.contains('residence') || name.contains('residence')) {
      return [
        'Permanent Residence',
        'Temporary Residence',
        'Domicile Certificate',
        'Residence Proof (Less than 1 year)',
        'Residence Proof (1-5 years)',
        'Residence Proof (More than 5 years)',
      ];
    }
    
    // Scholarship Application types
    if (code.contains('sa') || code.contains('scholarship') || name.contains('scholarship')) {
      return [
        'Merit Scholarship',
        'Need-Based Scholarship',
        'Sports Scholarship',
        'Minority Scholarship',
        'SC/ST Scholarship',
        'OBC Scholarship',
        'General Category Scholarship',
      ];
    }
    
    // Death Certificate types
    if (code.contains('dc') || code.contains('death') || name.contains('death')) {
      return [
        'Natural Death',
        'Accidental Death',
        'Medical Death',
        'Suicide',
        'Homicide',
        'Unknown Cause',
      ];
    }
    
    // Marriage Certificate types
    if (code.contains('mc') || code.contains('marriage') || name.contains('marriage')) {
      return [
        'Hindu Marriage',
        'Muslim Marriage',
        'Christian Marriage',
        'Sikh Marriage',
        'Court Marriage',
        'Inter-religious Marriage',
      ];
    }
    
    // Caste Certificate types
    if (code.contains('cc') || code.contains('caste') || name.contains('caste')) {
      return [
        'Scheduled Caste (SC)',
        'Scheduled Tribe (ST)',
        'Other Backward Class (OBC)',
        'General Category',
        'Economically Backward Class (EBC)',
      ];
    }
    
    // Character Certificate types
    if (code.contains('char') || name.contains('character')) {
      return [
        'Good Character Certificate',
        'Police Verification Certificate',
        'No Criminal Record Certificate',
      ];
    }
    
    // Default: Generic certificate types
    return [
      'Standard Certificate',
      'Verified Certificate',
      'Approved Certificate',
      'Official Certificate',
    ];
  }
  
  // Get value label for certificate value input
  static String getValueLabel(String serviceCode, String serviceName) {
    final code = serviceCode.toLowerCase();
    final name = serviceName.toLowerCase();
    
    if (code.contains('ic') || code.contains('income') || name.contains('income')) {
      return 'Annual Income Amount (₹)';
    }
    if (code.contains('bc') || code.contains('birth') || name.contains('birth')) {
      return 'Birth Weight (kg)';
    }
    if (code.contains('age') || name.contains('age')) {
      return 'Age (years)';
    }
    if (code.contains('rc') || code.contains('residence') || name.contains('residence')) {
      return 'Residence Duration (years)';
    }
    if (code.contains('sa') || code.contains('scholarship') || name.contains('scholarship')) {
      return 'Scholarship Amount (₹)';
    }
    
    return 'Value';
  }
  
  // Get value placeholder text
  static String getValuePlaceholder(String serviceCode, String serviceName) {
    final code = serviceCode.toLowerCase();
    final name = serviceName.toLowerCase();
    
    if (code.contains('ic') || code.contains('income') || name.contains('income')) {
      return 'Enter annual income amount (e.g., 300000)';
    }
    if (code.contains('bc') || code.contains('birth') || name.contains('birth')) {
      return 'Enter birth weight in kg (e.g., 3.5)';
    }
    if (code.contains('age') || name.contains('age')) {
      return 'Enter age in years (e.g., 25)';
    }
    if (code.contains('rc') || code.contains('residence') || name.contains('residence')) {
      return 'Enter residence duration (e.g., 5)';
    }
    if (code.contains('sa') || code.contains('scholarship') || name.contains('scholarship')) {
      return 'Enter scholarship amount (e.g., 50000)';
    }
    
    return 'Enter value';
  }
  
  // Check if service requires value input
  static bool requiresValueInput(String serviceCode, String serviceName) {
    final code = serviceCode.toLowerCase();
    final name = serviceName.toLowerCase();
    
    // Services that require value input
    final servicesRequiringValue = [
      'ic', 'income',
      'bc', 'birth',
      'age',
      'sa', 'scholarship',
    ];
    
    for (final keyword in servicesRequiringValue) {
      if (code.contains(keyword) || name.contains(keyword)) {
        return true;
      }
    }
    
    return false;
  }
  
  // Validate value input
  static String? validateValue(String serviceCode, String serviceName, String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Value is required';
    }
    
    final code = serviceCode.toLowerCase();
    final name = serviceName.toLowerCase();
    
    // Income Certificate - should be numeric
    if (code.contains('ic') || code.contains('income') || name.contains('income')) {
      final numValue = double.tryParse(value);
      if (numValue == null) {
        return 'Please enter a valid number';
      }
      if (numValue < 0) {
        return 'Income cannot be negative';
      }
      if (numValue > 100000000) {
        return 'Income amount seems too high';
      }
    }
    
    // Birth Certificate - should be numeric (weight)
    if (code.contains('bc') || code.contains('birth') || name.contains('birth')) {
      final numValue = double.tryParse(value);
      if (numValue == null) {
        return 'Please enter a valid weight';
      }
      if (numValue < 0.5 || numValue > 10) {
        return 'Please enter a valid birth weight (0.5 - 10 kg)';
      }
    }
    
    // Age - should be numeric
    if (code.contains('age') || name.contains('age')) {
      final numValue = int.tryParse(value);
      if (numValue == null) {
        return 'Please enter a valid age';
      }
      if (numValue < 0 || numValue > 150) {
        return 'Please enter a valid age (0 - 150)';
      }
    }
    
    // Scholarship - should be numeric
    if (code.contains('sa') || code.contains('scholarship') || name.contains('scholarship')) {
      final numValue = double.tryParse(value);
      if (numValue == null) {
        return 'Please enter a valid amount';
      }
      if (numValue < 0) {
        return 'Amount cannot be negative';
      }
    }
    
    return null; // Valid
  }
  
  // Format value for display
  static String formatValue(String serviceCode, String serviceName, String value) {
    final code = serviceCode.toLowerCase();
    final name = serviceName.toLowerCase();
    
    // Income Certificate - format as currency
    if (code.contains('ic') || code.contains('income') || name.contains('income')) {
      final numValue = double.tryParse(value);
      if (numValue != null) {
        // Format with commas: 300000 -> ₹3,00,000
        final formatted = numValue.toStringAsFixed(0);
        String result = '';
        int count = 0;
        for (int i = formatted.length - 1; i >= 0; i--) {
          if (count == 3) {
            result = ',' + result;
            count = 0;
          }
          result = formatted[i] + result;
          count++;
        }
        return '₹$result';
      }
    }
    
    // Birth Certificate - format with unit
    if (code.contains('bc') || code.contains('birth') || name.contains('birth')) {
      return '$value kg';
    }
    
    // Age - format with unit
    if (code.contains('age') || name.contains('age')) {
      return '$value years';
    }
    
    // Scholarship - format as currency
    if (code.contains('sa') || code.contains('scholarship') || name.contains('scholarship')) {
      final numValue = double.tryParse(value);
      if (numValue != null) {
        // Format with commas: 50000 -> ₹50,000
        final formatted = numValue.toStringAsFixed(0);
        String result = '';
        int count = 0;
        for (int i = formatted.length - 1; i >= 0; i--) {
          if (count == 3) {
            result = ',' + result;
            count = 0;
          }
          result = formatted[i] + result;
          count++;
        }
        return '₹$result';
      }
    }
    
    return value;
  }
  
  // Check if service requires certificate type selection
  static bool requiresTypeSelection(String serviceCode, String serviceName) {
    final code = serviceCode.toLowerCase();
    final name = serviceName.toLowerCase();
    
    // Services that require type selection
    final servicesRequiringType = [
      'ic', 'income',
      'bc', 'birth',
      'rc', 'residence',
      'sa', 'scholarship',
      'dc', 'death',
      'mc', 'marriage',
      'cc', 'caste',
      'char', 'character',
    ];
    
    for (final keyword in servicesRequiringType) {
      if (code.contains(keyword) || name.contains(keyword)) {
        return true;
      }
    }
    
    return false;
  }
}
