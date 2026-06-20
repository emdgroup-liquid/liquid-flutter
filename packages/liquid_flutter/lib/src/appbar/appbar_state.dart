import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

// An app bar is a widget that is placed either at the top or bottom of the screen, in the future potentially on the
// left or right side too.
// The difference between an app bar and a normal widget is that an app bar is animated as the user scrolls the content
// This means that it affects the position of other app bars that are nested lower.
// The content however behaves independently of the app bar, meaning it is is not affected by the app bars visibility.
// The outermost app bars also have the job of padding correctly to avoid system bars and other safe areas.
// The challenge is that the parent might be scrolling so far off screen that the current app bar now has the job of
// padding for the screen

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
    required this.innerHeight,
    required this.configuredInsets,
    required this.isScrolledUnder,
    required this.appbarLayerMediaQuery,
    required this.level,
    required this.willHide,
    required this.scrollOffset,
    required this.systemInsets,
    required this.scrollBehavior,
    this.parentMetrics,
  });

  /// True for [modalReset] and other modal-scope baseline values.
  bool get isModalReset => level < 0;

  // Currently either top or bottom.
  final LdAppBarPosition position;

  /// The parent metrics. If this is the outermost app bar, this will be null.
  final LdAppBarMetrics? parentMetrics;

  final LdAppBarScrollBehavior scrollBehavior;

  /// Full inner height of the app bar including the inner padding.
  final EdgeInsets innerHeight;

  /// The margin that this app bar contributes to the total margin that is not inherited from ancestors.
  /// This is not affected by the scroll offset
  final EdgeInsets configuredInsets;

  /// The system insets that this app bar is affected by.
  final EdgeInsets systemInsets;

  /// The margin that this app bar inherited not affected by the scroll offset
  EdgeInsets get cumulatedPlainSizes {
    if (isModalReset) {
      return EdgeInsets.zero;
    }
    // This is just the sum of the inner heights of the ancestors.
    return (innerHeight + configuredInsets) + (parentMetrics?.cumulatedPlainSizes ?? EdgeInsets.zero);
  }

  EdgeInsets get accumulatedEffectiveSizes {
    if (isModalReset) {
      return EdgeInsets.zero;
    }
    final ownSize = (innerHeight + configuredInsets) - scrollOffset;

    return ownSize.atLeast(EdgeInsets.zero) + (parentMetrics?.accumulatedEffectiveSizes ?? EdgeInsets.zero);
  }

  EdgeInsets get accumulatedScrollOffset {
    if (isModalReset) {
      return EdgeInsets.zero;
    }
    return scrollOffset + (parentMetrics?.accumulatedScrollOffset ?? EdgeInsets.zero);
  }

  /// The scroll offset of the app bar. This is the offset that the appbar is currently scrolled. This includes
  /// all margins and the inner height of the app bar.
  final EdgeInsets scrollOffset;

  bool finishedScrolling(LdAppBarPosition position, bool scrollingDown) {
    if (willHide && position == this.position) {
      if (scrollingDown) {
        final didFinish = scrollOffset.atPosition(position) >= maximumSize.atPosition(position);

        return didFinish;
      }
      return scrollOffset.atPosition(position) <= 0;
    }
    return true;
  }

  bool ancestorFinishedScrolling(LdAppBarPosition position, bool scrollingDown) {
    if (finishedScrolling(position, scrollingDown)) {
      if (parentMetrics?.isModalReset ?? false) {
        return true;
      }
      return parentMetrics?.ancestorFinishedScrolling(position, scrollingDown) ?? true;
    }
    return false;
  }

  final bool willHide;

  EdgeInsets cumulatedPositionedSizes(LdAppBarPosition position) {
    if (isModalReset) {
      return EdgeInsets.zero;
    }

    EdgeInsets own = (innerHeight + configuredInsets).inDirection(position);

    if (scrollBehavior == LdAppBarScrollBehavior.hidden) {
      own = EdgeInsets.zero;
    }

    return own + (parentMetrics?.cumulatedPositionedSizes(position) ?? EdgeInsets.zero);
  }

  EdgeInsets get bodyPadding {
    return systemInsets.inDirection(position) + cumulatedPositionedSizes(position);
  }

  /// The maximum size this appbar takes up.
  EdgeInsets get maximumSize => cumulatedPlainSizes + systemInsets;

  /// The size this appbar takes up:
  EdgeInsets get effectiveSize => maximumSize - scrollOffset;

  final MediaQueryData appbarLayerMediaQuery;

  final bool isScrolledUnder;
  final int level;

  LdAppBarMetrics copyWith({
    LdAppBarPosition? position,
    EdgeInsets? innerHeight,
    EdgeInsets? ownMargin,
    EdgeInsets? scrollOffset,
    bool? isScrolledUnder,
    int? level,
    bool? willHide,
    EdgeInsets? systemInsets,
    LdAppBarMetrics? parentMetrics,
    MediaQueryData? appbarLayerMediaQuery,
  }) {
    return LdAppBarMetrics(
      scrollBehavior: scrollBehavior ?? this.scrollBehavior,
      position: position ?? this.position,
      willHide: willHide ?? this.willHide,
      innerHeight: innerHeight ?? this.innerHeight,
      systemInsets: systemInsets ?? this.systemInsets,
      configuredInsets: ownMargin ?? configuredInsets,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      isScrolledUnder: isScrolledUnder ?? this.isScrolledUnder,
      level: level ?? this.level,
      parentMetrics: parentMetrics ?? this.parentMetrics,
      appbarLayerMediaQuery: appbarLayerMediaQuery ?? this.appbarLayerMediaQuery,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LdAppBarMetrics &&
        other.position == position &&
        other.innerHeight == innerHeight &&
        other.configuredInsets == configuredInsets &&
        other.scrollOffset == scrollOffset &&
        other.isScrolledUnder == isScrolledUnder &&
        other.scrollBehavior == scrollBehavior &&
        other.willHide == willHide &&
        other.level == level &&
        other.parentMetrics == parentMetrics &&
        other.systemInsets == systemInsets &&
        other.appbarLayerMediaQuery == appbarLayerMediaQuery;
  }

  @override
  int get hashCode => Object.hash(
        position,
        innerHeight,
        configuredInsets,
        scrollOffset,
        isScrolledUnder,
        level,
        scrollBehavior,
        systemInsets,
        willHide,
        parentMetrics,
        appbarLayerMediaQuery,
      );

  @override
  String toString() => 'LdAppBarMetrics('
      'level: $level, \n'
      'position: $position, \n'
      'innerHeight: $innerHeight, \n'
      'ownMargin: $configuredInsets, \n'
      'scrollOffset: $scrollOffset, \n'
      'isScrolledUnder: $isScrolledUnder, \n'
      'systemInsets: $systemInsets, \n'
      'willHide: $willHide, \n'
      'scrollBehavior: $scrollBehavior, \n'
      'parentMetrics: ${parentMetrics?.toString().split('\n').map((e) {
        return '  $e';
      }).join('\n')}\n'
      'appbarLayerMediaQuery: $appbarLayerMediaQuery)';
}

/// Resolves ancestor [LdAppBarMetrics], treating [LdAppBarMetrics.modalReset] as absent.
LdAppBarMetrics? ldAppBarParentMetrics(BuildContext context) {
  final metrics = Provider.of<LdAppBarMetrics?>(context, listen: true);
  if (metrics != null && metrics.isModalReset) {
    return null;
  }
  return metrics;
}

extension ScalarAtPosition on EdgeInsets {
  double atPosition(LdAppBarPosition position) {
    return switch (position) {
      LdAppBarPosition.top => top,
      LdAppBarPosition.bottom => bottom,
    };
  }

  EdgeInsets inDirection(LdAppBarPosition position) {
    return switch (position) { LdAppBarPosition.top || LdAppBarPosition.bottom => copyWith(left: 0, right: 0) };
  }
}
