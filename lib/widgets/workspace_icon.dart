import 'package:flutter/material.dart';

class WorkspaceIcon extends StatelessWidget {
  final double? size;

  const WorkspaceIcon({
    super.key,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      width: size ?? 55,
      height: size ?? 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: Theme.of(context).colorScheme.primary,
      ),
      child: Icon(
        Icons.note,
        color: Colors.white,
      ),
    );
  }
}
