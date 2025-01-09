import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/form_label.dart';
import 'package:provider/provider.dart';

// a switch that can be turned on and off
class LdToggle extends StatefulWidget {
  final String? label;
  final bool checked;
  final LdSize size;

  final bool disabled;
  final Function(bool)? onChanged;
  final LdColor? color;
  const LdToggle(
      {this.label,
      required this.checked,
      this.size = LdSize.m,
      this.onChanged,
      this.color,
      this.disabled = false,
      Key? key})
      : super(key: key);

  @override
  State<LdToggle> createState() => _LdToggleState();
}

class _LdToggleState extends State<LdToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _updateStatus();
    super.initState();
  }

  LdTheme get _theme => Provider.of<LdTheme>(context, listen: false);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(oldWidget) {
    if (mounted) {
      _updateStatus();
    }

    super.didUpdateWidget(oldWidget);
  }

  void _updateStatus() {
    {
      if (widget.checked) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  void _onTap() {
    if (widget.onChanged != null) {
      HapticFeedback.selectionClick();
      widget.onChanged!(!widget.checked);
    }
  }

  double get _thumbSize {
    double size;
    switch (LdTheme.of(context, listen: true).themeSize) {
      case LdThemeSize.l:
        size = 20;
        break;
      case LdThemeSize.m:
        size = 16;
        break;
      case LdThemeSize.s:
        size = 12;
        break;
    }
    switch (widget.size) {
      case LdSize.l:
        return size * 1.5;
      case LdSize.m:
        return size;
      case LdSize.s:
        return size * 0.75;
      case LdSize.xs:
        return size * 0.5;
    }
  }

  double get _gap {
    switch (widget.size) {
      case LdSize.l:
        return 4;
      case LdSize.m:
        return 2.5;
      case LdSize.s:
      case LdSize.xs:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.color ?? _theme.palette.primary;

    final label = LdFormLabel(
      label: widget.label,
      size: widget.size,
      direction: Axis.horizontal,
    );

    return LdTouchableSurface(
        color: _theme.palette.neutral,
        mode: LdTouchableSurfaceMode.solid,
        onTap: _onTap,
        disabled: widget.disabled,
        active: widget.checked,
        builder: (contxt, colorBundle, status) {
          final thumbColor = switch ((widget.checked, status.hovering)) {
            (true, true) => colors.contrastingText(colors.idle(_theme.isDark)),
            (true, false) => colors.contrastingText(colors.idle(_theme.isDark)),
            (false, true) => _theme.neutralShade(4),
            (false, false) => _theme.neutralShade(7),
          };

          final background = switch ((widget.checked, status.hovering)) {
            (true, true) => colors.idle(_theme.isDark),
            (true, false) => colors.hover(_theme.isDark),
            (false, true) => _theme.neutralShade(5),
            (false, false) => _theme.neutralShade(4),
          };

          return Semantics(
            toggled: widget.checked,
            focusable: !widget.disabled,
            label: widget.label,
            enabled: !widget.disabled,
            onTap: _onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(_gap),
                  height: _thumbSize + 2 * _gap,
                  clipBehavior: Clip.hardEdge,
                  width: _thumbSize * 2 + 2 * _gap,
                  child: Row(children: [
                    LdSpring(
                      springConstant: 20,
                      dampingCoefficient: 20,
                      position: widget.checked ? _thumbSize : 0,
                      initialPosition: widget.checked ? _thumbSize : 0,
                      builder: (context, state) => Transform.translate(
                          offset: Offset(state.position, 0),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            decoration: BoxDecoration(
                              color: thumbColor,
                              shape: BoxShape.circle,
                            ),
                            height: _thumbSize,
                            width: _thumbSize +
                                (2 * state.velocity).clamp(0, _gap),
                          )),
                    ),
                  ]),
                  decoration: BoxDecoration(
                    color: background,
                    borderRadius: BorderRadius.circular(
                      (_thumbSize + 2 * _gap) / 2,
                    ),
                  ),
                ),
                Flexible(child: label),
              ],
            ),
          );
        });
  }
}
