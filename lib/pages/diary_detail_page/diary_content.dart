import 'package:asr_project/editor/diary_editor.dart';
import 'package:asr_project/models/diary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class DiaryContent extends StatelessWidget {
  final Diary diary;
  final QuillController controller;

  const DiaryContent({
    super.key,
    required this.diary,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(top: 16.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(10),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                diary.title,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              DiaryEditor(
                controller: controller,
                checkBoxReadOnly: true,
                enableInteractiveSelection: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
