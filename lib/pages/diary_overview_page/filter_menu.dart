import 'package:asr_project/pages/diary_overview_page/sort_filter_widget.dart';
import 'package:asr_project/pages/diary_overview_page/tags_filter.dart';
import 'package:flutter/material.dart';

class FilterMenu extends StatelessWidget {
  const FilterMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [SortFilterWidget(), TagsFilter()],
      ),
    );
  }
}
