import 'package:asr_project/models/enum/workspace_member_status.dart';
import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/models/workspace_member.dart';
import 'package:asr_project/providers/user_provider.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:asr_project/widgets/workspace_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkspaceInvitation extends ConsumerStatefulWidget {
  const WorkspaceInvitation({super.key});

  @override
  ConsumerState<WorkspaceInvitation> createState() =>
      _WorkspaceInvitationState();
}

class _WorkspaceInvitationState extends ConsumerState<WorkspaceInvitation> {
  @override
  Widget build(BuildContext context) {
    final User? user = ref.watch(userProvider).value;
    final AsyncValue<List<Workspace>> asyncWorkspaces =
        ref.watch(workspaceProvider);
    return Scaffold(
        appBar: AppBar(
          title: Text("Invitation"),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 20.0, 0, 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Workspace Invitations",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(
                height: 8.0,
              ),
              Expanded(
                child: asyncWorkspaces.when(
                  data: (workspaces) {
                    final List<Workspace> pendingWorkspaces = workspaces
                        .where((workspace) => workspace.members.any((member) =>
                            member.item1?.id == user?.id &&
                            member.item2.status ==
                                WorkspaceMemberStatus.pending))
                        .toList();
                    if (pendingWorkspaces.isEmpty) {
                      return Center(child: Text("No Notification"));
                    }
                    return ListView.separated(
                      itemCount: pendingWorkspaces.length,
                      itemBuilder: (context, index) {
                        final Workspace workspace = pendingWorkspaces[index];
                        final WorkspaceMember workspaceMember =
                            workspace.members
                                .firstWhere(
                                  (member) => member.item1?.id == user?.id,
                                )
                                .item2;
                        final String ownerName = workspace.members
                            .firstWhere((member) =>
                                member.item2.permission ==
                                WorkspacePermission.owner)
                            .item1!
                            .name;

                        return ListTile(
                          leading: WorkspaceIcon(
                            workspaceIconEnum: workspace.icon.iconEnum,
                            colorEnum: workspace.icon.colorEnum,
                          ),
                          title: Text(workspace.name),
                          subtitle: Text(
                              "$ownerName invited you to join this workspace"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () async {
                                  await ref
                                      .read(workspaceProvider.notifier)
                                      .acceptMember(
                                          workspace.id, workspaceMember.id);
                                },
                                icon: Icon(Icons.done),
                              ),
                              IconButton(
                                onPressed: () async {
                                  await ref
                                      .read(workspaceProvider.notifier)
                                      .rejectMember(
                                          workspace.id, workspaceMember.id);
                                },
                                icon: Icon(Icons.close),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (context, index) => Divider(),
                    );
                  },
                  loading: () => Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) =>
                      Center(child: Text("Error loading workspaces")),
                ),
              ),
            ],
          ),
        ));
  }
}
