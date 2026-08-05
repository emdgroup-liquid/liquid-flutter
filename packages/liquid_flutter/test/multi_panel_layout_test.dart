import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/drawer_layout.dart';
import 'package:provider/provider.dart';

import 'utils.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Wraps [child] with the standard liquid theme + MaterialApp used by other
/// tests in this package. [size] defaults to 800×800.
Widget _wrap(Widget child, {Size size = const Size(800, 800)}) {
  ldDisableAnimations = true;
  return LdThemeProvider(
    theme: LdTheme(),
    child: MaterialApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        LiquidLocalizations.delegate,
      ],
      home: Scaffold(
        body: Directionality(
          textDirection: TextDirection.ltr,
          child: MediaQuery(
            data: MediaQueryData(size: size),
            child: SizedBox(
              width: size.width,
              height: size.height,
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

/// A simple colored container used as panel / body placeholders.
Widget _placeholder(String label, Color color) => ColoredBox(
      color: color,
      child: Center(child: Text(label)),
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('LdMultiPanelLayout', () {
    // -------------------------------------------------------------------------
    // 1. sideBySide, panel left, visible
    // -------------------------------------------------------------------------
    testWidgets('sideBySide – panel left, visible: panel is at left edge',
        (WidgetTester tester) async {
      LdMultiPanelChildState? capturedPanelState;

      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.sideBySide,
            panelPosition: LdPanelPosition.left,
            panelWidth: 200,
            initialPanelVisible: true,
            body: _placeholder('body', Colors.blue),
            panel: Builder(
              builder: (context) {
                capturedPanelState = Provider.of<LdMultiPanelChildState>(context, listen: false);
                return _placeholder('panel', Colors.red);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The panel is rendered in a full-width overlay but its logical position
      // is tracked via LdMultiPanelChildState. When visible on the left its
      // left offset should be near 0 and its width should be ~200px.
      expect(capturedPanelState, isNotNull);
      expect(capturedPanelState!.left, closeTo(0, 1));
      expect(capturedPanelState!.width, closeTo(200, 1));
    });

    // -------------------------------------------------------------------------
    // 2. sideBySide, panel left, hidden
    // -------------------------------------------------------------------------
    testWidgets('sideBySide – panel left, hidden: panel is off-screen',
        (WidgetTester tester) async {
      LdMultiPanelChildState? capturedPanelState;

      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.sideBySide,
            panelPosition: LdPanelPosition.left,
            panelWidth: 200,
            initialPanelVisible: false,
            body: _placeholder('body', Colors.blue),
            panel: Builder(
              builder: (context) {
                capturedPanelState = Provider.of<LdMultiPanelChildState>(context, listen: false);
                return _placeholder('panel', Colors.red);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // When hidden on the left the panel's logical left offset is negative
      // (panel is fully translated off-screen to the left).
      expect(capturedPanelState, isNotNull);
      expect(capturedPanelState!.left, lessThan(0));
      expect(capturedPanelState!.onScreen, isFalse);
    });

    // -------------------------------------------------------------------------
    // 3. sideBySide, panel right, visible
    // -------------------------------------------------------------------------
    testWidgets('sideBySide – panel right, visible: panel is at right side',
        (WidgetTester tester) async {
      const layoutWidth = 800.0;
      const panelWidth = 200.0;
      LdMultiPanelChildState? capturedPanelState;

      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.sideBySide,
            panelPosition: LdPanelPosition.right,
            panelWidth: panelWidth,
            initialPanelVisible: true,
            body: _placeholder('body', Colors.blue),
            panel: Builder(
              builder: (context) {
                capturedPanelState = Provider.of<LdMultiPanelChildState>(context, listen: false);
                return _placeholder('panel', Colors.red);
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // For a visible right panel the logical left offset should be at
      // layoutWidth - panelWidth = 600.
      expect(capturedPanelState, isNotNull);
      expect(capturedPanelState!.left, closeTo(layoutWidth - panelWidth, 1));
      expect(capturedPanelState!.width, closeTo(panelWidth, 1));
    });

    // -------------------------------------------------------------------------
    // 4. stacked, panel left, visible → scrim ModalBarrier is in tree
    // -------------------------------------------------------------------------
    testWidgets('stacked – panel left, visible: scrim ModalBarrier added when visible',
        (WidgetTester tester) async {
      // Use initialPanelVisible: true so initState sets _panelVisible = true.
      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.stacked,
            panelPosition: LdPanelPosition.left,
            panelWidth: 200,
            initialPanelVisible: true,
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // With the panel visible, scrimOpacity = 0.5 > 0, so the ModalBarrier is
      // conditionally rendered by our layout. Baseline from plain MaterialApp = 1;
      // our scrim adds a second one → total >= 2.
      final visibleCount = tester.widgetList(find.byType(ModalBarrier)).length;
      expect(visibleCount, greaterThanOrEqualTo(2));
    });

    // -------------------------------------------------------------------------
    // 5. stacked, panel left, hidden → scrim ModalBarrier not added
    // -------------------------------------------------------------------------
    testWidgets('stacked – panel left, hidden: scrim ModalBarrier is not added',
        (WidgetTester tester) async {
      // Start visible (initialPanelVisible: true) so _panelVisible = true.
      // Use a unique key so that the second pumpWidget call forces a fresh initState.
      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            key: const ValueKey('stacked-visible'),
            mode: LdMultiPanelLayoutMode.stacked,
            panelPosition: LdPanelPosition.left,
            panelWidth: 200,
            initialPanelVisible: true,
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final visibleCount = tester.widgetList(find.byType(ModalBarrier)).length;

      // Replace with a different key to force a fresh widget state with
      // initialPanelVisible: false → _panelVisible = false in initState.
      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            key: const ValueKey('stacked-hidden'),
            mode: LdMultiPanelLayoutMode.stacked,
            panelPosition: LdPanelPosition.left,
            panelWidth: 200,
            initialPanelVisible: false,
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final hiddenCount = tester.widgetList(find.byType(ModalBarrier)).length;

      // Hidden state should have fewer ModalBarriers than visible state.
      expect(hiddenCount, lessThan(visibleCount));
    });

    // -------------------------------------------------------------------------
    // 6. onPanelVisibilityChanged fires when panel is dismissed via swipe
    // -------------------------------------------------------------------------
    testWidgets(
        'onPanelVisibilityChanged fires when panel is swiped closed in stacked mode',
        (WidgetTester tester) async {
      final callbacks = <bool>[];

      // Start with the panel visible in stacked mode.
      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.stacked,
            panelPosition: LdPanelPosition.left,
            panelWidth: 200,
            initialPanelVisible: true,
            onPanelVisibilityChanged: (v) => callbacks.add(v),
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(callbacks, isEmpty);

      // Swipe left on the panel to close it. The swipe-to-close GestureDetector
      // is placed over the panel area (left=0, width=200) when the panel is
      // visible. A leftward swipe > 30% of panelWidth (60px) dismisses the panel.
      await performPanGesture(
        tester,
        startPosition: const Offset(100, 400),
        offset: const Offset(-180, 0), // 90% of 200px → well over 30% threshold
      );

      // Closing the panel fires onPanelVisibilityChanged(false).
      expect(callbacks, [false]);
    });

    // -------------------------------------------------------------------------
    // 7. resize handle drag increases panel width
    // -------------------------------------------------------------------------
    testWidgets('resize handle drag increases panel width', (WidgetTester tester) async {
      const initialWidth = 300.0;
      final reportedWidths = <double>[];

      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.sideBySide,
            panelPosition: LdPanelPosition.left,
            allowResize: true,
            panelWidth: initialWidth,
            initialPanelVisible: true,
            onPanelWidthChanged: reportedWidths.add,
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // With panelWidth=300 and totalWidth=800 the resize handle sits at
      // x = bodyLeft = panelFraction * totalWidth = 300px.
      // The handle is 8px wide, so we tap at x=304 (centre) and drag right.
      await performPanGesture(
        tester,
        startPosition: const Offset(304, 400),
        offset: const Offset(50, 0),
      );

      // The effective panel width should have grown beyond initialWidth.
      expect(reportedWidths, isNotEmpty);
      expect(reportedWidths.last, greaterThan(initialWidth));
    });

    // -------------------------------------------------------------------------
    // 8. minPanelWidth clamp: drag to 0 → width == minPanelWidth
    // -------------------------------------------------------------------------
    testWidgets('resize handle drag clamps to minPanelWidth', (WidgetTester tester) async {
      const minWidth = 80.0;
      const startWidth = 300.0;
      final reportedWidths = <double>[];

      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.sideBySide,
            panelPosition: LdPanelPosition.left,
            allowResize: true,
            panelWidth: startWidth,
            minPanelWidth: minWidth,
            initialPanelVisible: true,
            onPanelWidthChanged: reportedWidths.add,
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drag the resize handle (at x≈300) far to the left to attempt pushing
      // panel width below the minimum.
      await performPanGesture(
        tester,
        startPosition: const Offset(304, 400),
        offset: const Offset(-300, 0),
      );

      expect(reportedWidths, isNotEmpty);
      // The width must never go below minPanelWidth.
      expect(reportedWidths.last, greaterThanOrEqualTo(minWidth));
      for (final w in reportedWidths) {
        expect(w, greaterThanOrEqualTo(minWidth));
      }
    });

    // -------------------------------------------------------------------------
    // 9. LdMultiPanelChildState.role injected correctly
    // -------------------------------------------------------------------------
    testWidgets(
        'LdMultiPanelChildState.role is panel for panel child and body for body child',
        (WidgetTester tester) async {
      LdPanelRole? capturedPanelRole;
      LdPanelRole? capturedBodyRole;

      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.sideBySide,
            panelPosition: LdPanelPosition.left,
            panelWidth: 200,
            initialPanelVisible: true,
            panel: Builder(
              builder: (context) {
                capturedPanelRole =
                    Provider.of<LdMultiPanelChildState>(context, listen: false).role;
                return const SizedBox.expand();
              },
            ),
            body: Builder(
              builder: (context) {
                capturedBodyRole =
                    Provider.of<LdMultiPanelChildState>(context, listen: false).role;
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(capturedPanelRole, LdPanelRole.panel);
      expect(capturedBodyRole, LdPanelRole.body);
    });

    // -------------------------------------------------------------------------
    // 10. LdDrawerLayout.openDrawer sets isOpen = true
    // -------------------------------------------------------------------------
    testWidgets('LdDrawerLayout.openDrawer sets isOpen = true', (WidgetTester tester) async {
      LdDrawerState? lastState;
      final drawerKey = GlobalKey<LdDrawerLayoutState>();

      await tester.pumpWidget(
        _wrap(
          LdDrawerLayout(
            key: drawerKey,
            reflowBreakpoint: 1200, // Force stacked mode at 800px width.
            drawerWidth: 250,
            drawerMinWidth: 200,
            onStateChange: (s) => lastState = s,
            drawer: _placeholder('drawer', Colors.green),
            body: _placeholder('body', Colors.blue),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(lastState?.isOpen ?? false, isFalse);

      drawerKey.currentState!.openDrawer();
      await tester.pumpAndSettle();

      expect(lastState?.isOpen, isTrue);

      // Close before test end to avoid setState-on-defunct-element during teardown.
      drawerKey.currentState!.closeDrawer();
      await tester.pumpAndSettle();
    });

    // -------------------------------------------------------------------------
    // 11. LdDrawerLayout.closeDrawer sets isOpen = false
    // -------------------------------------------------------------------------
    testWidgets('LdDrawerLayout.closeDrawer sets isOpen = false', (WidgetTester tester) async {
      LdDrawerState? lastState;
      final drawerKey = GlobalKey<LdDrawerLayoutState>();

      await tester.pumpWidget(
        _wrap(
          LdDrawerLayout(
            key: drawerKey,
            reflowBreakpoint: 1200,
            drawerWidth: 250,
            drawerMinWidth: 200,
            onStateChange: (s) => lastState = s,
            drawer: _placeholder('drawer', Colors.green),
            body: _placeholder('body', Colors.blue),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open first.
      drawerKey.currentState!.openDrawer();
      await tester.pumpAndSettle();
      expect(lastState?.isOpen, isTrue);

      // Then close.
      drawerKey.currentState!.closeDrawer();
      await tester.pumpAndSettle();
      expect(lastState?.isOpen, isFalse);
    });

    // -------------------------------------------------------------------------
    // 12. LdDrawerLayout back-button: LocalHistoryEntry added when open
    // -------------------------------------------------------------------------
    testWidgets(
        'LdDrawerLayout: LocalHistoryEntry is added when drawer opens and removed when it closes',
        (WidgetTester tester) async {
      final drawerKey = GlobalKey<LdDrawerLayoutState>();

      // We need a real Navigator so LocalHistoryEntry can be registered on a
      // ModalRoute. MaterialApp provides that.
      await tester.pumpWidget(
        LdThemeProvider(
          theme: LdTheme(),
          child: MaterialApp(
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              LiquidLocalizations.delegate,
            ],
            home: Scaffold(
              body: Directionality(
                textDirection: TextDirection.ltr,
                child: MediaQuery(
                  data: const MediaQueryData(size: Size(800, 800)),
                  child: SizedBox(
                    width: 800,
                    height: 800,
                    child: LdDrawerLayout(
                      key: drawerKey,
                      reflowBreakpoint: 1200,
                      drawerWidth: 250,
                      drawerMinWidth: 200,
                      onStateChange: (_) {},
                      drawer: _placeholder('drawer', Colors.green),
                      body: Builder(
                        builder: (context) => _placeholder('body', Colors.blue),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Before open: no local history entries → canPop is false.
      final NavigatorState navigator = tester.state(find.byType(Navigator).first);
      expect(navigator.canPop(), isFalse);

      // Open drawer → a LocalHistoryEntry is added → canPop becomes true.
      drawerKey.currentState!.openDrawer();
      await tester.pumpAndSettle();
      expect(navigator.canPop(), isTrue);

      // Close drawer → the history entry is removed → canPop becomes false again.
      drawerKey.currentState!.closeDrawer();
      await tester.pumpAndSettle();
      expect(navigator.canPop(), isFalse);
    });
    // -------------------------------------------------------------------------
    // 13. Regression: tapping the scrim closes the panel in stacked mode
    // -------------------------------------------------------------------------
    testWidgets('stacked – tapping scrim closes the panel',
        (WidgetTester tester) async {
      final callbacks = <bool>[];

      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.stacked,
            panelPosition: LdPanelPosition.left,
            panelWidth: 200,
            initialPanelVisible: true,
            onPanelVisibilityChanged: callbacks.add,
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on the body area (x=600, well outside the 200px panel).
      await tester.tapAt(const Offset(600, 400));
      await tester.pumpAndSettle();

      expect(callbacks, [false],
          reason: 'Tapping the scrim should close the panel');
    });

    // -------------------------------------------------------------------------
    // 13b. Regression: scrim dismiss keeps LdDrawerLayout state in sync
    // -------------------------------------------------------------------------
    testWidgets(
        'LdDrawerLayout: scrim dismiss reports isOpen false and openDrawer works again',
        (WidgetTester tester) async {
      LdDrawerState? lastState;
      final drawerKey = GlobalKey<LdDrawerLayoutState>();

      await tester.pumpWidget(
        _wrap(
          LdDrawerLayout(
            key: drawerKey,
            reflowBreakpoint: 1200,
            drawerWidth: 250,
            drawerMinWidth: 200,
            onStateChange: (s) => lastState = s,
            drawer: _placeholder('drawer', Colors.green),
            body: _placeholder('body', Colors.blue),
          ),
        ),
      );
      await tester.pumpAndSettle();

      drawerKey.currentState!.openDrawer();
      await tester.pumpAndSettle();
      expect(lastState?.isOpen, isTrue);

      await tester.tapAt(const Offset(600, 400));
      await tester.pumpAndSettle();

      expect(lastState?.isOpen, isFalse,
          reason: 'Dismiss via scrim must sync LdDrawerLayout._panelVisible');

      drawerKey.currentState!.openDrawer();
      await tester.pumpAndSettle();

      expect(lastState?.isOpen, isTrue);
      expect(find.text('drawer'), findsOneWidget);

      drawerKey.currentState!.closeDrawer();
      await tester.pumpAndSettle();
    });

    // -------------------------------------------------------------------------
    // 14. Stage 1 regression: spring elements survive mode switches
    //
    // In the refactored layout:
    //   - sideBySide uses Key('offset_spring') and Key('ratio_spring')
    //   - stacked uses Key('panel')
    // The panel widget itself is always kept alive via the `child` slot of the
    // spring, so switching modes should not remount the panel content.
    // -------------------------------------------------------------------------
    testWidgets(
        'Key("panel") spring in stacked mode survives a stacked rebuild',
        (WidgetTester tester) async {
      final visibilityNotifier = ValueNotifier<bool>(true);

      await tester.pumpWidget(
        _wrap(
          ValueListenableBuilder<bool>(
            valueListenable: visibilityNotifier,
            builder: (context, visible, _) {
              return LdMultiPanelLayout(
                mode: LdMultiPanelLayoutMode.stacked,
                panelPosition: LdPanelPosition.left,
                panelWidth: 200,
                panelVisible: visible,
                body: _placeholder('body', Colors.blue),
                panel: _placeholder('panel', Colors.red),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Capture the element for Key('panel') while in stacked mode.
      final elementBefore = tester.element(find.byKey(const Key('panel')));

      // Toggle visibility — the stacked spring must survive without teardown.
      visibilityNotifier.value = false;
      await tester.pumpAndSettle();

      final elementAfterHide = tester.element(find.byKey(const Key('panel')));
      expect(
        identical(elementBefore, elementAfterHide),
        isTrue,
        reason:
            'Key("panel") spring element must survive a visibility toggle in stacked mode',
      );

      visibilityNotifier.value = true;
      await tester.pumpAndSettle();

      final elementAfterShow = tester.element(find.byKey(const Key('panel')));
      expect(
        identical(elementBefore, elementAfterShow),
        isTrue,
        reason:
            'Key("panel") spring element must survive show → hide → show in stacked mode',
      );

      visibilityNotifier.dispose();
    });

    testWidgets(
        'Key("offset_spring") in sideBySide mode survives a resize rebuild',
        (WidgetTester tester) async {
      final widthNotifier = ValueNotifier<double>(200);

      await tester.pumpWidget(
        _wrap(
          ValueListenableBuilder<double>(
            valueListenable: widthNotifier,
            builder: (context, width, _) {
              return LdMultiPanelLayout(
                mode: LdMultiPanelLayoutMode.sideBySide,
                panelPosition: LdPanelPosition.left,
                panelWidth: width,
                initialPanelVisible: true,
                body: _placeholder('body', Colors.blue),
                panel: _placeholder('panel', Colors.red),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final elementBefore = tester.element(find.byKey(const Key('offset_spring')));

      // Update panel width — the spring must survive without teardown.
      widthNotifier.value = 250;
      await tester.pumpAndSettle();

      final elementAfter = tester.element(find.byKey(const Key('offset_spring')));
      expect(
        identical(elementBefore, elementAfter),
        isTrue,
        reason:
            'Key("offset_spring") element must survive a panelWidth update in sideBySide mode',
      );

      widthNotifier.dispose();
    });

    // -------------------------------------------------------------------------
    // 15. Stage 2: during drag the panel renders at the dragged position
    // -------------------------------------------------------------------------
    testWidgets(
        'stacked – mid-drag panel tracks finger 1:1 (overriden=true during drag)',
        (WidgetTester tester) async {
      // Panel starts visible on the left, width = 200px.
      // During a leftward drag, overriden=true forces the spring to track the
      // finger position immediately (no spring catch-up lag).
      // After gesture ends, overriden=false and spring snaps/animates back.

      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.stacked,
            panelPosition: LdPanelPosition.left,
            panelWidth: 200,
            initialPanelVisible: true,
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Record the panel's starting left edge.
      final panelBoxBefore = tester.getTopLeft(find.text('panel'));
      expect(panelBoxBefore.dx, greaterThanOrEqualTo(0),
          reason: 'Panel should start fully on-screen');

      // Begin a closing swipe but do NOT end it — check mid-drag state.
      final gesture = await tester.startGesture(
        const Offset(100, 400),
      );
      await tester.pump();

      // Drag 50px to the left in 5 steps.
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(-10, 0));
        await tester.pump();
      }

      // Mid-drag: panel should have shifted left by ~50px.
      final panelBoxDuring = tester.getTopLeft(find.text('panel'));
      expect(panelBoxDuring.dx, lessThan(panelBoxBefore.dx),
          reason: 'Panel should shift left during a closing drag');
      expect(panelBoxDuring.dx, closeTo(panelBoxBefore.dx - 50, 5),
          reason: 'Panel should track finger 1:1 with overriden=true (±5px)');

      // End the gesture and settle — panel springs back to visible position.
      await gesture.up();
      await tester.pumpAndSettle();

      final panelBoxAfter = tester.getTopLeft(find.text('panel'));
      expect(panelBoxAfter.dx, closeTo(panelBoxBefore.dx, 1),
          reason: 'Panel should snap back to visible position after gesture ends');
    });

    // -------------------------------------------------------------------------
    // 16. Regression: panelVisible prop seeds initial visibility in initState (was 15)
    // -------------------------------------------------------------------------
    testWidgets('panelVisible prop is honoured as initial visibility seed',
        (WidgetTester tester) async {
      // Pass panelVisible: true with no initialPanelVisible — the panel must
      // start visible (regression for desktop auto-open via LdDrawerLayout).
      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.sideBySide,
            panelPosition: LdPanelPosition.left,
            panelWidth: 200,
            panelVisible: true, // controlled prop only — no initialPanelVisible
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Panel must be on-screen: its left edge should be >= 0.
      final panelBox = tester.getTopLeft(find.text('panel'));
      expect(panelBox.dx, greaterThanOrEqualTo(0),
          reason: 'Panel should be visible when panelVisible: true is passed');
    });

    // -------------------------------------------------------------------------
    // 17. Stage 3: widget.body and widget.panel elements survive a resize drag
    // -------------------------------------------------------------------------
    testWidgets(
        'sideBySide – widget.body and widget.panel element identity preserved across resize drag',
        (WidgetTester tester) async {
      // Use a stable GlobalKey so we can find the exact Element for body/panel.
      final bodyKey = GlobalKey();
      final panelKey = GlobalKey();

      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.sideBySide,
            panelPosition: LdPanelPosition.left,
            allowResize: true,
            panelWidth: 200,
            initialPanelVisible: true,
            body: SizedBox.expand(key: bodyKey),
            panel: SizedBox.expand(key: panelKey),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Capture element identity before the resize gesture.
      final bodyElementBefore = bodyKey.currentContext!;
      final panelElementBefore = panelKey.currentContext!;

      // The resize handle is an 8px strip centred at x ≈ panelW - 4 = 196.
      // Drag rightward by 50px to simulate a resize.
      await performPanGesture(
        tester,
        startPosition: const Offset(200, 400), // centre of handle strip
        offset: const Offset(50, 0),
      );
      await tester.pumpAndSettle();

      // Element identity must be preserved — no remount of body or panel.
      expect(
        identical(bodyElementBefore, bodyKey.currentContext!),
        isTrue,
        reason: 'widget.body must not be remounted during a resize drag',
      );
      expect(
        identical(panelElementBefore, panelKey.currentContext!),
        isTrue,
        reason: 'widget.panel must not be remounted during a resize drag',
      );
    });

    // -------------------------------------------------------------------------
    // Regression: panelWidth updates when parent layout constraints change
    // -------------------------------------------------------------------------
    testWidgets('panelWidth from parent updates reactively across layout passes',
        (WidgetTester tester) async {
      const narrowWidth = 40.0;
      const fullWidth = 800.0;
      const drawerWidth = 250.0;

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: narrowWidth,
            child: LdDrawerLayout(
              reflowBreakpoint: 1200,
              drawerWidth: drawerWidth,
              drawerMinWidth: 200,
              onStateChange: (_) {},
              drawer: _placeholder('drawer', Colors.green),
              body: _placeholder('body', Colors.blue),
            ),
          ),
          size: const Size(narrowWidth, 800),
        ),
      );
      await tester.pumpAndSettle();

      // Should not throw during the narrow first pass.
      expect(find.text('drawer'), findsOneWidget);

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: fullWidth,
            child: LdDrawerLayout(
              reflowBreakpoint: 1200,
              drawerWidth: drawerWidth,
              drawerMinWidth: 200,
              onStateChange: (_) {},
              drawer: _placeholder('drawer', Colors.green),
              body: _placeholder('body', Colors.blue),
            ),
          ),
          size: const Size(fullWidth, 800),
        ),
      );
      await tester.pumpAndSettle();

      final panelState = LdMultiPanelChildState.of(
        tester.element(find.text('drawer')),
      );
      expect(panelState.width, drawerWidth);
    });
  });
}
