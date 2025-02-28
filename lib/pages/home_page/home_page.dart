import 'package:asr_project/models/diary.dart';
import 'package:asr_project/widgets/diary/diary_folder_blocks.dart';
import 'package:asr_project/widgets/diary/diary_list_view_horizontal.dart';
import 'package:asr_project/providers/diary_list_provider.dart';
import 'package:asr_project/widgets/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late bool creatingFolderMode = false;
  late List<Map<String, dynamic>> categories;
  final String username = "username";

  @override
  void initState() {
    super.initState();
    categories = [
      {
        "name": "Default",
        "diaries": [Diary()],
      }
    ];
  }

  void _addFolder() {
    setState(() {
      categories.add({
        "name": "New Folder",
        "diaries": [],
      });
      creatingFolderMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final diaryListAsync = ref.watch(diaryListProvider);

    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Row(
                children: [
                  ProfileImage(),
                  SizedBox(width: 8.0),
                  Text("Username"),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: diaryListAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Error: $err")),
        data: (diaryList) {
          final DateTime now = DateTime.now();
          final DateTime sevenDaysAgo = now.subtract(Duration(days: 7));

          final List<Diary> recentDiaries = diaryList.where((e) {
            return e.updatedAt.isAfter(sevenDaysAgo) &&
                e.updatedAt.isBefore(now);
          }).toList();

          return SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20.0,
                children: [
                  _buildHomeWelcomeContainer(context),
                  if (recentDiaries.isNotEmpty)
                    DiaryListViewHorizontal(
                      title: "Recently",
                      diaryList: recentDiaries,
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: DiaryFolderBlocks(
                      categories: categories,
                      onCreateFolder: _addFolder,
                      creatingFolderMode: creatingFolderMode,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, "/diary/create"),
        icon: Icon(Icons.add),
        label: Text("Diary"),
      ),
    );
  }

  Widget _buildHomeWelcomeContainer(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0),
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
                username,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ],
          ),
          ProfileImage(size: 50)
        ],
      ),
    );
  }
}
