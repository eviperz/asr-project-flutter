import 'package:flutter_quill/flutter_quill.dart' as quill;

class AudioBlockEmbed extends quill.CustomBlockEmbed {
  AudioBlockEmbed(String audioName, String? transcribe)
      : super(
            'audio',
            jsonEncode({
              'audioUrl': audioName,
              'transcribe': transcribe ?? '',
            }));
}
