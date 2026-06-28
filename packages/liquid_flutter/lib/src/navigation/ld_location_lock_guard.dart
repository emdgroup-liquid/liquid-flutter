import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/src/navigation/ld_location_lock_registry.dart';

/// Registers an [LdLocationLock] while [locked] and blocks predictive back via
/// [PopScope].
///
/// Use for detail editors and create routes with unsaved edits. When a pop is
/// blocked, [onBlockedPop] runs (typically showing a discard prompt).
class LdLocationLockGuard extends StatefulWidget {
  final bool locked;
  final Widget child;
  final String? lockId;
  final String? pathPrefix;
  final Future<bool> Function(BuildContext context) onLeave;
  final Future<void> Function(Object? popResult)? onBlockedPop;

  const LdLocationLockGuard({
    super.key,
    required this.locked,
    required this.child,
    required this.onLeave,
    this.lockId,
    this.pathPrefix,
    this.onBlockedPop,
  });

  @override
  State<LdLocationLockGuard> createState() => _LdLocationLockGuardState();
}

class _LdLocationLockGuardState extends State<LdLocationLockGuard> {
  LdLocationLockRegistry? _lockRegistry;
  late final String _lockId = widget.lockId ?? 'ldLocationLockGuard-${identityHashCode(this)}';
  bool _lockRegistered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lockRegistry = LdLocationLockRegistry.maybeOf(context);
    _syncLocationLock();
  }

  @override
  void didUpdateWidget(covariant LdLocationLockGuard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locked != widget.locked ||
        oldWidget.pathPrefix != widget.pathPrefix ||
        oldWidget.lockId != widget.lockId) {
      _syncLocationLock();
    }
  }

  @override
  void dispose() {
    if (_lockRegistered) {
      _lockRegistry?.unregister(_lockId);
    }
    super.dispose();
  }

  void _syncLocationLock() {
    final registry = _lockRegistry;
    if (registry == null) {
      return;
    }

    if (!widget.locked) {
      if (_lockRegistered) {
        registry.unregister(_lockId);
        _lockRegistered = false;
      }
      return;
    }

    final pathPrefix = widget.pathPrefix ?? GoRouter.of(context).state.uri.path;
    registry.register(
      LdLocationLock(
        id: _lockId,
        pathPrefix: pathPrefix,
        onLeave: widget.onLeave,
      ),
    );
    _lockRegistered = true;
  }

  Future<void> _handleBlockedPop(Object? result) async {
    final onBlockedPop = widget.onBlockedPop;
    if (onBlockedPop != null) {
      await onBlockedPop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.locked,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        if (widget.locked) {
          _handleBlockedPop(result);
        }
      },
      child: widget.child,
    );
  }
}
