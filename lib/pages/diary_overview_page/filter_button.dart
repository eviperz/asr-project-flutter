import 'package:asr_project/providers/search_and_filter_query_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterButton extends ConsumerWidget {
  const FilterButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filterQuery = ref.watch(filterQueryProvider);

    return OutlinedButton(
      onPressed: () {
        ref.read(filterQueryProvider.notifier).state = !filterQuery;
      },
      child: Icon(Icons.filter_list),
    );
  }
}
