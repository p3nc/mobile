import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

enum SocketState { disconnected, connecting, connected, reconnecting }

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  factory SocketManager() => _instance;
  SocketManager._internal();

  SocketState state = SocketState.disconnected;
  final StreamController<Map<String, dynamic>> _streamController = StreamController.broadcast();
  WebSocketChannel? _channel;

  Stream<Map<String, dynamic>> get stream => _streamController.stream;

  Future<void> connect(String url) async {
    if (state == SocketState.connected || state == SocketState.connecting) return;

    state = SocketState.connecting;
    _streamController.add({'type': 'state_change', 'state': state.name});

    try {

      await Future.delayed(const Duration(milliseconds: 100));

      _channel = WebSocketChannel.connect(Uri.parse(url));
      state = SocketState.connected;
      _streamController.add({'type': 'state_change', 'state': state.name});

      _channel!.stream.listen(
            (message) => _streamController.add(jsonDecode(message)),
        onDone: () => disconnect(),
        onError: (_) => reconnect(url),
      );
    } catch (e) {
      reconnect(url);
    }
  }

  void disconnect() {
    _channel?.sink.close();
    state = SocketState.disconnected;
    _streamController.add({'type': 'state_change', 'state': state.name});
  }

  void reconnect(String url) {
    disconnect();
    state = SocketState.reconnecting;
    _streamController.add({'type': 'state_change', 'state': state.name});
    Future.delayed(const Duration(seconds: 3), () => connect(url));
  }
}