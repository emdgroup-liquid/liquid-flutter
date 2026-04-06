# Structure

**Generated:** 2026-04-05
**Provider:** gh

## Directory Layout Overview

```
liquid-flutter/                    # Melos monorepo root
├── apps/                           # Application entry points
│   └── example/                    # Example/demo Flutter app
├── packages/                        # Shared packages
│   ├── liquid_flutter/             # Main component library
│   ├── liquid_flutter_emd_theme/   # EMD-specific theme extension
│   ├── liquid_flutter_test_utils/  # Testing utilities
│   ├── liquid_flutter_window_utils/# Window/screen utilities
│   └── liquid_generators/          # Code generators
├── generators/                      # (build tooling)
└── lib/                            # Root-level entry (monorepo config)
```

## Purpose of Each Major Directory

### `/packages/liquid_flutter/` - Main Component Library

**Purpose**: Flutter component library providing UI primitives

**Key Structure:**
```
lib/
├── liquid_flutter.dart              # Main barrel export
├── liquid_flutter_devtools.dart    # DevTools integration
├── fonts/                          # Bundled font files
├── oss_licenses.dart               # License tracking
└── src/
    ├── [component].dart             # Individual components
    ├── [component].variants.g.dart  # Generated variant configs
    ├── annotations.dart            # @Variants, @ContextConfigurable
    ├── tokens.dart                 # LdSize, shadows, spacers
    ├── theme/                      # LdTheme, theming
    ├── color/                      # LdColor, palettes
    ├── exception/                  # Exception handling
    ├── monkey/                     # Testing/scaffolding patterns
    ├── l10n/                       # Localization (ARB + generated)
    └── submit/                     # Form submission system
```

### `/packages/liquid_flutter_emd_theme/` - Theme Extension

**Purpose**: EMD-specific theme customization extending base `LdTheme`

```
lib/
├── liquid_flutter_emd_theme.dart    # Barrel export
├── fonts/                          # EMD-specific fonts
└── src/
    └── colors.dart                 # EMD color palette
```

### `/packages/liquid_flutter_test_utils/` - Testing Framework

**Purpose**: Testing utilities including golden testing and frame rendering

```
lib/
├── ld_frame.dart                   # Screenshot frame renderer
├── ld_frame_options.dart           # Frame configuration
├── golden_utils.dart               # Golden file utilities
├── multi_golden_test.dart          # Multi-device golden testing
├── widget_tree_test.dart           # Widget tree comparison
├── system_ui/                      # Device frame definitions
│   ├── iphone_16_pro.dart
│   ├── ipad_11_pro.dart
│   └── fairphone_6.dart
└── diff_util.dart                  # Visual diff utilities
```

### `/packages/liquid_flutter_window_utils/` - Window Management

**Purpose**: Platform window/screen utilities (method channels)

```
lib/
├── liquid_flutter_window_utils.dart          # Barrel export
├── liquid_flutter_window_utils_method_channel.dart
├── liquid_flutter_window_utils_platform_interface.dart
├── messages.g.dart                           # Generated message codec
└── screen_radius_defaults.dart              # Platform-specific radii
```

### `/packages/liquid_generators/` - Code Generation

**Purpose**: Build-time code generation for variant system

```
lib/
└── variant_generator.dart          # Builds Config/ConfigProvider classes
```

### `/apps/example/` - Demo Application

**Purpose**: Reference implementation and showcase

```
lib/
├── main.dart                       # App entry point
├── home.dart                       # Main demo screen
├── router.dart                     # Navigation
├── chemical_screen.dart            # Example screen
├── demos/                          # Component demonstrations
├── components/                     # Demo-specific components
└── patterns/                       # Layout patterns
```

## Key File Locations

### Entry Points

| Purpose | Path |
|---------|------|
| Main library | `packages/liquid_flutter/lib/liquid_flutter.dart` |
| Example app | `apps/example/lib/main.dart` |
| Monorepo config | `pubspec.yaml` |
| Melos config | `pubspec.yaml` (workspace) |

### Configuration

| Purpose | Path |
|---------|------|
| Main analysis | `analysis_options.yaml` |
| Package analysis | `packages/liquid_flutter/analysis_options.yaml` |
| Build config | `packages/liquid_flutter/build.yaml` |
| Generator config | `packages/liquid_generators/build.yaml` |
| L10n config | `packages/liquid_flutter/l10n.yaml` |

