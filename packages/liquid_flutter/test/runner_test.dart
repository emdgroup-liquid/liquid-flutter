import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

Widget _wrapWithMaterialApp(Widget widget) {
  return LdNotificationProvider(
    child: LdThemeProvider(
      child: LdThemedAppBuilder(
        appBuilder: (context, theme) => MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: Scaffold(body: widget),
        ),
      ),
    ),
  );
}

void main() {
  group('LdRunnerLog selection', () {
    const messages = ['first line', 'second line'];

    testWidgets('brings its own selection region when standing alone', (WidgetTester tester) async {
      await tester.pumpWidget(_wrapWithMaterialApp(const LdRunnerLog(messages: messages)));
      await tester.pumpAndSettle();

      expect(find.byType(SelectableRegion), findsOneWidget);
      expect(find.text('first line'), findsOneWidget);
    });

    testWidgets('joins an enclosing selection region instead of nesting', (WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapWithMaterialApp(
          const SelectionArea(child: LdRunnerLog(messages: messages)),
        ),
      );
      await tester.pumpAndSettle();

      // The one region is the enclosing SelectionArea's; a nested one would
      // cut the log off from any selection started outside it.
      expect(find.byType(SelectableRegion), findsOneWidget);
      expect(find.text('first line'), findsOneWidget);
    });
  });
}
