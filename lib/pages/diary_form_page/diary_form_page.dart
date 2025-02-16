import 'package:asr_project/editor/diary_editor.dart';
import 'package:asr_project/editor/diary_toolbar.dart';
import 'package:asr_project/providers/diary_list_provider.dart';
import 'package:asr_project/widgets/custom_dialog.dart';
import 'package:asr_project/pages/diary_form_page/diary_title_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/widgets/diary_widget/diary_tag_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiaryFormPage extends ConsumerStatefulWidget {
  final Diary diary;

  const DiaryFormPage({
    super.key,
    required this.diary,
  });

  @override
  ConsumerState<DiaryFormPage> createState() => _DiaryFormScreenState();
}

class _DiaryFormScreenState extends ConsumerState<DiaryFormPage> {
  // final DiaryDatabase diaryDatabase = DiaryDatabase();
  late final quill.QuillController _controller;
  late final TextEditingController _titleController;

  final Set<String> _tags = {};

  bool _isEdited = false;

  @override
  void initState() {
    super.initState();

    _controller = quill.QuillController(
      document: quill.Document.fromDelta(widget.diary.content),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _titleController = TextEditingController(text: widget.diary.title);
    _tags.addAll(widget.diary.tags);

    _controller.addListener(
      () {
        _isEdited = true;
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: "Saved",
        content: "Are you confirm for saved?",
        onConfirm: () async {
          try {
            // _diary.updateContent(
            //     jsonEncode(_controller.document.toDelta().toJson()));
            // _diary.updateDateTimeNow();

            // if (_diary.id == null) {
            //   await diaryDatabase.insertDiary(_diary);
            // } else {
            //   await diaryDatabase.updateDiary(_diary);
            // }

            if (!context.mounted) return;
            ref.read(diaryListProvider.notifier).updateDiary(DiaryDetail(
                  id: widget.diary.id,
                  title: _titleController.text.isEmpty
                      ? 'Untitled'
                      : _titleController.text,
                  content: _controller.document.toDelta(),
                  tags: _tags,
                  dateTime: DateTime.now(),
                ));
            setState(() {
              _isEdited = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("บันทึกแล้ว!")),
            );

            Navigator.pop(context);
          } catch (e) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("เกิดข้อผิดพลาดในการบันทึก: $e")),
            );
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showUnSaveDialog(BuildContext diaryContext) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: "Unsaved",
        content: "Are you confirm for unsaved?",
        onConfirm: () {
          if (!context.mounted) return;

          // pop dialog
          Navigator.pop(context);

          // pop diary form
          Navigator.pop(context);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _onTagsChanged(Set<String> tags) {
    setState(() {
      _tags.clear();
      _tags.addAll(tags);
      _isEdited = true;
    });
  }

  // bool _isDiffirentDiary() {
  //   final diffTitle = _titleController.text != widget.diary.title;
  //   final diffContent = _controller. != widget.diary.content;
  //   final diffTags = _diary.tags != widget.diary.tags;
  //   return diffTitle || diffContent || diffTags;
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (_isEdited) {
              _showUnSaveDialog(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(widget.diary.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: _showSaveDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DiaryTitleTextfield(
                  controller: _titleController,
                  onChanged: (newTitle) {
                    // setState(() {
                    //   _diary.title = newTitle.isEmpty ? "Untitled" : newTitle;
                    // });
                    setState(() {
                      _isEdited = true;
                    });
                  },
                ),
                DiaryTagList(
                  tags: _tags,
                  onChanged: _onTagsChanged,
                ),
              ],
            ),
            Expanded(
              child: DiaryEditor(
                controller: _controller,
              ),
            ),
            DiaryToolbar(controller: _controller),
          ],
        ),
      ),
    );
  }
}
