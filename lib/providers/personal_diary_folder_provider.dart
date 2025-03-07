import 'dart:async';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/services/diary_folder_service.dart';
import 'package:asr_project/services/diary_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier Provider
final personalDiaryFoldersProvider =
    AsyncNotifierProvider<PersonalDiaryFoldersNotifier, List<DiaryFolderModel>>(() {
  return PersonalDiaryFoldersNotifier();
});

// Notifier Class
class PersonalDiaryFoldersNotifier extends AsyncNotifier<List<DiaryFolderModel>> {
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

  Future<String?> createPersonalDiaryFolder() async {
    DiaryFolderModel? diaryFolderModel =
        await _diaryFolderService.createPersonalDiaryFolder();

    if (diaryFolderModel != null) {
      state = AsyncValue.data([...(state.value ?? []), diaryFolderModel]);
      // _fetchData();
      return "Sucess to create Diary Folder";
    }
    return null;
  }

  Future<String?> updateDiaryFolder(
      String id, DiaryFolderDetail diaryFolderDetail) async {
    DiaryFolderModel? diaryFolderModel =
        await _diaryFolderService.updateDiaryFolder(id, diaryFolderDetail);

    if (diaryFolderModel != null) {
      state = AsyncValue.data((state.value ?? [])
          .map((d) => d.id == id ? diaryFolderModel : d)
          .toList());
      // _fetchData();
      return "Sucess to update Diary Folder";
    }
    return null;
  }

  Future<String?> deleteDiaryFolder(String folderId) async {
    String? id = await _diaryFolderService.deleteDiaryFolder(folderId);
    if (id != null) {
      state = AsyncValue.data(
          (state.value ?? []).where((d) => d.id != id).toList());
      return "Sucess to delete Diary Folder";
    }
    return null;
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

  Future<void> deleteDiary(String diaryId) async {
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
