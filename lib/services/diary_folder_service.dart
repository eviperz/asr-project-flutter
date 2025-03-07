import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:asr_project/config.dart';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:http/http.dart' as http;

class DiaryFolderService {
  final String userId = AppConfig.userId;
  final String baseUrl = "${AppConfig.baseUrl}/folders";
  final Map<String, String> headers = {
    'Authorization': AppConfig.basicAuth,
    'Content-Type': 'application/json',
  };

  Future<List<DiaryFolderModel>> getAllPersonalDiaryFoldersWithDiaries() async {
    try {
      final String type = "personal";
      final response =
          await http.get(Uri.parse("$baseUrl/$type/$userId"), headers: headers);

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

  Future<DiaryFolderModel?> createPersonalDiaryFolder() async {
    try {
      final String type = "personal";
      final response = await http.post(Uri.parse("$baseUrl/$type/$userId"),
          headers: headers,
          body:
              jsonEncode(DiaryFolderDetail(folderName: "New Folder").toJson()));

      if (response.statusCode == 200) {
        return DiaryFolderModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      log("Error creating diary folders: $e");
    }
    return null;
  }

  Future<List<DiaryFolderModel>> getAllWorkspaceDiaryFoldersWithDiaries(String workspaceId) async {
    try {
      final response =
          await http.get(Uri.parse("$baseUrl/workspace/$userId"), headers: headers);

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

  Future<DiaryFolderModel?> createWorkspaceDiaryFolder(String workspaceId) async {
    try {
      final response = await http.post(Uri.parse("$baseUrl/workspace/$userId"),
          headers: headers,
          body:
              jsonEncode(DiaryFolderDetail(folderName: "New Folder").toJson()));

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

  Future<String?> deleteDiaryFolder(String id) async {
    try {
      final response =
          await http.delete(Uri.parse("$baseUrl/$id"), headers: headers);

      if (response.statusCode == 200) {
        return id;
      } else {
        throw Exception("Fail to delete diary folder: ${response.statusCode}");
      }
    } catch (e) {
      log("Error deleting diary folders: $e");
    }
    return null;
  }

  Future<Diary?> addDiaryToFolder(String id, DiaryDetail diaryDetail) async {
    try {
      final response = await http.post(Uri.parse("$baseUrl/$id/diary"),
          headers: headers, body: jsonEncode(diaryDetail));
      if (response.statusCode == 200) {
        return Diary.fromMap(jsonDecode(response.body));
      }
    } catch (e) {
      log("Error updating diary folders: $e");
    }
    return null;
  }
}
