import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';
import 'package:url_launcher/url_launcher.dart';

const _defaultEditorMarkdown = r'''# Welcome to LdMarkdownEditor

A live WYSIWYG markdown editor — the line you are editing shows raw source,
all other lines render styled.

## Keyboard shortcuts

- **Cmd/Ctrl + B** — **bold**
- **Cmd/Ctrl + I** — *italic*
- **Cmd/Ctrl + E** — `inline code`
- **Tab / Shift+Tab** — indent / unindent
- **Enter** — smart list & blockquote continuation

## Try it out

- Item one
- Item two
  - Nested item

1. First
2. Second

> A blockquote that continues when you press Enter.

Inline `code` and a [link](https://flutter.dev).
''';

class MarkdownEditorDemo extends StatefulWidget {
  const MarkdownEditorDemo({super.key});

  @override
  State<MarkdownEditorDemo> createState() => _MarkdownEditorDemoState();
}

class _MarkdownEditorDemoState extends State<MarkdownEditorDemo> {
  late final LdMarkdownEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LdMarkdownEditingController(text: _defaultEditorMarkdown);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: "lib/components/form_elements/markdown_editor.dart",
      title: "LdMarkdownEditor",
      category: "Form Elements",
      apiComponents: const ["LdMarkdownEditor", "LdMarkdownEditingController"],
      demo: LdAutoSpace(
        children: [
          LdDivider(),
          LdMarkdownEditor(
            controller: _controller,
            minLines: 10,
            hintText: "Start writing markdown…",
            onLinkTap: (url, title) {
              launchUrl(Uri.parse(url));
            },
          ),
        ],
      ),
    );
  }
}
