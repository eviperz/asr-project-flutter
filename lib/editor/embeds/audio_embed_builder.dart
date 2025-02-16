import 'package:asr_project/widgets/asr_widget/audio_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class AudioEmbedBuilder extends quill.EmbedBuilder {
  @override
  String get key => 'audio';

  @override
  Widget build(BuildContext context, quill.QuillController controller,
      quill.Embed node, bool readOnly, bool inline, TextStyle textStyle) {
    final String audioUrl = node.value.data;
    return AudioPlayerWidget(
      audioUrl: audioUrl,
    );
  }
}
