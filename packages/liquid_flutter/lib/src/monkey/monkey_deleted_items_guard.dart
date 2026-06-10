import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class LdMonkeyDeletedItemsGuard<T extends Identifiable<IdType>, IdType> extends StatefulWidget {
  final Widget child;

  const LdMonkeyDeletedItemsGuard({
    super.key,
    required this.child,
  });

  @override
  State<LdMonkeyDeletedItemsGuard<T, IdType>> createState() => _LdMonkeyDeletedItemsGuardState<T, IdType>();
}

class _LdMonkeyDeletedItemsGuardState<T extends Identifiable<IdType>, IdType>
    extends State<LdMonkeyDeletedItemsGuard<T, IdType>> {
  StreamSubscription<LdPaginatorItem<T>>? _itemsSubscription;

  /// Accumulates deleted ids until the router has caught up. Without this,
  /// rapid deletions each read stale selection from the URL and overwrite
  /// one another with partial updates.
  final Set<IdType> _deletedIds = {};
  bool _flushScheduled = false;

  /// Router updates are async; track what we already dispatched so we do not
  /// call [router.replace] again while the URL still reflects the old state.
  Set<IdType>? _pendingSelection;
  Set<IdType>? _pendingViewing;

  @override
  void initState() {
    super.initState();
    final repository = context.read<LdRepository<T, IdType>>();
    _itemsSubscription = repository.updatedItems.listen(_onItemsChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _itemsSubscription?.cancel();
    final repository = context.read<LdRepository<T, IdType>>();
    _itemsSubscription = repository.updatedItems.listen(_onItemsChanged);
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    super.dispose();
  }

  void _onItemsChanged(LdPaginatorItem<T> item) {
    if (item.state != LdPaginatorItemState.deleted || item.value?.id == null) {
      return;
    }
    _deletedIds.add(item.value!.id);
    _scheduleFlush();
  }

  void _scheduleFlush() {
    if (_flushScheduled) {
      return;
    }
    _flushScheduled = true;
    scheduleMicrotask(_flushPendingDeletions);
  }

  void _flushPendingDeletions() {
    _flushScheduled = false;
    if (!mounted || _deletedIds.isEmpty) {
      return;
    }

    final selection = context.read<LdMonkeySelection<T, IdType>?>();
    if (selection == null) {
      return;
    }

    final newViewing = selection.viewing.difference(_deletedIds);
    final newSelection = selection.selection.difference(_deletedIds);

    // Only drop ids once the route no longer references them; clearing earlier
    // would lose track of removals while the router is still catching up.
    _deletedIds.removeWhere(
      (id) => !selection.selection.contains(id) && !selection.viewing.contains(id),
    );

    if (!setEquals(newViewing, selection.viewing) &&
        (_pendingViewing == null || !setEquals(newViewing, _pendingViewing!))) {
      _pendingViewing = newViewing;
      LdMonkeySelection.updateViewing<T, IdType>(context, newViewing);
    }
    if (!setEquals(newSelection, selection.selection) &&
        (_pendingSelection == null || !setEquals(newSelection, _pendingSelection!))) {
      _pendingSelection = newSelection;
      LdMonkeySelection.updateSelection<T, IdType>(context, newSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LdRepository<T, IdType>>();
    final selection = context.watch<LdMonkeySelection<T, IdType>?>();
    if (selection != null) {
      if (_pendingSelection != null && setEquals(selection.selection, _pendingSelection!)) {
        _pendingSelection = null;
      }
      if (_pendingViewing != null && setEquals(selection.viewing, _pendingViewing!)) {
        _pendingViewing = null;
      }
      if (_deletedIds.isNotEmpty) {
        _deletedIds.removeWhere(
          (id) => !selection.selection.contains(id) && !selection.viewing.contains(id),
        );
      }
    }
    return widget.child;
  }
}
