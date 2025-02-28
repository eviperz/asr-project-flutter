import 'package:asr_project/models/tag.dart';
import 'package:asr_project/providers/tag_list_provider.dart';
import 'package:asr_project/widgets/diary/diary_tag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagsManagementModal extends ConsumerStatefulWidget {
  final List<Tag> tags;
  final Function() onChanged;

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

  void _reloadModal() {
    setState(() {});
  }

  void _addTag(Tag tag) {
    setState(() {
      widget.tags.add(tag);
    });

    widget.onChanged.call();
    setState(() {});
  }

  String colorToHex(Color color) {
    return color.toHexString().substring(2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final List<Tag> tags = ref.watch(tagListProvider).asData?.value ?? [];
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
            padding: const EdgeInsets.all(16.0),
            height: double.maxFinite,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTagInputField(),
                const SizedBox(height: 24.0),
                Text(
                  "Select or Create Tag",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8.0),
                Expanded(
                  child: Card(
                    child: Container(
                      width: double.maxFinite,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white12),
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white10,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildCreateTagButton(filteredTags),
                            _buildFilteredTagList(filteredTags),
                          ],
                        ),
                      ),
                    ),
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
    return Card(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _focusNode.requestFocus();
          });
        },
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white12),
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white10,
          ),
          child: Wrap(spacing: 8.0, children: [
            DiaryTagList(
              tags: widget.tags,
              textField: _buildTextField(),
              onChanged: widget.onChanged,
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return IntrinsicWidth(
      child: TextField(
        focusNode: _focusNode,
        style: Theme.of(context).textTheme.labelLarge,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Enter Tag",
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary),
          labelStyle: Theme.of(context).textTheme.labelMedium,
        ),
        controller: _controller,
        onChanged: (value) {
          _reloadModal();
        },
      ),
    );
  }

  Widget _buildCreateTagButton(List<Tag> filteredTags) {
    return TextButton(
      onPressed: () async {
        if (_controller.text.isNotEmpty) {
          bool tagExists = [...filteredTags, ...widget.tags]
              .any((tag) => tag.name == _controller.text.trim());

          if (!tagExists) {
            Tag? tag = await ref
                .read(tagListProvider.notifier)
                .addTag(TagDetail(name: _controller.text.trim()));

            _controller.clear();

            if (tag != null) {
              _addTag(tag);
            } else {
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Error creating tag")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tag already exists")),
            );
          }
        } else {
          _focusNode.requestFocus();
        }
      },
      style: TextButton.styleFrom(
        fixedSize: const Size(double.infinity, 50),
        alignment: Alignment.centerLeft,
      ),
      child: Row(
        children: [
          const Text("Create"),
          const SizedBox(width: 8.0),
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
    );
  }

  Widget _buildFilteredTagList(List<Tag> filteredTags) {
    return Column(
      children: filteredTags
          .where((tag) =>
              tag.name.contains(_controller.text.trim()) ||
              _controller.text.isEmpty)
          .map((tag) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        fixedSize: const Size(double.infinity, 50),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () {
                        if (!widget.tags.any((t) => t.name == tag.name)) {
                          _addTag(tag);
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Chip(
                            label: Text(
                              tag.name,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            backgroundColor: tag.color,
                          ),
                          Row(
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
                        ],
                      ),
                    ),
                  ),
                ],
              ))
          .toList(),
    );
  }

  void _showTagEditModal(Tag tag) {
    Color currentColor = tag.color;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text("Tag"),
            leading: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  String hexColor = colorToHex(currentColor);
                  ref.read(tagListProvider.notifier).updateTag(
                        tag.id,
                        TagDetail(name: tag.name, colorCode: hexColor),
                      );
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ],
            backgroundColor: Colors.transparent,
          ),
          body: Center(
            child: Container(
              padding: const EdgeInsets.all(20.0),
              width: 300,
              child: ColorPicker(
                enableAlpha: false,
                labelTypes: [],
                hexInputBar: true,
                colorPickerWidth: 200,
                pickerColor: currentColor,
                onColorChanged: (Color color) {
                  setState(() {
                    currentColor = color;
                  });
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _deleteTag(String id) {
    try {
      ref.watch(tagListProvider.notifier).removeTag(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Delete tag")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error delete tag")),
      );
    }
  }
}
