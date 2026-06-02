import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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

  final LdThemeSize? size;
  final LdPlatform? platform;

  /// The dark palette to use when [autoBrightness] is true defaults to [deepOcean]
  final LdPalette? darkPalette;

  /// The light palette to use when [autoBrightness] is true defaults to [ocean]
  final LdPalette? lightPalette;

  /// If true the theme will change based on the type of the device
  /// will use LdThemeSize.m on mobile and LdThemeSize.s on desktop

  /// Screen corner radius in logical pixels for device or window chrome.
  final Future<double>? screenRadius;

  /// When this stream emits `true`, [screenRadius] is overridden to `0` (e.g. maximized desktop window).
  final Stream<bool>? windowMaximizedStream;

  const LdThemeProvider({
    required this.child,
    super.key,
    this.theme,
    this.brightnessMode = LdThemeBrightnessMode.auto,
    this.darkPalette,
    this.lightPalette,
    this.screenRadius,
    this.windowMaximizedStream,
    this.size,
    this.platform,
  });

  @override
  State<LdThemeProvider> createState() => _LdThemeProviderState();
}

class _LdThemeProviderState extends State<LdThemeProvider> with WidgetsBindingObserver {
  LdPalette? _palette;

  LdThemeSize? _themeSize;
  LdTheme? _createdTheme;

  LdPalette get _darkPalette => widget.darkPalette ?? shadDefaultDark;
  LdPalette get _lightPalette => widget.lightPalette ?? shadDefault;
  LdTheme get _theme => widget.theme ?? _createdTheme!;

  double? _baseScreenRadius;
  bool _isWindowMaximized = false;
  StreamSubscription<bool>? _windowMaximizedSubscription;

  @override
  void initState() {
    super.initState();

    if (widget.theme == null) {
      _createdTheme = LdTheme();
    }
    _palette = _theme.palette;
    _themeSize = _theme.themeSize;
    _theme.addListener(themeChanged);
    WidgetsBinding.instance.addObserver(this);

    _applyScreenRadius();
    _listenToWindowMaximizedStream();
    _runAfterFrame(_applyInitialTheme);
  }

  void _runAfterFrame(VoidCallback callback) {
    if (!mounted) {
      return;
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    final shouldDefer = switch (phase) {
      SchedulerPhase.idle || SchedulerPhase.postFrameCallbacks => false,
      _ => true,
    };

    if (!shouldDefer) {
      callback();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      callback();
    });
  }

  void _applyInitialTheme() {
    _applyPlatformOverride();
    _applyBrightness();
    _applyThemeSize();
  }

  void _applyScreenRadius() {
    final screenRadius = widget.screenRadius;
    if (screenRadius == null) {
      return;
    }
    screenRadius.then((radius) {
      if (!mounted) {
        return;
      }
      _baseScreenRadius = radius;
      _updateEffectiveScreenRadius();
    });
  }

  void _listenToWindowMaximizedStream() {
    final stream = widget.windowMaximizedStream;
    if (stream == null) {
      return;
    }
    _windowMaximizedSubscription = stream.listen((isMaximized) {
      if (!mounted) {
        return;
      }
      _isWindowMaximized = isMaximized;
      _updateEffectiveScreenRadius();
    });
  }

  void _updateEffectiveScreenRadius() {
    final base = _baseScreenRadius;
    if (base == null) {
      return;
    }
    final effective = _isWindowMaximized ? 0.0 : base;
    _runAfterFrame(() {
      if (_theme.screenRadius == effective) {
        return;
      }
      _theme.screenRadius = effective;
      // [_windowDecoration] lives in this State's build; theme listeners alone do not rebuild it.
      setState(() {});
    });
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    _applyBrightness();
  }

  void _applyBrightness() {
    final targetPalette = switch (widget.brightnessMode) {
      LdThemeBrightnessMode.auto =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
            ? _darkPalette
            : _lightPalette,
      LdThemeBrightnessMode.light => _lightPalette,
      LdThemeBrightnessMode.dark => _darkPalette,
    };

    if (_theme.palette == targetPalette) {
      return;
    }
    _theme.setPalette(targetPalette);
  }

  void _applyThemeSize() {
    final targetThemeSize = widget.size ??
        switch (_theme.platform.isDesktop) {
          true => LdThemeSize.s,
          false => LdThemeSize.m,
        };

    if (_theme.themeSize == targetThemeSize) {
      return;
    }
    _theme.setThemeSize(targetThemeSize);
  }

  void _applyPlatformOverride() {
    final platform = widget.platform;
    if (platform == null || _theme.platform == platform) {
      return;
    }
    _theme.platform = platform;
  }

  @override
  void didUpdateWidget(covariant LdThemeProvider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.theme != widget.theme) {
      oldWidget.theme?.removeListener(themeChanged);
      widget.theme?.addListener(themeChanged);
      _palette = _theme.palette;
      _themeSize = _theme.themeSize;
    }

    final didThemeInputsChange = oldWidget.brightnessMode != widget.brightnessMode ||
        oldWidget.size != widget.size ||
        oldWidget.platform != widget.platform;

    if (didThemeInputsChange) {
      _runAfterFrame(_applyInitialTheme);
    }

    if (oldWidget.screenRadius != widget.screenRadius) {
      _baseScreenRadius = null;
      _applyScreenRadius();
    }

    if (oldWidget.windowMaximizedStream != widget.windowMaximizedStream) {
      _windowMaximizedSubscription?.cancel();
      _isWindowMaximized = false;
      _listenToWindowMaximizedStream();
      _updateEffectiveScreenRadius();
    }
  }

  @override
  void dispose() {
    _theme.removeListener(themeChanged);
    WidgetsBinding.instance.removeObserver(this);
    _windowMaximizedSubscription?.cancel();
    _createdTheme?.dispose();
    super.dispose();
  }

  void themeChanged() async {
    final paletteChanged = _palette != _theme.palette;
    final sizeChanged = _themeSize != _theme.themeSize;

    if (paletteChanged || sizeChanged) {
      _palette = _theme.palette;
      _themeSize = _theme.themeSize;
    }
  }

  BoxDecoration? get _windowDecoration {
    if (_theme.platform == LdPlatform.macos) {
      return BoxDecoration(
        color: _theme.background,
        borderRadius: BorderRadius.circular(_theme.screenRadius),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final windowDecoration = _windowDecoration;
    return Container(
      decoration: windowDecoration,
      clipBehavior: windowDecoration != null ? Clip.hardEdge : Clip.none,
      child: Provider.value(
        value: LdSurfaceInfo(isSurface: false),
        child: ChangeNotifierProvider.value(
          value: _theme,
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: DefaultTextStyle.merge(
                style: ldBuildTextStyle(
                  _theme,
                  LdTextType.paragraph,
                  LdSize.m,
                ),
                child: child!,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}
