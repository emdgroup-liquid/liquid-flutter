import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

enum LdThemeBrightnessMode {
  auto,
  light,
  dark,
}

/// Provides a theme to all the components in the widget tree
/// Theme can be accessed using LdTheme.of(context)
class LdThemeProvider extends StatefulWidget {
  final Widget child;
  final LdTheme? theme;

  final LdThemeBrightnessMode brightnessMode;

  /// The dark palette to use when [autoBrightness] is true defaults to [deepOcean]
  final LdPalette? darkPalette;

  /// The light palette to use when [autoBrightness] is true defaults to [ocean]
  final LdPalette? lightPalette;

  /// If true the theme will change based on the type of the device
  /// will use LdThemeSize.m on mobile and LdThemeSize.s on desktop
  final bool autoSize;

  const LdThemeProvider({
    required this.child,
    Key? key,
    this.theme,
    this.brightnessMode = LdThemeBrightnessMode.auto,
    this.autoSize = true,
    this.darkPalette,
    this.lightPalette,
  }) : super(key: key);

  @override
  State<LdThemeProvider> createState() => _LdThemeProviderState();
}

class _LdThemeProviderState extends State<LdThemeProvider>
    with WidgetsBindingObserver {
  LdPalette? _palette;

  LdThemeSize? _themeSize;
  LdTheme? _createdTheme;

  LdPalette get _darkPalette => widget.darkPalette ?? shadDefaultDark;
  LdPalette get _lightPalette => widget.lightPalette ?? shadDefault;
  LdTheme get _theme => widget.theme ?? _createdTheme!;

  @override
  void initState() {
    if (widget.theme == null) {
      _createdTheme = LdTheme();
    }

    _applyBrightness();

    _palette = _theme.palette;
    _themeSize = _theme.themeSize;
    _theme.addListener(themeChanged);
    WidgetsBinding.instance.addObserver(this);

    if (widget.autoSize) {
      if (kIsWeb ||
          Platform.isMacOS ||
          Platform.isWindows ||
          Platform.isLinux) {
        _theme.setThemeSize(LdThemeSize.s);
      } else {
        _theme.setThemeSize(LdThemeSize.m);
      }
    }

    super.initState();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _applyBrightness();
  }

  void _applyBrightness() {
    switch (widget.brightnessMode) {
      case LdThemeBrightnessMode.auto:
        var brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;

        if (brightness == Brightness.dark && _theme.palette != _darkPalette) {
          _theme.setPalette(_darkPalette);
        } else {
          _theme.setPalette(_lightPalette);
        }
        break;
      case LdThemeBrightnessMode.light:
        _theme.setPalette(_lightPalette);
        break;
      case LdThemeBrightnessMode.dark:
        _theme.setPalette(_darkPalette);
        break;
    }
  }

  @override
  void didUpdateWidget(covariant LdThemeProvider oldWidget) {
    if (oldWidget.theme != widget.theme) {
      oldWidget.theme?.removeListener(themeChanged);
      widget.theme?.addListener(themeChanged);
    }

    if (oldWidget.brightnessMode != widget.brightnessMode) {
      _applyBrightness();
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  dispose() {
    _createdTheme?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void themeChanged() async {
    bool paletteChanged = _palette != _theme.palette;
    bool sizeChanged = _themeSize != _theme.themeSize;

    if (paletteChanged || sizeChanged) {
      _palette = _theme.palette;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: LdSurfaceInfo(isSurface: false),
      child: ChangeNotifierProvider.value(
        value: _theme,
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.ltr,
            child: DefaultTextStyle(
              style: TextStyle(
                color: _theme.text,
                fontFamily: _theme.fontFamily,
                package: _theme.fontFamilyPackage,
                decoration: TextDecoration.none,
              ),
              child: child!,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
