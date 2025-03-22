import 'dart:convert';
import 'dart:developer';

import 'package:asr_project/config.dart';
import 'package:http/http.dart' as http;

class AuthService {
  final String baseUrl = "${AppConfig.baseUrl}/auth";
  Future<Map<String, String>> _getHeaders() async {
    String? token = await AppConfig.getToken();

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept-Charset': 'utf-8',
    };
  }

  Future<String?> login(String email, String password) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept-Charset': 'utf-8',
      };
      log(email);
      log(password);
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await AppConfig.setToken(data['token']);
        String? userId = await me();
        if (userId != null) {
          await AppConfig.setUserId(userId);
        }
        return userId;
      }
      throw Exception("Failed to login: ${response.statusCode}");
    } catch (e) {
      log("Error during login: $e");
      return null;
    }
  }

  Future<String?> signUp(String name, String email, String password) async {
    try {
      log(name);
      log(email);
      log(password);
      final headers = {
        'Content-Type': 'application/json',
        'Accept-Charset': 'utf-8',
      };
      final response = await http.post(
        Uri.parse("$baseUrl/signup"),
        headers: headers,
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        return "success";
      }
      throw Exception("Failed to sign up: ${response.statusCode}");
    } catch (e) {
      log("Error during sign up: $e");
      return null;
    }
  }

  Future<String?> me() async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.get(Uri.parse("$baseUrl/me"), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'];
      }
      throw Exception("Failed to fetch user: ${response.statusCode}");
    } catch (e) {
      log("Error fetching user: $e");
      return null;
    }
  }
}
