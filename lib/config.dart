import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// import 'package:shared_preferences/shared_preferences.dart';
final FlutterSecureStorage _storage = FlutterSecureStorage();

class AppConfig {
  static const String baseUrl = "http://192.168.1.37:8080";
  // static const String baseUrl = "http://localhost:8080";

  static const String username = "admin";
  static const String password = "password";

  static final String basicAuth =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  static String? userId;
  static String? token;

  // Set user ID securely
  static Future<void> setUserId(String newUserId) async {
    await _storage.write(key: "userId", value: newUserId);
    userId = newUserId;
  }

  // Get user ID securely
  static Future<String?> getUserId() async {
    return await _storage.read(key: "userId");
  }

  // Set token securely
  static Future<void> setToken(String newToken) async {
    await _storage.write(key: "token", value: newToken);
    token = newToken;
  }

  // Get token securely
  static Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }
}
