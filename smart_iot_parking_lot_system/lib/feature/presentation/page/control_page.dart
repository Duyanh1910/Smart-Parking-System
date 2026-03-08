import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_iot_parking_lot_system/feature/widget/control_page_widgets/control_progress_button.dart';

import '../../../core/provider_riverpod/websocket_provider.dart';
import '../../../core/theme/app_palette.dart';
import '../../widget/control_page_widgets/control_info_card.dart';
import '../../widget/control_page_widgets/control_plate_container.dart';

class ControlPage extends ConsumerStatefulWidget {
  const ControlPage({super.key});

  @override
  ConsumerState<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends ConsumerState<ControlPage> {
  @override
  void initState() {
    super.initState();
  }

  void sendCommand(String action) {
    try {
      final channel = ref.read(websocketChannelProvider);
      channel.sink.add(jsonEncode({"type": "cmd", "action": action}));
      print("📤 Sending command: $action");
    } catch (e) {
      print("❌ Không thể gửi lệnh WebSocket: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<Map<String, dynamic>>>(websocketProvider, (
      previous,
      next,
    ) {
      next.whenData((data) {
        switch (data["type"]) {
          case "door_state":
            final stateStr = data["state"].toString();
            int state = 2; // default = DUNG
            if (stateStr == "MO") {
              state = 1;
            } else if (stateStr == "DONG") {
              state = 0;
            } else if (stateStr == "DUNG") {
              state = 2;
            }
            ref.read(doorStateProvider.notifier).state = state;
            break;

          case "door_status":
            final status = data["status"].toString().toUpperCase();
            ref.read(onlineProvider.notifier).state = status == "ONLINE";
            break;

          case "NEW_PLATE":
            ref.read(licensePlateProvider.notifier).state = data["plate"]
                .toString();
            break;

          case "PLATE":
            ref.read(licensePlateProvider.notifier).state = data["plate"]
                .toString();
            break;
        }
      });
    });
    final doorState = ref.watch(doorStateProvider);
    final plate = ref.watch(licensePlateProvider);
    final isOnline = ref.watch(onlineProvider);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.go('/home'),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppPalette.primaryColor, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          "Điều khiển",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Automatic Door",
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Chip(
                          avatar: Icon(
                            isOnline ? Icons.wifi : Icons.wifi_off,
                            color: isOnline ? Colors.green : Colors.red,
                          ),
                          label: Text(
                            isOnline ? "Đang kết nối" : "Mất kết nối",
                            style: TextStyle(
                              color: isOnline
                                  ? Colors.green.shade700
                                  : Colors.red.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor: isOnline
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ControlInfoCard(
                      icon: Icons.door_front_door,
                      title: "Trạng thái cửa",
                      content: doorState == 0
                          ? "Đang đóng"
                          : doorState == 1
                          ? "Đang mở"
                          : "Dừng",
                      iconBackgroundColor: AppPalette.primaryColor.withValues(
                        alpha: 0.1,
                      ),
                      iconColor: AppPalette.primaryColor,
                      contentColor: doorState == 0
                          ? Colors.red
                          : doorState == 1
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Biển số xe",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(child: LicensePlateWidget(plateNumber: plate)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Điều khiển cửa",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    ControlProgressButton(
                      title: "Mở cửa",
                      onPressed: () async {
                        sendCommand("open");
                      },
                      icons: Icons.lock_open_outlined,
                      idleColor: Colors.green.shade400,
                    ),
                    const SizedBox(height: 15),
                    ControlProgressButton(
                      title: "Đóng cửa",
                      onPressed: () async {
                        sendCommand("close");
                      },
                      icons: Icons.lock_open_outlined,
                      idleColor: Colors.red.shade400,
                    ),
                    const SizedBox(height: 15),
                    ControlProgressButton(
                      title: "Dừng cửa",
                      onPressed: () async {
                        sendCommand("stop");
                      },
                      icons: Icons.play_arrow_outlined,
                      idleColor: Colors.orangeAccent,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
