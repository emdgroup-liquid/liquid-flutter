import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';

/// Configuration for panel width in LdMultiPanelLayout
class PanelWidth {
  final double? _fixed;
  final int? _numerator;
  final int? _denominator;
  final bool _isFill;
  final double _fillFlex;

  const PanelWidth._({
    double? fixed,
    int? numerator,
    int? denominator,
    bool isFill = false,
    double? fillFlex,
  })  : _fixed = fixed,
        _numerator = numerator,
        _denominator = denominator,
        _fillFlex = fillFlex ?? 1,
        _isFill = isFill;

  /// Fixed pixel width
  const PanelWidth.fixed(double width) : this._(fixed: width);

  /// Fraction of available width (numerator/denominator)
  const PanelWidth.fraction(int numerator, int denominator) : this._(numerator: numerator, denominator: denominator);

  /// Half width (1/2)
  const PanelWidth.half() : this.fraction(1, 2);

  /// Third width (1/3)
  const PanelWidth.third() : this.fraction(1, 3);

  /// Two thirds width (2/3)
  const PanelWidth.twoThirds() : this.fraction(2, 3);

  /// Quarter width (1/4)
  const PanelWidth.quarter() : this.fraction(1, 4);

  /// Three quarters width (3/4)
  const PanelWidth.threeQuarters() : this.fraction(3, 4);

  /// Fill remaining space after other panels
  const PanelWidth.fill({double fillFlex = 1}) : this._(isFill: true, fillFlex: fillFlex);

  /// Whether this is a fixed width
  bool get isFixed => _fixed != null;

  /// Whether this is a fraction width
  bool get isFraction => _numerator != null && _denominator != null;

  /// Whether this fills remaining space
  bool get isFill => _isFill;

  /// Get fixed width value (null if not fixed)
  double? get fixedValue => _fixed;

  /// Get fraction numerator (null if not fraction)
  int? get fractionNumerator => _numerator;

  /// Get fraction denominator (null if not fraction)
  int? get fractionDenominator => _denominator;

  /// Get fill flex value
  double get fillFlex => _fillFlex;

  double? calculateWidth(double availableWidth) {
    if (isFixed) {
      return _fixed;
    }
    if (isFraction) {
      return _numerator! / _denominator! * availableWidth;
    }
    return null;
  }

  /// Calculate actual width based on available space and other panels
  static (List<double> widths, double remainingOffset) calculateSideBySideWidths({
    required List<PanelWidth> widths,
    required double availableWidth,
    required int visibleStartIndex,
    required int visibleEndIndex,
    required double dragOffset,
    required bool dragFromLeft,
    required double spacing,
  }) {
    if (widths.isEmpty || availableWidth <= 0) {
      return (List.filled(widths.length, 0.0), availableWidth);
    }

    final result = List<double>.filled(widths.length, 0.0);
    double remainingWidth = availableWidth;
    final onScreenFillIndices = <int>[];
    final offScreenFillIndices = <int>[];

    // Total spacing between panels
    double totalSpacing = spacing * (visibleEndIndex - visibleStartIndex);

    remainingWidth -= totalSpacing;

    // First pass: calculate fixed and fraction widths
    for (var i = 0; i < widths.length; i++) {
      final width = widths[i];
      if (width._fixed != null) {
        result[i] = width._fixed!.clamp(0, remainingWidth);
      } else if (width._numerator != null && width._denominator != null) {
        final fraction = width._numerator! / width._denominator!;
        result[i] = (availableWidth * fraction);
      }

      if (i >= visibleStartIndex && i <= visibleEndIndex) {
        remainingWidth -= result[i];
      }

      if (width._isFill) {
        if (i >= visibleStartIndex && i <= visibleEndIndex) {
          onScreenFillIndices.add(i);
        } else {
          offScreenFillIndices.add(i);
        }
      }
    }

    if (dragFromLeft) {
      if ((visibleStartIndex != 0 || dragOffset < 0)) {
        remainingWidth -= dragOffset;
      }
    }
    if (!dragFromLeft) {
      if ((visibleEndIndex != (widths.length - 1) || dragOffset > 0)) {
        remainingWidth += dragOffset;
      }
    }

    final totalFillFlex =
        widths.sublist(visibleStartIndex, visibleEndIndex + 1).where((e) => e.isFill).map((e) => e.fillFlex).sum;

    final fillWidth = remainingWidth / max(1, totalFillFlex);

    for (final index in onScreenFillIndices) {
      result[index] = fillWidth * widths[index].fillFlex;
    }

    for (final index in offScreenFillIndices) {
      result[index] = fillWidth;
    }

    return (result, availableWidth);
  }
}
