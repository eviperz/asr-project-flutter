import 'dart:convert';
import 'dart:developer';
import 'package:asr_project/config.dart';
import 'package:asr_project/models/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = "${AppConfig.baseUrl}/users";
  // final String? userId = AppConfig.userId;
  Future<Map<String, String>> _getHeaders() async {
    // final String? token = await AppConfig.getToken();
    return {
      // 'Authorization': token != null ? 'Bearer $token' : AppConfig.basicAuth,
      'Authorization': AppConfig.basicAuth,
      'Content-Type': 'application/json',
      'Accept-Charset': 'utf-8',
    };
  }

  Future<User?> getUserById(String userId) async {
    try {
      // final String? userId = await AppConfig.getUserId();
      if (userId == null) {
        throw Exception("User ID not found. Please log in.");
      }

      final headers = await _getHeaders();
      final response =
          await http.get(Uri.parse("$baseUrl/$userId"), headers: headers);

      if (response.statusCode == 200) {
        return User.fromJson(jsonDecode(response.body));
      }
      throw Exception("Failed to fetch user: ${response.statusCode}");
    } catch (e) {
      log("Error fetching user: $e");
      return null;
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: headers,
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // final data = jsonDecode(response.body);
        // log(response.body);
        final String userId = response.body;

        await AppConfig.setUserId(userId);
        return response.body;
      }
      throw Exception("Failed to login: ${response.statusCode}");
    } catch (e) {
      log("Error during login: $e");
      return null;
    }
  }
}
