import 'dart:convert';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthApiService {
  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiService.post(
      '/auth/login',
      {'email': email, 'password': password},
      includeAuth: false,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['token'] != null) {
        await ApiService.saveToken(data['token'] as String);
        // Get user info
        if (data['user'] != null) {
          final userData = data['user'] as Map<String, dynamic>;
          return {
            'token': data['token'] as String,
            'user': userData,
            'userId': (data['userId'] ?? userData['_id'] ?? userData['id']).toString(),
            'type': (data['type'] ?? userData['type']).toString(),
          };
        }
      }
      return Map<String, dynamic>.from(data);
    } else {
      final error = json.decode(response.body) as Map<String, dynamic>;
      throw Exception((error['message'] ?? 'Login failed').toString());
    }
  }

  // Signup
  static Future<Map<String, dynamic>> signup({
    required String email,
    required String password,
    required String name,
    required String type, // 'employee' or 'entreprise'
    String? phoneNumber,
    Map<String, dynamic>? resume,
  }) async {
    final userData = {
      'email': email,
      'password': password,
      'name': name,
      'type': type,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };

    final body = {
      'user': userData,
      'resume': resume ?? {}, // Backend expects resume even for entreprises (it's only used for employees)
    };

    final response = await ApiService.post(
      '/auth/signup',
      body,
      includeAuth: false,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      if (data['token'] != null) {
        await ApiService.saveToken(data['token'] as String);
      }
      return Map<String, dynamic>.from(data);
    } else {
      final error = json.decode(response.body) as Map<String, dynamic>;
      throw Exception((error['message'] ?? 'Signup failed').toString());
    }
  }

  // Get user by ID
  static Future<User> getUserById(String userId) async {
    final response = await ApiService.get('/auth/user/$userId');

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return User.fromJson(data);
    } else {
      throw Exception('Failed to get user');
    }
  }

  // Upload avatar
  static Future<String> uploadAvatar(String filePath) async {
    final response = await ApiService.postMultipart(
      '/auth/upload-avatar',
      {},
      'avatar',
      filePath,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return (data['avatarPath'] ?? '').toString();
    } else {
      throw Exception('Failed to upload avatar');
    }
  }
}

