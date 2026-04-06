# Architecture

**Generated:** 2026-04-05
**Provider:** gh

## Overall Architectural Pattern

**Layered Component Library Architecture** with Provider-based state management. This is a Flutter component library (not an application) that follows a layered architecture pattern with clear separation between:

- **UI Layer**: Flutter widgets with platform-specific adaptations
- **Theming Layer**: Centralized theming via `LdTheme` (ChangeNotifier)
- **Behavioral Layer**: State management via Provider pattern
- **Code Generation Layer**: Annotation-driven variant generation

## Key Layers and Their Responsibilities

### 1. UI Components (`packages/liquid_flutter/lib/src/`)

Individual Flutter widgets that export through `liquid_flutter.dart`. Each component:
- Is self-contained with its own state
- Uses `LdTheme.of(context)` for styling
- Supports `LdSize` scaling system (xs, s, m, l)
- Follows `@Variants` annotation pattern for generating variant classes

**Key Directories:**
- `src/button.dart`, `src/checkbox.dart`, `src/input.dart` - Form controls
- `src/appbar/` - Navigation components
- `src/modal/`, `src/drawer/` - Overlay components
- `src/list/` - List-related components
- `src/notifications/` - Toast/notification system

### 2. Theming Layer (`packages/liquid_flutter/lib/src/theme/`)

Centralized design token management via `LdTheme` (extends `ChangeNotifier`):

```dart
// packages/liquid_flutter/lib/src/theme/theme.dart:9
class LdTheme extends ChangeNotifier {
  LdPalette _palette = shadDefault;
  LdThemeSize _defaultSize = LdThemeSize.m;
  LdSizingConfig _sizingConfig = LdSizingConfig();
  LdPlatform _platform = /* platform detection */;
}
```

Theme access pattern:
```dart
// Usage in any widget
LdTheme theme = Provider.of<LdTheme>(context, listen: true);
// or
LdTheme theme = LdTheme.of(context);
```

### 3. State Management Layer

**Provider Pattern** using `package:provider`:

- **ChangeNotifier subclasses** for local state:
  - `LdSubmitController` (`src/submit/model/submit_controller.dart`)
  - `LdNotificationsController` (`src/notifications/notifications_controller.dart`)
  - `LdMonkeyShellState` (`src/monkey/monkey_shell_state.dart`)
  - `LdPaginator` (`src/list/list_paginator.dart`)

- **Repository Pattern** for data:
  - `LdRepository<T extends Identifiable<IdType>, IdType>` (`src/monkey/data/repository.dart`)
  - Handles fetching, filtering, sorting, CRUD operations

### 4. Exception Handling Layer (`packages/liquid_flutter/lib/src/exception/`)

Structured exception system:

```dart
// src/exception/model/exception.dart:8
class LdException extends Error {
  final bool canRetry;
  final LdHintType type;
  final dynamic exception;
  final StackTrace? stackTrace;
}

// src/exception/model/exception.dart:76
class LdLocalizedException extends LdException {
  final String message;
  final String? moreInfo;
  final Widget Function(BuildContext context)? additionalBuilder;
}
```

Exception display components:
- `LdExceptionDialog` - Modal dialog for exceptions
- `LdExceptionView` - Inline exception display
- `LdRetryIndicator` - Retry UI with configuration

### 5. Code Generation Layer (`packages/liquid_generators/`)

Annotation-driven code generation for component variants:

```dart
// src/annotations.dart
class Variants {
  final List<Variant> variants;
  const Variants(this.variants);
}

class Variant {
  final String name;
  final Map<String, String> defaults;
  const Variant(this.name, {required this.defaults});
}

class ContextConfigurable {
  const ContextConfigurable();
}
```

Generator (`packages/liquid_generators/lib/variant_generator.dart`) creates:
- `*Config` classes (e.g., `LdButtonConfig`)
- `*ConfigProvider` widgets for context-based configuration
- Convenience constructors for variants

Example usage:
```dart
// src/button.dart
@Variants([
  Variant('ghost', defaults: {'mode': 'LdButtonMode.ghost'}),
  Variant('filled', defaults: {'mode': 'LdButtonMode.filled'}),
])
class _LdButtonWidget extends StatefulWidget {
  @ContextConfigurable() LdButtonMode mode = LdButtonMode.filled;
}
```

