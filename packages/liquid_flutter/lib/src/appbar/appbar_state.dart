import 'package:flutter/widgets.dart';

enum LdAppBarPosition {
  top,
  bottom,
}

/// Immutable snapshot of the combined app-bar state at a point in time.
///
/// All per-edge values are stored as [EdgeInsets] so the same object covers
/// both positions simultaneously.  A top bar sets only the `top` component of
/// each inset; a bottom bar sets only `bottom`.  When bars at *both* edges are
/// present the fields accumulate so any descendant can read the correct value
/// for its own edge without knowing which ancestor wrote it.
///
/// [barHeight]              – full rendered height of each bar surface,
///                            including the outer safe-area / ancestor-bar
///                            padding (EdgeInsets, relevant edge non-zero).
/// [edgeMargin]             – outer padding already on each edge before this
///                            bar (device safe-area + ancestor bars' net
///                            heights, EdgeInsets).
/// [hideOffset]             – how many pixels each bar has been scrolled
///                            off-screen (0 = fully visible, EdgeInsets).
///                            Animated.
/// [accumulatedHideOffset]  – cumulative hide from all ancestor bars, per
///                            edge (EdgeInsets).
/// [isScrolledUnder]        – true when scroll content is under any bar.
/// [level]                  – stacking index among bars at the same position
///                            (0 = outermost).
/// [position]               – the position of the bar that last wrote these
///                            metrics.  Kept for callers that need to know
///                            which edge this bar occupies (e.g. level/window-
///                            controls checks).
class LdAppBarMetrics {
  const LdAppBarMetrics({
    required this.position,
    required this.barHeight,
    required this.edgeMargin,
    required this.hideOffset,
    required this.isScrolledUnder,
    required this.level,
    this.accumulatedHideOffset = EdgeInsets.zero,
  });

  final LdAppBarPosition position;

  /// Full outer-container height per edge: edgeMargin + own inner content.
  final EdgeInsets barHeight;

  /// Outer padding already on each edge before this bar (device safe-area +
  /// all ancestor bars' stable net heights).
  final EdgeInsets edgeMargin;

  /// Animated scroll-hide offset per edge (0 = fully visible).
  final EdgeInsets hideOffset;

  /// Cumulative hide offset from all ancestor bars, per edge.
  /// Zero for the outermost bar.
  final EdgeInsets accumulatedHideOffset;

  final bool isScrolledUnder;
  final int level;

  // ── Convenience helpers ────────────────────────────────────────────────────

  /// Scalar bar height for [position]'s edge.
  double get barHeightForPosition =>
      position == LdAppBarPosition.top ? barHeight.top : barHeight.bottom;

  /// Scalar edge margin for [position]'s edge.
  double get edgeMarginForPosition =>
      position == LdAppBarPosition.top ? edgeMargin.top : edgeMargin.bottom;

  /// Scalar hide offset for [position]'s edge.
  double get hideOffsetForPosition =>
      position == LdAppBarPosition.top ? hideOffset.top : hideOffset.bottom;

  /// Scalar accumulated hide offset for [position]'s edge.
  double get accumulatedHideOffsetForPosition =>
      position == LdAppBarPosition.top
          ? accumulatedHideOffset.top
          : accumulatedHideOffset.bottom;

  // ── Consumed-insets helpers ────────────────────────────────────────────────

  /// Net insets this bar contributes to its subtree, stable (never animated).
  ///
  /// For each edge: max(0, barHeight - edgeMargin).
  ///
  /// Used to patch [MediaQuery.padding] for the body subtree so the
  /// scroll-content floor never shifts while the bar animates.
  EdgeInsets get stableConsumedInsets {
    return EdgeInsets.only(
      top: (barHeight.top - edgeMargin.top).clamp(0.0, double.infinity),
      bottom: (barHeight.bottom - edgeMargin.bottom).clamp(0.0, double.infinity),
    );
  }

  /// Net insets currently visible — animated, shrinks as bars hide.
  ///
  /// For each edge: max(0, barHeight - hideOffset - edgeMargin).
  ///
  /// NOT used for the scroll-content padding (that uses [stableConsumedInsets])
  /// but kept for external consumers that want to know the live visible height.
  EdgeInsets get consumedInsets {
    final visibleTop = (barHeight.top - hideOffset.top).clamp(0.0, double.infinity);
    final visibleBottom = (barHeight.bottom - hideOffset.bottom).clamp(0.0, double.infinity);
    return EdgeInsets.only(
      top: (visibleTop - edgeMargin.top).clamp(0.0, double.infinity),
      bottom: (visibleBottom - edgeMargin.bottom).clamp(0.0, double.infinity),
    );
  }

  LdAppBarMetrics copyWith({
    LdAppBarPosition? position,
    EdgeInsets? barHeight,
    EdgeInsets? edgeMargin,
    EdgeInsets? hideOffset,
    EdgeInsets? accumulatedHideOffset,
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
