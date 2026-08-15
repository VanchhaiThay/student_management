import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/auth_api.dart';

class AuthState {
  final bool isLoading;
  final String? token;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.token,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? token,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final authApiProvider = Provider<AuthApi>((ref) => AuthApi());

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _loadToken();
    return AuthState();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    if (token != null) {
      state = state.copyWith(token: token);
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authApi = ref.read(authApiProvider);
      final response = await authApi.signIn(email, password);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        
        if (token != null) {
          await _saveToken(token);
          state = state.copyWith(isLoading: false, token: token);
          return true;
        } else {
          state = state.copyWith(isLoading: false, error: 'Token is missing from response.');
          return false;
        }
      } else {
        state = state.copyWith(isLoading: false, error: 'Invalid email or password.');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Network error: ');
      return false;
    }
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String teacherId,
    required String department,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authApi = ref.read(authApiProvider);
      final response = await authApi.signUp(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        teacherId: teacherId,
        department: department,
        password: password,
      );

      if (response.statusCode == 200) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.body);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Network error: ');
      return false;
    }
  }

  Future<void> logout() async {
    await _clearToken();
    state = state.copyWith(token: null);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
