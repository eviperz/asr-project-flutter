import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/widgets/profile_image.dart';
import 'package:asr_project/widgets/workspace_icon.dart';
import 'package:flutter/material.dart';

class WorkspaceTile extends StatelessWidget {
  final Workspace workspace;
  final bool isStarred;
  final Function(String) toggleStarred;

  const WorkspaceTile({
    required this.workspace,
    required this.isStarred,
    required this.toggleStarred,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () => Navigator.pushNamed(
            context,
            "/workspace/detail",
            arguments: workspace,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          leading: WorkspaceIcon(),
          title: Text(workspace.name),
          subtitle: Row(children: [
            SizedBox(
              width: 105,
              child: Stack(
                children: [
                  if (workspace.users.length > 1)
                    Positioned(
                      left: 60,
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(24.0)),
                        child: ProfileImage(
                          profile: workspace.users[1].profile,
                        ),
                      ),
                    ),
                  if (workspace.users.isNotEmpty)
                    Positioned(
                      left: 30,
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(24.0)),
                        child: ProfileImage(
                          profile: workspace.users[0].profile,
                        ),
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(24.0)),
                    child: ProfileImage(
                      profile: workspace.owner.profile,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 8.0,
            ),
            if (workspace.users.length > 2)
              Text("+ ${workspace.users.length - 2}")
          ]),
          trailing: IconButton(
            onPressed: () {
              toggleStarred(workspace.id!);
            },
            icon: Icon(
              isStarred ? Icons.star : Icons.star_border,
              color: isStarred ? Colors.amber : null,
            ),
          ),
        ),
      ],
    );
  }
}
