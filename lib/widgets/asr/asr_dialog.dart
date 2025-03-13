import 'dart:io';
import 'package:asr_project/editor/embeds/audio_block_embed.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class ASRDialog extends StatefulWidget {
  final quill.QuillController controller;

  const ASRDialog({
    super.key,
    required this.controller,
  });

  @override
  _ASRDialogState createState() => _ASRDialogState();
}

class _ASRDialogState extends State<ASRDialog> {
  bool _isRecording = false;
  late Record audioRecord;
  String? audioPath;

  @override
  void initState() {
    super.initState();
    audioRecord = Record();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.microphone.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      openAppSettings();
    }
  }

  Future<void> _insertAudio(String audioUrl) async {
    final index = widget.controller.selection.baseOffset;
    widget.controller.document.insert(
      index,
      quill.BlockEmbed.custom(AudioBlockEmbed(audioUrl)),
    );
  }

  Future<String?> _uploadAudioFile(File file) async {
    try {
      // var uri = Uri.parse("https://your-backend.com/upload");
      // var request = http.MultipartRequest("POST", uri);

      // request.files.add(
      //   await http.MultipartFile.fromPath(
      //     'audio',
      //     file.path,
      //     contentType:
      //         MediaType.parse(lookupMimeType(file.path) ?? 'audio/mpeg'),
      //   ),
      // );

      // var response = await request.send();
      // if (response.statusCode == 200) {
      //   var responseBody = await response.stream.bytesToString();
      //   return responseBody; // Adjust this according to the response format
      // }
    } catch (e) {
      print("Upload failed: $e");
    }
    return null;
  }

  Future<void> _startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        String filePath =
            '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.mp3';

        await audioRecord.start(path: filePath);
        setState(() {
          _isRecording = true;
          audioPath = filePath;
        });
      } else {
        print("Microphone permission not granted.");
      }
    } catch (e) {
      print('Error Start Recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      String? path = await audioRecord.stop();

      if (path != null && File(path).existsSync()) {
        setState(() {
          _isRecording = false;
          audioPath = path;
        });

        File file = File(path);
        String? uploadedUrl = await _uploadAudioFile(file);
        if (uploadedUrl != null) {
          _insertAudio(uploadedUrl);
        }
      } else {
        print("Recording failed or file does not exist.");
      }
    } catch (e) {
      print('Error Stop Recording: $e');
    }
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path ?? '');
      String? uploadedUrl = await _uploadAudioFile(file);
      if (uploadedUrl != null) {
        _insertAudio(uploadedUrl);
      }
    }
  }

  @override
  void dispose() {
    audioRecord.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Auto Speech Recognition Mode",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isRecording ? _stopRecording : _startRecording,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(_isRecording ? "Stop Recording" : "Record Audio"),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _pickAudioFile,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Insert Audio File"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
