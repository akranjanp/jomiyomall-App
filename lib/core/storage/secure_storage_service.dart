import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _tokenKey = 'jwt_auth_token';
  static const _userDataKey = 'user_profile_json';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _tokenKey).timeout(const Duration(seconds: 3));
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUserData(String json) async {
    try {
      await _storage.write(key: _userDataKey, value: json).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<String?> getUserData() async {
    try {
      return await _storage.read(key: _userDataKey).timeout(const Duration(seconds: 3));
    } catch (_) {
      return null;
    }
  }

  Future<void> clearAuth() async {
    try {
      await _storage.delete(key: _tokenKey).timeout(const Duration(seconds: 3));
      await _storage.delete(key: _userDataKey).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }
}
