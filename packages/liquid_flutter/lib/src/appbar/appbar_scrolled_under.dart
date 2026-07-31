import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Whether scroll content has moved under the given [position] edge.
bool ldAppBarIsScrolledUnder({
  required LdAppBarPosition position,
  required ScrollMetrics metrics,
}) {
  final isReverse = metrics.axisDirection == AxisDirection.up;
  return switch (isReverse) {
    false => switch (position) {
        LdAppBarPosition.top => metrics.extentBefore > 0,
        LdAppBarPosition.bottom => metrics.extentAfter > 0,
      },
    true => switch (position) {
        LdAppBarPosition.top => metrics.extentAfter > 0,
        LdAppBarPosition.bottom => metrics.extentBefore > 0,
      },
  };
}

/// Provides the current [isScrolledUnder] value from a descendant
/// [LdAppBarScrolledUnderDetector].
class LdAppBarScrolledUnderScope extends InheritedWidget {
  const LdAppBarScrolledUnderScope({
    super.key,
    required this.isScrolledUnder,
    required super.child,
  });

  final bool isScrolledUnder;

  static bool of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LdAppBarScrolledUnderScope>();
    return scope?.isScrolledUnder ?? false;
  }

  @override
  bool updateShouldNotify(LdAppBarScrolledUnderScope oldWidget) {
    return isScrolledUnder != oldWidget.isScrolledUnder;
  }
}

/// Listens for [ScrollMetricsNotification]s and exposes whether the body
/// scrollable is under the given app bar [position].
class LdAppBarScrolledUnderDetector extends StatefulWidget {
  const LdAppBarScrolledUnderDetector({
    super.key,
    required this.position,
    required this.child,
    this.onChanged,
  });

  final LdAppBarPosition position;
  final Widget child;
  final ValueChanged<bool>? onChanged;

  @override
  State<LdAppBarScrolledUnderDetector> createState() => LdAppBarScrolledUnderDetectorState();
}

class LdAppBarScrolledUnderDetectorState extends State<LdAppBarScrolledUnderDetector> {
  bool _isScrolledUnder = false;

  bool get isScrolledUnder => _isScrolledUnder;

  /// When [wrappedChild] is swapped we cannot rely on scroll metrics from the
  /// previous subtree. A top bar that was not scrolled under is a safe default;
  /// otherwise assume scrolled-under until a [ScrollMetricsNotification]
  /// arrives from the new scrollable.
  void handleWrappedChildReplaced() {
    final isSafeTopState = widget.position == LdAppBarPosition.top && !_isScrolledUnder;

    final nextValue = isSafeTopState ? false : true;
    if (nextValue == _isScrolledUnder) {
      return;
    }

    setState(() => _isScrolledUnder = nextValue);
    widget.onChanged?.call(nextValue);
  }

  bool _handleScrollMetrics(ScrollMetricsNotification notification) {
    if (notification.depth != 0) {
      return false;
    }
    if (notification.metrics.axis != Axis.vertical) {
      return false;
    }

    final nextValue = ldAppBarIsScrolledUnder(
      position: widget.position,
      metrics: notification.metrics,
    );

    if (nextValue == _isScrolledUnder) {
      return false;
    }

    setState(() => _isScrolledUnder = nextValue);
    widget.onChanged?.call(nextValue);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollMetricsNotification>(
      onNotification: _handleScrollMetrics,
      child: LdAppBarScrolledUnderScope(
        isScrolledUnder: _isScrolledUnder,
        child: widget.child,
      ),
    );
  }
}
