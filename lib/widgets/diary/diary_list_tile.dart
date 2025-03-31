import 'dart:convert';

import 'package:asr_project/models/diary.dart';
import 'package:flutter/material.dart';

class DiaryListTile extends StatelessWidget {
  const DiaryListTile({
    super.key,
    required this.canEdit,
    required this.diary,
    this.padding,
  });

  final bool canEdit;
  final Diary diary;
  final EdgeInsetsGeometry? padding;

  bool _checkForInsertAndCustom(String contentJson) {
    return contentJson.contains('"insert"') && contentJson.contains('"custom"');
  }

  @override
  Widget build(BuildContext context) {
    // print(diary.content);
    String contentJson = jsonEncode(diary.content);
    bool isHasAudio = _checkForInsertAndCustom(contentJson);

    return ListTile(
      leading: Icon(Icons.note),
      title: Text(diary.title),
      subtitle: Text(diary.formatDate),
      contentPadding: padding,
      trailing: isHasAudio
          ? Padding(
              padding: EdgeInsets.only(right: 24),
              child: Icon(Icons.music_note,
                  color: Theme.of(context).colorScheme.inversePrimary))
          : null,
      onTap: () {
        Navigator.pushNamed(
          context,
          "/diary/detail",
          arguments: {'diary': diary, 'canEdit': canEdit},
        );
      },
    );
  }
}
