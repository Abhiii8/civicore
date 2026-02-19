/// CiviCore - Complaint Service
/// 
/// Handles complaint-related API calls

import 'dart:io';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:dio/dio.dart' as dio;

class ComplaintService {
  final ApiClient _apiClient = ApiClient();
  
  // Create complaint with photo
  Future<Map<String, dynamic>> createComplaint({
    required String subject,
    required String description,
    File? photo,
  }) async {
    try {
      final formData = FormData.fromMap({
        'subject': subject,
        'description': description,
      });

      // Add photo if provided
      if (photo != null) {
        final fileName = photo.path.split('/').last;
        formData.files.add(MapEntry(
          'photo',
          await dio.MultipartFile.fromFile(
            photo.path,
            filename: fileName,
          ),
        ));
      }

      final response = await _apiClient.postFormData(
        ApiConstants.complaints,
        formData,
      );
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  
  // Get my complaints
  Future<List<dynamic>> getMyComplaints() async {
    try {
      final response = await _apiClient.get(ApiConstants.myComplaints);
      if (response.data is Map && response.data['success'] == true) {
        return response.data['data'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
