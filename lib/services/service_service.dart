/// CiviCore - Service Service
/// 
/// Handles service-related API calls

import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/service_model.dart';

class ServiceService {
  final ApiClient _apiClient = ApiClient();
  
  // Get all services
  Future<List<ServiceModel>> getAllServices() async {
    try {
      final response = await _apiClient.get(ApiConstants.services);
      if (response.data is! Map) return [];
      
      final responseData = Map<String, dynamic>.from(response.data);
      if (responseData['success'] == true && responseData['data'] is List) {
        final List<dynamic> data = responseData['data'];
        return data.map((json) {
          if (json is Map) {
            return ServiceModel.fromJson(Map<String, dynamic>.from(json));
          }
          return null;
        }).whereType<ServiceModel>().toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
  // Get service by ID
  Future<ServiceModel?> getService(int id) async {
    try {
      final response = await _apiClient.get('${ApiConstants.serviceById}/$id');
      if (response.data is! Map) return null;
      
      final responseData = Map<String, dynamic>.from(response.data);
      if (responseData['success'] == true && responseData['data'] is Map) {
        return ServiceModel.fromJson(Map<String, dynamic>.from(responseData['data']));
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  
  // Create service (Admin only)
  Future<Map<String, dynamic>> createService({
    required String name,
    required int departmentId,
    String? code,
    String? description,
    String? requiredDocuments,
    int processingDays = 7,
    double fee = 0.0,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.services,
        data: {
          'name': name,
          'department_id': departmentId,
          'code': code,
          'description': description,
          'required_documents': requiredDocuments,
          'processing_days': processingDays,
          'fee': fee,
        },
      );
      return response.data;
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
