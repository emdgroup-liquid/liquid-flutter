import 'package:flutter/widgets.dart';

enum LdAppBarPosition {
  top,
  bottom,
}

/// Immutable snapshot of an app-bar's metrics at a point in time.
///
/// [position]        – whether this bar sits at the top or bottom.
/// [barHeight]       – the full rendered height of the bar (pixels).
/// [edgeMargin]      – additional spacing between the bar and the screen edge
///                     (e.g. floating margin), included in consumed insets.
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

  /// The insets consumed by this bar in the current state.
  ///
  /// For a **top** bar:  `top = barHeight - hideOffset + edgeMargin`, rest 0.
  /// For a **bottom** bar: `bottom = barHeight - hideOffset + edgeMargin`, rest 0.
  EdgeInsets get consumedInsets {
    final visible = (barHeight - hideOffset + edgeMargin).clamp(0.0, double.infinity);
    return switch (position) {
      LdAppBarPosition.top => EdgeInsets.only(top: visible),
      LdAppBarPosition.bottom => EdgeInsets.only(bottom: visible),
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
