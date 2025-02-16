import 'package:asr_project/editor/embeds/audio_block_embed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class ASRDialog extends StatelessWidget {
  final quill.QuillController controller;

  const ASRDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Auto Speech Recognition Mode",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // void _insertAudio(quill.QuillController controller) {
                  String audioUrl =
                      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

                  final index = controller.selection.baseOffset;
                  controller.document.insert(
                    index,
                    quill.BlockEmbed.custom(
                      AudioBlockEmbed(audioUrl),
                    ),
                  );
                  Navigator.pop(context);
                  // }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Insert Audio File",
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    "/record",
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Record Audio",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
