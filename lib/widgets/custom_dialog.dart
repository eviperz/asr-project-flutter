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
    return AlertDialog(
      title: Text(widget.title),
      content: Text(widget.content),
      actions: [
        TextButton(
          onPressed: () => widget.onConfirm(),
          child: Text(widget.confirmLabel ?? "Confirm"),
        ),
        if (widget.onCancel != null)
          TextButton(
            onPressed: () => widget.onCancel!(),
            child: Text(widget.cancelLabel ?? "Cancel"),
          ),
      ],
    );
  }
}
