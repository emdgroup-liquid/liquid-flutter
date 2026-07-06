# liquid_flutter_md

Markdown rendering and editing for [Liquid Flutter](https://pub.dev/packages/liquid_flutter).

## Features

- **`LdMarkdown`** — renders a Markdown string as styled Flutter widgets, following the active `LdTheme`.
- **`LdMarkdownEditor`** — a WYSIWYG-style text editor with Markdown preview and a `MarkdownEditingController`.

## Usage

```dart
import 'package:liquid_flutter_md/liquid_flutter_md.dart';

// Render Markdown
LdMarkdown(data: '# Hello\nThis is **bold** text.');

// Edit Markdown
final controller = MarkdownEditingController();
LdMarkdownEditor(controller: controller);
```

## Third-party code

`lib/src/markdown/` contains a vendored, lightly modified copy of the
[`markdown`](https://pub.dev/packages/markdown) Dart package at **version 7.3.1**
(Copyright 2012, the Dart project authors, BSD-3-Clause).  
The full BSD license text is reproduced in the [LICENSE](LICENSE) file under
"Third-party notices".
