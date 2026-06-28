# Coding Conventions

This document describes the coding conventions used in the liquid-flutter codebase.

## Naming Patterns

### Files

- **Dart files**: Use `snake_case.dart` for all file names
- **Generated files**: Use `.variants.g.dart` suffix for code-generated variants
- **Index/Barrel files**: Use `index.dart` for directory exports

```
lib/
  src/
    button.dart           # Component file
    button.variants.g.dart # Generated variants
    appbar/
      index.dart          # Barrel file
      appbar.dart         # Component file
```

### Functions & Methods

- **Public functions**: `PascalCase` (e.g., `buildSubmit`, `createTestListController`)
- **Private functions**: `_camelCase` with leading underscore (e.g., `_buildHint`, `_onTap`)
- **Callbacks**: Suffix with `Callback` when type name (e.g., `VoidCallback? retry`)
- **Handlers**: Suffix with `Handler` for event handlers (e.g., `onPressed`)

### Variables

- **Private variables**: `_camelCase` with leading underscore
- **Public variables**: `camelCase`
- **Constants**: `camelCase` (not UPPER_SNAKE_CASE for runtime values)
- **Boolean variables**: Use `is`, `has`, `can` prefixes when appropriate (e.g., `isLoading`, `hasError`)

### Types & Classes

- **Classes**: `LdPascalCase` prefix with `Ld` (e.g., `LdButton`, `LdTheme`, `LdException`)
- **Enums**: `LdPascalCase` (e.g., `LdButtonMode`, `LdHintType`)
- **Type aliases**: `LdPascalCase` or descriptive (e.g., `FetchListWithParameters`)
- **Generic type parameters**: `T`, `IdType`, descriptive names

### Example from source code

```dart
// button.dart
class _LdButtonWidget extends StatefulWidget {
  final Widget child;
  final FutureOr<void> Function() onPressed;
  final bool disabled;
  final LdButtonMode mode;
  final LdSize size;
}

class _LdButtonState extends State<_LdButtonWidget> {
  bool _loading = false;
  bool _failed = false;
  LdException? _error;
}
```

## Code Style Tools

### Analysis Options

The project uses `analysis_options.yaml` which extends `package:flutter_lints/flutter.yaml`:

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:

