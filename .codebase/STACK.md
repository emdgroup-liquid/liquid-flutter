# Technology Stack

## Languages and Versions

- **Dart**: `>=3.5.0 <4.0.0` (workspace root in `pubspec.yaml`)
- **Flutter**: Stable channel, version `3.38.8` (CI in `.github/workflows/pr_validation.yaml`)

## Runtime Environment and Package Manager

- **Package Manager**: Dart's built-in Pub package manager
- **Monorepo Tool**: Melos `^7.1.0` (configured in `pubspec.yaml`)
- **Workspace Structure**: Multi-package Flutter workspace defined in root `pubspec.yaml`

## Core Frameworks and Their Purposes

| Package | Purpose | Location |
|---------|---------|----------|
| `liquid_flutter` | Main component library ("Liquid Oxygen Components") | `packages/liquid_flutter/` |
| `liquid_flutter_emd_theme` | EMD brand theme | `packages/liquid_flutter_emd_theme/` |
| `liquid_flutter_window_utils` | Native window interaction utilities | `packages/liquid_flutter_window_utils/` |
| `liquid_generators` | Code generation for liquid_flutter | `packages/liquid_generators/` |
| `liquid_flutter_test_utils` | Test utilities and golden testing | `packages/liquid_flutter_test_utils/` |
| `liquid_flutter_extension` | DevTools extension | `packages/liquid_flutter/extension/devtools/liquid_flutter_extension/` |
| `apps/example` | Example/demo application | `apps/example/` |

## Key Dependencies

### State Management & Navigation
- `provider: ^6.0.2` - State management (used extensively across codebase)
- `go_router: ^17.0.1` - Declarative routing/navigation

### UI & Animation
- `flutter_animate: ^4.1.1` - Animation library
- `lucide_icons_flutter: ^3.1.9` - Icon library
- `flutter_svg: ^2.0.10+1` - SVG rendering
- `responsive_builder: ^0.7.0` - Responsive layout
- `google_fonts: ^8.0.1` - Typography (example app)

### Utilities
- `equatable: ^2.0.7` - Value equality
- `jiffy: ^6.3.1` - Date/time manipulation
- `shared_preferences: ^2.5.3` - Local key-value storage (example app)
- `device_info_plus: ^11.2.0` - Device information
- `sensors_plus: ^7.0.0` - Device sensor access
- `haptic_feedback: ^0.6.4+3` - Haptic feedback
- `mutex: ^3.1.0` - Synchronization primitives
- `intl: ^0.20.2` - Internationalization

### Platform Integration
- `pigeon: ^26.1.0` - Native platform code generation (for `liquid_flutter_window_utils`)
- `plugin_platform_interface: ^2.0.2` - Plugin interface

### API & Documentation
- `mtrust_api_guard: ^5.1.0` - API versioning and changelog generation

## Code Generation & Build

- `build_runner: ^2.1.10` / `^2.3.3` - Build system
- `source_gen: ^2.0.0` / `any` - Source code generation
- `code_builder: ^4.11.1` / `^4.8.0` - Code builder utilities
- `build_config: ^1.1.1` - Build configuration
- `analyzer: ^7.4.5` / `^7.7.1` / `any` - Static analysis

## Testing

- `flutter_test` - Flutter testing framework
- `golden_toolkit: ^0.15.0` - Golden test comparison
- `diff_match_patch: ^0.4.1` - Text diffing for tests

## Configuration Files

| File | Purpose |
|------|---------|
| `pubspec.yaml` | Root workspace configuration |
| `packages/*/pubspec.yaml` | Individual package configurations |
| `melos` block in root `pubspec.yaml` | Monorepo scripts and workspace definition |
| `packages/liquid_flutter/build.yaml` | Build targets configuration |
| `packages/liquid_flutter/l10n.yaml` | Localization configuration |
| `analysis_options.yaml` | Dart analyzer rules (excludes `lib/oss_licenses.dart`) |
| `packages/*/analysis_options.yaml` | Package-specific analyzer rules |
| `packages/liquid_flutter_window_utils/pubspec.yaml` | Platform plugin config (Android/macOS) |
| `apps/example/icons_launcher.yaml` | App icon generation config |

## Platform Requirements

- **Target Platforms**: Android, iOS, macOS, Windows, Linux, Web (Flutter standard)
- **Android Package**: `com.liquid.flutter.window_utils` (window_utils plugin)
- **macOS Plugin**: `LiquidFlutterWindowUtilsPlugin` (window_utils plugin)
- **Minimum Flutter**: `>=3.3.0` (window_utils), `>=1.17.0` (other packages)
