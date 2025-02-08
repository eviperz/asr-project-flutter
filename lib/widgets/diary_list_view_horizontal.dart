import 'package:asr_project/models/diary.dart';
import 'package:asr_project/screens/diary_detail_screen.dart';
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
                return DiaryCard(diary: diary);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class DiaryCard extends StatelessWidget {
  final Diary diary;

  const DiaryCard({super.key, required this.diary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DiaryDetailScreen(diary: diary),
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          width: 300,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    diary.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 8, // Space between tags
                    runSpacing: 4, // Space between rows of tags (if wrapping)
                    children: diary.tags.map((tag) {
                      return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Text(
                diary.getFormatDate(),
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
        ),
      ),
    );
  }
}
