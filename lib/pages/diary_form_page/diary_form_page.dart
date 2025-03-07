import 'package:asr_project/providers/tag_list_provider.dart';
import 'package:asr_project/providers/personal_diary_folder_provider.dart';
import 'package:asr_project/providers/workspace_diary_folder_provider%20copy.dart';
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
  final String type;
  final Diary diary;

  const DiaryFormPage({
    super.key,
    required this.type,
    required this.diary,
  });

  @override
  ConsumerState<DiaryFormPage> createState() => _DiaryFormState();
}

class _DiaryFormState extends ConsumerState<DiaryFormPage> {
  final TextEditingController _titleController = TextEditingController();
  final quill.QuillController _controller = quill.QuillController.basic();
  late List<Tag> _tags;
  late DateTime _updatedAt;
  bool _isEdited = false;
  bool _isKeyboardVisible = false;

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
        .map((id) => ref.read(tagListProvider.notifier).getTag(id))
        .whereType<Tag>()
        .toList();
    _updatedAt = widget.diary.updatedAt;
    _isEdited = false;
    super.didChangeDependencies();
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
    );

    if (widget.type == "personal") {
      await ref
          .read(personalDiaryFoldersProvider.notifier)
          .updateDiary(widget.diary.id, diaryDetail);
    } else {
      await ref
          .watch(workspaceDiaryFoldersProvider.notifier)
          .updateDiary(widget.diary.id, diaryDetail);
    }

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
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == "save") {
                await _saveDiary();
              } else if (value == "delete") {
                showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                    title: "Delete Diary",
                    content: "Are you sure you want to delete this diary?",
                    onConfirm: () async {
                      await ref
                          .read(personalDiaryFoldersProvider.notifier)
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
                child: ListTile(leading: Icon(Icons.save), title: Text('Save')),
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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleTextField(context),
            DiaryInfo(
              tags: _tags,
              updatedAt: _updatedAt,
              onChange: () => setState(() => _isEdited = true),
            ),
            Expanded(
              child: DiaryEditor(
                controller: _controller,
                onKeyboardVisibilityChanged: (isVisible) =>
                    setState(() => _isKeyboardVisible = isVisible),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _isKeyboardVisible
          ? DiaryToolbar(
              controller: _controller,
              onKeyboardVisibilityChanged: (isVisible) =>
                  setState(() => _isKeyboardVisible = isVisible),
            )
          : null,
    );
  }

  Widget _buildTitleTextField(BuildContext context) {
    return TextField(
      style: Theme.of(context).textTheme.headlineLarge,
      controller: _titleController,
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
