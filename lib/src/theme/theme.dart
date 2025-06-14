import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'package:provider/provider.dart';

/// Provides a theme to all the components in the widget tree
/// Theme can be accessed using LdTheme.of(context)
class LdTheme extends ChangeNotifier {
  LdPalette _palette = shadDefault;
  LdPalette get palette => _palette;
  LdThemeSize _defaultSize = LdThemeSize.m;
  LdThemeSize get themeSize => _defaultSize;

  LdSizingConfig _sizingConfig = LdSizingConfig();

  LdSizingConfig get sizingConfig => _sizingConfig;

  set sizingConfig(LdSizingConfig config) {
    _sizingConfig = config;
    notifyListeners();
  }

  BorderRadius radius(LdSize size) {
    return BorderRadius.circular(switch (size) {
      (LdSize.xs) => _sizingConfig.radiusXS,
      (LdSize.s) => _sizingConfig.radiusS,
      (LdSize.m) => _sizingConfig.radiusM,
      (LdSize.l) => _sizingConfig.radiusL,
    });
  }

  double _screenRadius = 0;

  double get screenRadius => _screenRadius;

  set screenRadius(double radius) {
    _screenRadius = radius;
    notifyListeners();
  }

  String _fontFamily = 'Lato';

  /// Get the font family for the theme, defaults to 'Lato'
  String get fontFamily => _fontFamily;

  /// Set the font family for the theme
  set fontFamily(String newFont) {
    _fontFamily = newFont;
    notifyListeners();
  }

  String _headlineFontFamily = 'Lato';

  String get headlineFontFamily => _headlineFontFamily;

  set headlineFontFamily(String newFont) {
    _headlineFontFamily = newFont;
    notifyListeners();
  }

  String? _fontFamilyPackage = ldIncludeFontPackage ? 'liquid_flutter' : null;

  String? get fontFamilyPackage => _fontFamilyPackage;

  /// Set the font family package for the theme
  set fontFamilyPackage(String? newFontPackage) {
    _fontFamilyPackage = newFontPackage;
    notifyListeners();
  }

  /// Set the default size for the theme
  void setThemeSize(LdThemeSize size) {
    _defaultSize = size;
    notifyListeners();
  }

  /// Get the balanced padding for a given size
  EdgeInsets balPad(LdSize size) {
    return EdgeInsets.symmetric(
      horizontal: themeSize.paddingSize(size.adjust(0)),
      vertical: themeSize.paddingSize(size.adjust(-1)),
    );
  }

  /// Get the border width for a given size
  double get borderWidth {
    switch (themeSize) {
      case LdThemeSize.s:
        return 1;
      case LdThemeSize.m:
      case LdThemeSize.l:
        return 2;
    }
  }

  /// Get the size of padding for a given size as a double
  double paddingSize({LdSize size = LdSize.m}) {
    return switch (themeSize) {
      (LdThemeSize.s) => switch (size) {
          (LdSize.xs) => _sizingConfig.themeSPaddingXS,
          (LdSize.s) => _sizingConfig.themeSPaddingS,
          (LdSize.m) => _sizingConfig.themeSPaddingM,
          (LdSize.l) => _sizingConfig.themeSPaddingL,
        },
      (LdThemeSize.m) => switch (size) {
          (LdSize.xs) => _sizingConfig.themeMPaddingXS,
          (LdSize.s) => _sizingConfig.themeMPaddingS,
          (LdSize.m) => _sizingConfig.themeMPaddingM,
          (LdSize.l) => _sizingConfig.themeMPaddingL,
        },
      (LdThemeSize.l) => switch (size) {
          (LdSize.xs) => _sizingConfig.themeLPaddingXS,
          (LdSize.s) => _sizingConfig.themeLPaddingS,
          (LdSize.m) => _sizingConfig.themeLPaddingM,
          (LdSize.l) => _sizingConfig.themeLPaddingL,
        },
    };
  }

  /// Get the size of a label for a given size as a double
  double labelSize(LdSize? size) {
    return themeSize.labelSize(size ?? LdSize.m);
  }

  /// Get the size of a paragraph for a given size as a double
  double paragraphSize(LdSize? size) {
    return themeSize.paragraphSize(size ?? LdSize.m);
  }

