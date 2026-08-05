import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:liquid_flutter_test_utils/ld_frame_options.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _wrap(
  Widget child, {
  LdFrameOptions ldFrameOptions = const LdFrameOptions(),
}) {
  return MaterialApp(
    localizationsDelegates: const [LiquidLocalizations.delegate],
    home: ldFrame(
      size: LdThemeSize.m,
      brightnessMode: LdThemeBrightnessMode.light,
      ldFrameOptions: ldFrameOptions,
      child: child,
    ),
  );
}

void main() {
  group('LdNavigationRail', () {
    final sampleTabs = [
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

    testWidgets('renders destinations', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            height: 400,
            child: LdNavigationRail(
              destinations: sampleTabs,
              activeRoute: '/home',
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('fires onDestinationSelected on tap', (tester) async {
      ldDisableAnimations = true;
      String? selected;

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            height: 400,
            child: LdNavigationRail(
              destinations: sampleTabs,
              activeRoute: '/home',
              onDestinationSelected: (route) => selected = route,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();

      expect(selected, '/search');
    });

    testWidgets('matches wildcard routes', (tester) async {
      ldDisableAnimations = true;
      final tabs = [
        LdNavigationTab(
          label: 'Home',
          icon: const Icon(LucideIcons.house),
          route: '/home',
        ),
        LdNavigationTab(
          label: 'Settings',
          icon: const Icon(LucideIcons.settings),
          route: '/settings*',
        ),
      ];

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            height: 400,
            child: LdNavigationRail(
              destinations: tabs,
              activeRoute: '/settings/profile',
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(tabs[1].matches(tester.element(find.text('Settings')), '/settings/profile'), isTrue);
      expect(tabs[0].matches(tester.element(find.text('Home')), '/settings/profile'), isFalse);
    });

    testWidgets('matches via isActive callback', (tester) async {
      ldDisableAnimations = true;
      final tabs = [
        LdNavigationTab(
          label: 'Home',
          icon: const Icon(LucideIcons.house),
          route: '/home',
          isActive: (_) => false,
        ),
        LdNavigationTab(
          label: 'Custom',
          icon: const Icon(LucideIcons.star),
          route: '/ignored',
          isActive: (_) => true,
        ),
      ];

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            height: 400,
            child: LdNavigationRail(
              destinations: tabs,
              activeRoute: '/home',
              onDestinationSelected: (_) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final context = tester.element(find.text('Custom'));
      expect(tabs[1].matches(context, '/home'), isTrue);
      expect(tabs[0].matches(context, '/home'), isFalse);
    });

    testWidgets('compact layout uses Column for destinations', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _wrap(
          Center(
            child: SizedBox(
              width: 100,
              height: 500,
              child: LdNavigationRail(
                destinations: sampleTabs,
                activeRoute: '/home',
                onDestinationSelected: (_) {},
                extendedBreakpoint: LdNavigationRail.defaultExtendedBreakpoint,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('ld-navigation-rail-compact')), findsOneWidget);
      expect(find.byType(AspectRatio), findsWidgets);
    });

    testWidgets('extended layout uses Row for destinations', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _wrap(
          Center(
            child: SizedBox(
              width: 240,
              height: 400,
              child: LdNavigationRail(
                destinations: sampleTabs,
                activeRoute: '/home',
                onDestinationSelected: (_) {},
                extendedBreakpoint: LdNavigationRail.defaultExtendedBreakpoint,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('ld-navigation-rail-extended')), findsOneWidget);
      expect(find.byType(AspectRatio), findsNothing);
    });

    testWidgets('renders leading and trailing', (tester) async {
      ldDisableAnimations = true;

      await tester.pumpWidget(
        _wrap(
          SizedBox(
            width: 200,
            height: 400,
            child: LdNavigationRail(
              destinations: sampleTabs,
              activeRoute: '/home',
              onDestinationSelected: (_) {},
              leading: const Text('Leading'),
              trailing: const Text('Trailing'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Leading'), findsOneWidget);
      expect(find.text('Trailing'), findsOneWidget);
    });

    testWidgets('works inside LdScaffold drawer', (tester) async {
      ldDisableAnimations = true;
      String? selected;

      await tester.binding.setSurfaceSize(const Size(1000, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        _wrap(
          LdScaffold(
            drawerWidth: LdNavigationRail.defaultWidth,
            drawerMinWidth: LdNavigationRail.defaultMinWidth,
            drawer: LdNavigationRail(
              destinations: sampleTabs,
              activeRoute: '/home',
              onDestinationSelected: (route) => selected = route,
            ),
            body: const Center(child: Text('Body')),
          ),
          ldFrameOptions: const LdFrameOptions(platform: LdPlatform.macos),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(selected, '/search');
    });
  });

  group('LdNavigationTab.matches', () {
    testWidgets('exact route', (tester) async {
      await tester.pumpWidget(
        _wrap(const SizedBox.shrink()),
      );
      final context = tester.element(find.byType(SizedBox));
      const tab = LdNavigationTab(
        label: 'Home',
        icon: Icon(LucideIcons.house),
        route: '/home',
      );
      expect(tab.matches(context, '/home'), isTrue);
      expect(tab.matches(context, '/other'), isFalse);
    });
  });
}
