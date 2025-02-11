import 'package:asr_project/providers/search_and_filter_query_provider.dart';
import 'package:asr_project/widgets/filter_widget/tag_fillter_modal_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TagsFilterWidget extends ConsumerStatefulWidget {
  const TagsFilterWidget({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TagsFilterWidgetState();
}

class _TagsFilterWidgetState extends ConsumerState<TagsFilterWidget> {
  final Set<String> items = {"text", "asr", "flutter", "dart"};

  void _showMultiSelectOptions() {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return TagFillterModalWidget(
              items: items, activeItems: ref.read(selectedTagsProvider));
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
            "Tags: ${ref.read(selectedTagsProvider).join(', ')}",
          ),
          Icon(Icons.keyboard_arrow_down_outlined)
        ],
      ),
    );
  }
}
