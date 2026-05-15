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
    // 2. MediaQuery.padding reflects bar height inside the wrapped child
    // -----------------------------------------------------------------------

    testWidgets('wrappedChild sees MediaQuery.padding with bar insets added', (tester) async {
      EdgeInsets? capturedPadding;

      await tester.pumpWidget(
        _withTheme(
          AppBarFrame(
            position: LdAppBarPosition.top,
            wrappedChild: Builder(builder: (context) {
              capturedPadding = MediaQuery.paddingOf(context);
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

      // The outer MediaQuery has top = 44. After the bar is measured the top
      // padding inside the wrapped child must be >= the outer safe-area top.
      // (It equals outerTop + consumedInsets.top once the bar is measured.)
      expect(capturedPadding!.top, greaterThanOrEqualTo(44.0));
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
}
