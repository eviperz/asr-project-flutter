import 'package:asr_project/models/tag.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/widgets/profile_image.dart';
import 'package:asr_project/widgets/diary/diary_tag_list.dart';
import 'package:asr_project/pages/diary_form_page/tags_management_modal/tags_management_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiaryInfo extends StatelessWidget {
  final User? owner;
  final DateTime updatedAt;
  final List<Tag> tags;
  final VoidCallback? onChange;

  const DiaryInfo({
    super.key,
    this.owner,
    required this.tags,
    required this.updatedAt,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge;
    return Column(
      children: [
        _buildInfoRow(
          context: context,
          icon: Icons.person,
          label: "Created by",
          child: Row(
            children: [
              const ProfileImage(),
              const SizedBox(width: 8.0),
              Text(owner?.name ?? "Anonymous", style: textStyle),
            ],
          ),
        ),
        _buildInfoRow(
          context: context,
          icon: Icons.access_time_outlined,
          label: "Last Edited",
          child: Text(
            DateFormat.yMMMd().format(updatedAt),
            style: textStyle,
          ),
        ),
        _buildInfoRow(
          context: context,
          icon: Icons.tag,
          label: "Tags",
          child: Wrap(
            spacing: 8.0,
            children: [
              DiaryTagList(tags: tags, onChanged: onChange),
              if (onChange != null) _buildAddTagButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    final labelStyle =
        Theme.of(context).textTheme.labelLarge!.copyWith(color: Colors.grey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Row(
              children: [
                Icon(icon, color: Colors.grey, size: 16),
                const SizedBox(width: 8.0),
                Text(label, style: labelStyle),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildAddTagButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => showCupertinoModalPopup(
        context: context,
        barrierDismissible: true,
        builder: (_) => TagsManagementModal(tags: tags, onChanged: onChange),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(100, 35),
        padding: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 16),
          SizedBox(width: 6.0),
          Text("Add Tag"),
        ],
      ),
    );
  }
}
