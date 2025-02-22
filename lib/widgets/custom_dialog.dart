import 'package:flutter/material.dart';

class CustomDialog extends StatefulWidget {
  final String title;
  final String content;
  final Function() onConfirm;
  final String? confirmLabel;
  final Function()? onCancel;
  final String? cancelLabel;

  const CustomDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
    this.confirmLabel,
    this.onCancel,
    this.cancelLabel,
  });

  @override
  State<CustomDialog> createState() => _CustomDialogState();
}

class _CustomDialogState extends State<CustomDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(widget.title),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(widget.content),
      ),
      actions: [
        if (widget.onCancel != null)
          TextButton(
            onPressed: () => widget.onCancel!(),
            child: Text(
              widget.cancelLabel ?? "Cancel",
              style: TextStyle(color: const Color.fromARGB(255, 255, 120, 120)),
            ),
          ),
        TextButton(
          onPressed: () => widget.onConfirm(),
          child: Text(
            widget.confirmLabel ?? "Confirm",
          ),
        ),
      ],
    );
  }
}
