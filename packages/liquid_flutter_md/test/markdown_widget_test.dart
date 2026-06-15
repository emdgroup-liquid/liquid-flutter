import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_md/markdown_widget.dart';

Widget _withTheme(Widget child) {
  ldDisableAnimations = true;
  return LdThemeProvider(
    theme: LdTheme(),
    child: MaterialApp(
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        LiquidLocalizations.delegate,
      ],
      home: Scaffold(body: child),
    ),
  );
}

void main() {
  testWidgets('renders flat list as rich text', (tester) async {
    await tester.pumpWidget(
      _withTheme(
        const LdMarkdown(
          data: '- Item **one**\n- Item two',
        ),
      ),
    );

    expect(find.textContaining('Item one'), findsOneWidget);
    expect(find.textContaining('Item two'), findsOneWidget);
  });

  testWidgets('renders nested list with indent', (tester) async {
    await tester.pumpWidget(
      _withTheme(
        const LdMarkdown(
          data: '* Something here\n  * Something nested\n* A third item',
        ),
      ),
    );

    final outer = tester.getTopLeft(find.textContaining('Something here'));
    final inner = tester.getTopLeft(find.textContaining('Something nested'));
    final third = tester.getTopLeft(find.textContaining('A third item'));

    expect(inner.dx, greaterThan(outer.dx));
    expect(third.dx, closeTo(outer.dx, 1));
    expect(inner.dy - outer.dy, greaterThan(0));
    expect(third.dy - inner.dy, greaterThan(0));
    expect(third.dy - inner.dy, closeTo(inner.dy - outer.dy, 4));
  });

  testWidgets('renders headings and paragraphs', (tester) async {
    await tester.pumpWidget(
      _withTheme(
        const LdMarkdown(
          data: '# Title\n\nA paragraph with [link](https://example.com).',
        ),
      ),
    );

    expect(find.textContaining('Title'), findsOneWidget);
    expect(find.textContaining('A paragraph with'), findsOneWidget);
    expect(find.textContaining('link'), findsOneWidget);
  });
}
