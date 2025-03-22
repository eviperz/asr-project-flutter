import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'dart:async';
import 'dart:developer';

import 'package:asr_project/services/asr_service.dart';
import 'package:path/path.dart' as path;

class EditAudioWidget extends StatefulWidget {
  final String audioName;
  final String initialTranscribe;

  const EditAudioWidget({
    super.key,
    required this.audioName,
    required this.initialTranscribe,
  });

  @override
  State<EditAudioWidget> createState() => _EditAudioWidgetState();
}

class _EditAudioWidgetState extends State<EditAudioWidget> {
  late QuillController _quillController;
  late audioplayers.AudioPlayer _audioPlayer;
  late StreamSubscription _playerStateSubscription;
  late StreamSubscription _durationSubscription;
  late StreamSubscription _positionSubscription;

  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _audioUrl;
  final AsrService _asrService = AsrService();
  late TextEditingController _audioNameController;
  late String _fileExtension;

  bool _isEdited = false;

  @override
  void initState() {
    super.initState();

    String fileNameWithoutExtension =
        path.basenameWithoutExtension(widget.audioName);
    _fileExtension = path.extension(widget.audioName);

    _quillController = QuillController(
      document: Document()..insert(0, widget.initialTranscribe),
      selection: const TextSelection.collapsed(offset: 0),
    );
    _quillController.addListener(() => setState(() => _isEdited = true));
    _audioNameController =
        TextEditingController(text: fileNameWithoutExtension);
    _audioPlayer = audioplayers.AudioPlayer();

    _playerStateSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == audioplayers.PlayerState.playing;
      });
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((d) {
      setState(() {
        _duration = d;
      });
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((p) {
      setState(() {
        _position = p;
      });
    });

    _fetchAudioUrl();

    // Detect changes in transcription
    _quillController.document.changes.listen((event) {
      setState(() {
        _isEdited = true;
      });
    });

    // Detect changes in audio name
    _audioNameController.addListener(() {
      if (_audioNameController.text != widget.audioName) {
        setState(() {
          _isEdited = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    _audioPlayer.dispose();
    _audioNameController.dispose();
    super.dispose();
  }

  /// **Fetch Audio URL**
  Future<void> _fetchAudioUrl() async {
    try {
      log("Fetching audio URL...");
      String url = await _asrService.getFileUrl(widget.audioName);
      if (url.isNotEmpty) {
        setState(() {
          _audioUrl = url;
        });
        log("Audio URL: $_audioUrl");
      }
    } catch (e) {
      log("Error fetching audio URL: $e");
    }
  }

  /// **Play Audio**
  Future<void> _play() async {
    if (_audioUrl == null) {
      log("No URL available.");
      return;
    }
    try {
      await _audioPlayer.setSourceUrl(_audioUrl!);
      await _audioPlayer.resume();
    } catch (e) {
      log("Error playing audio: $e");
    }
  }

  /// **Pause Audio**
  Future<void> _pause() async {
    await _audioPlayer.pause();
  }

  /// **Seek in Audio**
  void _seek(double value) {
    final position =
        Duration(milliseconds: (value * _duration.inMilliseconds).toInt());
    _audioPlayer.seek(position);
  }

  // void _confirmSave(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (context) => CustomDialog(
  //       title: "Save Changes?",
  //       content:
  //           "Do you want to save the changes to '${_audioNameController.text}'?",
  //       confirmLabel: "Save",
  //       cancelLabel: "Dismiss",
  //       onConfirm: () async {
  //         if (mounted) {
  //           await _saveChanges();

  //           Navigator.pop(context);
  //         }
  //       },
  //       onCancel: () {
  //         Navigator.pop(context);
  //       },
  //     ),
  //   );
  // }

  Future<void> _saveChanges() async {
    log("Saving changes...");

    setState(() {
      _isEdited = false;
    });

    String updatedAudioName = _audioNameController.text.trim() + _fileExtension;
    String updatedTranscription =
        _quillController.document.toPlainText().trim();

    log("Updated Audio Name: $updatedAudioName");
    log("Updated Transcription: $updatedTranscription");

    Navigator.pop(context, {
      "audioName": updatedAudioName,
      "transcription": updatedTranscription,
    });

    setState(() => _isEdited = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // leading: BackButton(
        //   onPressed: () =>
        //       _isEdited ? _confirmSave(context) : Navigator.pop(context),
        // ),
        title: const Text("Editing Transcription"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveChanges,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
              color: Colors.white24,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipOval(
                      child: IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                        onPressed: _isPlaying ? _pause : _play,
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                              Colors.deepPurpleAccent),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 150,
                      child: Slider(
                        onChanged: _seek,
                        value: _duration.inMilliseconds > 0
                            ? (_position.inMilliseconds /
                                    _duration.inMilliseconds)
                                .clamp(0.0, 1.0)
                            : 0.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text(
                        _position.toString().split('.').first,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _audioNameController,
              decoration: const InputDecoration(
                labelText: "Audio Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Transcription",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  child: QuillEditor.basic(
                    controller: _quillController,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
