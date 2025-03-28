import 'dart:developer';

import 'package:asr_project/models/tag.dart';
import 'package:asr_project/pages/diary_form_page/tags_management_modal/tag_edit_form.dart';
import 'package:asr_project/providers/tag_provider.dart';
import 'package:asr_project/widgets/diary/diary_tag_list.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagsManagementModal extends ConsumerStatefulWidget {
  final List<Tag> tags;
  final Function()? onChanged;

  const TagsManagementModal({
    super.key,
    required this.tags,
    required this.onChanged,
  });

  @override
  ConsumerState<TagsManagementModal> createState() =>
      _TagsManagementModalState();
}

class _TagsManagementModalState extends ConsumerState<TagsManagementModal> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _focusNode.dispose();
  }

  bool checkExists() {
    return _controller.text.isEmpty ||
        ref.read(tagsProvider.notifier).isExist(_controller.text.trim());
  }

  void _addTag(Tag tag) {
    setState(() {
      widget.tags.add(tag);
    });

    widget.onChanged?.call();
  }

  void _deleteTag(String id) {
    try {
      ref.read(tagsProvider.notifier).removeTag(id);
      setState(() {
        widget.tags.removeWhere((tag) => tag.id == id);
      });
      widget.onChanged?.call();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete tag")),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error delete tag")),
      );
    }
  }

  void _showTagEditModal(Tag tag) async {
    Tag? updatedTag = await showCupertinoModalPopup<Tag>(
      context: context,
      builder: (context) => TagEditModal(tag: tag),
    );

    if (updatedTag != null) {
      TagDetail updatedTagDetail = TagDetail(
        name: updatedTag.name,
        colorEnum: updatedTag.colorEnum,
      );

      Tag? newTag = await ref
          .read(tagsProvider.notifier)
          .updateTag(tag.id, updatedTagDetail);

      if (newTag != null) {
        ref.invalidate(tagsProvider);
        setState(() {
          widget.tags.removeWhere((t) => t.id == tag.id);
          widget.tags.add(newTag);
        });

        widget.onChanged?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tag updated successfully")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error updating tag")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Tag> tags = ref.watch(tagsProvider).value ?? [];
    final List<Tag> filteredTags = tags
        .where((tag) => !widget.tags.any((t) => t.name == tag.name))
        .toList();

    return SafeArea(
      bottom: false,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
        child: Scaffold(
          backgroundColor: ColorScheme.of(context).surface,
          appBar: AppBar(
            title: const Text("Tags Management"),
            backgroundColor: Colors.transparent,
          ),
          body: Container(
            padding: const EdgeInsets.all(20.0),
            height: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tags",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    _buildTagInputField(),
                  ],
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8.0,
                    children: [
                      Text(
                        "Select or Create Tag",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      Expanded(
                        child: Container(
                          width: double.maxFinite,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          child: Column(
                            children: [
                              if (!filteredTags
                                  .map((tag) => tag.name)
                                  .contains(_controller.text))
                                _buildCreateTagButton(filteredTags),
                              Flexible(
                                child: _buildFilteredTagList(
                                    // _controller.text.isNotEmpty
                                    //     ? allTags
                                    //         .where((tag) => tag.name
                                    //             .contains(_controller.text))
                                    //         .toList()
                                    //     : allTags,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagInputField() {
    List<Tag> tags = ref.watch(tagsProvider).value ?? [];
    List<Tag> filteredTags = tags
        .where((tag) => widget.tags.any((t) => t.name == tag.name))
        .toList();

    // if it have a update on a filtered tags, update the tags
    if (!IterableEquality().equals(filteredTags, widget.tags)) {
      widget.tags.clear();
      widget.tags.addAll(filteredTags);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _focusNode.requestFocus();
        });
      },
      child: Container(
        width: double.maxFinite,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: Theme.of(context).colorScheme.secondary,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DiaryTagList(
              tags: widget.tags,
              textField: _buildTextField(),
              onChanged: () {
                setState(() {});
              },
              reload: () {
                ref.watch(tagsProvider.notifier).fetchData();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return IntrinsicWidth(
      child: TextField(
        focusNode: _focusNode,
        controller: _controller,
        maxLength: 20,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Enter Tag",
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
          ),
          counterText: "",
        ),
        onChanged: (value) {
          setState(() {});
        },
        onTapOutside: (event) {
          _focusNode.unfocus();
        },
      ),
    );
  }

  Widget _buildCreateTagButton(List<Tag> filteredTags) {
    return Column(
      children: [
        ListTile(
          title: Row(
            spacing: 8.0,
            children: [
              Text(
                "Create",
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              Flexible(
                child: _controller.text.isNotEmpty
                    ? Chip(
                        label: Text(
                          _controller.text,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        backgroundColor: Colors.grey,
                      )
                    : Container(),
              ),
            ],
          ),
          onTap: () async {
            if (_controller.text.isNotEmpty) {
              bool tagExists = [...filteredTags, ...widget.tags]
                  .any((tag) => tag.name == _controller.text.trim());

              if (!tagExists) {
                Tag? tag =
                    await ref.read(tagsProvider.notifier).createTag(TagDetail(
                          name: _controller.text.trim(),
                        ));

                _controller.clear();

                if (tag != null) {
                  _addTag(tag);
                } else {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error creating tag")),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Tag already exists")),
                );
              }
            }
          },
        ),
        Divider()
      ],
    );
  }

  Widget _buildFilteredTagList() {
    List<Tag> tags = ref.watch(tagsProvider).value ?? [];
    List<Tag> filteredTags = tags
        .where((tag) => !widget.tags.any((t) => t.name == tag.name))
        .toList();
    List<Tag> allTags = [...widget.tags, ...filteredTags];
    return ListView.separated(
        shrinkWrap: true,
        itemCount: allTags.length,
        itemBuilder: (context, index) {
          final Tag tag = allTags[index];
          return ListTile(
            title: Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                label: Text(tag.name),
                backgroundColor: tag.colorEnum.color,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _showTagEditModal(tag),
                  icon: const Icon(Icons.edit),
                ),
                IconButton(
                  onPressed: () => _deleteTag(tag.id),
                  icon: const Icon(Icons.delete),
                )
              ],
            ),
            onTap: () {
              _addTag(tag);
            },
          );
        },
        separatorBuilder: (context, index) {
          return Divider();
        });
  }
}
