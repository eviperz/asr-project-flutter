import 'package:asr_project/config.dart';
import 'package:asr_project/providers/diary_folder_provider.dart';
import 'package:asr_project/providers/tag_provider.dart';
import 'package:asr_project/widgets/asr/asr_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:asr_project/models/diary.dart';
import 'package:asr_project/models/tag.dart';
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
  final quill.QuillController _controller = quill.QuillController.basic();
  late List<Tag> _tags;
  String? _userId;
  late DateTime _updatedAt;
  bool _isEdited = false;
  bool _isKeyboardVisible = false;

  _DiaryFormState() {
    _initializeUserId();
  }
  Future<void> _initializeUserId() async {
    _userId = await AppConfig.getUserId();
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() => _isEdited = true));
  }

  @override
  void didChangeDependencies() {
    _titleController.text = widget.diary.title;
    _controller.document = quill.Document.fromDelta(widget.diary.content);
    _tags = (widget.diary.tagIds)
        .map((id) => ref.read(tagsProvider.notifier).getTag(id))
        .whereType<Tag>()
        .toList();
    _updatedAt = widget.diary.updatedAt;
    _isEdited = false;
    super.didChangeDependencies();
  }

  void _showAsrDialog() {
    showDialog(
      context: context,
      builder: (context) => AsrDialog(
        controller: _controller,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _saveDiary() async {
    final DiaryDetail diaryDetail = DiaryDetail(
      title: _titleController.text.trim().isEmpty
          ? 'Untitled'
          : _titleController.text.trim(),
      content: _controller.document.toDelta(),
      tagIds: _tags.map((tag) => tag.id).toList(),
      userId: _userId,
    );

    await ref
        .read(diaryFoldersProvider.notifier)
        .updateDiary(widget.diary.id, diaryDetail);

    setState(() => _isEdited = false);
  }

  void _confirmSave(BuildContext context) {
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

          if (mounted) {
            Navigator.pop(context);
            Navigator.pop(context);
          }
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
          onPressed: () =>
              _isEdited ? _confirmSave(context) : Navigator.pop(context),
        ),
        title: Text(_titleController.text.isNotEmpty
            ? _titleController.text
            : "Untitled"),
        actions: [
          if (widget.canEdit)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == "save") {
                  await _saveDiary(); // If no audio, pass an empty string
                } else if (value == "delete") {
                  showDialog(
                    context: context,
                    builder: (context) => CustomDialog(
                      title: "Delete Diary",
                      content: "Are you sure you want to delete this diary?",
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
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTitleTextField(context, widget.canEdit),
              DiaryInfo(
                owner: widget.diary.owner,
                tags: _tags,
                updatedAt: _updatedAt,
                onChange: widget.canEdit
                    ? () => setState(() => _isEdited = true)
                    : null,
              ),
              DiaryEditor(
                controller: _controller,
                enableInteractiveSelection: widget.canEdit,
                onKeyboardVisibilityChanged: (isVisible) =>
                    setState(() => _isKeyboardVisible = isVisible),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _isKeyboardVisible
          ? DiaryToolbar(
              controller: _controller,
              onKeyboardVisibilityChanged: (isVisible) =>
                  setState(() => _isKeyboardVisible = isVisible),
            )
          : null,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAsrDialog,
        child: const Icon(Icons.mic),
      ),
    );
  }

  Widget _buildTitleTextField(BuildContext context, bool canEdit) {
    return TextField(
      style: Theme.of(context).textTheme.headlineLarge,
      controller: _titleController,
      readOnly: !canEdit,
      decoration: const InputDecoration(
        border: InputBorder.none,
        hintText: "Untitled",
        counterText: "",
      ),
      autocorrect: false,
      maxLength: 20,
      onChanged: (_) => setState(() => _isEdited = true),
    );
  }
}
