import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:provider/provider.dart';

import 'touchable/touchable_colors.dart';
import 'touchable/touchable_status.dart';

/// Determines the mode of the button
enum LdButtonMode { filled, outline, ghost, vague }

/// A pressable button
class LdButton extends StatefulWidget {
  final Widget child;
  final Function onPressed;
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

  final LdButtonMode mode;
  final MainAxisAlignment? alignment;
  final LdSize size;
  final bool? active;
  final bool? circular;
  final BorderRadius? borderRadius;

  final String? loadingText;
  final String? errorText;

  const LdButton({
    required this.child,
    required this.onPressed,
    this.autoLoading = true,
    this.borderRadius,
    this.color,
    this.active,
    this.width,
    this.disabled = false,
    this.focusNode,
    this.autoFocus = false,
    this.alignment,
    this.leading,
    this.circular,
    this.loading = false,
    this.loadingText,
    this.errorText,
    this.mode = LdButtonMode.filled,
    this.progress,
    this.size = LdSize.m,
    this.trailing,
    Key? key,
  }) : super(key: key);

  @override
  State<LdButton> createState() => _LdButtonState();
}

class _LdButtonState extends State<LdButton> {
  bool _loading = false;

  bool _failed = false;

  LdException? _error;

  @override
  void initState() {
    super.initState();
  }

  // Button themes are determined using the theme provider
  LdTheme get _theme => Provider.of<LdTheme>(context, listen: true);

  Widget get _child {
    var child = widget.child;

    return Flexible(child: child);
  }

  Widget get _trailing {
    if (widget.trailing == null) {
      return Container();
    }
    return Padding(
        padding: const EdgeInsets.only(left: 8.0), child: widget.trailing);
  }

  MainAxisAlignment get _alignment {
    if (widget.alignment != null) {
      return widget.alignment!;
    }

    final hasAddons = widget.leading != null || widget.trailing != null;

    // Center if there are addons
    return (hasAddons
        ? MainAxisAlignment.spaceBetween
        : MainAxisAlignment.center);
  }

  bool get centerText {
    return _alignment == MainAxisAlignment.center ||
        _alignment == MainAxisAlignment.spaceBetween;
  }

  Widget get _buttonContent {
    return Row(
      mainAxisSize:
          widget.width == double.infinity ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: _alignment,
      children: [_leading, _child, _trailing],
    );
  }

  Widget get _leading {
    if (widget.leading == null) {
      return const SizedBox();
    }
    return Padding(
        padding: const EdgeInsets.only(right: 8.0), child: widget.leading!);
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
  void didUpdateWidget(covariant LdButton oldWidget) {
    if (oldWidget.loading != widget.loading) {
      setState(() {
        _loading = widget.loading;
        _failed = false;
      });
    }

    super.didUpdateWidget(oldWidget);
  }

  bool get _circular {
    return widget.circular == true ||
        (widget.child is Icon && widget.circular == null);
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
      autoFocus: widget.autoFocus,
      mode: switch (widget.mode) {
        (LdButtonMode.filled) => LdTouchableSurfaceMode.solid,
        (LdButtonMode.ghost) => LdTouchableSurfaceMode.ghost,
        (LdButtonMode.outline) => LdTouchableSurfaceMode.outline,
        (LdButtonMode.vague) => LdTouchableSurfaceMode.vague,
      },
      active: widget.active ?? false,
      disabled: widget.disabled || isLoading,
      onTap: _onTap,
      color: colors,
      builder: (context, colors, status) => Opacity(
        opacity: widget.disabled ? 0.5 : 1,
        child: Semantics(
          button: true,
          enabled: !widget.disabled,
          focused: status.focus,
          child: _ButtonShape(
              colors: colors,
              status: status,
              center: centerText,
              circular: _circular,
              width: widget.width,
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
                        child: _buttonContent),
                    LdSpring(
                      dampingCoefficient: 5,
                      position: isLoading ? 0 : 1,
                      builder: (context, state) {
                        return Transform.translate(
                          offset: Offset(0, 20 * state.position),
                          child: isLoading
                              ? _loadingContent(
                                  colors,
                                )
                              : const SizedBox(),
                        );
                      },
                    ),
                    LdSpring(
                      position: _failed ? 0 : 1,
                      builder: (context, state) {
                        if (!_failed) {
                          return const SizedBox();
                        }

                        if (_circular) {
                          return const Icon(
                            LucideIcons.x,
                          );
                        }

                        final errorText = widget.errorText ??
                            _error?.message ??
                            LiquidLocalizations.of(context).failed;

                        return Transform.translate(
                          offset: Offset(0, 20 * state.position),
                          child: Text(errorText),
                        );
                      },
                    ),
                  ]))),
        ),
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

  final bool circular;

  final Widget child;

  final LdTouchableStatus status;

  const _ButtonShape(
      {required this.mode,
      required this.size,
      required this.colors,
      required this.child,
      this.width,
      required this.status,
      required this.circular,
      required this.center,
      this.borderRadius});

  Border? _border(context) {
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

  EdgeInsets _padding(BuildContext context) {
    final theme = LdTheme.of(context);

    var borderWidth = EdgeInsets.all(_border(context)?.left.width ?? 0);

    if (circular) {
      EdgeInsets.zero;
    }

    return theme.balPad(size) - borderWidth;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    return Container(
      clipBehavior: Clip.hardEdge,
      width: width,
      padding: _padding(context),
      decoration: BoxDecoration(
        color: colors.surface,
        border: _border(context),
        borderRadius: circular ? null : borderRadius,
        shape: circular ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: DefaultTextStyle(
        textAlign: center ? TextAlign.center : null,
        style: TextStyle(
          color: colors.text,
          package: theme.fontFamilyPackage,
          fontFamily: theme.fontFamily,
          fontSize: theme.labelSize(size),
          height: 1,
          fontWeight: FontWeight.bold,
        ),
        child: IconTheme(
          child: child,
          data: IconThemeData(
            color: colors.text,
            size:
                circular ? theme.labelSize(size) * 1.5 : theme.labelSize(size),
          ),
        ),
      ),
    );
  }
}
