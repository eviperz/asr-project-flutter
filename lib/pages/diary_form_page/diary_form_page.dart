import 'package:asr_project/editor/diary_editor.dart';
import 'package:asr_project/editor/diary_toolbar.dart';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/tag.dart';
import 'package:asr_project/pages/diary_form_page/diary_info.dart';
import 'package:asr_project/pages/diary_form_page/diary_title_textfield.dart';
import 'package:asr_project/providers/diary_list_provider.dart';
import 'package:asr_project/widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class DiaryFormPage extends ConsumerStatefulWidget {
  final Diary? diary;

  const DiaryFormPage({super.key, this.diary});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DiaryFormState();
}

class _DiaryFormState extends ConsumerState<DiaryFormPage> {
  late String? _id;
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _titleController;
  late final quill.QuillController _controller;
  final List<Tag> _tags = [];
  late final DateTime _updatedAt;

  bool _isEdited = false;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    _id = widget.diary?.id;

    _controller = quill.QuillController(
      document: quill.Document.fromDelta(widget.diary?.content ?? Delta()
        ..insert("\n")),
      selection: const TextSelection.collapsed(offset: 0),
    );

    _titleController = TextEditingController(text: widget.diary?.title ?? "");

    _tags.addAll(widget.diary?.tags ?? []);

    _updatedAt = widget.diary?.updatedAt ?? DateTime.now();

    _controller.addListener(
      () {
        _isEdited = true;
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _updateKeyboardVisibility(bool isVisible) {
    setState(() {
      _isKeyboardVisible = isVisible;
      if (!isVisible) _focusNode.unfocus();
    });
  }

  void _onTagsChanged() {
    setState(() {
      _isEdited = true;
    });
  }

  void _showSaveDialog(BuildContext diaryContext) {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: "Are you sure?",
        content:
            "Do you want to save the changes you made to ${_titleController.text}?",
        confirmLabel: "Save",
        cancelLabel: "Dismiss",
        onConfirm: () {
          if (!context.mounted) return;
          _saveProcess();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${_titleController.text} saved!")),
          );

          // pop dialog
          Navigator.pop(context);

          // pop diary form
          Navigator.pop(context);
        },
        onCancel: () {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("${_titleController.text} unsaved!")),
          );

          // pop dialog
          Navigator.pop(context);

          // pop diary form
          Navigator.pop(context);
        },
      ),
    );
  }

  void _saveProcess() async {
    if (_id == null) {
      Diary? diary = await ref.read(diaryListProvider.notifier).addDiary(
            DiaryDetail(
              title: _titleController.text.isEmpty
                  ? 'Untitled'
                  : _titleController.text,
              content: _controller.document.toDelta(),
              tagIds: _tags.map((tag) => tag.id).toList(),
            ),
          );

      if (diary != null && mounted) {
        setState(() {
          _id = diary.id;
        });
      }
    } else {
      await ref.read(diaryListProvider.notifier).updateDiary(
          _id!,
          DiaryDetail(
            title: _titleController.text.isEmpty
                ? 'Untitled'
                : _titleController.text,
            content: _controller.document.toDelta(),
            tagIds: _tags.map((tag) => tag.id).toList(),
          ));
    }

    setState(() {
      _isEdited = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(diaryListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (_isEdited) {
              _showSaveDialog(context);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _titleController.text.isNotEmpty ? _titleController.text : "Untitled",
        ),
        actions: [
          // Consumer(builder: (context, ref, child) {
          //   ref.watch(diaryFavoriteProvider);
          //   final favoriteProvider = ref.read(diaryFavoriteProvider.notifier);
          //   final bool isFavorite =
          //       favoriteProvider.isFavorite(widget.diary.id);
          //   return IconButton(
          //     onPressed: () {
          //       favoriteProvider.toggleFavorite(widget.diary.id);
          //     },
          //     icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_outline),
          //   );
          // }),
          PopupMenuButton<String>(
            position: PopupMenuPosition.under,
            onSelected: (value) {
              switch (value) {
                case "save":
                  _saveProcess();

                case "delete":
                  showDialog(
                    context: context,
                    builder: (context) => CustomDialog(
                      title: "Delete",
                      content: "Are you confirm for delete?",
                      onConfirm: () async {
                        try {
                          if (_id == null) {
                            Navigator.of(context)
                              ..pop()
                              ..pop();
                          } else {
                            await ref
                                .read(diaryListProvider.notifier)
                                .removeDiary(_id!);

                            if (!context.mounted) return;
                            Navigator.of(context)
                              ..pop()
                              ..pop();

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Delete Diary!")),
                            );
                          }
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
                value: 'save',
                child: ListTile(
                  leading: Icon(Icons.save),
                  title: Text('Save'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                ),
              ),
            ],
            padding: EdgeInsets.all(0),
            menuPadding: EdgeInsets.all(8.0),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            spacing: 8.0,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DiaryTitleTextfield(
                controller: _titleController,
                onChanged: (newTitle) {
                  setState(() {
                    _isEdited = true;
                  });
                },
              ),
              DiaryInfo(
                tags: _tags,
                updatedAt: _updatedAt,
                onChange: () => _onTagsChanged(),
              ),
              DiaryEditor(
                focusNode: _focusNode,
                onKeyboardVisibilityChanged: _updateKeyboardVisibility,
                controller: _controller,
              ),
              SizedBox(
                height: _isKeyboardVisible ? 20 : 0,
              )
            ],
          ),
        ),
      ),
      bottomSheet: _isKeyboardVisible
          ? DiaryToolbar(
              controller: _controller,
              onKeyboardVisibilityChanged: _updateKeyboardVisibility,
            )
          : null,
    );
  }
}
