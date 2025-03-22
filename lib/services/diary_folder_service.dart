import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:asr_project/config.dart';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:http/http.dart' as http;

class DiaryFolderService {
  String? _userId;
  final String baseUrl = "${AppConfig.baseUrl}/folders";
  Future<Map<String, String>> _getHeaders() async {
    String? token = await AppConfig.getToken();

    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept-Charset': 'utf-8',
    };
  }

  DiaryFolderService() {
    _initializeUserId();
  }
  Future<void> _initializeUserId() async {
    _userId = await AppConfig.getUserId();
    log("User ID Loaded DiaryFolderService: $_userId");
  }

  Future<List<DiaryFolderModel>> getAllPersonalDiaryFoldersWithDiaries() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse("$baseUrl/personal/$_userId"),
          headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => DiaryFolderModel.fromJson(data)).toList();
      }
      throw Exception("Fail to fetch diary folders: ${response.statusCode}");
    } catch (e) {
      log("Error fetching diary folders: $e");
      return [];
    }
  }

  Future<DiaryFolderModel?> createPersonalDiaryFolder(
      DiaryFolderDetail diaryFolderDetail) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(Uri.parse("$baseUrl/personal/$_userId"),
          headers: headers, body: jsonEncode(diaryFolderDetail.toJson()));

      if (response.statusCode == 200) {
        return DiaryFolderModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      log("Error creating diary folders: $e");
    }
    return null;
  }

  Future<List<DiaryFolderModel>> getAllWorkspaceDiaryFoldersWithDiaries(
      String workspaceId) async {
    try {
      final headers = await _getHeaders();
      final response = await http
          .get(Uri.parse("$baseUrl/workspace/$workspaceId"), headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => DiaryFolderModel.fromJson(data)).toList();
      }
      throw Exception("Fail to fetch diary folders: ${response.statusCode}");
    } catch (e) {
      log("Error fetching diary folders: $e");
      return [];
    }
  }

  Future<DiaryFolderModel?> createWorkspaceDiaryFolder(
      String workspaceId, DiaryFolderDetail diaryFolderDetail) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
          Uri.parse("$baseUrl/workspace/$workspaceId"),
          headers: headers,
          body: jsonEncode(diaryFolderDetail.toJson()));

      if (response.statusCode == 200) {
        return DiaryFolderModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      log("Error creating diary folders: $e");
    }
    return null;
  }

  Future<DiaryFolderModel?> updateDiaryFolder(
      String id, DiaryFolderDetail diaryFolderDetail) async {
    try {
      final headers = await _getHeaders();
      final response = await http.patch(Uri.parse("$baseUrl/$id"),
          headers: headers, body: jsonEncode(diaryFolderDetail));

      if (response.statusCode == 200) {
        return DiaryFolderModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      log("Error updating diary folders: $e");
    }
    return null;
  }

  Future<bool> deleteDiaryFolder(String id) async {
    try {
      final headers = await _getHeaders();
      final response =
          await http.delete(Uri.parse("$baseUrl/$id"), headers: headers);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception("Fail to delete diary folder: ${response.statusCode}");
      }
    } catch (e) {
      log("Error deleting diary folders: $e");
    }
    return false;
  }

  Future<Diary?> addDiaryToFolder(String id, DiaryDetail diaryDetail) async {
    try {
      final headers = await _getHeaders();
      // log(id);
      // log(diaryDetail.toJson().toString());
      final response = await http.post(
        Uri.parse("$baseUrl/$id/diary"),
        headers: headers,
        body: jsonEncode(diaryDetail),
      );

      if (response.statusCode == 200) {
        return Diary.fromMap(jsonDecode(response.body));
      } else {
        throw Exception("Fail to add diary to folder: ${response.statusCode}");
      }
    } catch (e) {
      log("Error to add diary to folder: $e");
    }
    return null;
  }
}
