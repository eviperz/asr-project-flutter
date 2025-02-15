import 'package:asr_project/models/diary.dart';
import 'package:asr_project/providers/diary_favorite_provider.dart';
import 'package:asr_project/providers/diary_list_provider.dart';
import 'package:asr_project/widgets/custom_dialog.dart';
import 'package:asr_project/pages/diary_detail_page/date_box.dart';
import 'package:asr_project/pages/diary_detail_page/diary_content.dart';
import 'package:asr_project/widgets/diary_widget/diary_tag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DiaryDetailScreen extends ConsumerStatefulWidget {
  final String id;

  const DiaryDetailScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DiaryDetail();
}

class _DiaryDetail extends ConsumerState<DiaryDetailScreen> {
  // final DiaryDatabase diaryDatabase = DiaryDatabase();
  late final QuillController _controller;
  late Diary _diary;

  @override
  void initState() {
    _diary = ref.read(diaryListProvider.notifier).get(widget.id);
    _controller = QuillController(
      document: Document.fromDelta(_diary.content),
      selection: const TextSelection.collapsed(offset: 0),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(diaryListProvider);
    try {
      _diary = ref.read(diaryListProvider.notifier).get(widget.id);
    } on StateError catch (_) {
      return Container();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_diary.title),
        actions: [
          PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.pushNamed(
                  context,
                  "/diary/edit",
                  arguments: _diary.id,
                );
              } else if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                    title: "Delete",
                    content: "Are you confirm for delete?",
                    onConfirm: () async {
                      try {
                        if (!context.mounted) return;

                        ref
                            .read(diaryListProvider.notifier)
                            .removeDiary(_diary.id);

                        Navigator.of(context)
                          ..pop()
                          ..pop();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("ลบแล้ว!")),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text("เกิดข้อผิดพลาดในการบันทึก: $e")),
                        );
                      }
                    },
                    onCancel: () => Navigator.pop(context),
                  ),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('Edit'),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete'),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DateBox(dateTime: _diary.dateTime),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(height: 30),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: DiaryTagList(
                              tags: _diary.tags,
                            ),
                          ),
                          Consumer(builder: (context, ref, child) {
                            ref.watch(diaryFavoriteProvider);
                            final favoriteProvider =
                                ref.read(diaryFavoriteProvider.notifier);
                            final bool isFavorite =
                                favoriteProvider.isFavorite(_diary.id);
                            return IconButton(
                              onPressed: () {
                                favoriteProvider.toggleFavorite(_diary.id);
                              },
                              icon: Icon(isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_outline),
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            DiaryContent(diary: _diary, controller: _controller),
            Container(
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.topRight,
              height: 80,
              child: Text(
                "Last Updated: ${DateFormat.yMMMd().format(_diary.dateTime)}",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
