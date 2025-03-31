import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/providers/diary_folder_provider.dart';
import 'package:asr_project/providers/tag_provider.dart';
import 'package:asr_project/providers/user_provider.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:asr_project/widgets/custom_textfield.dart';
import 'package:asr_project/widgets/diary/diary_folder_blocks.dart';
import 'package:asr_project/widgets/diary/diary_list_view_horizontal.dart';
import 'package:asr_project/widgets/profile_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final FocusNode _searchFocusNode = FocusNode();
  late bool creatingFolderMode = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(userProvider.notifier).fetchData();
      ref.read(workspaceIdProvider.notifier).state = null;
      ref.read(diaryFoldersProvider.notifier).fetchData();
      ref.read(tagsProvider.notifier).fetchData();
    });
    _searchFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _searchFocusNode.dispose();
  }

  void _addFolder() async {
    String uniqueName = _generateUniqueFolderName("New Folder", 0);

    DiaryFolderDetail diaryFolderDetail = DiaryFolderDetail(
      name: uniqueName,
    );

    String? responseMessage = await ref
        .read(diaryFoldersProvider.notifier)
        .createDiaryFolder(diaryFolderDetail);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(responseMessage)),
    );
  }

  String _generateUniqueFolderName(String baseName, double count) {
    final List<DiaryFolderModel> diaryFolders =
        ref.read(diaryFoldersProvider).value ?? [];

    String newName = count == 0 ? baseName : "$baseName (${count.toInt()})";

    bool isDuplicate = diaryFolders.any((folder) => folder.name == newName);

    if (isDuplicate) {
      return _generateUniqueFolderName(baseName, count + 1);
    }

    return newName;
  }

  void _updateFolderName(String id, String name) async {
    DiaryFolderDetail diaryFolderDetail = DiaryFolderDetail(
      name: name,
    );

    try {
      String? responseMessage = await ref
          .read(diaryFoldersProvider.notifier)
          .updateDiaryFolderName(id, diaryFolderDetail);

      if (!mounted) return;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Failed to update name of Meeting Note folder")),
      );
    }
  }

  Future<void> _deleteFolder(String id) async {
    String? responseMessage =
        await ref.read(diaryFoldersProvider.notifier).deleteDiaryFolder(id);

    if (!mounted) return;
    if (responseMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete Meeting Note folder")),
      );
    }
  }

  Future<void> _addDiaryInFolder(String folderId) async {
    DiaryDetail diaryDetail = DiaryDetail.createDiary();
    Diary? diary = await ref
        .read(diaryFoldersProvider.notifier)
        .addDiaryToFolder(folderId, diaryDetail);

    if (!mounted) return;
    if (diary != null) {
      Navigator.pushNamed(context, "/diary/detail",
          arguments: {'diary': diary, 'canEdit': true});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create Meeting Note")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<User?> user = ref.watch(userProvider);
    final AsyncValue<List<DiaryFolderModel>> diaryFoldersAsync =
        ref.watch(diaryFoldersProvider);

    return Scaffold(
      body: diaryFoldersAsync.when(
        data: (diaryFolders) {
          final List<Diary> diaries =
              ref.watch(diaryFoldersProvider.notifier).allDiariesInFolders;
          return _buildBody(context, diaryFolders, diaries, user.value);
        },
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (err, stack) => Center(child: Text("Error: $err")),
      ),
      floatingActionButton: diaryFoldersAsync.when(
        data: (diaryFolders) {
          final DiaryFolderModel? defaultFolder = diaryFolders
              .firstWhereOrNull((folder) => folder.name == "Default");

          return FloatingActionButton.extended(
            onPressed: () {
              if (defaultFolder != null) {
                _addDiaryInFolder(defaultFolder.id);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("No Default folder found")),
                );
              }
            },
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            icon: Icon(
              Icons.add,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: Text(
              "Note",
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
          );
        },
        loading: () => const SizedBox(),
        error: (err, stack) => const SizedBox(),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<DiaryFolderModel> diaryFolders,
      List<Diary> diaries, User? user) {
    final DateTime now = DateTime.now();
    final DateTime sevenDaysAgo = now.subtract(const Duration(days: 7));

    final List<Diary> recentDiaries = diaryFolders
        .expand((folder) => folder.diaries ?? [])
        .cast<Diary>()
        .where((diary) =>
            diary.updatedAt.isAfter(sevenDaysAgo) &&
            diary.updatedAt.isBefore(now))
        .toList();

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHomeWelcomeContainer(context, user),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: CustomTextfield(
                  hintText: "Search",
                  iconData: Icons.search,
                  canClear: true,
                  keyboardType: TextInputType.text,
                  focusNode: _searchFocusNode,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      "/diary/search",
                      arguments: true,
                    );
                    _searchFocusNode.unfocus();
                  }),
            ),
            if (recentDiaries.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 10.0),
                child: DiaryListViewHorizontal(
                  title: "Recently",
                  diaryList: recentDiaries,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 30.0),
              child: DiaryFolderBlocks(
                canEdit: true,
                folders: diaryFolders,
                onCreateFolder: _addFolder,
                onUpdateFolderName: _updateFolderName,
                onDeleteFolder: _deleteFolder,
                onCreateDiary: _addDiaryInFolder,
                creatingFolderMode: creatingFolderMode,
              ),
            ),
          ],
          // ],
        ),
      ),
    );
  }

  Widget _buildHomeWelcomeContainer(BuildContext context, User? user) {
    String name = user?.name ?? "Guest";
    String truncatedName =
        name.length > 20 ? '${name.substring(0, 16)}...' : name;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome back",
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                truncatedName,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          ProfileImage(profile: user?.getProfile(), size: 50)
        ],
      ),
    );
  }
}
