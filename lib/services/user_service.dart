import 'dart:convert';
import 'dart:developer';
import 'dart:io';
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

  Future<User?> updateUser({
    String? name,
    File? image,
  }) async {
    try {
      final userId = AppConfig.userId;
      final headers = await _getHeaders();

      var request = http.MultipartRequest("PUT", Uri.parse("$baseUrl/$userId"))
        ..headers.addAll(headers);

      if (name != null && name.isNotEmpty) {
        request.fields["name"] = name;
      }

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            "profileImgPath",
            image.path,
            filename: image.path.split('/').last,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        log(response.body);
        return User.fromJson(jsonDecode(response.body));
      }

      throw Exception("Failed to update User: ${response.statusCode}");
    } catch (e) {
      log("Error updating user: $e");
      return null;
    }
  }
}
