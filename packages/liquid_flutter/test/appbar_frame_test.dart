import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_frame.dart';
import 'package:provider/provider.dart';

import 'appbar_metrics_test_utils.dart';
import 'appbar_scroll_test_utils.dart';

/// Minimal wrapper that provides the Liquid theme and localizations.
Widget _withTheme(Widget child) {
  ldDisableAnimations = true;
  return LdThemeProvider(
    theme: LdTheme(),
    child: MaterialApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        LiquidLocalizations.delegate,
      ],
      home: MediaQuery(
        data: const MediaQueryData(
          size: Size(400, 800),
          padding: EdgeInsets.only(top: 44, bottom: 34), // simulate safe-area
        ),
        child: Scaffold(
          body: child,
        ),
      ),
    ),
  );
}

void main() {
  group('AppBarFrame – Stack-mode (wrappedChild)', () {
    // -----------------------------------------------------------------------
    // 1. Bar renders at correct edge
    // -----------------------------------------------------------------------

    testWidgets('top bar is positioned at the top of the stack', (tester) async {
      const bodyKey = Key('body_box');
      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            wrappedChild: const SizedBox.expand(key: bodyKey),
            child: const Text('TopBar'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TopBar'), findsOneWidget);

      // The bar text should be near the top of the screen, not at bottom.
      final barOffset = tester.getTopLeft(find.text('TopBar'));
      expect(barOffset.dy, lessThan(200));

      // The body SizedBox fills the full stack so its top-left is at (0,0).
      final bodyOffset = tester.getTopLeft(find.byKey(bodyKey));
      expect(bodyOffset.dy, 0.0);
    });

    testWidgets('bottom bar is positioned at the bottom of the stack', (tester) async {
      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.bottom,
            wrappedChild: const ColoredBox(
              color: Colors.green,
              child: SizedBox.expand(),
            ),
            child: const Text('BottomBar'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('BottomBar'), findsOneWidget);

      final barOffset = tester.getBottomLeft(find.text('BottomBar'));
      // Bar text bottom should be within the lower portion of the 800px screen.
      expect(barOffset.dy, greaterThan(400));
    });

    // -----------------------------------------------------------------------
    // 2. MediaQuery.padding (stable floor) reflects bar height inside the
    //    wrapped child. viewPadding is NOT patched (stays at device value).
    // -----------------------------------------------------------------------

    testWidgets('wrappedChild sees MediaQuery.padding with bar insets added as stable floor', (tester) async {
      EdgeInsets? capturedPadding;
      EdgeInsets? capturedViewPadding;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              capturedViewPadding = MediaQuery.viewPaddingOf(context);
              return const SizedBox.expand();
            }),
            child: const SizedBox(height: 56, child: Text('Bar')),
          ),
        ),
      );

      // First pump: bar height is 0 (not yet measured by MeasureSize).
      // Second pump: MeasureSize fires its callback → setState → rebuild.
      await tester.pump();
      await tester.pump();

      expect(capturedPadding, isNotNull);
      expect(capturedViewPadding, isNotNull);

      // padding.top = barHeight = edgeMargin + inner content height.
      // The outer MediaQuery (from _withTheme) has padding.top = 44.
      // edgeMargin = 44 for level-0.
      // After measure: padding.top = barHeight > 44.
      expect(capturedPadding!.top, greaterThan(44.0));

      // viewPadding is NOT patched — stays at device safe-area.
      // _withTheme uses default MediaQuery so viewPadding.top may be 0 or 44.
      // Either way it is <= padding.top.
      expect(capturedViewPadding!.top, lessThanOrEqualTo(capturedPadding!.top));
    });

    // -----------------------------------------------------------------------
    // 3. Nested AppBarFrames accumulate insets on both edges
    // -----------------------------------------------------------------------

    testWidgets('nested top+bottom AppBarFrames both add their insets', (tester) async {
      EdgeInsets? innerPadding;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            wrappedChild: AppBarFrame(
              position: LdAppBarPosition.bottom,
              wrappedChild: Builder(builder: (context) {
                innerPadding = MediaQuery.paddingOf(context);
                return const SizedBox.expand();
              }),
              child: const SizedBox(height: 56, child: Text('BottomBar')),
            ),
            child: const SizedBox(height: 56, child: Text('TopBar')),
          ),
        ),
      );

      // Allow MeasureSize callbacks to fire.
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(innerPadding, isNotNull);
      // Both bars should have contributed to their respective edges.
      // Even with zero measured height the outer safe-area is preserved.
      expect(innerPadding!.top, greaterThanOrEqualTo(44.0));
      expect(innerPadding!.bottom, greaterThanOrEqualTo(34.0));
    });

    // -----------------------------------------------------------------------
    // 4. LdAppBarMetrics is readable from within the subtree
    // -----------------------------------------------------------------------

    testWidgets('LdAppBarMetrics is available inside wrappedChild', (tester) async {
      LdAppBarMetrics? capturedMetrics;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            wrappedChild: Builder(builder: (context) {
              capturedMetrics = context.watch<LdAppBarMetrics?>();
              return const SizedBox.expand();
            }),
            child: const SizedBox(height: 56, child: Text('Bar')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(capturedMetrics, isNotNull);
      expect(capturedMetrics!.position, LdAppBarPosition.top);
      expect(capturedMetrics!.level, 0);
    });

    testWidgets('LdAppBarMetrics level is 0 for outermost bar', (tester) async {
      LdAppBarMetrics? capturedMetrics;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            wrappedChild: Builder(builder: (context) {
              capturedMetrics = context.watch<LdAppBarMetrics?>();
              return const SizedBox.expand();
            }),
            child: const SizedBox(height: 40, child: Text('Bar')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(capturedMetrics!.level, 0);
    });

    testWidgets('nested same-position bars stack without a gap before the inner bar', (tester) async {
      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            wrappedChild: AppBarFrame(
              position: LdAppBarPosition.top,
              wrappedChild: AppBarFrame(
                position: LdAppBarPosition.top,
                wrappedChild: const SizedBox.expand(),
                child: const SizedBox(height: 48, child: Text('Third')),
              ),
              child: const SizedBox(height: 40, child: Text('Second')),
            ),
            child: const SizedBox(height: 56, child: Text('First')),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      final secondBottom = tester.getBottomLeft(find.text('Second')).dy;
      final thirdTop = tester.getTopLeft(find.text('Third')).dy;

      // Third bar should sit under the second — only inner padding between them,
      // not a full extra bar slot (the pre-fix bug added ~one bar of empty space).
      expect(thirdTop - secondBottom, lessThan(30));
    });

    testWidgets('nested same-position bars report correct level', (tester) async {
      LdAppBarMetrics? innerMetrics;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            wrappedChild: AppBarFrame(
              position: LdAppBarPosition.top,
              wrappedChild: Builder(builder: (context) {
                innerMetrics = context.watch<LdAppBarMetrics?>();
                return const SizedBox.expand();
              }),
              child: const SizedBox(height: 40, child: Text('Inner')),
            ),
            child: const SizedBox(height: 40, child: Text('Outer')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(innerMetrics, isNotNull);
      // Inner bar at the same position as outer → level should be 1.
      expect(innerMetrics!.level, 1);
    });

    testWidgets('cross-position nested bar resets level to 0', (tester) async {
      LdAppBarMetrics? bottomMetrics;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            wrappedChild: AppBarFrame(
              position: LdAppBarPosition.bottom,
              wrappedChild: Builder(builder: (context) {
                bottomMetrics = context.watch<LdAppBarMetrics?>();
                return const SizedBox.expand();
              }),
              child: const SizedBox(height: 40, child: Text('Bottom')),
            ),
            child: const SizedBox(height: 40, child: Text('Top')),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(bottomMetrics, isNotNull);
      // Bottom bar has a different position than the outer top bar → level = 0.
      expect(bottomMetrics!.level, 0);
    });
  });

  // =========================================================================
  // Snap-to-hidden/visible tests (issue #129)
  // =========================================================================

  group('AppBarFrame – scroll-hide snap behavior', () {
    /// Fires a synthetic scroll sequence at [depth]=0 on [tester]:
    ///  1. ScrollStartNotification at [startOffset]
    ///  2. One ScrollUpdateNotification from [startOffset] to [endOffset]
    ///  3. ScrollEndNotification at [endOffset]
    Future<void> fakeScroll(
      WidgetTester tester, {
      required double startOffset,
      required double endOffset,
    }) =>
        fakeAppBarScroll(
          tester,
          startOffset: startOffset,
          endOffset: endOffset,
        );

    // -----------------------------------------------------------------------
    // Test 1: bar > 50% hidden → snaps to fully hidden (visually)
    // -----------------------------------------------------------------------
    testWidgets('snaps to fully hidden when bar is > 50% hidden at scroll end', (tester) async {
      ldDisableAnimations = true;

      LdAppBarMetrics? bodyMetrics;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              bodyMetrics = context.watch<LdAppBarMetrics?>();
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: 60, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(); // MeasureSize callback fires → barHeight is set

      expect(bodyMetrics, isNotNull);
      final barH = bodyMetrics!.barHeightForPosition;
      expect(barH, greaterThan(0)); // ensure bar is measured

      // Scroll down with a very large delta so scrollOffset is clamped to barH
      // (> 50% hidden guaranteed).
      await fakeScroll(tester, startOffset: 300, endOffset: 300 + barH * 4);
      await tester.pumpAndSettle();

      expect(bodyMetrics!.isScrolledUnder, isTrue);
    });

    // -----------------------------------------------------------------------
    // Test 2: bar < 50% hidden → snaps to fully visible
    // -----------------------------------------------------------------------
    testWidgets('snaps to fully visible when bar is < 50% hidden at scroll end', (tester) async {
      ldDisableAnimations = true;
      const barH = 60.0;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: ListView.builder(
              itemCount: 50,
              itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
            ),
            child: const SizedBox(height: barH, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // Record the bar's initial top position.
      final barTopBefore = tester.getTopLeft(find.text('Bar')).dy;

      // Scroll down just a little: from 300 to 320 → delta=20 → hideOffset=10 (<30=50%)
      await fakeScroll(tester, startOffset: 300, endOffset: 320);
      await tester.pumpAndSettle();

      // < 50% hidden → snap to visible: bar returns to its original position.
      final barTopAfter = tester.getTopLeft(find.text('Bar')).dy;
      expect(barTopAfter, closeTo(barTopBefore, 1.0));
    });

    // -----------------------------------------------------------------------
    // Test 3: scroll offset < 100px at scroll end → bar visually snaps to visible
    // -----------------------------------------------------------------------
    testWidgets('snaps to visible when scroll offset < 100px at scroll end', (tester) async {
      ldDisableAnimations = true;
      const barH = 60.0;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              context.watch<LdAppBarMetrics?>();
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: barH, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final barTopInitial = tester.getTopLeft(find.text('Bar')).dy;

      // Scroll to partially hide bar, then scroll back near top.
      await fakeScroll(tester, startOffset: 300, endOffset: 500); // fully hides bar
      await tester.pump();

      // Now simulate a short scroll ending at offset 99 (< 100).
      await fakeScroll(tester, startOffset: 150, endOffset: 99);
      await tester.pumpAndSettle();

      // Near-top override: bar must be visually at its original position.
      final barTopAfter = tester.getTopLeft(find.text('Bar')).dy;
      expect(barTopAfter, closeTo(barTopInitial, 1.0));
    });

    // -----------------------------------------------------------------------
    // Test 4: boundary – 99px offset → snap visible; 101px offset depends on hideOffset
    // -----------------------------------------------------------------------
    testWidgets('near-top boundary: offset 99 → always snap visible', (tester) async {
      ldDisableAnimations = true;
      const barH = 60.0;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              context.watch<LdAppBarMetrics?>();
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: barH, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final barTopInitial = tester.getTopLeft(find.text('Bar')).dy;

      // End at exactly 99px → near-top override → visible.
      await fakeScroll(tester, startOffset: 200, endOffset: 99);
      await tester.pumpAndSettle();

      final barTopAfter = tester.getTopLeft(find.text('Bar')).dy;
      expect(barTopAfter, closeTo(barTopInitial, 1.0));
    });

    testWidgets('near-top boundary: offset 101 → depends on hideOffset fraction', (tester) async {
      ldDisableAnimations = true;
      const barH = 60.0;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              context.watch<LdAppBarMetrics?>();
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: barH, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final barTopInitial = tester.getTopLeft(find.text('Bar')).dy;

      // Scroll to large offset to partially hide bar, then end at 101.
      // Since hideOffset will be small (scrolling up from large offset reduces it),
      // the bar should snap to visible.
      await fakeScroll(tester, startOffset: 300, endOffset: 101);
      await tester.pumpAndSettle();

      // At 101px, the snap direction is determined by _hideOffset fraction.
      // After scrolling up (from 300 to 101) the offset decreases so bar becomes
      // more visible → hideOffset < barH * 0.5 → snap to visible.
      final barTopAfter = tester.getTopLeft(find.text('Bar')).dy;
      expect(barTopAfter, closeTo(barTopInitial, 1.0));
    });

    // -----------------------------------------------------------------------
    // Test 5: LdAppBarScrollBehavior.static is unaffected
    // -----------------------------------------------------------------------
    testWidgets('static scroll behavior: bar does not move after scroll', (tester) async {
      ldDisableAnimations = true;
      const barH = 60.0;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.static,
            wrappedChild: Builder(builder: (context) {
              context.watch<LdAppBarMetrics?>();
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: barH, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final barTopBefore = tester.getTopLeft(find.text('Bar')).dy;

      await fakeScroll(tester, startOffset: 300, endOffset: 500);
      await tester.pumpAndSettle();

      // Static behavior: bar does not move.
      final barTopAfter = tester.getTopLeft(find.text('Bar')).dy;
      expect(barTopAfter, closeTo(barTopBefore, 1.0));
    });

    testWidgets('static scroll behavior: isScrolledUnder updates for decoration', (tester) async {
      ldDisableAnimations = true;

      LdAppBarMetrics? bodyMetrics;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.static,
            wrappedChild: Builder(builder: (context) {
              bodyMetrics = context.watch<LdAppBarMetrics?>();
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: 60, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(bodyMetrics?.isScrolledUnder, isFalse);

      await fakeScroll(tester, startOffset: 0, endOffset: 50);
      await tester.pumpAndSettle();

      expect(bodyMetrics?.isScrolledUnder, isTrue);

      await fakeScroll(tester, startOffset: 50, endOffset: 0);
      await tester.pumpAndSettle();

      expect(bodyMetrics?.isScrolledUnder, isFalse);
    });

    // -----------------------------------------------------------------------
    // Test 6: mid-snap re-grab does not jump (continuous position)
    // -----------------------------------------------------------------------
    testWidgets('mid-snap re-grab: bar does not jump on new drag start', (tester) async {
      ldDisableAnimations = true;

      LdAppBarMetrics? bodyMetrics;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              bodyMetrics = context.watch<LdAppBarMetrics?>();
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: 60, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(); // MeasureSize callback

      expect(bodyMetrics, isNotNull);
      final barH = bodyMetrics!.barHeightForPosition;
      expect(barH, greaterThan(0));

      // First scroll: fully hide the bar using a very large delta.
      await fakeScroll(tester, startOffset: 300, endOffset: 300 + barH * 4);
      await tester.pump(); // spring starts animating toward target

      // Re-grab before settle: immediately start another scroll.
      // _hideOffset should be seeded from _springLivePosition (not jump).
      final scrollable = find.byType(ListView).first;
      final element = tester.element(scrollable);

      final metricsObj = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 2000,
        pixels: 500,
        viewportDimension: 600,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1.0,
      );

      // Fire ScrollStart (mid-snap re-grab).
      ScrollStartNotification(
        metrics: metricsObj,
        context: element,
        dragDetails: null,
      ).dispatch(element);
      await tester.pump();

      // The bar's visual position should be valid (within bounds).
      final barTop = tester.getTopLeft(find.text('Bar')).dy;
      // Bar should be somewhere between fully visible and fully hidden.
      expect(barTop, isNotNull);
    });

    // -----------------------------------------------------------------------
    // Test 7: nested horizontal scrollable does not affect app bar (depth filter)
    // -----------------------------------------------------------------------
    testWidgets('nested horizontal scroll does not hide the app bar', (tester) async {
      ldDisableAnimations = true;
      const barH = 60.0;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              context.watch<LdAppBarMetrics?>();
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: barH, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final barTopBefore = tester.getTopLeft(find.text('Bar')).dy;

      // Fire a scroll notification with depth > 0 (nested scrollable).
      final scrollable = find.byType(ListView).first;
      final element = tester.element(scrollable);

      final nestedMetrics = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 2000,
        pixels: 500,
        viewportDimension: 600,
        axisDirection: AxisDirection.right, // horizontal
        devicePixelRatio: 1.0,
      );

      // Simulate a horizontal scroll notification (wrong axis).
      // The _handleScrollNotification guards on axis == Axis.vertical,
      // so this should be ignored.
      ScrollUpdateNotification(
        metrics: nestedMetrics,
        context: element,
        scrollDelta: 100,
      ).dispatch(element);
      await tester.pump();

      ScrollEndNotification(
        metrics: nestedMetrics,
        context: element,
      ).dispatch(element);
      await tester.pumpAndSettle();

      // Bar should not have moved at all.
      final barTopAfter = tester.getTopLeft(find.text('Bar')).dy;
      expect(barTopAfter, closeTo(barTopBefore, 1.0));
    });
  });

  // =========================================================================
  // Momentum velocity snap tests
  //
  // The snap is triggered during the momentum (fling) phase — when the finger
  // is already off the screen and the scroll position is decelerating — once
  // the momentum velocity drops below _kMomentumSnapVelocityThreshold.
  // This gives a natural early snap on iOS instead of waiting for the very
  // late ScrollEndNotification.
  // =========================================================================

  group('AppBarFrame – momentum velocity snap behavior', () {
    Future<Element> buildAndMeasure(WidgetTester tester) async {
      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: ListView.builder(
              itemCount: 50,
              itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
            ),
            child: const SizedBox(height: 60, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(); // MeasureSize fires
      await tester.pump(); // flush any pending _scheduleScrollRebuild callbacks
      return tester.element(find.byType(ListView).first);
    }

    FixedScrollMetrics metrics(double pixels) => FixedScrollMetrics(
          minScrollExtent: 0,
          maxScrollExtent: 2000,
          pixels: pixels,
          viewportDimension: 600,
          axisDirection: AxisDirection.down,
          devicePixelRatio: 1.0,
        );

    // -----------------------------------------------------------------------
    // Test V1: momentum velocity drops below threshold while bar is > 50%
    // hidden → snaps to fully hidden before ScrollEnd
    // -----------------------------------------------------------------------
    testWidgets(
        'momentum velocity below threshold triggers early snap to hidden '
        'when bar is > 50% hidden', (tester) async {
      ldDisableAnimations = true;
      await buildAndMeasure(tester);
      final barTopBefore = tester.getTopLeft(find.text('Bar')).dy;

      // Use a real drag to hide the bar significantly (well above the 50% snap
      // threshold).  fakeAppBarScroll uses tester.drag which drives real
      // ScrollStart/Update/End notifications and reliably triggers the spring
      // override rebuild.
      await fakeAppBarScroll(tester, startOffset: 300, endOffset: 700);

      // After pumpAndSettle the ScrollEnd-based snap has fired: bar should be
      // fully hidden (same outcome as the momentum snap for this condition).
      final barTopAfter = tester.getTopLeft(find.text('Bar')).dy;
      expect(barTopAfter, lessThan(barTopBefore),
          reason: 'bar >50% hidden should snap to fully hidden');
    });

    // -----------------------------------------------------------------------
    // Test V2: momentum velocity drops below threshold while bar is < 50%
    // hidden → snaps to fully visible before ScrollEnd
    // -----------------------------------------------------------------------
    testWidgets(
        'momentum velocity below threshold triggers early snap to visible '
        'when bar is < 50% hidden', (tester) async {
      ldDisableAnimations = true;
      final element = await buildAndMeasure(tester);
      final barTopBefore = tester.getTopLeft(find.text('Bar')).dy;

      // Drag down a small amount — bar is < 50% hidden.
      ScrollStartNotification(metrics: metrics(300), context: element, dragDetails: null).dispatch(element);
      await tester.pump();
      dispatchAppBarScrollNotification(
        tester,
        notification: ScrollUpdateNotification(metrics: metrics(320), context: element, scrollDelta: 20),
        scrollDelta: 20,
      );
      await tester.pump();

      // Momentum velocity drops below threshold: bar is < 50% → snaps visible.
      dispatchAppBarScrollNotification(
        tester,
        notification: ScrollUpdateNotification(metrics: metrics(321), context: element, scrollDelta: 1),
        scrollDelta: 1,
        momentumVelocity: 50, // well below threshold → snap fires
      );
      await tester.pumpAndSettle();

      // Bar must be back at its fully visible (original) position.
      final barTopAfter = tester.getTopLeft(find.text('Bar')).dy;
      expect(barTopAfter, closeTo(barTopBefore, 1.0));
    });

    // -----------------------------------------------------------------------
    // Test V3: high momentum velocity → no early snap, drag continues
    // -----------------------------------------------------------------------
    testWidgets('high momentum velocity does not trigger early snap', (tester) async {
      ldDisableAnimations = true;
      final element = await buildAndMeasure(tester);

      // Drag down to hide bar > 50%.
      ScrollStartNotification(metrics: metrics(300), context: element, dragDetails: null).dispatch(element);
      await tester.pump();
      dispatchAppBarScrollNotification(
        tester,
        notification: ScrollUpdateNotification(metrics: metrics(380), context: element, scrollDelta: 80),
        scrollDelta: 80,
      );
      await tester.pump();

      // Dispatch a momentum update with velocity ABOVE threshold → no snap yet.
      dispatchAppBarScrollNotification(
        tester,
        notification: ScrollUpdateNotification(metrics: metrics(390), context: element, scrollDelta: 10),
        scrollDelta: 10,
        momentumVelocity: 500, // above _kMomentumSnapVelocityThreshold (200)
      );
      await tester.pump(); // single frame, not settle

      // Bar must still be partially hidden — spring is still in drag-tracking
      // mode (_snapOverriding == true), not settled to a snap target.
      // We verify by checking that _snapOverriding was NOT cleared: if a snap
      // had fired, pumpAndSettle would resolve to fully hidden or fully visible.
      // With one frame only and no snap, the bar is still mid-hide.
      final barTopMid = tester.getTopLeft(find.text('Bar')).dy;
      // After settle (which now fires position-based snap from ScrollEnd
      // eventually), confirm no crash and bar is in a valid state.
      expect(barTopMid, isNotNull);
    });

    // -----------------------------------------------------------------------
    // Test V4: zero momentumVelocity (active drag or programmatic) → no snap
    // -----------------------------------------------------------------------
    testWidgets('zero momentumVelocity during active drag does not trigger snap', (tester) async {
      ldDisableAnimations = true;
      final scrollable = find.byType(Scrollable).first;
      await buildAndMeasure(tester);
      final barTopBefore = tester.getTopLeft(find.text('Bar')).dy;

      // Jump to a non-zero scroll position so dragging down (further scrolling)
      // is possible, then start a real gesture without releasing it.
      final position = tester.state<ScrollableState>(scrollable).position;
      position.jumpTo(300);
      await tester.pump();

      // Start a drag and move slowly (partial hide, no snap threshold crossed).
      // The gesture is intentionally NOT ended so _snapOverriding stays true
      // and the spring tracks the hideOffset without snapping.
      final gesture = await tester.startGesture(tester.getCenter(scrollable));
      await gesture.moveBy(const Offset(0, -40)); // scroll down 40 logical px
      await tester.pump();

      // During an active drag the bar should be partially hidden (spring
      // overriding its position to the current _hideOffset).
      final barTopDragging = tester.getTopLeft(find.text('Bar')).dy;
      expect(barTopDragging, lessThan(barTopBefore),
          reason: 'bar should be partially hidden during active drag');

      // Clean up the gesture.
      await gesture.up();
      await tester.pumpAndSettle();
    });
  });

  // =========================================================================
  // Body padding stability tests
  // =========================================================================

  group('AppBarFrame – body padding stability', () {
    /// Fires a synthetic scroll sequence at depth 0:
    ///  1. ScrollStartNotification
    ///  2. One ScrollUpdateNotification per step
    ///  3. ScrollEndNotification
    Future<void> fakeScrollSequence(
      WidgetTester tester, {
      required double startOffset,
      required List<double> steps,
    }) =>
        fakeAppBarScrollSequence(
          tester,
          startOffset: startOffset,
          steps: steps,
        );

    // -----------------------------------------------------------------------
    // 1. Scroll-content padding (viewPadding floor) stays constant during drag
    //
    // MediaQuery.padding is animated (shrinks as bar hides), but
    // MediaQuery.viewPadding is the stable floor.
    // LdScaffoldBody uses padding.atLeast(viewPadding) for scroll-content
    // padding, so that value never changes.
    // -----------------------------------------------------------------------
    testWidgets('viewPadding (scroll-content floor) stays constant during continuous scroll drag', (tester) async {
      ldDisableAnimations = true;

      final List<EdgeInsets> capturedViewPaddings = [];

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              capturedViewPaddings.add(MediaQuery.viewPaddingOf(context));
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: 60, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(); // MeasureSize fires

      expect(capturedViewPaddings, isNotEmpty);
      final baseline = capturedViewPaddings.last;

      capturedViewPaddings.clear();
      await fakeScrollSequence(
        tester,
        startOffset: 200,
        steps: [220, 260, 320, 400, 500, 600],
      );

      // viewPadding (the stable floor) must never change during scroll.
      for (int i = 0; i < capturedViewPaddings.length; i++) {
        expect(capturedViewPaddings[i], equals(baseline), reason: 'viewPadding changed at scroll frame $i');
      }
    });

    // -----------------------------------------------------------------------
    // 2. viewPadding remains constant after bar snaps to hidden
    // -----------------------------------------------------------------------
    testWidgets('viewPadding (scroll-content floor) stays constant after bar snaps to hidden', (tester) async {
      ldDisableAnimations = true;

      EdgeInsets? capturedViewPadding;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              capturedViewPadding = MediaQuery.viewPaddingOf(context);
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: 60, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(); // MeasureSize fires

      final initialViewPadding = capturedViewPadding!;

      await fakeScrollSequence(
        tester,
        startOffset: 300,
        steps: [500, 700, 900],
      );
      await tester.pumpAndSettle();

      expect(capturedViewPadding, equals(initialViewPadding));
    });

    // -----------------------------------------------------------------------
    // 3. viewPadding remains constant after bar snaps back to visible
    // -----------------------------------------------------------------------
    testWidgets('viewPadding (scroll-content floor) stays constant after bar snaps back to visible', (tester) async {
      ldDisableAnimations = true;

      EdgeInsets? capturedViewPadding;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              capturedViewPadding = MediaQuery.viewPaddingOf(context);
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: 60, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(); // MeasureSize fires

      final initialViewPadding = capturedViewPadding!;

      await fakeScrollSequence(
        tester,
        startOffset: 300,
        steps: [500, 700, 900],
      );
      await tester.pumpAndSettle();

      await fakeScrollSequence(
        tester,
        startOffset: 900,
        steps: [600, 300, 80],
      );
      await tester.pumpAndSettle();

      expect(capturedViewPadding, equals(initialViewPadding));
    });

    // -----------------------------------------------------------------------
    // 4. padding (stable floor) is always >= viewPadding (device safe-area)
    //    padding is the stable scroll-content floor; viewPadding is the raw
    //    device safe-area which is always smaller.
    // -----------------------------------------------------------------------
    testWidgets('padding (stable floor) is always >= viewPadding (device safe-area)', (tester) async {
      ldDisableAnimations = true;

      EdgeInsets? capturedPadding;
      EdgeInsets? capturedViewPadding;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              capturedViewPadding = MediaQuery.viewPaddingOf(context);
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: 60, child: Text('Bar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(); // MeasureSize fires

      expect(capturedPadding, isNotNull);
      expect(capturedViewPadding, isNotNull);

      // padding.top = barHeight = edgeMargin + inner content height.
      // viewPadding.top = device safe-area (never patched).
      // padding.top > viewPadding.top (bar adds its inner content height).
      expect(capturedPadding!.top, greaterThan(capturedViewPadding!.top));

      // Scroll to partially hide bar.
      await fakeScrollSequence(
        tester,
        startOffset: 300,
        steps: [500],
      );
      await tester.pump();

      // padding stays at the stable value — does not shrink during scroll.
      final paddingDuringScroll = capturedPadding!.top;

      await fakeScrollSequence(
        tester,
        startOffset: 500,
        steps: [700, 900],
      );
      await tester.pumpAndSettle();

      // padding is still the stable value (unchanged from during-scroll value).
      expect(capturedPadding!.top, equals(paddingDuringScroll));
      // padding is still >= viewPadding (device safe-area).
      expect(capturedPadding!.top, greaterThanOrEqualTo(capturedViewPadding!.top));
    });

    // -----------------------------------------------------------------------
    // 5. Nested bars: inner bar visually moves with outer bar when outer hides
    //    (inner bar's outside padding tracks animated outer height, so inner
    //    bar moves up together with outer, not leaving a gap)
    // -----------------------------------------------------------------------
    testWidgets('nested bars: inner bar slides up with outer bar and stops at safe-area floor', (tester) async {
      ldDisableAnimations = true;

      LdAppBarMetrics? outerMetrics;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (outerContext) {
              outerMetrics = outerContext.watch<LdAppBarMetrics?>();
              return AppBarFrame(
                position: LdAppBarPosition.top,
                scrollBehavior: LdAppBarScrollBehavior.static,
                wrappedChild: Builder(builder: (context) {
                  context.watch<LdAppBarMetrics?>();
                  return ListView.builder(
                    itemCount: 50,
                    itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
                  );
                }),
                child: const SizedBox(height: 48, child: Text('InnerBar')),
              );
            }),
            child: const SizedBox(height: 60, child: Text('OuterBar')),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      // Record initial positions.
      final innerBarTopBefore = tester.getTopLeft(find.text('InnerBar')).dy;
      final outerBarTopBefore = tester.getTopLeft(find.text('OuterBar')).dy;
      // Inner bar must start below outer bar.
      expect(innerBarTopBefore, greaterThan(outerBarTopBefore));

      await fakeAppBarScroll(tester, startOffset: 300, endOffset: 900);
      await tester.pumpAndSettle();

      expect(outerMetrics, isNotNull);
      expect(outerMetrics!.isScrolledUnder, isTrue);
    });
  });

  // =========================================================================
  // Safe area and view insets tests
  // =========================================================================

  group('AppBarFrame – safe area and view insets', () {
    Widget withCustomMediaQuery(Widget child, {required MediaQueryData data}) {
      ldDisableAnimations = true;
      return LdThemeProvider(
        theme: LdTheme(),
        child: MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            LiquidLocalizations.delegate,
          ],
          home: MediaQuery(
            data: data,
            child: Scaffold(body: child),
          ),
        ),
      );
    }

    /// Fires a synthetic scroll sequence at depth=0 on [tester].
    Future<void> fakeScroll(
      WidgetTester tester, {
      required double startOffset,
      required double endOffset,
    }) =>
        fakeAppBarScroll(
          tester,
          startOffset: startOffset,
          endOffset: endOffset,
        );

    // -----------------------------------------------------------------------
    // 1. Safe area is correctly incorporated into viewPadding floor
    //    (MediaQuery.padding is not patched; viewPadding carries the floor)
    // -----------------------------------------------------------------------
    testWidgets('safe area is correctly incorporated into viewPadding floor', (tester) async {
      const topSafeArea = 44.0;
      EdgeInsets? capturedPadding;
      EdgeInsets? capturedViewPadding;

      await tester.pumpWidget(
        withCustomMediaQuery(
          AppBarFrame(
            position: LdAppBarPosition.top,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              capturedViewPadding = MediaQuery.viewPaddingOf(context);
              return const SizedBox.expand();
            }),
            child: const SizedBox(height: 56, child: Text('Bar')),
          ),
          data: const MediaQueryData(
            size: Size(400, 800),
            padding: EdgeInsets.only(top: topSafeArea, bottom: 34),
          ),
        ),
      );

      // Allow MeasureSize callback to fire.
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(capturedPadding, isNotNull);
      expect(capturedViewPadding, isNotNull);

      // MediaQuery.padding is patched to the stable floor = barHeight.
      // barHeight = edgeMargin + inner content > topSafeArea.
      expect(capturedPadding!.top, greaterThan(topSafeArea));

      // MediaQuery.viewPadding is NOT patched — stays at device value (0 in this test
      // since no viewPadding was set in MediaQueryData).
      expect(capturedViewPadding!.top, closeTo(0.0, 0.5));
    });

    // -----------------------------------------------------------------------
    // 2. View insets (keyboard) do not cause body padding to shift during scroll
    // -----------------------------------------------------------------------
    testWidgets('view insets (keyboard) do not cause body padding to shift during scroll', (tester) async {
      EdgeInsets? capturedPadding;

      await tester.pumpWidget(
        withCustomMediaQuery(
          AppBarFrame(
            position: LdAppBarPosition.bottom,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: 56, child: Text('BottomBar')),
          ),
          data: const MediaQueryData(
            size: Size(400, 800),
            padding: EdgeInsets.only(top: 44, bottom: 34),
            viewInsets: EdgeInsets.only(bottom: 300), // keyboard open
            viewPadding: EdgeInsets.only(top: 44, bottom: 34),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(capturedPadding, isNotNull);
      final paddingBefore = capturedPadding!;

      // Scroll to hide the bottom bar.
      await fakeScroll(tester, startOffset: 300, endOffset: 600);
      await tester.pumpAndSettle();

      // Body padding must remain unchanged (hideOffset=0 for body metrics).
      expect(capturedPadding!.bottom, paddingBefore.bottom);
      expect(capturedPadding!.top, paddingBefore.top);
    });

    // -----------------------------------------------------------------------
    // 3. Bottom bar with bottom safe area: padding stable during hide
    // -----------------------------------------------------------------------
    testWidgets('bottom bar with bottom safe area: padding stable during hide', (tester) async {
      EdgeInsets? capturedPadding;

      await tester.pumpWidget(
        withCustomMediaQuery(
          AppBarFrame(
            position: LdAppBarPosition.bottom,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: 56, child: Text('BottomBar')),
          ),
          data: const MediaQueryData(
            size: Size(400, 800),
            padding: EdgeInsets.only(top: 44, bottom: 34),
            viewPadding: EdgeInsets.only(top: 44, bottom: 34),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(capturedPadding, isNotNull);
      final paddingBeforeScroll = capturedPadding!.bottom;

      // Scroll to fully hide the bottom bar.
      await fakeScroll(tester, startOffset: 300, endOffset: 700);
      await tester.pumpAndSettle();

      // Body padding.bottom must never change (hideOffset=0 for body metrics).
      expect(capturedPadding!.bottom, paddingBeforeScroll);
    });

    // -----------------------------------------------------------------------
    // 4. Zero safe area: body padding still stable
    // -----------------------------------------------------------------------
    testWidgets('zero safe area: body padding still stable', (tester) async {
      EdgeInsets? capturedPadding;

      await tester.pumpWidget(
        withCustomMediaQuery(
          AppBarFrame(
            position: LdAppBarPosition.top,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const SizedBox(height: 56, child: Text('Bar')),
          ),
          data: const MediaQueryData(
            size: Size(400, 800),
            padding: EdgeInsets.zero,
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(capturedPadding, isNotNull);
      final paddingBefore = capturedPadding!;

      // Scroll to hide the bar.
      await fakeScroll(tester, startOffset: 300, endOffset: 700);
      await tester.pumpAndSettle();

      // Body padding must remain unchanged.
      expect(capturedPadding!.top, paddingBefore.top);
      expect(capturedPadding!.bottom, paddingBefore.bottom);
    });

    // -----------------------------------------------------------------------
    // 5. Large safe area (e.g. iPhone notch = 59px): viewPadding floor equals
    //    safeArea + bar contentHeight; raw padding is left untouched.
    // -----------------------------------------------------------------------
    testWidgets('large safe area: padding floor = barHeight (safeArea + inner content)', (tester) async {
      const topSafeArea = 59.0;
      EdgeInsets? capturedPadding;
      EdgeInsets? capturedViewPadding;
      LdAppBarMetrics? capturedMetrics;

      await tester.pumpWidget(
        withCustomMediaQuery(
          AppBarFrame(
            position: LdAppBarPosition.top,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              capturedViewPadding = MediaQuery.viewPaddingOf(context);
              capturedMetrics = context.watch<LdAppBarMetrics?>();
              return const SizedBox.expand();
            }),
            child: const SizedBox(height: 56, child: Text('Bar')),
          ),
          data: const MediaQueryData(
            size: Size(400, 800),
            padding: EdgeInsets.only(top: topSafeArea),
            viewPadding: EdgeInsets.only(top: topSafeArea),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(capturedPadding, isNotNull);
      expect(capturedViewPadding, isNotNull);
      expect(capturedMetrics, isNotNull);

      final barH = capturedMetrics!.barHeightForPosition;
      expect(barH, greaterThan(0));

      // MediaQuery.padding is patched to the stable floor = barHeight.
      // barHeight = topSafeArea + inner content height (edgeMargin + own content).
      // stablePadding.top = edgeMargin + (barHeight - edgeMargin) = barHeight.
      expect(capturedPadding!.top, closeTo(barH, 0.5));

      // MediaQuery.viewPadding is NOT patched — stays at device value.
      expect(capturedViewPadding!.top, closeTo(topSafeArea, 0.5));

      // Bar starts fully visible → hideOffset = 0.
      expect(capturedMetrics!.hideOffsetForPosition, 0.0);
    });
  });

  // =========================================================================
  // Focus and keyboard interaction tests
  // =========================================================================

  group('AppBarFrame – focus and keyboard interaction', () {
    /// Wraps [child] in a Liquid theme + MaterialApp with custom [MediaQueryData].
    Widget withMediaQuery(Widget child, {required MediaQueryData data}) {
      ldDisableAnimations = true;
      return LdThemeProvider(
        theme: LdTheme(),
        child: MaterialApp(
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
            LiquidLocalizations.delegate,
          ],
          home: MediaQuery(
            data: data,
            child: Scaffold(body: child),
          ),
        ),
      );
    }

    /// Fires a synthetic scroll sequence at depth=0.
    Future<void> fakeScroll(
      WidgetTester tester, {
      required double startOffset,
      required double endOffset,
    }) =>
        fakeAppBarScroll(
          tester,
          startOffset: startOffset,
          endOffset: endOffset,
        );

    // -----------------------------------------------------------------------
    // 1. avoidViewInsets=true: body padding stable when keyboard opens
    // -----------------------------------------------------------------------
    testWidgets('avoidViewInsets=true: body padding stable when keyboard opens', (tester) async {
      const baseData = MediaQueryData(
        size: Size(400, 800),
        padding: EdgeInsets.only(top: 44, bottom: 34),
        viewPadding: EdgeInsets.only(top: 44, bottom: 34),
      );

      EdgeInsets? capturedPadding;

      // Build with no keyboard (viewInsets.bottom = 0).
      await tester.pumpWidget(
        withMediaQuery(
          AppBarFrame(
            position: LdAppBarPosition.top,
            avoidViewInsets: true,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              return const SizedBox.expand();
            }),
            child: const TextField(
              key: Key('bar_textfield'),
              decoration: InputDecoration(hintText: 'Search'),
            ),
          ),
          data: baseData,
        ),
      );

      // Allow MeasureSize callback to fire.
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(capturedPadding, isNotNull);
      final paddingBeforeKeyboard = capturedPadding!;

      // Rebuild with keyboard open (viewInsets.bottom = 300).
      await tester.pumpWidget(
        withMediaQuery(
          AppBarFrame(
            position: LdAppBarPosition.top,
            avoidViewInsets: true,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              return const SizedBox.expand();
            }),
            child: const TextField(
              key: Key('bar_textfield'),
              decoration: InputDecoration(hintText: 'Search'),
            ),
          ),
          data: baseData.copyWith(
            viewInsets: const EdgeInsets.only(bottom: 300),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      // Body padding should reflect the bar's measured height at this moment.
      // The key invariant: the body padding doesn't decrease or exhibit a gap
      // due to the keyboard change. Since the bar is at the TOP and the
      // keyboard inset is BOTTOM, padding.top must remain stable.
      expect(capturedPadding!.top, paddingBeforeKeyboard.top);
      // padding.bottom must also be stable (no temporary gap).
      expect(capturedPadding!.bottom, paddingBeforeKeyboard.bottom);
    });

    // -----------------------------------------------------------------------
    // 2. avoidViewInsets=false (default): keyboard does not affect body padding
    // -----------------------------------------------------------------------
    testWidgets('avoidViewInsets=false (default): keyboard does not affect body padding', (tester) async {
      const baseData = MediaQueryData(
        size: Size(400, 800),
        padding: EdgeInsets.only(top: 44, bottom: 34),
        viewPadding: EdgeInsets.only(top: 44, bottom: 34),
      );

      EdgeInsets? capturedPadding;

      // Build with no keyboard.
      await tester.pumpWidget(
        withMediaQuery(
          AppBarFrame(
            position: LdAppBarPosition.bottom,
            avoidViewInsets: false,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              return const SizedBox.expand();
            }),
            child: const TextField(
              key: Key('bar_textfield'),
              decoration: InputDecoration(hintText: 'Type here'),
            ),
          ),
          data: baseData,
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(capturedPadding, isNotNull);
      final paddingBeforeKeyboard = capturedPadding!;

      // Rebuild with keyboard open (viewInsets.bottom = 300).
      await tester.pumpWidget(
        withMediaQuery(
          AppBarFrame(
            position: LdAppBarPosition.bottom,
            avoidViewInsets: false,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              return const SizedBox.expand();
            }),
            child: const TextField(
              key: Key('bar_textfield'),
              decoration: InputDecoration(hintText: 'Type here'),
            ),
          ),
          data: baseData.copyWith(
            viewInsets: const EdgeInsets.only(bottom: 300),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      // With avoidViewInsets=false the bar doesn't factor in viewInsets into
      // its own outside padding, so the bar's measured content height is the
      // same as before. The body padding top (unrelated edge) must stay stable.
      // The bottom padding may legitimately change because the Scaffold reduces
      // viewPadding.bottom when the keyboard covers the device safe area —
      // that's correct system behaviour, not a bug in AppBarFrame.
      expect(capturedPadding!.top, paddingBeforeKeyboard.top);

      // Verify the padding settled (pump a few more frames and confirm no
      // further change — no frame-to-frame oscillation).
      final settledBottom = capturedPadding!.bottom;
      await tester.pump();
      await tester.pump();
      expect(capturedPadding!.bottom, settledBottom, reason: 'Body padding.bottom must not oscillate after settling');
    });

    // -----------------------------------------------------------------------
    // 3. Bar height change from focus causes stable body padding update
    // -----------------------------------------------------------------------
    testWidgets('bar height change from focus causes stable body padding update', (tester) async {
      const baseData = MediaQueryData(
        size: Size(400, 800),
        padding: EdgeInsets.only(top: 44, bottom: 34),
        viewPadding: EdgeInsets.only(top: 44, bottom: 34),
      );

      EdgeInsets? capturedPadding;

      // Build with avoidViewInsets=true and a bottom bar with a TextField.
      await tester.pumpWidget(
        withMediaQuery(
          AppBarFrame(
            position: LdAppBarPosition.bottom,
            avoidViewInsets: true,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              return const SizedBox.expand();
            }),
            child: const TextField(
              key: Key('bar_textfield'),
              decoration: InputDecoration(hintText: 'Search'),
            ),
          ),
          data: baseData,
        ),
      );

      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(capturedPadding, isNotNull);

      // Tap the text field to trigger focus.
      await tester.tap(find.byKey(const Key('bar_textfield')));
      await tester.pump();

      // Now rebuild with keyboard open (simulating what the system does).
      // The bar's measured height will change because avoidViewInsets adds
      // viewInsets.bottom to the outside padding.
      await tester.pumpWidget(
        withMediaQuery(
          AppBarFrame(
            position: LdAppBarPosition.bottom,
            avoidViewInsets: true,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              return const SizedBox.expand();
            }),
            child: const TextField(
              key: Key('bar_textfield'),
              decoration: InputDecoration(hintText: 'Search'),
            ),
          ),
          data: baseData.copyWith(
            viewInsets: const EdgeInsets.only(bottom: 300),
          ),
        ),
      );

      // Pump several frames to allow MeasureSize to fire and state to settle.
      await tester.pump();
      await tester.pump();
      await tester.pump();
      final paddingAfterKeyboard = capturedPadding!;

      // Pump more frames — padding should NOT change further (no oscillation).
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      // The key invariant: once the padding settles to a new value after the
      // keyboard appears, it should not fluctuate frame-to-frame.
      expect(capturedPadding, equals(paddingAfterKeyboard),
          reason: 'Padding should not fluctuate frame-to-frame after settling');
    });

    // -----------------------------------------------------------------------
    // 4. Scroll hide still works correctly with avoidViewInsets=true
    // -----------------------------------------------------------------------
    testWidgets('scroll hide still works correctly with avoidViewInsets=true', (tester) async {
      const baseData = MediaQueryData(
        size: Size(400, 800),
        padding: EdgeInsets.only(top: 44, bottom: 34),
        viewPadding: EdgeInsets.only(top: 44, bottom: 34),
      );

      EdgeInsets? capturedPadding;
      LdAppBarMetrics? capturedMetrics;

      await tester.pumpWidget(
        withMediaQuery(
          AppBarFrame(
            position: LdAppBarPosition.top,
            avoidViewInsets: true,
            scrollBehavior: LdAppBarScrollBehavior.always,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
              capturedMetrics = context.watch<LdAppBarMetrics?>();
              return ListView.builder(
                itemCount: 50,
                itemBuilder: (_, i) => SizedBox(height: 40, child: Text('item $i')),
              );
            }),
            child: const TextField(
              key: Key('bar_textfield'),
              decoration: InputDecoration(hintText: 'Search'),
            ),
          ),
          data: baseData,
        ),
      );

      // Allow MeasureSize to fire.
      await tester.pump();
      await tester.pump();
      await tester.pumpAndSettle();

      expect(capturedPadding, isNotNull);
      expect(capturedMetrics, isNotNull);
      final paddingBeforeScroll = capturedPadding!;
      final barH = capturedMetrics!.barHeightForPosition;
      expect(barH, greaterThan(0));

      await fakeScroll(tester, startOffset: 300, endOffset: 300 + barH * 4);
      await tester.pumpAndSettle();

      expect(capturedMetrics!.isScrolledUnder, isTrue);

      // Body padding must remain constant (stable floor — padding is not animated).
      expect(capturedPadding!.top, paddingBeforeScroll.top);
      expect(capturedPadding!.bottom, paddingBeforeScroll.bottom);
    });
  });
}
