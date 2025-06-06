import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:haptic_feedback/haptic_feedback.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/form_label.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdSlider extends StatefulWidget {
  final VoidCallback onSlideComplete;

  final LdColor? color;

  final String? hint;
  final String? label;
  final bool disabled;

  const LdSlider(
      {super.key,
      required this.onSlideComplete,
      this.hint,
      this.color,
      this.label,
      this.disabled = false});

  @override
  State<LdSlider> createState() => _LdSliderState();
}

class _LdSliderState extends State<LdSlider> with TickerProviderStateMixin {
  double _value = 0;
  double _max = 0;
  final double _threshold = 0.8;
  bool _sliding = false;

  AnimationController? _controller;
  AnimationController? _opacityController;
  @override
  initState() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    _opacityController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200), value: 1);

    super.initState();
  }

  @override
  dispose() {
    _controller?.dispose();
    _opacityController?.dispose();
    _controller = null;
    _opacityController = null;
    super.dispose();
  }

  _onDragStart(DragStartDetails details, BoxConstraints constraints) {
    if (widget.disabled) {
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() {
      _max = constraints.maxWidth;
      _sliding = true;
    });
  }

  _onDragUpdate(DragUpdateDetails details) {
    if (widget.disabled) {
      _controller?.value = 0;
      _value = 0;
      return;
    }
    setState(() {
      _value = (details.localPosition.dx - 48 / 2) / _max;

      _controller?.value = _value;

      if (_value > _threshold) {
        LdHaptics.vibrate(HapticsType.rigid);
      } else {
        LdHaptics.vibrate(HapticsType.soft);
      }
    });
  }

  _onDragEnd(DragEndDetails details) async {
    if (widget.disabled) {
      return;
    }
    if (_value > _threshold) {
      LdHaptics.vibrate(HapticsType.heavy);
      widget.onSlideComplete();

      await _controller?.animateTo(1);
      await Future.delayed(const Duration(milliseconds: 300));
      await _opacityController?.animateTo(0,
          duration: const Duration(milliseconds: 300));

      _controller?.value = 0.0;
      _opacityController?.animateTo(1);
    } else {
      _controller?.animateTo(0);
    }

    if (mounted) {
      setState(() {
        _value = 0;
        _sliding = false;
      });
    }
  }

  bool get _reachedThreshold => _value > _threshold;

  double get _thumbSize => 40;
  double get _thumbPadding => 4;

  Color _activeColor(LdTheme theme) =>
      (widget.color ?? theme.palette.primary).active(
        theme.isDark,
      );

  Color _borderColor(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    if (_reachedThreshold) {
      return _activeColor(theme);
    }
    return theme.border;
  }

  Widget _buildThumb(LdTheme theme, BoxConstraints constraints) {
    Color iconColor =
        (widget.color ?? theme.palette.primary).idle(theme.isDark);
    Color borderColor = theme.border;
    Color thumbColor = theme.neutralShade(2);

    if (_reachedThreshold) {
      iconColor = _activeColor(theme);
      borderColor = _activeColor(theme);
    } else if (_sliding) {
      thumbColor = theme.neutralShade(4);
    }

    if (widget.disabled) {
      thumbColor = theme.neutralShade(2);
      iconColor = theme.neutralShade(3);
    }

    final slideValue = _controller?.value ?? 0;
    final opacityValue = _opacityController?.value ?? 1;

    final availableWidth = constraints.maxWidth -
        _thumbSize -
        _thumbPadding * 2 -
        theme.borderWidth * 2;

    return Positioned(
      left: slideValue * availableWidth + _thumbPadding,
      top: _thumbPadding,
      child: Opacity(
        opacity: opacityValue,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: _thumbSize,
          height: _thumbSize,
          child: Icon(LucideIcons.arrowRight, size: 24, color: iconColor),
          decoration: BoxDecoration(
            color: thumbColor,
            border: Border.all(
              color: borderColor,
              width: theme.borderWidth,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            borderRadius: BorderRadius.circular(
              theme.sizingConfig.radiusM - 3,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = LdTheme.of(context, listen: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LdFormLabel(
          label: widget.label,
          size: LdSize.m,
          disabled: widget.disabled,
        ),
        LayoutBuilder(
          builder: (context, constraints) => Container(
            height: _thumbSize + _thumbPadding * 2 + theme.borderWidth * 2,
            decoration: BoxDecoration(
              border: Border.all(
                color: _borderColor(context),
                width: theme.borderWidth,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
              borderRadius: theme.radius(LdSize.m),
            ),
            child: LdAutoBackground(
                borderRadius: theme.radius(LdSize.m),
                child: GestureDetector(
                  onHorizontalDragStart: (details) =>
                      _onDragStart(details, constraints),
                  onHorizontalDragUpdate: _onDragUpdate,
                  onHorizontalDragEnd: _onDragEnd,
                  child: AnimatedBuilder(
                    animation: _opacityController!,
                    builder: (context, child) {
                      return AnimatedBuilder(
                        animation: _controller!,
                        builder: (context, child) {
                          return Stack(
                            children: [
                              if (widget.hint != null)
                                Center(
                                  child: Opacity(
                                    child: LdMute(child: LdTextL(widget.hint!)),
                                    opacity: widget.disabled
                                        ? 0.2
                                        : 1 - _controller!.value,
                                  ),
                                ),
                              _buildThumb(theme, constraints)
                            ],
                          );
                        },
                      );
                    },
                  ),
                )),
          ),
        ),
      ],
    );
  }
}
