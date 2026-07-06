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
    // The invariant: the *length* of the flattened span equals the source
    // length.  WidgetSpans contribute U+FFFC (one char) replacing exactly one
    // source char, so lengths must match even if byte content differs.
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

    testWidgets('invariant holds for focused table row', (tester) async {
      // Simulate cursor on the first row of a table.
      final ctrl = LdMarkdownEditingController(text: '| A | B |\n| --- | --- |\n');
      ctrl.selection = const TextSelection.collapsed(offset: 3); // inside first row
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
    });

    testWidgets('invariant holds for table mixed with other elements', (tester) async {
      const src = '# Heading\n\n| Col1 | Col2 |\n| --- | --- |\n| val | val |\n\nParagraph\n';
      final ctrl = LdMarkdownEditingController(text: src);
      addTearDown(ctrl.dispose);
      await checkInvariant(tester, ctrl);
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
      await tester.enterText(
        find.byType(TextField, skipOffstage: false),
        'hello',
      );
      expect(changed, isNotNull);
    });

    testWidgets('controller is used when provided', (tester) async {
      final ctrl = LdMarkdownEditingController(text: 'initial');
      addTearDown(ctrl.dispose);

      await tester.pumpWidget(
        _withTheme(LdMarkdownEditor(controller: ctrl)),
      );

      expect(find.text('initial'), findsOneWidget);
    });
  });
}

/// Recursively flattens a [TextSpan] tree into a plain string.
/// [WidgetSpan]s contribute the U+FFFC object replacement character.
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
    // WidgetSpans are represented as U+FFFC in the text buffer.
    return '\uFFFC';
  }
  return '';
}
