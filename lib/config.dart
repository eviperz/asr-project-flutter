import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

// import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  // static const String baseUrl = "http://192.168.1.37:8080";
  static const String baseUrl = "http://localhost:8080";

  static const String username = "admin";
  static const String password = "password";

  static final String basicAuth =
      'Basic ${base64Encode(utf8.encode('$username:$password'))}';

  static String? userId;

  static Future<void> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getString("userId");
  }

  static Future<void> setUserId(String newUserId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", newUserId);
    userId = newUserId;
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("userId");
  }
}
