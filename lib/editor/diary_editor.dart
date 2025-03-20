import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:asr_project/editor/embeds/audio_embed_builder.dart';

class DiaryEditor extends StatefulWidget {
  final quill.QuillController controller;
  final bool? checkBoxReadOnly;
  final bool? enableInteractiveSelection;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onKeyboardVisibilityChanged;

  const DiaryEditor({
    super.key,
    required this.controller,
    this.focusNode,
    this.checkBoxReadOnly,
    this.enableInteractiveSelection,
    this.onKeyboardVisibilityChanged,
  });

  @override
  State<DiaryEditor> createState() => _DiaryEditorState();
}

class _DiaryEditorState extends State<DiaryEditor> {
  late FocusNode _focusNode;
  late ScrollController _scrollController;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _scrollController = ScrollController();

    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isKeyboardVisible = _focusNode.hasFocus;
          if (widget.onKeyboardVisibilityChanged != null) {
            widget.onKeyboardVisibilityChanged!(_isKeyboardVisible);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: quill.QuillEditor(
        controller: widget.controller,
        focusNode: _focusNode,
        scrollController: _scrollController,
        configurations: quill.QuillEditorConfigurations(
          checkBoxReadOnly: widget.checkBoxReadOnly ?? false,
          enableInteractiveSelection: widget.enableInteractiveSelection ?? true,
          embedBuilders: [AudioEmbedBuilder()],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
