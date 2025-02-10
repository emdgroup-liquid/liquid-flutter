import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:liquid/router.dart';

import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:provider/provider.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GoRouter.optionURLReflectsImperativeAPIs = true;

  await Highlighter.initialize(['dart', 'yaml', 'sql']);

  runApp(const LiquidExample());

  if (!kIsWeb && Platform.isMacOS) {
    doWhenWindowReady(() {
      const initialSize = Size(1000, 800);
      appWindow.minSize = const Size(100, 100);
      appWindow.size = initialSize;

      appWindow.alignment = Alignment.center;
      appWindow.show();
    });
  }
}

class LiquidExample extends StatefulWidget {
  const LiquidExample({Key? key}) : super(key: key);

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
        child: Builder(builder: (BuildContext context) {
          return LdNotificationProvider(child: LdThemeProvider(
            child: LdThemedAppBuilder(appBuilder: (context, theme) {
              // We use a root navigator because else our nested navigation will not work
              var router = context.read<AppRouter>().router;

              return MaterialApp.router(
                localizationsDelegates:
                    LiquidLocalizations.localizationsDelegates,
                locale: const Locale('en'),
                title: 'Liquid Design Demo',
                debugShowCheckedModeBanner: false,
                theme: theme,
                routerConfig: router,
              );
            }),
          ));
        }));
  }
}
