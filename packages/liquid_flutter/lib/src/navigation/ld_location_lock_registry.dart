import 'package:flutter/widgets.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

/// Callback invoked when navigation would leave [LdLocationLock.pathPrefix].
///
/// Return `true` to allow leaving (the lock is removed). Return `false` to stay.
typedef LdLocationLockOnLeave = Future<bool> Function(BuildContext context);

/// A path-prefix lock that blocks navigation away from [pathPrefix].
///
/// Navigation to the same path or any deeper sub-path is allowed.
///
/// Multiple locks may share the same [pathPrefix] (e.g. several editors on one
/// detail route); only disjoint, non-nested prefixes are treated as conflicts.
class LdLocationLock {
  final String id;
  final String pathPrefix;
  final LdLocationLockOnLeave onLeave;

  const LdLocationLock({
    required this.id,
    required this.pathPrefix,
    required this.onLeave,
  });
}

/// Global registry for path-prefix location locks.
///
/// Mounted by [LdThemeProvider]. Pair with [ldLocationLockRedirect] on
/// [GoRouter.redirect].
class LdLocationLockRegistry extends ChangeNotifier {
  final Map<String, LdLocationLock> _locks = {};
  bool _notifyPending = false;

  Iterable<LdLocationLock> get locks => _locks.values;

  bool get isEmpty => _locks.isEmpty;

  /// Registers or replaces a lock with [lock.id].
  ///
  /// Throws [StateError] when [lock.pathPrefix] conflicts with an existing lock
  /// (disjoint, non-nested prefixes). Locks on the same prefix do not conflict.
  void register(LdLocationLock lock) {
    final normalized = normalizeLocationPath(lock.pathPrefix);
    for (final existing in _locks.values) {
      if (existing.id == lock.id) {
        continue;
      }
      if (locationPathsConflict(existing.pathPrefix, normalized)) {
        throw StateError(
          'Location lock "${lock.id}" at "$normalized" conflicts with '
          'lock "${existing.id}" at "${existing.pathPrefix}".',
        );
      }
    }

    final previous = _locks[lock.id];
    _locks[lock.id] = LdLocationLock(
      id: lock.id,
      pathPrefix: normalized,
      onLeave: lock.onLeave,
    );

    final unchanged = previous != null &&
        normalizeLocationPath(previous.pathPrefix) == normalized;
    if (!unchanged) {
      _notifyListenersSafely();
    }
  }

  void unregister(String id) {
    if (_locks.remove(id) != null) {
      _notifyListenersSafely();
    }
  }

  void clear() {
    if (_locks.isEmpty) {
      return;
    }
    _locks.clear();
    _notifyListenersSafely();
  }

  void _notifyListenersSafely() {
    if (!hasListeners) {
      return;
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle || phase == SchedulerPhase.postFrameCallbacks) {
      notifyListeners();
      return;
    }

    if (_notifyPending) {
      return;
    }
    _notifyPending = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _notifyPending = false;
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  static LdLocationLockRegistry? maybeOf(BuildContext context) {
    try {
      return Provider.of<LdLocationLockRegistry>(context, listen: false);
    } on ProviderNotFoundException {
      return null;
    }
  }

  static LdLocationLockRegistry of(BuildContext context) {
    final registry = maybeOf(context);
    if (registry == null) {
      throw StateError(
        'LdLocationLockRegistry not found. Wrap the app in LdThemeProvider.',
      );
    }
    return registry;
  }
}

/// Normalizes a location path for prefix comparisons.
String normalizeLocationPath(String path) {
  if (path.isEmpty) {
    return '/';
  }
  var normalized = path;
  if (!normalized.startsWith('/')) {
    normalized = '/$normalized';
  }
  while (normalized.length > 1 && normalized.endsWith('/')) {
    normalized = normalized.substring(0, normalized.length - 1);
  }
  return normalized;
}

/// Returns `true` when [path] is [prefix] or a sub-path of [prefix].
bool isWithinLocationPathPrefix(String prefix, String path) {
  final normalizedPrefix = normalizeLocationPath(prefix);
  final normalizedPath = normalizeLocationPath(path);
  if (normalizedPrefix == normalizedPath) {
    return true;
  }
  return normalizedPath.startsWith('$normalizedPrefix/');
}

/// Returns `true` when two lock prefixes cannot be active at the same time.
///
/// Identical prefixes and nested prefixes share a common base and never
/// conflict; only disjoint sibling prefixes do.
bool locationPathsConflict(String a, String b) {
  final normalizedA = normalizeLocationPath(a);
  final normalizedB = normalizeLocationPath(b);
  if (normalizedA == normalizedB) {
    return false;
  }
  if (isWithinLocationPathPrefix(normalizedA, normalizedB) ||
      isWithinLocationPathPrefix(normalizedB, normalizedA)) {
    return false;
  }
  return true;
}
