import 'package:flutter/material.dart';

class WorkspaceNameAndDescriptionTextField extends StatefulWidget {
  final TextEditingController nameTextEditingController;
  final TextEditingController descriptionTextEditingController;
  final Function(String)? updateName;
  final Function(String)? updateDescription;
  final Function reload;

  const WorkspaceNameAndDescriptionTextField({
    super.key,
    required this.nameTextEditingController,
    required this.descriptionTextEditingController,
    this.updateName,
    this.updateDescription,
    required this.reload,
  });

  @override
  State<WorkspaceNameAndDescriptionTextField> createState() =>
      _WorkspaceNameAndDescriptionTextFieldState();
}

class _WorkspaceNameAndDescriptionTextFieldState
    extends State<WorkspaceNameAndDescriptionTextField> {
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _descriptionFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _nameFocusNode.addListener(() {
      setState(() {});
      if (!_nameFocusNode.hasFocus && widget.updateName != null) {
        widget.updateName!(widget.nameTextEditingController.text.trim());
      }
    });

    _descriptionFocusNode.addListener(() {
      setState(() {});
      if (!_descriptionFocusNode.hasFocus && widget.updateDescription != null) {
        widget.updateDescription!(
            widget.descriptionTextEditingController.text.trim());
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _nameFocusNode.dispose();
    _descriptionFocusNode.dispose();
  }

  bool _validateWorkspaceName() {
    if (widget.nameTextEditingController.text.isNotEmpty) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      spacing: 8.0,
      children: [
        Text(
          "Workspace",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Theme.of(context).colorScheme.secondary,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: !_validateWorkspaceName()
                              ? Theme.of(context).colorScheme.error
                              : _nameFocusNode.hasFocus
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.onSecondary,
                        ),
                  ),
                  TextField(
                    autocorrect: false,
                    controller: widget.nameTextEditingController,
                    focusNode: _nameFocusNode,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter name",
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      labelStyle: Theme.of(context).textTheme.labelMedium,
                    ),
                    onChanged: (value) {
                      widget.reload();
                    },
                    onTapOutside: (event) {
                      _nameFocusNode.unfocus();
                    },
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Divider(),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          color: _descriptionFocusNode.hasFocus
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSecondary,
                        ),
                  ),
                  SizedBox(
                    height: 100,
                    child: TextField(
                      autocorrect: false,
                      controller: widget.descriptionTextEditingController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      focusNode: _descriptionFocusNode,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter Description",
                        hintStyle: TextStyle(
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        labelStyle: Theme.of(context).textTheme.labelMedium,
                      ),
                      onTapOutside: (event) {
                        _descriptionFocusNode.unfocus();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
          child: !_validateWorkspaceName()
              ? Text(
                  "Workspace name is required",
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium!
                      .copyWith(color: Theme.of(context).colorScheme.error),
                )
              : null,
        ),
      ],
    );
  }
}
