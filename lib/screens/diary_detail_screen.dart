import 'package:asr_project/models/diary.dart';
import 'package:flutter/material.dart';

class DiaryDetailScreen extends StatefulWidget {
  final Diary diary;

  const DiaryDetailScreen({super.key, required this.diary});

  @override
  State<StatefulWidget> createState() => _DiaryDetail();
}

class _DiaryDetail extends State<DiaryDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diary.title),
      ),
    );
  }
}
