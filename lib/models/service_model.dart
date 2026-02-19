/// CiviCore - Service Model
/// 
/// Represents government service structure

class ServiceModel {
  final int id;
  final String name;
  final String code;
  final String? description;
  final String? requiredDocuments;
  final int processingDays;
  final double fee;
  final String departmentName;
  final int? departmentId;
  
  ServiceModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.requiredDocuments,
    required this.processingDays,
    required this.fee,
    required this.departmentName,
    this.departmentId,
  });
  
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Handle id - can be int or String
    int serviceId = json['id'] is int 
        ? json['id'] 
        : int.tryParse(json['id']?.toString() ?? '0') ?? 0;
    
    // Handle departmentId
    int? deptId;
    if (json['department_id'] != null) {
      deptId = json['department_id'] is int 
          ? json['department_id'] 
          : int.tryParse(json['department_id'].toString());
    }
    
    return ServiceModel(
      id: serviceId,
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      description: json['description']?.toString(),
      requiredDocuments: json['required_documents']?.toString(),
      processingDays: json['processing_days'] is int 
          ? json['processing_days'] 
          : int.tryParse(json['processing_days']?.toString() ?? '7') ?? 7,
      fee: json['fee'] is double 
          ? json['fee'] 
          : (json['fee'] is int 
              ? json['fee'].toDouble() 
              : double.tryParse(json['fee']?.toString() ?? '0') ?? 0.0),
      departmentName: json['department_name']?.toString() ?? '',
      departmentId: deptId,
    );
  }
}
