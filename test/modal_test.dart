// Test LdBreadcrumb

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

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
          child: Scaffold(
            body: Center(
              child: LdModalBuilder(
                builder: (context, open) {
                  return LdButton(
                      child: const Text("Open dialog"), onPressed: open);
                },
                modal: LdModal(
                  title: const Text("Dialog title"),
                  modalContent: (context) => const Text("Dialog content"),
                ),
              ),
            ),
          ),
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

  testWidgets('LdModal injectables work', (WidgetTester test) async {
    final model = TestModel();

    ldDisableAnimations = true;
    await test.pumpWidget(
      liquidFrame(
        isDark: false,
        key: const Key("frame"),
        size: LdThemeSize.m,
        child: SizedBox(
          height: 500,
          child: Scaffold(
            body: Center(
              child: LdModalBuilder(
                builder: (context, open) {
                  return LdButton(
                      child: const Text("Open dialog"), onPressed: open);
                },
                modal: LdModal(
                  injectables: (context) => [
                    ListenableProvider<TestModel>.value(value: model),
                  ],
                  title: const Text("Dialog title"),
                  modalContent: (context1) {
                    final model = context1.watch<TestModel>();
                    return Text(model.value);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await test.pumpAndSettle();

    await test.tap(find.text("Open dialog"));

    await test.pumpAndSettle();

    expect(find.text("Initial"), findsOneWidget);

    model.value = 'Changed';

    await test.pumpAndSettle();

    expect(find.text("Changed"), findsOneWidget);
  });
}

class TestModel extends ChangeNotifier {
  String _value = 'Initial';

  String get value => _value;

  set value(String value) {
    _value = value;
    notifyListeners();
  }
}
