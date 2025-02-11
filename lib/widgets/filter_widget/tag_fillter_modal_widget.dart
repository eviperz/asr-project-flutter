import 'package:asr_project/providers/search_and_filter_query_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagFillterModalWidget extends StatefulWidget {
  final Set<String> items;
  final Set<String> activeItems;

  const TagFillterModalWidget({
    super.key,
    required this.items,
    required this.activeItems,
  });

  @override
  State<TagFillterModalWidget> createState() => _TagFillterModalWidgetState();
}

class _TagFillterModalWidgetState extends State<TagFillterModalWidget> {
  late Set<String> _activeItems;

  @override
  void initState() {
    _activeItems = Set.from(widget.activeItems);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, child) {
      final notifier = ref.read(selectedTagsProvider.notifier);
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
                    notifier.clear();
                    Navigator.pop(context);
                  },
                  child: Text("Clear"),
                ),
              ),
              title: Text("Tags"),
              actions: [
                TextButton(
                  onPressed: () {
                    notifier.setTags(_activeItems);
                    Navigator.pop(context);
                  },
                  child: Text("Done"),
                ),
              ],
              backgroundColor: Colors.transparent,
            ),
            Expanded(
              child: ListView(
                children: widget.items.map((tag) {
                  return CheckboxListTile.adaptive(
                    title: Text(tag),
                    value: _activeItems.contains(tag),
                    onChanged: (bool? value) {
                      if (value == true) {
                        setState(() {
                          _activeItems.add(tag);
                        });
                      } else {
                        setState(() {
                          _activeItems.remove(tag);
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
    });
  }
}
