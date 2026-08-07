# liquid_flutter_ai_shared

Pure-Dart helpers shared by
[liquid_flutter_ai](https://pub.dev/packages/liquid_flutter_ai): tool allow-rules
and GenUI catalog schemas / prompt fragments. No Flutter dependency.

Part of the [liquid-flutter](https://github.com/emdgroup-liquid/liquid-flutter)
monorepo.

## Features

- **Tool allow-rules** — model, pin modes, match, merge, and JSON schema helpers
  for approving tool calls (`LdToolAllowRule`, related APIs).
- **GenUI schemas & prompts** — A2UI / Liquid GenUI schema builders and system
  prompt fragments used by the AI UI catalog.

## Installation

```bash
dart pub add liquid_flutter_ai_shared
```

Most apps should depend on `liquid_flutter_ai` instead; this package is for
hosts that need the allow-rule / schema layer without Flutter widgets.

## Usage

```dart
import 'package:liquid_flutter_ai_shared/liquid_flutter_ai_shared.dart';

// Match an incoming tool call against stored allow-rules, merge rules, or
// build GenUI schemas / prompt text for your agent host.
```

See the API docs and the `liquid_flutter_ai` package for end-to-end conversation
UI that consumes these types.

## License

Apache-2.0. See [LICENSE](LICENSE).
