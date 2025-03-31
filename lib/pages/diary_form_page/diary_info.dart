import 'package:asr_project/models/tag.dart';
import 'package:asr_project/models/user.dart';
import 'package:asr_project/providers/tag_provider.dart';
import 'package:asr_project/widgets/profile_image.dart';
import 'package:asr_project/widgets/diary/diary_tag_list.dart';
import 'package:asr_project/pages/diary_form_page/tags_management_modal/tags_management_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DiaryInfo extends ConsumerWidget {
  final User? owner;
  final DateTime updatedAt;
  final Set<String> tagIds;
  final Function(String)? onAddTag;
  final Function(String)? onRemoveTag;

  const DiaryInfo({
    super.key,
    this.owner,
    required this.tagIds,
    required this.updatedAt,
    this.onAddTag,
    this.onRemoveTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    AsyncValue<List<Tag>> tagsAsync = ref.watch(tagsProvider);
    List<Tag> tags = [];
    if (tagsAsync.hasValue && tagsAsync.value != null) {
      for (String id in tagIds) {
        Tag? foundTag =
            tagsAsync.value?.firstWhere((tag) => tag.id == id, orElse: null);
        if (foundTag != null) {
          tags.add(foundTag);
        }
      }
    }
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
              DiaryTagList(
                tagIds: tagIds,
                onRemoveTag: onRemoveTag,
              ),
              if (onAddTag != null && onRemoveTag != null)
                _buildAddTagButton(context, tags),
              if (onAddTag != null && onRemoveTag != null && tagIds.isEmpty)
                Text(
                  "No Tags",
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        color: Theme.of(context).colorScheme.tertiary,
                        fontStyle: FontStyle.italic,
                      ),
                )
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
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 120,
        height: 40,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
            ),
          ],
        ),
      ),
      title: child,
      titleAlignment: ListTileTitleAlignment.top,
    );
  }

  Widget _buildAddTagButton(BuildContext context, List<Tag> tags) {
    return OutlinedButton(
      onPressed: () => showCupertinoModalPopup(
        context: context,
        barrierDismissible: true,
        builder: (_) => TagsManagementModal(
          tags: tags,
          onAddTag: onAddTag,
          onRemoveTag: onRemoveTag,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(100, 35),
        padding: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