  /// Get the size of a headline for a given size as a double
  double headlineSize(LdSize? size) {
    return themeSize.headlineSize(size ?? LdSize.m);
  }

  /// Get uniform padding for a given size
  EdgeInsets pad({LdSize size = LdSize.m}) {
    return EdgeInsets.all(themeSize.paddingSize(size));
  }

  /// Set the color palette for the theme
  void setPalette(LdPalette palette) {
    _palette = palette;
    // In case theres a component listening for theme updates
    notifyListeners();
  }

  /// Get the theme from the context. Requires a provider above the widget tree
  static LdTheme of(BuildContext context, {bool listen = false}) {
    return Provider.of<LdTheme>(context, listen: listen);
  }

  /// Whether the theme is dark or not
  bool get isDark => _palette.isDark;

  /// Get the absolute foreground color for the theme
  Color get absolute {
    if (!isDark) {
      return Colors.white;
    } else {
      return Colors.black;
    }
  }

  /// Get a neutral shade based on the theme [shade].
  Color neutralShade(int shade) {
    return palette.neutral.relative(isDark, shade);
  }

  /// get the primary color name
  LdColor get primary => _palette.primary;

  /// get the secondary color name
  LdColor get secondary => _palette.secondary;

  /// get the success color name
  LdColor get success => _palette.success;

  /// get the warning color name
  LdColor get warning => _palette.warning;

  /// get the error color name
  LdColor get error => _palette.error;

  /// Get the idle primary color
  Color get primaryColor {
    return _palette.primary.center(isDark);
  }

  /// Get the idle primary color text
  Color get primaryColorText {
    return _palette.primary.contrastingText(primaryColor);
  }

  /// Get the idle secondary color
  Color get secondaryColor {
    return _palette.secondary.center(isDark);
  }

  /// Get the idle secondary color text
  Color get secondaryColorText {
    return _palette.secondary.contrastingText(secondaryColor);
  }

  /// Get the idle error color
  Color get errorColor {
    return _palette.error.center(isDark);
  }

  /// Get the idle error color text
  Color get errorColorText {
    return _palette.error.contrastingText(errorColor);
  }

  /// Get the idle success color
  Color get successColor {
    return _palette.success.center(isDark);
  }

  /// Get the idle success color text
  Color get successColorText {
    return _palette.success.contrastingText(successColor);
  }

  /// Get the idle warning color
  Color get warningColor {
    return _palette.warning.center(isDark);
  }

  /// Get the idle warning color text
  Color get warningColorText {
    return _palette.warning.contrastingText(warningColor);
  }

  /// Get the background color for the page
  Color get background {
    return _palette.background;
  }

  /// Get the default text color
  Color get text {
    return _palette.text;
  }

  /// Get the muted text color
  Color get textMuted {
    return _palette.textMuted;
  }

  /// Get the border color
  Color get border {
    return _palette.border;
  }

  /// Get the stroke color
  Color get stroke {
    return _palette.stroke;
  }

  /// Get the surface color
  Color get surface {
    return _palette.surface;
  }
}

class LdSizingConfig {
  double radiusXS;
  double radiusS;
  double radiusM;
  double radiusL;

  double themeSPaddingXS;
  double themeSPaddingS;
  double themeSPaddingM;
  double themeSPaddingL;

  double themeMPaddingXS;
  double themeMPaddingS;
  double themeMPaddingM;
  double themeMPaddingL;

  double themeLPaddingXS;
  double themeLPaddingS;
  double themeLPaddingM;
  double themeLPaddingL;

  LdSizingConfig({
    this.radiusXS = 4.0,
    this.radiusS = 8.0,
    this.radiusM = 16.0,
    this.radiusL = 24.0,
    this.themeSPaddingXS = 4.0,
    this.themeSPaddingS = 8.0,
    this.themeSPaddingM = 10.0,
    this.themeSPaddingL = 12.0,
    this.themeMPaddingXS = 8.0,
    this.themeMPaddingS = 12.0,
    this.themeMPaddingM = 14.0,
    this.themeMPaddingL = 24.0,
    this.themeLPaddingXS = 8.0,
    this.themeLPaddingS = 16.0,
    this.themeLPaddingM = 24.0,
    this.themeLPaddingL = 32.0,
  });
}
