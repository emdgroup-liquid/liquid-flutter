import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/golden_utils.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:liquid_flutter_test_utils/widget_tree_test.dart';

extension _LabelThemeSize on LdThemeSize {
  String get label => toString().split(".").last.toUpperCase();
}

extension _LabelBrightness on Brightness {
  String get label => toString().split(".").last;
}

extension _LabelOrientation on Orientation {
  String get label => toString().split(".").last;
}

typedef GoldenWidgetBuilder = Future<void> Function(
  WidgetTester tester,
  Future<void> Function(Widget widget) placeWidget,
);

/// Renders [finder] to a PNG at [pngPath] for widget-tree golden failures.
///
/// Uses the same [captureImage] + [WidgetTester.runAsync] pattern as Flutter's
/// golden matchers. Calling [RenderRepaintBoundary.toImage] / [Image.toByteData]
/// directly in a widget test can block the test process indefinitely.
Future<void> writeFailureScreenshot(
  WidgetTester tester,
  Finder finder,
  String pngPath,
) async {
  await tester.pumpAndSettle();
  final element = tester.element(finder);
  await tester.runAsync(() async {
    final image = await _captureElementImage(element);
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        final pngFile = File(pngPath);
        pngFile.parent.createSync(recursive: true);
        pngFile.writeAsBytesSync(byteData.buffer.asUint8List());
      }
    } finally {
      image.dispose();
    }
  });
}

/// Same approach as [captureImage] in `package:flutter_test` (`_matchers_io.dart`).
Future<ui.Image> _captureElementImage(Element element) {
  RenderObject renderObject = element.renderObject!;
  while (!renderObject.isRepaintBoundary) {
    renderObject = renderObject.parent!;
  }
  assert(!renderObject.debugNeedsPaint);
  final layer = renderObject.debugLayer! as OffsetLayer;
  return layer.toImage(renderObject.paintBounds);
}

/// Resets the [tester] to a clean state to prevent test contamination.
///
/// Call this after tests that modify tester view (devicePixelRatio,
/// physicalSize), binding (setSurfaceSize), or global state. Use in tearDown
/// or at the end of multiGolden to ensure subsequent tests start clean.
Future<void> resetTester(WidgetTester tester) async {
  // Reset view properties (devicePixelRatio, physicalSize, etc.)
  final view = tester.view;
  view.reset();
  // Reset surface size to default
  await tester.binding.setSurfaceSize(null);
}

