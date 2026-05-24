import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:liquid/router.dart';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_window_utils/liquid_flutter_window_utils.dart';
//import 'package:liquid_flutter_window_utils/liquid_flutter_window_utils.dart';

import 'package:provider/provider.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final searchFocusNode = FocusNode();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoRouter.optionURLReflectsImperativeAPIs = true;

  await Highlighter.initialize(['dart', 'yaml', 'sql']);

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

  runApp(const LiquidExample());
}

class LiquidExample extends StatefulWidget {
  const LiquidExample({super.key});

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
                screenRadiusStream: LiquidFlutterWindowUtils.instance.screenRadiusStream,
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
