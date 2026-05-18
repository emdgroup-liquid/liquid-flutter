import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';
import 'package:liquid_flutter_test_utils/golden_utils.dart';
import 'package:liquid_flutter_test_utils/system_ui/system_overlays.dart';

/// Create a frame for a widget to be used in golden tests.
Widget ldFrame({
  required Widget child,
  LdThemeBrightnessMode brightnessMode = LdThemeBrightnessMode.light,
  LdThemeSize? size,
  LdFrameOptions ldFrameOptions = const LdFrameOptions(),
  Orientation orientation = Orientation.portrait,
  bool showBackButton = false,
}) {
  GoRouter router(Function(BuildContext, GoRouterState) app) {
    return GoRouter(
      initialLocation: showBackButton ? '/child' : '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => app(context, state),
          routes: [
            GoRoute(
              path: 'child',
              builder: (context, state) => app(context, state),
            ),
          ],
        ),
      ],
    );
  }

  return KeyedSubtree(
    child: LdThemeProvider(
      size: size,
      platform: ldFrameOptions.platform,
      brightnessMode: brightnessMode,
      child: LdThemedAppBuilder(
        appBuilder: (context, theme) => MaterialApp.router(
          theme: theme,
          debugShowCheckedModeBanner: false,
          locale: LiquidLocalizations.supportedLocales.first,
          supportedLocales: LiquidLocalizations.supportedLocales,
          localizationsDelegates: [
            ...ldGoldenLocalizationsDelegates,
            ...LiquidLocalizations.localizationsDelegates,
          ],
          routerConfig: router(
            (context, state) {
              var padding = ldFrameOptions.viewPaddig;

              if (orientation == Orientation.landscape) {
                // Rotate the padding, left
                padding = EdgeInsets.only(
                  left: padding.top,
                  top: padding.right,
                  right: padding.bottom,
                  bottom: padding.left,
                );
              }

              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  viewPadding: padding,
                  padding: padding,
                  viewInsets: padding,
                ),
                child: SystemOverlayDetector(
                  builder: (context, style) {
                    if (ldFrameOptions.build != null) {
                      return ldFrameOptions.build!(
                        context,
                        orientation,
                        switch (style) {
                          null => switch (brightnessMode) {
                              LdThemeBrightnessMode.light => SystemUiOverlayStyle.dark,
                              LdThemeBrightnessMode.dark => SystemUiOverlayStyle.light,
                              _ => null
                            },
                          _ => style,
                        },
                        child,
                      );
                    }

                    return child;
                  },
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
