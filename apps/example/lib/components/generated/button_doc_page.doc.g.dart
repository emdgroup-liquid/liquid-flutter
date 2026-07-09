// GENERATED FILE — do not edit manually.
// Regenerate with: melos run generate_docs
//
// Source: _LdButtonWidget dartdoc comments.

import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/demo_registry.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';

class LdButtonDocPage extends StatelessWidget {
  const LdButtonDocPage({super.key});

  static const List<String> _apiComponents = ['LdButton', 'LdButtonGhost', 'LdButtonMode', 'LdButtonConfig', 'LdButtonConfigProvider'];

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: 'lib/src/button.dart',
      title: 'LdButton',
      category: 'Interaction',
      apiComponents: _apiComponents,
      demo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LdMarkdown(
            data: r'''
A pressable button with automatic loading state and error handling.

`LdButton` manages its own loading and error states when `autoLoading` is `true` (the default). If `onPressed` throws, the button briefly shows an error indication before resetting.

## Basic usage

```dart
LdButton(
  onPressed: () async {
    await saveData();
  },
  child: const Text('Save'),
)
```

## Modes

Control the visual style with `mode` (`LdButtonMode`). Convenience constructors `LdButton.ghost`, `LdButton.outline`, and `LdButton.vague` are available as shorthand.

## Interactive playground
''',
          ),
          demoRegistry['LdButtonPlayground']!(),
          LdMarkdown(
            data: r'''
## Leading and trailing icons

Pass an icon to `leading` or `trailing`. Do not set an explicit `size` on the icon — the button derives the correct size from its own `size` param.
''',
          ),
          demoRegistry['LdButtonLeadingTrailing']!(),
          LdMarkdown(
            data: r'''
## Disabled
''',
          ),
          demoRegistry['LdButtonDisabled']!(),
          LdMarkdown(
            data: r'''
## Circular / icon-only

Passing an `Icon` as `child` automatically renders a circular button. Set `circular` explicitly to override this behaviour.
''',
          ),
          demoRegistry['LdButtonCircular']!(),
          LdMarkdown(
            data: r'''
## Full width
''',
          ),
          demoRegistry['LdButtonFullWidth']!(),
          LdMarkdown(
            data: r'''
## Error state

When `onPressed` throws, the button automatically shows an error state. Throw an `LdLocalizedException` to surface a human-readable message.
''',
          ),
          demoRegistry['LdButtonError']!(),
          LdMarkdown(
            data: r'''
## Context configuration

Use `LdButtonConfigProvider` to apply default `LdButtonConfig` values to all buttons within a subtree — useful for toolbars and button groups.
''',
          ),
          demoRegistry['LdButtonConfig']!(),
        ],
      ),
    );
  }
}
