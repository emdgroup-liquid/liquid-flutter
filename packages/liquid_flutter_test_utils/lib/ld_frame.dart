import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';
import 'package:liquid_flutter_test_utils/golden_utils.dart';
import 'package:liquid_flutter_test_utils/ld_theme_wrapper.dart';
import 'package:liquid_flutter_test_utils/system_ui/system_overlays.dart';

/// Create a frame for a widget to be used in golden tests.
Widget ldFrame({
  required Key key,
  required Widget child,
  required bool dark,
  required LdThemeSize size,
  required LdFrameOptions ldFrameOptions,
  required Orientation orientation,
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
    // force a new subtree each time a new frame is created in order to avoid
    // state issues
    key: UniqueKey(),
    child: ldThemeWrapper(
      size: size,
      brightnessMode:
          dark ? LdThemeBrightnessMode.dark : LdThemeBrightnessMode.light,
      child: LdThemedAppBuilder(
        appBuilder: (context, theme) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: theme.copyWith(
            platform: ldFrameOptions.targetPlatform,
          ),
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
                child: KeyedSubtree(
                  key: key,
                  child: SystemOverlayDetector(
                    builder: (context, style) {
                      if (ldFrameOptions.build != null) {
                        return ldFrameOptions.build!(
                          context,
                          orientation,
                          child,
                          dark,
                          style ??
                              (!dark
                                  ? SystemUiOverlayStyle.dark
                                  : SystemUiOverlayStyle.light),
                        );
                      }

                      return child;
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