### Core Logic

| Purpose | Path |
|---------|------|
| Theme system | `packages/liquid_flutter/lib/src/theme/theme.dart` |
| Tokens/Constants | `packages/liquid_flutter/lib/src/tokens.dart` |
| Annotations | `packages/liquid_flutter/lib/src/annotations.dart` |
| Variant generator | `packages/liquid_generators/lib/variant_generator.dart` |
| Exception model | `packages/liquid_flutter/lib/src/exception/model/exception.dart` |
| Repository | `packages/liquid_flutter/lib/src/monkey/data/repository.dart` |

### Tests

| Purpose | Path |
|---------|------|
| Main package tests | `packages/liquid_flutter/test/` |
| Golden tests | `packages/liquid_flutter/test/*_golden_test.dart` |
| Monkey tests | `packages/liquid_flutter/test/monkey/` |
| Test utilities | `packages/liquid_flutter_test_utils/lib/` |

### Generated Files

| Purpose | Pattern |
|---------|---------|
| Variant configs | `*.variants.g.dart` |
| L10n | `src/l10n/generated/liquid_localizations*.dart` |
| Window messages | `packages/liquid_flutter_window_utils/lib/messages.g.dart` |

## Naming Conventions Observed

### Dart Files
- **Components**: `lower_snake_case.dart` (e.g., `button.dart`, `context_menu.dart`)
- **Directories**: `lower_snake_case/` (e.g., `appbar/`, `exception/`)
- **Generated**: `*.g.dart` or `*.variants.g.dart`

### Classes
- **Components**: `Ld{CamelCase}Widget` (private) with `Ld{CamelCase}` public (e.g., `LdButton`)
- **Config classes**: `{Component}Config` (e.g., `LdButtonConfig`)
- **Config providers**: `{Component}ConfigProvider` (e.g., `LdButtonConfigProvider`)
- **Controllers**: `Ld{Component}Controller` (e.g., `LdSubmitController`)
- **Theme**: `Ld{CamelCase}` for everything theme-related

### Enums
- `Ld{CamelCase}` prefix (e.g., `LdButtonMode`, `LdSize`, `LdPlatform`)

### Variables/Functions
- `lowerCamelCase` for variables and functions
- `lower_snake_case` for file names

### Exports
- Barrel files export from `src/` subdirectories
- Public API uses `ld` prefix for library-level variables

## Guidance on Where to Add New Code

### Adding a New Component

1. Create `packages/liquid_flutter/lib/src/{component}.dart`
2. Use `@Variants` annotation for variant support
3. Use `@ContextConfigurable()` for themeable properties
4. Export from `packages/liquid_flutter/lib/liquid_flutter.dart`
5. Create `packages/liquid_flutter/test/{component}_test.dart`

**Template:**
```dart
import 'package:liquid_flutter/liquid_flutter.dart';

part '{component}.variants.g.dart';

@Variants([...])
class _LdComponentWidget extends StatefulWidget {
  @ContextConfigurable() LdSize size = LdSize.m;
}

class LdComponent extends StatelessWidget {
  // Implementation
}
```

### Adding a New Theme Token

1. Add to `packages/liquid_flutter/lib/src/theme/theme.dart` (for runtime)
2. Add to `packages/liquid_flutter/lib/src/tokens.dart` (for constants)

### Adding a New Color Palette

1. Create or extend in `packages/liquid_flutter/lib/src/color/`
2. Export from `packages/liquid_flutter/lib/src/color/color.dart`

### Adding Test Coverage

1. Create test in `packages/liquid_flutter/test/`
2. Follow naming: `{component}_test.dart` or `{component}_golden_test.dart`
3. Use `LdThemeProvider` wrapper for theme-dependent tests

## Special Directories

### `/generated/` (committed)
- `packages/liquid_flutter/lib/src/l10n/generated/` - Generated localization files
- Committed to repo (not regenerated on build)

### `/.gitignore` patterns
- `build/` directories - Build artifacts
- `.dart_tool/` - Dart tooling cache
- `*.g.dart` except committed variants - Most generated files excluded

### `/packages/liquid_flutter/assets/`
- Static assets (icons, images bundled with library)

### `/packages/liquid_flutter/fonts/`
- Custom font files bundled with the library

### `/packages/liquid_flutter/api_guard/`
- API compatibility tracking
