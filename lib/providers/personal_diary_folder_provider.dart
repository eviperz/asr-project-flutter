import 'dart:async';
import 'dart:developer';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/services/diary_folder_service.dart';
import 'package:asr_project/services/diary_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier Provider
final personalDiaryFoldersProvider =
    AsyncNotifierProvider<PersonalDiaryFoldersNotifier, List<DiaryFolderModel>>(
        () {
  return PersonalDiaryFoldersNotifier();
});

// Notifier Class
class PersonalDiaryFoldersNotifier
    extends AsyncNotifier<List<DiaryFolderModel>> {
  final DiaryFolderService _diaryFolderService = DiaryFolderService();
  final DiaryService _diaryService = DiaryService();

  @override
  Future<List<DiaryFolderModel>> build() async {
    return _diaryFolderService.getAllPersonalDiaryFoldersWithDiaries();
  }

  Future<void> _fetchData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _diaryFolderService.getAllPersonalDiaryFoldersWithDiaries());
  }

  // Helper function to update state
  void _updateState(List<DiaryFolderModel> updatedFolders) {
    state = AsyncValue.data(updatedFolders);
  }

  Future<String?> createPersonalDiaryFolder(
      DiaryFolderDetail diaryFolderDetail) async {
    final result = await AsyncValue.guard(
        () => _diaryFolderService.createPersonalDiaryFolder(diaryFolderDetail));
    return result.when(
      data: (diaryFolderModel) {
        if (diaryFolderModel != null) {
          _updateState([...(state.value ?? []), diaryFolderModel]);
          return "Success to create Diary Folder";
        }
        return null;
      },
      loading: () => null,
      error: (_, __) => "Failed to create Diary Folder",
    );
  }

  Future<String?> updateDiaryFolder(
      String id, DiaryFolderDetail diaryFolderDetail) async {
    final result = await AsyncValue.guard(
        () => _diaryFolderService.updateDiaryFolder(id, diaryFolderDetail));

    log((result.value?.diaries ?? []).toString());
    return result.when(
      data: (diaryFolderModel) {
        if (diaryFolderModel != null) {
          _updateState((state.value ?? []).map((folder) {
            return folder.id == id ? diaryFolderModel : folder;
          }).toList());
          return "Success to update Diary Folder";
        }
        return null;
      },
      loading: () => null,
      error: (_, __) => "Failed to update Diary Folder",
    );
  }

  Future<String?> deleteDiaryFolder(String folderId) async {
    final result = await AsyncValue.guard(
        () => _diaryFolderService.deleteDiaryFolder(folderId));
    return result.when(
      data: (id) {
        if (id != null) {
          _updateState(
              (state.value ?? []).where((folder) => folder.id != id).toList());
          return "Success to delete Diary Folder";
        }
        return null;
      },
      loading: () => null,
      error: (_, __) => "Failed to delete Diary Folder",
    );
  }

  Future<Diary?> addDiaryToFolder(
      String folderId, DiaryDetail diaryDetail) async {
    final result = await AsyncValue.guard(
        () => _diaryFolderService.addDiaryToFolder(folderId, diaryDetail));
    return result.when(
      data: (diary) {
        if (diary != null) {
          final updatedFolders = (state.value ?? []).map((folder) {
            if (folder.id == folderId) {
              return folder.copyWith(
                diaries: [...?folder.diaries, diary],
              );
            }
            return folder;
          }).toList();
          _updateState(updatedFolders);
        }
        return diary;
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  Future<Diary?> updateDiary(String diaryId, DiaryDetail diaryDetail) async {
    final diary = await _diaryService.updateDiary(diaryId, diaryDetail);
    if (diary != null) {
      await _fetchData();
      return diary;
    }
    return null;
  }

  Future<void> deleteDiary(String diaryId) async {
    await _diaryService.deleteDiary(diaryId);
    await _fetchData();
  }

  DiaryFolderModel? diaryFolderById(String folderId) =>
      state.value?.firstWhere((item) => item.id == folderId);

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
