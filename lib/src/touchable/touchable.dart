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
  bool hovering,
) {
  final palette = theme.palette;
  final neutral = theme.palette.neutral;

  if (disabled) {
    return LdColorBundle(
      surface: theme.neutralShade(1).withAlpha(23),
      text: theme.neutralShade(5),
      border: Colors.transparent,
      icon: palette.background.withAlpha(disabledAlpha),
    );
  }
  if (active) {
    return LdColorBundle(
      surface: neutral.relative(theme.isDark, 2),
      text: neutral.contrastingText(neutral.relative(theme.isDark, 2)),
      border: Colors.transparent,
      icon: neutral.contrastingText(neutral.relative(theme.isDark, 2)),
    );
  }

  if (hovering) {
    return LdColorBundle(
      surface: neutral.relative(theme.isDark, 2),
      text: neutral.contrastingText(neutral.relative(theme.isDark, 2)),
      border: Colors.transparent,
      icon: neutral.contrastingText(neutral.relative(theme.isDark, 2)),
    );
  }

  if (focus) {
    return LdColorBundle(
      surface: theme.neutralShade(3),
      text: palette.neutral.focus(theme.isDark),
      border: Colors.transparent,
      icon: palette.neutral.focus(theme.isDark),
    );
  }

  return LdColorBundle(
    surface: theme.neutralShade(1).withAlpha(0),
    text: theme.isDark ? theme.text : palette.primary.center(theme.isDark),
    border: Colors.transparent,
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
            text: disabledColor.contrastingText(foreground),
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
      return LdColorBundle(
        surface: color.idle(theme.isDark).withAlpha(26),
        text: color.idle(theme.isDark),
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
        text: disabledColor.contrastingText(disabledColor.active(theme.isDark)),
        border: Colors.transparent,
      );
    }
    return LdColorBundle(
      surface: disabledColor.idle(theme.isDark),
      text: disabledColor.contrastingText(disabledColor.idle(theme.isDark)),
      border: Colors.transparent,
    );
  }

  if (active) {
    return LdColorBundle(
      surface: color.active(theme.isDark),
      text: color.contrastingText(color.active(theme.isDark)),
      border: Colors.transparent,
    );
  }

  if (focus) {
    return LdColorBundle(
      surface: color.focus(theme.isDark),
      text: color.contrastingText(color.focus(theme.isDark)),
      border: Colors.transparent,
    );
  }

  if (hovering) {
    return LdColorBundle(
      surface: color.hover(theme.isDark),
      text: color.contrastingText(color.hover(theme.isDark)),
      border: Colors.transparent,
    );
  }

  return LdColorBundle(
    surface: color.idle(theme.isDark),
    text: color.contrastingText(color.idle(theme.isDark)),
    border: Colors.transparent,
  );
}

class LdTouchableSurface extends StatefulWidget {
  final LdColor? color;
  final bool disabled;

  final bool active;

  final LdTouchableSurfaceMode mode;

  final FocusNode? focusNode;
  final Function() onTap;
  final Widget Function(BuildContext contxt, LdColorBundle colorBundle,
      LdTouchableStatus status) builder;
  const LdTouchableSurface({
    super.key,
    required this.onTap,
    this.color,
    required this.builder,
    this.focusNode,
    this.active = false,
    this.mode = LdTouchableSurfaceMode.neutralGhost,
    this.disabled = false,
  });

  @override
  State<LdTouchableSurface> createState() => _LdTouchableSurfaceState();
}

class _LdTouchableSurfaceState extends State<LdTouchableSurface> {
  bool _hovering = false;
  bool _pressed = false;
  bool _hasFocus = false;

  @override
  void initState() {
    assert(widget.color != null ||
        widget.mode == LdTouchableSurfaceMode.neutralGhost);
    _hasFocus = widget.focusNode?.hasFocus ?? false;
    super.initState();
  }

  bool get active => !widget.disabled && (_pressed || widget.active);

  LdColorBundle get _colorBundle {
    if (widget.mode == LdTouchableSurfaceMode.neutralGhost) {
      return neutralGhostColor(
        LdTheme.of(context),
        widget.disabled,
        active,
        _hasFocus,
        _hovering,
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
  Widget build(BuildContext context) {
    var colors = _colorBundle;
    return Focus(
      focusNode: widget.focusNode,
      canRequestFocus: !widget.disabled,
      onFocusChange: (value) {
        setState(() {
          _hasFocus = value;
        });
      },
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && widget.disabled == false) {
          if (event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            widget.onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Builder(builder: (context) {
        return MouseRegion(
          cursor: (widget.disabled)
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          onEnter: (event) {
            setState(() {
              _hovering = true;
            });
          },
          onExit: (event) {
            setState(() {
              _hovering = false;
            });
          },
          child: Listener(
            onPointerDown: (_) => setState(() {
              _pressed = true;
            }),
            onPointerUp: (_) => setState(() {
              _pressed = false;
            }),
            onPointerCancel: (_) => setState(() {
              _pressed = false;
            }),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (!widget.disabled) widget.onTap();
              },
              child: widget.builder(
                context,
                colors,
                LdTouchableStatus(
                  hovering: _hovering && !widget.disabled,
                  focus: _hasFocus,
                  active: !widget.disabled && (_pressed || widget.active),
                  disabled: widget.disabled,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
