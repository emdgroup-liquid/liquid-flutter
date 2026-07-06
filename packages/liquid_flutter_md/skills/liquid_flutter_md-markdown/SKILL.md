---
name: liquid_flutter_md-markdown
description: Use when rendering or editing Markdown in a Liquid Flutter application — covers LdMarkdown viewer, LdMarkdownEditor, LdMarkdownEditingController, supported syntax, and link/image customization.
---

# Liquid Flutter Markdown

`liquid_flutter_md` provides two widgets for Markdown in Liquid Flutter:

- **`LdMarkdown`** — read-only renderer that converts Markdown to native Liquid Flutter widgets.
- **`LdMarkdownEditor`** — WYSIWYG inline editor (Typora/Obsidian style) with live preview.

## Import

```dart
import 'package:liquid_flutter_md/liquid_flutter_md.dart';
```

## LdMarkdown — Read-only Renderer

Parses and renders Markdown using Liquid Flutter components (`LdCard`, `LdHint`, `LdDivider`, `LdCheckbox`, `LdAutoSpace`, etc.). Caches the parsed AST and only re-parses when `data` changes.

```dart
LdMarkdown(
  data: markdownString,
  // optional:
  shrinkWrap: true,                           // default true
  padding: EdgeInsets.all(16),                // default zero
  onLinkTap: (url, title) { /* ... */ },
  imageBuilder: (src, alt) => MyImage(src),   // return null for default
)
```

### Supported Markdown syntax

| Feature | Notes |
|---|---|
| Headings h1–h6 | — |
| Bold / italic / bold-italic / strikethrough | inline |
| Inline code | `` `code` `` |
| Fenced code blocks | ` ``` ` |
| Blockquotes | rendered as `LdCard` |
| Unordered / ordered lists | flat and nested |
| Task lists | `- [x]` rendered as `LdCheckbox` |
| Tables | rendered as `LdCard` + `Table` |
| Images | customizable via `imageBuilder` |
| Links | tappable via `onLinkTap` |
| Horizontal rules | `LdDivider` |
| GFM alerts | `[!NOTE]` / `[!TIP]` / `[!IMPORTANT]` / `[!CAUTION]` / `[!WARNING]` → `LdHint` |

## LdMarkdownEditor — WYSIWYG Editor

The line under the cursor is shown as raw Markdown source; all other lines render with inline styling. Blurs to a fully rendered `Text.rich` (allowing GFM tables to render correctly).

```dart
LdMarkdownEditor(
  controller: _controller,         // optional — owns one if omitted
  initialValue: '# Hello',         // used when controller is null
  onChanged: (value) { /* ... */ },
  onLinkTap: (url, title) { /* ... */ },
  imageBuilder: (src, alt) => MyImage(src),
  minLines: 5,
  maxLines: null,                  // null = unbounded
  hintText: 'Write something…',
  focusNode: _focusNode,
)
```

**Keyboard shortcuts**

| Shortcut | Action |
|---|---|
| `Ctrl/Cmd+B` | Toggle bold |
| `Ctrl/Cmd+I` | Toggle italic |
| `Ctrl/Cmd+E` | Toggle inline code |
| `Tab` | Indent list item |
| `Shift+Tab` | Unindent list item |
| `Enter` | Smart continuation (list / blockquote) |

## LdMarkdownEditingController

Subclass of `TextEditingController`. Use when you need programmatic access to the text or when sharing a controller between multiple widgets.

```dart
final _controller = LdMarkdownEditingController(text: '# Initial');

// Later:
_controller.text = newMarkdown;
final current = _controller.text;

// Customize link/image handling on the controller:
_controller.onLinkTap = (url, title) { /* ... */ };
_controller.imageBuilder = (src, alt) => MyImage(src);

// Dispose when done:
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

`isEditing` is managed by `LdMarkdownEditor` automatically — do not set it manually.

## Common patterns

### Editable note with save button

```dart
class NoteEditor extends StatefulWidget {
  final String initialContent;
  const NoteEditor({required this.initialContent, super.key});

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  late final LdMarkdownEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = LdMarkdownEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LdAutoSpace(
      children: [
        LdMarkdownEditor(controller: _controller),
        LdButton(
          child: const Text('Save'),
          onPressed: () => save(_controller.text),
        ),
      ],
    );
  }
}
```

### Read-only with link handling

```dart
LdMarkdown(
  data: article.body,
  onLinkTap: (url, title) => launchUrl(Uri.parse(url)),
)
```

## Notes

- The markdown parser (`lib/src/markdown/`) is an **inlined fork** of `package:markdown` v7.3.1 (BSD-3-Clause). Do not add `package:markdown` as a separate dependency — it is already bundled.
- GitHub Flavored Markdown + GitHub Web extensions are enabled by default.
