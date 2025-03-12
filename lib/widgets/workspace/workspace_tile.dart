import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/widgets/workspace/workspace_member_display.dart';
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
          leading: WorkspaceIcon(
            workspaceIconEnum: workspace.icon.iconEnum,
            colorEnum: workspace.icon.colorEnum,
          ),
          title: Text(workspace.name),
          subtitle: WorkspaceMemberDisplay(
              memberWithoutOwner: memberWithoutOwner, owner: owner),
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
