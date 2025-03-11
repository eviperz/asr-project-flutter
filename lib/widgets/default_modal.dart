import 'package:flutter/material.dart';

class DefaultModal extends StatelessWidget {
  final String title;
  final Widget child;

  const DefaultModal({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Card(
          surfaceTintColor: Theme.of(context).colorScheme.primary,
          child: Container(
            padding: EdgeInsets.all(12.0),
            width: 350,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.close)),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    )
                  ],
                ),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
