import 'dart:developer';

import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/pages/workspace_page/workspace_detail_page/workspace_setting/workspace_setting_page.dart';
import 'package:asr_project/providers/diary_folder_provider.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:asr_project/widgets/custom_textfield.dart';
import 'package:asr_project/widgets/diary/diary_folder_blocks.dart';
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

  final TextEditingController _searchTextEditingController =
      TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(workspaceIdProvider.notifier).state = widget.workspace.id;
    });

    _workspace = widget.workspace;
    _searchTextEditingController.addListener(() => setState(() {}));
    _searchFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextEditingController.dispose();
    _searchFocusNode.dispose();
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

  void _addFolder() async {
    String uniqueName = _generateUniqueFolderName("New Folder", 0);
    DiaryFolderDetail diaryFolderDetail =
        DiaryFolderDetail(folderName: uniqueName);

    String? responseMessage = await ref
        .read(diaryFoldersProvider.notifier)
        .createDiaryFolder(diaryFolderDetail);

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
    DiaryFolderDetail diaryFolderDetail = DiaryFolderDetail(
      folderName: name,
    );

    try {
      String? responseMessage = await ref
          .read(diaryFoldersProvider.notifier)
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
    String? responseMessage =
        await ref.read(diaryFoldersProvider.notifier).deleteDiaryFolder(id);

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
        .read(diaryFoldersProvider.notifier)
        .addDiaryToFolder(folderId, diaryDetail);

    if (!mounted) return;
    if (diary != null) {
      Navigator.pushNamed(context, "/diary/detail", arguments: diary);
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
    final AsyncValue diaryFoldersAsync = ref.watch(diaryFoldersProvider);
    final List<Diary> diaries =
        ref.read(diaryFoldersProvider.notifier).allDiariesInFolders;

    log(ref.watch(workspaceIdProvider).toString());
    // log(diaryFolders.length.toString());

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
                CustomTextfield(
                    hintText: "Search",
                    iconData: Icons.search,
                    canClear: true,
                    keyboardType: TextInputType.text,
                    focusNode: _searchFocusNode,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        "/diary/search",
                        arguments: diaries,
                      );
                      _searchFocusNode.unfocus();
                    }),
                diaryFoldersAsync.when(
                  data: (diaryFolders) => Column(
                    children: [
                      DiaryFolderBlocks(
                        folders: diaryFolders,
                        onCreateFolder: _addFolder,
                        onUpdateFolderName: _updateFolderName,
                        onCreateDiary: _addDiaryInFolder,
                        onDeleteFolder: _deleteFolder,
                        creatingFolderMode: creatingFolderMode,
                      ),
                    ],
                  ),
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stackTrace) => Center(
                    child: Text("Error: $error"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
