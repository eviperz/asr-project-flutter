import 'dart:convert';
import 'dart:developer';
import 'package:asr_project/config.dart';
import 'package:asr_project/models/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl = "${AppConfig.baseUrl}/users";

  Future<Map<String, String>> _getHeaders() async {
    String? token = await AppConfig.getToken();

    return {
      'Authorization': 'Bearer $token',
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
}
