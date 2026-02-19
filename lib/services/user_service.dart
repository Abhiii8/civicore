/// CiviCore - User Service
/// 
/// Handles user profile-related API calls

import 'dart:io';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import 'package:dio/dio.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();
  
  // Update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    String? phone,
    File? profileImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'full_name': fullName,
        if (phone != null) 'phone': phone,
      });

      // Add profile image if provided
      if (profileImage != null) {
        final fileName = profileImage.path.split('/').last;
        formData.files.add(MapEntry(
          'profile_picture',
          await MultipartFile.fromFile(
            profileImage.path,
            filename: fileName,
          ),
        ));
      }

      final response = await _apiClient.postFormData(
        ApiConstants.updateProfile,
        formData,
      );
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  
  // Get user profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _apiClient.get(ApiConstants.getProfile);
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
