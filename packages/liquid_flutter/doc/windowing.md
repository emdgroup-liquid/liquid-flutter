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

- Host the app in a `RegularWindow` when you want child windows. Flutter's
  `WidgetsApp` automatically installs a `WindowManager` when the feature flag is
  on, but popups, tooltips and dialogs need a parent `WindowScope`:

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

  `LdWindowRoot` uses Flutter's `RegularWindow` when windowing is available and
  renders into the implicit view everywhere else, so the same entry point works
  on every platform. The example app ships one at
  [`apps/example/lib/main_windowing.dart`](../../../apps/example/lib/main_windowing.dart).

  Apps that keep `runApp` still compile and run; the components silently fall
  back to overlays because there is no parent window controller.

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
