
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_route.dart';
import '../helper/shared_preferences.dart';
import "../../core/helper/permission_dialog.dart";

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Notifications for important events',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  final title = message.data['title'] ?? 'Thông báo';
  final body = message.data['body'] ?? '';

  await flutterLocalNotificationsPlugin.show(
    message.hashCode,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      ),
    ),
    payload: message.data['plate'],
  );
}

class FirebaseMessagingService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Notifications for important events',
    importance: Importance.high,
    playSound: true,
  );

  static RemoteMessage? latestMessage;

  static Future<void> initFCM(WidgetRef ref) async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) async {
        if (latestMessage != null) {
          _navigateToControl(latestMessage!, ref);
        }
      },
    );

    await _messaging.requestPermission(alert: true, badge: true, sound: true);

    final token = await _messaging.getToken();
    debugPrint('🚗 FCM Token: $token');

    FirebaseMessaging.onMessage.listen((message) {
      debugPrint("🚗 Nhận FCM foreground");
      latestMessage = message;
      _showLocalNotification(message);
      _handlePlate(message, ref);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      latestMessage = message;
      _navigateToControl(message, ref);
    });

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      latestMessage = initialMessage;
      _navigateToControl(initialMessage, ref);
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final title =
        message.data['title'] ?? message.notification?.title ?? 'Thông báo';
    final body =
        message.data['body'] ?? message.notification?.body ?? '';

    await _flutterLocalNotificationsPlugin.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: message.data['plate'],
    );
  }

  static Future<void> _navigateToControl(
      RemoteMessage message, WidgetRef ref) async {
    final isLoggedIn = await SharedPref.checkLogin();
    final plate = message.data['plate'];

    if (isLoggedIn) {
      if (plate != null) {
        _handlePlate(message,ref);
      }
    } else {
      AppRoute.appRouter.go('/login', extra: message.data);
    }
  }

  static void _handlePlate(RemoteMessage message, WidgetRef ref) {
    final plate = message.data['plate'];
    if (plate != null) {
        showPlateDialog(plate, ref);
    }
  }
}