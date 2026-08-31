import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
import 'package:liquid_flutter_test_utils/system_ui/fairphone_6.dart';
import 'package:liquid_flutter_test_utils/system_ui/iphone_16_pro.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testGoldens('LdRawAppBar Golden', (WidgetTester tester) async {
    await multiGolden(
      tester,
      'LdRawAppBar',
      {
        'Bottom raw app bar (basic)': (tester, place) async {
          await place(
            LdScaffold(
              body: LdRawAppBar.bottom(
                content: const Text('Raw content'),
                child: Center(
                  child: LdText.p('Body Content'),
                ),
              ),
            ),
          );
        },
        'Leading scroll trailing': (tester, place) async {
          await place(
            LdScaffold(
              body: LdAppBar.top(
                title: const Text('Title'),
                child: LdRawAppBar.bottom(
                  leading: LdButton.outline(
                    onPressed: () {},
                    child: const Icon(LucideIcons.plus),
                  ),
                  trailing: LdButton.filled(
                    onPressed: () {},
                    child: const Icon(LucideIcons.arrowUp),
                  ),
                  content: LdHorizontalScroll(
                    layout: LdHorizontalScrollLayout.scroll,
                    children: const [
                      LdTag(child: Text('Inbox')),
                      LdTag(child: Text('Starred')),
                      LdTag(child: Text('Sent')),
                      LdTag(child: Text('Drafts')),
                      LdTag(child: Text('Archive')),
                      LdTag(child: Text('Spam')),
                    ],
                  ),
                  child: Center(
                    child: LdText.p('Body Content'),
                  ),
                ),
              ),
            ),
          );
        },
        'Centered wrap': (tester, place) async {
          await place(
            LdScaffold(
              body: LdRawAppBar.bottom(
                layout: LdRawAppBarLayout.center,
                leading: LdButton.outline(
                  onPressed: () {},
                  child: const Icon(LucideIcons.plus),
                ),
                trailing: LdButton.filled(
                  onPressed: () {},
                  child: const Icon(LucideIcons.arrowUp),
                ),
                content: const LdTag(child: Text('Compose')),
                child: Center(
                  child: LdText.p('Body Content'),
                ),
              ),
            ),
          );
        },
        'Inside decoration': (tester, place) async {
          await place(
            Builder(
              builder: (context) {
                final theme = LdTheme.of(context);
                return LdScaffold(
                  body: LdRawAppBar.bottom(
                    insideDecoration: BoxDecoration(
                      color: theme.surface,
                      borderRadius: theme.radius(LdSize.l),
                      border: Border.all(
                        color: theme.floatingBorder,
                        width: theme.borderWidth,
                      ),
                    ),
                    leading: LdButton.outline(
                      onPressed: () {},
                      child: const Icon(LucideIcons.plus),
                    ),
                    trailing: LdButton.filled(
                      onPressed: () {},
                      child: const Icon(LucideIcons.arrowUp),
                    ),
                    content: const Text('Decorated'),
                    child: Center(
                      child: LdText.p('Body Content'),
                    ),
                  ),
                );
              },
            ),
          );
        },
      },
      frameScenarios: [
        iPhone16Pro,
        fairphone6,
      ],
      themeSizeScenarios: [
        LdThemeSize.m,
      ],
    );
  });
}
