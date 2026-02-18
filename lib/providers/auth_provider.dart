import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  AuthProvider() {
    _loadUser();
  }

  Future<void> _loadUser() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      if (userJson != null) {
        _currentUser = User.fromJson(json.decode(userJson));
        _isAuthenticated = true;
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthApiService.login(email, password);
      
      // Get user info from result
      final userData = result['user'];
      if (userData != null) {
        _currentUser = User.fromJson(userData as Map<String, dynamic>);
      } else {
        // If no user data in response, fetch it using userId
        final userId = result['userId']?.toString();
        if (userId != null) {
          _currentUser = await AuthApiService.getUserById(userId);
        } else {
          throw Exception('User data not found in login response');
        }
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', json.encode(_currentUser!.toJson()));
      
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Backend expects 'entreprise' or 'employee'
      final type = role == 'company' ? 'entreprise' : 'employee';
      
      final result = await AuthApiService.signup(
        email: email,
        password: password,
        name: name,
        type: type,
      );

      // Get user info - might need to fetch user by ID
      final userId = result['userId'] ?? result['user']?['_id'] ?? result['user']?['id'];
      if (userId != null) {
        _currentUser = await AuthApiService.getUserById(userId.toString());
      } else if (result['user'] != null) {
        _currentUser = User.fromJson(result['user']);
      } else {
        throw Exception('User data not found in response');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('current_user', json.encode(_currentUser!.toJson()));
      
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Register error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    await ApiService.clearToken();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', json.encode(user.toJson()));
    notifyListeners();
  }
}


