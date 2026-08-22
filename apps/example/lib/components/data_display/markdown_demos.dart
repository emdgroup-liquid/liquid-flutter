import 'package:flutter/material.dart';
import 'package:liquid/components/component_well/component_well.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';

const _liveMarkdown = r'''# Heading 1

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

class LdMarkdownLiveDemo extends StatefulWidget {
  const LdMarkdownLiveDemo({super.key});

  @override
  State<LdMarkdownLiveDemo> createState() => _LdMarkdownLiveDemoState();
}

class _LdMarkdownLiveDemoState extends State<LdMarkdownLiveDemo> {
  final _controller = TextEditingController(text: _liveMarkdown);

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
    return ComponentWell(
      padding: EdgeInsets.zero,
      child: LdAutoSpace(
        children: [
          Padding(
            padding: theme.pad(),
            child: LdInput(
              controller: _controller,
              hint: 'Enter markdown…',
              minLines: 6,
              maxLines: 12,
            ),
          ),
          LdDivider(),
          Padding(
            padding: theme.pad(),
            child: LdMarkdown(data: _controller.text),
          ),
        ],
      ),
    );
  }
}
