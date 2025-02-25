import 'dart:developer';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/providers/diary_favorite_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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
      onTap: () => Navigator.pushNamed(context, "/diary/detail",
          arguments: widget.diary.id),
      child: Card(
        child: Container(
          width: widget.width,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16.0,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Container(
                          color: Theme.of(context).colorScheme.primary,
                          padding: EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.event_note,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          late bool isFavorite = ref
                              .read(diaryFavoriteProvider.notifier)
                              .isFavorite(widget.diary.id);
                          return IconButton(
                            onPressed: () {
                              if (isFavorite) {
                                ref
                                    .read(diaryFavoriteProvider.notifier)
                                    .removeFavorite(widget.diary.id);
                              } else {
                                ref
                                    .read(diaryFavoriteProvider.notifier)
                                    .addFavorite(widget.diary.id);
                              }

                              setState(() {});
                            },
                            icon: isFavorite
                                ? Icon(
                                    Icons.favorite,
                                    color: Colors.red,
                                  )
                                : Icon(
                                    Icons.favorite_border,
                                  ),
                          );
                        },
                      ),
                    ],
                  ),
                  Text(
                    widget.diary.title,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  DateFormat.yMMMd().format(
                    widget.diary.updatedAt,
                  ),
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
