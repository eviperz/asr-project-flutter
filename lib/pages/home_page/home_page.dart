import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/providers/tag_list_provider.dart';
import 'package:asr_project/providers/personal_diary_folder_provider.dart';
import 'package:asr_project/providers/user_provider.dart';
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
  late bool creatingFolderMode = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(tagListProvider));
  }

  void _addFolder() async {
    String? responseMessage = await ref
        .read(personalDiaryFoldersProvider.notifier)
        .createPersonalDiaryFolder();

    if (!mounted) return;
    if (responseMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create diary folder")),
      );
    }
  }

  void _updateFolderName(String id, String name) async {
    DiaryFolderModel? diaryFolder =
        (ref.read(personalDiaryFoldersProvider).value ?? [])
            .firstWhereOrNull((folder) => folder.id == id);

    if (diaryFolder == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Folder not found")),
      );
      return;
    }

    DiaryFolderDetail diaryFolderDetail = DiaryFolderDetail(
      folderName: name,
      diaryIds: (diaryFolder.diaries ?? []).map((diary) => diary.id).toList(),
    );

    try {
      String? responseMessage = await ref
          .read(personalDiaryFoldersProvider.notifier)
          .updateDiaryFolder(id, diaryFolderDetail);

      if (!mounted) return;
      if (responseMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseMessage)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update name of diary folder")),
      );
    }
  }

  Future<void> _deleteFolder(String id) async {
    String? responseMessage = await ref
        .read(personalDiaryFoldersProvider.notifier)
        .deleteDiaryFolder(id);

    if (!mounted) return;
    if (responseMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete diary folder")),
      );
    }
  }

  Future<void> _addDiaryInFolder(String folderId) async {
    DiaryDetail diaryDetail = DiaryDetail();
    Diary? diary = await ref
        .read(personalDiaryFoldersProvider.notifier)
        .addDiaryToFolder(folderId, diaryDetail);

    if (!mounted) return;
    if (diary != null) {
      Navigator.pushNamed(context, "/diary/detail", arguments: {
        "type": "personal",
        "diary": diary,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create diary")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? name = ref.watch(userProvider).value?.name;
    final List<DiaryFolderModel> diaryFolders =
        ref.watch(personalDiaryFoldersProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(),
      drawer: _buildDrawer(name ?? "Guest"),
      body: _buildBody(context, diaryFolders, name ?? "Guest"),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final DiaryFolderModel? defaultFolder = diaryFolders
              .firstWhereOrNull((folder) => folder.name == "Default");

          if (defaultFolder != null) {
            _addDiaryInFolder(defaultFolder.id);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No Default folder found")),
            );
          }
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
                type: "personal",
                title: "Recently",
                diaryList: recentDiaries,
              ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: DiaryFolderBlocks(
                type: "workspace",
                folders: diaryFolders,
                onCreateFolder: _addFolder,
                onUpdateFolderName: _updateFolderName,
                onDeleteFolder: _deleteFolder,
                onCreateDiary: _addDiaryInFolder,
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
