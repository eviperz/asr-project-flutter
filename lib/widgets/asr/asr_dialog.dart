import 'dart:developer';
import 'dart:io';

import 'package:asr_project/editor/embeds/audio_block_embed.dart';
import 'package:asr_project/services/asr_service.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AsrDialog extends StatefulWidget {
  final quill.QuillController controller;
  final bool isHasAudio;

  const AsrDialog(
      {super.key, required this.controller, required this.isHasAudio});

  @override
  State<AsrDialog> createState() => _ASRDialogState();
}

class _ASRDialogState extends State<AsrDialog> {
  final AsrService _asrService = AsrService();
  bool _isAfterFirstRecord = false;
  bool _isRecording = false;
  late Record audioRecord;
  String? audioPath;

  late final RecorderController _recorderController;

  @override
  void initState() {
    super.initState();
    audioRecord = Record();
    _requestPermissions();

    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100
      ..bitRate = 128000;
  }

  Future<bool> _requestPermissions() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      openAppSettings();
      return false;
    }

    return await Permission.microphone.request().isGranted;
  }

  Future<void> _insertAudio(String audioUrl) async {
    final index = widget.controller.selection.baseOffset;

    // Only proceed if isHasAudio is true
    if (widget.isHasAudio) {
      bool replaceAudio = await _showReplaceDialog();
      if (!replaceAudio) {
        return;
      }
    }
    if (widget.isHasAudio) {
      final document = widget.controller.document;
      final delta = document.toDelta();

      for (var i = 0; i < delta.length; i++) {
        final operation = delta[i];

        if (operation.isInsert) {
          final insertedValue = operation.data;

          // Check if it's a BlockEmbed and contains audio data
          if (insertedValue is Map && insertedValue.containsKey('audio')) {
            document.replace(
                i, 1, quill.BlockEmbed.custom(AudioBlockEmbed(audioUrl, "")));
            break;
          }
        }
      }
    } else {
      _isAfterFirstRecord = true;
      widget.controller.document.insert(
        index,
        quill.BlockEmbed.custom(AudioBlockEmbed(audioUrl, "")),
      );
    }
  }

  Future<void> _handleReplaceAudio() async {
    bool replaceAudio = await _showReplaceDialog();
    if (replaceAudio) {
      _replaceAudioOptions();
    }
  }

  Future<bool> _showReplaceDialog() async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Replace Audio"),
          content: const Text(
              "You already have an audio. Do you want to replace it?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Replace"),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  Future<void> _replaceAudioOptions() async {
    bool? choice = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Choose Audio Action"),
          content:
              const Text("Do you want to record new audio or pick a file?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Record New Audio"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Pick Audio File"),
            ),
          ],
        );
      },
    );

    if (choice == true) {
      _startRecording();
    } else if (choice == false) {
      _pickAudioFile();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath =
            '${directory.path}/recording_${DateTime.now().microsecondsSinceEpoch}.m4a';

        await _recorderController.record(path: filePath);
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      print('Error Start Recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      String? path = await _recorderController.stop();

      if (path != null && File(path).existsSync()) {
        setState(() {
          _isRecording = false;
          audioPath = path;
        });
        _isAfterFirstRecord = true;
        log("check bool $_isAfterFirstRecord");
        _uploadFile(File(path));
      }
    } catch (e) {
      print('Error Stop Recording: $e');
    }
  }

  Future<void> _uploadFile(File file) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const UploadingDialog(),
    );

    String uploadedUrl = await _asrService.uploadFile(file);

    if (!mounted) return;
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (_) => const UploadSuccessDialog(),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      Navigator.pop(context);
      _insertAudio(uploadedUrl);
      Navigator.pop(context);
    });
  }

  Future<void> _pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path ?? '');
      _isAfterFirstRecord = true;
      _uploadFile(file);
    }
  }

  @override
  void dispose() {
    audioRecord.dispose();
    _recorderController.dispose();
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
              child: const Text(
                "Note: The audio file will be used only for one record audio for one diary.",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            if (_isRecording)
              AudioWaveforms(
                enableGesture: false,
                size: Size(MediaQuery.of(context).size.width, 50),
                recorderController: _recorderController,
                waveStyle: const WaveStyle(
                  waveColor: Colors.blueAccent,
                  spacing: 5.0,
                  showMiddleLine: false,
                ),
              ),
            const SizedBox(height: 10),
            if (widget.isHasAudio || _isAfterFirstRecord) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _handleReplaceAudio();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Replace Audio"),
                ),
              ),
            ] else ...[
              // Show the Record Audio or Insert Audio File buttons if no audio exists
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isRecording ? Colors.red : Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isRecording ? "Stop Recording" : "Record Audio",
                    style: const TextStyle(color: Colors.white),
                  ),
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
          ],
        ),
      ),
    );
  }
}

// Uploading Dialog
class UploadingDialog extends StatelessWidget {
  const UploadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          CircularProgressIndicator(),
          SizedBox(height: 10),
          Text("Uploading..."),
        ],
      ),
    );
  }
}

//  Upload Success Dialog
class UploadSuccessDialog extends StatelessWidget {
  const UploadSuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, color: Colors.green, size: 50),
          SizedBox(height: 10),
          Text("Upload Complete!"),
        ],
      ),
    );
  }
}
