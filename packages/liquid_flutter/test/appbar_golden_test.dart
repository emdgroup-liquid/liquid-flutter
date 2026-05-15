import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
import 'package:liquid_flutter_test_utils/system_ui/fairphone_6.dart';
import 'package:liquid_flutter_test_utils/system_ui/iphone_16_pro.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testGoldens("LdAppBar Golden", (WidgetTester tester) async {
    await multiGolden(tester, "LdAppBar", {
      "Top app bar (basic)": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: Text("Top App Bar"),
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Bottom app bar (basic)": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.bottom(
              title: const Text("Bottom App Bar"),
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "App bar with title": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("App Bar Title"),
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "App bar with actions": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("App Bar"),
              actions: [
                LdAppBarAction(
                  onPressed: () {},
                  child: const Text("Action 1"),
                ),
                LdAppBarAction(
                  onPressed: () {},
                  child: const Text("Action 2"),
                ),
              ],
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "App bar with search": (tester, place) async {
        await place(
          Builder(
            builder: (context) => LdScaffold(
              body: LdAppBar.top(
                searchConfig: LdSearchConfig(onSearch: (value) {}, hint: "Search..."),
                child: Center(
                  child: LdText.p("Body Content"),
                ),
              ),
            ),
          ),
        );
      },
      "App bar with leading and trailing": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("App Bar"),
              leading: const Icon(LucideIcons.menu),
              trailing: const Icon(LucideIcons.settings),
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "App bar attached": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("Attached App Bar"),
              attachedMode: LdAppBarAttachedMode.attached,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "App bar floating": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("Floating App Bar"),
              attachedMode: LdAppBarAttachedMode.floating,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "App bar with background mode visible": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("App Bar"),
              backgroundMode: LdAppBarBackgroundMode.visible,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "App bar with background mode hidden": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("App Bar"),
              backgroundMode: LdAppBarBackgroundMode.hidden,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "App bar with shadow mode visible": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("App Bar"),
              shadowMode: LdAppBarShadowMode.visible,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "App bar with shadow mode hidden": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("App Bar"),
              shadowMode: LdAppBarShadowMode.hidden,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "App bar with border mode visible": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("App Bar"),
              borderMode: LdAppBarBorderMode.visible,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "App bar with border mode hidden": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("App Bar"),
              borderMode: LdAppBarBorderMode.hidden,
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Multiple app bars stacked": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("First App Bar"),
              child: LdAppBar.top(
                title: const Text("Second App Bar"),
                child: Center(
                  child: LdText.p("Body Content"),
                ),
              ),
            ),
          ),
        );
      },
      "App bar with bottom widget": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("App Bar"),
              bottom: const Text("Bottom Content"),
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "App bar with custom backgroundColor": (tester, place) async {
        await place(
          Builder(
            builder: (context) => LdScaffold(
              body: LdAppBar.top(
                title: const Text("App Bar"),
                backgroundMode: LdAppBarBackgroundMode.visible,
                backgroundColor: LdTheme.of(context).primaryColor,
                child: Center(
                  child: LdText.p("Body Content"),
                ),
              ),
            ),
          ),
        );
      },
    }, frameScenarios: [
      iPhone16Pro,
      fairphone6
    ], themeSizeScenarios: [
      LdThemeSize.m
    ]);
  });
}
