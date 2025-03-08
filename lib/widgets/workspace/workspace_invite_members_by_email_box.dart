import 'package:asr_project/providers/user_provider.dart';
import 'package:asr_project/providers/workspace_diary_folder_provider%20copy.dart';
import 'package:asr_project/providers/workspace_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkspaceInviteMembersByEmailBox extends ConsumerStatefulWidget {
  final List<String> invitedMemberEmails;
  final Function(String) addEmail;
  final Function(String) removeEmail;
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
  final List<String> _invitedMemberEmails = [];
  final FocusNode _focusNode = FocusNode();
  late bool _checkError = false;

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
        isExistEmails = workspace.members.keys.any(
          (member) => member.email == _textEditingController.text,
        );
      } else {
        isExistEmails = false;
      }
    } else {
      isExistEmails = false;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,
      children: [
        if (widget.inviteByEmails != null)
          Text(
            "Invite member by Email",
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
                color: (_checkError || isCurrentUserEmail || isExistEmails)
                    ? Theme.of(context).colorScheme.error
                    : _focusNode.hasFocus
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.tertiary),
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
                        color:
                            (_checkError || isCurrentUserEmail || isExistEmails)
                                ? Theme.of(context).colorScheme.error
                                : _focusNode.hasFocus
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.secondary,
                      ),
                ),
                Container(
                  width: double.maxFinite,
                  height: 100,
                  decoration: BoxDecoration(),
                  child: Wrap(spacing: 8.0, children: [
                    ..._invitedMemberEmails.map((email) {
                      return Chip(
                        label: Text(email),
                        labelStyle: Theme.of(context)
                            .textTheme
                            .bodyLarge!
                            .copyWith(
                                color: Theme.of(context).colorScheme.onPrimary),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        side: BorderSide(
                            color: Theme.of(context).colorScheme.onPrimary),
                        deleteIconColor:
                            Theme.of(context).colorScheme.onPrimary,
                        onDeleted: () {
                          widget.removeEmail(email);
                          setState(() {
                            _invitedMemberEmails.remove(email);
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
                          labelStyle: Theme.of(context).textTheme.labelMedium,
                        ),
                        onSubmitted: (value) {
                          if (_textEditingController.text.isNotEmpty &&
                              !_checkError &&
                              !isCurrentUserEmail &&
                              !isExistEmails) {
                            widget.addEmail(value);

                            setState(() {
                              _invitedMemberEmails.add(value);
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
              onPressed: () {
                widget.inviteByEmails!();
              },
              child: Text("Invite member"))
      ],
    );
  }
}
