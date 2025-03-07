import 'dart:developer';

import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/pages/workspace_page/workspace_detail_page/workspace_setting/workspace_setting_page.dart';
import 'package:asr_project/providers/workspace_diary_folder_provider%20copy.dart';
import 'package:asr_project/widgets/diary/diary_folder_blocks.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkspaceDetailPage extends ConsumerStatefulWidget {
  final Workspace workspace;
  const WorkspaceDetailPage({super.key, required this.workspace});

  @override
  ConsumerState<WorkspaceDetailPage> createState() =>
      _WorkspaceDetailPageState();
}

class _WorkspaceDetailPageState extends ConsumerState<WorkspaceDetailPage> {
  late Workspace _workspace;
  late bool creatingFolderMode = false;
  List<DiaryFolderModel> filteredDiaryFolders = [];

  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _workspace = widget.workspace;
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _addFolder() async {
    String? responseMessage = await ref
        .read(workspaceDiaryFoldersProvider.notifier)
        .createWorkspaceDiaryFolder();

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
        (ref.read(workspaceDiaryFoldersProvider).value ?? [])
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
          .read(workspaceDiaryFoldersProvider.notifier)
          .updateDiaryFolder(id, diaryFolderDetail);
      log(responseMessage.toString());

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
        .read(workspaceDiaryFoldersProvider.notifier)
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
        .read(workspaceDiaryFoldersProvider.notifier)
        .addDiaryToFolder(folderId, diaryDetail);

    if (!mounted) return;
    if (diary != null) {
      Navigator.pushNamed(context, "/diary/detail",
          arguments: {"type": "workspace", "diary": diary});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create diary")),
      );
    }
  }

  void _showSettingModal() async {
    final Workspace? updatedWorkspace =
        await showCupertinoModalPopup<Workspace>(
      context: context,
      builder: (context) {
        return WorkspaceSettingPage(workspace: _workspace);
      },
    );

    if (updatedWorkspace != null) {
      setState(() {
        _workspace = updatedWorkspace;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<DiaryFolderModel> diaryFolders =
        ref.watch(workspaceDiaryFoldersProvider).value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_workspace.name),
        actions: [
          IconButton(onPressed: _showSettingModal, icon: Icon(Icons.settings))
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              spacing: 16.0,
              children: [
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    hintText: "Search Diary",
                  ),
                  controller: _textEditingController,
                  onTap: () {
                    // Navigator.pushNamed(context, route)
                  },
                ),
                Column(
                  children: [
                    DiaryFolderBlocks(
                      type: "workspace",
                      folders: diaryFolders,
                      onCreateFolder: _addFolder,
                      onUpdateFolderName: _updateFolderName,
                      onCreateDiary: _addDiaryInFolder,
                      onDeleteFolder: _deleteFolder,
                      creatingFolderMode: creatingFolderMode,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
