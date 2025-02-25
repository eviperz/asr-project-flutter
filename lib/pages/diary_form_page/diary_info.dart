import 'package:asr_project/models/tag.dart';
import 'package:asr_project/widgets/tag_widget/diary_tag_list.dart';
import 'package:asr_project/pages/diary_form_page/tags_management_modal.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DiaryInfo extends StatelessWidget {
  final DateTime updatedAt;
  final List<Tag> tags;
  final Function() onChange;

  const DiaryInfo({
    super.key,
    required this.tags,
    required this.updatedAt,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow(
          context: context,
          icon: Icons.person,
          label: "Created by",
          child: Row(
            children: [
              _buildProfileIcon(context),
              SizedBox(width: 8.0),
              Text("Person Name",
                  style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
        ),
        _buildInfoRow(
          context: context,
          icon: Icons.access_time_outlined,
          label: "Last Edited",
          child: Text(
            DateFormat.yMMMd().format(updatedAt),
            style: Theme.of(context).textTheme.labelLarge,
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
              _buildAddTagButton(context),
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
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          width: 130,
          child: Row(
            children: [
              Icon(icon, color: Colors.grey, size: 16),
              SizedBox(width: 8.0),
              Text(label,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge!
                      .copyWith(color: Colors.grey)),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Widget _buildProfileIcon(BuildContext context) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(20.0),
      ),
      child:
          Image.asset("assets/images/default-profile.png", fit: BoxFit.cover),
    );
  }

  Widget _buildAddTagButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (context) =>
            TagsManagementModal(tags: tags, onChanged: onChange),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(100, 35),
        padding: EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add, size: 16),
          SizedBox(width: 6.0),
          Text("Add Tag", style: Theme.of(context).textTheme.labelMedium),
        ],
      ),
    );
  }
}
