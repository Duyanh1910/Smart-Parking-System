import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import '../helper/permission_dialog.dart';
import '../helper/shared_preferences.dart';
import '../provider_riverpod/websocket_provider.dart';
import 'firebase_messaging_service.dart';

class WebSocketListener extends ConsumerStatefulWidget {
  final Widget child;

  const WebSocketListener({super.key, required this.child});

  @override
  ConsumerState<WebSocketListener> createState() => _WebSocketListenerState();
}

class _WebSocketListenerState extends ConsumerState<WebSocketListener> {
  late ProviderSubscription sub;

  @override
  void initState() {
    super.initState();

    FirebaseMessagingService.initFCM(ref);

    sub = ref.listenManual(
      websocketProvider,
          (prev, next) async {
        final data = next.value;

        if (data['type'] == "NEW_PLATE") {
          final plate = data['plate'];
          final isLoggedIn = await SharedPref.checkLogin();
          if (isLoggedIn) {
            showPlateDialog(plate, ref);
          }
        }
      },
    );
  }

  @override
  void dispose() {
    sub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
