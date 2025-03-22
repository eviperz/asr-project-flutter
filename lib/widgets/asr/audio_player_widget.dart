import 'dart:async';
import 'dart:developer';
import 'package:asr_project/services/asr_socket_service.dart';
import 'package:asr_project/widgets/asr/edit_audio_widget.dart';
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:flutter/material.dart';
import 'package:asr_project/services/asr_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioName;
  final String initialTranscribe;
  final Function(String) onTranscribe;
  final Function(String) onAudioNameChange;

  const AudioPlayerWidget({
    super.key,
    required this.audioName,
    required this.initialTranscribe,
    required this.onTranscribe,
    required this.onAudioNameChange,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AsrService _asrService = AsrService();
  final AsrSocketService _asrSocketService = AsrSocketService();
  late audioplayers.AudioPlayer _audioPlayer;
  late StreamSubscription _playerStateSubscription;
  late StreamSubscription _durationSubscription;
  late StreamSubscription _positionSubscription;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _audioUrl;
  String _transcribeResult = "";
  late String _currentAudioName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
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

    _transcribeResult = widget.initialTranscribe;
    _currentAudioName = widget.audioName;

    _fetchAudioUrl();
    _asrSocketService.initSocket();
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    _audioPlayer.dispose();
    _asrSocketService.disconnect(); // Disconnect Socket.IO
    super.dispose();
  }

  Future<void> _fetchAudioUrl() async {
    try {
      log("Fetching audio URL...");
      String url = await _asrService.getFileUrl(widget.audioName);
      if (url.isNotEmpty) {
        setState(() {
          _audioUrl = url;
        });
        log("Audio URL: $_audioUrl");
      } else {
        throw Exception("Invalid URL");
      }
    } catch (e) {
      log("Error fetching audio URL: $e");
    }
  }

  Future<void> _play() async {
    if (_audioUrl == null) {
      log("No URL available, waiting...");
      return;
    }

    try {
      await _audioPlayer.setSourceUrl(_audioUrl!);
      await _audioPlayer.resume();
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      log("Error playing audio: $e");
    }
  }

  Future<void> _pause() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  void _seek(double value) {
    final position =
        Duration(milliseconds: (value * _duration.inMilliseconds).toInt());
    _audioPlayer.seek(position);
  }

  void eachChunk(dynamic chunk) {
    if (chunk is String) {
      setState(() {
        if (!_transcribeResult.contains(chunk)) {
          _transcribeResult += chunk;
        }
      });
    } else if (chunk is Map) {
      String transcriptionChunk = chunk['enhanced_text_chunk'] ?? '';

      print('Text in widget: $transcriptionChunk');

      if (transcriptionChunk.isNotEmpty &&
          !_transcribeResult.contains(transcriptionChunk)) {
        setState(() {
          _transcribeResult += transcriptionChunk;
        });
      }
    }

    // Debugging print for current transcription state
    print("Current Transcription: $_transcribeResult");

    // Call the widget callback to notify parent of updated transcription
    widget.onTranscribe(_transcribeResult);
  }

  Future<void> _transcribeAudio() async {
    setState(() {
      _isLoading = true;
      _transcribeResult = "";
    });

    try {
      _asrSocketService.sendAudioForTranscription(_audioUrl!, eachChunk);
    } catch (e) {
      log("Error during transcription: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;

    int lastSpace = text.lastIndexOf(' ', maxLength);
    if (lastSpace == -1) lastSpace = maxLength;

    return text.substring(0, lastSpace) + '...';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Wrap(
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
                              icon: Icon(
                                  _isPlaying ? Icons.pause : Icons.play_arrow),
                              onPressed: _isPlaying ? _pause : _play,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
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
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Audio: "),
                        Expanded(
                          child: Text(_currentAudioName),
                        ),
                        IconButton(
                            icon: Icon(Icons.arrow_forward),
                            onPressed: () async {
                              if (_audioUrl != null) {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditAudioWidget(
                                      audioName: _currentAudioName,
                                      initialTranscribe: _transcribeResult,
                                    ),
                                  ),
                                );

                                if (result != null &&
                                    result is Map<String, String>) {
                                  setState(() {
                                    _currentAudioName = result["audioName"] ??
                                        _currentAudioName;
                                    _transcribeResult =
                                        result["transcription"] ??
                                            _transcribeResult;
                                  });
                                  widget.onAudioNameChange(_currentAudioName);
                                  widget.onTranscribe(_transcribeResult);
                                }
                              }
                            }),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _transcribeAudio,
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text("Transcribe Audio"),
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Text(
                            _transcribeResult.isNotEmpty
                                ? "Transcription: ${_truncateText(_transcribeResult, 150)}"
                                : "No transcription available",
                            style: TextStyle(
                                fontSize: 16, fontStyle: FontStyle.italic),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
