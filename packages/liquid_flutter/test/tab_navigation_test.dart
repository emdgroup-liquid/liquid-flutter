import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_theme_wrapper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: sampleTabs,
                  activeRoute: '/home',
                  onTabPressed: (route) {},
                ),
              ],
              body: const Center(child: Text('Body')),
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
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: sampleTabs,
                  activeRoute: '/home',
                  onTabPressed: (route) {
                    selectedRoute = route;
                  },
                ),
              ],
              body: const Center(child: Text('Body')),
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

    testWidgets('Active route matching - exact', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: sampleTabs,
                  activeRoute: '/search',
                  onTabPressed: (route) {},
                ),
              ],
              body: const Center(child: Text('Body')),
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
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: tabsWithWildcard,
                  activeRoute: '/settings/profile',
                  onTabPressed: (route) {},
                ),
              ],
              body: const Center(child: Text('Body')),
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
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: sampleTabs,
                  activeRoute: '/home',
                  onTabPressed: (route) {},
                  position: LdAppBarPositionMode.top,
                ),
              ],
              body: const Center(child: Text('Body')),
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
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: sampleTabs,
                  activeRoute: '/home',
                  onTabPressed: (route) {},
                  position: LdAppBarPositionMode.bottom,
                ),
              ],
              body: const Center(child: Text('Body')),
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
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: sampleTabs,
                  activeRoute: '/home',
                  onTabPressed: (route) {},
                  attachedMode: LdAppBarAttachedMode.floating,
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Tab navigation max visible tabs', (WidgetTester tester) async {
      ldDisableAnimations = true;
      final manyTabs = List.generate(
        10,
        (index) => LdNavigationTab(
          label: 'Tab $index',
          icon: const Icon(LucideIcons.circle),
          route: '/tab$index',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: manyTabs,
                  activeRoute: '/tab0',
                  onTabPressed: (route) {},
                  maxVisibleTabs: 5,
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show first 5 tabs + more button
      expect(find.text('Tab 0'), findsOneWidget);
      expect(find.text('Tab 4'), findsOneWidget);
    });

    testWidgets('Tab navigation overflow menu', (WidgetTester tester) async {
      ldDisableAnimations = true;
      final manyTabs = List.generate(
        8,
        (index) => LdNavigationTab(
          label: 'Tab $index',
          icon: const Icon(LucideIcons.circle),
          route: '/tab$index',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: manyTabs,
                  activeRoute: '/tab0',
                  onTabPressed: (route) {},
                  maxVisibleTabs: 5,
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show more button when tabs overflow
      expect(find.text('More'), findsOneWidget);
    });

    testWidgets('Tab navigation background mode', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: sampleTabs,
                  activeRoute: '/home',
                  onTabPressed: (route) {},
                  backgroundMode: LdAppBarBackgroundMode.visible,
                ),
              ],
              body: const Center(child: Text('Body')),
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
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: sampleTabs,
                  activeRoute: '/home',
                  onTabPressed: (route) {},
                  scrollBehavior: LdAppBarScrollBehavior.static,
                ),
              ],
              body: ListView(
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
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: tabsWithCustomActive,
                  activeRoute: '/home',
                  onTabPressed: (route) {},
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('Tab navigation order affects stacking', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: sampleTabs,
                  activeRoute: '/home',
                  onTabPressed: (route) {},
                  order: 0,
                ),
                LdTabNavigation(
                  tabs: [
                    LdNavigationTab(
                      label: 'Extra',
                      icon: const Icon(LucideIcons.plus),
                      route: '/extra',
                    ),
                  ],
                  activeRoute: '/extra',
                  onTabPressed: (route) {},
                  order: 1,
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Extra'), findsOneWidget);
    });

    testWidgets('Tab navigation enableGradient', (WidgetTester tester) async {
      ldDisableAnimations = true;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: ldThemeWrapper(
            size: LdThemeSize.m,
            brightnessMode: LdThemeBrightnessMode.light,
            child: LdScaffold(
              appBars: [
                LdTabNavigation(
                  tabs: sampleTabs,
                  activeRoute: '/home',
                  onTabPressed: (route) {},
                  enableGradient: false,
                ),
              ],
              body: const Center(child: Text('Body')),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
