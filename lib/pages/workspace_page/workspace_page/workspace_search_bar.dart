import 'package:asr_project/widgets/custom_textfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WorkspaceSearchBar extends StatelessWidget {
  const WorkspaceSearchBar({
    super.key,
    required TextEditingController searchTextEditingController,
    required FocusNode searchFocusNode,
  }) : _searchTextEditingController = searchTextEditingController, _searchFocusNode = searchFocusNode;

  final TextEditingController _searchTextEditingController;
  final FocusNode _searchFocusNode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: CustomTextfield(
        hintText: "Search Workspace",
        keyboardType: TextInputType.text,
        textEditController: _searchTextEditingController,
        focusNode: _searchFocusNode,
        canClear: true,
        iconData: Icons.search,
      ),
    );
  }
}
