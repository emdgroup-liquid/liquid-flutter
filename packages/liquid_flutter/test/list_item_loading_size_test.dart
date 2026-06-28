import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'utils.dart';

/// Pumps a real [LdListItem] next to its [LdListItemLoading] counterpart under
/// the same [LdListItemConfig] (mirroring how [LdList] wraps its children) and
/// returns the measured heights so we can assert the loader does not cause a
/// scroll jump when it is swapped for a real item.
Future<({double item, double loader})> _measure(
  WidgetTester tester, {
  required EdgeInsets? Function(LdTheme theme) configPadding,
  required Widget? leading,
  required Widget? subtitle,
  required bool hasLeading,
  required bool hasSubtitle,
}) async {
  await tester.pumpWidget(
    withLiquidTheme(
      Builder(
        builder: (context) {
          final theme = LdTheme.of(context);
          final config = LdListItemConfig(padding: configPadding(theme));
          return Align(
            alignment: Alignment.topCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LdListItemConfigProvider(
                  config: config,
                  child: LdListItem(
                    leading: leading,
                    title: const Text("A task title"),
                    subtitle: subtitle,
                  ),
                ),
                LdListItemConfigProvider(
                  config: config,
                  child: LdListItemLoading(
                    hasLeading: hasLeading,
                    hasSubtitle: hasSubtitle,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    ),
  );
  await tester.pump();

  return (
    item: tester.getSize(find.byType(LdListItem)).height,
    loader: tester.getSize(find.byType(LdListItemLoading)).height,
  );
}

void main() {
  group('LdListItemLoading size precision', () {
    testWidgets('matches a real item in a list (config padding, leading + subtitle)', (tester) async {
      final sizes = await _measure(
        tester,
        // [LdList] wraps every item with `MediaQuery.padding + theme.pad()`.
        configPadding: (theme) => theme.pad(),
        leading: const LdAvatar(emoji: true, child: LdText("🐒")),
        subtitle: const Text("Due tomorrow"),
        hasLeading: true,
        hasSubtitle: true,
      );

      expect(sizes.loader, moreOrLessEquals(sizes.item, epsilon: 0.5));
    });

    testWidgets('matches a standalone item (default padding, leading + subtitle)', (tester) async {
      final sizes = await _measure(
        tester,
        configPadding: (theme) => null,
        leading: const LdAvatar(emoji: true, child: LdText("🐒")),
        subtitle: const Text("Due tomorrow"),
        hasLeading: true,
        hasSubtitle: true,
      );

      expect(sizes.loader, moreOrLessEquals(sizes.item, epsilon: 0.5));
    });

    testWidgets('matches a real item without leading (subtitle only)', (tester) async {
      final sizes = await _measure(
        tester,
        configPadding: (theme) => theme.pad(),
        leading: null,
        subtitle: const Text("Due tomorrow"),
        hasLeading: false,
        hasSubtitle: true,
      );

      expect(sizes.loader, moreOrLessEquals(sizes.item, epsilon: 0.5));
    });
  });
}
