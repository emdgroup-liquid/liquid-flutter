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

/// Translates a [low, high] range by [valueDelta] (in value-space) while
/// preserving range width and clamping to [min, max].
({double low, double high}) _translateRange({
  required double low,
  required double high,
  required double valueDelta,
  required double min,
  required double max,
}) {
  final rangeWidth = high - low;
  final newLow = (low + valueDelta).clamp(min, max - rangeWidth);
  final newHigh = newLow + rangeWidth;
  return (low: newLow, high: newHigh);
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
  final String tooltipMessage;
  final GlobalKey<TooltipState> tooltipKey;

  const _LdSliderHandle({
    required this.fraction,
    required this.isDragging,
    required this.disabled,
    required this.size,
    required this.tooltipMessage,
    required this.tooltipKey,
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
  void didUpdateWidget(covariant _LdSliderHandle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isDragging && widget.isDragging) {
      // Drag started — show tooltip immediately
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.tooltipKey.currentState?.ensureTooltipVisible();
        }
      });
    } else if (oldWidget.isDragging && !widget.isDragging) {
      // Drag ended — dismiss tooltip
      widget.tooltipKey.currentState?.deactivate();
    }
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

    final cursor = widget.disabled
        ? SystemMouseCursors.forbidden
        : widget.direction == Axis.vertical
            ? SystemMouseCursors.resizeUpDown
            : SystemMouseCursors.resizeLeftRight;

    return Tooltip(
      key: widget.tooltipKey,
      message: widget.tooltipMessage,
      triggerMode: TooltipTriggerMode.manual,
      child: MouseRegion(
        cursor: cursor,
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// LdSlider
// ---------------------------------------------------------------------------

/// A value-input slider widget.
///
/// Displays a track with a draggable handle that maps to a [double]
/// value in the range [[min], [max]].
///
/// Use [LdSlider.range] to create a range slider with two handles.
/// Use [direction] to switch between horizontal and vertical orientation.
class LdSlider extends StatefulWidget {
  // ---- Single-mode fields ------------------------------------------------

  /// The current value of the slider (single mode only).
  final double? value;

  /// Called when the value changes via user interaction (single mode only).
  final ValueChanged<double>? onChanged;

  // ---- Range-mode fields -------------------------------------------------

  /// The current low value of the range (range mode only).
  final double? lowValue;

  /// The current high value of the range (range mode only).
  final double? highValue;

  /// Called when the range changes via user interaction (range mode only).
  final void Function(double low, double high)? onRangeChanged;

  /// Whether the entire filled region between the two handles can be dragged
  /// as a unit, translating both values by the same delta while preserving
  /// range width. Only has effect in range mode when the slider is not disabled.
  final bool allowRangeDrag;

  // ---- Shared fields -----------------------------------------------------

  /// Minimum value. Defaults to 0.0.
  final double min;

  /// Maximum value. Defaults to 1.0.
  final double max;

  /// Snap step. 0 means continuous. Defaults to 0.0.
  final double step;

  /// Orientation of the slider. Defaults to [Axis.horizontal].
  final Axis direction;

  /// Size of the slider and its handle. Defaults to [LdSize.m].
  final LdSize size;

  /// Optional accent color. Falls back to theme primary.
  final LdColor? color;

  /// Whether the slider is disabled.
  final bool disabled;

  /// Optional label shown above the widget regardless of axis.
  final String? label;

  /// Whether this is a range slider (two handles).
  final bool _isRange;

  const LdSlider({
    super.key,
    required double value,
    required ValueChanged<double> onChanged,
    this.min = 0.0,
    this.max = 1.0,
    this.step = 0.0,
    this.direction = Axis.horizontal,
    this.size = LdSize.m,
    this.color,
    this.disabled = false,
    this.label,
  })  : _isRange = false,
        // ignore: prefer_initializing_formals
        value = value,
        // ignore: prefer_initializing_formals
        onChanged = onChanged,
        lowValue = null,
        highValue = null,
        onRangeChanged = null,
        allowRangeDrag = false;

  /// Creates a range slider with two independent handles.
  ///
  /// [lowValue] must be <= [highValue] in debug mode; in release mode the
  /// values are clamped gracefully.
  const LdSlider.range({
    super.key,
    required double lowValue,
    required double highValue,
    required void Function(double low, double high) onRangeChanged,
    bool allowRangeDrag = false,
    this.min = 0.0,
    this.max = 1.0,
    this.step = 0.0,
    this.direction = Axis.horizontal,
    this.size = LdSize.m,
    this.color,
    this.disabled = false,
    this.label,
  })  : _isRange = true,
        value = null,
        onChanged = null,
        // ignore: prefer_initializing_formals
        lowValue = lowValue,
        // ignore: prefer_initializing_formals
        highValue = highValue,
        // ignore: prefer_initializing_formals
        onRangeChanged = onRangeChanged,
        // ignore: prefer_initializing_formals
        allowRangeDrag = allowRangeDrag;

  @override
  State<LdSlider> createState() => _LdSliderState();
}

class _LdSliderState extends State<LdSlider> {
  // ---- Axis helper --------------------------------------------------------

  bool get _isVertical => widget.direction == Axis.vertical;

  // ---- Single-mode drag state --------------------------------------------
  bool _isDragging = false;

  /// Previous step index used for haptic feedback on step change (single mode).
  int? _prevStepIndex;

  // ---- Range-mode drag state ---------------------------------------------
  bool _isDraggingLow = false;
  bool _isDraggingHigh = false;
  bool _isDraggingRange = false;

  /// Step-index tracking for haptics — low handle.
  int? _prevLowStepIndex;

  /// Step-index tracking for haptics — high handle.
  int? _prevHighStepIndex;

  /// Anchor value at the start of a low-handle drag (Bug 1 fix).
  double? _lowDragAnchorValue;

  /// Accumulated pixel delta since low-handle drag started (Bug 1 fix).
  double _lowDragAccumPx = 0.0;

  /// Anchor value at the start of a high-handle drag (Bug 1 fix).
  double? _highDragAnchorValue;

  /// Accumulated pixel delta since high-handle drag started (Bug 1 fix).
  double _highDragAccumPx = 0.0;

  // ---- Tooltip keys ------------------------------------------------------
  // _lowTooltipKey used in both single and range mode.
  final _lowTooltipKey = GlobalKey<TooltipState>();
  final _highTooltipKey = GlobalKey<TooltipState>();

  // ---- Single-mode helpers -----------------------------------------------

  double get _clampedValue => widget.value!.clamp(widget.min, widget.max);

  String get _formattedValue {
    final v = _clampedValue;
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  // ---- Range-mode helpers ------------------------------------------------

  /// A small epsilon to ensure the low handle never equals the high handle.
  double get _epsilon => 0.001 * (widget.max - widget.min);

  double get _minSeparation => widget.step > 0 ? widget.step : _epsilon;

  double get _clampedLow {
    final raw = widget.lowValue!.clamp(widget.min, widget.max);
    final ceiling = widget.highValue!.clamp(widget.min, widget.max) - _minSeparation;
    return raw.clamp(widget.min, ceiling);
  }

  double get _clampedHigh {
    final raw = widget.highValue!.clamp(widget.min, widget.max);
    final floor = widget.lowValue!.clamp(widget.min, widget.max) + _minSeparation;
    return raw.clamp(floor, widget.max);
  }

  String _formatValue(double v) {
    if (v == v.roundToDouble()) return v.toInt().toString();
    return v.toStringAsFixed(2);
  }

  // ---- Track and handle geometry -----------------------------------------

  double _trackThickness(LdTheme theme) {
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

  // ---- Single-mode drag helpers ------------------------------------------

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

  void _onDragUpdate(DragUpdateDetails details, double trackLength) {
    if (widget.disabled) return;

    final handleDiameter = _handleDiameter(LdTheme.of(context));
    final usableLength = trackLength - handleDiameter;
    if (usableLength <= 0) return;

    double fraction;
    if (_isVertical) {
      // Vertical: value 0 is at bottom, value max is at top.
      // localPosition.dy increases downward; invert so dragging up increases value.
      fraction = (1.0 - (details.localPosition.dy - handleDiameter / 2) / usableLength)
          .clamp(0.0, 1.0);
    } else {
      fraction = ((details.localPosition.dx - handleDiameter / 2) / usableLength)
          .clamp(0.0, 1.0);
    }

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
      widget.onChanged!(snapped);
    }
  }

  void _onDragEnd(DragEndDetails details) {
    if (!mounted) return;
    setState(() {
      _isDragging = false;
      _prevStepIndex = null;
    });
  }

  // ---- Range-mode drag helpers -------------------------------------------

  void _onLowDragStart(DragStartDetails details) {
    if (widget.disabled) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isDraggingLow = true;
      _lowDragAnchorValue = _clampedLow;
      _lowDragAccumPx = 0.0;
      _prevLowStepIndex = widget.step > 0
          ? (_clampedLow / widget.step).round()
          : null;
    });
  }

  void _onLowDragUpdate(DragUpdateDetails details, double trackLength) {
    if (widget.disabled) return;

    final handleDiameter = _handleDiameter(LdTheme.of(context));
    final usableLength = trackLength - handleDiameter;
    if (usableLength <= 0) return;

    // Accumulate pixel delta from drag start; convert to value via anchor.
    if (_isVertical) {
      // Inverted: drag up (negative dy) increases value.
      _lowDragAccumPx -= details.delta.dy;
    } else {
      _lowDragAccumPx += details.delta.dx;
    }

    final anchorFraction = _valueToFraction(_lowDragAnchorValue!, widget.min, widget.max);
    final fraction = (anchorFraction + _lowDragAccumPx / usableLength).clamp(0.0, 1.0);
    final raw = _fractionToValue(fraction, widget.min, widget.max);

    // Clamp so low handle stays below high handle
    final ceiling = _clampedHigh - _minSeparation;
    final clamped = raw.clamp(widget.min, ceiling);
    final snapped = _snapToStep(clamped, widget.min, ceiling, widget.step);

    // Haptics
    if (widget.step > 0) {
      final currentStepIndex = (snapped / widget.step).round();
      if (_prevLowStepIndex != null && currentStepIndex != _prevLowStepIndex) {
        LdHaptics.vibrate(HapticsType.selection);
      }
      _prevLowStepIndex = currentStepIndex;
    }

    if (snapped != widget.lowValue) {
      widget.onRangeChanged!(snapped, widget.highValue!);
    }
  }

  void _onLowDragEnd(DragEndDetails details) {
    if (!mounted) return;
    setState(() {
      _isDraggingLow = false;
      _prevLowStepIndex = null;
      _lowDragAnchorValue = null;
      _lowDragAccumPx = 0.0;
    });
  }

  void _onHighDragStart(DragStartDetails details) {
    if (widget.disabled) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _isDraggingHigh = true;
      _highDragAnchorValue = _clampedHigh;
      _highDragAccumPx = 0.0;
      _prevHighStepIndex = widget.step > 0
          ? (_clampedHigh / widget.step).round()
          : null;
    });
  }

  void _onHighDragUpdate(DragUpdateDetails details, double trackLength) {
    if (widget.disabled) return;

    final handleDiameter = _handleDiameter(LdTheme.of(context));
    final usableLength = trackLength - handleDiameter;
    if (usableLength <= 0) return;

    // Accumulate pixel delta from drag start; convert to value via anchor.
    if (_isVertical) {
      _highDragAccumPx -= details.delta.dy;
    } else {
      _highDragAccumPx += details.delta.dx;
    }

    final anchorFraction = _valueToFraction(_highDragAnchorValue!, widget.min, widget.max);
    final fraction = (anchorFraction + _highDragAccumPx / usableLength).clamp(0.0, 1.0);
    final raw = _fractionToValue(fraction, widget.min, widget.max);

    // Clamp so high handle stays above low handle
    final floor = _clampedLow + _minSeparation;
    final clamped = raw.clamp(floor, widget.max);
    final snapped = _snapToStep(clamped, floor, widget.max, widget.step);

    // Haptics
    if (widget.step > 0) {
      final currentStepIndex = (snapped / widget.step).round();
      if (_prevHighStepIndex != null && currentStepIndex != _prevHighStepIndex) {
        LdHaptics.vibrate(HapticsType.selection);
      }
      _prevHighStepIndex = currentStepIndex;
    }

    if (snapped != widget.highValue) {
      widget.onRangeChanged!(widget.lowValue!, snapped);
    }
  }

  void _onHighDragEnd(DragEndDetails details) {
    if (!mounted) return;
    setState(() {
      _isDraggingHigh = false;
      _prevHighStepIndex = null;
      _highDragAnchorValue = null;
      _highDragAccumPx = 0.0;
    });
  }

  // ---- Range fill drag helpers -------------------------------------------

  void _onRangeDragStart(DragStartDetails details) {
    if (widget.disabled) return;
    HapticFeedback.mediumImpact();
    setState(() => _isDraggingRange = true);
  }

  void _onRangeDragUpdate(DragUpdateDetails details, double trackPx) {
    if (widget.disabled) return;
    if (trackPx <= 0) return;

    final double pixelDelta;
    if (_isVertical) {
      // Inverted: drag up (negative dy) increases value.
      pixelDelta = -details.delta.dy;
    } else {
      pixelDelta = details.delta.dx;
    }

    // Convert pixel delta to value delta (1:1 cursor-to-range mapping).
    final valueDelta = (pixelDelta / trackPx) * (widget.max - widget.min);

    var result = _translateRange(
      low: _clampedLow,
      high: _clampedHigh,
      valueDelta: valueDelta,
      min: widget.min,
      max: widget.max,
    );

    // Apply step snapping: snap both endpoints to the step grid independently.
    // newLow is snapped first, then newHigh is snapped while preserving that
    // newHigh >= newLow + minSeparation.
    if (widget.step > 0) {
      final snappedLow = _snapToStep(result.low, widget.min, widget.max, widget.step);
      final snappedHigh = _snapToStep(
        result.high,
        snappedLow + _minSeparation,
        widget.max,
        widget.step,
      );
      result = (low: snappedLow, high: snappedHigh);
    }

    if (result.low != widget.lowValue || result.high != widget.highValue) {
      widget.onRangeChanged!(result.low, result.high);
    }
  }

  void _onRangeDragEnd(DragEndDetails details) {
    if (!mounted) return;
    setState(() => _isDraggingRange = false);
  }

  // ---- Build ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (widget._isRange) {
      return _buildRange(context);
    }
    return _buildSingle(context);
  }

  Widget _buildSingle(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);
    final effectiveColor = widget.color ?? theme.palette.primary;

    final fraction = _valueToFraction(_clampedValue, widget.min, widget.max);
    final handleDiameter = _handleDiameter(theme);
    final trackThickness = _trackThickness(theme);
    final totalCrossAxis = handleDiameter;

    // Active track color
    final activeColor = widget.disabled
        ? theme.neutralShade(4)
        : effectiveColor.idle(theme.isDark);

    final inactiveColor = theme.neutralShade(3);

    // Label always sits above the slider widget
    final label = LdFormLabel(
      label: widget.label,
      size: widget.size,
      disabled: widget.disabled,
    );

    final track = LayoutBuilder(
      builder: (context, constraints) {
        final trackLength = _isVertical ? constraints.maxHeight : constraints.maxWidth;
        final usableLength = trackLength - handleDiameter;

        final gestureDetector = GestureDetector(
          onHorizontalDragStart: _isVertical ? null : _onDragStart,
          onHorizontalDragUpdate: _isVertical
              ? null
              : (details) => _onDragUpdate(details, trackLength),
          onHorizontalDragEnd: _isVertical ? null : _onDragEnd,
          onVerticalDragStart: _isVertical ? _onDragStart : null,
          onVerticalDragUpdate: _isVertical
              ? (details) => _onDragUpdate(details, trackLength)
              : null,
          onVerticalDragEnd: _isVertical ? _onDragEnd : null,
          child: LdSpring(
            position: fraction,
            initialPosition: fraction,
            // When dragging, override the spring so the handle tracks the
            // pointer 1:1. When not dragging, let the spring animate toward
            // the programmatic target value.
            overriden: _isDragging,
            builder: (context, springState, _) {
              final springFraction = springState.position.clamp(0.0, 1.0);

              if (_isVertical) {
                // Vertical layout: value 0 at bottom, value max at top.
                // handleOffset is measured from the TOP of the track container.
                final handleOffset = (1.0 - springFraction) * usableLength;

                return SizedBox(
                  width: totalCrossAxis,
                  height: trackLength,
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      // Background track (full height between half-handle margins)
                      Positioned(
                        top: handleDiameter / 2,
                        bottom: handleDiameter / 2,
                        child: Container(
                          width: trackThickness,
                          decoration: BoxDecoration(
                            color: inactiveColor,
                            borderRadius:
                                BorderRadius.circular(trackThickness / 2),
                          ),
                        ),
                      ),
                      // Active (filled) portion — from current handle down to bottom
                      Positioned(
                        top: handleDiameter / 2 + handleOffset,
                        bottom: handleDiameter / 2,
                        child: Container(
                          width: trackThickness,
                          decoration: BoxDecoration(
                            color: activeColor,
                            borderRadius:
                                BorderRadius.circular(trackThickness / 2),
                          ),
                        ),
                      ),
                      // Handle
                      Positioned(
                        top: handleOffset,
                        child: _LdSliderHandle(
                          fraction: springFraction,
                          isDragging: _isDragging,
                          disabled: widget.disabled,
                          size: widget.size,
                          color: widget.color,
                          direction: widget.direction,
                          tooltipMessage: _formattedValue,
                          tooltipKey: _lowTooltipKey,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                // Horizontal layout (original behavior)
                final handleOffset = springFraction * usableLength;

                return SizedBox(
                  height: totalCrossAxis,
                  width: trackLength,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Background track
                      Positioned(
                        left: handleDiameter / 2,
                        right: handleDiameter / 2,
                        child: Container(
                          height: trackThickness,
                          decoration: BoxDecoration(
                            color: inactiveColor,
                            borderRadius:
                                BorderRadius.circular(trackThickness / 2),
                          ),
                        ),
                      ),
                      // Active (filled) portion of track
                      Positioned(
                        left: handleDiameter / 2,
                        width: handleOffset,
                        child: Container(
                          height: trackThickness,
                          decoration: BoxDecoration(
                            color: activeColor,
                            borderRadius:
                                BorderRadius.circular(trackThickness / 2),
                          ),
                        ),
                      ),
                      // Handle
                      Positioned(
                        left: handleOffset,
                        child: _LdSliderHandle(
                          fraction: springFraction,
                          isDragging: _isDragging,
                          disabled: widget.disabled,
                          size: widget.size,
                          color: widget.color,
                          direction: widget.direction,
                          tooltipMessage: _formattedValue,
                          tooltipKey: _lowTooltipKey,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        );

        return gestureDetector;
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        label,
        if (_isVertical) Expanded(child: track) else track,
      ],
    );
  }

  Widget _buildRange(BuildContext context) {
    assert(() {
      if (widget.lowValue! > widget.highValue!) {
        throw FlutterError(
          'LdSlider.range: lowValue (${widget.lowValue}) must be <= highValue (${widget.highValue}). '
          'Swap the values or ensure the correct order.',
        );
      }
      return true;
    }());

    final theme = LdTheme.of(context, listen: true);
    final effectiveColor = widget.color ?? theme.palette.primary;

    final clampedLow = _clampedLow;
    final clampedHigh = _clampedHigh;

    final lowFraction = _valueToFraction(clampedLow, widget.min, widget.max);
    final highFraction = _valueToFraction(clampedHigh, widget.min, widget.max);

    final handleDiameter = _handleDiameter(theme);
    final trackThickness = _trackThickness(theme);
    final totalCrossAxis = handleDiameter;

    final activeColor = widget.disabled
        ? theme.neutralShade(4)
        : effectiveColor.idle(theme.isDark);
    final inactiveColor = theme.neutralShade(3);

    // Label always sits above the slider widget
    final label = LdFormLabel(
      label: widget.label,
      size: widget.size,
      disabled: widget.disabled,
    );

    final track = LayoutBuilder(
      builder: (context, constraints) {
        final trackLength = _isVertical ? constraints.maxHeight : constraints.maxWidth;
        final usableLength = trackLength - handleDiameter;

        if (_isVertical) {
          return SizedBox(
            width: totalCrossAxis,
            height: trackLength,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // --- Background track ---
                Positioned(
                  top: handleDiameter / 2,
                  bottom: handleDiameter / 2,
                  child: Container(
                    width: trackThickness,
                    decoration: BoxDecoration(
                      color: inactiveColor,
                      borderRadius: BorderRadius.circular(trackThickness / 2),
                    ),
                  ),
                ),

                // --- Low handle spring ---
                LdSpring(
                  position: lowFraction,
                  initialPosition: lowFraction,
                  overriden: _isDraggingRange || _isDraggingLow || _isDraggingHigh,
                  builder: (context, lowSpringState, _) {
                    final lowSpringFraction =
                        lowSpringState.position.clamp(0.0, 1.0);
                    // In vertical mode, offset from top = (1 - fraction) * usableLength
                    final lowTopOffset = (1.0 - lowSpringFraction) * usableLength;

                    // --- High handle spring (nested so we have both positions) ---
                    return LdSpring(
                      position: highFraction,
                      initialPosition: highFraction,
                      overriden: _isDraggingRange || _isDraggingLow || _isDraggingHigh,
                      builder: (context, highSpringState, _) {
                        final highSpringFraction =
                            highSpringState.position.clamp(0.0, 1.0);
                        final highTopOffset = (1.0 - highSpringFraction) * usableLength;

                        // Fill: from high handle top (higher on screen) to low handle bottom
                        final fillTop = handleDiameter / 2 + highTopOffset;
                        final fillBottom = handleDiameter / 2 + lowTopOffset;
                        final fillHeight = (fillBottom - fillTop).clamp(0.0, double.infinity);

                        // Vertical handle centers (Y from top of the Stack container)
                        final handleRadius = handleDiameter / 2;
                        final highHandleCenter = highTopOffset + handleRadius;
                        final lowHandleCenter = lowTopOffset + handleRadius;

                        // Fill hit region (vertical): from highHandleCenter+handleRadius
                        // (below high handle) to lowHandleCenter-handleRadius (above low handle)
                        final fillHitTop = highHandleCenter + handleRadius;
                        final fillHitBottom = lowHandleCenter - handleRadius;
                        final fillHitHeight = fillHitBottom - fillHitTop;

                        return Stack(
                          alignment: Alignment.topCenter,
                          children: [
                            // Active fill between handles
                            Positioned(
                              top: fillTop,
                              height: fillHeight,
                              child: Container(
                                width: trackThickness,
                                decoration: BoxDecoration(
                                  color: activeColor,
                                  borderRadius:
                                      BorderRadius.circular(trackThickness / 2),
                                ),
                              ),
                            ),

                            // Fill drag overlay (allowRangeDrag, vertical)
                            // Rendered BEFORE handles so handles are above in Z-order.
                            if (widget.allowRangeDrag &&
                                !widget.disabled &&
                                fillHitHeight > 0)
                              Positioned(
                                top: fillHitTop,
                                height: fillHitHeight,
                                left: 0,
                                right: 0,
                                child: MouseRegion(
                                  cursor: _isDraggingRange
                                      ? SystemMouseCursors.grabbing
                                      : SystemMouseCursors.grab,
                                  child: GestureDetector(
                                    onVerticalDragStart: _onRangeDragStart,
                                    onVerticalDragUpdate: (details) =>
                                        _onRangeDragUpdate(details, usableLength),
                                    onVerticalDragEnd: _onRangeDragEnd,
                                  ),
                                ),
                              ),

                            // Low handle gesture detector (lower on screen = lower value)
                            Positioned(
                              top: lowTopOffset,
                              child: GestureDetector(
                                onVerticalDragStart: _onLowDragStart,
                                onVerticalDragUpdate: (details) =>
                                    _onLowDragUpdate(details, trackLength),
                                onVerticalDragEnd: _onLowDragEnd,
                                child: _LdSliderHandle(
                                  fraction: lowSpringFraction,
                                  isDragging: _isDraggingLow,
                                  disabled: widget.disabled,
                                  size: widget.size,
                                  color: widget.color,
                                  direction: widget.direction,
                                  tooltipMessage:
                                      _formatValue(clampedLow),
                                  tooltipKey: _lowTooltipKey,
                                ),
                              ),
                            ),

                            // High handle gesture detector (higher on screen = higher value)
                            Positioned(
                              top: highTopOffset,
                              child: GestureDetector(
                                onVerticalDragStart: _onHighDragStart,
                                onVerticalDragUpdate: (details) =>
                                    _onHighDragUpdate(details, trackLength),
                                onVerticalDragEnd: _onHighDragEnd,
                                child: _LdSliderHandle(
                                  fraction: highSpringFraction,
                                  isDragging: _isDraggingHigh,
                                  disabled: widget.disabled,
                                  size: widget.size,
                                  color: widget.color,
                                  direction: widget.direction,
                                  tooltipMessage:
                                      _formatValue(clampedHigh),
                                  tooltipKey: _highTooltipKey,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          // Horizontal range slider (original behavior)
          return SizedBox(
            height: totalCrossAxis,
            width: trackLength,
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // --- Background track ---
                Positioned(
                  left: handleDiameter / 2,
                  right: handleDiameter / 2,
                  child: Container(
                    height: trackThickness,
                    decoration: BoxDecoration(
                      color: inactiveColor,
                      borderRadius: BorderRadius.circular(trackThickness / 2),
                    ),
                  ),
                ),

                // --- Low handle spring ---
                LdSpring(
                  position: lowFraction,
                  initialPosition: lowFraction,
                  overriden: _isDraggingRange || _isDraggingLow || _isDraggingHigh,
                  builder: (context, lowSpringState, _) {
                    final lowSpringFraction =
                        lowSpringState.position.clamp(0.0, 1.0);
                    final lowOffset = lowSpringFraction * usableLength;

                    // --- High handle spring (nested so we have both positions) ---
                    return LdSpring(
                      position: highFraction,
                      initialPosition: highFraction,
                      overriden: _isDraggingRange || _isDraggingLow || _isDraggingHigh,
                      builder: (context, highSpringState, _) {
                        final highSpringFraction =
                            highSpringState.position.clamp(0.0, 1.0);
                        final highOffset = highSpringFraction * usableLength;

                        // Fill width between low and high handle centers
                        final fillLeft =
                            handleDiameter / 2 + lowOffset;
                        final fillRight =
                            handleDiameter / 2 + highOffset;
                        final fillWidth =
                            (fillRight - fillLeft).clamp(0.0, double.infinity);

                        // Handle centers in the Stack coordinate space
                        final handleRadius = handleDiameter / 2;
                        // lowHandleCenter and highHandleCenter are the x positions
                        // of the centers of the low and high handles.
                        final lowHandleCenter = lowOffset + handleRadius;
                        final highHandleCenter = highOffset + handleRadius;

                        // Fill hit region: from lowHandleCenter+handleRadius to
                        // highHandleCenter-handleRadius. If the range is narrower
                        // than 2×handleRadius, the fill is not interactive.
                        final fillHitLeft = lowHandleCenter + handleRadius;
                        final fillHitRight = highHandleCenter - handleRadius;
                        final fillHitWidth = fillHitRight - fillHitLeft;

                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            // Active fill between handles
                            Positioned(
                              left: fillLeft,
                              width: fillWidth,
                              child: Container(
                                height: trackThickness,
                                decoration: BoxDecoration(
                                  color: activeColor,
                                  borderRadius:
                                      BorderRadius.circular(trackThickness / 2),
                                ),
                              ),
                            ),

                            // Fill drag overlay (allowRangeDrag, horizontal)
                            // Rendered BEFORE handles so handles are above in Z-order.
                            if (widget.allowRangeDrag &&
                                !widget.disabled &&
                                fillHitWidth > 0)
                              Positioned(
                                left: fillHitLeft,
                                width: fillHitWidth,
                                top: 0,
                                bottom: 0,
                                child: MouseRegion(
                                  cursor: _isDraggingRange
                                      ? SystemMouseCursors.grabbing
                                      : SystemMouseCursors.grab,
                                  child: GestureDetector(
                                    onHorizontalDragStart: _onRangeDragStart,
                                    onHorizontalDragUpdate: (details) =>
                                        _onRangeDragUpdate(details, usableLength),
                                    onHorizontalDragEnd: _onRangeDragEnd,
                                  ),
                                ),
                              ),

                            // Low handle gesture detector
                            Positioned(
                              left: lowOffset,
                              child: GestureDetector(
                                onHorizontalDragStart: _onLowDragStart,
                                onHorizontalDragUpdate: (details) =>
                                    _onLowDragUpdate(details, trackLength),
                                onHorizontalDragEnd: _onLowDragEnd,
                                child: _LdSliderHandle(
                                  fraction: lowSpringFraction,
                                  isDragging: _isDraggingLow,
                                  disabled: widget.disabled,
                                  size: widget.size,
                                  color: widget.color,
                                  direction: widget.direction,
                                  tooltipMessage:
                                      _formatValue(clampedLow),
                                  tooltipKey: _lowTooltipKey,
                                ),
                              ),
                            ),

                            // High handle gesture detector
                            Positioned(
                              left: highOffset,
                              child: GestureDetector(
                                onHorizontalDragStart: _onHighDragStart,
                                onHorizontalDragUpdate: (details) =>
                                    _onHighDragUpdate(details, trackLength),
                                onHorizontalDragEnd: _onHighDragEnd,
                                child: _LdSliderHandle(
                                  fraction: highSpringFraction,
                                  isDragging: _isDraggingHigh,
                                  disabled: widget.disabled,
                                  size: widget.size,
                                  color: widget.color,
                                  direction: widget.direction,
                                  tooltipMessage:
                                      _formatValue(clampedHigh),
                                  tooltipKey: _highTooltipKey,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        }
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        label,
        if (_isVertical) Expanded(child: track) else track,
      ],
    );
  }
}
