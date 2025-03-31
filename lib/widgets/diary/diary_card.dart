import 'package:asr_project/models/diary.dart';
import 'package:flutter/material.dart';

class DiaryCard extends StatefulWidget {
  final Diary diary;
  final double width;

  const DiaryCard({
    super.key,
    required this.diary,
    required this.width,
  });

  @override
  State<DiaryCard> createState() => _DiaryCardState();
}

class _DiaryCardState extends State<DiaryCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        "/diary/detail",
        arguments: {
          'diary': widget.diary,
          'canEdit': true,
        },
      ),
      child: Card(
        child: Container(
          width: widget.width,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipOval(
                child: Container(
                  color: Theme.of(context).colorScheme.primary,
                  padding: EdgeInsets.all(16.0),
                  child: Icon(
                    Icons.note,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                widget.diary.title,
                style: Theme.of(context).textTheme.headlineMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                softWrap: false,
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  widget.diary.formatDate,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
