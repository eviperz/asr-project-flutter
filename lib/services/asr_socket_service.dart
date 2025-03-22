import 'package:socket_io_client/socket_io_client.dart' as IO;

class AsrSocketService {
  late IO.Socket _socket;
  Function(String)? _onTranscriptionChunk;

  /// Initialize the Socket.IO connection
  void initSocket() {
    print("Initializing socket...");

    _socket = IO.io('http://192.168.1.35:5114', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'forceNew': true,
    });

    _socket.onConnect((_) {
      print('✅ Connected to Model Asr server');
    });

    _socket.on('audio_processed_chunk', (chunk) {
      print('📩 Received text chunk: $chunk');
      if (_onTranscriptionChunk != null) {
        _onTranscriptionChunk!(chunk);
      }
    });

    _socket.onDisconnect((_) {
      print('❌ Disconnected from Model Asr server');
    });

    _socket.connect();
  }

  /// Send audio file URL for transcription
  void sendAudioForTranscription(
      String audioUrl, Function(String) onChunkReceived) {
    _onTranscriptionChunk = onChunkReceived;
    _socket.emit('process_audio', {'audioUrl': audioUrl});
  }

  // void sendAudioForTranscription(
  //     String audioUrl, Function(String) onTranscriptionChunk) {
  //   _onTranscriptionChunk = onTranscriptionChunk;

  //   // print('📤 Sending audio for transcription: $audioName');
  //   _socket.emit('process_audio', {'audioUrl': audioUrl});
  // }

  void disconnect() {
    print("🔌 Disconnecting socket...");
    _socket.disconnect();
  }
}
