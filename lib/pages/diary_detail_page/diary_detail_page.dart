import 'package:asr_project/models/diary.dart';
import 'package:asr_project/widgets/custom_dialog.dart';
import 'package:asr_project/pages/diary_detail_page/date_box.dart';
import 'package:asr_project/pages/diary_detail_page/diary_content.dart';
import 'package:asr_project/widgets/diary_widget/diary_tag_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';

class DiaryDetailScreen extends StatefulWidget {
  final Diary diary;

  const DiaryDetailScreen({super.key, required this.diary});

  @override
  State<StatefulWidget> createState() => _DiaryDetail();
}

class _DiaryDetail extends State<DiaryDetailScreen> {
  // final DiaryDatabase diaryDatabase = DiaryDatabase();
  late QuillController _controller;
  late Diary _diary;

  @override
  void initState() {
    _diary = widget.diary;

    _controller = QuillController(
      document: Document.fromDelta(widget.diary.content),
      selection: const TextSelection.collapsed(offset: 0),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.diary.title),
        actions: [
          PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            onSelected: (value) {
              if (value == 'edit') {
                Navigator.pushNamed(
                  context,
                  "/diary/edit",
                  arguments: widget.diary,
                );
              } else if (value == 'delete') {
                showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                    title: "Delete",
                    content: "Are you confirm for delete?",
                    onConfirm: () async {
                      try {
                        // await diaryDatabase.removeDiary(_diary);

                        if (!context.mounted) return;

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
                        children: [
                          Expanded(
                            child: DiaryTagList(
                              tags: _diary.tags,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.favorite),
                          ),
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
