import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';

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
  group('LdMarkdownEditingController — flat-text invariant', () {
    Future<void> checkInvariant(
      WidgetTester tester,
      LdMarkdownEditingController ctrl,
    ) async {
      late TextSpan span;
      await tester.pumpWidget(
        _withTheme(
          Builder(builder: (context) {
            span = ctrl.buildTextSpan(
              context: context,
              style: const TextStyle(),
              withComposing: false,
            );
            return const SizedBox.shrink();
          }),
        ),
      );
      final flattened = _flattenSpan(span);
      expect(
        flattened.length,
        ctrl.text.length,
        reason:
            'Flattened span length ${flattened.length} != source length ${ctrl.text.length}.\n'
            'Source: ${ctrl.text.replaceAll('\n', '⏎')}\n'
            'Flat:   ${flattened.replaceAll('\n', '⏎')}',
      );
    }

    testWidgets('invariant holds for heading + paragraph + bold', (tester) async {
      final ctrl = LdMarkdownEditingController(
        text: '# Heading\n\nA paragraph with **bold** text.\n',
      );
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
    });

    testWidgets('invariant holds for empty string', (tester) async {
      final ctrl = LdMarkdownEditingController(text: '');
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
    });

    testWidgets('invariant holds for hr', (tester) async {
      final ctrl = LdMarkdownEditingController(text: 'Above\n\n---\n\nBelow\n');
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
    });

    testWidgets('invariant holds for inline code', (tester) async {
      final ctrl = LdMarkdownEditingController(text: 'Use `foo()` here\n');
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
    });

    testWidgets('invariant holds for italic', (tester) async {
      final ctrl = LdMarkdownEditingController(text: 'Hello *world* end\n');
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
    });

    testWidgets('invariant holds for simple table', (tester) async {
      const src = '| Name | Age |\n| --- | --- |\n| Alice | 30 |\n| Bob | 25 |\n';
      final ctrl = LdMarkdownEditingController(text: src);
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
    });

    testWidgets('invariant holds for table row with inline formatting', (tester) async {
      const src = '| **Bold** | *Italic* | `Code` |\n| --- | --- | --- |\n';
      final ctrl = LdMarkdownEditingController(text: src);
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
    });

    testWidgets('invariant holds for table separator row', (tester) async {
      const src = '| :--- | ---: | :---: |\n';
      final ctrl = LdMarkdownEditingController(text: src);
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
    });

    testWidgets('invariant holds for table mixed with other elements', (tester) async {
      const src = '# Heading\n\n| Col1 | Col2 |\n| --- | --- |\n| val | val |\n\nParagraph\n';
      final ctrl = LdMarkdownEditingController(text: src);
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
    });

    testWidgets('invariant holds for footnote ref', (tester) async {
      final ctrl = LdMarkdownEditingController(
        text: 'See this.[^1]\n',
      );
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
    });

    testWidgets('invariant holds for footnote definition', (tester) async {
      final ctrl = LdMarkdownEditingController(
        text: 'See this.[^1]\n\n[^1]: The footnote body.\n',
      );
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
    });

    testWidgets('invariant holds for indented footnote continuation', (
      tester,
    ) async {
      final ctrl = LdMarkdownEditingController(
        text:
            'See this.[^bignote]\n'
            '\n'
            '[^bignote]: First paragraph.\n'
            '\n'
            '    Second paragraph stays in the footnote.\n'
            '\n'
            '    `{ my code }`\n',
      );
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
    });

    testWidgets('enumerates matching footnotes as widget spans off-focus', (
      tester,
    ) async {
      final ctrl = LdMarkdownEditingController(
        text:
            'Here is a simple footnote,[^1] and a named one.[^bignote]\n'
            '\n'
            '[^1]: First footnote body.\n'
            '\n'
            '[^bignote]: Named footnote body.\n',
      );
      addTearDown(ctrl.dispose);
      ctrl.isEditing = false;

      late TextSpan span;
      await tester.pumpWidget(
        _withTheme(
          Builder(
            builder: (context) {
              span = ctrl.buildTextSpan(
                context: context,
                style: const TextStyle(),
                withComposing: false,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(_flattenSpan(span).length, ctrl.text.length);
      // Two inline refs + two definition markers.
      expect(_widgetSpanCount(span), 4);
    });
  });

  group('LdMarkdownEditor widget', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(
        _withTheme(
          LdMarkdownEditor(
            initialValue: '# Hello\n\nWorld',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('onChanged is called when text changes', (tester) async {
      String? changed;
      await tester.pumpWidget(
        _withTheme(
          LdMarkdownEditor(
            initialValue: '',
            onChanged: (v) => changed = v,
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), 'hello');
      expect(changed, 'hello');
    });

    testWidgets('controller is used when provided', (tester) async {
      final ctrl = LdMarkdownEditingController(text: 'initial');
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _withTheme(LdMarkdownEditor(controller: ctrl)),
      );

      expect(ctrl.text, 'initial');
    });
  });

  group('LdMarkdownEditingController — list continuation (value setter intercept)', () {
    void insertNewlineAtCursor(LdMarkdownEditingController ctrl) {
      final pos = ctrl.selection.baseOffset;
      final text = ctrl.text;
      ctrl.value = TextEditingValue(
        text: '${text.substring(0, pos)}\n${text.substring(pos)}',
        selection: TextSelection.collapsed(offset: pos + 1),
      );
    }

    test('continues unordered list with -', () {
      final ctrl = LdMarkdownEditingController(text: '- item');
      addTearDown(ctrl.dispose);
      ctrl.selection = const TextSelection.collapsed(offset: 6);

      insertNewlineAtCursor(ctrl);

      expect(ctrl.text, '- item\n- ');
    });

    test('removes empty unordered list item', () {
      final ctrl = LdMarkdownEditingController(text: '- ');
      addTearDown(ctrl.dispose);
      ctrl.selection = const TextSelection.collapsed(offset: 2);

      insertNewlineAtCursor(ctrl);

      expect(ctrl.text, '');
    });

    test('continues unordered list with *', () {
      final ctrl = LdMarkdownEditingController(text: '* item');
      addTearDown(ctrl.dispose);
      ctrl.selection = const TextSelection.collapsed(offset: 6);

      insertNewlineAtCursor(ctrl);

      expect(ctrl.text, '* item\n* ');
    });

    test('continues ordered list', () {
      final ctrl = LdMarkdownEditingController(text: '1. item');
      addTearDown(ctrl.dispose);
      ctrl.selection = const TextSelection.collapsed(offset: 7);

      insertNewlineAtCursor(ctrl);

      expect(ctrl.text, '1. item\n2. ');
    });

    test('removes empty ordered list item', () {
      final ctrl = LdMarkdownEditingController(text: '1. ');
      addTearDown(ctrl.dispose);
      ctrl.selection = const TextSelection.collapsed(offset: 3);

      insertNewlineAtCursor(ctrl);

      expect(ctrl.text, '');
    });

    test('continues blockquote', () {
      final ctrl = LdMarkdownEditingController(text: '> quote');
      addTearDown(ctrl.dispose);
      ctrl.selection = const TextSelection.collapsed(offset: 7);

      insertNewlineAtCursor(ctrl);

      expect(ctrl.text, '> quote\n> ');
    });

    test('removes empty blockquote', () {
      final ctrl = LdMarkdownEditingController(text: '> ');
      addTearDown(ctrl.dispose);
      ctrl.selection = const TextSelection.collapsed(offset: 2);

      insertNewlineAtCursor(ctrl);

      expect(ctrl.text, '');
    });

    test('does not continue horizontal rule', () {
      final ctrl = LdMarkdownEditingController(text: '---');
      addTearDown(ctrl.dispose);
      ctrl.selection = const TextSelection.collapsed(offset: 3);

      insertNewlineAtCursor(ctrl);

      expect(ctrl.text, '---\n');
    });

    test('continues indented list item', () {
      final ctrl = LdMarkdownEditingController(text: '  - item');
      addTearDown(ctrl.dispose);
      ctrl.selection = const TextSelection.collapsed(offset: 8);

      insertNewlineAtCursor(ctrl);

      expect(ctrl.text, '  - item\n  - ');
    });

    test('non-list newline is not modified', () {
      final ctrl = LdMarkdownEditingController(text: 'hello world');
      addTearDown(ctrl.dispose);
      ctrl.selection = const TextSelection.collapsed(offset: 11);

      insertNewlineAtCursor(ctrl);

      expect(ctrl.text, 'hello world\n');
    });
  });
}

String _flattenSpan(InlineSpan span) {
  if (span is TextSpan) {
    final buf = StringBuffer();
    if (span.text != null) buf.write(span.text);
    if (span.children != null) {
      for (final child in span.children!) {
        buf.write(_flattenSpan(child));
      }
    }
    return buf.toString();
  }
  if (span is WidgetSpan) {
    return '\uFFFC';
  }
  return '';
}

int _widgetSpanCount(InlineSpan span) {
  if (span is WidgetSpan) return 1;
  if (span is TextSpan) {
    var count = 0;
    for (final child in span.children ?? const <InlineSpan>[]) {
      count += _widgetSpanCount(child);
    }
    return count;
  }
  return 0;
}