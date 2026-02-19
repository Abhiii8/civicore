/// CiviCore - API Client
/// 
/// Handles all HTTP requests to the backend
/// Includes JWT token management and error handling

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  late Dio _dio;
  static final ApiClient _instance = ApiClient._internal();
  
  factory ApiClient() {
    return _instance;
  }
  
  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 60), // Increased timeout
      receiveTimeout: const Duration(seconds: 60), // Increased timeout
      sendTimeout: const Duration(seconds: 60), // Added send timeout
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        return status! < 500; // Accept status codes less than 500
      },
    ));
    
    // Add interceptor for token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expired or invalid - handle logout
          _handleUnauthorized();
        }
        return handler.next(error);
      },
    ));
  }
  
  void _handleUnauthorized() {
    // Clear token and navigate to login
    // This will be handled by auth service
  }
  
  // Build URL with query parameter routing (fallback if .htaccess doesn't work)
  String _buildUrl(String endpoint) {
    // Remove leading slash if present
    endpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    // Use query parameter routing for better compatibility
    return '${ApiConstants.baseUrl}/index.php?route=$endpoint';
  }
  
  // GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    try {
      final url = _buildUrl(endpoint);
      print('API GET Request: $url'); // Debug log
      final response = await _dio.get(url, queryParameters: queryParameters);
      
      // Check for error responses even with 200 status
      if (response.data is Map && response.data['success'] == false) {
        final errorMsg = response.data['message'] ?? 'Request failed';
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          message: errorMsg,
        );
      }
      
      return response;
    } on DioException catch (e) {
      // Re-throw with better error message
      throw _handleError(e);
    } catch (e) {
      // Handle any other errors
      throw DioException(
        requestOptions: RequestOptions(path: endpoint),
        type: DioExceptionType.unknown,
        message: 'Unexpected error: $e',
      );
    }
  }
  
  // POST request
  Future<Response> post(String endpoint, {dynamic data}) async {
    try {
      final url = _buildUrl(endpoint);
      print('API POST Request: $url'); // Debug log
      final response = await _dio.post(url, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      throw DioException(
        requestOptions: RequestOptions(path: endpoint),
        type: DioExceptionType.unknown,
        message: 'Unexpected error: $e',
      );
    }
  }
  
  // PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    try {
      final url = _buildUrl(endpoint);
      final response = await _dio.put(url, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // DELETE request
  Future<Response> delete(String endpoint) async {
    try {
      final url = _buildUrl(endpoint);
      final response = await _dio.delete(url);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  // POST with FormData (for file uploads)
  Future<Response> postFormData(String endpoint, FormData formData) async {
    try {
      final url = _buildUrl(endpoint);
      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }
  
  DioException _handleError(DioException error) {
    String message = 'An error occurred';
    
    // Handle different error types
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check:\n'
            '1. XAMPP Apache is running\n'
            '2. Backend URL is correct\n'
            '3. Your internet connection';
        break;
      case DioExceptionType.connectionError:
        message = 'Cannot connect to server. Please check:\n'
            '1. XAMPP Apache is running\n'
            '2. Backend is accessible at: ${ApiConstants.baseUrl}\n'
            '3. Firewall is not blocking Apache';
        break;
      case DioExceptionType.badResponse:
        if (error.response != null) {
          if (error.response!.data is Map) {
            final responseData = Map<String, dynamic>.from(error.response!.data);
            message = responseData['message']?.toString() ?? 'An error occurred';
            
            // Provide specific messages for common errors
            if (error.response!.statusCode == 401) {
              message = 'Unauthorized. Please login again.';
            } else if (error.response!.statusCode == 403) {
              message = 'Access denied. You do not have permission to perform this action.';
            } else if (error.response!.statusCode == 404) {
              message = 'Endpoint not found. Please check backend configuration.';
            }
          } else {
            message = 'Server error: ${error.response!.statusCode}';
          }
        }
        break;
      default:
        message = 'Network error. Please check your connection and ensure XAMPP Apache is running.';
    }
    
    // Log the error for debugging
    print('API Error: ${error.type}');
    print('URL: ${error.requestOptions.uri}');
    print('Message: $message');
    
    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: error.error,
      message: message,
    );
  }
}
