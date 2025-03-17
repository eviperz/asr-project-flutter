import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class AudioBlockEmbed extends quill.CustomBlockEmbed {
  AudioBlockEmbed(String audioName, String transcribe)
      : super(
            audioType,
            jsonEncode({
              'audioUrl': audioName,
              'transcribe': transcribe,
            }));

  static const String audioType = 'audio';

  static AudioBlockEmbed fromDocument(quill.Document document) {
    // Convert document's Delta to a JSON List
    List<Map<String, dynamic>> deltaJson = document.toDelta().toJson();

    // Initialize variables for audio URL and transcription
    String audioUrl = '';
    String transcribe = '';

    // Iterate over the Delta JSON to find the audio block
    for (var element in deltaJson) {
      if (element['insert'] != null && element['insert'] is Map) {
        var insertData = element['insert'] as Map;
        if (insertData['audioUrl'] != null &&
            insertData['transcribe'] != null) {
          // Extract audioUrl and transcribe if found
          audioUrl = insertData['audioUrl'] ?? '';
          transcribe = insertData['transcribe'] ?? '';
          break;
        }
      }
    }

    // Return a new AudioBlockEmbed with the extracted values
    return AudioBlockEmbed(audioUrl, transcribe);
  }
}
