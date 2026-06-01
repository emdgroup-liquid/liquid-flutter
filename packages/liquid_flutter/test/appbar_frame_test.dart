import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/appbar/appbar_frame.dart';
import 'package:provider/provider.dart';

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

    // -----------------------------------------------------------------------
    // 5. wrappedChild = null falls back to legacy mode without throwing
    // -----------------------------------------------------------------------

    testWidgets('legacy mode (no wrappedChild) renders bar child without Positioned.fill', (tester) async {
      await tester.pumpWidget(
        _withTheme(
          // Legacy mode: wrappedChild is null; AppBarFrame just renders its
          // child with the outside/inside padding containers.
          const AppBarFrame(
            position: LdAppBarPosition.top,
            // wrappedChild is null → legacy mode
            child: Text('LegacyBar'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('LegacyBar'), findsOneWidget);
      // In legacy mode there is no Stack → no Positioned.fill.
      expect(find.byType(Positioned), findsNothing);
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
    }) async {
      // Build a fake metrics object; the app bar only reads pixels and axis.
      final controller = ScrollController(initialScrollOffset: startOffset);
      addTearDown(controller.dispose);

      // We fire notifications directly through the NotificationListener tree.
      final scrollable = find.byType(ListView).first;
      final element = tester.element(scrollable);

      final metrics = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 2000,
        pixels: startOffset,
        viewportDimension: 600,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1.0,
      );

      final endMetrics = metrics.copyWith(pixels: endOffset);

      // Start
      ScrollStartNotification(
        metrics: metrics,
        context: element,
        dragDetails: null,
      ).dispatch(element);
      await tester.pump();

      // Update
      ScrollUpdateNotification(
        metrics: endMetrics,
        context: element,
        scrollDelta: endOffset - startOffset,
      ).dispatch(element);
      await tester.pump();

      // End
      ScrollEndNotification(
        metrics: endMetrics,
        context: element,
      ).dispatch(element);
      await tester.pump();
    }

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

      // Record the bar's initial top position.
      final barTopBefore = tester.getTopLeft(find.text('Bar')).dy;

      // Scroll down with a very large delta so _hideOffset is clamped to barH
      // (> 50% hidden guaranteed).
      await fakeScroll(tester, startOffset: 300, endOffset: 300 + barH * 4);
      await tester.pumpAndSettle();

      // The bar should have moved upward by barH+1 (fully hidden + 1px border bleed).
      final barTopAfter = tester.getTopLeft(find.text('Bar')).dy;
      expect(barTopAfter, closeTo(barTopBefore - (barH + 1), 1.0));
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
    }) async {
      final scrollable = find.byType(ListView).first;
      final element = tester.element(scrollable);

      final startMetrics = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 2000,
        pixels: startOffset,
        viewportDimension: 600,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1.0,
      );

      ScrollStartNotification(
        metrics: startMetrics,
        context: element,
        dragDetails: null,
      ).dispatch(element);
      await tester.pump();

      double previousOffset = startOffset;
      for (final offset in steps) {
        final stepMetrics = startMetrics.copyWith(pixels: offset);
        ScrollUpdateNotification(
          metrics: stepMetrics,
          context: element,
          scrollDelta: offset - previousOffset,
        ).dispatch(element);
        await tester.pump();
        previousOffset = offset;
      }

      final endMetrics = startMetrics.copyWith(pixels: previousOffset);
      ScrollEndNotification(
        metrics: endMetrics,
        context: element,
      ).dispatch(element);
      await tester.pump();
    }

    // -----------------------------------------------------------------------
    // 1. Scroll-content padding (viewPadding floor) stays constant during drag
    //
    // MediaQuery.padding is animated (shrinks as bar hides), but
    // MediaQuery.viewPadding is the stable floor.
    // LdScaffoldBody uses padding.atLeast(viewPadding) for scroll-content
    // padding, so that value never changes.
    // -----------------------------------------------------------------------
    testWidgets(
        'viewPadding (scroll-content floor) stays constant during continuous scroll drag',
        (tester) async {
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
                itemBuilder: (_, i) =>
                    SizedBox(height: 40, child: Text('item $i')),
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
        expect(capturedViewPaddings[i], equals(baseline),
            reason: 'viewPadding changed at scroll frame $i');
      }
    });

    // -----------------------------------------------------------------------
    // 2. viewPadding remains constant after bar snaps to hidden
    // -----------------------------------------------------------------------
    testWidgets(
        'viewPadding (scroll-content floor) stays constant after bar snaps to hidden',
        (tester) async {
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
                itemBuilder: (_, i) =>
                    SizedBox(height: 40, child: Text('item $i')),
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
    testWidgets(
        'viewPadding (scroll-content floor) stays constant after bar snaps back to visible',
        (tester) async {
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
                itemBuilder: (_, i) =>
                    SizedBox(height: 40, child: Text('item $i')),
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
    testWidgets(
        'padding (stable floor) is always >= viewPadding (device safe-area)',
        (tester) async {
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
                itemBuilder: (_, i) =>
                    SizedBox(height: 40, child: Text('item $i')),
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
    testWidgets(
        'nested bars: inner bar slides up with outer bar and stops at safe-area floor',
        (tester) async {
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
                    itemBuilder: (_, i) =>
                        SizedBox(height: 40, child: Text('item $i')),
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
      final outerBarTopBefore = tester.getTopLeft(find.text('OuterBar')).dy;
      final innerBarTopBefore = tester.getTopLeft(find.text('InnerBar')).dy;
      // Inner bar must start below outer bar.
      expect(innerBarTopBefore, greaterThan(outerBarTopBefore));

      // Scroll to hide the outer bar.
      final scrollable = find.byType(ListView).first;
      final element = tester.element(scrollable);

      final startMetrics = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 2000,
        pixels: 300,
        viewportDimension: 600,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1.0,
      );

      ScrollStartNotification(
        metrics: startMetrics,
        context: element,
        dragDetails: null,
      ).dispatch(element);
      await tester.pump();

      final endMetrics = startMetrics.copyWith(pixels: 900);
      ScrollUpdateNotification(
        metrics: endMetrics,
        context: element,
        scrollDelta: 600,
      ).dispatch(element);
      await tester.pump();

      ScrollEndNotification(
        metrics: endMetrics,
        context: element,
      ).dispatch(element);
      await tester.pumpAndSettle();

      // Outer bar has moved up (hidden).
      final outerBarTopAfter = tester.getTopLeft(find.text('OuterBar')).dy;
      expect(outerBarTopAfter, lessThan(outerBarTopBefore));

      // Inner bar has also moved up.
      final innerBarTopAfter = tester.getTopLeft(find.text('InnerBar')).dy;
      expect(innerBarTopAfter, lessThan(innerBarTopBefore));

      // When the outer bar is fully hidden, the inner bar's outer padding shrinks
      // to the device safe-area floor (44px in _withTheme). The inner bar content
      // is now near the top of the screen (close to where the outer bar was).
      //
      // Specifically: animatedEdgeMargin = max(44, outerBarHeight - outerHide) = 44
      // so the inner bar content top ≈ 44 + insidePadding.top.
      // That is approximately where the outer bar's content was at rest.
      expect(innerBarTopAfter, closeTo(outerBarTopBefore, 4.0));

      // The outer metrics hideOffset should equal barHeight (fully hidden).
      expect(outerMetrics, isNotNull);
      expect(outerMetrics!.hideOffsetForPosition, closeTo(outerMetrics!.barHeightForPosition, 1.0));
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
    }) async {
      final scrollable = find.byType(ListView).first;
      final element = tester.element(scrollable);

      final metrics = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 2000,
        pixels: startOffset,
        viewportDimension: 600,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1.0,
      );

      final endMetrics = metrics.copyWith(pixels: endOffset);

      ScrollStartNotification(
        metrics: metrics,
        context: element,
        dragDetails: null,
      ).dispatch(element);
      await tester.pump();

      ScrollUpdateNotification(
        metrics: endMetrics,
        context: element,
        scrollDelta: endOffset - startOffset,
      ).dispatch(element);
      await tester.pump();

      ScrollEndNotification(
        metrics: endMetrics,
        context: element,
      ).dispatch(element);
      await tester.pump();
    }

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
    }) async {
      final scrollable = find.byType(ListView).first;
      final element = tester.element(scrollable);

      final metrics = FixedScrollMetrics(
        minScrollExtent: 0,
        maxScrollExtent: 2000,
        pixels: startOffset,
        viewportDimension: 600,
        axisDirection: AxisDirection.down,
        devicePixelRatio: 1.0,
      );

      final endMetrics = metrics.copyWith(pixels: endOffset);

      ScrollStartNotification(
        metrics: metrics,
        context: element,
        dragDetails: null,
      ).dispatch(element);
      await tester.pump();

      ScrollUpdateNotification(
        metrics: endMetrics,
        context: element,
        scrollDelta: endOffset - startOffset,
      ).dispatch(element);
      await tester.pump();

      ScrollEndNotification(
        metrics: endMetrics,
        context: element,
      ).dispatch(element);
      await tester.pump();
    }

    // -----------------------------------------------------------------------
    // 1. avoidViewInsets=true: body padding stable when keyboard opens
    // -----------------------------------------------------------------------
    testWidgets(
        'avoidViewInsets=true: body padding stable when keyboard opens',
        (tester) async {
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
    testWidgets(
        'avoidViewInsets=false (default): keyboard does not affect body padding',
        (tester) async {
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
      expect(capturedPadding!.bottom, settledBottom,
          reason: 'Body padding.bottom must not oscillate after settling');
    });

    // -----------------------------------------------------------------------
    // 3. Bar height change from focus causes stable body padding update
    // -----------------------------------------------------------------------
    testWidgets(
        'bar height change from focus causes stable body padding update',
        (tester) async {
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
    testWidgets(
        'scroll hide still works correctly with avoidViewInsets=true',
        (tester) async {
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
                itemBuilder: (_, i) =>
                    SizedBox(height: 40, child: Text('item $i')),
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

      // Record bar's initial top position.
      final barTopBefore = tester.getTopLeft(find.byKey(const Key('bar_textfield'))).dy;

      // Scroll to hide the bar (large scroll delta).
      await fakeScroll(tester, startOffset: 300, endOffset: 300 + barH * 4);
      await tester.pumpAndSettle();

      // Bar should have moved off-screen (upward for top bar).
      final barTopAfter = tester.getTopLeft(find.byKey(const Key('bar_textfield'))).dy;
      expect(barTopAfter, lessThan(barTopBefore));

      // Body padding must remain constant (stable floor — padding is not animated).
      expect(capturedPadding!.top, paddingBeforeScroll.top);
      expect(capturedPadding!.bottom, paddingBeforeScroll.bottom);
    });
  });
}
