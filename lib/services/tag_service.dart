import 'dart:convert';
import 'dart:developer';
import 'package:asr_project/config.dart';
import 'package:asr_project/models/tag.dart';
import 'package:http/http.dart' as http;

class TagService {
  String? _userId;
  final String baseUrl = "${AppConfig.baseUrl}/tags";
  Future<Map<String, String>> _getHeaders() async {
    String? token = await AppConfig.getToken();

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept-Charset': 'utf-8',
    };
  }

  TagService() {
    _initializeUserId();
  }
  Future<void> _initializeUserId() async {
    _userId = await AppConfig.getUserId();
    log("User ID Loaded TagService: $_userId");
  }

  Future<List<Tag>> getAllPersonalTags() async {
    try {
      final headers = await _getHeaders();
      final String? userId = await AppConfig.getUserId();
      final response = await http.get(
        Uri.parse("$baseUrl/personal/$userId"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => Tag.fromJson(data)).toList();
      }
      throw Exception("Fail to fetch tags: ${response.statusCode}");
    } catch (e) {
      log("Error fetching tags: $e");
      return [];
    }
  }

  Future<List<Tag>> getAllWorkspaceTags(String workspaceId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse("$baseUrl/workspace/$workspaceId"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => Tag.fromJson(data)).toList();
      }
      throw Exception("Fail to fetch tags: ${response.statusCode}");
    } catch (e) {
      log("Error fetching tags: $e");
      return [];
    }
  }

  Future<Tag?> createPersonalTag(TagDetail tagDetail) async {
    try {
      final headers = await _getHeaders();
      final String? userId = await AppConfig.getUserId();

      final response = await http.post(
        Uri.parse("$baseUrl/personal/$userId"),
        headers: headers,
        body: jsonEncode(tagDetail.toJson()),
      );

      if (response.statusCode == 200) {
        return Tag.fromJson(jsonDecode(response.body));
      }
      throw Exception("Fail to create tag: ${response.statusCode}");
    } catch (e) {
      log("Error adding tag: $e");
      return null;
    }
  }

  Future<Tag?> createWorkspaceTag(
      String workspaceId, TagDetail tagDetail) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse("$baseUrl/workspace/$workspaceId"),
        headers: headers,
        body: jsonEncode(tagDetail.toJson()),
      );

      if (response.statusCode == 200) {
        return Tag.fromJson(jsonDecode(response.body));
      }
      throw Exception("Fail to create tag: ${response.statusCode}");
    } catch (e) {
      log("Error adding tag: $e");
      return null;
    }
  }

  Future<Tag?> updateTag(String id, TagDetail tagDetail) async {
    try {
      final headers = await _getHeaders();

      final response = await http.patch(
        Uri.parse("$baseUrl/$id"),
        headers: headers,
        body: jsonEncode(tagDetail.toJson()),
      );

      if (response.statusCode == 200) {
        return Tag.fromJson(jsonDecode(response.body));
      }

      throw Exception("Fail to update tag: ${response.statusCode}");
    } catch (e) {
      log("Error updating tag: $e");
      return null;
    }
  }

  Future<bool> deleteTag(String id) async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.delete(Uri.parse("$baseUrl/$id"), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      log("Error deleting tag: $e");
      return false;
    }
  }
}
