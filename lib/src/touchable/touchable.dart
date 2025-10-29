import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/touchable/ghost_color.dart';
import 'package:liquid_flutter/src/touchable/input_color.dart';
import 'package:liquid_flutter/src/touchable/neutral_ghost_color.dart';
import 'package:liquid_flutter/src/touchable/outline_color.dart';
import 'package:liquid_flutter/src/touchable/solid_color.dart';
import 'package:liquid_flutter/src/touchable/touchable_colors.dart';
import 'package:liquid_flutter/src/touchable/touchable_status.dart';
import 'package:liquid_flutter/src/touchable/vague_color.dart';

const disabledAlpha = 200;

enum LdTouchableSurfaceMode { ghost, outline, solid, neutralGhost, vague, input }

/// Select the appropriate color for a touchable surface
LdColorBundle touchableColor(
  LdColor color,
  LdTheme theme,
  LdTouchableStatus status, {
  LdTouchableSurfaceMode mode = LdTouchableSurfaceMode.solid,
}) {
  return switch (mode) {
    LdTouchableSurfaceMode.ghost => ghostColor(color, theme, status),
    LdTouchableSurfaceMode.outline => outlineColor(color, theme, status),
    LdTouchableSurfaceMode.vague => vagueColor(color, theme, status),
    LdTouchableSurfaceMode.solid => solidColor(color, theme, status),
    LdTouchableSurfaceMode.input => inputColor(theme, status, isValid: true),
    LdTouchableSurfaceMode.neutralGhost => neutralGhostColor(theme, status),
  };
}

class LdTouchableSurface extends StatefulWidget {
  final LdColor? color;
  final bool disabled;

  final bool active;

  final bool autoFocus;
  final bool isOdd;

  final LdTouchableSurfaceMode mode;

  final FocusNode? focusNode;
  final Function() onPressed;
  final bool isInput;
  final bool allowTapOutside;

  final Widget Function(BuildContext contxt, LdColorBundle colorBundle, LdTouchableStatus status) builder;
  const LdTouchableSurface({
    super.key,
    required this.onPressed,
    this.color,
    required this.builder,
    this.allowTapOutside = false,
    this.focusNode,
    this.active = false,
    this.isInput = false,
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

  final _listenerKey = GlobalKey();
  FocusNode? _focusNode;

  bool _createdFocusNode = false;

  @override
  void initState() {
    assert(widget.color != null ||
        widget.mode == LdTouchableSurfaceMode.neutralGhost ||
        widget.mode == LdTouchableSurfaceMode.input);
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

  LdColorBundle _colorBundle(LdTouchableStatus status) {
    if (widget.mode == LdTouchableSurfaceMode.neutralGhost) {
      return neutralGhostColor(
        LdTheme.of(context),
        status,
      );
    }

    if (widget.mode == LdTouchableSurfaceMode.input) {
      return inputColor(
        LdTheme.of(context),
        status,
        isValid: true, // This could be made configurable if needed
        onSurface: false, // This could be made configurable if needed
      );
    }

    return touchableColor(
      widget.color!,
      LdTheme.of(context),
      status,
      mode: widget.mode,
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
    final status = LdTouchableStatus(
      hovering: _hovering && !widget.disabled,
      focus: _hasFocus,
      active: !widget.disabled && (_pressed || widget.active),
      disabled: widget.disabled,
      pressed: _pressed,
      isOdd: widget.isOdd,
      onSurface: LdSurfaceInfo.of(context).isSurface,
      panOffset: _panOffset,
    );

    var colors = _colorBundle(status);

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
        if (event is KeyDownEvent && widget.disabled == false && !widget.isInput) {
          if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.space) {
            widget.onPressed();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: TapRegion(
        onTapOutside: (details) {
          if (widget.allowTapOutside) {
            return;
          }
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
              key: _listenerKey,
              onPointerDown: (_) => _safeSetState(() {
                _pressed = true;
              }),
              onPointerUp: (details) => _safeSetState(() {
                _pressed = false;

                final listenerBox = _listenerKey.currentContext?.findRenderObject() as RenderBox?;
                final size = listenerBox?.size ?? Size.zero;
                if (details.localPosition.dx > 0 &&
                    details.localPosition.dx < size.width &&
                    details.localPosition.dy > 0 &&
                    details.localPosition.dy < size.height) {
                  if (!widget.disabled) widget.onPressed();
                  _focusNode?.unfocus();
                }
              }),
              onPointerMove: (event) {
                _safeSetState(() {
                  _panOffset = event.localPosition;
                });
              },
              onPointerCancel: (_) => _safeSetState(() {
                _pressed = false;
              }),
              child: widget.builder(
                context,
                colors,
                status,
              ),
            ),
          );
        }),
      ),
    );
  }
}

class LdTouchableTouchFeedback extends StatelessWidget {
  final Widget child;
  final LdTouchableStatus status;
  const LdTouchableTouchFeedback({super.key, required this.child, required this.status});

  @override
  Widget build(BuildContext context) {
    return LdSpring(
      springConstant: 20,
      dampingCoefficient: 5,
      initialPosition: status.pressed ? 0.1 : 0,
      position: status.pressed ? 0.1 : 0,
      builder: (context, state, child) {
        return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..scale(
                state.position * 0.01 + 1 + min(0.2, (status.panOffset?.dx.abs() ?? 0) * 0.001 * state.position),
                state.position * 0.01 + 1 + min(0.2, (status.panOffset?.dy.abs() ?? 0) * 0.001 * state.position),
                1.0,
              ),
            child: child);
      },
      child: child,
    );
  }
}
