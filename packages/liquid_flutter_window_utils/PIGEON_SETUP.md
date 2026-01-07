# Pigeon Setup Guide

This document explains how to get started with the Pigeon setup in this package.

## What is Pigeon?

[Pigeon](https://pub.dev/packages/pigeon) is a code generator tool for Flutter that creates type-safe platform channels. It generates platform-specific code (Java/Kotlin for Android, Swift/Objective-C for iOS/macOS) from a single Dart interface definition.

## Current Setup

The package is configured with:

1. **Pigeon dependency** in `pubspec.yaml`
2. **Build configuration** in `build.yaml`
3. **API definition** in `pigeons/messages.dart`
4. **Generated code** will be created in multiple locations

## Getting Started

### 1. Install Dependencies

```bash
cd liquid_flutter_window_utils
flutter pub get
```

### 2. Generate Code

After installing dependencies, generate the platform-specific code:

```bash
# Option 1: Use the provided script
./scripts/generate_pigeon.sh

# Option 2: Use pigeon directly
flutter packages pub run pigeon --input pigeons/messages.dart

# Option 3: Use build_runner
flutter packages pub run build_runner build
```

### 3. Add Your First Method

1. Edit `pigeons/messages.dart` and uncomment one of the example methods
2. Regenerate the code using step 2
3. Implement the native code in the generated platform files
4. Add the method call in `lib/liquid_flutter_window_utils.dart`

## File Structure After Generation

```
liquid_flutter_window_utils/
├── pigeons/
│   └── messages.dart          # Your API definition
├── lib/
│   ├── messages.g.dart        # Generated Dart code
│   └── liquid_flutter_window_utils.dart
├── android/src/main/java/.../
│   └── Messages.java          # Generated Android code
├── ios/Classes/
│   ├── Messages.h             # Generated iOS header
│   └── Messages.m             # Generated iOS implementation
└── macos/Classes/
    └── Messages.swift         # Generated macOS code
```

## Example: Adding a Window Size Method

1. **Define the API** in `pigeons/messages.dart`:

```dart
@HostApi()
abstract class WindowUtilsApi {
  bool setWindowSize(int width, int height);
}
```

2. **Generate code**:

```bash
./scripts/generate_pigeon.sh
```

3. **Implement native code** in the generated platform files

4. **Use in Dart**:

```dart
Future<bool> setWindowSize(int width, int height) async {
  final api = WindowUtilsApi();
  return await api.setWindowSize(width, height);
}
```

## Troubleshooting

- **Linter errors**: These are expected until you run `flutter pub get` and generate the code
- **Missing generated files**: Run the generation command to create them
- **Platform-specific errors**: Check that the generated platform files are properly implemented

## Next Steps

1. Run `flutter pub get` to install Pigeon
2. Generate the initial code using the script
3. Uncomment and implement one of the example methods
4. Test the basic functionality
5. Add more methods as needed
