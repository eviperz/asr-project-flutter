import 'package:asr_project/models/diary.dart';
import 'package:asr_project/widgets/diary_list/diary_card.dart';
import 'package:flutter/material.dart';

class DiaryListViewHorizontal extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List diaryList;

  const DiaryListViewHorizontal({
    super.key,
    required this.title,
    required this.diaryList,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 10,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.labelLarge,
              ),
          ],
        ),
        SizedBox(
          height: 200,
          child: Scrollbar(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: diaryList.length,
              itemBuilder: (context, index) {
                Diary diary = diaryList[index];
                return DiaryCard(
                  diary: diary,
                  width: 300,
                  height: 150,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
