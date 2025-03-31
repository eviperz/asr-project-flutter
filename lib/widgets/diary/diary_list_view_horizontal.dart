import 'package:asr_project/models/diary.dart';
import 'package:asr_project/widgets/diary/diary_card.dart';
import 'package:flutter/material.dart';

class DiaryListViewHorizontal extends StatelessWidget {
  final String title;
  final List diaryList;

  const DiaryListViewHorizontal({
    super.key,
    required this.title,
    required this.diaryList,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8.0,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 20.0),
            scrollDirection: Axis.horizontal,
            itemCount: diaryList.length,
            itemBuilder: (context, index) {
              Diary diary = diaryList[index];
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: DiaryCard(
                  diary: diary,
                  width: 250,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
