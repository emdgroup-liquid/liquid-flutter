import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import 'touchable/touchable_colors.dart';
import 'touchable/touchable_status.dart';

part 'button.variants.g.dart';

/// Determines the mode of the button
enum LdButtonMode { filled, outline, ghost, vague }

/// A pressable button
@Variants([
  Variant('ghost', defaults: {'mode': 'LdButtonMode.ghost'}),
  Variant('vague', defaults: {'mode': 'LdButtonMode.vague'}),
  Variant('outline', defaults: {'mode': 'LdButtonMode.outline'}),
  Variant('filled', defaults: {'mode': 'LdButtonMode.filled'}),
  Variant('warning', defaults: {'color': 'LdTheme.of(context).warning'}),
  Variant('error', defaults: {'color': 'LdTheme.of(context).error'}),
  Variant('success', defaults: {'color': 'LdTheme.of(context).success'}),
])
class _LdButtonWidget extends StatefulWidget {
  final Widget child;
  final FutureOr<void> Function() onPressed;
  final bool disabled;
  final FocusNode? focusNode;
  final Widget? trailing;
  final Widget? leading;
  final bool loading;
  final LdColor? color;
  final double? width;
  final bool autoLoading;
  final double? progress;
  final bool autoFocus;
  final bool disableSqueeze;

  final LdButtonMode mode;
  final MainAxisAlignment? alignment;
  final LdSize size;
  final bool? active;
  final bool? circular;
  final BorderRadius? borderRadius;

  final String? loadingText;
  final String? errorText;

  const _LdButtonWidget({
    required this.child,
    required this.onPressed,
    @ContextConfigurable() this.autoLoading = true,
    @ContextConfigurable() this.borderRadius,
    @ContextConfigurable() this.color,
    @ContextConfigurable() this.active,
    @ContextConfigurable() this.width,
    @ContextConfigurable() this.disabled = false,
    @ContextConfigurable() this.focusNode,
    this.autoFocus = false,
    @ContextConfigurable() this.alignment,
    this.leading,
    @ContextConfigurable() this.circular,
    this.loading = false,
    this.loadingText,
    this.errorText,
    @ContextConfigurable() this.mode = LdButtonMode.filled,
    this.progress,
    @ContextConfigurable() this.size = LdSize.m,
    this.trailing,
    @ContextConfigurable() this.disableSqueeze = false,
  });

  @override
  State<_LdButtonWidget> createState() => _LdButtonState();
}

class _LdButtonState extends State<_LdButtonWidget> {
  bool _loading = false;

  bool _failed = false;

  LdException? _error;

  @override
  void initState() {
    super.initState();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(FlagProperty('_loading', value: _loading, ifTrue: 'loading'))
      ..add(FlagProperty('_failed', value: _failed, ifTrue: 'failed'))
      ..add(DiagnosticsProperty<LdException?>('_error', _error))
      ..add(DiagnosticsProperty('widget.onPressed', widget.onPressed))
      ..add(DiagnosticsProperty('widget.child', widget.child))
      ..add(StringProperty('widget.loadingText', widget.loadingText))
      ..add(StringProperty('widget.errorText', widget.errorText))
      ..add(DiagnosticsProperty('widget.leading', widget.leading))
      ..add(DiagnosticsProperty('widget.trailing', widget.trailing))
      ..add(DiagnosticsProperty('widget.autoLoading', widget.autoLoading))
      ..add(DiagnosticsProperty('widget.active', widget.active))
      ..add(DiagnosticsProperty('_circular', _circular))
      ..add(DiagnosticsProperty('widget.disabled', widget.disabled))
      ..add(DiagnosticsProperty('widget.disableSqueeze', widget.disableSqueeze))
      ..add(DiagnosticsProperty('widget.alignment', widget.alignment))
      ..add(EnumProperty('widget.mode', widget.mode))
      ..add(EnumProperty('widget.size', widget.size))
      ..add(DiagnosticsProperty('widget.color', widget.color))
      ..add(DoubleProperty('widget.width', widget.width));
  }

  // Button themes are determined using the theme provider
  LdTheme get _theme => Provider.of<LdTheme>(context, listen: true);

  Widget get _child {
    var child = widget.child;

    return Flexible(child: child);
  }

  Widget? get _trailing {
    return widget.trailing;
  }

  MainAxisAlignment get _alignment {
    if (widget.alignment != null) {
      return widget.alignment!;
    }

    final hasAddons = widget.leading != null || widget.trailing != null;

    // Center if there are addons
    return (hasAddons ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center);
  }

  bool get centerText {
    return _alignment == MainAxisAlignment.center || _alignment == MainAxisAlignment.spaceBetween;
  }

