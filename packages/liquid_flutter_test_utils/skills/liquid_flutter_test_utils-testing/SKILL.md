---
name: liquid_flutter_test_utils-testing
description: Use when writing widget or golden tests for Liquid Flutter — covers multiGolden, widgetTreeMatchesGolden, ldFrame, LdFrameOptions, device presets (iPhone 16 Pro, iPad 11 Pro), and WidgetTreeOptions.
---

# Liquid Flutter Test Utils

`liquid_flutter_test_utils` provides golden-test infrastructure for Liquid Flutter. It wraps `golden_toolkit` and adds multi-theme / multi-size / multi-device rendering, XML widget-tree golden tests, and device frame overlays.

## Import

```dart
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
```

---

## Setup

Call once in `setUpAll`:

```dart
void main() {
  setUpAll(() async {
    await setupGoldenTest(
      localizationsDelegates: [MyAppLocalizations.delegate], // optional
    );
  });

  // ... tests
}
```

`setupGoldenTest` stores localizations delegates globally and is called automatically by `multiGolden` (via `loadAppFonts`).

---

## multiGolden — main test runner

Iterates over all combinations of frame scenarios × widgets × theme sizes × brightnesses × orientations, renders each, and compares against golden widget-tree XML files (and optionally pixel goldens).

```dart
testGoldens('My widget', (tester) async {
  await multiGolden(
    tester,
    'MyWidget',                            // golden file prefix
    {
      'Default': (tester, placeWidget) async {
        await placeWidget(MyWidget());
      },
      'Error state': (tester, placeWidget) async {
        await placeWidget(MyWidget(isError: true));
      },
    },
    // optional:
    frameScenarios: [LdFrameOptions(width: 400), iPhone16Pro],
    performWidgetTreeTests: true,          // default true
    themeSizeScenarios: LdThemeSize.values, // default: all sizes
    brightnessScenarios: Brightness.values, // default: light + dark
    orientationScenarios: [Orientation.portrait],
    clipScreenToRadius: true,
  );
});
```

**Output location:** `test/golden_widget_trees/<Name>/<Scenario>/<FrameLabel>_<Size>_<Brightness>.xml`

**Failure screenshots** (written on mismatch): `test/failures/golden_widget_trees/` (gitignore this directory).

---

## widgetTreeMatchesGolden — single tree test

Lower-level; captures the widget tree as XML and compares/writes the golden file directly.

```dart
testGoldens('specific tree', (tester) async {
  const key = ValueKey('root');
  final widget = ldFrame(child: MyWidget(key: key));
  await tester.pumpWidget(widget);

  await widgetTreeMatchesGolden(
    tester,
    widget: widget,
    options: WidgetTreeOptions(
      findWidget: (tester, widget) => find.byKey(key),
      goldenName: 'MyWidgetCustomName',
      strippedWidgets: {...defaultIgnoredWidgets, 'NotificationListener'},
      includeWidgetBounds: IncludeWidgetBounds.relative,
    ),
  );
});
```

---

## WidgetTreeOptions

Controls what is captured and compared in widget-tree goldens.

```dart
WidgetTreeOptions({
  Finder Function(WidgetTester, Widget)? findWidget,  // default: find the root widget
  String goldenPath = 'test/golden_widget_trees',
  String failurePath = 'test/failures/golden_widget_trees',
  String? goldenName,
  Set<dynamic> strippedWidgets = defaultIgnoredWidgets,
  bool stripPrivateWidgets = true,
  IncludeWidgetBounds includeWidgetBounds = IncludeWidgetBounds.relative,
  int boundsPrecision = 0,
})
```

**`strippedWidgets`** can contain `Type` objects or `String` names (required for generic types, e.g. `'NotificationListener'`).

**Default stripped set (`defaultIgnoredWidgets`):** `MediaQuery`, `Material`, `AnimatedDefaultTextStyle`, `DefaultTextStyle`, `PhysicalModel`, `AnimatedPhysicalModel`, `AnimatedBuilder`, `Semantics`, `Actions`, `'NotificationListener'`, `Focus`, `'Provider'`, `KeyedSubtree`, `MouseRegion`, `Builder`.

**`IncludeWidgetBounds`:**
- `none` — no bounds included
- `relative` — bounds relative to parent (default)
- `absolute` — screen-absolute coordinates

---

## ldFrame — test harness wrapper

Wraps a widget in the full Liquid test environment: `LdThemeProvider` → `LdThemedAppBuilder` → `MaterialApp.router` (GoRouter) → `MediaQuery` with safe-area padding → optional device-frame overlay.

```dart
final framed = ldFrame(
  child: MyWidget(),
  brightnessMode: LdThemeBrightnessMode.dark,
  size: LdThemeSize.m,
  ldFrameOptions: iPhone16Pro,
  orientation: Orientation.portrait,
  showBackButton: false,  // true adds a /child route so back arrow appears
);
await tester.pumpWidget(framed);
```

---

## LdFrameOptions — device frame configuration

```dart
const LdFrameOptions({
  String label = '',
  double width = 500,
  double? height,               // null = intrinsic height
  double devicePixelRatio = 1.0,
  double? screenRadius,
  LdPlatform? platform,
  EdgeInsets viewPadding = EdgeInsets.zero,
  Widget Function(BuildContext, Orientation, SystemUiOverlayStyle?, Widget)? build,
})
```

### Pre-built device presets

```dart
import 'package:liquid_flutter_test_utils/system_ui/iphone_16_pro.dart';
import 'package:liquid_flutter_test_utils/system_ui/ipad_11_pro.dart';
import 'package:liquid_flutter_test_utils/system_ui/fairphone_6.dart';

// Usage:
frameScenarios: [iPhone16Pro, iPadPro11],
```

| Preset | Width | DPR | Radius | Platform |
|---|---|---|---|---|
| `iPhone16Pro` | 393 | 3.0 | 55px | iOS |
| `iPadPro11` | see source | — | — | iOS |
| `fairphone6` | see source | — | — | Android |

---

## Full example

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:liquid_flutter_test_utils/liquid_flutter_test_utils.dart';
import 'package:liquid_flutter_test_utils/system_ui/iphone_16_pro.dart';

void main() {
  setUpAll(() async {
    await setupGoldenTest();
  });

  testGoldens('StatusBadge renders all states', (tester) async {
    await multiGolden(
      tester,
      'StatusBadge',
      {
        'Active': (tester, place) async {
          await place(StatusBadge(status: Status.active));
        },
        'Inactive': (tester, place) async {
          await place(StatusBadge(status: Status.inactive));
        },
      },
      frameScenarios: [
        LdFrameOptions(width: 300),
        iPhone16Pro,
      ],
      brightnessScenarios: Brightness.values,
      themeSizeScenarios: [LdThemeSize.m],
    );
  });
}
```

---

## Notes

- Widget tree goldens must be updated with `flutter test --update-goldens` (or set `autoUpdateGoldenFiles = true` in Flutter test config).
- Failure screenshots in `test/failures/` are written automatically on mismatch — add this path to `.gitignore`.
- Use `resetTester(tester)` between unrelated tests when running multiple `multiGolden` calls in one `main()` to avoid surface size bleed-over.
