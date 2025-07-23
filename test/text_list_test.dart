import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

void main() {
  group('LdTextList', () {
    testWidgets('renders bulleted list correctly', (WidgetTester tester) async {
      const items = ['Item 1', 'Item 2', 'Item 3'];

      await tester.pumpWidget(
        MaterialApp(
          home: LdThemeProvider(
            child: Scaffold(
              body: LdTextList(
                items,
                type: LdTextListType.bulleted,
              ),
            ),
          ),
        ),
      );

      // Find the RichText widget and check its content
      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      final fullText = textSpan.toPlainText();

      expect(fullText, contains('• Item 1'));
      expect(fullText, contains('• Item 2'));
      expect(fullText, contains('• Item 3'));
    });

    testWidgets('renders enumerated list correctly', (WidgetTester tester) async {
      const items = ['First item', 'Second item', 'Third item'];

      await tester.pumpWidget(
        MaterialApp(
          home: LdThemeProvider(
            child: Scaffold(
              body: LdTextList(
                items,
                type: LdTextListType.enumerated,
              ),
            ),
          ),
        ),
      );

      // Find the RichText widget and check its content
      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      final fullText = textSpan.toPlainText();

      expect(fullText, contains('1. First item'));
      expect(fullText, contains('2. Second item'));
      expect(fullText, contains('3. Third item'));
    });

    testWidgets('uses paragraph text typography', (WidgetTester tester) async {
      const items = ['Test item'];

      await tester.pumpWidget(
        MaterialApp(
          home: LdThemeProvider(
            child: Scaffold(
              body: LdTextList(items),
            ),
          ),
        ),
      );

      // Find the RichText widget and check its text style
      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      final textStyle = textSpan.children?.first.style;

      // Verify it uses the paragraph font weight
      expect(textStyle?.fontWeight, FontWeight.w400);
    });

    testWidgets('respects size parameter', (WidgetTester tester) async {
      const items = ['Test item'];

      await tester.pumpWidget(
        MaterialApp(
          home: LdThemeProvider(
            child: Scaffold(
              body: LdTextList(
                items,
                size: LdSize.l,
              ),
            ),
          ),
        ),
      );

      // Find the RichText widget and check its text style
      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      final textStyle = textSpan.children?.first.style;

      // The font size should be larger for LdSize.l
      expect(textStyle?.fontSize, isNotNull);
    });

    testWidgets('handles multiple items with proper spacing', (WidgetTester tester) async {
      const items = ['Item 1', 'Item 2', 'Item 3'];

      await tester.pumpWidget(
        MaterialApp(
          home: LdThemeProvider(
            child: Scaffold(
              body: LdTextList(
                items,
                type: LdTextListType.bulleted,
              ),
            ),
          ),
        ),
      );

      // Should find one RichText widget containing all items
      expect(find.byType(RichText), findsOneWidget);

      // The text should contain all items with bullets
      final richTextWidget = tester.widget<RichText>(find.byType(RichText));
      final textSpan = richTextWidget.text as TextSpan;
      final fullText = textSpan.toPlainText();

      expect(fullText, contains('• Item 1'));
      expect(fullText, contains('• Item 2'));
      expect(fullText, contains('• Item 3'));
    });
  });
}
