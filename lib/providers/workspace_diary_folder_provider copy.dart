import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/services/diary_folder_service.dart';
import 'package:asr_project/services/diary_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workspaceIdProvider = StateProvider<String>((ref) {
  return '';
});

final workspaceDiaryFoldersProvider = AsyncNotifierProvider<
    WorkspaceDiaryFoldersNotifier, List<DiaryFolderModel>>(() {
  return WorkspaceDiaryFoldersNotifier();
});

class WorkspaceDiaryFoldersNotifier
    extends AsyncNotifier<List<DiaryFolderModel>> {
  final DiaryFolderService _diaryFolderService = DiaryFolderService();
  final DiaryService _diaryService = DiaryService();

  @override
  Future<List<DiaryFolderModel>> build() async {
    final String id = ref.watch(workspaceIdProvider);
    return _diaryFolderService.getAllWorkspaceDiaryFoldersWithDiaries(id);
  }

  Future<void> _fetchData() async {
    final String id = ref.watch(workspaceIdProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
        () => _diaryFolderService.getAllWorkspaceDiaryFoldersWithDiaries(id));
  }

  Future<String?> createWorkspaceDiaryFolder(DiaryFolderDetail diaryFolderDetail) async {
    final String id = ref.watch(workspaceIdProvider);
    final result = await AsyncValue.guard(
        () => _diaryFolderService.createWorkspaceDiaryFolder(id, diaryFolderDetail));

    return result.when(
      data: (diaryFolderModel) {
        if (diaryFolderModel != null) {
          state = AsyncValue.data([...(state.value ?? []), diaryFolderModel]);
        }
        return "Success to create Diary Folder";
      },
      loading: () => null,
      error: (_, __) => "Failed to create Diary Folder",
    );
  }

  Future<String?> updateDiaryFolder(
      String id, DiaryFolderDetail diaryFolderDetail) async {
    final result = await AsyncValue.guard(
        () => _diaryFolderService.updateDiaryFolder(id, diaryFolderDetail));

    return result.when(
      data: (diaryFolderModel) {
        if (diaryFolderModel != null) {
          state = AsyncValue.data(
            (state.value ?? [])
                .map((d) => d.id == id ? diaryFolderModel : d)
                .toList(),
          );
        }
        return "Success to update Diary Folder";
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
        state = AsyncValue.data(
            (state.value ?? []).where((d) => d.id != id).toList());
        return "Success to delete Diary Folder";
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
          List<DiaryFolderModel> updatedFolders =
              (state.value ?? []).map((folder) {
            if (folder.id == folderId) {
              return folder.copyWith(
                diaries: [...?folder.diaries, diary],
              );
            }
            return folder;
          }).toList();

          state = AsyncValue.data(updatedFolders);
        } else {
          return null;
        }
        return diary;
      },
      loading: () => null,
      error: (_, __) => null,
    );
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
    await AsyncValue.guard(() => _diaryService.deleteDiary(diaryId));
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
