import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'utils.dart';

void main() {
  group('LdMasterDetail Tests', () {
    testWidgets('renders master view and opens detail view on item selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        withLiquidTheme(
          LdMasterDetail<String>(
            buildMaster: (context, openItem, isSeparatePage, controller) => ElevatedButton(
              onPressed: () => controller.openItem('Item 1'),
              child: const Text('Open Item 1'),
            ),
            buildDetail: (context, item, isSeparatePage, controller) => Text('Detail View: $item'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Open Item 1'), findsOneWidget);
      expect(find.text('Detail View: Item 1'), findsNothing);

      await tester.tap(find.text('Open Item 1'));
      await tester.pumpAndSettle();

      expect(find.text('Detail View: Item 1'), findsOneWidget);
    });
  });
}
