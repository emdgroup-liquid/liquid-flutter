# liquid_flutter_ai

Presentational AI conversation UI for
[Liquid Flutter](https://pub.dev/packages/liquid_flutter): message list, compose
bar, bubbles, tool/approval/reasoning cards, activity grouping, send-fly,
approval allow-rules, GenUI surfaces, and usage/cost UI.

Part of the [liquid-flutter](https://github.com/emdgroup-liquid/liquid-flutter)
monorepo.

Pure-Dart allow-rule and GenUI schema helpers live in
[liquid_flutter_ai_shared](https://pub.dev/packages/liquid_flutter_ai_shared)
(re-exported from this package).

## Features

- **`LdConversation`** — reversed conversation list with optional activity
  grouping and approval wiring.
- **`LdComposeBar`** — bottom compose bar (text, attachments, optional voice).
- **Bubbles** — user, agent Markdown, tool call, approval, reasoning, system
  prompt, and activity groups.
- **`LdSendFlyScope`** — animated send-from-compose-to-list transition.
- **Allow-rules** — picker/editor UI on top of `liquid_flutter_ai_shared`.
- **GenUI** — Liquid catalog helpers and surface widgets (`buildLdCatalog`,
  surface manager / strip).
- **Usage** — context usage indicator and cost modal helpers.

## Installation

```bash
flutter pub add liquid_flutter_ai
```

Requires [liquid_flutter](https://pub.dev/packages/liquid_flutter) and
[liquid_flutter_md](https://pub.dev/packages/liquid_flutter_md).

## Usage

```dart
import 'package:liquid_flutter_ai/liquid_flutter_ai.dart';

// Conversation list (newest near the compose bar)
LdConversation(
  items: items,
  approval: LdConversationApprovalActions(
    onApprove: (item) { /* ... */ },
    onDeny: (item) { /* ... */ },
  ),
);

// Compose bar wrapping page content
LdComposeBar(
  onSend: (text) { /* enqueue user message */ },
  child: yourScaffoldBody,
);
```

Wrap the tree with `LdThemeProvider` (and typically `LdScaffold` /
`LdAppBar`) so components pick up Liquid theme tokens.

Agent runtime, networking, and tool execution are **not** included — this
package is the UI layer. Wire your host to produce `LdConversationItem`s and
handle compose / approval callbacks.

## License

Apache-2.0. See [LICENSE](LICENSE).
