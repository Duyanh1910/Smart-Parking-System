import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_iot_parking_lot_system/core/config/config.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final websocketController = StreamController<Map<String, dynamic>>.broadcast();

final websocketChannelProvider = Provider<WebSocketChannel>((ref) {
  late WebSocketChannel channel;
  Timer? reconnectTimer;

  void connect() {
    print("🔌 Connecting WebSocket...");
    channel = WebSocketChannel.connect(Uri.parse(Config.websocketUrl));

    channel.stream.listen(
      (event) {
        try {
          final data = json.decode(event) as Map<String, dynamic>;
          websocketController.add(data);
        } catch (_) {}
      },
      onDone: () {
        print("❌ WebSocket closed → reconnect sau 3s");
        reconnectTimer = Timer(const Duration(seconds: 3), connect);
      },
      onError: (e) {
        print("⚠️ WebSocket error: $e → reconnect sau 3s");
        reconnectTimer = Timer(const Duration(seconds: 3), connect);
      },
    );
  }

  connect();

  ref.onDispose(() {
    print("🗑 Dispose websocket");
    reconnectTimer?.cancel();
    channel.sink.close();
    websocketController.close();
  });

  return channel;
});

// StreamProvider dùng broadcast stream
final websocketProvider = StreamProvider<Map<String, dynamic>>(
  (ref) => websocketController.stream,
);

final heartbeatProvider = Provider((ref) {
  final channel = ref.watch(websocketChannelProvider);
  final timer = Timer.periodic(const Duration(seconds: 30), (_) {
    channel.sink.add(jsonEncode({"type": "ping"}));
    print("💓 WS ping");
  });
  ref.onDispose(() => timer.cancel());
});
final doorStateProvider = StateProvider<int>((ref) => 1);
final onlineProvider = StateProvider<bool>((ref) => false);
final licensePlateProvider = StateProvider<String>((ref) => "");
