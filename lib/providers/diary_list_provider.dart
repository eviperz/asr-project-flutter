import 'dart:convert';
import 'dart:developer';

import 'package:asr_project/config.dart';
import 'package:asr_project/models/diary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

final diaryListProvider = StateNotifierProvider<DiaryListNotifier, List<Diary>>(
  (ref) => DiaryListNotifier(),
);

class DiaryListNotifier extends StateNotifier<List<Diary>> {
  DiaryListNotifier() : super([]) {
    _fetchDiaries();
  }

  Future<void> _fetchDiaries() async {
    try {
      final response = await http.get(
        Uri.parse("${AppConfig.baseUrl}/diaries"),
        headers: {
          'Authorization': AppConfig.basicAuth,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        final List<Diary> diaries =
            jsonData.map((data) => Diary.fromMap(data)).toList();
        state = diaries;
      } else {
        throw Exception("Fail to fetching diaries: ${response.statusCode}");
      }
    } catch (e) {
      log("Exception occurred while fetching diaries: $e");
    }
  }

  Future<Diary?> addDiary(DiaryDetail diaryDetail) async {
    try {
      final http.Response response = await http.post(
        Uri.parse("${AppConfig.baseUrl}/diaries"),
        headers: {
          'Authorization': AppConfig.basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(diaryDetail.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final Diary diary = Diary.fromMap(jsonData);

        _fetchDiaries();
        return diary;
      } else {
        throw Exception("Fail to create diary: ${response.statusCode}");
      }
    } catch (e) {
      log("Exception occurred while adding diary: $e");
      return null;
    }
  }

  Future<Diary?> updateDiary(String id, DiaryDetail diaryDetail) async {
    try {
      final http.Response response = await http.patch(
        Uri.parse("${AppConfig.baseUrl}/diaries/$id"),
        headers: {
          'Authorization': AppConfig.basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode(diaryDetail.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final Diary diary = Diary.fromMap(jsonData);

        _fetchDiaries();
        return diary;
      } else {
        throw Exception("Fail to update diary: ${response.statusCode}");
      }
    } catch (e) {
      log("Exception occurred while updating diary: $e");
      return null;
    }
  }

  Future<void> removeDiary(String id) async {
    try {
      final http.Response response = await http.delete(
        Uri.parse("${AppConfig.baseUrl}/diaries/$id"),
        headers: {
          'Authorization': AppConfig.basicAuth,
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _fetchDiaries();
      } else {
        throw Exception("Fail to delete diary: ${response.statusCode}");
      }
    } catch (e) {
      log("Exception occurred while deleting diary: $e");
    }
  }

  Diary get(String id) {
    return state.firstWhere((e) => e.id == id);
  }

  bool isExist(String id) {
    return state.any((e) => e.id == id);
  }

  Set<String> get tags {
    return Set.from(state.expand((e) => e.tags));
  }
}
