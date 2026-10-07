import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_mobile_assistant/utils/constants.dart';
import 'package:ai_mobile_assistant/models/detection_result.dart';

/// Centralized API service for all backend communication.
class ApiService {
  /// Detect objects in an image using YOLOv8 backend.
  Future<List<DetectionResult>> detectObjects(File imageFile) async {
    final uri = Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.endpointDetect}');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send().timeout(AppConstants.apiTimeout);
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final json = jsonDecode(responseData);
      if (json['objects'] != null) {
        return (json['objects'] as List)
            .map((item) => DetectionResult.fromJson(item))
            .toList();
      }
    } else {
      throw Exception('Server returned status ${response.statusCode}');
    }
    return [];
  }

  /// Describe a scene using the BLIP backend.
  Future<String> describeScene(File imageFile) async {
    final uri = Uri.parse(
        '${AppConstants.apiBaseUrl}${AppConstants.endpointDescribe}');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
        await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send().timeout(AppConstants.apiTimeout);
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final json = jsonDecode(responseData);
      return json['description'] ?? '';
    } else {
      throw Exception('Server returned status ${response.statusCode}');
    }
  }

  /// Check if the backend server is running.
  Future<bool> checkHealth() async {
    try {
      final uri = Uri.parse(AppConstants.apiBaseUrl);
      final response =
          await http.get(uri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
