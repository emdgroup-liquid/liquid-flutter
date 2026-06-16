import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
import 'package:liquid_flutter_test_utils/system_ui/fairphone_6.dart';
import 'package:liquid_flutter_test_utils/system_ui/ipad_11_pro.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testGoldens("LdTabNavigation Golden", (WidgetTester tester) async {
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

    final fiveTabs = [
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
        label: 'Messages',
        icon: const Icon(LucideIcons.messageCircle),
        route: '/messages',
      ),
      LdNavigationTab(
        label: 'Notifications',
        icon: const Icon(LucideIcons.bell),
        route: '/notifications',
      ),
      LdNavigationTab(
        label: 'Profile',
        icon: const Icon(LucideIcons.user),
        route: '/profile',
      ),
    ];

    final manyTabs = List.generate(
      8,
      (index) => LdNavigationTab(
        label: 'Tab ${index + 1}',
        icon: const Icon(LucideIcons.circle),
        route: '/tab$index',
      ),
    );

    await multiGolden(tester, "LdTabNavigation", {
      "Basic tab navigation": (tester, place) async {
        await place(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Tab navigation with 3 tabs": (tester, place) async {
        await place(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Tab navigation with 5 tabs": (tester, place) async {
        await place(
          LdScaffold(
            body: LdTabNavigation(
              tabs: fiveTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Tab navigation with overflow": (tester, place) async {
        await place(
          LdScaffold(
            body: LdTabNavigation(
              tabs: manyTabs,
              activeRoute: '/tab0',
              onTabPressed: (route) {},
              minTabWidth: 100,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Tab navigation with active tab": (tester, place) async {
        await place(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/search',
              onTabPressed: (route) {},
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Tab navigation at top position": (tester, place) async {
        await place(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              position: LdAppBarPositionMode.top,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Tab navigation at bottom position": (tester, place) async {
        await place(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              position: LdAppBarPositionMode.bottom,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Tab navigation attached": (tester, place) async {
        await place(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              attachedMode: LdAppBarAttachedMode.attached,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Tab navigation floating": (tester, place) async {
        await place(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              attachedMode: LdAppBarAttachedMode.floating,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Tab navigation with background mode visible": (tester, place) async {
        await place(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              backgroundMode: LdAppBarBackgroundMode.visible,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Tab navigation with background mode hidden": (tester, place) async {
        await place(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              backgroundMode: LdAppBarBackgroundMode.hidden,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Tab navigation with scrollable body": (tester, place) async {
        await place(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              child: ListView(
                children: List.generate(
                  10,
                  (index) => LdListItem(
                    title: Text("Item ${index + 1}"),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      "Tab navigation with enableGradient false": (tester, place) async {
        await place(
          LdScaffold(
            body: LdTabNavigation(
              tabs: sampleTabs,
              activeRoute: '/home',
              onTabPressed: (route) {},
              enableGradient: false,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
    }, frameScenarios: [
      fairphone6,
      iPadPro11,
    ]);
  });
}
