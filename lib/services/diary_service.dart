import 'dart:convert';
import 'dart:developer';
import 'package:asr_project/config.dart';
import 'package:asr_project/models/diary.dart';
import 'package:http/http.dart' as http;

class DiaryService {
  final String baseUrl = "${AppConfig.baseUrl}/diaries";
  final Map<String, String> headers = {
    'Authorization': AppConfig.basicAuth,
    'Content-Type': 'application/json',
  };

  Future<List<Diary>> fetchDiaries() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((data) => Diary.fromMap(data)).toList();
      }
      throw Exception("Fail to fetch diaries: ${response.statusCode}");
    } catch (e) {
      log("Error fetching diaries: $e");
      return [];
    }
  }

  Future<Diary?> addDiary(DiaryDetail diaryDetail) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(diaryDetail.toJson()),
      );

      if (response.statusCode == 200) {
        return Diary.fromMap(jsonDecode(response.body));
      }
      throw Exception("Fail to create diary: ${response.statusCode}");
    } catch (e) {
      log("Error adding diary: $e");
      return null;
    }
  }

  Future<Diary?> updateDiary(String id, DiaryDetail diaryDetail) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/$id"),
        headers: headers,
        body: jsonEncode(diaryDetail.toJson()),
      );

      if (response.statusCode == 200) {
        return Diary.fromMap(jsonDecode(response.body));
      }
      throw Exception("Fail to update diary: ${response.statusCode}");
    } catch (e) {
      log("Error updating diary: $e");
      return null;
    }
  }

  Future<bool> deleteDiary(String id) async {
    try {
      final response =
          await http.delete(Uri.parse("$baseUrl/$id"), headers: headers);
      Diary.removeCache(id);

      return response.statusCode == 200;
    } catch (e) {
      log("Error deleting diary: $e");
      return false;
    }
  }
}
