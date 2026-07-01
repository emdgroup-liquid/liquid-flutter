import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/src/appbar/appbar_scroll_notifier.dart';

/// Scrolls the first [Scrollable] under test using real scroll notifications.
Future<void> fakeAppBarScroll(
  WidgetTester tester, {
  required double startOffset,
  required double endOffset,
}) async {
  final scrollable = find.byType(Scrollable).first;
  final position = tester.state<ScrollableState>(scrollable).position;

  position.jumpTo(startOffset);
  await tester.pump();

  final delta = endOffset - startOffset;
  if (delta != 0) {
    await tester.drag(scrollable, Offset(0, -delta));
    await tester.pumpAndSettle();
  }
}

/// Multi-step variant of [fakeAppBarScroll].
Future<void> fakeAppBarScrollSequence(
  WidgetTester tester, {
  required double startOffset,
  required List<double> steps,
}) async {
  final scrollable = find.byType(Scrollable).first;
  final position = tester.state<ScrollableState>(scrollable).position;

  position.jumpTo(startOffset);
  await tester.pump();

  var previousOffset = startOffset;
  for (final offset in steps) {
    final delta = offset - previousOffset;
    if (delta != 0) {
      await tester.drag(scrollable, Offset(0, -delta));
      await tester.pump();
    }
    previousOffset = offset;
  }
  await tester.pumpAndSettle();
}

/// Dispatches [ScrollMetricsNotification] for tests that assert [isScrolledUnder].
Future<void> fakeAppBarScrollMetrics(
  WidgetTester tester, {
  required double pixels,
}) async {
  final scrollable = find.byType(Scrollable).first;
  final element = tester.element(scrollable);

  final metrics = FixedScrollMetrics(
    minScrollExtent: 0,
    maxScrollExtent: 2000,
    pixels: pixels,
    viewportDimension: 600,
    axisDirection: AxisDirection.down,
    devicePixelRatio: 1.0,
  );

  ScrollMetricsNotification(
    metrics: metrics,
    context: element,
  ).dispatch(element);
  await tester.pump();
}

/// Dispatches [LdAppBarScrollNotification] directly (for mid-snap re-grab tests).
void dispatchAppBarScrollNotification(
  WidgetTester tester, {
  required ScrollNotification notification,
  required double scrollDelta,
  double momentumVelocity = 0.0,
}) {
  final element = tester.element(find.byType(Scrollable).first);
  LdAppBarScrollNotification(
    source: notification,
    scrollDelta: scrollDelta,
    momentumVelocity: momentumVelocity,
  ).dispatch(element);
}
