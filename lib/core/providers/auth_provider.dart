import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/auth_api.dart';
import '../models/user_model.dart';

class AuthState {
  final bool isLoading;
  final String? token;
  final UserModel? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.token,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    String? token,
    UserModel? user,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      token: token ?? this.token,
      user: clearUser ? null : (user ?? this.user),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final authApiProvider = Provider<AuthApi>((ref) => AuthApi());

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _loadTokenAndUser();
    return AuthState();
  }

  Map<String, dynamic>? _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64Url.normalize(parts[1]);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payload = jsonDecode(resp);
      if (payload is Map<String, dynamic>) {
        return payload;
      }
    } catch (_) {}
    return null;
  }

  UserModel _extractUser(dynamic data, String? token, String fallbackEmail) {
    Map<String, dynamic> userMap = {};

    // 1. If JWT payload exists, extract claims from it first
    if (token != null) {
      final jwtClaims = _decodeJwt(token);
      if (jwtClaims != null) {
        userMap.addAll(jwtClaims);
      }
    }

    // 2. If response data is a Map, merge top-level or nested user
    if (data is Map<String, dynamic>) {
      if (data['user'] is Map<String, dynamic>) {
        userMap.addAll(data['user'] as Map<String, dynamic>);
      } else if (data['teacher'] is Map<String, dynamic>) {
        userMap.addAll(data['teacher'] as Map<String, dynamic>);
      } else if (data['data'] is Map<String, dynamic>) {
        userMap.addAll(data['data'] as Map<String, dynamic>);
      }
      for (final key in [
        'id',
        'userId',
        '_id',
        'fullName',
        'full_name',
        'name',
        'displayName',
        'username',
        'email',
        'phoneNumber',
        'phone_number',
        'phone',
        'teacherId',
        'teacher_id',
        'department',
        'dept',
        'role',
      ]) {
        if (data[key] != null) {
          userMap[key] = data[key];
        }
      }
    }

    // 3. Fallback email if still missing
    if ((userMap['email'] == null || userMap['email'].toString().isEmpty) &&
        fallbackEmail.isNotEmpty) {
      userMap['email'] = fallbackEmail;
    }

    return UserModel.fromJson(userMap);
  }

  Future<void> _loadTokenAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');
    final userDataStr = prefs.getString('user_data');

    UserModel? user;
    if (userDataStr != null && userDataStr.isNotEmpty) {
      try {
        final userJson = jsonDecode(userDataStr);
        if (userJson is Map<String, dynamic>) {
          user = UserModel.fromJson(userJson);
        }
      } catch (_) {}
    }

    // Fallback: If no user_data saved but token exists, extract user from JWT claims
    if (user == null && token != null) {
      user = _extractUser(null, token, '');
    }

    if (token != null) {
      // Also check local cache for this email if fields are missing
      if (user != null && (user.phoneNumber == null || user.teacherId == null)) {
        final cached = prefs.getString('user_profile_${user.email?.toLowerCase()}');
        if (cached != null) {
          try {
            final cachedJson = jsonDecode(cached);
            if (cachedJson is Map<String, dynamic>) {
              final cachedUser = UserModel.fromJson(cachedJson);
              user = user.copyWith(
                fullName: user.fullName ?? cachedUser.fullName,
                phoneNumber: user.phoneNumber ?? cachedUser.phoneNumber,
                teacherId: user.teacherId ?? cachedUser.teacherId,
                department: user.department ?? cachedUser.department,
              );
            }
          } catch (_) {}
        }
      }

      state = state.copyWith(token: token, user: user);
      // Fetch latest profile from backend in background
      _fetchProfile(token, email: user?.email);
    }
  }

  Future<void> _saveTokenAndUser(String token, UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    if (user.email != null && user.email!.isNotEmpty) {
      await prefs.setString(
        'user_profile_${user.email!.toLowerCase()}',
        jsonEncode(user.toJson()),
      );
    }
  }

  Future<void> _clearTokenAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_data');
  }

  Future<void> _fetchProfile(String token, {String? email}) async {
    try {
      final authApi = ref.read(authApiProvider);
      final userEmail = email ?? state.user?.email ?? '';
      final profileData = await authApi.fetchUserProfile(token: token, email: userEmail);
      if (profileData != null) {
        final updatedUser = _extractUser(profileData, token, userEmail);
        state = state.copyWith(user: updatedUser);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(updatedUser.toJson()));
        if (userEmail.isNotEmpty) {
          await prefs.setString('user_profile_${userEmail.toLowerCase()}', jsonEncode(updatedUser.toJson()));
        }
      }
    } catch (_) {}
  }

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final authApi = ref.read(authApiProvider);
      final response = await authApi.signIn(email, password);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] ?? data['jwt'] ?? data['accessToken'];

        if (token != null) {
          var user = _extractUser(data, token.toString(), email);

          // Check if there is a cached profile for this email in SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final cachedProfileStr = prefs.getString('user_profile_${email.toLowerCase()}');
          if (cachedProfileStr != null) {
            try {
              final cachedJson = jsonDecode(cachedProfileStr);
              if (cachedJson is Map<String, dynamic>) {
                final cachedUser = UserModel.fromJson(cachedJson);
                user = user.copyWith(
                  fullName: (user.fullName != null && user.fullName!.isNotEmpty) ? user.fullName : cachedUser.fullName,
                  phoneNumber: (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) ? user.phoneNumber : cachedUser.phoneNumber,
                  teacherId: (user.teacherId != null && user.teacherId!.isNotEmpty) ? user.teacherId : cachedUser.teacherId,
                  department: (user.department != null && user.department!.isNotEmpty) ? user.department : cachedUser.department,
                );
              }
            } catch (_) {}
          }

          state = state.copyWith(isLoading: false, token: token.toString(), user: user);
          await _saveTokenAndUser(token.toString(), user);

          // Fetch full user profile details from backend
          await _fetchProfile(token.toString(), email: email);

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
      state = state.copyWith(isLoading: false, error: 'Network error: $e');
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
        // Cache user details locally
        final prefs = await SharedPreferences.getInstance();
        final newUser = UserModel(
          fullName: fullName,
          email: email,
          phoneNumber: phoneNumber,
          teacherId: teacherId,
          department: department,
        );
        await prefs.setString(
          'user_profile_${email.toLowerCase()}',
          jsonEncode(newUser.toJson()),
        );

        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.body);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Network error: $e');
      return false;
    }
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    state = state.copyWith(user: updatedUser);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', jsonEncode(updatedUser.toJson()));
    if (updatedUser.email != null && updatedUser.email!.isNotEmpty) {
      await prefs.setString(
        'user_profile_${updatedUser.email!.toLowerCase()}',
        jsonEncode(updatedUser.toJson()),
      );
    }
  }

  Future<void> refreshProfile() async {
    if (state.token != null) {
      await _fetchProfile(state.token!, email: state.user?.email);
    }
  }

  Future<void> logout() async {
    await _clearTokenAndUser();
    state = AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
