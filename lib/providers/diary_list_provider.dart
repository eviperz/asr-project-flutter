import 'package:asr_project/models/diary.dart';
import 'package:asr_project/services/diary_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Service Provider
// final diaryServiceProvider = Provider((ref) => DiaryService());

// AsyncNotifier Provider
final diaryListProvider =
    AsyncNotifierProvider<DiaryListNotifier, List<Diary>>(() {
  return DiaryListNotifier();
});

// Notifier Class
class DiaryListNotifier extends AsyncNotifier<List<Diary>> {
  final DiaryService _diaryService = DiaryService();

  @override
  Future<List<Diary>> build() async {
    // _diaryService = ref.watch(diaryServiceProvider);
    return await _diaryService.fetchDiaries();
  }

  Future<void> loadDiaries() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _diaryService.fetchDiaries());
  }

  Future<Diary?> addDiary(DiaryDetail diaryDetail) async {
    final diary = await _diaryService.addDiary(diaryDetail);
    if (diary != null) {
      state = AsyncValue.data([...state.value ?? [], diary]);
      return diary;
    }
    return null;
  }

  Future<Diary?> updateDiary(String id, DiaryDetail diaryDetail) async {
    final updatedDiary = await _diaryService.updateDiary(id, diaryDetail);
    if (updatedDiary != null) {
      state = AsyncValue.data(
          state.value!.map((d) => d.id == id ? updatedDiary : d).toList());
      return updatedDiary;
    }
    return null;
  }

  Future<void> removeDiary(String id) async {
    final success = await _diaryService.deleteDiary(id);
    if (success) {
      state = AsyncValue.data(state.value!.where((d) => d.id != id).toList());
    }
  }

  Diary? getDiary(String id) {
    try {
      return state.value?.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  bool isExist(String id) => state.value?.any((e) => e.id == id) ?? false;

  Set<String> get tags {
    return state.value?.expand((e) => e.tags.map((tag) => tag.name)).toSet() ??
        {};
  }
}
