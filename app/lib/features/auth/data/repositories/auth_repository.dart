import 'dart:io';

import 'package:dio/dio.dart';

import '../../../../core/services/api_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _api;

  AuthRepository(this._api);

  Future<({UserModel user, String token})> login(
      String email, String password) async {
    final response = await _api.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    final user = UserModel.fromJson(response.data['user']);
    final token = response.data['token'] as String;

    await _api.setToken(token);

    return (user: user, token: token);
  }

  Future<({UserModel user, String token})> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String locale = 'es',
  }) async {
    final response = await _api.post('/auth/register', data: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'phone': phone,
      'locale': locale,
    });

    final user = UserModel.fromJson(response.data['user']);
    final token = response.data['token'] as String;

    await _api.setToken(token);

    return (user: user, token: token);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {
      // Ignore errors on logout
    } finally {
      await _api.clearToken();
    }
  }

  Future<UserModel> getMe() async {
    final response = await _api.get('/auth/me');
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> updateProfile({
    String? name,
    String? phone,
    String? locale,
    String? themePreference,
  }) async {
    final response = await _api.put('/profile', data: {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (locale != null) 'locale': locale,
      if (themePreference != null) 'theme_preference': themePreference,
    });
    return UserModel.fromJson(response.data);
  }

  Future<void> updateFcmToken(String fcmToken) async {
    await _api.put('/profile/fcm-token', data: {
      'fcm_token': fcmToken,
    });
  }

  Future<bool> isAuthenticated() async {
    return await _api.hasToken();
  }

  Future<({UserModel user, String token})> googleLogin({
    String? idToken,
    String? accessToken,
  }) async {
    if (idToken == null && accessToken == null) {
      throw ArgumentError(
          'At least one of idToken or accessToken must be provided');
    }

    final response = await _api.post('/auth/google', data: {
      if (idToken != null) 'id_token': idToken,
      if (accessToken != null) 'access_token': accessToken,
    });

    final user = UserModel.fromJson(response.data['user']);
    final token = response.data['token'] as String;

    await _api.setToken(token);

    return (user: user, token: token);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _api.put('/profile/password', data: {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPasswordConfirmation,
    });
  }

  Future<UserModel> uploadAvatar(File imageFile) async {
    final fileName = imageFile.path.split('/').last;
    final formData = FormData.fromMap({
      'avatar': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });
    final response =
        await _api.postMultipart('/profile/avatar', data: formData);
    return UserModel.fromJson(response.data);
  }

  Future<UserModel> selectUserType(String userType) async {
    final response = await _api.post('/auth/select-user-type', data: {
      'user_type': userType,
    });
    return UserModel.fromJson(response.data);
  }
}
