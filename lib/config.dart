import 'dart:developer';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// import 'package:shared_preferences/shared_preferences.dart';
final FlutterSecureStorage _storage = FlutterSecureStorage();

class AppConfig {
  static const String baseUrl = "http://192.168.1.35:8080";
  // static const String baseUrl = "http://localhost:8080";

  static String? userId = "";
  static String? token = "";

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

  static Future<void> removeToken() async {
    await _storage.delete(key: "token");
  }

  // Get token securely
  static Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }

  static Future<bool> isAuthenticated() async {
    final token = await getToken();

    if (token == null) return false;

    try {
      final jwt = JWT.decode(token);
      final exp = jwt.payload['exp'];

      if (exp == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp > now;
    } catch (e) {
      return false;
    }
  }
}
