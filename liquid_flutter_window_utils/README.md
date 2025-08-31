# Liquid Flutter Window Utils

A Flutter plugin for window utilities using Pigeon for platform-specific code generation.

## Setup

This package uses [Pigeon](https://pub.dev/packages/pigeon) for generating platform-specific code. The Pigeon configuration is in `pigeons/messages.dart`.

## Development

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Generate Pigeon code

After modifying the Pigeon messages file, regenerate the platform-specific code:

```bash
flutter packages pub run pigeon --input pigeons/messages.dart
```

Or use the build runner:

```bash
flutter packages pub run build_runner build
```

### 3. Add new methods

To add new window utility methods:

1. Edit `pigeons/messages.dart` to add new methods to the `WindowUtilsApi` class
2. Regenerate the code using one of the commands above
3. Implement the methods in the platform-specific files (Android, iOS, macOS)
4. Add the method calls in `lib/liquid_flutter_window_utils.dart`

## Project Structure

- `pigeons/messages.dart` - Pigeon API definition
- `lib/messages.g.dart` - Generated Dart code (do not edit manually)
- `android/src/main/java/.../Messages.java` - Generated Android code
- `ios/Classes/Messages.h` - Generated iOS header
- `ios/Classes/Messages.m` - Generated iOS implementation
- `macos/Classes/Messages.swift` - Generated macOS code

## Example

```dart
// In pigeons/messages.dart
@HostApi()
abstract class WindowUtilsApi {
  bool setWindowSize(int width, int height);
  void setWindowTitle(String title);
}

// In lib/liquid_flutter_window_utils.dart
Future<bool> setWindowSize(int width, int height) async {
  final api = WindowUtilsApi();
  return await api.setWindowSize(width, height);
}
```
