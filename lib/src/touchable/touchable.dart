import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/touchable/touchable_colors.dart';
import 'package:liquid_flutter/src/touchable/touchable_status.dart';

const disabledAlpha = 200;

LdColorBundle neutralGhostColor(
  LdTheme theme,
  bool disabled,
  bool active,
  bool focus,
  bool hovering, {
  bool isOdd = false,
}) {
  final palette = theme.palette;
  final neutral = theme.palette.neutral;
  Color border = Colors.transparent;

  if (focus) {
    border = palette.primary.center(theme.isDark);
  }

  if (disabled) {
    return LdColorBundle(
      surface: theme.neutralShade(isOdd ? 2 : 1).withAlpha(23),
      text: theme.neutralShade(5),
      border: border,
      icon: palette.background.withAlpha(disabledAlpha),
    );
  }

  if (active) {
    return LdColorBundle(
      surface: Color.alphaBlend(theme.primaryColor.withAlpha(20), neutral.relative(theme.isDark, isOdd ? 3 : 2)),
      text: neutral.contrastingText(neutral.relative(theme.isDark, 2)),
      border: border,
      icon: neutral.contrastingText(neutral.relative(theme.isDark, 2)),
    );
  }

  if (hovering) {
    return LdColorBundle(
      surface: neutral.relative(theme.isDark, isOdd ? 3 : 2),
      text: neutral.contrastingText(neutral.relative(theme.isDark, 2)),
      border: border,
      icon: neutral.contrastingText(neutral.relative(theme.isDark, 2)),
    );
  }

  return LdColorBundle(
    surface: isOdd ? theme.neutralShade(2).withAlpha(100) : theme.neutralShade(1).withAlpha(0),
    text: theme.isDark ? theme.text : palette.primary.center(theme.isDark),
    border: border,
    icon: palette.primary.center(theme.isDark),
  );
}

enum LdTouchableSurfaceMode { ghost, outline, solid, neutralGhost, vague }

/// Select the appropriate color for a touchable surface
LdColorBundle touchableColor(
  LdColor color, {
  required LdTheme theme,
  LdTouchableSurfaceMode mode = LdTouchableSurfaceMode.solid,
  bool hovering = false,
  bool disabled = false,
  bool active = false,
  bool focus = false,
}) {
  if (mode == LdTouchableSurfaceMode.ghost ||
      mode == LdTouchableSurfaceMode.outline ||
      mode == LdTouchableSurfaceMode.vague) {
    if (disabled) {
      final disabledColor = color.disabled(theme.isDark);
      if (active) {
        final foreground = disabledColor.active(theme.isDark);
        return LdColorBundle(
          surface: Colors.transparent,
          text: disabledColor.contrastingText(foreground),
          border: Colors.transparent,
          icon: disabledColor.contrastingText(foreground),
        );
      } else {
        final foreground = disabledColor.idle(theme.isDark);
        if (mode == LdTouchableSurfaceMode.vague) {
          return LdColorBundle(
            surface: foreground.withAlpha(26),
            text: disabledColor.contrastingText(foreground.withAlpha(26), background: theme.background),
            border: foreground,
            icon: foreground.withAlpha(153),
          );
        }

        return LdColorBundle(
          surface: Colors.transparent,
          text: foreground,
          border: foreground,
        );
      }
    }

    if (active) {
      return LdColorBundle(
        surface: color.idle(theme.isDark).withAlpha(51),
        text: color.moveRelative(
          color.active(theme.isDark),
          theme.isDark ? -2 : 2,
        ),
        border: color.active(theme.isDark),
      );
    }

    if (hovering) {
      return LdColorBundle(
        surface: color.hover(theme.isDark).withAlpha(51),
        text: color.moveRelative(
          color.hover(theme.isDark),
          theme.isDark ? -2 : 2,
        ),
        border: color.hover(theme.isDark),
      );
    }

    if (focus) {
      return LdColorBundle(
        surface: color.focus(theme.isDark).withAlpha(51),
        text: color.focus(theme.isDark),
        border: color.focus(theme.isDark),
      );
    }

    if (mode == LdTouchableSurfaceMode.vague) {
      final surface = color.idle(theme.isDark).withAlpha(26);
      return LdColorBundle(
        surface: surface,
        text: color.contrastingText(
          surface,
          background: theme.background,
          isDark: theme.isDark,
        ),
        border: color.idle(theme.isDark),
      );
    }
    return LdColorBundle(
      surface: color.idle(theme.isDark).withAlpha(0),
      text: color.idle(theme.isDark),
      border: color.idle(theme.isDark),
    );
  }

  if (disabled) {
    final disabledColor = color.disabled(theme.isDark);
    if (active) {
      return LdColorBundle(
        surface: disabledColor.active(theme.isDark),
        text: disabledColor
            .contrastingText(
              disabledColor.active(theme.isDark),
              background: theme.background,
              isDark: theme.isDark,
            )
            .withAlpha(disabledAlpha),
        border: Colors.transparent,
      );
    }
    return LdColorBundle(
      surface: disabledColor.idle(theme.isDark),
      text: disabledColor.contrastingText(
        background: theme.background,
        disabledColor.idle(theme.isDark),
      ),
      border: Colors.transparent,
    );
  }

  if (active) {
    return LdColorBundle(
      surface: color.active(theme.isDark),
      text: color.contrastingText(
        color.active(theme.isDark),
        isDark: theme.isDark,
      ),
      border: Colors.transparent,
    );
  }

  if (focus) {
    return LdColorBundle(
      surface: color.focus(
        theme.isDark,
      ),
      text: color.contrastingText(
        color.focus(theme.isDark),
        isDark: theme.isDark,
      ),
      border: Colors.transparent,
    );
  }

  if (hovering) {
    return LdColorBundle(
      surface: color.hover(theme.isDark),
      text: color.contrastingText(
        color.hover(theme.isDark),
        isDark: theme.isDark,
      ),
      border: Colors.transparent,
    );
  }

  final surface = color.idle(theme.isDark);

  return LdColorBundle(
    surface: surface,
    text: color.contrastingText(
      surface,
      isDark: theme.isDark,
    ),
    border: Colors.transparent,
  );
}

