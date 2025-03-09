import 'package:flutter/material.dart';

class CustomTextfield extends StatefulWidget {
  final String? label;
  final String hintText;
  final IconData? iconData;
  final bool canClear;
  final TextInputType? keyboardType;
  final String? errorText;
  final TextEditingController textEditController;
  final FocusNode focusNode;

  const CustomTextfield({
    super.key,
    this.label,
    required this.hintText,
    this.iconData,
    bool? canClear,
    this.errorText,
    required this.keyboardType,
    required this.textEditController,
    required this.focusNode,
  }) : canClear = canClear ?? false;

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    bool isPasswordField = widget.keyboardType == TextInputType.visiblePassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null)
          Text(widget.label ?? "",
              style: Theme.of(context).textTheme.headlineSmall),
        SizedBox(height: 8.0),
        TextField(
          controller: widget.textEditController,
          focusNode: widget.focusNode,
          autocorrect: false,
          keyboardType: widget.keyboardType,
          obscureText: isPasswordField ? _isObscured : false, // Hide password
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.secondary,
            prefixIcon: widget.iconData != null
                ? Icon(
                    widget.iconData,
                    color: widget.errorText != null
                        ? Theme.of(context).colorScheme.error
                        : widget.focusNode.hasFocus
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSecondary,
                  )
                : null,
            suffixIcon: isPasswordField
                ? IconButton(
                    icon: Icon(
                        _isObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() {
                        _isObscured = !_isObscured;
                      });
                    },
                  )
                : widget.canClear
                    ? (widget.textEditController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              widget.textEditController.clear();
                              (context as Element).markNeedsBuild();
                            },
                            icon: Icon(Icons.close),
                            iconSize: 18,
                          )
                        : null)
                    : null,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            errorText: widget.errorText,
          ),
          onTapOutside: (event) {
            widget.focusNode.unfocus();
          },
        ),
      ],
    );
  }
}
