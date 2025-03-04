import 'package:asr_project/models/diary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier Provider
final userDiariesProvider =
    StateNotifierProvider<UserDiariesNotifier, Map<String, List<Diary>>>((ref) {
  return UserDiariesNotifier();
});

// Notifier Class
class UserDiariesNotifier extends StateNotifier<Map<String, List<Diary>>> {
  UserDiariesNotifier() : super({});

  // final DiaryFolderService _diaryFolderService = DiaryFolderService();

  void addNewKey(String id) {
    state = {
      ...state,
      id: state[id] ?? []
    };
  }

  void updateDiaries(Map<String, List<Diary>> diaries) {
    state = diaries;
  }
}
