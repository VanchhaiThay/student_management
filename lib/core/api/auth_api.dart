import 'dart:convert';
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
}
