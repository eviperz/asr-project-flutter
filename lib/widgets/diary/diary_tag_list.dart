import 'dart:developer';

import 'package:asr_project/models/tag.dart';
import 'package:asr_project/providers/tag_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryTagList extends ConsumerStatefulWidget {
  final Set<String> tagIds;
  final Widget? textField;
  final Function(String)? onRemoveTag;
  final Function()? reload;

  const DiaryTagList({
    super.key,
    required this.tagIds,
    this.textField,
    this.onRemoveTag,
    this.reload,
  });

  @override
  ConsumerState<DiaryTagList> createState() => _DiaryTagListState();
}

class _DiaryTagListState extends ConsumerState<DiaryTagList> {
  void _removeTag(String removedId) {
    setState(() {
      widget.tagIds.removeWhere((id) => removedId == id);
    });

    widget.onRemoveTag!(removedId);
    log("test remove tag: $removedId");
    widget.reload?.call();
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<Tag>> tagsAsync = ref.watch(tagsProvider);
    List<Tag> tags = [];
    if (tagsAsync.hasValue && tagsAsync.value != null) {
      for (String id in widget.tagIds) {
        Tag? foundTag = tagsAsync.value?.firstWhere((tag) => tag.id == id);
        if (foundTag != null) {
          tags.add(foundTag);
        }
      }
    }

    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.0,
      children: [
        ...tags.map(
          (tag) => Chip(
            label: Text(tag.name),
            backgroundColor: tag.colorEnum.color,
            onDeleted: widget.onRemoveTag != null
                ? () {
                    _removeTag(tag.id);
                  }
                : null,
          ),
        ),
        if (widget.textField != null) widget.textField!,
      ],
    );
  }
}
