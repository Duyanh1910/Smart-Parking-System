import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:smart_iot_parking_lot_system/feature/presentation/page/history_page.dart';
import 'package:smart_iot_parking_lot_system/feature/presentation/page/home_page.dart';
import 'package:smart_iot_parking_lot_system/feature/presentation/page/notify_page.dart';
import '../../feature/presentation/page/control_page.dart';
import '../../feature/presentation/page/login_page.dart';
import '../../feature/presentation/page/profile_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRoute {
  static late GoRouter appRouter;

  static void init({required bool isLoggedIn}) {
    appRouter = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: isLoggedIn ? '/home' : '/login',
      routes: <RouteBase>[
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
        GoRoute(path: '/history', builder: (context, state) => const HistoryPage()),
        GoRoute(
          path: '/control',
          builder: (BuildContext context, GoRouterState state) {
            return ControlPage();
          },
        ),
        GoRoute(path: '/notify', builder: (context, state) => const NotifyPage()),
      ],
    );
  }
}
