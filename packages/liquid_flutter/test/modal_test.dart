// Test LdBreadcrumb

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_test_utils/ld_frame.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

void main() {
  testWidgets('LdModal', (WidgetTester test) async {
    ldDisableAnimations = true;
    await test.pumpWidget(
      ldFrame(
        size: LdThemeSize.m,
        brightnessMode: LdThemeBrightnessMode.light,
        child: SizedBox(
          height: 500,
          child: Builder(builder: (context) {
            return LdScaffold(
                body: Center(
              child: LdModalBuilder(
                builder: (context, open) {
                  return LdButton(onPressed: open, child: const Text("Open dialog"));
                },
                modal: LdModalRoute(
                  context: context,
                  pageBuilder: (context) => LdScaffold(
                    body: LdAppBar(
                      title: Text("Dialog title"),
                      child: LdScaffoldBody(children: [
                        LdText(
                          "Dialog content",
                        )
                      ]),
                    ),
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
