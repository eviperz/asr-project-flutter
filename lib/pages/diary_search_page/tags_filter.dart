import 'package:asr_project/models/tag.dart';
import 'package:asr_project/providers/tag_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagsFilter extends ConsumerStatefulWidget {
  final Function(String) onSelectTags;
  final Function() clearActiveTags;
  final Set<String> activeTags;

  const TagsFilter({
    super.key,
    required this.onSelectTags,
    required this.clearActiveTags,
    required this.activeTags,
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
            activeTags: widget.activeTags,
            clearActiveTags: widget.clearActiveTags,
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
            "Tags: ${widget.activeTags.join(', ')}",
          ),
          Icon(Icons.keyboard_arrow_down_outlined)
        ],
      ),
    );
  }
}

class TagFillterModal extends ConsumerStatefulWidget {
  final Function(String) onSelectTag;
  final Function() clearActiveTags;
  final Set<String> activeTags;

  const TagFillterModal({
    super.key,
    required this.activeTags,
    required this.clearActiveTags,
    required this.onSelectTag,
  });

  @override
  ConsumerState<TagFillterModal> createState() => _TagFillterModalState();
}

class _TagFillterModalState extends ConsumerState<TagFillterModal> {
  @override
  Widget build(BuildContext context) {
    final List<Tag> tags = ref.watch(tagsProvider).value ?? [];

    return Container(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close)),
              Text(
                "Select tags",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextButton(
                    onPressed: () {
                      widget.clearActiveTags();
                    },
                    child: Text(
                      "clear",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    )),
              )
            ],
          ),
          Expanded(
            child: tags.isEmpty
                ? Center(
                    child: Text("No tags"),
                  )
                : ListView(
                    children: tags.map((tag) {
                      return CheckboxListTile.adaptive(
                        title: Align(
                          alignment: Alignment.centerLeft,
                          child: Chip(
                            label: Text(tag.name),
                            backgroundColor: tag.colorEnum.color,
                          ),
                        ),
                        value: widget.activeTags.contains(tag.name),
                        onChanged: (bool? value) {
                          setState(() {});
                          widget.onSelectTag(tag.name);
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
