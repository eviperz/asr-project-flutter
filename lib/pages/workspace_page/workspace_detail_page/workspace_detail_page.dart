import 'dart:developer';

import 'package:asr_project/config.dart';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/diary_folder.dart';
import 'package:asr_project/models/enum/workspace_member_status.dart';
import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/providers/diary_folder_provider.dart';
import 'package:asr_project/providers/user_provider.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:asr_project/widgets/custom_textfield.dart';
import 'package:asr_project/widgets/diary/diary_folder_blocks.dart';
import 'package:asr_project/widgets/workspace/workspace_member_display.dart';
import 'package:asr_project/widgets/workspace_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkspaceDetailPage extends ConsumerStatefulWidget {
  const WorkspaceDetailPage({super.key});

  @override
  ConsumerState<WorkspaceDetailPage> createState() =>
      _WorkspaceDetailPageState();
}

class _WorkspaceDetailPageState extends ConsumerState<WorkspaceDetailPage> {
  // late Workspace workspace;
  late bool creatingFolderMode = false;
  List<DiaryFolderModel> filteredDiaryFolders = [];

  final TextEditingController _searchTextEditingController =
      TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(diaryFoldersProvider.notifier).fetchData();
    });

    // workspace = widget.workspace;
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
    DiaryFolderDetail diaryFolderDetail = DiaryFolderDetail(name: uniqueName);

    String responseMessage = await ref
        .read(diaryFoldersProvider.notifier)
        .createDiaryFolder(diaryFolderDetail);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(responseMessage)),
    );
  }

  void _updateFolderName(String id, String name) async {
    DiaryFolderDetail diaryFolderDetail = DiaryFolderDetail(
      name: name,
    );

    try {
      String responseMessage = await ref
          .read(diaryFoldersProvider.notifier)
          .updateDiaryFolderName(id, diaryFolderDetail);
      log(responseMessage.toString());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(responseMessage)),
      );
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
    DiaryDetail diaryDetail = DiaryDetail.createDiary();
    Diary? diary = await ref
        .read(diaryFoldersProvider.notifier)
        .addDiaryToFolder(folderId, diaryDetail);

    final User? user = ref.watch(userProvider).value;
    final Workspace workspace =
        ref.read(workspaceProvider.notifier).workspaceByIdProvider;

    final bool canEdit = workspace.members.any((member) =>
        member.item1?.id == user?.id &&
        member.item2.permission != WorkspacePermission.viewer);

    if (!mounted) return;
    if (diary != null) {
      Navigator.pushNamed(context, "/diary/detail",
          arguments: {'diary': diary, 'canEdit': canEdit});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to create diary")),
      );
    }
  }

  void _navigatorSetting() async {
    final Workspace workspace =
        ref.read(workspaceProvider.notifier).workspaceByIdProvider;
    Navigator.pushNamed(context, "/workspace/setting", arguments: workspace);
  }

  @override
  Widget build(BuildContext context) {
    final User? user = ref.watch(userProvider).value;
    final AsyncValue workspacesAsync = ref.watch(workspaceProvider);
    late Workspace workspace;
    if (workspacesAsync.hasValue) {
      final List<Workspace> workspaces = workspacesAsync.value!;
      workspace =
          workspaces.firstWhere((ws) => ws.id == ref.read(workspaceIdProvider));
    }

    final AsyncValue diaryFoldersAsync = ref.watch(diaryFoldersProvider);

    final User owner = workspace.members
        .firstWhere(
            (member) => member.item2.permission == WorkspacePermission.owner)
        .item1!;

    final List<User> memberWithoutOwner = workspace.members
        .where((member) =>
            member.item2.permission != WorkspacePermission.owner &&
            member.item2.status == WorkspaceMemberStatus.accepted)
        .map((member) => member.item1!)
        .toList();

    final bool canEdit = workspace.members.any((member) =>
        member.item2.email == user?.email &&
        member.item2.permission != WorkspacePermission.viewer);

    log("canEdit: ${user?.email} $canEdit");

    return Scaffold(
      appBar: AppBar(
        title: Text(workspace.name),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16.0,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 20,
                        children: [
                          WorkspaceIcon(
                            workspaceIconEnum: workspace.icon.iconEnum,
                            colorEnum: workspace.icon.colorEnum,
                            size: 80,
                          ),
                          Expanded(
                            child: SizedBox(
                              height: 85,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    child: Text(
                                      workspace.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineLarge,
                                      softWrap: true,
                                    ),
                                  ),
                                  WorkspaceMemberDisplay(
                                      memberWithoutOwner: memberWithoutOwner,
                                      owner: owner),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (owner.id == AppConfig.userId)
                      IconButton(
                        onPressed: _navigatorSetting,
                        icon: Icon(Icons.edit),
                      )
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description",
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Theme.of(context).colorScheme.tertiary),
                      ),
                      if (workspace.description != null &&
                          workspace.description!.isNotEmpty)
                        Text(
                          workspace.description ?? "",
                          style: Theme.of(context).textTheme.bodyLarge,
                        )
                      else
                        Text(
                          "No Description",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.tertiary)
                              .copyWith(fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
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
                        arguments: canEdit,
                      );
                      _searchFocusNode.unfocus();
                    }),
                diaryFoldersAsync.when(
                  data: (diaryFolders) => DiaryFolderBlocks(
                    canEdit: canEdit,
                    folders: diaryFolders,
                    onCreateFolder: _addFolder,
                    onUpdateFolderName: _updateFolderName,
                    onCreateDiary: _addDiaryInFolder,
                    onDeleteFolder: _deleteFolder,
                    creatingFolderMode: creatingFolderMode,
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator.adaptive()),
                  error: (error, stack) => Center(
                    child: Text("Error loading diary folders: $error"),
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
