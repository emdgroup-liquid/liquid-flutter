# Desktop windowing

Liquid Flutter can render **context menus**, **tooltips**, and **dialogs** in
real operating-system windows on macOS, Linux, and Windows. The integration is
additive: on mobile, web, unsupported Flutter versions, or when the feature flag
is off, every component keeps its existing overlay behavior.

> **Experimental:** this integration uses Flutter's windowing API, which is
> still marked `@internal`. Expect breaking changes from Flutter between patch
> releases. The API is isolated in
> [`lib/src/windowing.dart`](../lib/src/windowing.dart).

## Requirements

- Flutter **3.44** or newer (the windowing API was introduced in 3.44).
- A desktop target (macOS, Linux, or Windows).
- Enable the Flutter feature flag before building:

  ```sh
  flutter config --enable-windowing
  ```

> At the time of writing, Flutter gates the flag to the `master` channel.
> Stable builds ship the framework API but keep `isWindowingEnabled` false, so
> the components keep using overlays. The implementation targets the current
> `master` names (`Window` / `WindowController`).

- Host the app in a `Window` when you want child windows. Starting with Flutter
  master, `WidgetsApp` no longer installs a `WindowManager` on its own and
  popups, tooltips and dialogs need a parent `WindowScope`:

  ```dart
  import 'package:flutter/widgets.dart';
  import 'package:liquid_flutter/liquid_flutter.dart';

  void main() {
    WidgetsFlutterBinding.ensureInitialized();
    runWidget(
      LdWindowRoot(
        title: 'My App',
        size: const Size(1280, 800),
        child: const MyApp(),
      ),
    );
  }
  ```

  `LdWindowRoot` uses Flutter's `Window` when windowing is available and
  renders into the implicit view everywhere else, so the same entry point works
  on every platform. The example app ships one at
  [`apps/example/lib/main.dart`](../../../apps/example/lib/main.dart).

  Apps that keep `runApp` still compile and run on stable Flutter. On a
  multi-view capable host `runApp` throws because no implicit view exists, so
  use `runWidget` together with `LdWindowRoot` (or any explicit `View`) instead.

### Runner setup (macOS)

Flutter can only enable multi-view while the engine has no view controller
attached, so a windowing app must let the framework create its windows:

- Create the `FlutterEngine` in `applicationDidFinishLaunching` and register the
  generated plugins on the engine instead of a `FlutterViewController`.
- Do not keep the default `MainFlutterWindow` / window from `MainMenu.xib`;
  that window attaches a view controller before the first Flutter window exists
  and the engine then asserts with
  `Multiview can only be enabled before adding any view controllers`.

[`apps/example/macos/Runner/AppDelegate.swift`](../../../apps/example/macos/Runner/AppDelegate.swift)
shows a runner that works on both: it owns the engine when the framework
supports windowing and falls back to a classic view-controller window on older
Flutter versions.

Hosts that attach a view controller up front must not use `LdWindowRoot` while
windowing is enabled: Flutter asserts when the first window is created. Keep
`runApp` for those, which renders into the implicit view; the components then
fall back to overlays because no parent window exists.

## What uses a native window

| Component | Native window | Fallback |
| --- | --- | --- |
| `LdContextMenu` | Popup window anchored to the trigger or cursor | Overlay route |
| `LdTooltip` | Tooltip window anchored to the child | Material `Tooltip` |
| `LdModalRoute` | Dialog window when the route renders as a dialog | Overlay dialog or sheet |

`LdModalRoute` only uses a native dialog when it would render as a dialog. On
narrow windows, or when `modalTypeMode` resolves to a sheet, it keeps the
overlay sheet implementation. Native dialog windows have no barrier and are
modal to their parent through the operating system.

## Opting out

Disable windowing for a subtree:

```dart
LdWindowingScope(
  enabled: false,
  child: MyApp(),
)
```

Disable it for one component:

```dart
LdContextMenu(
  windowMode: LdWindowMode.disabled,
  // ...
)

LdTooltip(
  windowMode: LdWindowMode.disabled,
  // ...
)

LdModalRoute(
  context: context,
  windowMode: LdWindowMode.disabled,
  // ...
)
```

## Checking availability

```dart
if (LdWindowing.isAvailable(context)) {
  // Native popups, tooltips, and dialogs are available here.
}
```

## Testing

Inject a fake `LdWindowingAdapter` through `LdWindowingScope` to exercise the
native code paths without a real desktop window. See
[`test/windowing_test.dart`](../test/windowing_test.dart) for examples.
