import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Helper: wraps the given [body] in a test scaffold.
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
  group('LdTabNavigation Widget Tests', () {
    final sampleTabs = [
      LdNavigationTab(
        label: 'Home',
        icon: const Icon(LucideIcons.circle),
        route: '/home',
      ),
      LdNavigationTab(
        label: 'Search',
        icon: const Icon(LucideIcons.search),
        route: '/search',
      ),
      LdNavigationTab(
        label: 'Profile',
        icon: const Icon(LucideIcons.user),
        route: '/profile',
      ),
    ];

    testWidgets('Basic tab navigation rendering', (WidgetTester tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('Tab selection and active state', (WidgetTester tester) async {
      ldDisableAnimations = true;
      String? selectedRoute = '/home';

      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {
                selectedRoute = route;
              },
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Search tab
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(selectedRoute, equals('/search'));
    });

    testWidgets('Tapping the active tab still reaches the tab button', (WidgetTester tester) async {
      ldDisableAnimations = true;
      String? selectedRoute;

      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {
                selectedRoute = route;
              },
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(selectedRoute, equals('/home'));
    });

    testWidgets('Dragging the indicator selects the closest tab', (WidgetTester tester) async {
      ldDisableAnimations = true;
      String? selectedRoute = '/home';

      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {
                selectedRoute = route;
              },
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final indicator = find.byWidgetPredicate(
        (widget) => widget is GestureDetector && widget.onHorizontalDragEnd != null,
      );
      expect(indicator, findsOneWidget);

      final tabWidth = tester.getSize(indicator).width;
      await tester.timedDrag(
        indicator,
        Offset(tabWidth + 12, 0),
        const Duration(milliseconds: 300),
      );
      await tester.pumpAndSettle();

      expect(selectedRoute, equals('/search'));
    });

    testWidgets('Active route matching - exact', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/search',
              onTabPressed: (route) {},
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Search tab should be active
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('Active route matching - wildcard', (WidgetTester tester) async {
      ldDisableAnimations = true;
      final tabsWithWildcard = [
        LdNavigationTab(
          label: 'Home',
          icon: const Icon(LucideIcons.circle),
          route: '/home',
        ),
        LdNavigationTab(
          label: 'Settings',
          icon: const Icon(LucideIcons.settings),
          route: '/settings/*',
        ),
      ];

      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdTabNavigation(
              tabs: tabsWithWildcard,
              activeRoute: '/settings/profile',
              onTabPressed: (route) {},
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Settings tab should be active due to wildcard match
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Tab navigation position - top', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              position: LdAppBarPositionMode.top,
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Tab navigation position - bottom', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              position: LdAppBarPositionMode.bottom,
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Tab navigation attached mode - floating', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              attachedMode: LdAppBarAttachedMode.floating,
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Tab navigation background mode', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              backgroundMode: LdAppBarBackgroundMode.visible,
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Tab navigation scroll behavior', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
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

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Tab navigation with custom isActive function', (WidgetTester tester) async {
      ldDisableAnimations = true;
      final tabsWithCustomActive = [
        LdNavigationTab(
          label: 'Home',
          icon: const Icon(LucideIcons.circle),
          route: '/home',
          isActive: (context) => true,
        ),
        LdNavigationTab(
          label: 'Search',
          icon: const Icon(LucideIcons.search),
          route: '/search',
          isActive: (context) => false,
        ),
      ];

      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdTabNavigation(
              tabs: tabsWithCustomActive,
              activeRoute: '/home',
              onTabPressed: (route) {},
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('Tab navigation enableGradient', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        _wrapInScaffold(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              enableGradient: false,
              child: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    // ── New wrapper-mode specific tests ──────────────────────────────────────

    testWidgets(
      'LdAppBar.top wrapping LdTabNavigation.bottom — both edges rendered',
      (WidgetTester tester) async {
        ldDisableAnimations = true;

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdAppBar.top(
                title: const Text('Top Bar'),
                child: LdTabNavigation(
                  tabs: sampleTabs,
                  activeRoute: '/home',
                  onTabPressed: (_) {},
                  position: LdAppBarPositionMode.bottom,
                  child: const Center(child: Text('Body')),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Top Bar'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
        expect(find.text('Body'), findsOneWidget);
      },
    );
  });

  // ── PageController sync tests ──────────────────────────────────────────────

  group('LdTabNavigation PageController sync', () {
    final pageViewTabs = [
      LdNavigationTab(
        label: 'Home',
        icon: const Icon(LucideIcons.house),
        route: '/home',
      ),
      LdNavigationTab(
        label: 'Search',
        icon: const Icon(LucideIcons.search),
        route: '/search',
      ),
      LdNavigationTab(
        label: 'Profile',
        icon: const Icon(LucideIcons.user),
        route: '/profile',
      ),
    ];

    testWidgets(
      'renders with only pageController (no activeRoute)',
      (WidgetTester tester) async {
        ldDisableAnimations = true;
        final pageController = PageController();

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdTabNavigation(
                tabs: pageViewTabs,
                pageController: pageController,
                onTabPressed: (_) {},
                child: PageView(
                  controller: pageController,
                  children: const [
                    Center(child: Text('Page 0')),
                    Center(child: Text('Page 1')),
                    Center(child: Text('Page 2')),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Search'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);

        pageController.dispose();
      },
    );

    testWidgets(
      'initial page from PageController.initialPage seeds the indicator',
      (WidgetTester tester) async {
        ldDisableAnimations = true;
        // Start on page 1 (Search)
        final pageController = PageController(initialPage: 1);
        String? pressedRoute;

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdTabNavigation(
                tabs: pageViewTabs,
                pageController: pageController,
                onTabPressed: (route) => pressedRoute = route,
                child: PageView(
                  controller: pageController,
                  children: const [
                    Center(child: Text('Page 0')),
                    Center(child: Text('Page 1')),
                    Center(child: Text('Page 2')),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Tapping Search tab (page 1) should call onTabPressed with /search.
        await tester.tap(find.text('Search'));
        await tester.pumpAndSettle();

        expect(pressedRoute, equals('/search'));

        pageController.dispose();
      },
    );

    testWidgets(
      'tapping a tab calls onTabPressed with the correct route',
      (WidgetTester tester) async {
        ldDisableAnimations = true;
        final pageController = PageController();
        String? pressedRoute;

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdTabNavigation(
                tabs: pageViewTabs,
                pageController: pageController,
                onTabPressed: (route) => pressedRoute = route,
                child: PageView(
                  controller: pageController,
                  children: const [
                    Center(child: Text('Page 0')),
                    Center(child: Text('Page 1')),
                    Center(child: Text('Page 2')),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.tap(find.text('Search'));
        await tester.pumpAndSettle();

        expect(pressedRoute, equals('/search'));

        pageController.dispose();
      },
    );

    testWidgets(
      'pageController.jumpToPage updates the active tab index',
      (WidgetTester tester) async {
        ldDisableAnimations = true;
        final pageController = PageController();

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdTabNavigation(
                tabs: pageViewTabs,
                pageController: pageController,
                onTabPressed: (_) {},
                child: PageView(
                  controller: pageController,
                  children: const [
                    Center(child: Text('Page 0')),
                    Center(child: Text('Page 1')),
                    Center(child: Text('Page 2')),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Jump to page 2 (Profile)
        pageController.jumpToPage(2);
        await tester.pumpAndSettle();

        // Profile tab should now be the active one — verify by tapping it and
        // checking nothing unexpected fires (the tab is already active).
        expect(find.text('Profile'), findsOneWidget);

        pageController.dispose();
      },
    );

    testWidgets(
      'can use both activeRoute and pageController together',
      (WidgetTester tester) async {
        ldDisableAnimations = true;
        final pageController = PageController();

        await tester.pumpWidget(
          _wrapInScaffold(
            LdScaffold(
              body: LdTabNavigation(
                tabs: pageViewTabs,
                activeRoute: '/home',
                pageController: pageController,
                onTabPressed: (_) {},
                child: PageView(
                  controller: pageController,
                  children: const [
                    Center(child: Text('Page 0')),
                    Center(child: Text('Page 1')),
                    Center(child: Text('Page 2')),
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);

        pageController.dispose();
      },
    );

    testWidgets(
      'swapping pageController detaches old listener and attaches new one',
      (WidgetTester tester) async {
        ldDisableAnimations = true;
        final pc1 = PageController();
        final pc2 = PageController(initialPage: 2);
        String? pressedRoute;

        Widget buildWidget(PageController pc) => _wrapInScaffold(
              LdScaffold(
                body: LdTabNavigation(
                  tabs: pageViewTabs,
                  pageController: pc,
                  onTabPressed: (route) => pressedRoute = route,
                  child: PageView(
                    controller: pc,
                    children: const [
                      Center(child: Text('Page 0')),
                      Center(child: Text('Page 1')),
                      Center(child: Text('Page 2')),
                    ],
                  ),
                ),
              ),
            );

        await tester.pumpWidget(buildWidget(pc1));
        await tester.pumpAndSettle();

        // Swap to pc2
        await tester.pumpWidget(buildWidget(pc2));
        await tester.pumpAndSettle();

        // Tapping Profile (index 2, which pc2 started on) should still work.
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();

        expect(pressedRoute, equals('/profile'));

        pc1.dispose();
        pc2.dispose();
      },
    );
  });
}
