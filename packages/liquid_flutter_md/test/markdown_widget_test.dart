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

  testWidgets('renders footnote refs and definitions', (tester) async {
    await tester.pumpWidget(
      _withTheme(
        const LdMarkdown(
          data:
              'Here is a simple footnote,[^1] and a named one.[^bignote]\n'
              '\n'
              '[^1]: First footnote body.\n'
              '\n'
              '[^bignote]: Named footnote body.\n',
        ),
      ),
    );

    expect(find.textContaining('Here is a simple footnote'), findsOneWidget);
    expect(find.byType(LdContextMenu), findsNWidgets(2));
    expect(find.textContaining('First footnote body'), findsNothing);
    expect(find.textContaining('Named footnote body'), findsNothing);
    expect(find.text('section'), findsNothing);

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('First footnote body'), findsOneWidget);
  });

  testWidgets('omits unused footnote definitions', (tester) async {
    await tester.pumpWidget(
      _withTheme(
        const LdMarkdown(
          data: 'Hello world.\n\n[^unused]: Should not appear.\n',
        ),
      ),
    );

    expect(find.textContaining('Hello world'), findsOneWidget);
    expect(find.textContaining('Should not appear'), findsNothing);
    expect(find.byType(LdContextMenu), findsNothing);
    expect(find.text('section'), findsNothing);
  });

  testWidgets('renders multi-paragraph footnote bodies', (tester) async {
    await tester.pumpWidget(
      _withTheme(
        const LdMarkdown(
          data:
              'See the long note.[^bignote]\n'
              '\n'
              '[^bignote]: First paragraph of the note.\n'
              '\n'
              '    Second paragraph stays in the footnote.\n'
              '\n'
              '    `{ my code }`\n',
        ),
      ),
    );

    expect(find.textContaining('See the long note'), findsOneWidget);
    expect(find.textContaining('First paragraph of the note'), findsNothing);

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('First paragraph of the note'), findsOneWidget);
    expect(
      find.textContaining('Second paragraph stays in the footnote'),
      findsOneWidget,
    );
    expect(find.textContaining('{ my code }'), findsOneWidget);
    expect(find.text('section'), findsNothing);
  });

  testWidgets('does not forward footnote fragment hrefs to onLinkTap', (
    tester,
  ) async {
    final tapped = <String>[];
    await tester.pumpWidget(
      _withTheme(
        LdMarkdown(
          data: 'A footnote.[^1]\n\n[^1]: The note.\n',
          onLinkTap: (url, title) => tapped.add(url),
        ),
      ),
    );

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(find.textContaining('The note'), findsOneWidget);
    expect(tapped, isEmpty);
  });
}
