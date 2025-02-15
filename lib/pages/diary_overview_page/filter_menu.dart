import 'package:asr_project/pages/diary_overview_page/sort_filter_widget.dart';
import 'package:asr_project/pages/diary_overview_page/tags_filter.dart';
import 'package:flutter/material.dart';

class FilterMenu extends StatelessWidget {
  final Function(bool) onSort;
  final bool isAscending;
  final Function(Set<String>) onSelectTags;
  final Set<String> selectedTags;

  const FilterMenu({
    super.key,
    required this.onSort,
    required this.isAscending,
    required this.onSelectTags,
    required this.selectedTags,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            selectedTags: selectedTags,
          )
        ],
      ),
    );
  }
}
