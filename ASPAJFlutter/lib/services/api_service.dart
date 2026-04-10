import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/student.dart';
import '../models/borrowing.dart';
import '../models/borrowing_item.dart';
import '../models/commodity.dart';
import '../models/school_class.dart';
import '../models/dashboard_stats.dart';

class ApiService {
  // Note: Using 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS, or your local machine IP
  static const String _defaultIP = '192.168.1.3'; 
  
  static String get baseUrl => 'http://$_defaultIP:8000/api';
  static String get baseStorageUrl => 'http://$_defaultIP:8000';

  static String? fixPhotoUrl(String? url) {
    if (url == null || url.isEmpty) return null;

    try {
      // If it's already a full URL, return it as is
      if (url.startsWith('http://') || url.startsWith('https://')) {
        print('fixPhotoUrl - Already full URL: $url');
        return url;
      }

      // For relative paths, build the full URL pointing to /storage/<path>
      final base = Uri.parse(baseStorageUrl);
      final segments = [
        'storage',
        ...url.split('/').where((seg) => seg.isNotEmpty),
      ];

      final uri = Uri(
        scheme: base.scheme,
        host: base.host,
        port: base.hasPort ? base.port : null,
        pathSegments: segments,
      );

      print('fixPhotoUrl - Original URL: $url');
      print('fixPhotoUrl - Fixed URL: ${uri.toString()}');
      return uri.toString();
    } catch (e, stackTrace) {
      print('fixPhotoUrl - Error: $e');
      print('fixPhotoUrl - Stack Trace: $stackTrace');
      return null;
    }
  }

