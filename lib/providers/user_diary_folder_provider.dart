import 'dart:async';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/services/diary_folder_service.dart';
import 'package:asr_project/services/diary_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier Provider
final userDiaryFoldersProvider =
    AsyncNotifierProvider<UserDiaryFoldersNotifier, List<DiaryFolderModel>>(() {
  return UserDiaryFoldersNotifier();
});

// Notifier Class
class UserDiaryFoldersNotifier extends AsyncNotifier<List<DiaryFolderModel>> {
  final String userId = "67c6dc96cebfae511c3c7a3a";
  final DiaryFolderService _diaryFolderService = DiaryFolderService();
  final DiaryService _diaryService = DiaryService();

  @override
  Future<List<DiaryFolderModel>> build() async {
    return _diaryFolderService.getAllPersonalDiaryFoldersWithDiaries(userId);
  }

  Future<void> _fetchData() async {
    state =
        const AsyncValue.loading();
    state = await AsyncValue.guard(() =>
        _diaryFolderService.getAllPersonalDiaryFoldersWithDiaries(userId));
  }

  Future<void> createPersonalDiaryFolder() async {
    DiaryFolderModel? diaryFolderModel =
        await _diaryFolderService.createPersonalDiaryFolder(userId);

    if (diaryFolderModel != null) {
      state = AsyncValue.data([...?state.value, diaryFolderModel]);
    }
  }

  Future<void> updateDiaryFolder(
      String id, DiaryFolderDetail diaryFolderDetail) async {
    DiaryFolderModel? diaryFolderModel =
        await _diaryFolderService.updateDiaryFolder(id, diaryFolderDetail);

    if (diaryFolderModel != null) {
      state = AsyncValue.data((state.value ?? [])
          .map((d) => d.id == id ? diaryFolderModel : d)
          .toList());
    }
  }

  Future<void> deleteDiaryFolder(String folderId) async {
    String? id = await _diaryFolderService.deleteDiaryFolder(folderId);
    if (id != null) {
      state = AsyncValue.data(
          (state.value ?? []).where((d) => d.id != id).toList());
    }
  }

  Future<Diary?> addDiaryToFolder(
      String folderId, DiaryDetail diaryDetail) async {
    Diary? diary =
        await _diaryFolderService.addDiaryToFolder(folderId, diaryDetail);

    if (diary != null) {
      List<DiaryFolderModel> updatedFolders = (state.value ?? []).map((folder) {
        if (folder.id == folderId) {
          return folder.copyWith(
            diaries: [...?folder.diaries, diary],
          );
        }
        return folder;
      }).toList();

      state = AsyncValue.data(updatedFolders);
      return diary;
    }
    return null;
  }

  Future<Diary?> updateDiary(String diaryId, DiaryDetail diaryDetail) async {
    Diary? diary = await _diaryService.updateDiary(diaryId, diaryDetail);

    if (diary != null) {
      await _fetchData();
      return diary;
    }
    return null;
  }

  Future<void> removeDiary(String diaryId) async {
    await _diaryService.deleteDiary(diaryId);
    await _fetchData();
  }

  List<String> get diaryIds =>
      state.value?.map((item) => item.id).toList() ?? [];

  String get getDefaultFolderId =>
      state.value
          ?.firstWhere(
            (item) => item.name == "Default",
            orElse: () =>
                DiaryFolderModel(id: "", name: "Default", diaries: []),
          )
          .id ??
      "";
}
