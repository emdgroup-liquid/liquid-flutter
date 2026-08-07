# liquid_flutter_md

Markdown rendering and editing for
[Liquid Flutter](https://pub.dev/packages/liquid_flutter).

Part of the [liquid-flutter](https://github.com/emdgroup-liquid/liquid-flutter)
monorepo.

## Features

- **`LdMarkdown`** — render a Markdown string as themed Flutter widgets.
- **`LdMarkdownEditor`** — live WYSIWYG-style editor with preview as you type.
- **`LdMarkdownEditingController`** — text controller that drives the editor.

## Installation

```bash
flutter pub add liquid_flutter_md
```

## Usage

```dart
import 'package:liquid_flutter_md/liquid_flutter_md.dart';

// Render Markdown
LdMarkdown(data: '# Hello\nThis is **bold** text.');

// Edit Markdown
LdMarkdownEditor(
  controller: LdMarkdownEditingController(text: '# Hello\n\nWorld'),
  onLinkTap: (url, title) {
    // open url
  },
);
```

Wrap with your app’s `LdThemeProvider` (or an existing Liquid Flutter scaffold)
so colors, type, and spacing follow the active theme.

## Third-party code

`lib/src/markdown/` contains a vendored, lightly modified copy of the
[`markdown`](https://pub.dev/packages/markdown) Dart package at **version 7.3.1**
(Copyright 2012, the Dart project authors, BSD-3-Clause).  
The full BSD license text is reproduced in the [LICENSE](LICENSE) file under
"Third-party notices".

## License

Apache-2.0. See [LICENSE](LICENSE).
