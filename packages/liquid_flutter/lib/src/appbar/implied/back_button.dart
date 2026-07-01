import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class LdAppBarBackButton extends StatelessWidget {
  const LdAppBarBackButton({super.key});

  static bool canShow(BuildContext context) {
    if (!context.mounted) return false;

    final parentShows = LdAppBarImpliedFeature.back.shownByParent(context);
    if (parentShows) return false;

    if (context.isInDrawerSlot) return false;

    if (context.isInLdModal) return false;

    if (!context.isInTopAppBar) return false;

    if (!(ModalRoute.of(context)?.isCurrent ?? false)) {
      return false;
    }

    final router = GoRouter.maybeOf(context);
    if (router != null) {
      final rootCanPop = context.canPop();

      if (!rootCanPop) {
        return false;
      }
      return _goRouterCanPop(router, context);
    }

    return false;
  }

  void _popParentRoute(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route?.impliesAppBarDismissal ?? false) {
      route?.navigator?.maybePop();
      return;
    }

    final router = GoRouter.maybeOf(context);
    if (router != null) {
      router.pop();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return LdButton.ghost(
      onPressed: () => _popParentRoute(context),
      child: const Icon(LucideIcons.chevronLeft),
    );
  }
}

/// Returns true if the back button at [context] is inside a navigator that
/// currently has something to pop.
///
/// Checks shell navigators first (for `ShellRoute`-scoped stacks), then falls
/// back to the root GoRouter navigator (for top-level `context.push` calls
/// that land outside any shell, producing an `ImperativeRouteMatch` at the
/// top level of the match list). Using `matches.length > 1` avoids a false
/// positive from open drawers, which add a local history entry to the current
/// route but do not create a new top-level match.
bool _goRouterCanPop(GoRouter router, BuildContext context) {
  final matches = router.routerDelegate.currentConfiguration.matches;
  if (matches.isEmpty) {
    return false;
  }

  // Walk every top-level match entry (there may be more than one when an
  // ImperativeRouteMatch was pushed on top of an existing ShellRouteMatch).
  // For each ShellRouteMatch, check if our context is a descendant of its
  // navigator and if that navigator's page stack can pop.
  for (final topMatch in matches) {
    RouteMatchBase walker = topMatch;
    while (walker is ShellRouteMatch) {
      final navigatorContext = walker.navigatorKey.currentContext;
      final navigatorState = walker.navigatorKey.currentState;

      if (navigatorContext != null &&
          _isDescendant(context, navigatorContext) &&
          (navigatorState?.canPop() ?? false)) {
        return true;
      }
      walker = walker.matches.last;
    }
  }

  // No shell navigator owns the pop. Fall back to checking whether the root
  // GoRouter navigator has more than one page-level match (i.e. an
  // ImperativeRouteMatch was pushed at the top level). This covers a
  // `context.push` over a ShellRoute where the pushed page is rendered by the
  // root navigator. We deliberately avoid using NavigatorState.canPop() here
  // because that also returns true for open drawers (local history entries).
  if (matches.length > 1) {
    final rootNavigatorContext = router.routerDelegate.navigatorKey.currentContext;
    if (rootNavigatorContext != null &&
        _isDescendant(context, rootNavigatorContext)) {
      return true;
    }
  }

  return false;
}

bool _isDescendant(BuildContext descendant, BuildContext ancestor) {
  bool found = false;
  descendant.visitAncestorElements((Element element) {
    if (element == ancestor) {
      found = true;
      return false; // stop visiting
    }
    return true; // continue
  });
  return found;
}
