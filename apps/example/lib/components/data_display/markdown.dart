import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_md/markdown_widget.dart';

const _defaultDemoMarkdown = r'''# Heading 1

## Heading 2

### Heading 3

A paragraph with **bold** and *italic* text.

- Unordered item one
- Unordered item two

1. Ordered item one
2. Ordered item two

Inline `code` and a [link](https://example.com).

> A blockquote.

| Name   | Role    | Status  |
| ------ | ------- | ------- |
| Alice  | Admin   | Active  |
| Bob    | Editor  | Pending |
| Carol  | Viewer  | Active  |


```dart
void main() {
  print('Hello, world!');
}
```

---

Here's a simple footnote,[^1] and here's a longer one.[^bignote]

[^1]: This is the first footnote.

[^bignote]: Here's one with multiple paragraphs and code.

    Indent paragraphs to include them in the footnote.

    `{ my code }`

    Add as many paragraphs as you like.
''';

class MarkdownDemo extends StatefulWidget {
  const MarkdownDemo({super.key});

  @override
  State<MarkdownDemo> createState() => _MarkdownDemoState();
}

class _MarkdownDemoState extends State<MarkdownDemo> {
  final _controller = TextEditingController(text: _defaultDemoMarkdown);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context);
    final padding = theme.pad(size: LdSize.m);

    return ComponentPage(
      path: "lib/components/data_display/markdown.dart",
      title: "LdMarkdown",
      category: "Data Display",
      demo: LdAutoSpace(
        children: [
          LdText.l("Edit markdown"),
          LdInput(controller: _controller, hint: "Enter markdown...", minLines: 6, maxLines: 12),
          LdText.l("Preview"),
          LdMarkdown(data: _controller.text, padding: padding),
          LdText.l("Tree (for debugging)"),
          LdCard(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(
                  formatMarkdownTree(_controller.text),
                  style: TextStyle(
                    fontFamily: 'NotoSansMono',
                    fontSize: theme.paragraphSize(LdSize.s),
                    color: theme.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
