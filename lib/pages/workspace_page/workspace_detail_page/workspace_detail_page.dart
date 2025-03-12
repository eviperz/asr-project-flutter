import 'dart:developer';

import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/providers/diary_folder_provider.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:asr_project/widgets/custom_textfield.dart';
import 'package:asr_project/widgets/diary/diary_folder_blocks.dart';
import 'package:asr_project/widgets/workspace/workspace_member_display.dart';
import 'package:asr_project/widgets/workspace_icon.dart';
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

  void _navigatorSetting() async {
    final bool? isEdit = await Navigator.pushNamed<bool?>(
        context, "/workspace/setting",
        arguments: _workspace);

    if (isEdit != null && isEdit) {
      setState(() {
        _workspace = ref.read(workspaceProvider.notifier).workspaceByIdProvider;
        log(_workspace.icon.colorEnum.hexCode.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue diaryFoldersAsync = ref.watch(diaryFoldersProvider);
    final List<Diary> diaries =
        ref.read(diaryFoldersProvider.notifier).allDiariesInFolders;
    final User owner = _workspace.members.entries
        .firstWhere((entry) => entry.value == WorkspacePermission.owner)
        .key;

    final List<User> memberWithoutOwner = Map.fromEntries(
      _workspace.members.entries.where((entry) => entry.key != owner),
    ).keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_workspace.name),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              spacing: 16.0,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 20,
                      children: [
                        WorkspaceIcon(
                          workspaceIconEnum: _workspace.icon.iconEnum,
                          colorEnum: _workspace.icon.colorEnum,
                          size: 80,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _workspace.name,
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            WorkspaceMemberDisplay(
                                memberWithoutOwner: memberWithoutOwner,
                                owner: owner),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: _navigatorSetting,
                      icon: Icon(Icons.edit),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(),
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
