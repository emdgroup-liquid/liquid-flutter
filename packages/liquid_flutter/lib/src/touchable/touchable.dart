import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

const disabledAlpha = 200;

enum LdTouchableSurfaceMode { ghost, outline, solid, neutralGhost, vague, input }

class LdTouchableSurface extends StatefulWidget {
  final bool disabled;
  final HitTestBehavior hitTestBehavior;

  final bool active;

  final bool autoFocus;
  final bool isOdd;

  final FocusNode? focusNode;
  final Function() onPressed;
  final bool allowTapOutside;

  /// When true, uses [TextFieldTapRegion] so taps on text selection handles and
  /// toolbars do not trigger [onTapOutside] / unfocus (same group as [TextField]).
  final bool textFieldTapRegion;

  final Widget? child;
  final Set<LogicalKeyboardKey>? onPressedKeys;

  final void Function(bool isHovering)? onHover;

  final Widget Function(
    BuildContext contxt,
    LdTouchableStatus status,
    Widget? child,
  ) builder;
  const LdTouchableSurface({
    super.key,
    required this.onPressed,
    this.hitTestBehavior = HitTestBehavior.opaque,
    this.onHover,
    required this.builder,
    this.allowTapOutside = false,
    this.textFieldTapRegion = false,
    this.focusNode,
    this.active = false,
    this.disabled = false,
    this.autoFocus = false,
    this.onPressedKeys,
    this.isOdd = false,
    this.child,
  });

  @override
  State<LdTouchableSurface> createState() => _LdTouchableSurfaceState();
}

class _LdTouchableSurfaceState extends State<LdTouchableSurface> {
  bool _isHovering = false;
  bool _pressed = false;
  bool _hasFocus = false;

  set _hovering(bool value) {
    if (widget.onHover != null) {
      widget.onHover!(value);
    }

    _isHovering = value;
  }

  bool get _hovering => _isHovering;

  final _listenerKey = GlobalKey();
  FocusNode? _focusNode;
  Offset? _pointerDownOffset;

  bool _createdFocusNode = false;

  Set<LogicalKeyboardKey> get _onPressedKeys =>
      widget.onPressedKeys ?? {LogicalKeyboardKey.enter, LogicalKeyboardKey.space};

  @override
  void initState() {
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

  @override
  void dispose() {
    if (_createdFocusNode) {
      _focusNode?.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LdTouchableSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode == widget.focusNode) {
      return;
    }

    final hadFocus = _focusNode?.hasFocus ?? false;

    if (_createdFocusNode) {
      _focusNode?.dispose();
    }

    _focusNode = widget.focusNode ?? FocusNode();
    _createdFocusNode = widget.focusNode == null;
    _hasFocus = _focusNode?.hasFocus ?? false;

    if (hadFocus) {
      _focusNode?.requestFocus();
    }
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
      onSurface: LdSurfaceInfo.of(context, listen: true).isSurface,
      panOffset: _panOffset,
    );

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
          if (_onPressedKeys.contains(event.logicalKey)) {
            widget.onPressed();
            return KeyEventResult.handled;
          }
        }

        return KeyEventResult.ignored;
      },
      child: _TapRegionWrapper(
        textFieldTapRegion: widget.textFieldTapRegion,
        onTapOutside: (details) {
          if (widget.allowTapOutside) {
            return;
          }
          _safeSetState(() {
            _hovering = false;
            _pressed = false;
            if (_hasFocus) {
              _focusNode?.unfocus();
            }
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
            child: GestureDetector(
              key: _listenerKey,
              behavior: widget.hitTestBehavior,
              onTapDown: (d) => _safeSetState(() {
                if (!widget.disabled) {
                  if (widget.focusNode != null) {
                    _focusNode?.requestFocus();
                  }
                  _safeSetState(() {
                    _pressed = true;
                    _pointerDownOffset = d.localPosition;
                  });
                }
              }),
              onTapUp: (details) => _safeSetState(() {
                _safeSetState(() {
                  _pressed = false;
                });
              }),
              onTap: () {
                if (widget.disabled) {
                  return;
                }

                widget.onPressed();
              },
              onPanUpdate: (event) {
                if (_pressed) {
                  _safeSetState(() {
                    _panOffset = event.localPosition;
                  });
                }
              },
              onPanEnd: (_) {
                if (_pressed) {
                  _safeSetState(() {
                    _pressed = false;
                  });
                }
              },
              child: Provider.value(
                value: status,
                child: widget.builder(context, status, widget.child),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _TapRegionWrapper extends StatelessWidget {
  const _TapRegionWrapper({
    required this.textFieldTapRegion,
    required this.onTapOutside,
    required this.child,
  });

  final bool textFieldTapRegion;
  final TapRegionCallback onTapOutside;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (textFieldTapRegion) {
      return TextFieldTapRegion(
        onTapOutside: onTapOutside,
        child: child,
      );
    }
    return TapRegion(
      onTapOutside: onTapOutside,
      child: child,
    );
  }
}

class LdTouchableTouchFeedback extends StatelessWidget {
  final Widget child;
  final LdTouchableStatus status;
  final double scaleFactor;
  const LdTouchableTouchFeedback({super.key, required this.child, required this.status, this.scaleFactor = 1.0});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return LdSpring(
        springConstant: 10,
        dampingCoefficient: 5,
        initialPosition: status.pressed ? 1 : 0,
        position: status.pressed ? 1 : 0,
        builder: (context, state, child) {
          double squeezeFactor = (status.panOffset?.dx.abs() ?? 0) * 0.00001 * scaleFactor * state.position;

          final scale = 1 + squeezeFactor;

          return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..scaleByDouble(
                  scale,
                  scale,
                  1.0,
                  1.0,
                ),
              child: child);
        },
        child: child,
      );
    });
  }
}