analyzer:
  exclude:
    - lib/oss_licenses.dart
    - example/build/**

formatter:
  page_width: 120
```

### Key Settings

- **Page width**: 120 characters
- **Linting**: Uses Flutter's recommended lint set
- **Excluded files**: Generated license files and build outputs

### Running Analysis

```bash
# Analyze all code
dart analyze

# Via melos
melos analyze
```

## Import Organization

Imports are organized in the following order:

1. **Dart core imports** (`dart:async`, `dart:io`, etc.)
2. **Flutter SDK imports** (`package:flutter/material.dart`)
3. **Third-party package imports** (alphabetically)
4. **Package imports** (`package:liquid_flutter/liquid_flutter.dart`)
5. **Relative imports** (for local files)

```dart
// Example from button.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'touchable/touchable_colors.dart';
import 'touchable/touchable_status.dart';

part 'button.variants.g.dart';
```

## Error Handling

### Exception Pattern

Use `LdException` and `LdLocalizedException` for renderable exceptions:

```dart
// exception.dart
class LdException extends Error {
  final bool canRetry;
  final LdHintType type;
  final dynamic exception;
  final int? attempt;
  final StackTrace? stackTrace;
}

class LdLocalizedException extends LdException {
  final String message;
  final String? moreInfo;
  final Widget Function(BuildContext context)? additionalBuilder;
  final Widget Function(BuildContext context)? additionalDetailsBuilder;
}
```

### Try-Catch with Debug Logging

```dart
try {
  res = await config.action(arg?.value);
} catch (e, s) {
  if (ldPrintDebugMessages) {
    debugPrint("An error occurred: $e \n $s");
  }
  rethrow;
}
```

### Assert Statements

Use assertions for developer-facing contracts:

```dart
assert(
  retryController == null || retry == null,
  'Cannot provide both retryController and retry. Use only one.',
);
```

## Logging Approach

### Debug Mode Printing

Use the `ldPrintDebugMessages` flag for debug output:

```dart
var ldPrintDebugMessages = kDebugMode;

// Usage
if (ldPrintDebugMessages) {
  debugPrint("Cancelling submit controller");
}
```

### When to Log

- State transitions (cancel, reset, trigger)
- Error conditions (with `kDebugMode` guard)
- Debug-only behavior

## Comment Conventions

### When to Comment

- **Public API**: Document all public classes and methods with doc comments
- **Complex logic**: Explain non-obvious algorithms or business rules
- **State machines**: Document state transitions

### Doc Comments

Use `///` for documentation comments on public APIs:

```dart
/// Renders an LdException
class LdExceptionView extends StatelessWidget {
  /// The exception to render
  final LdException exception;

  /// The controller for managing retry operations
  final LdRetryController? retryController;

  /// A callback to retry the action that caused the exception
  /// If null, the retry button will not be displayed
  final VoidCallback? retry;
}
```

### No Comments for Obvious Code

Self-documenting code doesn't need comments:

```dart
// Good
if (widget.disabled) {
  return;
}

// Bad
// Check if the widget is disabled
if (widget.disabled) {
  return;
}
```

## Function Design Guidelines

### Function Size

- Prefer small, focused functions (< 30 lines)
- Extract complex logic into named private methods
- Use helper functions for repeated patterns

### Parameter Guidelines

- **Required params first**, optional params after
- **Group related params** using anonymous structs or sub-objects
- **Use `@ContextConfigurable()`** for theme-related parameters that can be overridden via context

```dart
const _LdButtonWidget({
  required this.child,
  required this.onPressed,
  @ContextConfigurable() this.autoLoading = true,
  @ContextConfigurable() this.borderRadius,
  @ContextConfigurable() this.color,
  this.autoFocus = false,
});
```

### Return Values

- Use `Future<void>` for async operations without return values
- Use `async/await` consistently
- Return `Widget` from build methods

### Naming Conventions for Functions

| Pattern | Example | Use Case |
|---------|---------|----------|
| `build*` | `buildSubmit()` | Construct UI elements |
| `create*` | `createTestListController()` | Factory methods |
| `_on*` | `_onTap()`, `_onFocusChange()` | Event handlers |
| `get*` | `get _theme` | Getters |
| `_build*` | `_buildHint()` | Private builders |

## Module Design

### Barrel Files (index.dart)

Use `index.dart` files to export entire directories:

```dart
// appbar/index.dart
export 'appbar.dart';
export 'appbar_action.dart';
export 'appbar_system_ui.dart';
export 'appbar_action_overflow_menu.dart';
export 'bottom_bar.dart';
export 'drawer_buttons.dart';
export 'search_components.dart';
export 'search_config.dart';
export 'tab_navigation.dart';
export 'window_callbacks.dart';
```

### Main Package Export

The `liquid_flutter.dart` barrel file exports everything:

```dart
export 'src/accordion.dart';
export 'src/annotations.dart';
export 'src/appbar/index.dart';
export 'src/button.dart';
// ... all exports in alphabetical order by path
```

### Part Files

Use `part` for generated code:

```dart
part 'button.variants.g.dart';
```

### Private Implementation

Prefix internal classes with underscore:

```dart
class _LdButtonWidget extends StatefulWidget { ... }
class _LdButtonState extends State<_LdButtonWidget> { ... }
class _ButtonShape extends StatelessWidget { ... }
```

### Mixins and Extensions

- **Mixins**: For reusable stateful/stateless logic
- **Extensions**: For adding functionality to existing types

```dart
extension LdThemeExtension on BuildContext {
  LdTheme get ld {
    return LdTheme.of(this);
  }
}
```
