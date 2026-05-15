import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
import 'package:liquid_flutter_test_utils/system_ui/fairphone_6.dart';
import 'package:liquid_flutter_test_utils/system_ui/ipad_11_pro.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testGoldens("LdScaffold Golden", (WidgetTester tester) async {
    await multiGolden(tester, "LdScaffold", {
      "Basic scaffold with body": (tester, place) async {
        await place(
          LdScaffold(
            body: Center(
              child: LdText.p("Body Content"),
            ),
          ),
        );
      },
      "Scaffold with top app bar": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("Top App Bar"),
              child: Center(
                child: LdText.p("Body Content"),
              ),
            ),
          ),
        );
      },
      "Scaffold with bottom app bar": (tester, place) async {
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
      "Scaffold with both top and bottom app bars": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("Top App Bar"),
              child: LdAppBar.bottom(
                title: const Text("Bottom App Bar"),
                child: Center(
                  child: LdText.p("Body Content"),
                ),
              ),
            ),
          ),
        );
      },
      "Scaffold with drawer": (tester, place) async {
        await place(
          LdScaffold(
            drawer: LdAutoSpace(
              children: [
                const LdSectionHeader("Section 1"),
                LdDrawerItemSection(
                  active: true,
                  leading: const Icon(LucideIcons.circle),
                  child: const Text("Item 1"),
                ),
                LdDrawerItemSection(
                  leading: const Icon(LucideIcons.circle),
                  child: const Text("Item 2"),
                ),
              ],
            ),
            body: Center(
              child: LdText.p("Body Content"),
            ),
          ),
        );
      },
      "Scaffold with multiple app bars at same position": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("First Top App Bar"),
              child: LdAppBar.top(
                title: const Text("Second Top App Bar"),
                child: Center(
                  child: LdText.p("Body Content"),
                ),
              ),
            ),
          ),
        );
      },
      "Scaffold with scrollable body": (tester, place) async {
        await place(
          LdScaffold(
            body: LdAppBar.top(
              title: const Text("Scrollable Content"),
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
      "Scaffold with extendBodyBehindAppBar": (tester, place) async {
        await place(
          Builder(
            builder: (context) => LdScaffold(
              extendBodyBehindAppBar: true,
              body: LdAppBar.top(
                title: const Text("Extended Body"),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        LdTheme.of(context).primaryColor.withAlpha(100),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Center(
                    child: LdText.p("Body Behind App Bar"),
                  ),
                ),
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
