import 'package:flutter/material.dart';

class WorkspaceNameAndDescriptionTextField extends StatelessWidget {
  final TextEditingController nameTextEditingController;
  final TextEditingController descriptionTextEditingController;
  final Function reload;
  const WorkspaceNameAndDescriptionTextField({
    super.key,
    required this.nameTextEditingController,
    required this.descriptionTextEditingController,
    required this.reload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white10,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Workspace Name"),
                TextField(
                  autocorrect: false,
                  controller: nameTextEditingController,
                  decoration: InputDecoration(
                    hintText: "Enter workspace name",
                    errorText: nameTextEditingController.text.isEmpty
                        ? "Workspace name is required"
                        : null,
                  ),
                  onChanged: (value) {
                    reload();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Description",
                ),
                SizedBox(
                  height: 100,
                  child: TextField(
                    autocorrect: false,
                    controller: descriptionTextEditingController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Enter Description",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
