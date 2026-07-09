// GENERATED FILE — do not edit manually.
// Regenerate with: melos run generate_docs
//
// Source: _LdHintWidget dartdoc comments.

import 'package:flutter/material.dart';
import 'package:liquid/components/component_page.dart';
import 'package:liquid/components/demo_registry.dart';
import 'package:liquid_flutter_md/liquid_flutter_md.dart';

class LdHintDocPage extends StatelessWidget {
  const LdHintDocPage({super.key});

  static const List<String> _apiComponents = ['LdHint', 'LdHintType'];

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      path: 'lib/src/hint.dart',
      title: 'LdHint',
      category: 'Feedback',
      apiComponents: _apiComponents,
      demo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LdMarkdown(
            data: r'''
A status indicator paired with an optional text label.

`LdHint` combines an `LdIndicator` icon with a text child to communicate the state of an operation or piece of content. The color and icon are driven by the `type` parameter.

## Basic usage

```dart
LdHint(
  type: LdHintType.success,
  child: const Text('Saved successfully'),
)
```

## All types
''',
          ),
          demoRegistry['LdHintVariants']!(),
          LdMarkdown(
            data: r'''
## With background

Set `withBackground` to `true` to add a tinted background and border, useful for drawing attention to the hint inside a form or card.
''',
          ),
          demoRegistry['LdHintWithBackground']!(),
        ],
      ),
    );
  }
}
