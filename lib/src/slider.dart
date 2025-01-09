import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/form_label.dart';

class LdSlider extends StatefulWidget {
  final VoidCallback onSlideComplete;

  final String? hint;
  final String? label;
  final bool disabled;

  const LdSlider(
      {super.key,
      required this.onSlideComplete,
      this.hint,
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

  late AnimationController _controller;
  late AnimationController _opacityController;
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
    _controller.dispose();
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
      _controller.value = 0;
      _value = 0;
      return;
    }
    setState(() {
      _value = (details.localPosition.dx - 48 / 2) / _max;
      _controller.value = _value;
      /*if (_value > _threshold && !_reached) {
        HapticFeedback.heavyImpact();
        _reached = true;
        widget.onSlideComplete();
      }*/
    });
  }

  _onDragEnd(DragEndDetails details) async {
    if (widget.disabled) {
      return;
    }
    if (_value > _threshold) {
      HapticFeedback.mediumImpact();
      widget.onSlideComplete();
      await _controller.animateTo(1);
      await Future.delayed(const Duration(milliseconds: 300));
      await _opacityController.animateTo(0,
          duration: const Duration(milliseconds: 300));

      _controller.value = 0.0;
      _opacityController.animateTo(1);
    } else {
      _controller.animateTo(0);
    }
    setState(() {
      _value = 0;

      _sliding = false;
    });
  }

  bool get reachedThreshold => _value > _threshold;

  Color activeColor(LdTheme theme) => theme.palette.primary.active(
        theme.isDark,
      );

  Widget buildThumb(LdTheme theme, BoxConstraints constraints) {
    Color iconColor = theme.neutralShade(5);
    Color borderColor = theme.border;
    Color thumbColor = theme.neutralShade(2);

    if (reachedThreshold) {
      iconColor = activeColor(theme);
      borderColor = activeColor(theme);
    } else if (_sliding) {
      thumbColor = theme.neutralShade(4);
    }

    if (widget.disabled) {
      thumbColor = theme.neutralShade(2);
      iconColor = theme.neutralShade(3);
    }

    return Positioned(
      left: _controller.value * (constraints.maxWidth - 60) + 4,
      top: 4,
      child: Opacity(
        opacity: _opacityController.value,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_forward, size: 24, color: iconColor),
          decoration: BoxDecoration(
            color: thumbColor,
            border: Border.all(
              color: borderColor,
              width: 2,
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
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(
                  color: reachedThreshold
                      ? theme.palette.primary.active(theme.isDark)
                      : theme.border,
                  width: 2,
                ),
                color: theme.background,
                borderRadius: theme.radius(LdSize.m),
              ),
              child: GestureDetector(
                onHorizontalDragStart: (details) =>
                    _onDragStart(details, constraints),
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: AnimatedBuilder(
                  animation: _opacityController,
                  builder: (context, child) {
                    return AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Stack(
                          children: [
                            if (widget.hint != null)
                              Center(
                                child: Opacity(
                                  child: Text(widget.hint!),
                                  opacity: widget.disabled
                                      ? 0.2
                                      : 1 - _controller.value,
                                ),
                              ),
                            buildThumb(theme, constraints)
                          ],
                        );
                      },
                    );
                  },
                ),
              )),
        ),
      ],
    );
  }
}
