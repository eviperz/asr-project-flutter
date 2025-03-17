import 'dart:convert';
import 'dart:developer';

import 'package:asr_project/editor/embeds/audio_block_embed.dart';
import 'package:asr_project/widgets/asr/audio_player_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class AudioEmbedBuilder extends quill.EmbedBuilder {
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
    final Map<String, dynamic> data = jsonDecode(node.value.data);
    final String audioUrl = data['audioUrl'];
    final String? transcribe = data['transcribe'];

    return AudioPlayerWidget(
      audioName: audioUrl,
      initialTranscribe: transcribe ?? "",
      onTranscribe: (newTranscript) {
        _updateTranscript(controller, node, newTranscript);
      },
    );
  }

  void _updateTranscript(
      quill.QuillController controller, quill.Embed node, String transcribe) {
    int nodeIndex = _findEmbedIndex(controller, node);
    if (nodeIndex == -1) return;

    final Map<String, dynamic> data = jsonDecode(node.value.data);
    final updatedNode = quill.BlockEmbed.custom(
      AudioBlockEmbed(data['audioUrl'], transcribe),
    );

    controller.replaceText(
      nodeIndex,
      1,
      updatedNode,
      TextSelection.collapsed(offset: nodeIndex),
    );
  }

  int _findEmbedIndex(quill.QuillController controller, quill.Embed node) {
    int offset = 0;

    for (var op in controller.document.toDelta().toList()) {
      if (op.isInsert && op.data is Map) {
        final data = op.data as Map;

        if (data.containsKey('custom')) {
          try {
            final decodedCustom = jsonDecode(data['custom']);
            final audioData = jsonDecode(decodedCustom['audio']);

            if (audioData.containsKey('audioUrl')) {
              final nodeAudioData = jsonDecode(node.value.data);
              if (audioData['audioUrl'] == nodeAudioData['audioUrl']) {
                return offset;
              }
            }
          } catch (e) {
            log("JSON Decode Error: $e");
          }
        }
      }
      offset += op.length!;
    }
    return -1;
  }
}
