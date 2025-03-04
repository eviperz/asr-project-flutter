import 'dart:convert';
import 'dart:developer';
import 'package:asr_project/config.dart';
import 'package:asr_project/models/tag.dart';
import 'package:http/http.dart' as http;

class TagService {
  final String baseUrl = "${AppConfig.baseUrl}/tags";
  final Map<String, String> headers = {
    'Authorization': AppConfig.basicAuth,
    'Content-Type': 'application/json',
  };

  Future<List<Tag>> getAllTagsByOwnerId(String ownerId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/owner/$ownerId"),
          headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => Tag.fromMap(data)).toList();
      }
      throw Exception("Fail to fetch tags: ${response.statusCode}");
    } catch (e) {
      log("Error fetching tags: $e");
      return [];
    }
  }

  Future<Tag?> addTag(TagDetail tagDetail) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(tagDetail.toJson()),
      );

      if (response.statusCode == 200) {
        return Tag.fromMap(jsonDecode(response.body));
      }
      throw Exception("Fail to create tag: ${response.statusCode}");
    } catch (e) {
      log("Error adding tag: $e");
      return null;
    }
  }

  Future<Tag?> updateTag(String id, TagDetail tagDetail) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/$id"),
        headers: headers,
        body: jsonEncode(tagDetail.toJson()),
      );

      if (response.statusCode == 200) {
        return Tag.fromMap(jsonDecode(response.body));
      }
      throw Exception("Fail to update tag: ${response.statusCode}");
    } catch (e) {
      log("Error updating tag: $e");
      return null;
    }
  }

  Future<bool> deleteTag(String id) async {
    try {
      final response =
          await http.delete(Uri.parse("$baseUrl/$id"), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      log("Error deleting tag: $e");
      return false;
    }
  }
}
