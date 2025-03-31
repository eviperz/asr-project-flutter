import 'package:asr_project/models/enum/workspace_member_status.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/pages/workspace_page/workspace_page/workspace_search_bar.dart';
import 'package:asr_project/providers/user_provider.dart';
import 'package:asr_project/widgets/workspace/workspace_list.dart';
import 'package:asr_project/providers/workspace_provider.dart';
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
    final User? user = ref.watch(userProvider).value;
    final workspacesAsync = ref.watch(workspaceProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Workspace",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              WorkspaceSearchBar(
                searchTextEditingController: _searchTextEditingController,
                searchFocusNode: _searchFocusNode,
              ),
              workspacesAsync.when(
                data: (workspaces) {
                  workspaces = workspaces
                      .where((workspace) => workspace.members.any((member) =>
                          member.item1?.id == user?.id &&
                          member.item2.status ==
                              WorkspaceMemberStatus.accepted))
                      .toList();

                  return Expanded(
                    child: WorkspaceList(
                      workspaces: _filterWorkspace(workspaces),
                      starredWorkspace: starredWorkspace,
                      toggleStarred: _toggleStarredWorkspace,
                    ),
                  );
                },
                loading: () => Expanded(
                    child: const Center(
                        child: CircularProgressIndicator.adaptive())),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
