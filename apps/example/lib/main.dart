import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:liquid/router.dart';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_window_utils/liquid_flutter_window_utils.dart';
import 'package:liquid_flutter_window_utils/screen_radius_defaults.dart';

import 'package:provider/provider.dart';

GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final searchFocusNode = FocusNode();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;

  // Window callbacks for macOS
  LdAppBarWidget.callbacks = LdWindowCallbacks(
    onClose: () {
      LiquidFlutterWindowUtils.instance.closeWindow();
    },
    onMinimize: () {
      LiquidFlutterWindowUtils.instance.minimizeWindow();
    },
    onMaximize: () {
      LiquidFlutterWindowUtils.instance.maximizeWindow();
    },
    onMove: () {
      LiquidFlutterWindowUtils.instance.startDragging();
    },
  );

  // Listen for window ready events
  LiquidFlutterWindowUtils.instance.windowReadyStream.listen((isReady) async {
    if (isReady) {
      // You can perform any initialization here that requires the window to be ready
      await LiquidFlutterWindowUtils.instance.configureWindow();
    }
  });

  final screenRadius = await getScreenRadius();

  // `LdWindowRoot` renders into Flutter's implicit view on mobile, web and
  // older Flutter versions, and into a native window when desktop windowing is
  // available. `runApp` is not an option because it requires the implicit view,
  // which hosts with windowing support do not create.
  runWidget(
    LdWindowRoot(
      title: 'Liquid Design Demo',
      size: const Size(1280, 900),
      constraints: const BoxConstraints(minWidth: 900, minHeight: 600),
      child: LiquidExample(screenRadius: screenRadius),
    ),
  );
}

class LiquidExample extends StatefulWidget {
  const LiquidExample({required this.screenRadius, super.key});

  final double screenRadius;

  @override
  State<LiquidExample> createState() => _LiquidExampleState();
}

class _LiquidExampleState extends State<LiquidExample> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<AppRouter>(
      create: (context) => AppRouter(),
      child: Builder(
        builder: (BuildContext context) {
          return CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.keyK, meta: true): () {
                searchFocusNode.requestFocus();
              },
              const SingleActivator(LogicalKeyboardKey.keyK, control: true): () {
                searchFocusNode.requestFocus();
              },
            },
            child: LdNotificationProvider(
              child: LdThemeProvider(
                screenRadius: Future.value(widget.screenRadius),
                windowMaximizedStream: LiquidFlutterWindowUtils.instance.windowMaximizedStream,
                child: LdThemedAppBuilder(
                  appBuilder: (context, theme) {
                    // We use a root navigator because else our nested navigation will not work
                    var router = context.read<AppRouter>().router;

                    return MaterialApp.router(
                      localizationsDelegates: LiquidLocalizations.localizationsDelegates,
                      locale: const Locale('en'),
                      title: 'Liquid Design Demo',
                      debugShowCheckedModeBanner: false,
                      theme: theme,
                      routerConfig: router,
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
