import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../config/app_route.dart';
import '../provider_riverpod/websocket_provider.dart';
import 'dialog_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
bool _isPlateDialogOpen = false;
void showPlateDialog(String plate, WidgetRef ref) {
  if (_isPlateDialogOpen) return;
  _isPlateDialogOpen = true;
  debugPrint("🚗 Hiện hộp thoại");
  final context = navigatorKey.currentState?.overlay?.context;
  if (context == null) return;
  String? currentRoute = ModalRoute.of(context)?.settings.name;
  if (currentRoute == '/login') return;

  AppDialogs.show(
    context,
    thirdButton: true,
    type: DialogType.warning,
    title: "Thông báo",
    desc: "Phát hiện biển số xe mới: $plate\nCó cho phép mở cửa không?",
    okText: "Có",
    neutralText: "Có (lưu CSDL)",
    cancelText: "Không",
    onCancel: () {
      _isPlateDialogOpen = false;
      return;
    },
    onConfirm: () {
      _isPlateDialogOpen = false;
      final channel = ref.read(websocketChannelProvider);
      channel.sink.add(jsonEncode({
        "type": "cmd",
        "action": "open_nodatabase",
        "plate": plate,
      }));
    },
    onNeutral: (){
      _isPlateDialogOpen = false;
      final channel = ref.read(websocketChannelProvider);
      channel.sink.add(jsonEncode({
        "type": "cmd",
        "action": "open_database",
        "plate": plate,
      }));
    }
  );
}