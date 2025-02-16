import 'package:asr_project/models/diary.dart';
import 'package:flutter/material.dart';

class DiaryCard extends StatefulWidget {
  final Diary diary;
  final double width;
  final double height;

  const DiaryCard({
    super.key,
    required this.diary,
    required this.width,
    required this.height,
  });

  @override
  State<DiaryCard> createState() => _DiaryCardState();
}

class _DiaryCardState extends State<DiaryCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, "/diary/detail",
          arguments: widget.diary.id),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Container(
          height: widget.height,
          width: widget.width,
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
                    widget.diary.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: widget.diary.tags.map((tag) {
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
                widget.diary.formatDate,
                style: Theme.of(context).textTheme.bodySmall,
              )
            ],
          ),
        ),
      ),
    );
  }
}