  Widget get _buttonContent {
    return Row(
      mainAxisSize: widget.width == double.infinity ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: _alignment,
      spacing: _theme.paddingSize(size: LdSize.s),
      children: [
        if (widget.leading != null) _leading!,
        _child,
        if (widget.trailing != null) _trailing!,
      ],
    );
  }

  Widget? get _leading {
    return widget.leading!;
  }

  Widget _loadingContent(LdColorBundle bundle) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
            height: _theme.paragraphSize(widget.size) / 1.5,
            width: _theme.paragraphSize(widget.size) / 1.5,
            child: CircularProgressIndicator(
              value: widget.progress ?? (ldDisableAnimations ? 0.5 : null),
              strokeWidth: 2,
              color: bundle.text,
            )),
        if (!_circular) ...[
          ldSpacerS,
          widget.loadingText != null
              ? Text(widget.loadingText!)
              : Text(
                  LiquidLocalizations.of(context).loading,
                )
        ]
      ],
    );
  }

  void _onTap() async {
    if (widget.disabled) {
      return;
    }

    if (widget.autoLoading) {
      setState(() {
        _loading = true;
        _failed = false;
        _error = null;
      });
    }
    try {
      await widget.onPressed();
    } catch (e) {
      if (widget.autoLoading && mounted) {
        setState(() {
          _loading = false;
          _failed = true;
          if (e is LdException) {
            _error = e;
          }
        });

        HapticFeedback.heavyImpact().then((value) async {
          await Future.delayed(const Duration(milliseconds: 200));
          HapticFeedback.heavyImpact();
        });
        await Future.delayed(const Duration(milliseconds: 1500));

        if (mounted) {
          setState(() {
            _failed = false;
          });
        }
      }
      rethrow;
    }
    if (widget.autoLoading && mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  void didUpdateWidget(covariant _LdButtonWidget oldWidget) {
    if (oldWidget.loading != widget.loading) {
      setState(() {
        _loading = widget.loading;
        _failed = false;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  bool get _circular {
    return widget.circular ?? (widget.child is Icon);
  }

  @override
  Widget build(BuildContext context) {
    var isLoading = widget.loading || (_loading && widget.autoLoading);

    LdColor colors;

    if (widget.color != null) {
      colors = widget.color!;
    } else {
      colors = _theme.palette.primary;
    }

    if (_failed) {
      colors = _theme.error;
    }

    return LdTouchableSurface(
      focusNode: widget.focusNode,
      hitTestBehavior: HitTestBehavior.opaque,
      autoFocus: widget.autoFocus,
      mode: switch (widget.mode) {
        (LdButtonMode.filled) => LdTouchableSurfaceMode.solid,
        (LdButtonMode.ghost) => LdTouchableSurfaceMode.ghost,
        (LdButtonMode.outline) => LdTouchableSurfaceMode.outline,
        (LdButtonMode.vague) => LdTouchableSurfaceMode.vague,
      },
      active: widget.active ?? false,
      disabled: widget.disabled || isLoading,
      onPressed: _onTap,
      color: colors,
      builder: (context, colors, status, _) => Semantics(
        button: true,
        enabled: !widget.disabled,
        focused: status.focus,
        child: _ButtonShape(
            panOffset: status.panOffset,
            colors: colors,
            status: status,
            center: centerText,
            circular: _circular,
            width: widget.width,
            disableSqueeze: widget.disableSqueeze,
            mode: widget.mode,
            borderRadius: widget.borderRadius ?? _theme.radius(LdSize.s),
            size: widget.size,
            child: AnimatedSize(
                duration: 200.ms,
                child: Stack(alignment: Alignment.center, children: [
                  AnimatedOpacity(
                    duration: const Duration(
                      milliseconds: 200,
                    ),
                    opacity: !isLoading && !_failed ? 1 : 0,
                    child: _buttonContent,
                  ),
                  LdSpring(
                    dampingCoefficient: 5,
                    position: isLoading ? 0 : 1,
                    child: isLoading ? _loadingContent(colors) : const SizedBox(),
                    builder: (context, state, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * state.position),
                        child: child,
                      );
                    },
                  ),
                  LdSpring(
                    position: _failed ? 0 : 1,
                    builder: (context, state, _) {
                      if (!_failed) {
                        return const SizedBox();
                      }

                      if (_circular) {
                        return const Icon(
                          LucideIcons.x,
                        );
                      }

                      final errorText = widget.errorText ??
                          _error?.localize(context).message ??
                          LiquidLocalizations.of(context).failed;

                      return Transform.translate(
                        offset: Offset(0, 20 * state.position),
                        child: Text(errorText),
                      );
                    },
                  ),
                ]))),
      ),
    );
  }
}

/// Build the button shape
class _ButtonShape extends StatelessWidget {
  final LdButtonMode mode;
  final LdColorBundle colors;
  final BorderRadius? borderRadius;
  final bool center;
  final LdSize size;
  final double? width;
  final bool disableSqueeze;
  final bool circular;

  final Widget child;

  final LdTouchableStatus status;

  final Offset? panOffset;

  const _ButtonShape({
    required this.mode,
    required this.size,
    required this.colors,
    required this.child,
    this.width,
    required this.status,
    required this.circular,
    required this.center,
    this.borderRadius,
    this.panOffset,
    required this.disableSqueeze,
  });

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(EnumProperty<LdButtonMode>('mode', mode))
      ..add(DiagnosticsProperty<LdColorBundle>('colors', colors))
      ..add(DiagnosticsProperty<BorderRadius?>('borderRadius', borderRadius))
      ..add(FlagProperty('center', value: center, ifTrue: 'center'))
      ..add(EnumProperty<LdSize>('size', size))
      ..add(DoubleProperty('width', width))
      ..add(FlagProperty('disableSqueeze', value: disableSqueeze, ifTrue: 'disableSqueeze'))
      ..add(FlagProperty('circular', value: circular, ifTrue: 'circular'))
      ..add(DiagnosticsProperty<Widget>('child', child))
      ..add(DiagnosticsProperty<Offset?>('panOffset', panOffset));
  }

  Border? _border(BuildContext context) {
    switch (mode) {
      case LdButtonMode.outline:
        return Border.all(
          color: colors.border,
          width: LdTheme.of(context, listen: true).borderWidth,
        );
      default:
        return null;
    }
  }

  double get _circularSizeBump {
    if (!circular) {
      return 0;
    }
    return switch (size) {
      (LdSize.xs) => 1,
      (LdSize.s) => 2,
      (LdSize.m) => 4,
      (LdSize.l) => 6,
    };
  }

  EdgeInsets _padding(BuildContext context) {
    final theme = LdTheme.of(context);

    var borderWidth = EdgeInsets.all(_border(context)?.left.width ?? 0);

    if (circular) {
      return theme.pad(size: size) - EdgeInsets.all(_circularSizeBump);
    }

    return theme.balPad(size) - borderWidth;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final panDistance = sqrt(pow(status.panOffset?.dx ?? 0, 2) + pow(status.panOffset?.dy ?? 0, 2));

    double squeezeFactor = 0;

    if (!disableSqueeze && status.pressed) {
      squeezeFactor = panDistance * 0.01 + 0.01;
    }

    return LdSpring(
      position: squeezeFactor,
      initialPosition: squeezeFactor,
      builder: (context, state, child) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scaleByDouble(
              min(0.05, state.position * 0.01) + 1,
              min(0.05, state.position * 0.01) + 1,
              1.0,
              1.0,
            ),
          child: Container(
            clipBehavior: Clip.hardEdge,
            key: const Key('ldButton_shape'),
            width: width,
            decoration: BoxDecoration(
              color: colors.surface,
              border: _border(context),
              borderRadius: circular ? null : borderRadius,
              boxShadow: [
                if (status.pressed)
                  BoxShadow(
                    color: colors.surface.withAlpha(100),
                    blurRadius: max(0, state.position * 10),
                    offset: const Offset(0, 0),
                  ),
              ],
              shape: circular ? BoxShape.circle : BoxShape.rectangle,
            ),
            child: child,
          ),
        );
      },
      child: Stack(
        children: [
          Padding(
            padding: _padding(context),
            child: DefaultTextStyle(
              textAlign: center ? TextAlign.center : null,
              maxLines: 1,
              style: TextStyle(
                color: colors.text,
                package: theme.fontFamilyPackage,
                fontFamily: theme.fontFamily,
                fontSize: theme.labelSize(size),
                height: 1,
                fontWeight: FontWeight.bold,
              ),
              child: IconTheme(
                data: IconThemeData(
                  color: colors.text,
                  size: theme.labelSize(size) + _circularSizeBump,
                ),
                child: child,
              ),
            ),
          ),
          if (panOffset != null && status.pressed)
            Positioned(
              left: panOffset!.dx - 64,
              top: panOffset!.dy - 64,
              child: Container(
                key: const Key('ldButton_ripple'),
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    radius: 0.5,
                    colors: [
                      Colors.white.withAlpha(150),
                      Colors.white.withAlpha(0),
                    ],
                    stops: const [0, 1],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
