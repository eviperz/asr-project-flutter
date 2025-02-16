import 'package:flutter/material.dart';

class DiaryTitleTextfield extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const DiaryTitleTextfield({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      style: Theme.of(context).textTheme.headlineLarge,
      controller: controller,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: "Untitled",
        counterText: "",
      ),
      maxLength: 20,
      onChanged: onChanged,
    );
  }
}
