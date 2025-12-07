import 'package:check_in_qr/presentation/pages/home/home_screen.dart';
import 'package:check_in_qr/routers/router_name.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../presentation/pages/auth/login_screen.dart';
import '../presentation/pages/home/check_in_scanner_screen.dart';
import '../presentation/view_models/auth_change_notifier.dart';

class AppRouter {
  final GoRouter router;
  AppRouter(AuthChangeNotifier authNotifier)
    : router = GoRouter(
        initialLocation: RouterPath.login,
        debugLogDiagnostics: true,
        errorBuilder: (context, state) => Scaffold(
          body: Center(child: Text('Page not found2: ${state.uri.toString()}')),
        ),
        routes: [
          GoRoute(
            path: RouterPath.login,
            builder: (context, state) => LoginScreen(),
          ),
          GoRoute(
            path: RouterPath.home,
            builder: (context, state) => HomeScreen(),
          ),
          GoRoute(
            path: RouterPath.check_in,
            builder: (context, state) {
              final eventId = state.extra as String;   // nhận từ extra
              return CheckInScannerScreen(eventId: eventId);
            },
          ),

        ],
        redirect: (context, state) async {},
        refreshListenable: authNotifier,
      ) {}
}
