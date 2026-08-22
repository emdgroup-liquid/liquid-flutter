import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter_md/src/markdown/markdown.dart' as md;

// Helper to parse and return the first top-level element.
md.Element _parseFirst(String src) {
  final doc = md.Document(extensionSet: md.ExtensionSet.gitHubWeb);
  final nodes = doc.parse(src);
  return nodes.whereType<md.Element>().first;
}

void main() {
  group('Source offsets — block syntaxes', () {
    test('ATX heading has correct sourceOffset and sourceLength', () {
      const src = '## Hello World\n';
      final el = _parseFirst(src);
      expect(el.tag, 'h2');
      expect(el.sourceOffset, 0);
      expect(el.sourceLength, src.trimRight().length);
    });

    test('paragraph has correct sourceOffset', () {
      const src = 'Hello world\n';
      final el = _parseFirst(src);
      expect(el.tag, 'p');
      expect(el.sourceOffset, 0);
    });

    test('horizontal rule has correct sourceOffset', () {
      const src = '---\n';
      final el = _parseFirst(src);
      expect(el.tag, 'hr');
      expect(el.sourceOffset, 0);
    });

    test('second heading offset is non-zero', () {
      const src = 'First paragraph\n\n## Second heading\n';
      final doc = md.Document(extensionSet: md.ExtensionSet.gitHubWeb);
      final nodes = doc.parse(src).whereType<md.Element>().toList();
      expect(nodes.length, 2);
      final h2 = nodes[1];
      expect(h2.tag, 'h2');
      // The heading starts after "First paragraph\n\n"
      expect(h2.sourceOffset, greaterThan(0));
    });

    test('fenced code block has correct sourceOffset', () {
      const src = '```dart\nfoo();\n```\n';
      final el = _parseFirst(src);
      expect(el.tag, 'pre');
      expect(el.sourceOffset, 0);
    });

    test('blockquote sourceOffset is 0', () {
      const src = '> A quoted line\n';
      final el = _parseFirst(src);
      expect(el.tag, 'blockquote');
      expect(el.sourceOffset, 0);
    });
  });

  group('Source offsets — inline syntaxes', () {
    test('bold Text node has sourceOffset inside paragraph', () {
      const src = 'Hello **world** end\n';
      final el = _parseFirst(src);
      expect(el.tag, 'p');
      final strong = el.children
          ?.whereType<md.Element>()
          .firstWhere((e) => e.tag == 'strong');
      expect(strong, isNotNull);
      // **world** starts at offset 6 in source
      expect(strong!.sourceOffset, 6);
      expect(strong.sourceLength, '**world**'.length);
    });

    test('inline code has sourceOffset', () {
      const src = 'Use `foo()` here\n';
      final el = _parseFirst(src);
      expect(el.tag, 'p');
      final code = el.children
          ?.whereType<md.Element>()
          .firstWhere((e) => e.tag == 'code');
      expect(code, isNotNull);
      // `foo()` starts at offset 4
      expect(code!.sourceOffset, 4);
      expect(code.sourceLength, '`foo()`'.length);
    });

    test('plain Text node has sourceOffset', () {
      const src = 'Hello world\n';
      final el = _parseFirst(src);
      expect(el.tag, 'p');
      final textNode = el.children?.whereType<md.Text>().first;
      expect(textNode, isNotNull);
      expect(textNode!.sourceOffset, 0);
      expect(textNode.sourceLength, 'Hello world'.length);
    });
  });

  group('Source offsets — coverage invariant', () {
    test('annotated top-level nodes are in order and non-overlapping', () {
      const src =
          '# Heading\n\nA paragraph with **bold** text.\n\n---\n\n- item one\n- item two\n';
      final doc = md.Document(extensionSet: md.ExtensionSet.gitHubWeb);
      final nodes = doc.parse(src).whereType<md.Element>().toList();

      // At least heading, paragraph, and hr should be annotated.
      final annotated = nodes
          .where((n) => n.sourceOffset != null && n.sourceLength != null)
          .toList();
      expect(annotated.length, greaterThanOrEqualTo(3));

      // Annotated nodes must be in order and non-overlapping.
      int prev = 0;
      for (final n in annotated) {
        expect(n.sourceOffset, greaterThanOrEqualTo(prev));
        prev = n.sourceOffset! + n.sourceLength!;
      }
    });
  });

  group('Footnotes', () {
    test('parse twice does not leak footnote labels', () {
      final doc = md.Document(extensionSet: md.ExtensionSet.gitHubWeb);
      doc.parse('Hi.[^1]\n\n[^1]: One.\n');
      expect(doc.footnoteLabels, isNotEmpty);
      expect(doc.footnoteReferences, isNotEmpty);

      final nodes = doc.parse('No footnotes here.\n');
      expect(doc.footnoteLabels, isEmpty);
      expect(doc.footnoteReferences, isEmpty);
      expect(
        nodes.whereType<md.Element>().any(
          (e) => e.attributes['class'] == 'footnotes',
        ),
        isFalse,
      );
    });

    test('collects referenced footnotes into a section', () {
      final doc = md.Document(extensionSet: md.ExtensionSet.gitHubWeb);
      final nodes = doc.parse(
        'A note.[^1]\n\n[^1]: The footnote body.\n',
      );
      final section = nodes.whereType<md.Element>().firstWhere(
        (e) => e.tag == 'section' && e.attributes['class'] == 'footnotes',
      );
      expect(section.textContent, contains('The footnote body'));
    });
  });
}
