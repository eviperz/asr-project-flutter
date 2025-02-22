import 'dart:developer';

import 'package:asr_project/models/tag.dart';
import 'package:asr_project/widgets/tag_widget/add_tag_button.dart';
import 'package:flutter/material.dart';

class DiaryTagList extends StatefulWidget {
  final List<Tag> tags;
  final TextEditingController? textController;
  final FocusNode? focusNode;
  final Function(String)? onAddTag;
  final Function()? onChanged;
  final Function()? reloadModal;

  const DiaryTagList({
    super.key,
    required this.tags,
    this.textController,
    this.focusNode,
    this.onAddTag,
    this.onChanged,
    this.reloadModal,
  });

  @override
  State<DiaryTagList> createState() => _DiaryTagListState();
}

class _DiaryTagListState extends State<DiaryTagList> {
  late bool _isDuplicate;

  @override
  void initState() {
    _isDuplicate = false;
    super.initState();
  }

  void _removeTag(Tag tag) {
    setState(() {
      widget.tags.removeWhere((t) => t.name == tag.name);
    });

    widget.onChanged?.call();
    widget.reloadModal?.call();
    setState(() {});
  }

  void _addTag(String name) {
    final trimmedName = name.trim();
    if (_isDuplicate || trimmedName.isEmpty) return;

    Tag tag = Tag(name: trimmedName, colorCode: "colorCode");
    log("create: ${tag.name}");
    widget.textController?.clear();

    setState(() {
      widget.tags.add(tag);
    });

    widget.onChanged?.call();
    widget.reloadModal?.call();
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
            label: Text(
              tag.name,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            backgroundColor: Colors.grey,
            onDeleted: widget.onChanged != null ? () => _removeTag(tag) : null,
          ),
        ),
        widget.textController == null
            ? AddTagButton(
                tags: widget.tags,
                onAddTag: _addTag,
                onChanged: widget.onChanged,
              )
            : IntrinsicWidth(
                child: TextField(
                  focusNode: widget.focusNode,
                  style: Theme.of(context).textTheme.labelLarge,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: "",
                    labelStyle: Theme.of(context).textTheme.labelMedium,
                  ),
                  controller: widget.textController,
                  onChanged: (value) {
                    // final trimmedValue = value.trim();
                    // final isDuplicate =
                    //     widget.tags.any((tag) => tag.name == trimmedValue);
                    // log("isDu: ${isDuplicate.toString()}");

                    // setState(() {
                    //   _isDuplicate = isDuplicate;
                    // });

                    // if (trimmedValue.isNotEmpty && !_isDuplicate) {
                    //   widget.textController!.text = trimmedValue;
                    // }
                    widget.reloadModal?.call();
                  },
                ),
              )
      ],
    );
  }
}
