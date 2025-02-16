import 'dart:async';

import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:flutter/material.dart';

class AudioPlayer extends StatefulWidget {
  final String audioUrl;
  const AudioPlayer({
    super.key,
    required this.audioUrl,
  });

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  late audioplayers.AudioPlayer _audioPlayer;
  late StreamSubscription _playerStateSubscription;
  late StreamSubscription _durationSubscription;
  late StreamSubscription _positionSubscription;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    _audioPlayer = audioplayers.AudioPlayer();

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged
        .listen((audioplayers.PlayerState state) {
      setState(() {
        _isPlaying = state == audioplayers.PlayerState.playing;
      });
    });

    _durationSubscription = _audioPlayer.onDurationChanged.listen((Duration d) {
      setState(() {
        _duration = d;
      });
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((Duration p) {
      setState(() {
        _position = p;
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _playerStateSubscription.cancel();
    _durationSubscription.cancel();
    _positionSubscription.cancel();

    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _play() async {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    await _audioPlayer.play(audioplayers.UrlSource(widget.audioUrl));
  }

  void _pause() async {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    await _audioPlayer.pause();
  }

  void _seek(double value) {
    final position =
        Duration(milliseconds: (value * _duration.inMilliseconds).toInt());
    _audioPlayer.seek(position);
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
                    shape: RoundedRectangleBorder(
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
                              onPressed: !_isPlaying ? _play : _pause,
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
                  TextButton(
                    onPressed: () {},
                    child: Wrap(
                      spacing: 8,
                      children: [
                        Text("Edit ASR Text"),
                        Icon(Icons.arrow_forward_outlined),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 20.0),
                child: Text(
                  widget.audioUrl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
