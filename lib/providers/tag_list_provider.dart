import 'dart:convert';
import 'dart:developer';
import 'package:asr_project/config.dart';
import 'package:asr_project/models/tag.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final tagListProvider = StateNotifierProvider<TagListNotifier, List<Tag>>(
  (ref) => TagListNotifier(),
);

class TagListNotifier extends StateNotifier<List<Tag>> {
  TagListNotifier() : super([]) {
    fetchTags();
  }

  Future<void> fetchTags() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/tags"),
        headers: {
          'Authorization': AppConfig.basicAuth,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<Tag> tags =
            jsonData.map((data) => Tag.fromMap(data)).toList();
        state.clear();
        state.addAll(tags);
      } else {
        log("Error fetching tags: ${response.statusCode}");
      }
    } catch (e) {
      log("Exception occurred while fetching tags: $e");
    }
  }

  Future<Tag?> addTag(TagDetail tagDetail) async {
    try {
      final http.Response response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/tags"),
        headers: {
          'Authorization': AppConfig.basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(tagDetail.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final Tag tag = Tag.fromMap(jsonData);

        fetchTags(); // Fetch updated tags after adding

        return tag;
      } else {
        log("Error adding tag: ${response.body}");
      }
    } catch (e) {
      log("Exception occurred while adding tag: $e");
    }
    return null;
  }

  Future<Tag?> updateTag(String id, TagDetail tagDetail) async {
    try {
      final http.Response response = await http.patch(
        Uri.parse("${AppConfig.baseUrl}/tags/$id"),
        headers: {
          'Authorization': AppConfig.basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(tagDetail.toJson()),
      );

      if (response.statusCode == 200) {
        fetchTags();
        return getTagById(id);
      } else {
        log("Error updating tag: ${response.body}");
      }
    } catch (e) {
      log("Exception occurred while updating tag: $e");
    }
    return null;
  }

  Future<void> removeTag(String id) async {
    try {
      final http.Response response = await http.delete(
        Uri.parse("${AppConfig.baseUrl}/tags/$id"),
        headers: {
          'Authorization': AppConfig.basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        fetchTags(); // Fetch updated tags after removal
      } else {
        log("Error removing tag: ${response.body}");
      }
    } catch (e) {
      log("Exception occurred while removing tag: $e");
    }
  }

  Tag getTagById(String id) {
    try {
      final tag = state.firstWhere(
        (tag) => tag.id == id,
        orElse: () => throw Exception('Tag not found'),
      );
      return tag;
    } catch (e) {
      rethrow;
    }
  }
}
