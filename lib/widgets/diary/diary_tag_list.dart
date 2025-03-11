import 'package:asr_project/models/tag.dart';
import 'package:flutter/material.dart';

class DiaryTagList extends StatefulWidget {
  final List<Tag> tags;
  final Widget? textField;
  final Function()? onChanged;
  final Function()? reload;

  const DiaryTagList({
    super.key,
    required this.tags,
    this.textField,
    this.onChanged,
    this.reload,
  });

  @override
  State<DiaryTagList> createState() => _DiaryTagListState();
}

class _DiaryTagListState extends State<DiaryTagList> {
  void _removeTag(Tag tag) {
    setState(() {
      widget.tags.removeWhere((t) => t.id == tag.id);
    });

    widget.onChanged?.call();
    widget.reload!();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8.0,
      children: [
        ...widget.tags.map(
          (tag) => Chip(
            label: Text(tag.name),
            backgroundColor: tag.color,
            onDeleted: widget.onChanged != null ? () => _removeTag(tag) : null,
          ),
        ),
        if (widget.textField != null) widget.textField!,
      ],
    );
  }
}
