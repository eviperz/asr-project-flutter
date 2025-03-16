import 'package:flutter_quill/flutter_quill.dart' as quill;

class AudioBlockEmbed extends quill.CustomBlockEmbed {
  AudioBlockEmbed(String audioUrl, String transcribe)
      : super(audioUrl, transcribe);

  static AudioBlockEmbed fromJson(Map<String, dynamic> data) {
    return AudioBlockEmbed(data['audioUrl'], data['transcribe']);
  }
}
