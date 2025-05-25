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

  static Future<void> createLand({
    required String name,
    required double latitude,
    required double longitude,
  }) async {
    final response = await HttpHelper.post(
      '/lands/create',
      body: {'name': name, 'latitude': latitude, 'longitude': longitude},
    );

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
}
