import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';import 'package:asr_project/widgets/profile_image.dart';
import 'package:asr_project/widgets/workspace_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkspaceTile extends ConsumerWidget {
  final Workspace workspace;
  final bool isStarred;
  final Function(String) toggleStarred;

  const WorkspaceTile({
    super.key,
    required this.workspace,
    required this.isStarred,
    required this.toggleStarred,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User owner = workspace.members.entries
        .firstWhere((entry) => entry.value == WorkspacePermission.owner)
        .key;

    final List<User> memberWithoutOwner = Map.fromEntries(
      workspace.members.entries.where((entry) => entry.key != owner),
    ).keys.toList();

    return Column(
      children: [
        ListTile(
          onTap: () {
            Navigator.pushNamed(
              context,
              "/workspace/detail",
              arguments: workspace,
            );
          },
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
                  if (memberWithoutOwner.length > 1)
                    Positioned(
                      left: 60,
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(24.0)),
                        child: ProfileImage(
                          profile: memberWithoutOwner[1].profile,
                        ),
                      ),
                    ),
                  if (memberWithoutOwner.isNotEmpty)
                    Positioned(
                      left: 30,
                      child: Container(
                        padding: EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(24.0)),
                        child: ProfileImage(
                          profile: memberWithoutOwner[0].profile,
                        ),
                      ),
                    ),
                  Container(
                    padding: EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(24.0)),
                    child: ProfileImage(
                      profile: owner.profile,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 8.0,
            ),
            if (memberWithoutOwner.length > 2)
              Text("+ ${memberWithoutOwner.length - 2}")
          ]),
          trailing: IconButton(
            onPressed: () {
              toggleStarred(workspace.id);
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
