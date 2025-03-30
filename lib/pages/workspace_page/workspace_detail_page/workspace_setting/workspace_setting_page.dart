import 'package:asr_project/models/enum/color_platte.dart';
import 'package:asr_project/models/enum/workspace_icon.dart';
import 'package:asr_project/models/enum/workspace_member_status.dart';
import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/models/workspace_icon_model.dart';
import 'package:asr_project/models/workspace_member.dart';
import 'package:asr_project/widgets/custom_dialog.dart';
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
import 'package:tuple/tuple.dart';

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
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  final TextEditingController _descriptionTextEditingController =
      TextEditingController();
  final FocusNode _descriptionFocusNode = FocusNode();

  late List<Tuple2<User?, WorkspaceMember>> _members = [];
  final List<WorkspaceMemberInviting> _invitedMemberEmails = [];
  late WorkspaceIconEnum _workspaceIconEnum;
  late ColorPalette _colorEnum;

  @override
  void initState() {
    super.initState();
    _nameTextEditingController.text = widget.workspace.name;
    _descriptionTextEditingController.text = widget.workspace.description ?? "";
    _members = widget.workspace.members;
    _workspaceIconEnum = widget.workspace.icon.iconEnum;
    _colorEnum = widget.workspace.icon.colorEnum;

    _nameFocusNode.addListener(() {
      setState(() {});
      if (!_nameFocusNode.hasFocus) {
        _updateWorkspaceName(_nameTextEditingController.text.trim());
      }
    });

    _descriptionFocusNode.addListener(() {
      setState(() {});
      if (!_descriptionFocusNode.hasFocus) {
        _updateWorkspaceDescription(
            _descriptionTextEditingController.text.trim());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameTextEditingController.dispose();
    _nameFocusNode.dispose();
    _descriptionTextEditingController.dispose();
    _descriptionFocusNode.dispose();
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

  void _addInvitedMemberEmails(WorkspaceMemberInviting email) {
    setState(() {
      _invitedMemberEmails.add(email);
    });
  }

  void _removeInvitedMemberEmails(WorkspaceMemberInviting email) {
    setState(() {
      _invitedMemberEmails.remove(email);
    });
  }

  void _inviteByEmails() async {
    final Workspace? workspace = await ref
        .read(workspaceProvider.notifier)
        .inviteMembers(widget.workspace.id, _invitedMemberEmails);

    if (!mounted) return;

    if (workspace != null) {
      setState(() {
        _members = workspace.members;
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
    });
  }

  void _removeMember(String workspaceMemberId) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: "Remove Member",
          content:
              "Are you sure you want to remove this member from the workspace?",
          confirmLabel: "Remove",
          cancelLabel: "Cancel",
          onConfirm: () {
            Navigator.pop(context, true);
          },
          onCancel: () {
            Navigator.pop(context, false);
          },
        );
      },
    );

    if (confirmDelete == true) {
      await ref
          .read(workspaceProvider.notifier)
          .removeMember(widget.workspace.id, workspaceMemberId);

      setState(() {
        _members = _members
            .where((member) => member.item2.id != workspaceMemberId)
            .toList();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Member removed successfully")),
      );
    }
  }

  void _updatePermission(
      String workspaceMemberId, WorkspacePermission permission) async {
    List<Tuple2<User?, WorkspaceMember>>? members = await ref
        .read(workspaceProvider.notifier)
        .updatePermission(widget.workspace.id, workspaceMemberId, permission);

    if (!mounted) return;
    if (members != null) {
      setState(() {
        _members = members;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update permission")),
      );
    }
  }

  void _deleteWorkspace() async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomDialog(
          title: "Delete Workspace",
          content:
              "Are you sure you want to delete this workspace? This action cannot be undone.",
          confirmLabel: "Delete",
          cancelLabel: "Cancel",
          onConfirm: () {
            Navigator.pop(context, true);
          },
          onCancel: () {
            Navigator.pop(context, false);
          },
        );
      },
    );

    if (confirmDelete == true) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text("Workspace Setting"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            spacing: 8.0,
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
                nameFocusNode: _nameFocusNode,
                descriptionTextEditingController:
                    _descriptionTextEditingController,
                descriptionFocusNode: _descriptionFocusNode,
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
                        icon: Icon(Icons.add),
                      )
                    ],
                  ),
                  ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: _members.length,
                      itemBuilder: (context, index) {
                        final User? user = _members[index].item1;
                        final WorkspaceMember workspaceMember =
                            _members[index].item2;
                        return ListTile(
                          titleAlignment: ListTileTitleAlignment.top,
                          leading: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ProfileImage(
                                profile: user?.getProfile(), size: 45),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 4.0,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Text(
                                  workspaceMember.status ==
                                          WorkspaceMemberStatus.accepted
                                      ? user!.name
                                      : workspaceMember.email,
                                ),
                              ),
                              workspaceMember.status ==
                                      WorkspaceMemberStatus.pending
                                  ? Text(
                                      "Pending",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary),
                                    )
                                  : Text(
                                      workspaceMember.permission ==
                                              WorkspacePermission.owner
                                          ? "Owner"
                                          : "Member",
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .tertiary),
                                    ),
                            ],
                          ),
                          subtitle: workspaceMember.permission !=
                                  WorkspacePermission.owner
                              ? Container(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTapDown: (TapDownDetails details) =>
                                        _updatePermission(
                                            workspaceMember.id,
                                            workspaceMember.permission ==
                                                    WorkspacePermission.viewer
                                                ? WorkspacePermission.editor
                                                : WorkspacePermission.viewer),
                                    child: Chip(
                                      padding: EdgeInsets.all(4.0),
                                      label: SizedBox(
                                        width: 70,
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                WorkspacePermission
                                                    .toStringWorkspacePermission(
                                                        workspaceMember
                                                            .permission),
                                              ),
                                              if (workspaceMember.permission !=
                                                  WorkspacePermission.owner)
                                                Icon(
                                                  Icons
                                                      .arrow_drop_down_outlined,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  size: 18,
                                                )
                                            ]),
                                      ),
                                      labelStyle: Theme.of(context)
                                          .textTheme
                                          .labelSmall!
                                          .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary),
                                    ),
                                  ),
                                )
                              : null,
                          trailing: workspaceMember.permission !=
                                  WorkspacePermission.owner
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _removeMember(workspaceMember.id);
                                      },
                                      icon: Icon(
                                        Icons.person_remove,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                )
                              : null,
                          contentPadding: EdgeInsets.only(right: 0, bottom: 10),
                        );
                      },
                      separatorBuilder: (context, index) => const Divider()),
                ],
              ),
              Container(
                padding: EdgeInsets.all(4.0),
                width: double.maxFinite,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
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
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.onError),
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
