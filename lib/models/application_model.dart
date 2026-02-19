/// CiviCore - Application Model
/// 
/// Represents citizen application structure

class ApplicationModel {
  final int id;
  final String applicationNumber;
  final String status;
  final int? serviceId;
  final String serviceName;
  final String serviceCode;
  final String departmentName;
  final String citizenName;
  final String? citizenEmail;
  final String? officerName;
  final String? remarks;
  final String? rejectionReason;
  final String? certificatePath;
  final DateTime appliedDate;
  final DateTime? reviewedDate;
  final DateTime? approvedDate;
  final List<Map<String, dynamic>>? documents;
  final List<Map<String, dynamic>>? logs;
  
  ApplicationModel({
    required this.id,
    required this.applicationNumber,
    required this.status,
    this.serviceId,
    required this.serviceName,
    required this.serviceCode,
    required this.departmentName,
    required this.citizenName,
    this.citizenEmail,
    this.officerName,
    this.remarks,
    this.rejectionReason,
    this.certificatePath,
    required this.appliedDate,
    this.reviewedDate,
    this.approvedDate,
    this.documents,
    this.logs,
  });
  
  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    // Handle id - can be int or String
    int appId = json['id'] is int 
        ? json['id'] 
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    
    // Handle dates safely
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) throw FormatException('Date is null');
      if (dateValue is DateTime) return dateValue;
      return DateTime.parse(dateValue.toString());
    }
    
    DateTime? parseNullableDate(dynamic dateValue) {
      if (dateValue == null) return null;
      try {
        if (dateValue is DateTime) return dateValue;
        return DateTime.parse(dateValue.toString());
      } catch (e) {
        return null;
      }
    }
    
    // Handle service_id
    int? serviceId;
    if (json['service_id'] != null) {
      serviceId = json['service_id'] is int 
          ? json['service_id'] 
          : int.tryParse(json['service_id'].toString());
    }
    
    return ApplicationModel(
      id: appId,
      applicationNumber: json['application_number']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      serviceId: serviceId,
      serviceName: json['service_name']?.toString() ?? '',
      serviceCode: json['service_code']?.toString() ?? '',
      departmentName: json['department_name']?.toString() ?? '',
      citizenName: json['citizen_name']?.toString() ?? '',
      citizenEmail: json['citizen_email']?.toString(),
      officerName: json['officer_name']?.toString(),
      remarks: json['remarks']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      certificatePath: json['certificate_path']?.toString(),
      appliedDate: parseNullableDate(json['applied_date']) ?? DateTime.now(),
      reviewedDate: parseNullableDate(json['reviewed_date']),
      approvedDate: parseNullableDate(json['approved_date']),
      documents: json['documents'] != null && json['documents'] is List
          ? List<Map<String, dynamic>>.from(
              json['documents'].map((doc) => doc is Map ? Map<String, dynamic>.from(doc) : {}))
          : null,
      logs: json['logs'] != null && json['logs'] is List
          ? List<Map<String, dynamic>>.from(
              json['logs'].map((log) => log is Map ? Map<String, dynamic>.from(log) : {}))
          : null,
    );
  }
  
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'under_review':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}
