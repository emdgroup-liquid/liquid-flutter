import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

/// Vertical primary navigation for use as [LdScaffold.drawer] content.
///
/// Accepts the same [LdNavigationTab] destinations as [LdTabNavigation].
/// Destination cells fill the available drawer width and reflow based on
/// [extendedBreakpoint]:
///
/// - **Narrow**: square-ish tiles with a larger icon and smaller label stacked
///   below.
/// - **Wide**: icon beside label in a row (drawer-item style).
class LdNavigationRail extends StatelessWidget {
  /// Suggested initial [LdScaffold.drawerWidth] for a mid-range rail that
  /// can be resized into both compact and extended layouts.
  static const double defaultWidth = 200;
  static const double defaultMinWidth = 70;

  /// Width at/above which destinations use icon + label in a row.
  static const double defaultExtendedBreakpoint = 150;

  final List<LdNavigationTab> destinations;
  final String activeRoute;
  final void Function(String route) onDestinationSelected;
  final Widget? leading;
  final Widget? trailing;
  final double extendedBreakpoint;

  const LdNavigationRail({
    super.key,
    required this.destinations,
    required this.activeRoute,
    required this.onDestinationSelected,
    this.leading,
    this.trailing,
    this.extendedBreakpoint = defaultExtendedBreakpoint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = MediaQuery.paddingOf(context);
        final width = constraints.maxWidth - padding.horizontal;

        final isExtended = width >= extendedBreakpoint;

        return Padding(
          padding: theme.pad(size: LdSize.s) + padding,
          child: MediaQuery.removePadding(
            context: context,
            child: Column(
              key: ValueKey(isExtended ? 'ld-navigation-rail-extended' : 'ld-navigation-rail-compact'),
              children: [
                if (leading != null) ...[
                  leading!,
                  ldSpacerM,
                ],
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: destinations.length,
                    separatorBuilder: (context, index) => ldSpacerS,
                    itemBuilder: (context, index) {
                      final destination = destinations[index];
                      return _LdNavigationRailDestination(
                        destination: destination,
                        active: destination.matches(context, activeRoute),
                        isExtended: isExtended,
                        onPressed: () => onDestinationSelected(destination.route),
                      );
                    },
                  ),
                ),
                if (trailing != null) ...[
                  ldSpacerM,
                  trailing!,
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LdNavigationRailDestination extends StatelessWidget {
  final LdNavigationTab destination;
  final bool active;
  final bool isExtended;
  final VoidCallback onPressed;

  const _LdNavigationRailDestination({
    required this.destination,
    required this.active,
    required this.isExtended,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = LdTheme.of(context, listen: true);

    return LdTouchableSurface(
      active: active,
      onPressed: onPressed,
      builder: (context, status, _) {
        final colors = switch (active) {
          true => ghostColor(theme.primary, theme, status),
          false => neutralGhostColor(theme, status),
        };

        final iconSize = switch (isExtended) {
          true => theme.labelSize(LdSize.l),
          false => theme.labelSize(LdSize.l) * 1.35,
        };

        final icon = IconTheme(
          data: IconThemeData(
            color: colors.icon,
            size: iconSize,
          ),
          child: destination.icon,
        );

        final label = switch (isExtended) {
          true => LdText.l(
              destination.label,
              color: colors.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          false => LdText.ls(
              destination.label,
              color: colors.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
        };

        final content = switch (isExtended) {
          true => Row(
              children: [
                icon,
                ldSpacerS,
                Expanded(child: label),
              ],
            ).padS(),
          false => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                ldSpacerXS,
                label,
              ],
            ).padXS(),
        };

        final tile = Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: theme.radius(LdSize.m),
          ),
          child: content,
        );

        // Compact destinations are square relative to the rail width.
        return switch (isExtended) {
          true => tile,
          false => Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 70,
                  maxHeight: 70,
                ),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: tile,
                ),
              ),
            ),
        };
      },
    );
  }
}
