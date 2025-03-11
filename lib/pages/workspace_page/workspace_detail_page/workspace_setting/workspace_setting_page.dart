import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/widgets/workspace/workspace_invite_members_by_email_box.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:asr_project/widgets/default_modal.dart';
import 'package:asr_project/widgets/profile_image.dart';
import 'package:asr_project/widgets/workspace/workspace_name_and_description_text_field.dart';
import 'package:asr_project/widgets/workspace_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkspaceSettingPage extends ConsumerStatefulWidget {
  final Workspace workspace;

  const WorkspaceSettingPage({
    super.key,
    required this.workspace,
  });

  @override
  ConsumerState<WorkspaceSettingPage> createState() =>
      _WorkspaceSettingPageState();
}

class _WorkspaceSettingPageState extends ConsumerState<WorkspaceSettingPage> {
  late Workspace _workspace;
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _descriptionTextEditingController =
      TextEditingController();
  final List<String> _invitedMemberEmails = [];
  late final User _owner;
  late Map<User, WorkspacePermission> _memberWithoutOwner;

  @override
  void initState() {
    super.initState();
    _workspace = widget.workspace;
    _nameTextEditingController.text = _workspace.name;
    _descriptionTextEditingController.text = _workspace.description ?? "";
    _owner = _workspace.members.entries
        .firstWhere((entry) => entry.value == WorkspacePermission.owner)
        .key;
    _memberWithoutOwner = Map.fromEntries(
      _workspace.members.entries.where((entry) => entry.key != _owner),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _nameTextEditingController.dispose();
    _descriptionTextEditingController.dispose();
  }

  void _updateWorkspace() async {
    final WorkspaceDetail workspaceDetail = WorkspaceDetail(
      name: _nameTextEditingController.text.isEmpty
          ? widget.workspace.name
          : _nameTextEditingController.text,
      description: _descriptionTextEditingController.text,
      members: _workspace.members,
    );

    final Workspace? updatedWorkspace = await ref
        .read(workspaceProvider.notifier)
        .updateWorkspace(widget.workspace.id, workspaceDetail);

    if (!mounted) return;
    if (updatedWorkspace != null) {
      Navigator.pop(context, updatedWorkspace);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update workspace")),
      );
    }
  }

  void _addInvitedMemberEmails(String email) {
    setState(() {
      _invitedMemberEmails.add(email);
    });
  }

  void _removeInvitedMemberEmails(String email) {
    setState(() {
      _invitedMemberEmails.remove(email);
    });
  }

  void _inviteByEmails() async {
    final WorkspaceDetail emails =
        WorkspaceDetail(invitedMemberEmails: _invitedMemberEmails);
    final Workspace? workspace = await ref
        .read(workspaceProvider.notifier)
        .updateWorkspace(_workspace.id, emails);

    if (!mounted) return;
    if (workspace != null) {
      setState(() {
        _workspace = (ref.watch(workspaceProvider).value ?? []).firstWhere(
          (workspace) => workspace.id == widget.workspace.id,
        );
        _memberWithoutOwner = Map.fromEntries(
          _workspace.members.entries.where((entry) => entry.key != _owner),
        );
      });

      _invitedMemberEmails.clear();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to invite members by email")),
      );
    }
  }

  void _deleteWorkspace() async {
    final bool response = await ref
        .read(workspaceProvider.notifier)
        .deleteWorkspace(_workspace.id);

    if (!mounted) return;
    if (response) {
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete workspace")),
      );
    }
  }

  void _removeMember(User user) {
    setState(() {
      _workspace.members.remove(user);
      _memberWithoutOwner.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: () {
                _updateWorkspace();
              },
            ),
            title: Text("Workspace Setting"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                spacing: 16.0,
                children: [
                  SizedBox(
                    height: 150,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        WorkspaceIcon(),
                        TextButton(
                            onPressed: () {},
                            child: Text(
                              "Change Icon",
                            ))
                      ],
                    ),
                  ),
                  WorkspaceNameAndDescriptionTextField(
                    nameTextEditingController: _nameTextEditingController,
                    descriptionTextEditingController:
                        _descriptionTextEditingController,
                    reload: () {
                      setState(() {});
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Users",
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          IconButton(
                              onPressed: () {
                                showCupertinoModalPopup(
                                    context: context,
                                    builder: (context) {
                                      return DefaultModal(
                                        title: "Invite Member Emails",
                                        child: WorkspaceInviteMembersByEmailBox(
                                          invitedMemberEmails:
                                              _invitedMemberEmails,
                                          addEmail: _addInvitedMemberEmails,
                                          removeEmail:
                                              _removeInvitedMemberEmails,
                                          inviteByEmails: _inviteByEmails,
                                        ),
                                      );
                                    });
                              },
                              icon: Icon(Icons.add))
                        ],
                      ),
                      SizedBox(
                        height: 150,
                        child: ListView.separated(
                            itemCount: _workspace.members.length,
                            itemBuilder: (context, index) {
                              final User user =
                                  [_owner, ..._memberWithoutOwner.keys][index];
                              return ListTile(
                                leading: ProfileImage(),
                                title: Text(user.name),
                                subtitle: Container(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTapDown: (TapDownDetails details) async {
                                      if (_owner.id != user.id) {
                                        setState(() {
                                          _memberWithoutOwner[user] =
                                              _memberWithoutOwner[user] ==
                                                      WorkspacePermission.viewer
                                                  ? WorkspacePermission.editor
                                                  : WorkspacePermission.viewer;

                                          _workspace.members[user] =
                                              _workspace.members[user] ==
                                                      WorkspacePermission.viewer
                                                  ? WorkspacePermission.editor
                                                  : WorkspacePermission.viewer;
                                        });
                                      }
                                    },
                                    child: Chip(
                                      padding: EdgeInsets.all(4.0),
                                      label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              permissionToString(
                                                  _workspace.members[user]!),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelSmall,
                                            ),
                                            if (_owner.id != user.id)
                                              Icon(
                                                Icons.arrow_drop_down_outlined,
                                                size: 18,
                                              )
                                          ]),
                                    ),
                                  ),
                                ),
                                trailing: IconButton(
                                  onPressed: () {
                                    _removeMember(user);
                                  },
                                  icon: Icon(Icons.remove),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) =>
                                const Divider()),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.all(4.0),
                    width: double.maxFinite,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        _deleteWorkspace();
                      },
                      child: Text(
                        "Delete Workspace",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
