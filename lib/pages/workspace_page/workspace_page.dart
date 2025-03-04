import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/pages/workspace_page/starred_workspace_list.dart';
import 'package:asr_project/pages/workspace_page/workspace_list.dart';
import 'package:flutter/material.dart';

class WorkspacePage extends StatefulWidget {
  const WorkspacePage({super.key});

  @override
  State<WorkspacePage> createState() => _WorkspacePageState();
}

class _WorkspacePageState extends State<WorkspacePage> {
  final TextEditingController _controller = TextEditingController();
  List<Workspace> workspaces = [
    // Workspace(name: "name1", owner: User(username: "username1")),
    // Workspace(
    //   name: "name2",
    //   owner: User(username: "username2"),
    //   users: [
    //     User(username: "username4"),
    //     User(username: "username5"),
    //   ],
    // ),
    // Workspace(
    //   name: "Project X",
    //   owner: User(username: "username3"),
    //   users: [
    //     User(username: "username4"),
    //     User(username: "username5"),
    //     User(username: "username6"),
    //     User(username: "username7"),
    //   ],
    // ),
  ];
  List<Workspace> filteredWorkspaces = [];
  Set<String> starredWorkspace = {};

  @override
  void initState() {
    super.initState();
    filteredWorkspaces = workspaces;
  }

  void _filterWorkspaces(String value) {
    setState(() {
      filteredWorkspaces = workspaces
          .where((workspace) =>
              workspace.name.toLowerCase().contains(value.trim().toLowerCase()))
          .toList();
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
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                workspaces: filteredWorkspaces,
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
