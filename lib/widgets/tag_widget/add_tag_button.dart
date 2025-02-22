import 'package:asr_project/models/tag.dart';
import 'package:asr_project/widgets/tag_widget/tags_management_modal.dart';
import 'package:flutter/material.dart';

class AddTagButton extends StatelessWidget {
  final List<Tag> tags;
  final Function(String) onAddTag;
  final Function()? onChanged;

  const AddTagButton({
    super.key,
    required this.tags,
    required this.onAddTag,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (context) => TagsManagementModal(
          tags: tags,
          onAddTag: onAddTag,
          onChanged: onChanged,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(100, 35),
        padding: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 16),
          SizedBox(width: 6.0),
          Text(
            "Add Tag",
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
