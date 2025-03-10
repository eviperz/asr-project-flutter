import 'package:asr_project/models/diary.dart';
import 'package:flutter/material.dart';

class DiaryListTile extends StatelessWidget {
  const DiaryListTile({
    super.key,
    required this.diary,
  });

  final Diary diary;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.note),
      title: Text(diary.title),
      subtitle: Text(diary.formatDate),
      onTap: () {
        Navigator.pushNamed(
          context,
          "/diary/detail",
          arguments: diary,
        );
      },
    );
  }
}
