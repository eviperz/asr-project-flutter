import 'package:flutter/material.dart';

class DefaultModal extends StatelessWidget {
  final Widget child;

  const DefaultModal({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Card(
          child: Container(
            padding: EdgeInsets.all(24.0),
            width: 350,
            child: child,
          ),
        ),
      ),
    );
  }
}
