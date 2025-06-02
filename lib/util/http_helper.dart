import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:daisy_frontend/auth/service/auth_service.dart';

class HttpHelper {
  static const String baseUrl = 'https://daisy-backend-wk3f.onrender.com';

  static Future<http.Response> get(String endpoint) async {
    final token = await AuthService.getToken();
    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(token),
    );
  }

  static Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final token = await AuthService.getToken();
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(token),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final token = await AuthService.getToken();
    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(token),
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> delete(String endpoint) async {
    final token = await AuthService.getToken();
    return http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: _buildHeaders(token),
    );
  }

  static Map<String, String> _buildHeaders(String? token) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }
}
