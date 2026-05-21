import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/form_label.dart';
import 'package:liquid_flutter/src/haptics.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

// ---------------------------------------------------------------------------
// Geometry helpers
// ---------------------------------------------------------------------------

double _snapToStep(double value, double min, double max, double step) {
  if (step == 0) return value;
  final snapped = (value / step).round() * step;
  return snapped.clamp(min, max);
}

double _valueToFraction(double value, double min, double max) {
  if (max == min) return 0.0;
  return ((value - min) / (max - min)).clamp(0.0, 1.0);
}

double _fractionToValue(double fraction, double min, double max) {
  return min + fraction * (max - min);
}

// ---------------------------------------------------------------------------
// _LdSliderHandle
// ---------------------------------------------------------------------------

class _LdSliderHandle extends StatefulWidget {
  final double fraction;
  final bool isDragging;
  final bool disabled;
  final LdSize size;
  final LdColor? color;
  final Axis direction;

  const _LdSliderHandle({
    required this.fraction,
    required this.isDragging,
    required this.disabled,
    required this.size,
    this.color,
    this.direction = Axis.horizontal,
  });

  @override
  State<_LdSliderHandle> createState() => _LdSliderHandleState();
}

class _LdSliderHandleState extends State<_LdSliderHandle> {
  bool _isHovered = false;
  bool _isPressed = false;

  double _handleDiameter(LdTheme theme) {
    return switch (widget.size) {
      LdSize.xs => theme.paddingSize(size: LdSize.s) * 2,
      LdSize.s => theme.paddingSize(size: LdSize.m) * 2,
      LdSize.m => theme.paddingSize(size: LdSize.l) * 2,
      LdSize.l => theme.paddingSize(size: LdSize.l) * 2 + 4,
    };
  }

