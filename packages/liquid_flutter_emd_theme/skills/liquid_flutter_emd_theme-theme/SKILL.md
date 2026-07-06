---
name: liquid_flutter_emd_theme-theme
description: Use when applying the EMD (Merck KGaA) brand theme to a Liquid Flutter application — covers emd palettes, LdColor swatches, LdIcons, and LdThemeProvider setup.
---

# Liquid Flutter EMD Theme

`liquid_flutter_emd_theme` provides Merck KGaA (EMD) brand design tokens for Liquid Flutter: color palettes, raw `LdColor` swatches, and a custom icon font.

> **License note**: This package is restricted to applications created for or by Merck KGaA.

## Import

```dart
import 'package:liquid_flutter_emd_theme/liquid_flutter_emd_theme.dart';
```

---

## Applying a palette

Pass one of the pre-built `LdPalette` objects to `LdThemeProvider`:

```dart
LdThemeProvider(
  palette: emdLightBlue,   // see table below
  child: ...,
)
```

### Available palettes

| Constant | Dark? | Primary | Secondary | Typical use |
|---|---|---|---|---|
| `emdLightBlue` | no | richBlue | vibrantCyan | Default light theme |
| `emdDarkBlue` | yes | richBlue | vibrantCyan | Default dark theme |
| `emdDarkForest` | yes | richGreen | vibrantGreen | Green dark variant |
| `emdDarkPurple` | yes | richPurple | vibrantMagenta | Purple dark variant |
| `emdLightPurple` | no | richPurple | vibrantYellow | Purple light variant |
| `emdNightRunner` | yes | richRed | vibrantMagenta | Red dark variant |

---

## Color swatches

Raw `LdColor` 11-stop swatches (usable wherever `LdColor` is accepted):

| Constant | Character |
|---|---|
| `richBlue` | Primary blue |
| `richGreen` | Positive / success green |
| `richPurple` | Purple |
| `richRed` | Error / negative red |
| `vibrantCyan` | Accent cyan |
| `vibrantGreen` | Accent green |
| `vibrantMagenta` | Accent magenta |
| `vibrantYellow` | Warning yellow |

---

## EMD Icons

`LdIcons` exposes `IconData` constants from the `LiquidIcons` custom font (EMD.ttf). Use them anywhere you would use `Icons.*`:

```dart
Icon(LdIcons.flask)
Icon(LdIcons.microscope)
Icon(LdIcons.dna)
```

### Selected icon names

`three_d`, `add`, `atom`, `attention`, `audio`, `baby`, `bacteria_microscope_view`, `basket`, `battery_charging` / `battery_empty` / `battery_full` / `battery_half`, `beaker`, `bell`, `bin`, `calendar`, `camera`, `car`, `chat`, `checkmark`, `clock`, `cloud_download` / `cloud_upload`, `copy`, `dashboard`, `dna`, `documents`, `download`, `eco`, `energy`, `filter`, `flask`, `house`, `laptop`, `list`, `location`, `mail`, `magnifier`, `microscope`, `mobile`, `monitor`, `monkey`, `pen`, `phone`, `print`, `refresh`, `rocket`, `settings`, `share`, `shield`, `star`, `upload`, `user`, `virus`, `watch`, `website`, `wi_fi`, `world`, `arrow_down` / `arrow_left` / `arrow_right` / `arrow_up`, and more.

---

## Typical root setup

```dart
import 'package:liquid_flutter_emd_theme/liquid_flutter_emd_theme.dart';

LdThemeProvider(
  palette: emdLightBlue,
  screenRadius: Future.value(screenRadius),
  windowMaximizedStream: LiquidFlutterWindowUtils.instance.windowMaximizedStream,
  child: LdThemedAppBuilder(
    appBuilder: (context, theme) => MaterialApp.router(
      theme: theme,
      routerConfig: router,
    ),
  ),
)
```

---

## Notes

- Prefer `LdIcons.*` over `Icons.*` / `CupertinoIcons.*` when an equivalent EMD icon exists.
- Swatches can be passed to `LdPalette(...)` constructor if you need a fully custom palette built from EMD colors.
