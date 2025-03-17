import 'package:asr_project/models/enum/workspace_member_status.dart';
import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/providers/workspace_provider.dart';
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

    return Column(
      children: [
        ListTile(
          onTap: () {
            ref.read(workspaceIdProvider.notifier).state = workspace.id;
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
