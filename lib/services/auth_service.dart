/// CiviCore - Authentication Service
/// 
/// Handles user authentication, registration, and token management
/// Implements secure JWT token storage

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api/api_client.dart';
import '../core/constants/api_constants.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  
  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      // Ensure response.data is a Map
      if (response.data is! Map) {
        return {
          'success': false,
          'message': 'Invalid response format from server',
        };
      }
      
      final responseData = Map<String, dynamic>.from(response.data);
      
      if (responseData['success'] == true) {
        final token = responseData['token']?.toString();
        final userData = responseData['user'];
        
        // Ensure userData is a Map
        if (userData == null || userData is! Map) {
          return {
            'success': false,
            'message': 'Invalid user data received',
          };
        }
        
        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        if (token != null && token.isNotEmpty) {
          await prefs.setString('auth_token', token);
          // Also save user data as JSON for profile access
          await prefs.setString('user_data', jsonEncode(userData));
        }
        
        return {
          'success': true,
          'user': UserModel.fromJson(Map<String, dynamic>.from(userData)),
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message']?.toString() ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // Register
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? aadhaarNumber,
    String? address,
    String? dateOfBirth,
  }) async {
    try {
      final response = await _apiClient.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'phone': phone,
          'aadhaar_number': aadhaarNumber,
          'address': address,
          'date_of_birth': dateOfBirth,
        },
      );
      
      // Ensure response.data is a Map
      if (response.data is! Map) {
        return {
          'success': false,
          'message': 'Invalid response format from server',
        };
      }
      
      final responseData = Map<String, dynamic>.from(response.data);
      
      if (responseData['success'] == true) {
        final token = responseData['token']?.toString();
        final userData = responseData['user'];
        
        // Ensure userData is a Map
        if (userData == null || userData is! Map) {
          return {
            'success': false,
            'message': 'Invalid user data received',
          };
        }
        
        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        if (token != null && token.isNotEmpty) {
          await prefs.setString('auth_token', token);
          // Also save user data as JSON for profile access
          await prefs.setString('user_data', jsonEncode(userData));
        }
        
        return {
          'success': true,
          'user': UserModel.fromJson(Map<String, dynamic>.from(userData)),
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message']?.toString() ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  
  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
  
  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }
  
  // Get current user token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  // Get stored user data
  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataStr = prefs.getString('user_data');
      if (userDataStr != null) {
        final userData = Map<String, dynamic>.from(
          jsonDecode(userDataStr) as Map,
        );
        return UserModel.fromJson(userData);
      }
      
      // If not in storage, try to get from API
      final token = await getToken();
      if (token != null) {
        final response = await _apiClient.get(ApiConstants.getProfile);
        if (response.data is Map && response.data['success'] == true) {
          final userData = response.data['data'];
          if (userData is Map) {
            final user = UserModel.fromJson(Map<String, dynamic>.from(userData));
            // Save to storage
            await prefs.setString('user_data', jsonEncode(user.toJson()));
            return user;
          }
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
