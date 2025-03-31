import 'dart:async';
import 'dart:collection';
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
  late StreamController<String> _transcriptionStreamController =
      StreamController.broadcast();
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
  String _currentAudioName = "";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentAudioName = widget.audioName;
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

  final Queue<String> _chunkQueue = Queue<String>();
  Completer<void>? _processingCompleter;

  Future<void> eachChunk(String chunk) async {
    _chunkQueue.add(chunk);

    if (_processingCompleter != null && !_processingCompleter!.isCompleted) {
      await _processingCompleter!.future;
    }

    _processingCompleter = Completer<void>();

    while (_chunkQueue.isNotEmpty) {
      String currentChunk = _chunkQueue.removeFirst();

      if (!mounted) break;

      setState(() {
        _transcribeResult += "$currentChunk ";
      });

      if (!_transcriptionStreamController.isClosed) {
        _transcriptionStreamController.add(_transcribeResult);
      }

      widget.onTranscribe(_transcribeResult);
      await Future.delayed(Duration(seconds: 3));
    }

    _processingCompleter?.complete();
    setState(() {
      _isLoading = false;
    });
  }

  void _transcribeAudio() {
    setState(() {
      _isLoading = true;
      _transcribeResult = "";
    });

    try {
      _transcriptionStreamController.close();
      _transcriptionStreamController = StreamController.broadcast();
      _asrSocketService.sendAudioForTranscription(_audioUrl!, eachChunk);
    } catch (e) {
      log("Error during transcription: $e");
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
        color: Theme.of(context).colorScheme.secondary,
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
                    color: Theme.of(context).colorScheme.secondary,
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
                                        Theme.of(context)
                                            .colorScheme
                                            .inversePrimary),
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
                              activeColor:
                                  Theme.of(context).colorScheme.inversePrimary,
                              inactiveColor: Theme.of(context)
                                  .colorScheme
                                  .onInverseSurface,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Text(
                              _position.toString().split('.').first,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onInverseSurface,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Audio File",
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
                          ),
                    ),
                    Text(
                      _currentAudioName,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _transcribeAudio,
                          child: Text("Transcribe Audio"),
                        ),
                        Visibility(
                          visible: _isLoading,
                          child: SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.arrow_forward,
                            color:
                                Theme.of(context).colorScheme.onInverseSurface,
                          ),
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
                                  _currentAudioName =
                                      result["audioName"] ?? _currentAudioName;
                                  _transcribeResult = result["transcription"] ??
                                      _transcribeResult;
                                });
                                widget.onAudioNameChange(_currentAudioName);
                                widget.onTranscribe(_transcribeResult);
                              }
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    if (_isLoading)
                      StreamBuilder<String>(
                        stream: _transcriptionStreamController.stream,
                        builder: (context, snapshot) {
                          return Text(
                            snapshot.data ?? "กำลังแปลงเสียง...",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onInverseSurface),
                          );
                        },
                      )
                    else
                      Text(
                        _truncateText(_transcribeResult, 150),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontStyle: FontStyle.italic,
                            color:
                                Theme.of(context).colorScheme.onInverseSurface),
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
