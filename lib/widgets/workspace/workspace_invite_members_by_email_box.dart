import 'package:asr_project/models/enum/workspace_permission.dart';
import 'package:asr_project/models/workspace_member.dart';
import 'package:asr_project/providers/user_provider.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkspaceInviteMembersByEmailBox extends ConsumerStatefulWidget {
  final List<WorkspaceMemberInviting> invitedMemberEmails;
  final Function(WorkspaceMemberInviting) addEmail;
  final Function(WorkspaceMemberInviting) removeEmail;
  final Function? inviteByEmails;
  const WorkspaceInviteMembersByEmailBox({
    super.key,
    required this.invitedMemberEmails,
    required this.addEmail,
    required this.removeEmail,
    this.inviteByEmails,
  });

  @override
  ConsumerState<WorkspaceInviteMembersByEmailBox> createState() =>
      _WorkspaceAddModalState();
}

class _WorkspaceAddModalState
    extends ConsumerState<WorkspaceInviteMembersByEmailBox> {
  final TextEditingController _textEditingController = TextEditingController();
  final List<WorkspaceMemberInviting> _invitedMemberEmails = [];
  final FocusNode _focusNode = FocusNode();
  late bool _checkError = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _invitedMemberEmails.addAll(widget.invitedMemberEmails);
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  void _validateEmail(String? value) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (value != null && emailRegex.hasMatch(value)) {
      setState(() {
        _checkError = false;
      });
      return;
    }
    setState(() {
      _checkError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isCurrentUserEmail =
        ref.watch(userProvider).value?.email == _textEditingController.text;

    late bool isExistEmails;
    if (widget.inviteByEmails != null) {
      var workspace = ref.watch(workspaceProvider).value?.firstWhere(
            (workspace) => workspace.id == ref.watch(workspaceIdProvider),
          );

      if (workspace != null) {
        isExistEmails = workspace.members
            .any((member) => member.item2.email == _textEditingController.text);
      } else {
        isExistEmails = false;
      }
    } else {
      isExistEmails = false;
    }

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 8.0,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _focusNode.requestFocus();
                  });
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Invite Emails",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: (_checkError ||
                                    isCurrentUserEmail ||
                                    isExistEmails)
                                ? Theme.of(context).colorScheme.error
                                : _focusNode.hasFocus
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSecondary,
                          ),
                    ),
                    Container(
                      width: double.maxFinite,
                      height: 100,
                      decoration: BoxDecoration(),
                      child: Wrap(spacing: 8.0, children: [
                        ..._invitedMemberEmails.map((workspaceMemberInviting) {
                          return Chip(
                            label: Text(workspaceMemberInviting.email),
                            onDeleted: () {
                              widget.removeEmail(workspaceMemberInviting);
                              setState(() {
                                _invitedMemberEmails
                                    .remove(workspaceMemberInviting);
                              });
                            },
                          );
                        }),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _textEditingController,
                            focusNode: _focusNode,
                            autocorrect: false,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Enter Email",
                              hintStyle: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              labelStyle:
                                  Theme.of(context).textTheme.labelMedium,
                            ),
                            onSubmitted: (value) {
                              if (_textEditingController.text.isNotEmpty &&
                                  !_checkError &&
                                  !isCurrentUserEmail &&
                                  !isExistEmails) {
                                WorkspaceMemberInviting
                                    workspaceMemberInviting =
                                    WorkspaceMemberInviting(
                                  email: value,
                                  permission: WorkspacePermission.viewer,
                                );
                                widget.addEmail(workspaceMemberInviting);

                                setState(() {
                                  _invitedMemberEmails
                                      .add(workspaceMemberInviting);
                                });

                                _focusNode.requestFocus();
                                _textEditingController.clear();
                              }
                            },
                            onChanged: (value) {
                              if (value.isEmpty) {
                                setState(() {
                                  _checkError = false;
                                });
                              } else {
                                _validateEmail(value);
                              }
                            },
                            onTapOutside: (event) {
                              _focusNode.unfocus();
                            },
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
              child: (_checkError || isCurrentUserEmail || isExistEmails)
                  ? Text(
                      _checkError
                          ? "Please enter Email format"
                          : isCurrentUserEmail
                              ? "Please don't enter your email"
                              : "Already has this email",
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium!
                          .copyWith(color: Theme.of(context).colorScheme.error),
                    )
                  : null,
            ),
            if (widget.inviteByEmails != null)
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const UploadingDialog();
                    },
                  );

                  await widget.inviteByEmails!();

                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const UploadSuccessDialog();
                    },
                  );
                },
                child: Text("Invite member"),
              ),
          ],
        ),

        // Centered Loading Indicator (if needed)
        if (_isLoading)
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
      ],
    );
  }
}

class UploadingDialog extends StatelessWidget {
  const UploadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text("Uploading..."),
        ],
      ),
    );
  }
}

//  Upload Success Dialog
class UploadSuccessDialog extends StatelessWidget {
  const UploadSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, color: Colors.green, size: 50),
          SizedBox(height: 10),
          Text("Invite Complete!"),
        ],
      ),
    );
  }
}
