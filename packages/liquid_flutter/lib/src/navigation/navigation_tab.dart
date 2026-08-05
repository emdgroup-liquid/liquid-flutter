import 'package:flutter/material.dart';

/// A primary navigation destination shared by [LdTabNavigation] and
/// [LdNavigationRail].
class LdNavigationTab {
  final String label;
  final Widget icon;
  final String route;
  final bool Function(BuildContext context)? isActive;

  const LdNavigationTab({
    required this.label,
    required this.icon,
    required this.route,
    this.isActive,
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
