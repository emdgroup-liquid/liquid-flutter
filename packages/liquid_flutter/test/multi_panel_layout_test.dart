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
      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.sideBySide,
            panelPosition: LdPanelPosition.left,
            initialPanelWidth: 200,
            initialPanelVisible: true,
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The panel is a Positioned widget inside a Stack. When visible and on
      // the left, LdSpring resolves to position 0 (panelTranslation = 0 when
      // visible). The Positioned.left for the left-panel is `transState.position`
      // which equals 0 after settling.
      final panelFinder = find.text('panel');
      expect(panelFinder, findsOneWidget);

      // Panel box must start at or near x = 0 within the layout.
      final panelBox = tester.getTopLeft(panelFinder);
      // The panel text is centred inside its 200px container, so its x offset
      // is at most the full panel width from 0.
      expect(panelBox.dx, lessThan(200));
    });

    // -------------------------------------------------------------------------
    // 2. sideBySide, panel left, hidden
    // -------------------------------------------------------------------------
    testWidgets('sideBySide – panel left, hidden: panel is off-screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.sideBySide,
            panelPosition: LdPanelPosition.left,
            initialPanelWidth: 200,
            initialPanelVisible: false,
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // When hidden on the left, panelTranslation = -panelW = -200.
      // Positioned.left = -200, so the panel sits at x = -200 (fully off left).
      final panelBox = tester.getTopLeft(find.text('panel'));
      // Centre of panel text = -200 + 100 (half of 200px) = -100, which is < 0.
      expect(panelBox.dx, lessThan(0));
    });

    // -------------------------------------------------------------------------
    // 3. sideBySide, panel right, visible
    // -------------------------------------------------------------------------
    testWidgets('sideBySide – panel right, visible: panel is at right side',
        (WidgetTester tester) async {
      const layoutWidth = 800.0;
      const panelWidth = 200.0;

      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.sideBySide,
            panelPosition: LdPanelPosition.right,
            initialPanelWidth: panelWidth,
            initialPanelVisible: true,
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // For a right panel:
      //   panelActualLeft = totalWidth - panelW + transState.position
      //                   = 800 - 200 + 0 = 600   (visible)
      // Panel text is centred, so x = 600 + 100 = 700.
      final panelBox = tester.getTopLeft(find.text('panel'));
      // The panel must be in the right half of the 800-wide layout.
      expect(panelBox.dx, greaterThanOrEqualTo(layoutWidth - panelWidth - 1));
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
            initialPanelWidth: 200,
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
            initialPanelWidth: 200,
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
            initialPanelWidth: 200,
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
            initialPanelWidth: 200,
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
      const initialWidth = 200.0;
      final reportedWidths = <double>[];

      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.sideBySide,
            panelPosition: LdPanelPosition.left,
            allowResize: true,
            initialPanelWidth: initialWidth,
            initialPanelVisible: true,
            onPanelWidthChanged: reportedWidths.add,
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The resize handle occupies an 8px-wide strip at x ≈ panelW - 4 = 196.
      // We drag from the centre of that strip (x=200, y=400) rightward by 50px.
      await performPanGesture(
        tester,
        startPosition: const Offset(200, 400),
        offset: const Offset(50, 0),
      );

      // The internal width should have grown toward 250.
      expect(reportedWidths, isNotEmpty);
      expect(reportedWidths.last, greaterThan(initialWidth));
    });

    // -------------------------------------------------------------------------
    // 8. minPanelWidth clamp: drag to 0 → width == minPanelWidth
    // -------------------------------------------------------------------------
    testWidgets('resize handle drag clamps to minPanelWidth', (WidgetTester tester) async {
      const initialWidth = 200.0;
      const minWidth = 80.0;
      final reportedWidths = <double>[];

      await tester.pumpWidget(
        _wrap(
          LdMultiPanelLayout(
            mode: LdMultiPanelLayoutMode.sideBySide,
            panelPosition: LdPanelPosition.left,
            allowResize: true,
            initialPanelWidth: initialWidth,
            minPanelWidth: minWidth,
            initialPanelVisible: true,
            onPanelWidthChanged: reportedWidths.add,
            body: _placeholder('body', Colors.blue),
            panel: _placeholder('panel', Colors.red),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Drag the resize handle far to the left (–300px) to attempt making
      // panel width negative / below minimum.
      await performPanGesture(
        tester,
        startPosition: const Offset(200, 400),
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
            initialPanelWidth: 200,
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
            initialPanelWidth: 200,
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
    // 14. Regression: panelVisible prop seeds initial visibility in initState
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
            initialPanelWidth: 200,
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
    // 15. Regression: LdDrawerLayout renders at correct width after zero-width
    //     first frame (release-mode / physical device scenario – issue #106).
    //
    //     The fix switches from `initialPanelWidth` (one-time seed, sticks at 0)
    //     to `panelWidth` (reactive / controlled) so that when the LayoutBuilder
    //     re-fires with the real constraints, the drawer panel tracks the new
    //     effective width.
    // -------------------------------------------------------------------------
    testWidgets(
        'LdDrawerLayout: drawer renders at correct width after zero-width first frame',
        (WidgetTester tester) async {
      // Capture injected LdMultiPanelChildState from inside the drawer slot.
      LdMultiPanelChildState? capturedState;

      Widget buildDrawer(Size size) => _wrap(
            LdDrawerLayout(
              reflowBreakpoint: 1200, // force stacked mode at 800 px
              drawerWidth: 250,
              onStateChange: (_) {},
              drawer: Builder(
                builder: (context) {
                  capturedState =
                      Provider.of<LdMultiPanelChildState>(context, listen: false);
                  return _placeholder('drawer', Colors.green);
                },
              ),
              body: _placeholder('body', Colors.blue),
            ),
            size: size,
          );

      // Phase 1: narrow first frame — simulates release mode on a physical
      // device where the outer LayoutBuilder fires with a very small maxWidth
      // before real layout resolves (the effective drawer width is ~82 px,
      // well below the configured 250 px).
      //
      // With the old `initialPanelWidth` (one-time seed), this small value
      // would be seeded into `_internalPanelWidth` and never updated, so the
      // drawer would remain narrow for the widget's lifetime.  With the fix
      // (`panelWidth`, reactive), the correct width is picked up on the next
      // frame.
      await tester.pumpWidget(buildDrawer(const Size(110, 800)));
      await tester.pumpAndSettle();

      // Phase 2: resize to real dimensions — the LayoutBuilder re-fires with
      // the actual constraints.  With `panelWidth` (reactive), the drawer width
      // must update; with the old `initialPanelWidth` (one-time seed) it would
      // stay stuck at ~82 px (min(110 * 0.75, 250) = 82.5).
      await tester.pumpWidget(buildDrawer(const Size(800, 800)));
      await tester.pumpAndSettle();

      // The effective drawer width = min(800 * 0.75, 250) = 250.
      // capturedState is null only if the drawer Builder never ran (layout error).
      expect(capturedState, isNotNull,
          reason: 'Builder inside drawer should have been called');
      expect(
        capturedState!.width,
        closeTo(250, 1),
        reason: 'Drawer panel width must reflect real layout constraints (250 px), '
            'not the narrow first-frame seed (~82 px).',
      );
    });
  });
}