## Data Flow Patterns

### 1. Widget Construction Flow

```
Component (e.g., LdButton)
  └── Wraps content with LdThemeProvider
  └── May inject LdButtonConfigProvider for variant defaults
  └── Resolves theme via LdTheme.of(context)
  └── Renders with platform-specific adaptations
```

### 2. Form/Submit Flow

```
LdForm
  └── Collects LdFormItem fields
  └── LdButton triggers onSubmit callback
  └── LdSubmitController manages async state
  └── LdSubmit displays loading/error/success states
```

### 3. Exception Flow

```
try/catch → LdException → LdLocalizedException → ExceptionView/ExceptionDialog
                                    ↓
                          LdExceptionLocalizerMapper (context provider)
```

### 4. Monkey (Testing) Data Flow

```
LdMonkeyShell
  └── LdMonkeyShellState (ChangeNotifier)
  └── LdRepository (extends LdPaginator)
       └── fetchListWithParameters (pagination, filtering, sorting)
       └── CRUD operations on individual items
  └── LdMonkeySelection (selection state)
```

## Key Abstractions and Examples

### Identifiable Pattern

```dart
// Used throughout monkey for type-safe ID handling
class Identifiable<IdType> {
  IdType get id;
}
```

### Repository Pattern

```dart
// packages/liquid_flutter/lib/src/monkey/data/repository.dart:16
class LdRepository<T extends Identifiable<IdType>, IdType> extends LdPaginator<T, IdType> {
  final FetchListWithParameters<T, IdType> _fetchListWithParameters;
  Future<T> Function(IdType id) _getById;
  // ... CRUD operations
}
```

### Config Provider Pattern

```dart
// Generated by variant_generator.dart
class LdButtonConfigProvider extends StatelessWidget {
  final LdButtonConfig config;
  final Widget child;
  // Merges with parent config, provides to descendants
}
```

### LdSize Scaling

```dart
// packages/liquid_flutter/lib/src/tokens.dart:6
enum LdSize { xs, s, m, l }

extension Modifier on LdSize {
  LdSize adjust(int steps) { ... }
  LdSize clamp(LdSize min, LdSize max) { ... }
}
```

## Entry Points

### Main Package Entry
```
packages/liquid_flutter/lib/liquid_flutter.dart  # Barrel export
```

### Example Application
```
apps/example/lib/main.dart  # Flutter app entry point
```

### Test Entry
```
packages/liquid_flutter/test/  # Test directory with *_test.dart files
```

### Code Generation Entry
```
packages/liquid_flutter/build.yaml  # Enables variant_generator
packages/liquid_generators/lib/variant_generator.dart  # Generator implementation
```

## Error Handling Strategy

1. **Structured Exceptions**: `LdException` and `LdLocalizedException` classes provide typed exceptions with retry capability
2. **Context-Based Mapping**: `LdExceptionLocalizerMapper` (Provider) localizes exceptions
3. **UI Presentation**: `LdExceptionDialog`, `LdExceptionView`, `LdRetryIndicator` render exceptions
4. **Async State**: `LdSubmitController` handles async operation states (loading, error, success)

## Cross-Cutting Concerns

### Theming
- Centralized in `LdTheme` (ChangeNotifier)
- Design tokens via `LdSizingConfig`, `LdPalette`
- Platform detection via `LdPlatform` enum

### Internationalization
- ARB files in `packages/liquid_flutter/lib/src/l10n/`
- Generated localizations via `flutter_localizations`
- Access via `LiquidLocalizations.of(context)`

### Logging/Debug
```dart
// liquid_flutter.dart:145
var ldPrintDebugMessages = kDebugMode;
```

### Animation Control
```dart
// liquid_flutter.dart:140
var ldDisableAnimations = false;  // For golden tests
```

### Font Management
```dart
// liquid_flutter.dart:133
var ldIncludeFontPackage = true;  // Prefix fonts with package name
```

### Provider Composition
- Heavy use of `MultiProvider`, `ListenableProvider`, `ChangeNotifierProvider`
- Context extension methods for provider access
