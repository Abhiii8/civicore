/// CiviCore - Application Service
/// 
/// Handles application-related API calls

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/application_model.dart';

class ApplicationService {
  final ApiClient _apiClient = ApiClient();
  
  // Create application
  Future<Map<String, dynamic>> createApplication(int serviceId) async {
    try {
      // Verify token exists before making request
      final prefs = await SharedPreferences.getInstance();
      final token = await prefs.getString('auth_token');
      
      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'message': 'Please login to apply for services',
        };
      }
      
      final response = await _apiClient.post(
        ApiConstants.applications,
        data: {'service_id': serviceId},
      );
      
      // Handle response properly
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data);
      }
      return {'success': false, 'message': 'Invalid response format'};
    } on DioException catch (e) {
      // Handle Dio errors specifically
      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map) {
          final errorMsg = errorData['message']?.toString() ?? 'Server error';
          return Map<String, dynamic>.from({
            'success': false,
            'message': errorMsg,
            'status_code': e.response!.statusCode,
          });
        }
        return {
          'success': false,
          'message': 'Server error: ${e.response!.statusCode}',
        };
      }
      return {'success': false, 'message': 'Network error: ${e.message}'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  
  // Get my applications
  Future<List<ApplicationModel>> getMyApplications() async {
    try {
      final response = await _apiClient.get(ApiConstants.myApplications);
      if (response.data is! Map) return [];
      
      final responseData = Map<String, dynamic>.from(response.data);
      if (responseData['success'] == true && responseData['data'] is List) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) {
          if (json is Map) {
            return ApplicationModel.fromJson(Map<String, dynamic>.from(json));
          }
          return null;
        }).whereType<ApplicationModel>().toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // Get application by ID
  Future<ApplicationModel?> getApplication(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.applicationById}/$id');
      if (response.data is! Map) return null;
      
      final responseData = Map<String, dynamic>.from(response.data);
      if (responseData['success'] == true && responseData['data'] is Map) {
        return ApplicationModel.fromJson(Map<String, dynamic>.from(responseData['data']));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Get all applications (Admin/Officer)
  Future<List<ApplicationModel>> getAllApplications({String? status}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.applications,
        queryParameters: status != null ? {'status': status} : null,
      );
      if (response.data is! Map) return [];
      
      final responseData = Map<String, dynamic>.from(response.data);
      if (responseData['success'] == true && responseData['data'] is List) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) {
          if (json is Map) {
            return ApplicationModel.fromJson(Map<String, dynamic>.from(json));
          }
          return null;
        }).whereType<ApplicationModel>().toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // Get assigned applications (Officer)
  Future<List<ApplicationModel>> getAssignedApplications({String? status}) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.assignedApplications,
        queryParameters: status != null ? {'status': status} : null,
      );
      if (response.data is! Map) return [];
      
      final responseData = Map<String, dynamic>.from(response.data);
      if (responseData['success'] == true && responseData['data'] is List) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) {
          if (json is Map) {
            return ApplicationModel.fromJson(Map<String, dynamic>.from(json));
          }
          return null;
        }).whereType<ApplicationModel>().toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // Approve application
  Future<Map<String, dynamic>> approveApplication(int id, {String? remarks}) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.approveApplication}/$id/approve',
        data: {'remarks': remarks ?? 'Application approved'},
      );
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
  
  // Reject application
  Future<Map<String, dynamic>> rejectApplication(int id, String rejectionReason, {String? remarks}) async {
    try {
      final response = await _apiClient.post(
        '${ApiConstants.rejectApplication}/$id/reject',
        data: {
          'rejection_reason': rejectionReason,
          'remarks': remarks,
        },
      );
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
