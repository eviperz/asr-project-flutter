import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/pages/workspace_page/workspace_create_form.dart';
import 'package:asr_project/widgets/workspace/workspace_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkspaceList extends StatelessWidget {
  final List<Workspace> workspaces;
  final Set<String> starredWorkspace;
  final Function(String) toggleStarred;

  const WorkspaceList({
    required this.workspaces,
    required this.starredWorkspace,
    required this.toggleStarred,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "All Workspace",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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
        if (workspaces.isNotEmpty)
          ListView.separated(
            itemCount: workspaces.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final Workspace workspace = workspaces[index];
              return WorkspaceTile(
                workspace: workspace,
                // isStarred: starredWorkspace.contains(workspace.id),
                // toggleStarred: toggleStarred,
              );
            },
            separatorBuilder: (context, index) {
              return Divider();
            },
          )
        else
          Center(child: Text("No Workspace"))
      ],
    );
  }
}
