// import 'package:asr_project/editor/embeds/audio_block_embed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:asr_project/widgets/asr/audio_player_widget.dart';

class AudioEmbedBuilder extends quill.EmbedBuilder {
  // AudioEmbedBuilder({required this.addAudio});

  // Future<void> Function(BuildContext context, {quill.Document? document})
  //     addAudio;

  @override
  String get key => 'audio';

  @override
  Widget build(
    BuildContext context,
    quill.QuillController controller,
    quill.Embed node,
    bool readOnly,
    bool inline,
    TextStyle textStyle,
  ) {
    // final audio = AudioBlockEmbed(
    //     node.value.data['audioUrl'], node.value.data['transcribe']);

    return AudioPlayerWidget(
      audioName: node.value.data['audioUrl'],
      transcribe: node.value.data['transcribe'],
    );
  }
}
