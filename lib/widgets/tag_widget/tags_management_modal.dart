import 'dart:developer';

import 'package:asr_project/models/tag.dart';
import 'package:asr_project/providers/tag_list_provider.dart';
import 'package:asr_project/widgets/tag_widget/diary_tag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagsManagementModal extends ConsumerStatefulWidget {
  final List<Tag> tags;
  final Function(String) onAddTag;
  final Function()? onChanged;

  const TagsManagementModal({
    super.key,
    required this.tags,
    required this.onAddTag,
    required this.onChanged,
  });

  @override
  ConsumerState<TagsManagementModal> createState() =>
      _TagsManagementModalState();
}

class _TagsManagementModalState extends ConsumerState<TagsManagementModal> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  void _reloadModal() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(tagListProvider);
    final List<Tag> tags = ref.watch(tagListProvider);
    final List<Tag> filteredTags = tags
        .where((tag) => !widget.tags.any((t) => t.name == tag.name))
        .toList();
    log("tags: ${tags.toString()}");
    log("filteredTag: ${filteredTags.toString()}");

    return Container(
      padding: EdgeInsets.all(16.0),
      height: 500,
      child: Column(
        children: [
          AppBar(
            title: Text("Tags"),
            backgroundColor: Colors.transparent,
          ),
          SizedBox(height: 24.0),
          GestureDetector(
            onTap: () {
              setState(() {
                _focusNode.requestFocus();
              });
            },
            child: Container(
              width: double.maxFinite,
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white12),
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white10,
              ),
              child: DiaryTagList(
                tags: widget.tags,
                textController: _controller,
                focusNode: _focusNode,
                onAddTag: widget.onAddTag,
                onChanged: widget.onChanged,
                reloadModal: _reloadModal,
              ),
            ),
          ),
          SizedBox(height: 24.0),
          Text(
            "Select or Create Tag",
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8.0),
          Container(
            width: double.maxFinite,
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white12),
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.white10,
            ),
            child: Column(
              children: [
                TextButton(
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      if (![...filteredTags, ...widget.tags]
                          .any((tag) => tag.name == _controller.text.trim())) {
                        widget.onAddTag.call(_controller.text.trim());
                        _controller.clear();
                      }
                    } else {
                      _focusNode.requestFocus();
                    }
                  },
                  child: Row(
                    children: [
                      Text("Create"),
                      SizedBox(width: 8.0),
                      Flexible(
                        child: _controller.text.isNotEmpty
                            ? Chip(
                                label: Text(
                                  _controller.text,
                                  style:
                                      Theme.of(context).textTheme.labelMedium,
                                ),
                                backgroundColor: Colors.grey,
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: filteredTags
                      .map((tag) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Divider(),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    alignment: Alignment.centerLeft,
                                  ),
                                  onPressed: () {
                                    bool isDuplicate = widget.tags.any(
                                      (t) => t.name == tag.name,
                                    );

                                    if (!isDuplicate) {
                                      widget.onAddTag(tag.name);
                                    }
                                  },
                                  child: Text(tag.name),
                                ),
                              ),
                            ],
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
