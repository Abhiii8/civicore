/// CiviCore - Template Service
/// 
/// Handles fetching certificate templates from backend

import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';

class TemplateService {
  final ApiClient _apiClient = ApiClient();

  // Get template for a specific service
  Future<Map<String, dynamic>?> getTemplateForService(int serviceId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.certificateTemplates,
        queryParameters: {'service_id': serviceId},
      );
      
      if (response.data['success'] == true && response.data['data'] is List) {
        final templates = response.data['data'] as List;
        
        // First, try to find template specifically for this service
        for (var template in templates) {
          final templateMap = Map<String, dynamic>.from(template);
          final templateServiceId = templateMap['service_id'];
          
          if (templateServiceId != null) {
            final id = templateServiceId is int ? templateServiceId : int.tryParse(templateServiceId.toString());
            if (id == serviceId) {
              return templateMap;
            }
          }
        }
        
        // If no specific template, return default (service_id is null)
        for (var template in templates) {
          final templateMap = Map<String, dynamic>.from(template);
          if (templateMap['service_id'] == null) {
            return templateMap;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error fetching template: $e');
      return null;
    }
  }

  // Get all templates
  Future<List<Map<String, dynamic>>> getAllTemplates() async {
    try {
      final response = await _apiClient.get(ApiConstants.certificateTemplates);
      if (response.data['success'] == true && response.data['data'] is List) {
        final templates = response.data['data'] as List;
        return templates.map((t) => Map<String, dynamic>.from(t)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
