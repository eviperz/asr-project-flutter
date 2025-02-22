import 'package:asr_project/providers/diary_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagsFilter extends ConsumerStatefulWidget {
  final Function(Set<String>) onSelectTags;
  final Set<String> selectedTags;

  const TagsFilter({
    super.key,
    required this.onSelectTags,
    required this.selectedTags,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TagsFilterState();
}

class _TagsFilterState extends ConsumerState<TagsFilter> {
  void _showMultiSelectOptions() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return TagFillterModal(
            items: ref.read(diaryListProvider.notifier).tags,
            activeItems: widget.selectedTags,
            onSelectTag: widget.onSelectTags,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _showMultiSelectOptions(),
      child: Wrap(
        spacing: 5,
        children: [
          Icon(Icons.tag_outlined),
          Text(
            "Tags: ${widget.selectedTags.join(', ')}",
          ),
          Icon(Icons.keyboard_arrow_down_outlined)
        ],
      ),
    );
  }
}

class TagFillterModal extends StatefulWidget {
  final Set<String> items;
  final Set<String> activeItems;
  final Function(Set<String>) onSelectTag;

  const TagFillterModal({
    super.key,
    required this.items,
    required this.activeItems,
    required this.onSelectTag,
  });

  @override
  State<TagFillterModal> createState() => _TagFillterModalState();
}

class _TagFillterModalState extends State<TagFillterModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      height: 300,
      child: Column(
        children: [
          AppBar(
            leading: SizedBox(
              width: 100,
              child: TextButton(
                onPressed: () {
                  widget.onSelectTag({});
                  Navigator.pop(context);
                },
                child: Text("Clear"),
              ),
            ),
            title: Text("Tags"),
            actions: [
              TextButton(
                onPressed: () {
                  widget.onSelectTag(widget.activeItems);
                  Navigator.pop(context);
                },
                child: Text("Done"),
              ),
            ],
            backgroundColor: Colors.transparent,
          ),
          Expanded(
            child: widget.items.isEmpty
                ? Center(
                    child: Text("No tags"),
                  )
                : ListView(
                    children: widget.items.map((tag) {
                      return CheckboxListTile.adaptive(
                        title: Text(tag),
                        value: widget.activeItems.contains(tag),
                        onChanged: (bool? value) {
                          if (value == true) {
                            setState(() {
                              widget.activeItems.add(tag);
                            });
                          } else {
                            setState(() {
                              widget.activeItems.remove(tag);
                            });
                          }
                        },
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}
