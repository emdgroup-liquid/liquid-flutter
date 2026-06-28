import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'ld_location_lock_registry.dart';

/// [GoRouter.redirect] handler that enforces [LdLocationLockRegistry] locks.
///
/// When navigation would leave a registered path prefix, [LdLocationLock.onLeave]
/// runs. Returning the current URI blocks the navigation; returning `null`
/// allows it after a successful leave callback.
Future<String?> ldLocationLockRedirect(
  BuildContext context,
  GoRouterState state,
) async {
  final registry = LdLocationLockRegistry.maybeOf(context);
  if (registry == null || registry.isEmpty) {
    return null;
  }

  final router = GoRouter.of(context);
  final fromUri = router.state.uri;
  final toPath = normalizeLocationPath(state.uri.path);
  final fromPath = normalizeLocationPath(fromUri.path);

  for (final lock in List<LdLocationLock>.from(registry.locks)) {
    final prefix = normalizeLocationPath(lock.pathPrefix);
    final leaving = isWithinLocationPathPrefix(prefix, fromPath) && !isWithinLocationPathPrefix(prefix, toPath);
    if (!leaving) {
      continue;
    }

    final allowLeave = await lock.onLeave(context);
    if (!allowLeave) {
      return fromUri.toString();
    }

    registry.unregister(lock.id);
  }

  return null;
}

/// Runs [redirects] in order; the first non-null result wins.
GoRouterRedirect ldComposeGoRouterRedirects(
  List<GoRouterRedirect> redirects,
) {
  return (BuildContext context, GoRouterState state) async {
    for (final redirect in redirects) {
      final result = await redirect(context, state);
      if (result != null) {
        return result;
      }
    }
    return null;
  };
}
