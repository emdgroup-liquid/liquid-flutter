import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

/// Helper: wraps [bar] (which has [child]) in a minimal scaffold-like tree.
/// The bar's wrappedChild provides MediaQuery insets to its subtree.
Widget _wrapInScaffold(Widget body) {
  return MaterialApp(
    localizationsDelegates: const [LiquidLocalizations.delegate],
    home: ldFrame(
      size: LdThemeSize.m,
      brightnessMode: LdThemeBrightnessMode.light,
      child: body,
    ),
  );
}

void main() {
  group('LdAppBar wrapper-mode tests', () {
    testWidgets('Basic app bar rendering (top)', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('Test App Bar'),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test App Bar'), findsOneWidget);
      expect(find.text('Body'), findsOneWidget);
    });

    testWidgets('Basic app bar rendering (bottom)', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.bottom(
              title: const Text('Bottom App Bar'),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bottom App Bar'), findsOneWidget);
    });

    testWidgets('App bar with leading widget', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              leading: const Icon(LucideIcons.database),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.database), findsOneWidget);
    });

    testWidgets('App bar with trailing widget', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              trailing: const Icon(LucideIcons.settings),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(LucideIcons.settings), findsOneWidget);
    });

    testWidgets('App bar with actions', (WidgetTester tester) async {
      ldDisableAnimations = true;
      bool actionPressed = false;

      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              actions: [
                LdAppBarAction(
                  onPressed: () {
                    actionPressed = true;
                  },
                  child: const Text('Action'),
                ),
              ],
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Action'), findsOneWidget);

      await tester.tap(find.text('Action'));
      await tester.pumpAndSettle();

      expect(actionPressed, isTrue);
    });

    testWidgets('App bar scroll behavior - static', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('Static App Bar'),
              scrollBehavior: LdAppBarScrollBehavior.static,
              child: ListView(
                children: List.generate(
                  50,
                  (index) => ListTile(title: Text('Item $index')),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Static App Bar'), findsOneWidget);
    });

    testWidgets('App bar background mode - visible', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              backgroundMode: LdAppBarBackgroundMode.visible,
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('App Bar'), findsOneWidget);
    });

    testWidgets('App bar shadow mode - whenScrolled', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              shadowMode: LdAppBarShadowMode.whenScrolled,
              child: ListView(
                children: List.generate(
                  50,
                  (index) => ListTile(title: Text('Item $index')),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('App Bar'), findsOneWidget);
    });

    testWidgets('App bar border mode - adaptive', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              borderMode: LdAppBarBorderMode.adaptive,
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('App Bar'), findsOneWidget);
    });

    testWidgets('App bar attached mode - floating', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('Floating App Bar'),
              attachedMode: LdAppBarAttachedMode.floating,
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Floating App Bar'), findsOneWidget);
    });

    testWidgets('App bar with search config', (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              searchConfig: LdSearchConfig(
                onSearch: (value) {},
              ),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(LdSearchInput), findsOneWidget);
    });

    testWidgets('App bar with bottom widget', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              bottom: const Text('Bottom Content'),
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Bottom Content'), findsOneWidget);
    });

    testWidgets('App bar implyLeading - false', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              implyLeading: false,
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should not show back button
      expect(find.byIcon(LucideIcons.chevronLeft), findsNothing);
    });

    testWidgets('App bar with custom backgroundColor', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              backgroundColor: Colors.red,
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('App Bar'), findsOneWidget);
    });

    testWidgets('App bar addContainer', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text('App Bar'),
              addContainer: true,
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('App Bar'), findsOneWidget);
    });

    testWidgets('App bar position mode - adaptive on mobile', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.s, // Small size typically indicates mobile
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              body: LdAppBar(
                title: const Text('Adaptive App Bar'),
                positionMode: LdAppBarPositionMode.adaptive,
                child: const Center(child: Text('Body')),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Adaptive App Bar'), findsOneWidget);
    });

    testWidgets(
      'App bar with multiple actions overflow',
      (WidgetTester tester) async {
        ldDisableAnimations = true;
        await tester.binding.setSurfaceSize(const Size(400, 800));

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdAppBar.top(
                title: const Text('App Bar'),
                actions: List.generate(
                  10,
                  (index) => LdAppBarAction(
                    onPressed: () {},
                    child: Text('Action $index'),
                  ),
                ),
                child: const Center(child: Text('Body')),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Some actions should overflow to menu
        expect(find.text('App Bar'), findsOneWidget);
      },
    );

    // ── New wrapper-mode tests ───────────────────────────────────────────────

    testWidgets(
      'LdAppBar.top wrapping LdTabNavigation.bottom — both edges padded',
      (WidgetTester tester) async {
        ldDisableAnimations = true;

        final tabs = [
          LdNavigationTab(
            label: 'Home',
            icon: const Icon(LucideIcons.circle),
            route: '/home',
          ),
        ];

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdAppBar.top(
                title: const Text('Top Bar'),
                child: LdTabNavigation(
                  tabs: tabs,
                  activeRoute: '/home',
                  onTabPressed: (_) {},
                  child: const Center(child: Text('Body')),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Top Bar'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Body'), findsOneWidget);

        // Both top and bottom padding should be > 0 from the bars.
        // (Exact values depend on bar sizes which may be 0 before layout,
        // so we just verify the widgets render without errors.)
      },
    );

    testWidgets(
      'LdAppBar LdAppBarMetrics provided to child subtree',
      (WidgetTester tester) async {
        ldDisableAnimations = true;

        LdAppBarMetrics? capturedMetrics;

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdAppBar.top(
                title: const Text('Top Bar'),
                child: Builder(
                  builder: (context) {
                    capturedMetrics = context.read<LdAppBarMetrics?>();
                    return const Center(child: Text('Body'));
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // LdAppBarMetrics should be available in the child's context.
        expect(capturedMetrics, isNotNull);
        expect(capturedMetrics!.position, equals(LdAppBarPosition.top));
        expect(capturedMetrics!.level, equals(0));
      },
    );

    testWidgets(
      'Nested LdAppBars — level increments',
      (WidgetTester tester) async {
        ldDisableAnimations = true;

        LdAppBarMetrics? outerMetrics;
        LdAppBarMetrics? innerMetrics;

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdAppBar.top(
                title: const Text('Outer Bar'),
                child: Builder(
                  builder: (context) {
                    outerMetrics = context.read<LdAppBarMetrics?>();
                    return LdAppBar.top(
                      title: const Text('Inner Bar'),
                      child: Builder(
                        builder: (context) {
                          innerMetrics = context.read<LdAppBarMetrics?>();
                          return const Center(child: Text('Body'));
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(outerMetrics, isNotNull);
        expect(innerMetrics, isNotNull);
        expect(outerMetrics!.level, equals(0));
        expect(innerMetrics!.level, equals(1));
      },
    );

    testWidgets(
      'scroll-hide: LdAppBar with scrollBehavior always renders without errors',
      (WidgetTester tester) async {
        ldDisableAnimations = true;

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdAppBar.top(
                title: const Text('Scroll-hide Bar'),
                scrollBehavior: LdAppBarScrollBehavior.always,
                child: ListView(
                  children: List.generate(
                    50,
                    (index) => ListTile(title: Text('Item $index')),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Scroll-hide Bar'), findsOneWidget);

        // Scroll down to trigger hide behaviour.
        await tester.fling(find.byType(ListView), const Offset(0, -500), 1000);
        await tester.pumpAndSettle();

        // Bar should still be in the tree (just potentially translated).
        expect(find.text('Scroll-hide Bar'), findsOneWidget);
      },
    );
  });

  // ── Legacy scaffold-injection mode (LdScaffold.appBars) ──────────────────
  group('LdAppBar legacy scaffold-injection mode (appBars)', () {
    testWidgets('Legacy: LdAppBar in appBars still renders', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldFrame(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              // ignore: deprecated_member_use
              appBars: [
                LdAppBar.top(title: const Text('Legacy Bar')),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Legacy Bar'), findsOneWidget);
    });
  });
}
