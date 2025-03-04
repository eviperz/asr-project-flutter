import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/providers/tag_list_provider.dart';
import 'package:asr_project/providers/user_diary_folder_provider.dart';
import 'package:asr_project/providers/user_provider.dart';
import 'package:asr_project/widgets/diary/diary_folder_blocks.dart';
import 'package:asr_project/widgets/diary/diary_list_view_horizontal.dart';
import 'package:asr_project/widgets/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late bool creatingFolderMode;

  @override
  void initState() {
    super.initState();
    creatingFolderMode = false;
    Future.microtask(() => ref.read(tagListProvider));
  }

  void _addFolder() {
    ref.read(userDiaryFoldersProvider.notifier).createPersonalDiaryFolder();
  }

  void _updateFolderName(String id, String name) {
    final List<String> diaryIds =
        ref.read(userDiaryFoldersProvider.notifier).diaryIds;

    ref.read(userDiaryFoldersProvider.notifier).updateDiaryFolder(
        id, DiaryFolderDetail(folderName: name, diaryIds: diaryIds));
  }

  void _deleteFolder(String id) {
    ref.read(userDiaryFoldersProvider.notifier).deleteDiaryFolder(id);
  }

  void _createDiaryInFolder(String folderId) async {
    DiaryDetail diaryDetail = DiaryDetail();
    Diary? diary = await ref
        .read(userDiaryFoldersProvider.notifier)
        .addDiaryToFolder(folderId, diaryDetail);

    if (!mounted) return;

    if (diary != null) {
      Navigator.pushNamed(context, "/diary/detail", arguments: diary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = ref.watch(userProvider).value?.name ?? "Guest";
    final userDiaryFoldersAsync = ref.watch(userDiaryFoldersProvider);

    return Scaffold(
      appBar: AppBar(),
      drawer: _buildDrawer(name),
      body: userDiaryFoldersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (diaryList) => _buildBody(
            context, userDiaryFoldersAsync.asData?.value ?? [], name),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final String defaultFolderId =
              ref.read(userDiaryFoldersProvider.notifier).getDefaultFolderId;
          _createDiaryInFolder(defaultFolderId);
        },
        icon: const Icon(Icons.add),
        label: const Text("Diary"),
      ),
    );
  }

  Widget _buildDrawer(String name) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Row(
              children: [
                const ProfileImage(),
                const SizedBox(width: 8.0),
                Text(name),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, List<DiaryFolderModel> diaryFolders, String name) {
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
            _buildHomeWelcomeContainer(context, name),
            if (recentDiaries.isNotEmpty)
              DiaryListViewHorizontal(
                title: "Recently",
                diaryList: recentDiaries,
              ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: DiaryFolderBlocks(
                folders: diaryFolders,
                onCreateFolder: _addFolder,
                onUpdateFolderName: _updateFolderName,
                onDeleteFolder: _deleteFolder,
                onCreateDiary: _createDiaryInFolder,
                creatingFolderMode: creatingFolderMode,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeWelcomeContainer(BuildContext context, String name) {
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
                name,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          const ProfileImage(size: 50)
        ],
      ),
    );
  }
}
