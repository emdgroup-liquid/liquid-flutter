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
      return _goRouterCanPop(router, context);
    }

    return false;
  }

  void _popParentRoute(BuildContext context) {
    final router = GoRouter.maybeOf(context);
    if (router == null) {
      Navigator.of(context).maybePop();
      return;
    }

    final shell = _findDeepestPoppableShell(router, context);
    if (shell != null) {
      _popShellMatch(shell);
      return;
    }

    final matches = router.routerDelegate.currentConfiguration.matches;
    if (matches.length > 1) {
      router.pop();
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
/// top level of the match list).
///
/// Uses `matches.length > 1` rather than [NavigatorState.canPop] so open
/// drawers (local history entries) do not produce a false positive.
bool _goRouterCanPop(GoRouter router, BuildContext context) {
  if (_findDeepestPoppableShell(router, context) != null) {
    return true;
  }

  final matches = router.routerDelegate.currentConfiguration.matches;
  if (matches.isEmpty) {
    return false;
  }

  // No shell navigator owns the pop. Fall back to checking whether the root
  // GoRouter navigator has more than one page-level match (i.e. an
  // ImperativeRouteMatch was pushed at the top level). This covers a
  // `context.push` over a ShellRoute where the pushed page is rendered by the
  // root navigator. We deliberately avoid using NavigatorState.canPop() here
  // because that also returns true for open drawers (local history entries).
  if (matches.length > 1) {
    final rootNavigatorContext = router.routerDelegate.navigatorKey.currentContext;
    if (rootNavigatorContext != null && _isDescendant(context, rootNavigatorContext)) {
      return true;
    }
  }

  return false;
}

/// Deepest [ShellRouteMatch] whose navigator owns [context] and has more than
/// one page-level match (a real route to pop, not drawer local history).
ShellRouteMatch? _findDeepestPoppableShell(GoRouter router, BuildContext context) {
  ShellRouteMatch? deepest;
  final matches = router.routerDelegate.currentConfiguration.matches;

  void walk(RouteMatchBase match) {
    if (match is! ShellRouteMatch) {
      return;
    }

    final navigatorContext = match.navigatorKey.currentContext;
    if (navigatorContext != null &&
        _isDescendant(context, navigatorContext) &&
        match.matches.length > 1) {
      deepest = match;
    }

    for (final nested in match.matches) {
      walk(nested);
    }
  }

  for (final match in matches) {
    walk(match);
  }
  return deepest;
}

/// Pops the top page of [shell].
///
/// GoRouter wraps each shell navigator in a [PopScope] with
/// `canPop: matches.length == 1`. That blocks [Navigator.maybePop] on a
/// *parent* navigator when the child shell still has sub-routes (nested
/// master-detail). In that case we force [Navigator.pop] so GoRouter's
/// `onPopPage` can remove the shell match. Otherwise we use [maybePop] so
/// forms / page-level [PopScope]s still work.
void _popShellMatch(ShellRouteMatch shell) {
  assert(shell.matches.length > 1);

  final navigator = shell.navigatorKey.currentState;
  if (navigator == null) {
    return;
  }

  final topMatch = shell.matches.last;
  if (topMatch is ShellRouteMatch && topMatch.matches.length > 1) {
    navigator.pop();
    return;
  }

  navigator.maybePop();
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
