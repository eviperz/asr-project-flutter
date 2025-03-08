import 'package:asr_project/models/workspace.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:asr_project/widgets/workspace/workspace_invite_members_by_email_box.dart';
import 'package:asr_project/widgets/workspace/workspace_name_and_description_text_field.dart';
import 'package:asr_project/widgets/workspace_icon.dart';
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
  final TextEditingController _descriptionTextEditingController =
      TextEditingController();
  final List<String> _invitedMemberEmails = [];

  @override
  void initState() {
    super.initState();
    _nameTextEditingController.text = "";
    _descriptionTextEditingController.text = "";
  }

  void _createWorkspace() async {
    if (_nameTextEditingController.text.isNotEmpty) {
      final WorkspaceDetail workspaceDetail = WorkspaceDetail(
        name: _nameTextEditingController.text,
        description: _descriptionTextEditingController.text,
        invitedMemberEmails: _invitedMemberEmails,
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
                  WorkspaceInviteMembersByEmailBox(
                    invitedMemberEmails: _invitedMemberEmails,
                    addEmail: _addInvitedMemberEmails,
                    removeEmail: _removeInvitedMemberEmails,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Theme.of(context).primaryColor),
                        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        )),
                      ),
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
