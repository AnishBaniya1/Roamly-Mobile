import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:roamly_app/core/services/secure_storage.dart';

class ApiService {
  // Singleton pattern
  ApiService._();
  static final ApiService instance = ApiService._();

  //securestoragservice
  final SecureStorageService _storage = SecureStorageService();

  //HTTP GET Request
  Future<dynamic> httpGet({
    required String url,
    required bool isWithoutToken,
  }) async {
    try {
      final headers = await _buildHeaders(isWithoutToken: isWithoutToken);
      final response = await http.get(Uri.parse(url), headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Get Request Failed: $e');
    }
  }

  //HTTP POST Request
  Future<dynamic> httpPost({
    required String url,
    required String body,
    required bool isWithoutToken,
  }) async {
    try {
      final headers = await _buildHeaders(isWithoutToken: isWithoutToken);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST request failed: $e');
    }
  }

  //HTTP POST with Multipart (for file uploads)
  Future<dynamic> httpPostMultipart({
    required String url,
    required Map<String, String> fields,
    required List<String> filePaths,
    required String fileFieldName,
    required bool isWithoutToken,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add authorization header
      if (!isWithoutToken) {
        final token = await _storage.readValue('authtoken');
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      }
      // Add text fields
      fields.forEach((key, value) {
        request.fields[key] = value;
      });

      // Add files
      for (var path in filePaths) {
        request.files.add(
          await http.MultipartFile.fromPath(fileFieldName, path),
        );
      }

      // Send request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Multipart POST request failed: $e');
    }
  }

  //HTTP PUT Request
  Future<dynamic> httpPut({
    required String url,
    required String body,
    required bool isWithoutToken,
  }) async {
    try {
      final headers = await _buildHeaders(isWithoutToken: isWithoutToken);

      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT request failed: $e');
    }
  }

  //HTTP DELETE Request
  Future<dynamic> httpDelete({
    required String url,
    required bool isWithoutToken,
  }) async {
    try {
      final headers = await _buildHeaders(isWithoutToken: isWithoutToken);

      final response = await http.delete(Uri.parse(url), headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE request failed: $e');
    }
  }

  //HTTP PATCH Request
  Future<dynamic> httpPatch({
    required String url,
    required String body,
    required bool isWithoutToken,
  }) async {
    try {
      final headers = await _buildHeaders(isWithoutToken: isWithoutToken);

      final response = await http.patch(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('PATCH request failed: $e');
    }
  }

  // ============================================
  // Private Helper Methods
  // ============================================

  //Request Headers
  Future<Map<String, String>> _buildHeaders({
    required bool isWithoutToken,
  }) async {
    final headers = {"Content-Type": "application/json"};
    if (!isWithoutToken) {
      final token = await _storage.readValue('authtoken');
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  //Handle HTTP Response
  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw Exception('Bad request: ${response.body}');
      case 401:
        throw Exception('Unauthorized: ${response.body}');
      case 403:
        throw Exception('Forbidden: ${response.body}');
      case 404:
        throw Exception('Not found: ${response.body}');
      case 500:
        throw Exception('Server error: ${response.body}');
      default:
        throw Exception('Request failed with status: ${response.statusCode}');
    }
  }
}
