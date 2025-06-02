import 'dart:convert';
import 'package:daisy_frontend/util/http_helper.dart';

class LandsService {
  static Future<List<Map<String, dynamic>>> getUserLands() async {
    final response = await HttpHelper.get('/lands/list');

    if (response.statusCode == 200) {
      final List<dynamic> landsJson = jsonDecode(response.body);
      return landsJson.cast<Map<String, dynamic>>();
    } else {
      final error = jsonDecode(response.body)['error'];
      throw Exception('Error: $error');
    }
  }

  static Future<void> createLand(Map<String, dynamic> data) async {
    final response = await HttpHelper.post('/lands/create', body: data);

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body)['error'];
      throw Exception('Error: $error');
    }
  }

  static Future<void> deleteLand(String landId) async {
    final response = await HttpHelper.delete('/lands/$landId');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete land');
    }
  }

  static Future<void> editLand(String landId, Map<String, dynamic> data) async {
    final response = await HttpHelper.put('/lands/$landId', body: data);

    if (response.statusCode != 200) {
      throw Exception('Failed to edit land');
    }
  }

  static Future<Map<String, dynamic>> getLiveWeatherForLand(
    String landId,
  ) async {
    final response = await HttpHelper.get('/lands/$landId/weather');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  static Future<List<Map<String, dynamic>>> getLatestYieldPredictionsForLand(
    String landId,
  ) async {
    final response = await HttpHelper.get('/lands/$landId/predict-yield');

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.cast<Map<String, dynamic>>();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
      throw Exception('Error: $error');
    }
  }

  static Future<List<Map<String, dynamic>>>
  getLatestYieldPredictionsForUser() async {
    final response = await HttpHelper.get('/lands/user/predict-yield');

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.cast<Map<String, dynamic>>();
    } else if (response.statusCode == 404) {
      return [];
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
      throw Exception('Error: $error');
    }
  }

  static Future<Map<String, dynamic>> getWaterSummaryForLand(
    String landId,
  ) async {
    final response = await HttpHelper.get('/lands/$landId/water-summary');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
      throw Exception('Failed to fetch land water summary: $error');
    }
  }

  static Future<Map<String, dynamic>> getWaterSummaryForUser() async {
    final response = await HttpHelper.get('/lands/user/water-summary');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
      throw Exception('Failed to fetch user water summary: $error');
    }
  }
}
