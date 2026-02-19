/// CiviCore - User Model
/// 
/// Represents user data structure

class UserModel {
  final int id;
  final String email;
  final String fullName;
  final String role;
  final int? roleId;
  final Map<String, dynamic>? department;
  final String? phone;
  final String? profilePicture;
  
  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.roleId,
    this.department,
    this.phone,
    this.profilePicture,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Handle id - can be int or String
    int userId = 0;
    if (json['id'] != null) {
      userId = json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0;
    } else if (json['user_id'] != null) {
      userId = json['user_id'] is int ? json['user_id'] : int.tryParse(json['user_id'].toString()) ?? 0;
    }
    
    // Handle roleId - can be int or null
    int? userRoleId;
    if (json['role_id'] != null) {
      userRoleId = json['role_id'] is int ? json['role_id'] : int.tryParse(json['role_id'].toString());
    }
    
    // Handle department - ensure it's a Map
    Map<String, dynamic>? dept;
    if (json['department'] != null) {
      if (json['department'] is Map) {
        dept = Map<String, dynamic>.from(json['department']);
      }
    }
    
    return UserModel(
      id: userId,
      email: json['email']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      role: json['role']?.toString() ?? json['role_name']?.toString() ?? '',
      roleId: userRoleId,
      department: dept,
      phone: json['phone']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'role_id': roleId,
      'department': department,
      'phone': phone,
      'profile_picture': profilePicture,
    };
  }
}
