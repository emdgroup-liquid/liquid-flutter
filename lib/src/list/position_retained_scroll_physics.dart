import 'package:flutter/material.dart';

/// In a "bidirectional infinite list" scenario, this physics will attempt to
/// retain the scroll position when the user scrolls up, causing the list to
/// append more items to the top. E.g. when items 40-49 are currently visible
/// and items 30-39 are appended to the top, we still want to show items 40-49
/// to the user.
class PositionRetainedScrollPhysics extends ScrollPhysics {
  final bool shouldRetain;

  const PositionRetainedScrollPhysics({
    this.shouldRetain = true,
    ScrollPhysics? parent,
  }) : super(parent: parent);

  @override
  PositionRetainedScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PositionRetainedScrollPhysics(
      shouldRetain: shouldRetain,
      parent: buildParent(ancestor),
    );
  }

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    final position = super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );

    // calculate the change in height of the scrollable
    final diff = newPosition.maxScrollExtent - oldPosition.maxScrollExtent;
    final adjustedPosition = position + diff;
    // detect whether we are scrolling to the top
    if (diff > 0 &&
        diff < oldPosition.maxScrollExtent &&
        // this condition is to prevent too drastic jumps:
        adjustedPosition / oldPosition.maxScrollExtent < 0.9 &&
        shouldRetain) {
      // try to jump back to the old position
      return adjustedPosition;
    }
    return position;
  }
}
