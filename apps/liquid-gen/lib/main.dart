import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_window_utils/liquid_flutter_window_utils.dart';

import 'package:provider/provider.dart';

import 'router.dart';
import 'schema/api_schema.dart';

void main() async {
  // 1. Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Configure GoRouter (if using go_router)
  GoRouter.optionURLReflectsImperativeAPIs = true;

  // 3. Set up window callbacks for desktop platforms
  LdAppBar.callbacks = LdWindowCallbacks(
    onClose: () => LiquidFlutterWindowUtils.instance.closeWindow(),
    onMinimize: () => LiquidFlutterWindowUtils.instance.minimizeWindow(),
    onMaximize: () => LiquidFlutterWindowUtils.instance.maximizeWindow(),
    onMove: () => LiquidFlutterWindowUtils.instance.startDragging(),
  );

  // 4. Listen for window ready events and configure window
  LiquidFlutterWindowUtils.instance.windowReadyStream.listen((isReady) async {
    if (isReady) {
      await LiquidFlutterWindowUtils.instance.configureWindow();
    }
  });

  // 5. Load API schema
  try {
    await ApiSchema.instance.load();
  } catch (e) {
    debugPrint('Warning: Failed to load API schema: $e');
  }

  // 6. Run the app
  runApp(const LiquidGenApp());
}

class LiquidGenApp extends StatefulWidget {
  const LiquidGenApp({super.key});

  @override
  State<LiquidGenApp> createState() => _LiquidGenAppState();
}

class _LiquidGenAppState extends State<LiquidGenApp> {
  @override
  Widget build(BuildContext context) {
    return Provider<AppRouter>(
      create: (context) => AppRouter(),
      child: Builder(
        builder: (BuildContext context) {
          return LdNotificationProvider(
            child: LdThemeProvider(
              screenRadiusStream: LiquidFlutterWindowUtils.instance.screenRadiusStream,
              child: LdThemedAppBuilder(
                appBuilder: (context, theme) {
                  final router = context.read<AppRouter>().router;
                  return MaterialApp.router(
                    localizationsDelegates: LiquidLocalizations.localizationsDelegates,
                    title: 'Liquid Gen',
                    debugShowCheckedModeBanner: false,
                    theme: theme,
                    routerConfig: router,
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
