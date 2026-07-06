---
name: liquid_flutter_window_utils-window
description: Use when integrating native window management in a Liquid Flutter desktop application — covers LiquidFlutterWindowUtils singleton, window control APIs, screen corner radius, reactive streams, and Android gesture exclusion rects.
---

# Liquid Flutter Window Utils

`liquid_flutter_window_utils` is a Flutter platform plugin that exposes native window management for macOS and Android. It silently no-ops on unsupported platforms (web, Windows, Linux).

## Import

```dart
import 'package:liquid_flutter_window_utils/liquid_flutter_window_utils.dart';
import 'package:liquid_flutter_window_utils/screen_radius_defaults.dart'; // iOS fallback
```

---

## LiquidFlutterWindowUtils singleton

All APIs are accessed through `LiquidFlutterWindowUtils.instance`.

### Window control

```dart
final utils = LiquidFlutterWindowUtils.instance;

// Size and position
await utils.setWindowSize(1280, 800);
await utils.setWindowPosition(100, 100);
await utils.setWindowTitle('My App');

// Window actions
await utils.closeWindow();
await utils.minimizeWindow();
await utils.maximizeWindow();
await utils.startDragging();   // initiate window drag from custom title bar

// Configure (call once when window is ready)
await utils.configureWindow();

// Query
final state = await utils.getWindowState();  // WindowState
final isMax = await utils.isWindowMaximized();
final radius = await utils.getScreenRadius();
```

### Reactive streams

```dart
// Listen for window state changes (macOS pushes changes; both emit current state on first listen)
utils.windowStateStream.listen((WindowState state) { ... });
utils.windowMaximizedStream.listen((bool isMaximized) { ... });
utils.windowReadyStream.listen((bool isReady) {
  if (isReady) utils.configureWindow();
});
```

### Android gesture exclusion rects

```dart
await utils.setSystemGestureExclusionRects([
  Rect(left: 0, top: 100, right: 50, bottom: 200),
]);
```

Note: `Rect` here is the Pigeon-generated data class — **not** `dart:ui Rect`.

---

## WindowState

```dart
class WindowState {
  int x, y, width, height;
  bool isMaximized, isMinimized;
}
```

---

## Screen corner radius

### `getScreenRadius()` (top-level, from `screen_radius_defaults.dart`)

Platform-aware helper that returns the hardware screen corner radius as a `double`:
- **macOS / Android**: queries native API.
- **iOS**: looks up a hard-coded table by device model identifier.
- **Web / Windows / Linux**: returns `0.0`.

```dart
final radius = await getScreenRadius();
```

Pass the result to `LdThemeProvider` so rounded corners and the window maximize guard work correctly:

```dart
LdThemeProvider(
  screenRadius: Future.value(radius),
  windowMaximizedStream: LiquidFlutterWindowUtils.instance.windowMaximizedStream,
  child: ...,
)
```

When the window is maximized, `LdThemeProvider` automatically sets the corner radius to `0`.

---

## Typical main() setup (desktop)

```dart
import 'package:liquid_flutter_window_utils/screen_radius_defaults.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wire up title-bar button callbacks
  LdAppBarWidget.callbacks = LdWindowCallbacks(
    onClose:    () => LiquidFlutterWindowUtils.instance.closeWindow(),
    onMinimize: () => LiquidFlutterWindowUtils.instance.minimizeWindow(),
    onMaximize: () => LiquidFlutterWindowUtils.instance.maximizeWindow(),
    onMove:     () => LiquidFlutterWindowUtils.instance.startDragging(),
  );

  // Configure window as soon as it is ready
  LiquidFlutterWindowUtils.instance.windowReadyStream.listen((isReady) async {
    if (isReady) await LiquidFlutterWindowUtils.instance.configureWindow();
  });

  final screenRadius = await getScreenRadius();
  runApp(MyApp(screenRadius: screenRadius));
}
```

---

## Notes

- Always call `LdAppBarWidget.callbacks` **before** `runApp()`.
- Always listen to `windowReadyStream` and call `configureWindow()` — do not call it unconditionally at startup.
- The `Rect` type from this package shadows `dart:ui Rect`; import carefully if you use both.
