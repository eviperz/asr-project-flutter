import 'package:asr_project/widgets/filter_widget/sort_filter_widget.dart';
import 'package:asr_project/widgets/filter_widget/tags_filter_widget.dart';
import 'package:flutter/material.dart';

class FilterMenuWidget extends StatelessWidget {
  const FilterMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [SortFilterWidget(), TagsFilterWidget()],
      ),
    );
  }
}
