import 'dart:math';

import 'package:flutter/material.dart';

class LdMultiPanelDragGestureHandler {
  final void Function(int startIndex, int endIndex)? onVisibleRangeChanged;
  final int childCount;
  final double Function(int index) getPanelWidth;
  final List<double> Function() getPositions;

  LdMultiPanelDragGestureHandler({
    required this.childCount,
    required this.onVisibleRangeChanged,
    required this.getPanelWidth,
    required this.getPositions,
  });

  bool _isDragging = false;
  double _dragStartX = 0;
  double _dragOffset = 0;
  bool _dragFromLeft = false;
  bool _dragFromRight = false;

  bool get isDragging => _isDragging;
  double get dragOffset => _dragOffset;
  bool get dragFromLeft => _dragFromLeft;
  bool get dragFromRight => _dragFromRight;

  bool _nearNr(double position, double value, double threshold) {
    return position > value - threshold && position < value + threshold;
  }

  void onDragStart(DragStartDetails details, int visibleStartIndex, int visibleEndIndex) {
    if (onVisibleRangeChanged == null) {
      return;
    }

    final positions = getPositions();
    if (positions.length != childCount) {
      return;
    }

    final widths = List<double>.generate(childCount, (i) => getPanelWidth(i));

    final firstPanelRight = positions[visibleStartIndex] + widths[visibleStartIndex];
    final firstPanelLeft = positions[visibleStartIndex];
    final lastPanelLeft = positions[visibleEndIndex];
    final lastPanelRight = positions[visibleEndIndex] + widths[visibleEndIndex];

    const threshold = 50.0;

    final isDraggingNearFirstPanelRight = _nearNr(details.localPosition.dx, firstPanelRight, threshold);
    final isDraggingNearFirstPanelLeft = _nearNr(details.localPosition.dx, firstPanelLeft, threshold);
    final isDraggingNearLastPanelLeft = _nearNr(details.localPosition.dx, lastPanelLeft, threshold);
    final isDraggingNearLastPanelRight = _nearNr(details.localPosition.dx, lastPanelRight, threshold);

    if (!isDraggingNearFirstPanelRight &&
        !isDraggingNearFirstPanelLeft &&
        !isDraggingNearLastPanelLeft &&
        !isDraggingNearLastPanelRight) {
      return;
    }

    _dragFromLeft = isDraggingNearFirstPanelRight || isDraggingNearFirstPanelLeft;
    _dragFromRight = isDraggingNearLastPanelRight || isDraggingNearLastPanelLeft;

    _isDragging = true;
    _dragStartX = details.globalPosition.dx;

    _dragOffset = 0;
  }

  void onDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;

    _dragOffset = details.globalPosition.dx - _dragStartX;
  }

  (int, int)? onDragEnd(int visibleStartIndex, int visibleEndIndex, double totalWidth) {
    if (!_isDragging) return null;

    _isDragging = false;

    final positions = getPositions();
    final widths = List<double>.generate(childCount, (i) => getPanelWidth(i));

    int newStartIndex = positions.length;
    int newEndIndex = 0;

    for (var i = 0; i < positions.length; i++) {
      final width = widths[i];
      final position = positions[i];

      if (position > -(width / 2)) {
        newStartIndex = min(newStartIndex, i);
      }

      if ((position + width) <= (totalWidth + (width / 2))) {
        newEndIndex = max(newEndIndex, i);
      }
    }

    newStartIndex = newStartIndex.clamp(0, childCount - 1);
    newEndIndex = newEndIndex.clamp(newStartIndex, childCount);

    if (newStartIndex != visibleStartIndex || newEndIndex != visibleEndIndex) {
      onVisibleRangeChanged?.call(newStartIndex, newEndIndex);
    }

    _dragOffset = 0;

    return (newStartIndex, newEndIndex);
  }

  void reset() {
    _isDragging = false;
    _dragOffset = 0;
    _dragFromLeft = false;
    _dragFromRight = false;
  }
}