  double _iconSize(LdTheme theme) {
    return switch (widget.size) {
      LdSize.xs => 10,
      LdSize.s => 12,
      LdSize.m => 16,
      LdSize.l => 20,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final effectiveColor = widget.color ?? theme.palette.primary;
    final diameter = _handleDiameter(theme);

    Color backgroundColor;
    Color iconColor;
    Color borderColor;

    if (widget.disabled) {
      backgroundColor = theme.neutralShade(2);
      iconColor = theme.neutralShade(4);
      borderColor = theme.neutralShade(3);
    } else if (_isPressed || widget.isDragging) {
      backgroundColor = effectiveColor.active(theme.isDark);
      iconColor = theme.absolute;
      borderColor = effectiveColor.active(theme.isDark);
    } else if (_isHovered) {
      backgroundColor = effectiveColor.hover(theme.isDark);
      iconColor = theme.absolute;
      borderColor = effectiveColor.hover(theme.isDark);
    } else {
      backgroundColor = theme.neutralShade(2);
      iconColor = effectiveColor.idle(theme.isDark);
      borderColor = theme.border;
    }

    return MouseRegion(
      cursor: widget.disabled
          ? SystemMouseCursors.forbidden
          : SystemMouseCursors.resizeLeftRight,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: theme.borderWidth,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            boxShadow: [ldShadowDefault],
          ),
          child: Center(
            child: Icon(
              LucideIcons.gripVertical,
              size: _iconSize(theme),
              color: iconColor,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LdSlider
// ---------------------------------------------------------------------------

/// A value-input slider widget.
///
/// Displays a horizontal track with a draggable handle that maps to a [double]
/// value in the range [[min], [max]].
class LdSlider extends StatefulWidget {
  /// The current value of the slider.
  final double value;

  /// Called when the value changes via user interaction.
  final ValueChanged<double> onChanged;

  /// Minimum value. Defaults to 0.0.
  final double min;

  /// Maximum value. Defaults to 1.0.
  final double max;

  /// Snap step. 0 means continuous. Defaults to 0.0.
  final double step;

  /// Orientation of the slider. Currently only horizontal is fully supported.
  final Axis direction;

  /// Size of the slider and its handle. Defaults to [LdSize.m].
  final LdSize size;

  /// Optional accent color. Falls back to theme primary.
  final LdColor? color;

  /// Whether the slider is disabled.
  final bool disabled;

  /// Optional label shown above the track.
  final String? label;

  const LdSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.step = 0.0,
    this.direction = Axis.horizontal,
    this.size = LdSize.m,
    this.color,
    this.disabled = false,
    this.label,
  });

  @override
  State<LdSlider> createState() => _LdSliderState();
}

class _LdSliderState extends State<LdSlider> {
  bool _isDragging = false;

  /// Previous step index used for haptic feedback on step change.
  int? _prevStepIndex;

  double get _clampedValue => widget.value.clamp(widget.min, widget.max);

  // Track and handle geometry ------------------------------------------------

  double _trackHeight(LdTheme theme) {
    return switch (widget.size) {
      LdSize.xs => 4.0,
      LdSize.s => 6.0,
      LdSize.m => 8.0,
      LdSize.l => 10.0,
    };
  }

  double _handleDiameter(LdTheme theme) {
    return switch (widget.size) {
      LdSize.xs => theme.paddingSize(size: LdSize.s) * 2,
      LdSize.s => theme.paddingSize(size: LdSize.m) * 2,
      LdSize.m => theme.paddingSize(size: LdSize.l) * 2,
      LdSize.l => theme.paddingSize(size: LdSize.l) * 2 + 4,
    };
  }

  // Drag helpers -------------------------------------------------------------

  void _onDragStart(DragStartDetails details) {
    if (widget.disabled) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isDragging = true;
      _prevStepIndex = widget.step > 0
          ? (_clampedValue / widget.step).round()
          : null;
    });
  }

  void _onDragUpdate(DragUpdateDetails details, double trackWidth) {
    if (widget.disabled) return;

    final handleDiameter = _handleDiameter(LdTheme.of(context));
    final usableWidth = trackWidth - handleDiameter;
    if (usableWidth <= 0) return;

    // Map pointer x relative to the left edge of the track
    final fraction = ((details.localPosition.dx - handleDiameter / 2) / usableWidth)
        .clamp(0.0, 1.0);
    final raw = _fractionToValue(fraction, widget.min, widget.max);
    final snapped = _snapToStep(raw, widget.min, widget.max, widget.step);

    // Haptics on step change
    if (widget.step > 0) {
      final currentStepIndex = (snapped / widget.step).round();
      if (_prevStepIndex != null && currentStepIndex != _prevStepIndex) {
        LdHaptics.vibrate(HapticsType.selection);
      }
      _prevStepIndex = currentStepIndex;
    }

    if (snapped != widget.value) {
      widget.onChanged(snapped);
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (!mounted) return;
    setState(() {
      _isDragging = false;
      _prevStepIndex = null;
    });
  }

  // Build --------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final effectiveColor = widget.color ?? theme.palette.primary;

    final fraction = _valueToFraction(_clampedValue, widget.min, widget.max);
    final handleDiameter = _handleDiameter(theme);
    final trackHeight = _trackHeight(theme);
    final totalHeight = handleDiameter;

    // Active track color
    final activeColor = widget.disabled
        ? theme.neutralShade(4)
        : effectiveColor.idle(theme.isDark);

    final inactiveColor = theme.neutralShade(3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        LdFormLabel(
          label: widget.label,
          size: widget.size,
          disabled: widget.disabled,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth;
            final usableWidth = trackWidth - handleDiameter;
            final handleOffset = fraction * usableWidth;

            return GestureDetector(
              onHorizontalDragStart: _onDragStart,
              onHorizontalDragUpdate: (details) =>
                  _onDragUpdate(details, trackWidth),
              onHorizontalDragEnd: _onDragEnd,
              child: SizedBox(
                height: totalHeight,
                width: trackWidth,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    // Background track
                    Positioned(
                      left: handleDiameter / 2,
                      right: handleDiameter / 2,
                      child: Container(
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: inactiveColor,
                          borderRadius:
                              BorderRadius.circular(trackHeight / 2),
                        ),
                      ),
                    ),
                    // Active (filled) portion of track
                    Positioned(
                      left: handleDiameter / 2,
                      width: handleOffset,
                      child: Container(
                        height: trackHeight,
                        decoration: BoxDecoration(
                          color: activeColor,
                          borderRadius:
                              BorderRadius.circular(trackHeight / 2),
                        ),
                      ),
                    ),
                    // Handle
                    Positioned(
                      left: handleOffset,
                      child: _LdSliderHandle(
                        fraction: fraction,
                        isDragging: _isDragging,
                        disabled: widget.disabled,
                        size: widget.size,
                        color: widget.color,
                        direction: widget.direction,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
