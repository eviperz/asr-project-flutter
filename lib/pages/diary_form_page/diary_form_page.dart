import 'dart:convert';
import 'dart:developer';

import 'package:asr_project/config.dart';
import 'package:asr_project/providers/diary_folder_provider.dart';
import 'package:asr_project/widgets/asr/asr_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/widgets/custom_dialog.dart';
import 'package:asr_project/editor/diary_editor.dart';
import 'package:asr_project/editor/diary_toolbar.dart';
import 'package:asr_project/pages/diary_form_page/diary_info.dart';

class DiaryFormPage extends ConsumerStatefulWidget {
  final Diary diary;
  final bool canEdit;

  const DiaryFormPage({
    super.key,
    required this.canEdit,
    required this.diary,
  });

  @override
  ConsumerState<DiaryFormPage> createState() => _DiaryFormState();
}

class _DiaryFormState extends ConsumerState<DiaryFormPage> {
  final TextEditingController _titleController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final quill.QuillController _controller = quill.QuillController.basic();
  final FocusNode _focusNode = FocusNode();

  bool _isToolbarVisible = false;

  Set<String> _tagIds = {};
  bool _isHasAudio = false;
  String? _userId;
  late DateTime _updatedAt;
  bool _isEdited = false;

  Future<void> _initializeUserId() async {
    _userId = await AppConfig.getUserId();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isEdited = true;
        String contentJson =
            jsonEncode(_controller.document.toDelta().toJson());
        // _isHasAudio = _checkForInsertAndCustom(contentJson);
        _tagIds = widget.diary.tagIds.toSet();
      });
    });
    _focusNode.addListener(
      () {
        _onFocusChange();
      },
    );
    _initializeUserId();

    _titleController.text = widget.diary.title;
    _controller.document = quill.Document.fromDelta(widget.diary.content);

    // String contentJson = jsonEncode(_controller.document.toDelta().toJson());
    // _isHasAudio = _checkForInsertAndCustom(contentJson);
    log(_isHasAudio.toString());
    _updatedAt = widget.diary.updatedAt;
    _isEdited = false;
  }

  // bool _checkForInsertAndCustom(String contentJson) {
  //   return contentJson.contains('"insert"') && contentJson.contains('"custom"');
  // }

  void _onFocusChange() {
    setState(() {
      _isToolbarVisible = _focusNode.hasFocus;
    });
  }

  void _showAsrDialog() async {
    bool? updated = await showDialog<bool>(
      context: context,
      builder: (context) => AsrDialog(
        controller: _controller,
        // isHasAudio: _isHasAudio,
      ),
    );

    if (updated == true) {
      setState(() {
        // String contentJson =
        //     jsonEncode(_controller.document.toDelta().toJson());
        // _isHasAudio = _checkForInsertAndCustom(contentJson);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveDiary() async {
    final DiaryDetail diaryDetail = DiaryDetail(
      title: _titleController.text.trim().isEmpty
          ? 'Untitled'
          : _titleController.text.trim(),
      content: _controller.document.toDelta(),
      tagIds: _tagIds.toList(),
      userId: _userId,
    );

    await ref
        .read(diaryFoldersProvider.notifier)
        .updateDiary(widget.diary.id, diaryDetail);

    setState(() => _isEdited = false);
  }

  void _confirmSave() {
    showDialog(
      context: context,
      builder: (context) => CustomDialog(
        title: "Save Changes?",
        content:
            "Do you want to save the changes to '${_titleController.text}'?",
        confirmLabel: "Save",
        cancelLabel: "Dismiss",
        onConfirm: () async {
          await _saveDiary();

          if (!mounted) return;
          Navigator.pop(context);
          Navigator.pop(context);
        },
        onCancel: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => _isEdited ? _confirmSave() : Navigator.pop(context),
        ),
        title: Text(_titleController.text.isNotEmpty
            ? _titleController.text
            : "Untitled"),
        actions: [
          if (widget.canEdit)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == "save") {
                  await _saveDiary();
                } else if (value == "delete") {
                  showDialog(
                    context: context,
                    builder: (context) => CustomDialog(
                      title: "Delete Meeting Note",
                      content:
                          "Are you sure you want to delete this Meeting Note?",
                      onConfirm: () async {
                        await ref
                            .read(diaryFoldersProvider.notifier)
                            .deleteDiary(widget.diary.id);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      onCancel: () => Navigator.pop(context),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'save',
                  child:
                      ListTile(leading: Icon(Icons.save), title: Text('Save')),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                      leading: Icon(Icons.delete), title: Text('Delete')),
                ),
              ],
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          _focusNode.unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitleTextField(context, widget.canEdit),
                DiaryInfo(
                  owner: widget.diary.owner,
                  tagIds: _tagIds,
                  updatedAt: _updatedAt,
                  onAddTag: widget.canEdit
                      ? (newId) {
                          setState(() {
                            _isEdited = true;
                            _tagIds.add(newId);
                          });
                        }
                      : null,
                  onRemoveTag: widget.canEdit
                      ? (removedId) {
                          setState(() {
                            _isEdited = true;
                            _tagIds.removeWhere((id) => id == removedId);
                          });
                        }
                      : null,
                ),
                IntrinsicHeight(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width,
                      minHeight: _focusNode.hasFocus
                          ? MediaQuery.of(context).size.height * 0.20
                          : MediaQuery.of(context).size.height * 0.55,
                    ),
                    child: DiaryEditor(
                      focusNode: _focusNode,
                      controller: _controller,
                      enableInteractiveSelection: widget.canEdit,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomSheet:
          _isToolbarVisible ? DiaryToolbar(controller: _controller) : null,
      floatingActionButton: widget.canEdit
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              onPressed: _showAsrDialog,
              child: Icon(Icons.mic),
            )
          : null,
    );
  }

  Widget _buildTitleTextField(BuildContext context, bool canEdit) {
    return TextField(
      style: Theme.of(context).textTheme.headlineLarge,
      controller: _titleController,
      focusNode: _titleFocusNode,
      readOnly: !canEdit,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: "Untitled",
        counterText: "",
      ),
      autocorrect: false,
      maxLength: 20,
      onChanged: (_) => setState(() => _isEdited = true),
      onTapOutside: (event) {
        _titleFocusNode.unfocus();
      },
    );
  }
}
