import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:flutter/material.dart';
import 'package:asr_project/services/asr_service.dart';
import 'package:flutter/services.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioName;
  final String transcribe;
  final AsrService _asrService = AsrService();

  AudioPlayerWidget({super.key, required this.audioName, this.transcribe = ""});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late audioplayers.AudioPlayer _audioPlayer;
  late StreamSubscription _playerStateSubscription;
  late StreamSubscription _durationSubscription;
  late StreamSubscription _positionSubscription;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _audioUrl; // Store URL for reuse
  String _transcribeResult = "";
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

    _fetchAudioUrl(); // Get URL on init
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  /// **Fetch audio URL only once**
  Future<void> _fetchAudioUrl() async {
    try {
      log("Fetching audio URL...");
      String url = await widget._asrService.getFileUrl(widget.audioName);
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

  /// **Play or Resume Audio**
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

  /// **Pause Audio**
  Future<void> _pause() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  /// **Seek in Audio**
  void _seek(double value) {
    final position =
        Duration(milliseconds: (value * _duration.inMilliseconds).toInt());
    _audioPlayer.seek(position);
  }

  Future<void> _transcribeAudio() async {
    setState(() {
      _isLoading = true; // Start loading when the request is made
    });

    try {
      final result = await widget._asrService.transcribeText(widget.audioName);
      setState(() {
        _transcribeResult = result;
        _isLoading = false; // Stop loading when transcription is done
      });
    } catch (e) {
      setState(() {
        _transcribeResult = "Error: $e";
        _isLoading = false; // Stop loading even if there's an error
      });
    }
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
                          child: Text(widget.audioName),
                        ),
                        IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            if (_audioUrl != null) {
                              Clipboard.setData(
                                  ClipboardData(text: _audioUrl!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("URL copied!")),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _transcribeAudio,
                      child: Text("Transcribe Audio"),
                    ),
                    // Display the transcription result as a Text widget
                    SizedBox(height: 20),
                    _isLoading
                        ? Center(child: CircularProgressIndicator())
                        : Text(
                            _transcribeResult.isNotEmpty
                                ? "Transcription: $_transcribeResult"
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
