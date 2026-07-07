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
  final Set<IdType> _pendingDeletedIds = {};

  bool _flushScheduled = false;

  @override
  void initState() {
    super.initState();
    final repository = context.read<LdListController<T, IdType>>();
    _itemsSubscription = repository.updatedItems.listen(_onItemsChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _itemsSubscription?.cancel();
    final repository = context.read<LdListController<T, IdType>>();
    _itemsSubscription = repository.updatedItems.listen(_onItemsChanged);
  }

  @override
  void dispose() {
    _itemsSubscription?.cancel();
    super.dispose();
  }

  void _onItemsChanged(LdPaginatorItem<T> item) {
    if (item.state != LdPaginatorItemState.deleted) {
      return;
    }
    if (item.value != null) {
      _pendingDeletedIds.add(item.value!.id);
    }
    _scheduleFlush();
  }

  void _scheduleFlush() {
    if (_flushScheduled) {
      return;
    }
    _flushScheduled = true;
    Future.delayed(Duration(milliseconds: 500), _flushPendingDeletions);
  }

  void _flushPendingDeletions() {
    _flushScheduled = false;
    if (!mounted) {
      return;
    }

    final selection = context.read<LdMonkeySelection<T, IdType>?>();
    if (selection == null) {
      return;
    }

    // Merge any ids tracked by the controller's detached map (covers real
    // delete flows) with ids accumulated from the stream (covers test stubs
    // that call notifyItemUpdated directly without going through the model).
    final deletedIds = {
      ...context.read<LdListController<T, IdType>>().deletedItems.map((item) => item.value!.id),
      ..._pendingDeletedIds,
    };
    _pendingDeletedIds.clear();

    final newViewing = selection.viewing.difference(deletedIds);
    final newSelection = selection.selection.difference(deletedIds);

    // Only drop ids once the route no longer references them; clearing earlier
    // would lose track of removals while the router is still catching up.

    if (!setEquals(newViewing, selection.viewing)) {
      LdMonkeySelection.updateViewing<T, IdType>(context, newViewing);
    }
    if (!setEquals(newSelection, selection.selection)) {
      LdMonkeySelection.updateSelection<T, IdType>(context, newSelection);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
