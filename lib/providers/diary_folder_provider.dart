import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:asr_project/services/diary_folder_service.dart';
import 'package:asr_project/services/diary_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier Provider
final diaryFoldersProvider =
    AsyncNotifierProvider<DiaryFoldersNotifier, List<DiaryFolderModel>>(
        DiaryFoldersNotifier.new);

// Notifier Class
class DiaryFoldersNotifier extends AsyncNotifier<List<DiaryFolderModel>> {
  final DiaryFolderService _diaryFolderService = DiaryFolderService();
  final DiaryService _diaryService = DiaryService();

  @override
  Future<List<DiaryFolderModel>> build() async {
    return await fetchData();
  }

  Future<List<DiaryFolderModel>> fetchData() async {
    state = AsyncLoading();
    final String? workspaceId = ref.read(workspaceIdProvider);
    if (workspaceId == null) {
      state = AsyncData(
          await _diaryFolderService.getAllPersonalDiaryFoldersWithDiaries());
    } else {
      state = AsyncData(await _diaryFolderService
          .getAllWorkspaceDiaryFoldersWithDiaries(workspaceId));
    }
    return state.value ?? [];
  }

  Future<String> createDiaryFolder(DiaryFolderDetail diaryFolderDetail) async {
    try {
      final String? workspaceId = ref.read(workspaceIdProvider);
      final DiaryFolderModel? diaryFolderModel = (workspaceId == null)
          ? await _diaryFolderService
              .createPersonalDiaryFolder(diaryFolderDetail)
          : await _diaryFolderService.createWorkspaceDiaryFolder(
              workspaceId, diaryFolderDetail);

      if (diaryFolderModel != null) {
        state = AsyncData([...state.value ?? [], diaryFolderModel]);
        return "Success to create Meeting Note Folder";
      } else {
        return "Failed to create Meeting Note Folder";
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return "Failed to create Meeting Note Folder";
    }
  }

  Future<String> updateDiaryFolderName(
      String id, DiaryFolderDetail diaryFolderName) async {
    try {
      final DiaryFolderModel? diaryFolderModel =
          await _diaryFolderService.updateDiaryFolder(id, diaryFolderName);

      if (diaryFolderModel != null) {
        state = AsyncData(state.value!.map((item) {
          if (item.id == id) {
            return item.copyWith(name: diaryFolderModel.name);
          }
          return item;
        }).toList());
        return "Success to update Meeting Note Folder";
      } else {
        return "Fail to update Meeting Note Folder";
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return "Fail to update Meeting Note Folder";
    }
  }

  Future<String?> deleteDiaryFolder(String folderId) async {
    try {
      final bool status = await _diaryFolderService.deleteDiaryFolder(folderId);

      if (status) {
        state = AsyncData(
            state.value!.where((item) => item.id != folderId).toList());
        return "Success to delete Meeting Note Folder";
      } else {
        return "Failed to delete Meeting Note Folder";
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return "Failed to delete Meeting Note Folder";
    }
  }

  Future<Diary?> addDiaryToFolder(
      String folderId, DiaryDetail diaryDetail) async {
    try {
      final Diary? diary =
          await _diaryFolderService.addDiaryToFolder(folderId, diaryDetail);

      if (diary != null) {
        state = AsyncData(state.value!.map((item) {
          if (item.id == folderId) {
            return item.copyWith(diaries: [...(item.diaries ?? []), diary]);
          }
          return item;
        }).toList());
        return diary;
      } else {
        return null;
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return null;
    }
  }

  Future<String> updateDiary(String diaryId, DiaryDetail diaryDetail) async {
    try {
      final Diary? updatedDiary =
          await _diaryService.updateDiary(diaryId, diaryDetail);

      if (updatedDiary != null) {
        state = AsyncData(state.value!.map((folder) {
          if ((folder.diaries ?? []).any((diary) => diary.id == diaryId)) {
            return folder.copyWith(
              diaries: (folder.diaries ?? []).map((diary) {
                return diary.id == diaryId
                    ? diary.copyWith(
                        title: updatedDiary.title,
                        content: updatedDiary.content,
                        tagIds: updatedDiary.tagIds,
                        updatedAt: updatedDiary.updatedAt,
                      )
                    : diary;
              }).toList(),
            );
          }
          return folder;
        }).toList());

        return "Success to update Meeting Note";
      } else {
        return "Fail to update Meeting Note";
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return "Fail to update Meeting Note";
    }
  }

  Future<String> deleteDiary(String diaryId) async {
    try {
      final bool status = await _diaryService.deleteDiary(diaryId);

      if (status) {
        state = AsyncData(state.value!.map((folder) {
          if ((folder.diaries ?? []).any((diary) => diary.id == diaryId)) {
            return folder.copyWith(
              diaries: (folder.diaries ?? [])
                  .where((diary) => diary.id != diaryId)
                  .toList(),
            );
          }
          return folder;
        }).toList());
        return "Success to delete Meeting Note";
      } else {
        return "Fail to delete Meeting Note";
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return "Fail to delete Meeting Note";
    }
  }

  DiaryFolderModel? diaryFolderById(String folderId) =>
      state.value?.firstWhere((item) => item.id == folderId);

  List<Diary> get allDiariesInFolders => (state.value ?? [])
      .expand((folder) => folder.diaries as List<Diary>)
      .toList();

  List<String> get diaryIds =>
      (state.value ?? []).map((item) => item.id).toList();

  String get getDefaultFolderId => (state.value ?? [])
      .firstWhere((item) => item.name == "Default",
          orElse: () => DiaryFolderModel(id: "", name: "Default", diaries: []))
      .id;
}
