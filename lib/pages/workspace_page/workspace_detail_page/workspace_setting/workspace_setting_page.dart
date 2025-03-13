import 'package:asr_project/models/enum/color_platte.dart';
import 'package:asr_project/models/enum/workspace_icon.dart';
import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/models/workspace_icon_model.dart';
import 'package:asr_project/widgets/workspace/workspace_icon_selector.dart';
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
  // late Workspace _workspace;
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final TextEditingController _descriptionTextEditingController =
      TextEditingController();
  final List<String> _invitedMemberEmails = [];
  late final User _owner;
  late Map<User, WorkspacePermission> _memberWithoutOwner;
  late WorkspaceIconEnum _workspaceIconEnum;
  late ColorPalette _colorEnum;
  late bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    _nameTextEditingController.text = widget.workspace.name;
    _descriptionTextEditingController.text = widget.workspace.description ?? "";
    _owner = widget.workspace.members.entries
        .firstWhere((entry) => entry.value == WorkspacePermission.owner)
        .key;
    _memberWithoutOwner = Map.fromEntries(
      widget.workspace.members.entries.where((entry) => entry.key != _owner),
    );
    _workspaceIconEnum = widget.workspace.icon.iconEnum;
    _colorEnum = widget.workspace.icon.colorEnum;
  }

  @override
  void dispose() {
    super.dispose();
    _nameTextEditingController.dispose();
    _descriptionTextEditingController.dispose();
  }

  void _updateWorkspace(WorkspaceDetail workspaceDetail) async {
    final Workspace? updatedWorkspace = await ref
        .read(workspaceProvider.notifier)
        .updateWorkspace(widget.workspace.id, workspaceDetail);

    if (!mounted) return;
    if (updatedWorkspace == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update workspace")),
      );
    } else {
      setState(() {
        _isEdit = true;
      });
    }
  }

  void _updateWorkspaceName(String name) {
    if (name.isNotEmpty) {
      final WorkspaceDetail workspaceDetail = WorkspaceDetail(
        name: name.isEmpty ? widget.workspace.name : name,
      );

      _updateWorkspace(workspaceDetail);
    }
  }

  void _updateWorkspaceDescription(String description) {
    final WorkspaceDetail workspaceDetail = WorkspaceDetail(
      description: description,
    );

    _updateWorkspace(workspaceDetail);
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
        .updateWorkspace(widget.workspace.id, emails);

    if (!mounted) return;
    if (workspace != null) {
      setState(() {
        _memberWithoutOwner = Map.fromEntries(
          workspace.members.entries.where((entry) => entry.key != _owner),
        );
        _isEdit = true;
      });

      _invitedMemberEmails.clear();
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to invite members by email")),
      );
    }
  }

  void _selectWorkspaceIcon(
      WorkspaceIconEnum iconEnum, ColorPalette colorEnum) {
    setState(() {
      _workspaceIconEnum = iconEnum;
      _colorEnum = colorEnum;
      _isEdit = true;
    });
  }

  void _removeMember(User user) async {
    await ref
        .read(workspaceProvider.notifier)
        .removeMember(widget.workspace.id, {"removedUserId": user.id});
    setState(() {
      _memberWithoutOwner.remove(user);
      _isEdit = true;
    });
  }

  void _updateMember(User user) {
    if (_owner.id != user.id) {
      WorkspaceDetail workspaceDetail =
          WorkspaceDetail(members: _memberWithoutOwner);
      _updateWorkspace(workspaceDetail);
    }
  }

  void _deleteWorkspace() async {
    final bool response = await ref
        .read(workspaceProvider.notifier)
        .deleteWorkspace(widget.workspace.id);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => Navigator.pop(context, _isEdit),
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
                    WorkspaceIcon(
                      workspaceIconEnum: _workspaceIconEnum,
                      colorEnum: _colorEnum,
                    ),
                    TextButton(
                      onPressed: () async {
                        final result =
                            await showCupertinoModalPopup<Map<String, dynamic>>(
                          context: context,
                          builder: (context) => WorkspaceIconSelector(
                            workspaceIconEnum: _workspaceIconEnum,
                            workspaceIconColorEnum: _colorEnum,
                          ),
                        );

                        if (result != null) {
                          _selectWorkspaceIcon(
                            result['iconEnum'] as WorkspaceIconEnum,
                            result['colorEnum'] as ColorPalette,
                          );

                          final WorkspaceDetail workspaceDetail =
                              WorkspaceDetail(
                            icon: WorkspaceIconDetail(
                              iconEnum: _workspaceIconEnum,
                              colorEnum: _colorEnum,
                            ),
                          );

                          _updateWorkspace(workspaceDetail);
                        }
                      },
                      child: Text("Change Icon"),
                    )
                  ],
                ),
              ),
              WorkspaceNameAndDescriptionTextField(
                nameTextEditingController: _nameTextEditingController,
                descriptionTextEditingController:
                    _descriptionTextEditingController,
                updateName: _updateWorkspaceName,
                updateDescription: _updateWorkspaceDescription,
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
                                      invitedMemberEmails: _invitedMemberEmails,
                                      addEmail: _addInvitedMemberEmails,
                                      removeEmail: _removeInvitedMemberEmails,
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
                        itemCount: _memberWithoutOwner.length + 1,
                        itemBuilder: (context, index) {
                          final User user =
                              [_owner, ..._memberWithoutOwner.keys][index];
                          return ListTile(
                            leading: ProfileImage(),
                            title: Text(user.name),
                            subtitle: Container(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTapDown: (TapDownDetails details) =>
                                    _updateMember(user),
                                child: Chip(
                                  padding: EdgeInsets.all(4.0),
                                  label: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          permissionToString(user.id ==
                                                  _owner.id
                                              ? WorkspacePermission.owner
                                              : _memberWithoutOwner[user] ??
                                                  WorkspacePermission.viewer),
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
                            trailing: _owner.id != user.id
                                ? IconButton(
                                    onPressed: () {
                                      _removeMember(user);
                                    },
                                    icon: Icon(Icons.remove),
                                  )
                                : null,
                          );
                        },
                        separatorBuilder: (context, index) => const Divider()),
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
    );
  }
}