/// Helper function to generate golden tests for multiple themes and sizes
/// for multiple widgets of the same scope (e.g. one screen with different
/// states).
Future<void> multiGolden(
  /// The [tester] instance to use for the tests.
  WidgetTester tester,

  /// The name of the golden test.
  String name,

  /// A map of widget builders for various scenarios (e.g. "Default", "Error").
  Map<String, GoldenWidgetBuilder> widgets, {
  /// The [LdFrameOptions] to use for the tests. Now a list, defaults to one entry.
  List<LdFrameOptions> frameScenarios = const [LdFrameOptions()],

  /// Whether to perform widget tree tests as well.
  bool performWidgetTreeTests = true,

  /// The [ThemeSize] scenarios to test.
  List<LdThemeSize> themeSizeScenarios = LdThemeSize.values,

  /// The [Brightness] scenarios to test.
  List<Brightness> brightnessScenarios = Brightness.values,

  /// The [Orientation] scenarios to test.
  List<Orientation> orientationScenarios = const [Orientation.portrait],

  /// Whether to clip the screen to the screen radius.
  bool clipScreenToRadius = true,

  /// Optional per-scenario [WidgetTreeOptions] overrides.
  ///
  /// Keys must match the keys in [widgets]. When a scenario key is present
  /// here, these options are merged on top of the default options (only
  /// [goldenName] is always derived from the slug and cannot be overridden).
  Map<String, WidgetTreeOptions> widgetTreeOptionsOverrides = const {},
}) async {
  // Save global state to restore on exit (prevents test contamination)
  final savedDebugDisableShadows = debugDisableShadows;
  final savedLdDisableAnimations = ldDisableAnimations;
  final savedLdIncludeFontPackage = ldIncludeFontPackage;

  try {
    debugDisableShadows = false;
    ldDisableAnimations = true;
    ldIncludeFontPackage = false;
    await loadAppFonts();

    // Track if any test fails
    List<String> failureMessages = [];

    // For each frame options, scenario, theme size, and brightness ...
    for (final ldFrameOptions in frameScenarios) {
      final frameLabel = ldFrameOptions.label;
      for (final entry in widgets.entries) {
        for (final themeSize in themeSizeScenarios) {
          for (final brightness in brightnessScenarios) {
            for (final orientation in orientationScenarios) {
              await resetTester(tester);

              final slug = "${entry.key}/${[
                if (themeSizeScenarios.length > 1) themeSize.label,
                if (brightnessScenarios.length > 1) brightness.label,
                if (frameScenarios.length > 1) frameLabel,
                if (orientationScenarios.length > 1) orientation.label,
              ].join("_")}";

              // Apply device pixel ratio from ldFrameOptions
              tester.view.devicePixelRatio = ldFrameOptions.devicePixelRatio;

              // Apply target platform from ldFrameOptions
              if (ldFrameOptions.platform != null) {
                debugDefaultTargetPlatformOverride = ldFrameOptions.targetPlatform;
              }

              // If we dont have a specified height, we start as a square
              Size size = Size(
                ldFrameOptions.width,
                ldFrameOptions.height ?? ldFrameOptions.width,
              );

              if (orientation == Orientation.landscape) {
                size = Size(size.height, size.width);
              }

              await tester.binding.setSurfaceSize(
                Size(size.width, size.height),
              );

              tester.view.physicalSize = Size(
                size.width,
                (size.height),
              );

              final key = ValueKey(slug);

              // placedWidget is set by the placeWidget callback so we can
              // capture the golden AFTER the full builder has run (including
              // any post-placement interactions such as tapping to open a modal).
              Widget? placedWidget;

              // Place the widget — only pumps it; golden capture happens below.
              await entry.value(tester, (widget) async {
                placedWidget = widget;

                final frame = RepaintBoundary(
                  key: key,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      clipScreenToRadius ? ldFrameOptions.screenRadius ?? 0 : 0,
                    ),
                    child: ldFrame(
                      child: widget,
                      size: themeSize,
                      ldFrameOptions: ldFrameOptions,
                      orientation: orientation,
                      brightnessMode: switch (brightness) {
                        Brightness.light => LdThemeBrightnessMode.light,
                        Brightness.dark => LdThemeBrightnessMode.dark,
                      },
                    ),
                  ),
                );

                // If we dont have a specified height, we need to wrap the frame in a
                // SingleChildScrollView to allow the frame to grow. We will
                // automatically detect the size of the widget later.
                if (ldFrameOptions.height == null) {
                  await tester.pumpWidget(
                    SingleChildScrollView(
                      child: IntrinsicWidth(
                        child: frame,
                      ),
                    ),
                    duration: Duration(milliseconds: 100),
                  );
                } else {
                  await tester.pumpWidget(
                    frame,
                    duration: Duration(milliseconds: 100),
                  );
                }
                // Settle after pumping so GoRouter finishes its initial routing
                // and all widgets are ready before the scenario builder proceeds
                // to do interactions (e.g. tapping to open a modal).
                await tester.pumpAndSettle();
              });

              // Capture the golden AFTER the full builder has run so that any
              // post-placement interactions (e.g. opening a modal) are reflected.
              if (performWidgetTreeTests && placedWidget != null) {
                try {
                  final scenarioOverride = widgetTreeOptionsOverrides[entry.key];
                  await widgetTreeMatchesGolden(
                    tester,
                    widget: placedWidget!,
                    options: WidgetTreeOptions(
                      goldenName: '$name/$slug',
                      findWidget: scenarioOverride?.findWidget,
                      strippedWidgets: scenarioOverride?.strippedWidgets ?? defaultIgnoredWidgets,
                      stripPrivateWidgets: scenarioOverride?.stripPrivateWidgets ?? true,
                      includeWidgetBounds: scenarioOverride?.includeWidgetBounds ?? IncludeWidgetBounds.relative,
                      boundsPrecision: scenarioOverride?.boundsPrecision ?? 0,
                    ),
                  );
                } catch (e) {
                  try {
                    await writeFailureScreenshot(
                      tester,
                      find.byKey(key),
                      path.join(
                        'test/failures/golden_widget_trees',
                        name,
                        '$slug.png',
                      ),
                    );
                  } catch (_) {
                    // Ignore screenshot failures; the XML failure is the main error
                  }
                  failureMessages.add(
                    'Widget tree test failed for $name/$slug: ${e.toString()}',
                  );
                }
              }

              debugDefaultTargetPlatformOverride = null;
            }
          }
        }
      }
    }

    // After all tests have been executed, fail if any test failed
    if (failureMessages.isNotEmpty) {
      throw Exception(
        'One or more golden tests failed:\n${failureMessages.join('\n')}',
      );
    }
  } finally {
    // Restore global state and reset tester to prevent test contamination
    debugDisableShadows = savedDebugDisableShadows;
    ldDisableAnimations = savedLdDisableAnimations;
    ldIncludeFontPackage = savedLdIncludeFontPackage;
    debugDefaultTargetPlatformOverride = null;
    await resetTester(tester);
  }
}
