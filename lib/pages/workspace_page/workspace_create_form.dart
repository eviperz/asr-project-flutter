import 'package:asr_project/models/enum/color_platte.dart';
import 'package:asr_project/models/enum/workspace_icon.dart';
import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/models/workspace_icon_model.dart';
import 'package:asr_project/models/workspace_member.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:asr_project/widgets/workspace/workspace_icon_selector.dart';
import 'package:asr_project/widgets/workspace/workspace_invite_members_by_email_box.dart';
import 'package:asr_project/widgets/workspace/workspace_name_and_description_text_field.dart';
import 'package:asr_project/widgets/workspace_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkspaceCreateForm extends ConsumerStatefulWidget {
  const WorkspaceCreateForm({super.key});

  @override
  ConsumerState<WorkspaceCreateForm> createState() =>
      _WorkspaceCreateFormState();
}

class _WorkspaceCreateFormState extends ConsumerState<WorkspaceCreateForm> {
  final TextEditingController _nameTextEditingController =
      TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  final TextEditingController _descriptionTextEditingController =
      TextEditingController();
  final FocusNode _descriptionFocusNode = FocusNode();

  late WorkspaceIconEnum _workspaceIconEnum = WorkspaceIconEnum.business;
  late ColorPalette _workspaceColorEnum = ColorPalette.gray;
  final List<WorkspaceMemberInviting> _invitedMemberEmails = [];

  @override
  void initState() {
    super.initState();
    _nameTextEditingController.addListener(() => setState(() {}));
    _nameFocusNode.addListener(() => setState(() {}));
    _descriptionTextEditingController.addListener(() => setState(() {}));
    _descriptionFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _nameTextEditingController.dispose();
    _descriptionTextEditingController.dispose();
  }

  void _createWorkspace() async {
    if (_nameTextEditingController.text.isNotEmpty) {
      final WorkspaceDetail workspaceDetail = WorkspaceDetail(
        name: _nameTextEditingController.text,
        description: _descriptionTextEditingController.text,
        icon: WorkspaceIconDetail(
          iconEnum: _workspaceIconEnum,
          colorEnum: _workspaceColorEnum,
        ),
        members: _invitedMemberEmails,
      );

      final bool response = await ref
          .read(workspaceProvider.notifier)
          .createWorkspace(workspaceDetail);

      if (!mounted) return;
      if (response) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create workspace")),
        );
      }
    }
  }

  void _addInvitedMemberEmails(
      WorkspaceMemberInviting workspaceMemberInviting) {
    setState(() {
      _invitedMemberEmails.add(workspaceMemberInviting);
    });
  }

  void _removeInvitedMemberEmails(
      WorkspaceMemberInviting workspaceMemberInviting) {
    setState(() {
      _invitedMemberEmails.remove(workspaceMemberInviting);
    });
  }

  void _selectWorkspaceIcon(
      WorkspaceIconEnum iconEnum, ColorPalette colorEnum) {
    setState(() {
      _workspaceIconEnum = iconEnum;
      _workspaceColorEnum = colorEnum;
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
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.close),
            ),
            title: Text(
              "Create Workspace",
            ),
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
                            colorEnum: _workspaceColorEnum),
                        TextButton(
                            onPressed: () async {
                              final result = await showCupertinoModalPopup<
                                  Map<String, dynamic>>(
                                context: context,
                                builder: (context) => WorkspaceIconSelector(
                                  workspaceIconEnum: _workspaceIconEnum,
                                  workspaceIconColorEnum: _workspaceColorEnum,
                                ),
                              );

                              if (result != null) {
                                _selectWorkspaceIcon(
                                  result['iconEnum'] as WorkspaceIconEnum,
                                  result['colorEnum'] as ColorPalette,
                                );
                              }
                            },
                            child: Text(
                              "Change Icon",
                            ))
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
                  WorkspaceInviteMembersByEmailBox(
                    invitedMemberEmails: _invitedMemberEmails,
                    addEmail: _addInvitedMemberEmails,
                    removeEmail: _removeInvitedMemberEmails,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _createWorkspace();
                      },
                      child:
                          Text("Create", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
