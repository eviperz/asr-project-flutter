import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/pages/workspace_page/starred_workspace_list.dart';
import 'package:asr_project/pages/workspace_page/workspace_create_form.dart';
import 'package:asr_project/widgets/workspace/workspace_list.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class WorkspacePage extends ConsumerStatefulWidget with RouteAware {
  const WorkspacePage({super.key});

  @override
  ConsumerState<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends ConsumerState<WorkspacePage> {
  final TextEditingController _controller = TextEditingController();
  // List<Workspace> filteredWorkspaces = [];
  Set<String> starredWorkspace = {};

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      _filterWorkspaces(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterWorkspaces(String value) {
    final allWorkspaces = ref.read(workspaceProvider).value ?? [];
    setState(() {
      // filteredWorkspaces = allWorkspaces
      //     .where((workspace) =>
      //         workspace.name.toLowerCase().contains(value.trim().toLowerCase()))
      //     .toList();
    });
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
    final List<Workspace> workspaces = ref.watch(workspaceProvider).value ?? [];
    // filteredWorkspaces =
    //     filteredWorkspaces.isEmpty ? workspaces : filteredWorkspaces;

    return Scaffold(
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
            spacing: 16.0,
            children: [
              Text(
                "Workspace",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  hintText: "Search Workspace",
                ),
                controller: _controller,
                onChanged: _filterWorkspaces,
              ),
              if (starredWorkspace.isNotEmpty)
                StarredWorkspaceList(
                  workspaces: workspaces,
                  starredWorkspace: starredWorkspace,
                  toggleStarred: _toggleStarredWorkspace,
                ),
              WorkspaceList(
                // workspaces: filteredWorkspaces,
                workspaces: workspaces,
                starredWorkspace: starredWorkspace,
                toggleStarred: _toggleStarredWorkspace,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
