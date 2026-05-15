import 'package:flutter/widgets.dart';

enum LdAppBarPosition {
  top,
  bottom,
}

/// Immutable snapshot of an app-bar's metrics at a point in time.
///
/// [position]        – whether this bar sits at the top or bottom.
/// [barHeight]       – the full rendered height of the bar (pixels).
/// [edgeMargin]      – padding already applied on this edge before this bar
///                     (safe area and/or ancestor bars), used to compute
///                     [consumedInsets] without double-counting.
/// [hideOffset]      – how many pixels the bar has been scrolled off-screen
///                     (0 = fully visible, barHeight = fully hidden).
/// [isScrolledUnder] – true when the scroll content has moved underneath
///                     the bar.
/// [level]           – stacking index among bars at the same position (0 = outermost).
class LdAppBarMetrics {
  const LdAppBarMetrics({
    required this.position,
    required this.barHeight,
    required this.edgeMargin,
    required this.hideOffset,
    required this.isScrolledUnder,
    required this.level,
  });

  final LdAppBarPosition position;
  final double barHeight;
  final double edgeMargin;
  final double hideOffset;
  final bool isScrolledUnder;
  final int level;

  /// The insets this bar adds beyond [edgeMargin] for its subtree.
  ///
  /// [barHeight] is measured on the full bar surface, including padding for
  /// bars stacked above ([edgeMargin], which matches outer [MediaQuery.padding]
  /// on that edge). Only the incremental height is published so nested bars do
  /// not double-count ancestor space.
  ///
  /// For a **top** bar: `top = max(0, barHeight - hideOffset - edgeMargin)`.
  /// For a **bottom** bar: `bottom = max(0, barHeight - hideOffset - edgeMargin)`.
  EdgeInsets get consumedInsets {
    final visible = (barHeight - hideOffset).clamp(0.0, double.infinity);
    final incremental = (visible - edgeMargin).clamp(0.0, double.infinity);
    return switch (position) {
      LdAppBarPosition.top => EdgeInsets.only(top: incremental),
      LdAppBarPosition.bottom => EdgeInsets.only(bottom: incremental),
    };
  }

  LdAppBarMetrics copyWith({
    LdAppBarPosition? position,
    double? barHeight,
    double? edgeMargin,
    double? hideOffset,
    bool? isScrolledUnder,
    int? level,
  }) {
    return LdAppBarMetrics(
      position: position ?? this.position,
      barHeight: barHeight ?? this.barHeight,
      edgeMargin: edgeMargin ?? this.edgeMargin,
      hideOffset: hideOffset ?? this.hideOffset,
      isScrolledUnder: isScrolledUnder ?? this.isScrolledUnder,
      level: level ?? this.level,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LdAppBarMetrics &&
        other.position == position &&
        other.barHeight == barHeight &&
        other.edgeMargin == edgeMargin &&
        other.hideOffset == hideOffset &&
        other.isScrolledUnder == isScrolledUnder &&
        other.level == level;
  }

  @override
  int get hashCode => Object.hash(
        position,
        barHeight,
        edgeMargin,
        hideOffset,
        isScrolledUnder,
        level,
      );

  @override
  String toString() => 'LdAppBarMetrics('
      'position: $position, '
      'barHeight: $barHeight, '
      'edgeMargin: $edgeMargin, '
      'hideOffset: $hideOffset, '
      'isScrolledUnder: $isScrolledUnder, '
      'level: $level)';
}
