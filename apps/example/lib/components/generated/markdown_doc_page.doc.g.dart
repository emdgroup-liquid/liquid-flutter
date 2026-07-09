// GENERATED FILE — do not edit manually.
// Regenerate with: melos run generate_docs
//
// Source: LdMarkdown dartdoc comments.

import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/demo_registry.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';

class LdMarkdownDocPage extends StatelessWidget {
  const LdMarkdownDocPage({super.key});

  static const List<String> _apiComponents = ['LdMarkdown', 'LdMarkdownEditor', 'LdMarkdownEditingController'];

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: 'lib/markdown_widget.dart',
      title: 'LdMarkdown',
      category: 'Data Display',
      apiComponents: _apiComponents,
      demo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LdMarkdown(
            data: r'''
Renders a markdown string using native Liquid Flutter components.

The parser uses the GitHub Web extension set, supporting tables, fenced code blocks, strikethrough, task lists, and GitHub-flavored alerts (`> [!NOTE]`, `> [!WARNING]`, etc.).

The parsed AST is cached: re-rendering with the same `data` string does not re-parse.

## Basic usage

```dart
LdMarkdown(
  data: '# Hello\n\nThis is **bold** and *italic*.',
)
```

## Link handling

Supply `onLinkTap` to intercept link taps; the widget does not launch URLs automatically.

```dart
LdMarkdown(
  data: '[Visit us](https://example.com)',
  onLinkTap: (url, title) => launchUrl(Uri.parse(url)),
)
```

## Live demo
''',
          ),
          demoRegistry['LdMarkdownLive']!(),
        ],
      ),
    );
  }
}
