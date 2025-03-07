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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,
      children: [
        Text(
          "Invite new member",
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          "Emails",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
                color: _checkError
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.tertiary,
                style: BorderStyle.solid),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _focusNode.requestFocus();
              });
            },
            child: Container(
              width: double.maxFinite,
              height: 150,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white10,
              ),
              child: Wrap(spacing: 8.0, children: [
                ..._invitedMemberEmails.map((email) {
                  return Chip(
                    label: Text(email),
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
                    style: Theme.of(context).textTheme.labelLarge,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Email",
                      hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary),
                      labelStyle: Theme.of(context).textTheme.labelMedium,
                    ),
                    onSubmitted: (value) {
                      if (_textEditingController.text.isNotEmpty &&
                          !_checkError) {
                        widget.addEmail(value);

                        setState(() {
                          _invitedMemberEmails.add(value);
                        });
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
                  ),
                ),
              ]),
            ),
          ),
        ),
        _checkError
            ? Text(
                "Please enter Email format",
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              )
            : SizedBox(
                height: 20,
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
