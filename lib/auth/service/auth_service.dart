import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:daisy_frontend/util/http_helper.dart';

class AuthService {
  static Future<void> login(String emailOrUsername, String password) async {
    try {
      final response = await HttpHelper.post(
        '/auth/login',
        body: {'email_or_username': emailOrUsername, 'password': password},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
      } else {
        final errorData = jsonDecode(response.body);
        final error = errorData['error'] ?? 'Login failed';
        throw Exception(error);
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your internet.');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signup({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    _validateSignupInput(
      email: email,
      username: username,
      password: password,
      confirmPassword: confirmPassword,
    );

    try {
      final response = await HttpHelper.post(
        '/auth/register',
        body: {'email': email, 'username': username, 'password': password},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['access_token'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
      } else {
        final errorData = jsonDecode(response.body);
        final error = errorData['error'] ?? 'Signup failed';
        throw Exception(error);
      }
    } on TimeoutException {
      throw Exception('Request timed out. Please check your internet.');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  static isTokenValid(String token) {
    return !JwtDecoder.isExpired(token);
  }

  static Future<Map<String, dynamic>?> getUserInfo() async {
    final token = await getToken();
    if (token == null || JwtDecoder.isExpired(token)) return null;

    try {
      return JwtDecoder.decode(token);
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getUserId() async {
    final user = await getUserInfo();
    return user?['sub'];
  }

  static Future<String?> getUsername() async {
    final user = await getUserInfo();
    return user?['username'];
  }

  static void _validateSignupInput({
    required String email,
    required String username,
    required String password,
    required String confirmPassword,
  }) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw Exception('Please enter a valid email address');
    }

    if (username.length < 3 || username.contains(' ')) {
      throw Exception(
        'Username must be at least 3 characters and contain no spaces',
      );
    }

    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters long');
    }

    final lowercase = RegExp(r'[a-z]');
    final uppercase = RegExp(r'[A-Z]');
    final digit = RegExp(r'\d');
    final special = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');

    if (!lowercase.hasMatch(password)) {
      throw Exception('Password must contain at least one lowercase letter');
    }
    if (!uppercase.hasMatch(password)) {
      throw Exception('Password must contain at least one uppercase letter');
    }
    if (!digit.hasMatch(password)) {
      throw Exception('Password must contain at least one number');
    }
    if (!special.hasMatch(password)) {
      throw Exception('Password must contain at least one special character');
    }

    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }
  }
}
