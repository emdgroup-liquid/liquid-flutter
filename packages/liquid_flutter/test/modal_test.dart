// Test LdBreadcrumb

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'golden_utils.dart';

void main() {
  testWidgets('LdModal', (WidgetTester test) async {
    ldDisableAnimations = true;
    await test.pumpWidget(
      liquidFrame(
        isDark: false,
        key: const Key("frame"),
        size: LdThemeSize.m,
        child: SizedBox(
          height: 500,
          child: Builder(builder: (context) {
            return Scaffold(
                body: Center(
              child: LdModalBuilder(
                builder: (context, open) {
                  return LdButton(onPressed: open, child: const Text("Open dialog"));
                },
                modal: LdModalRoute(
                  context: context,
                  pageBuilder: (context) => const LdScaffold(
                    appBars: [LdAppBar(title: Text("Dialog title"))],
                    body: LdScaffoldBody(children: [LdText("Dialog content")]),
                  ),
                ),
              ),
            ));
          }),
        ),
      ),
    );

    await test.pumpAndSettle();

    await test.tap(find.text("Open dialog"));

    await test.pumpAndSettle();

    expect(find.text("Dialog title"), findsOneWidget);
    expect(find.text("Dialog content"), findsOneWidget);

    await test.tap(find.byIcon(LucideIcons.x));

    await test.pumpAndSettle();
  });
}
