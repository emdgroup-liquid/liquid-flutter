import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

Widget withLiquidTheme(Widget child, {LdTheme? theme}) {
  ldDisableAnimations = true;
  return LdThemeProvider(
    theme: theme ?? LdTheme(),
    child: MaterialApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        LiquidLocalizations.delegate
      ],
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: const MediaQueryData(
              size: Size(800, 1200),
            ),
            child: SingleChildScrollView(
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

/// Performs a pan gesture from [startPosition] to [endPosition] (or by [offset]).
/// Moves in incremental steps to ensure onPanUpdate callbacks are properly triggered.
/// This is necessary because `tester.drag()` is designed for scrolling and doesn't
/// properly trigger pan gesture callbacks.
Future<void> performPanGesture(
  WidgetTester tester, {
  required Offset startPosition,
  Offset? endPosition,
  Offset? offset,
  int steps = 10,
  PointerDeviceKind kind = PointerDeviceKind.mouse,
}) async {
  assert(
    (endPosition != null) != (offset != null),
    'Either endPosition or offset must be provided, but not both',
  );

  final targetOffset = endPosition != null ? endPosition - startPosition : offset!;

  // Upward mouse drags do not reliably trigger vertical drag recognizers in
  // widget tests; touch pointers behave correctly for both directions.
  final effectiveKind = kind == PointerDeviceKind.mouse && targetOffset.dy < 0 ? PointerDeviceKind.touch : kind;

  // Start pan gesture
  final gesture = await tester.startGesture(
    startPosition,
    kind: effectiveKind,
  );

  await tester.pump();

  // Move the gesture in incremental steps to ensure onPanUpdate is called
  final stepsDouble = steps.toDouble();
  for (var i = 1; i <= steps; i++) {
    await gesture.moveBy(targetOffset / stepsDouble);
    await tester.pump();
  }

  // End the gesture
  await gesture.up();
  await tester.pumpAndSettle();
}
