import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterButton extends ConsumerWidget {
  final Function(bool) onFilter;
  final bool isFiltering;

  const FilterButton({
    super.key,
    required this.onFilter,
    required this.isFiltering,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: () {
        onFilter(!isFiltering);
      },
      child: Icon(Icons.filter_list),
    );
  }
}
