import 'package:flutter/widgets.dart';

enum LdAppBarPosition {
  top,
  bottom,
}

/// Immutable snapshot of an app-bar's metrics at a point in time.
///
/// [position]        – whether this bar sits at the top or bottom.
/// [barHeight]       – full rendered height of the bar surface, including the
///                     outside safe-area / ancestor-bar padding. Equals the
///                     height that MeasureSize measures on the outer container.
/// [edgeMargin]      – the outer padding already applied on this edge before
///                     this bar (device safe-area + ancestor bars' net heights).
///                     Equals [MediaQuery.paddingOf] on that edge at build time.
/// [hideOffset]      – how many pixels the bar has been scrolled off-screen
///                     (0 = fully visible, barHeight = fully hidden). Animated.
/// [isScrolledUnder] – true when scroll content has moved underneath the bar.
/// [level]           – stacking index among bars at the same position (0 = outermost).
class LdAppBarMetrics {
  const LdAppBarMetrics({
    required this.position,
    required this.barHeight,
    required this.edgeMargin,
    required this.hideOffset,
    required this.isScrolledUnder,
    required this.level,
    this.accumulatedHideOffset = 0.0,
  });

  final LdAppBarPosition position;

  /// Full outer-container height: edgeMargin + own inner content.
  final double barHeight;

  /// Outer padding already on this edge before this bar (device safe-area +
  /// all ancestor bars' stable net heights). Used to compute [stableConsumedInsets]
  /// without double-counting.
  final double edgeMargin;

  /// Animated scroll-hide offset (0 = fully visible, barHeight = fully hidden).
  final double hideOffset;

  /// Cumulative hide offset from all ancestor bars at the same position.
  /// 0 for the outermost bar. Used by nested bars to compute their translate
  /// so they follow ancestor bars as they hide.
  final double accumulatedHideOffset;

  final bool isScrolledUnder;
  final int level;

  /// Net insets this bar contributes to its subtree, stable (never animated).
  ///
  /// = max(0, barHeight - edgeMargin)
  ///
  /// Used to patch [MediaQuery.padding] for the body subtree so the
  /// scroll-content floor never shifts while the bar animates.
  EdgeInsets get stableConsumedInsets {
    final incremental = (barHeight - edgeMargin).clamp(0.0, double.infinity);
    return switch (position) {
      LdAppBarPosition.top => EdgeInsets.only(top: incremental),
      LdAppBarPosition.bottom => EdgeInsets.only(bottom: incremental),
    };
  }

  /// Net insets currently visible — animated, shrinks as bar hides.
  ///
  /// = max(0, barHeight - hideOffset - edgeMargin)
  ///
  /// NOT used for the scroll-content padding (that uses [stableConsumedInsets])
  /// but kept for external consumers that want to know the live visible height.
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
    double? accumulatedHideOffset,
    bool? isScrolledUnder,
    int? level,
  }) {
    return LdAppBarMetrics(
      position: position ?? this.position,
      barHeight: barHeight ?? this.barHeight,
      edgeMargin: edgeMargin ?? this.edgeMargin,
      hideOffset: hideOffset ?? this.hideOffset,
      accumulatedHideOffset: accumulatedHideOffset ?? this.accumulatedHideOffset,
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
        other.accumulatedHideOffset == accumulatedHideOffset &&
        other.isScrolledUnder == isScrolledUnder &&
        other.level == level;
  }

  @override
  int get hashCode => Object.hash(
        position,
        barHeight,
        edgeMargin,
        hideOffset,
        accumulatedHideOffset,
        isScrolledUnder,
        level,
      );

  @override
  String toString() => 'LdAppBarMetrics('
      'position: $position, '
      'barHeight: $barHeight, '
      'edgeMargin: $edgeMargin, '
      'hideOffset: $hideOffset, '
      'accumulatedHideOffset: $accumulatedHideOffset, '
      'isScrolledUnder: $isScrolledUnder, '
      'level: $level)';
}
