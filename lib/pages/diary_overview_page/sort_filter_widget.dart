import 'package:flutter/material.dart';

class SortFilterWidget extends StatelessWidget {
  final Function(bool) onSort;
  final bool isAscending;

  const SortFilterWidget({
    super.key,
    required this.onSort,
    required this.isAscending,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        onSort(!isAscending);
      },
      child: Wrap(
        spacing: 5,
        children: [
          Icon(isAscending ? Icons.arrow_upward : Icons.arrow_downward),
          Text("Sort by: Date time"),
        ],
      ),
    );
  }
}
