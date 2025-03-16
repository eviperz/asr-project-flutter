import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/pages/workspace_page/starred_workspace_list.dart';
import 'package:asr_project/pages/workspace_page/workspace_create_form.dart';
import 'package:asr_project/providers/user_provider.dart';
import 'package:asr_project/widgets/custom_drawer.dart';
import 'package:asr_project/widgets/custom_textfield.dart';
import 'package:asr_project/widgets/workspace/workspace_list.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkspacePage extends ConsumerStatefulWidget {
  const WorkspacePage({super.key});

  @override
  ConsumerState<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends ConsumerState<WorkspacePage> {
  final TextEditingController _searchTextEditingController =
      TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Set<String> starredWorkspace = {};

  @override
  void initState() {
    super.initState();
    _searchTextEditingController.addListener(() => setState(() {}));
    _searchFocusNode.addListener(() => setState(() {}));

    Future.microtask(() {
      ref.read(workspaceProvider.notifier).fetchData();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextEditingController.dispose();
    _searchFocusNode.dispose();
  }

  List<Workspace> _filterWorkspace(List<Workspace> workspaces) {
    List<Workspace> filtered = workspaces.where((workspace) {
      bool matchesSearch = _searchTextEditingController.text.isEmpty ||
          workspace.name
              .toLowerCase()
              .contains(_searchTextEditingController.text.toLowerCase().trim());

      return matchesSearch;
    }).toList();
    return filtered;
  }

  void _toggleStarredWorkspace(String id) {
    setState(() {
      if (starredWorkspace.contains(id)) {
        starredWorkspace.remove(id);
      } else {
        starredWorkspace.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final workspacesAsync = ref.watch(workspaceProvider);
    final User? user = ref.watch(userProvider).value;

    return Scaffold(
      drawer: CustomDrawer(name: user?.name ?? "Guest"),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () => showCupertinoModalPopup(
              context: context,
              barrierDismissible: true,
              builder: (_) => WorkspaceCreateForm(),
            ),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Workspace",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: CustomTextfield(
                  hintText: "Search Workspace",
                  keyboardType: TextInputType.text,
                  textEditController: _searchTextEditingController,
                  focusNode: _searchFocusNode,
                  canClear: true,
                  iconData: Icons.search,
                ),
              ),
              workspacesAsync.when(
                data: (workspaces) => Column(
                  children: [
                    if (starredWorkspace.isNotEmpty)
                      StarredWorkspaceList(
                        workspaces: workspaces,
                        starredWorkspace: starredWorkspace,
                        toggleStarred: _toggleStarredWorkspace,
                      ),
                    WorkspaceList(
                      workspaces: _filterWorkspace(workspaces),
                      starredWorkspace: starredWorkspace,
                      toggleStarred: _toggleStarredWorkspace,
                    ),
                  ],
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