  // Get stored token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Set token
  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Remove token
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  // Get headers with authorization
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('ApiService.login: Attempting login for email: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('ApiService.login: Response status: ${response.statusCode}');
      print('ApiService.login: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('ApiService.login: Parsed response data: $data');

        if (data['success'] == true && data['token'] != null) {
          await _setToken(data['token']);
          print('ApiService.login: Token saved successfully');
          return data;
        } else {
          print(
            'ApiService.login: Login failed - success: ${data['success']}, token: ${data['token']}',
          );
          throw Exception(
            'Login failed: ${data['message'] ?? 'Invalid response format'}',
          );
        }
      } else {
        print(
          'ApiService.login: HTTP error ${response.statusCode}: ${response.body}',
        );
        throw Exception(
          'Login failed: HTTP ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e, stackTrace) {
      print('ApiService.login: Exception occurred: $e');
      print('ApiService.login: Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _removeToken();
  }

  // Get current user
  Future<User> getCurrentUser() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: await _getHeaders(),
    );

    print('Get current user response status: ${response.statusCode}');
    print('Get current user response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      print('Parsed response JSON: $responseJson');

      if (responseJson['success'] == true && responseJson['data'] != null) {
        final userJson = responseJson['data'];
        print('Extracted user data: $userJson');
        final user = User.fromJson(userJson);
        print('Created user object - role: ${user.role}');
        return user;
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to get user: ${response.body}');
    }
  }

  // Get dashboard stats
  Future<DashboardStats> getDashboardStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard'), // Single endpoint for all roles
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['data'] != null) {
        return DashboardStats.fromJson(data['data']);
      } else {
        throw Exception('Failed to get dashboard stats: ${data['message'] ?? 'Invalid format'}');
      }
    } else {
      throw Exception('Failed to get dashboard stats: ${response.body}');
    }
  }

  // Get commodities
  Future<List<Commodity>> getCommodities({
    String? search,
    String? jurusan,
  }) async {
    print(
      'ApiService.getCommodities: Starting to fetch commodities with search: $search, jurusan: $jurusan',
    );
    final queryParams = <String, String>{};
    if (search != null) queryParams['search'] = search;
    if (jurusan != null) queryParams['jurusan'] = jurusan;

    final uri = Uri.parse(
      '$baseUrl/commodities',
    ).replace(queryParameters: queryParams);
    print('ApiService.getCommodities: Requesting URI: $uri');
    final response = await http.get(uri, headers: await _getHeaders());
    print('ApiService.getCommodities: Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        final List<dynamic> data = responseJson['data'];
        print(
          'ApiService.getCommodities: Successfully parsed ${data.length} commodities',
        );
        return data.map((json) => Commodity.fromJson(json)).toList();
      } else {
        print(
          'ApiService.getCommodities: Invalid response format: ${response.body}',
        );
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      print(
        'ApiService.getCommodities: Failed with status ${response.statusCode}: ${response.body}',
      );
      throw Exception('Failed to get commodities: ${response.body}');
    }
  }

  // Get borrowings with filters and pagination
  Future<Map<String, dynamic>> getBorrowings({
    String? status,
    String? search,
    String? jurusan,
    String? classId,
    int? page,
    int? perPage,
  }) async {
    final queryParams = <String, String>{};
    if (status != null) queryParams['status'] = status;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (jurusan != null && jurusan.isNotEmpty) queryParams['jurusan'] = jurusan;
    if (classId != null && classId.isNotEmpty)
      queryParams['class_id'] = classId;
    if (page != null) queryParams['page'] = page.toString();
    if (perPage != null) queryParams['per_page'] = perPage.toString();

    final uri = Uri.parse(
      '$baseUrl/borrowings',
    ).replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        final data = responseJson['data'];
        if (data is List) {
          // Legacy format without pagination
          return {
            'borrowings': data.map((json) => Borrowing.fromJson(json)).toList(),
            'current_page': 1,
            'last_page': 1,
            'total': data.length,
          };
        } else if (data is Map && data['data'] != null) {
          // Paginated format
          final List<dynamic> borrowingsData = data['data'];
          return {
            'borrowings': borrowingsData
                .map((json) => Borrowing.fromJson(json))
                .toList(),
            'current_page': data['current_page'] ?? 1,
            'last_page': data['last_page'] ?? 1,
            'total': data['total'] ?? borrowingsData.length,
          };
        } else {
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
        print(
          'ApiService.getBorrowings: Invalid response format: ${response.body}',
        );
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      print(
        'ApiService.getBorrowings: Failed with status ${response.statusCode}: ${response.body}',
      );
      throw Exception('Failed to get borrowings: ${response.body}');
    }
  }

  // Create borrowing
  Future<Borrowing> createBorrowing(Map<String, dynamic> borrowingData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/borrowings'),
      headers: await _getHeaders(),
      body: jsonEncode(borrowingData),
    );

    if (response.statusCode == 201) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return Borrowing.fromJson(responseJson['data']);
      } else {
        throw Exception('Failed to create borrowing: Invalid response format');
      }
    } else {
      throw Exception('Failed to create borrowing: ${response.body}');
    }
  }

  // Update borrowing status
  Future<Borrowing> updateBorrowingStatus(
    int borrowingId,
    String status,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/borrowings/$borrowingId/status'),
      headers: await _getHeaders(),
      body: jsonEncode({'borrowing_id': borrowingId, 'status': status}),
    );

    if (response.statusCode == 200) {
      return Borrowing.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update borrowing status: ${response.body}');
    }
  }

  // Return borrowing
  Future<Borrowing> returnBorrowing(
    int borrowingId,
    Map<String, dynamic> returnData,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/borrowings/$borrowingId/return'),
      headers: await _getHeaders(),
      body: jsonEncode(returnData),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return Borrowing.fromJson(responseJson['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to return borrowing: ${response.body}');
    }
  }

  // Return borrowing item by sending data (including photo path) as JSON
  Future<Borrowing> returnBorrowingItem(
    int borrowingId,
    int itemId,
    Map<String, dynamic> returnData, // This now contains { 'condition': '...', 'return_photo': 'path/to/photo.jpg' }
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/borrowings/$borrowingId/items/$itemId/return'),
      headers: await _getHeaders(), // Standard JSON headers
      body: jsonEncode(returnData), // Send data as JSON
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return Borrowing.fromJson(responseJson['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      // Log the error response from the server
      print('Failed to return borrowing item. Status: ${response.statusCode}, Body: ${response.body}');
      throw Exception('Failed to return borrowing item: ${response.body}');
    }
  }

  // Approve borrowing items
  Future<Borrowing> approveBorrowingItems(
    int borrowingId,
    List<int> itemIds,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/borrowings/$borrowingId/approve'),
      headers: await _getHeaders(),
      body: jsonEncode({'borrowing_id': borrowingId, 'items': itemIds}),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return Borrowing.fromJson(responseJson['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to approve items: ${response.body}');
    }
  }

  // Reject borrowing items
  Future<Borrowing> rejectBorrowingItems(
    int borrowingId,
    List<int> itemIds,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/borrowings/$borrowingId/reject'),
      headers: await _getHeaders(),
      body: jsonEncode({'borrowing_id': borrowingId, 'items': itemIds}),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return Borrowing.fromJson(responseJson['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to reject items: ${response.body}');
    }
  }

  // Get students
  Future<List<Student>> getStudents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/students'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Student.fromJson(json)).toList();
    } else {
      throw Exception('Failed to get students: ${response.body}');
    }
  }

  // Get school classes
  Future<List<SchoolClass>> getSchoolClasses() async {
    final response = await http.get(
      Uri.parse('$baseUrl/school-classes'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        final List<dynamic> data = responseJson['data'];
        return data.map((json) => SchoolClass.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to get school classes: ${response.body}');
    }
  }

  // Create school class
  Future<SchoolClass> createSchoolClass(Map<String, dynamic> classData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/school-classes'),
      headers: await _getHeaders(),
      body: jsonEncode(classData),
    );

    if (response.statusCode == 201) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return SchoolClass.fromJson(responseJson['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to create school class: ${response.body}');
    }
  }

  // Update school class
  Future<SchoolClass> updateSchoolClass(int classId, Map<String, dynamic> classData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/school-classes/$classId'),
      headers: await _getHeaders(),
      body: jsonEncode(classData),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return SchoolClass.fromJson(responseJson['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to update school class: ${response.body}');
    }
  }

  // Delete school class
  Future<void> deleteSchoolClass(int classId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/school-classes/$classId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete school class: ${response.body}');
    }
  }

  // Get class students
  Future<List<Student>> getClassStudents(int classId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/school-classes/$classId/students'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        final List<dynamic> data = responseJson['data'];
        return data.map((json) => Student.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to get class students: ${response.body}');
    }
  }

  // Move students to another class
  Future<void> moveStudents(int fromClassId, int toClassId, List<int> studentIds) async {
    final response = await http.post(
      Uri.parse('$baseUrl/school-classes/move-students'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'from_class_id': fromClassId,
        'to_class_id': toClassId,
        'student_ids': studentIds,
      }),
    );

    // Parse the response JSON
    final responseJson = jsonDecode(response.body);

    if (response.statusCode == 200 && responseJson['success'] == true) {
      return;
    } else {
      // Handle error cases: either non-200 status or success=false
      if (responseJson['success'] == false && responseJson['message'] != null) {
        throw Exception(responseJson['message']);
      } else {
        throw Exception('Failed to move students: ${response.body}');
      }
    }
  }

  // Delete students from class
  Future<void> deleteStudentsFromClass(int classId) async {
    print('ApiService.deleteStudentsFromClass: Attempting to delete all students from class $classId');
    final response = await http.delete(
      Uri.parse('$baseUrl/school-classes/$classId/students'),
      headers: await _getHeaders(),
    );

    print('ApiService.deleteStudentsFromClass: Response status: ${response.statusCode}');
    print('ApiService.deleteStudentsFromClass: Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete students from class: ${response.body}');
    }
  }

  // Remove individual student from class
  Future<void> removeStudentFromClass(int classId, int studentId) async {
    print('ApiService.removeStudentFromClass: Attempting to remove student $studentId from class $classId');
    final response = await http.delete(
      Uri.parse('$baseUrl/school-classes/$classId/students/$studentId'),
      headers: await _getHeaders(),
    );

    print('ApiService.removeStudentFromClass: Response status: ${response.statusCode}');
    print('ApiService.removeStudentFromClass: Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to remove student from class: ${response.body}');
    }
  }

  // Get users
  Future<List<User>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/users'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        final List<dynamic> data = responseJson['data'];
        return data.map((json) => User.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to get users: ${response.body}');
    }
  }

  // Update user profile by uploading the image file directly.
  Future<User> updateProfile({required Uint8List imageBytes, required String imageFileName}) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/user'));

    final headers = await _getHeaders();
    headers.remove('Content-Type'); // Let the http package set the multipart header
    request.headers.addAll(headers);

    final multipartFile = http.MultipartFile.fromBytes(
      'profile_picture', // This is the field name the backend controller expects
      imageBytes,
      filename: imageFileName,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    print('[ApiService.updateProfile] Sending multipart request to /user');

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    print('[ApiService.updateProfile] Response: ${response.statusCode}, body: $responseData');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(responseData);
      if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
        final updatedUser = User.fromJson(jsonResponse['data']);
        print('[ApiService.updateProfile] Profile updated successfully, new profile_picture: ${updatedUser.profilePicture}');
        return updatedUser;
      } else {
        throw Exception('Failed to update profile: Invalid response format');
      }
    } else {
      throw Exception('Failed to update profile: $responseData');
    }
  }

  // Upload file (for profile picture or return photo)
  Future<String> uploadFile(String filePath, String fieldName) async {
    print(
      '[ApiService.uploadFile] Uploading file from path: $filePath, fieldName: $fieldName',
    );

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));

    // Remove 'Content-Type' header to allow http package to set the correct multipart header.
    final headers = await _getHeaders();
    headers.remove('Content-Type');
    request.headers.addAll(headers);

    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    print(
      '[ApiService.uploadFile] Upload response: ${response.statusCode}, body: $responseData',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(responseData);
      if (data['path'] != null) {
        print('[ApiService.uploadFile] Upload successful, path: ${data['path']}');
        return data['path'];
      } else {
        print('[ApiService.uploadFile] Upload failed: "path" is null in response. Body: $responseData');
        throw Exception('Failed to upload file: "path" is null in response');
      }
    } else {
      print('[ApiService.uploadFile] Upload failed with status ${response.statusCode}. Body: $responseData');
      throw Exception('Failed to upload file: $responseData');
    }
  }

  // Upload bytes (used for web where file paths are not available)
  Future<String> uploadBytes(
    Uint8List bytes,
    String filename,
    String fieldName,
  ) async {
    print(
      '[ApiService.uploadBytes] Uploading bytes: ${bytes.length} bytes, filename: $filename, fieldName: $fieldName',
    );

    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/upload'));

    // Remove 'Content-Type' header to allow http package to set the correct multipart header.
    final headers = await _getHeaders();
    headers.remove('Content-Type');
    request.headers.addAll(headers);

    final multipartFile = http.MultipartFile.fromBytes(
      fieldName,
      bytes,
      filename: filename,
      contentType: MediaType('image', 'jpeg'),
    );
    request.files.add(multipartFile);

    print('[ApiService.uploadBytes] Request headers: ${request.headers}');

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    print(
      '[ApiService.uploadBytes] Upload response: ${response.statusCode}, body: $responseData',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(responseData);
      if (data['path'] != null) {
        print('[ApiService.uploadBytes] Upload successful, path: ${data['path']}');
        return data['path'];
      } else {
        print('[ApiService.uploadBytes] Upload failed: "path" is null in response. Body: $responseData');
        throw Exception('Failed to upload file: "path" is null in response');
      }
    } else {
      print('[ApiService.uploadBytes] Upload failed with status ${response.statusCode}. Body: $responseData');
      throw Exception('Failed to upload file: $responseData');
    }
  }

  // Create commodity
  Future<Commodity> createCommodity(Map<String, dynamic> commodityData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/assets'),
      headers: await _getHeaders(),
      body: jsonEncode(commodityData),
    );

    if (response.statusCode == 201) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return Commodity.fromJson(responseJson['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to create commodity: ${response.body}');
    }
  }

  // Update commodity
  Future<Commodity> updateCommodity(
    int id,
    Map<String, dynamic> commodityData,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/assets/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(commodityData),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return Commodity.fromJson(responseJson['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to update commodity: ${response.body}');
    }
  }

  // Delete commodity
  Future<void> deleteCommodity(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/assets/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete commodity: ${response.body}');
    }
  }

  // Get commodity detail
  Future<Commodity> getCommodityDetail(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/assets/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return Commodity.fromJson(responseJson['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to get commodity detail: ${response.body}');
    }
  }

  // Create user
  Future<User> createUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: await _getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return User.fromJson(responseJson['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to create user: ${response.body}');
    }
  }

  // Update user
  Future<User> updateUser(int id, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return User.fromJson(responseJson['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  // Delete user
  Future<void> deleteUser(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }

  // Approve user
  Future<User> approveUser(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$id/approve'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return User.fromJson(responseJson['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to approve user: ${response.body}');
    }
  }

  // Reject user
  Future<User> rejectUser(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/users/$id/reject'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        return User.fromJson(responseJson['data']);
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to reject user: ${response.body}');
    }
  }

  // Get cart
  Future<List<BorrowingItem>> getCart() async {
    final response = await http.get(
      Uri.parse('$baseUrl/cart'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true && responseJson['data'] != null) {
        final List<dynamic> data = responseJson['data'];
        return data.map((json) => BorrowingItem.fromJson(json)).toList();
      } else {
        throw Exception('Invalid response format: ${response.body}');
      }
    } else {
      throw Exception('Failed to get cart: ${response.body}');
    }
  }

  // Save cart
  Future<void> saveCart(List<Map<String, dynamic>> items) async {
    print(
      'ApiService.saveCart: Attempting to save cart with ${items.length} items',
    );
    final response = await http.post(
      Uri.parse('$baseUrl/cart'),
      headers: await _getHeaders(),
      body: jsonEncode({'items': items}),
    );

    print('ApiService.saveCart: Response status: ${response.statusCode}');
    print('ApiService.saveCart: Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true) {
        print('ApiService.saveCart: Cart saved successfully');
      } else {
        print(
          'ApiService.saveCart: Server returned success=false: ${responseJson['message']}',
        );
        throw Exception('Failed to save cart: ${response.body}');
      }
    } else {
      print(
        'ApiService.saveCart: HTTP error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Failed to save cart: ${response.body}');
    }
  }

  // Update cart item (add/update quantity)
  Future<void> updateCartItem(int commodityId, int quantity) async {
    print(
      'ApiService.updateCartItem: Updating cart item commodity_id: $commodityId, quantity: $quantity',
    );

    try {
      // Fetch current cart items from server
      final currentCart = await getCart();

      // Map to simple items list
      final items = currentCart
          .map(
            (ci) => {'commodity_id': ci.commodityId, 'quantity': ci.quantity},
          )
          .toList();

      // Check if item exists
      final index = items.indexWhere((it) => it['commodity_id'] == commodityId);

      if (quantity <= 0) {
        // Remove item if present
        if (index != -1) {
          items.removeAt(index);
        } else {
          // nothing to remove
          print(
            'ApiService.updateCartItem: Item $commodityId not present in cart, nothing to remove',
          );
        }
      } else {
        if (index != -1) {
          // Update existing
          items[index]['quantity'] = quantity;
        } else {
          // Add new item
          items.add({'commodity_id': commodityId, 'quantity': quantity});
        }
      }

      // Call saveCart endpoint with full items array
      print('ApiService.updateCartItem: Calling saveCart with items: $items');
      await saveCart(List<Map<String, dynamic>>.from(items));
      print('ApiService.updateCartItem: Completed saveCart call successfully');
    } catch (e, st) {
      print('ApiService.updateCartItem: Exception occurred: $e');
      print('ApiService.updateCartItem: Stack trace: $st');
      rethrow;
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    print('ApiService.clearCart: Clearing cart');
    final response = await http.delete(
      Uri.parse('$baseUrl/cart'),
      headers: await _getHeaders(),
    );

    print('ApiService.clearCart: Response status: ${response.statusCode}');
    print('ApiService.clearCart: Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true) {
        print('ApiService.clearCart: Cart cleared successfully');
      } else {
        print(
          'ApiService.clearCart: Server returned success=false: ${responseJson['message']}',
        );
        throw Exception('Failed to clear cart: ${responseJson['message']}');
      }
    } else {
      print(
        'ApiService.clearCart: HTTP error ${response.statusCode}: ${response.body}',
      );
      throw Exception('Failed to clear cart: ${response.body}');
    }
  }

  // Submit bug report
  Future<void> submitBugReport(Map<String, dynamic> bugData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/bug-reports'),
      headers: await _getHeaders(),
      body: jsonEncode(bugData),
    );

    if (response.statusCode == 201) {
      final responseJson = jsonDecode(response.body);
      if (responseJson['success'] == true) {
        print('Bug report submitted successfully');
      } else {
        throw Exception('Failed to submit bug report: ${responseJson['message']}');
      }
    } else {
      throw Exception('Failed to submit bug report: ${response.body}');
    }
  }

  // Update User
  Future<void> updateUser(int userId, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/$userId'),
      headers: await _getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  // Delete User
  Future<void> deleteUser(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  }
}
