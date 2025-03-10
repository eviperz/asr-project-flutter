import 'dart:convert';
import 'dart:developer';

import 'package:asr_project/config.dart';
import 'package:asr_project/models/user.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String id = AppConfig.userId;
  final String baseUrl = "${AppConfig.baseUrl}/users";
  final Map<String, String> headers = {
    'Authorization': AppConfig.basicAuth,
    'Content-Type': 'application/json',
  };

  Future<User?> getUserById() async {
    log("$baseUrl/$id");
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/$id"), headers: headers);

      if (response.statusCode == 200) {
        return User.fromMap(jsonDecode(response.body));
      }
      throw Exception("Fail to fetch user: ${response.statusCode}");
    } catch (e) {
      log("Error fetching user: $e");
      return null;
    }
  }
}
