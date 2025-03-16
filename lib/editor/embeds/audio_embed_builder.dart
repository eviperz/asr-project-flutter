import 'package:asr_project/widgets/asr/audio_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class AudioEmbedBuilder extends quill.EmbedBuilder {
  // final ValueChanged<String> onSaveTranscription;

  // AudioEmbedBuilder({required this.onSaveTranscription});

  @override
  String get key => 'audio';

  @override
  Widget build(BuildContext context, quill.QuillController controller,
      quill.Embed node, bool readOnly, bool inline, TextStyle textStyle) {
    final Map<String, dynamic> data = node.value.data;

    final String audioUrl = data['audioUrl'] ?? '';
    final String transcription = data['transcribe'] ?? '';

    // Add debug print to check values
    print('audioUrl: $audioUrl, transcription: $transcription');

    return AudioPlayerWidget(
      audioName: audioUrl,
      transcribe: transcription,
    );
  }
}
