import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/pages/workspace_page/workspace_tile.dart';
import 'package:flutter/material.dart';

class StarredWorkspaceList extends StatelessWidget {
  final List<Workspace> workspaces;
  final Set<String> starredWorkspace;
  final Function(String) toggleStarred;

  const StarredWorkspaceList({
    required this.workspaces,
    required this.starredWorkspace,
    required this.toggleStarred,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Starred",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        SizedBox(height: 8.0),
        ListView.builder(
          itemCount: starredWorkspace.length,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final String starredId = starredWorkspace.elementAt(index);
            final Workspace workspace = workspaces.firstWhere(
              (workspace) => workspace.id == starredId,
            );

            return WorkspaceTile(
              workspace: workspace,
              isStarred: true,
              toggleStarred: toggleStarred,
            );
          },
        ),
      ],
    );
  }
}
