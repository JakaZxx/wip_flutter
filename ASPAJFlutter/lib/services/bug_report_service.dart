import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class BugReportService {
  String get baseUrl => ApiService.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<void> submitBugReport(Map<String, dynamic> bugData) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/bug-report'),
    );

    // Get headers but remove Content-Type for multipart request
    final headers = await _getHeaders();
    headers.remove('Content-Type');
    request.headers.addAll(headers);

    // Add text fields
    request.fields['device_type'] = bugData['device_type'];
    request.fields['bug_type'] = bugData['bug_type'];
    request.fields['bug_description'] = bugData['bug_description'];

    // Handle image upload if provided
    if (bugData.containsKey('bug_image_path') && bugData['bug_image_path'] != null) {
      // If it's a file path, upload as file
      if (bugData['bug_image_path'] is String) {
        request.files.add(await http.MultipartFile.fromPath(
          'bug_image',
          bugData['bug_image_path'],
        ));
      } else if (bugData['bug_image_path'] is Uint8List) {
        // If it's bytes, upload as bytes
        request.files.add(http.MultipartFile.fromBytes(
          'bug_image',
          bugData['bug_image_path'],
          filename: bugData['image_filename'] ?? 'bug_image.jpg',
        ));
      }
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(responseData);
      if (responseJson['success'] == true) {
        debugPrint('Bug report submitted successfully');
      } else {
        throw Exception('Failed to submit bug report: ${responseJson['message']}');
      }
    } else {
      throw Exception('Failed to submit bug report: $responseData');
    }
  }
}
