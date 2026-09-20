import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class LdNavigationTabBadge {
  final int? value;
  final LdColor color;
  LdNavigationTabBadge({
    this.value,
    required this.color,
  });
}

/// A primary navigation destination shared by [LdTabNavigation] and
/// [LdNavigationRail].
class LdNavigationTab {
  final String label;
  final Widget icon;
  final String route;
  final LdNavigationTabBadge? badge;

  final bool Function(BuildContext context)? isActive;

  const LdNavigationTab({
    required this.label,
    required this.icon,
    required this.route,
    this.isActive,
    this.badge,
  });

  /// Whether this destination should be highlighted for [activeRoute].
  ///
  /// Uses [isActive] when provided. Otherwise matches [route] exactly, or as a
  /// prefix when [route] ends with `*`.
  bool matches(BuildContext context, String activeRoute) {
    if (isActive != null) {
      return isActive!(context);
    }
    if (route.endsWith('*')) {
      final withoutWildcard = route.substring(0, route.length - 1);
      return activeRoute.startsWith(withoutWildcard);
    }
    return activeRoute == route;
  }
}