class LdTouchableSurface extends StatefulWidget {
  final LdColor? color;
  final bool disabled;

  final bool active;

  final bool autoFocus;
  final bool isOdd;

  final LdTouchableSurfaceMode mode;

  final FocusNode? focusNode;
  final Function() onTap;
  final Widget Function(BuildContext contxt, LdColorBundle colorBundle, LdTouchableStatus status) builder;
  const LdTouchableSurface({
    super.key,
    required this.onTap,
    this.color,
    required this.builder,
    this.focusNode,
    this.active = false,
    this.mode = LdTouchableSurfaceMode.neutralGhost,
    this.disabled = false,
    this.autoFocus = false,
    this.isOdd = false,
  });

  @override
  State<LdTouchableSurface> createState() => _LdTouchableSurfaceState();
}

class _LdTouchableSurfaceState extends State<LdTouchableSurface> {
  bool _hovering = false;
  bool _pressed = false;
  bool _hasFocus = false;

  FocusNode? _focusNode;

  bool _createdFocusNode = false;

  @override
  void initState() {
    assert(widget.color != null || widget.mode == LdTouchableSurfaceMode.neutralGhost);
    _hasFocus = widget.focusNode?.hasFocus ?? false;
    _focusNode = widget.focusNode ?? FocusNode();
    _createdFocusNode = widget.focusNode == null;
    super.initState();
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Offset? _panOffset;

  bool get active => !widget.disabled && (_pressed || widget.active);

  LdColorBundle get _colorBundle {
    if (widget.mode == LdTouchableSurfaceMode.neutralGhost) {
      return neutralGhostColor(
        LdTheme.of(context),
        widget.disabled,
        active,
        _hasFocus,
        _hovering,
        isOdd: widget.isOdd,
      );
    }

    return touchableColor(
      widget.color!,
      hovering: _hovering,
      active: active,
      disabled: widget.disabled,
      mode: widget.mode,
      focus: _hasFocus,
      theme: LdTheme.of(context),
    );
  }

  @override
  void dispose() {
    if (_createdFocusNode) {
      _focusNode?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var colors = _colorBundle;
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autoFocus,
      canRequestFocus: !widget.disabled,
      onFocusChange: (value) {
        setState(() {
          _hasFocus = value;
        });
      },
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && widget.disabled == false) {
          if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.space) {
            widget.onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: TapRegion(
        onTapOutside: (details) {
          _safeSetState(() {
            _hovering = false;
            _pressed = false;

            _focusNode?.unfocus();
          });
        },
        child: Builder(builder: (context) {
          return MouseRegion(
            cursor: (widget.disabled) ? SystemMouseCursors.basic : SystemMouseCursors.click,
            onEnter: (event) {
              _safeSetState(() {
                _hovering = true;
              });
            },
            onExit: (event) {
              _safeSetState(() {
                _hovering = false;
              });
            },
            child: Listener(
              onPointerDown: (_) => _safeSetState(() {
                _pressed = true;
              }),
              onPointerUp: (_) => _safeSetState(() {
                _pressed = false;
                _focusNode?.unfocus();
              }),
              onPointerMove: (event) {
                _safeSetState(() {
                  _panOffset = event.localPosition;
                });
              },
              onPointerCancel: (_) => _safeSetState(() {
                _pressed = false;
              }),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (!widget.disabled) widget.onTap();
                  _focusNode?.unfocus();
                },
                child: widget.builder(
                  context,
                  colors,
                  LdTouchableStatus(
                    hovering: _hovering && !widget.disabled,
                    focus: _hasFocus,
                    active: !widget.disabled && (_pressed || widget.active),
                    disabled: widget.disabled,
                    pressed: _pressed,
                    panOffset: _panOffset,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
