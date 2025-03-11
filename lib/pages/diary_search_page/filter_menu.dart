import 'package:asr_project/pages/diary_search_page/sort_filter_widget.dart';
import 'package:asr_project/pages/diary_search_page/tags_filter.dart';
import 'package:flutter/material.dart';

class FilterMenu extends StatelessWidget {
  final VoidCallback onSort;
  final bool isAscending;
  final Function(String) onSelectTags;
  final Function() clearActiveTags;
  final Set<String> activeTags;

  const FilterMenu({
    super.key,
    required this.onSort,
    required this.isAscending,
    required this.onSelectTags,
    required this.clearActiveTags,
    required this.activeTags,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      width: double.maxFinite,
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(
                color: Theme.of(context).colorScheme.primary.withAlpha(24))),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 8,
          children: [
            SortFilterWidget(
              onSort: onSort,
              isAscending: isAscending,
            ),
            TagsFilter(
              onSelectTags: onSelectTags,
              clearActiveTags: clearActiveTags,
              activeTags: activeTags,
            )
          ],
        ),
      ),
    );
  }
}
