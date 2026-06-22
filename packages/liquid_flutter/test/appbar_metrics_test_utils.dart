import 'package:flutter/widgets.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Builds [LdAppBarMetrics] using the pre-refactor mental model:
/// [barHeight] = outer margin + inner content, [edgeMargin] = ancestor margin.
LdAppBarMetrics testAppBarMetrics({
  required LdAppBarPosition position,
  required EdgeInsets barHeight,
  EdgeInsets edgeMargin = EdgeInsets.zero,
  EdgeInsets hideOffset = EdgeInsets.zero,
  bool isScrolledUnder = false,
  int level = 0,
  LdAppBarScrollBehavior scrollBehavior = LdAppBarScrollBehavior.static,
  bool willHide = false,
  EdgeInsets systemInsets = EdgeInsets.zero,
  LdAppBarMetrics? parentMetrics,
  MediaQueryData appbarLayerMediaQuery = const MediaQueryData(),
  bool isTabNavigation = false,
}) {
  EdgeInsets innerHeight = EdgeInsets.zero;
  EdgeInsets configuredInsets = edgeMargin;

  for (final edge in const ['top', 'bottom']) {
    final bar = switch (edge) {
      'top' => barHeight.top,
      'bottom' => barHeight.bottom,
      _ => 0.0,
    };
    final margin = switch (edge) {
      'top' => edgeMargin.top,
      'bottom' => edgeMargin.bottom,
      _ => 0.0,
    };
    if (bar > 0) {
      final inner = (bar - margin).clamp(0.0, double.infinity);
      innerHeight = switch (edge) {
        'top' => innerHeight.copyWith(top: inner),
        'bottom' => innerHeight.copyWith(bottom: inner),
        _ => innerHeight,
      };
    }
  }

  return LdAppBarMetrics(
    position: position,
    innerHeight: innerHeight,
    configuredInsets: configuredInsets,
    scrollOffset: hideOffset,
    systemInsets: systemInsets,
    isScrolledUnder: isScrolledUnder,
    level: level,
    willHide: willHide,
    scrollBehavior: scrollBehavior,
    parentMetrics: parentMetrics,
    appbarLayerMediaQuery: appbarLayerMediaQuery,
    isTabNavigation: isTabNavigation,
  );
}

extension LdAppBarMetricsTestGetters on LdAppBarMetrics {
  double get barHeightForPosition => maximumSize.atPosition(position);

  double get hideOffsetForPosition => scrollOffset.atPosition(position);
}
