import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthApi {
  static final AuthApi _instance = AuthApi._internal();
  factory AuthApi() => _instance;
  AuthApi._internal();

  String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';

  Future<http.Response> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String teacherId,
    required String department,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'teacherId': teacherId,
        'department': department,
        'password': password,
      }),
    );
    return response;
  }

  Future<http.Response> signIn(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return response;
  }

  Future<Map<String, dynamic>?> fetchUserProfile({
    required String token,
    String? email,
  }) async {
    final authHeaders = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final noAuthHeaders = {
      'Content-Type': 'application/json',
    };

    final List<String> endpointsToTry = [
      if (email != null && email.isNotEmpty) ...[
        '$baseUrl/users/email/$email',
        '$baseUrl/users/$email',
        '$baseUrl/users/search/findByEmail?email=$email',
        '$baseUrl/users?email=$email',
        '$baseUrl/users/by-email?email=$email',
        '$baseUrl/teachers/email/$email',
        '$baseUrl/teachers/$email',
      ],
      '$baseUrl/users/me',
      '$baseUrl/users/profile',
      '$baseUrl/users/current',
      '$baseUrl/users',
      '$baseUrl/teachers',
    ];

    for (final url in endpointsToTry) {
      // Try with Bearer token
      try {
        debugPrint('[AuthApi] Attempting GET $url with token');
        final res = await http.get(Uri.parse(url), headers: authHeaders).timeout(const Duration(seconds: 3));
        debugPrint('[AuthApi] Response from $url (with token): status=${res.statusCode}, body=${res.body}');
        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          final match = _extractMatchingUser(decoded, email);
          if (match != null) {
            debugPrint('[AuthApi] Found matching user profile: $match');
            return match;
          }
        }
      } catch (e) {
        debugPrint('[AuthApi] Error requesting $url (with token): $e');
      }

      // Try without Bearer token
      try {
        final res = await http.get(Uri.parse(url), headers: noAuthHeaders).timeout(const Duration(seconds: 3));
        debugPrint('[AuthApi] Response from $url (no auth): status=${res.statusCode}, body=${res.body}');
        if (res.statusCode == 200) {
          final decoded = jsonDecode(res.body);
          final match = _extractMatchingUser(decoded, email);
          if (match != null) {
            debugPrint('[AuthApi] Found matching user profile (no auth): $match');
            return match;
          }
        }
      } catch (e) {
        debugPrint('[AuthApi] Error requesting $url (no auth): $e');
      }
    }

    return null;
  }

  Map<String, dynamic>? _extractMatchingUser(dynamic decoded, String? email) {
    if (decoded is Map<String, dynamic>) {
      // Check if wrapped inside _embedded (Spring Data REST)
      if (decoded['_embedded'] is Map<String, dynamic>) {
        final embedded = decoded['_embedded'] as Map<String, dynamic>;
        for (final val in embedded.values) {
          if (val is List) {
            final match = _findInList(val, email);
            if (match != null) return match;
          }
        }
      }
      if (decoded['user'] is Map<String, dynamic>) {
        return decoded['user'] as Map<String, dynamic>;
      }
      if (decoded['data'] is Map<String, dynamic>) {
        return decoded['data'] as Map<String, dynamic>;
      }
      // If it has user-like properties
      if (decoded.containsKey('email') ||
          decoded.containsKey('fullName') ||
          decoded.containsKey('full_name') ||
          decoded.containsKey('teacherId') ||
          decoded.containsKey('teacher_id') ||
          decoded.containsKey('phoneNumber') ||
          decoded.containsKey('phone_number')) {
        if (email == null || email.isEmpty || decoded['email'] == email) {
          return decoded;
        }
      }
    } else if (decoded is List) {
      return _findInList(decoded, email);
    }
    return null;
  }

  Map<String, dynamic>? _findInList(List list, String? email) {
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        if (email != null && email.isNotEmpty) {
          if (item['email']?.toString().toLowerCase() == email.toLowerCase()) {
            return item;
          }
        } else {
          return item;
        }
      }
    }
    return null;
  }
}
