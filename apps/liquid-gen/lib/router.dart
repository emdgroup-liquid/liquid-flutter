import 'package:go_router/go_router.dart';

import 'screens/main_screen.dart';
import 'settings/settings_screen.dart';

class AppRouter {
  AppRouter();

  late final router = GoRouter(
    debugLogDiagnostics: true, // Set to false in production
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const MainScreen(),
        ),
      ),
      GoRoute(
        path: '/settings',
        pageBuilder: (context, state) => NoTransitionPage<void>(
          key: state.pageKey,
          child: const SettingsScreen(),
        ),
      ),
    ],
  );
}
