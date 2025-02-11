import 'package:asr_project/providers/search_and_filter_query_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SortFilterWidget extends StatefulWidget {
  const SortFilterWidget({
    super.key,
  });

  @override
  State<SortFilterWidget> createState() => _SortFilterWidgetState();
}

class _SortFilterWidgetState extends State<SortFilterWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final isDescending = ref.watch(sortByDateTimeFilterQueryProvider);

        return OutlinedButton(
          onPressed: () {
            ref.read(sortByDateTimeFilterQueryProvider.notifier).toggleSort();
          },
          child: Wrap(
            spacing: 5,
            children: [
              Icon(isDescending ? Icons.arrow_downward : Icons.arrow_upward),
              Text("Sort by: Date time"),
            ],
          ),
        );
      },
    );
  }
}
