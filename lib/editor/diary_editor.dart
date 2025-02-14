import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:asr_project/editor/embeds/audio_embed_builder.dart';

class DiaryEditor extends StatelessWidget {
  final quill.QuillController controller;
  final bool? checkBoxReadOnly;
  final bool? enableInteractiveSelection;

  const DiaryEditor({
    super.key,
    required this.controller,
    this.checkBoxReadOnly,
    this.enableInteractiveSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: quill.QuillEditor.basic(
        controller: controller,
        configurations: quill.QuillEditorConfigurations(
          checkBoxReadOnly: checkBoxReadOnly ?? false,
          enableInteractiveSelection: enableInteractiveSelection ?? true,
          embedBuilders: [AudioEmbedBuilder()],
        ),
      ),
    );
  }
}
