import 'dart:convert';
import 'package:daisy_frontend/util/http_helper.dart';

class BlockService {
  static Future<List<Map<String, dynamic>>> getBlocksByLandId(
    String landId,
  ) async {
    final response = await HttpHelper.get('/lands/$landId/blocks/');

    if (response.statusCode == 200) {
      final List<dynamic> blocksJson = jsonDecode(response.body);
      return blocksJson.cast<Map<String, dynamic>>();
    } else {
      final error = jsonDecode(response.body)['error'];
      throw Exception('Error: $error');
    }
  }

  static Future<void> createBlock(
    String landId,
    Map<String, dynamic> data,
  ) async {
    final response = await HttpHelper.post(
      '/lands/$landId/blocks/',
      body: data,
    );

    if (response.statusCode != 201) {
      final error = jsonDecode(response.body)['error'];
      throw Exception('Error: $error');
    }
  }

  static Future<void> deleteBlock(String landId, String blockId) async {
    final response = await HttpHelper.delete('/lands/$landId/blocks/$blockId');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete block');
    }
  }

  static Future<void> editBlock(
    String landId,
    String blockId,
    Map<String, dynamic> data,
  ) async {
    final response = await HttpHelper.put(
      '/lands/$landId/blocks/$blockId',
      body: data,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit block');
    }
  }

  static Future<Map<String, dynamic>> getCropDistribution({
    String? landId,
  }) async {
    final endpoint =
        landId == null
            ? '/lands/crop-distribution'
            : '/lands/$landId/blocks/crop-distribution';

    final response = await HttpHelper.get(endpoint);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final error = jsonDecode(response.body)['error'] ?? 'Unknown error';
      throw Exception('Error: $error');
    }
  }
}
