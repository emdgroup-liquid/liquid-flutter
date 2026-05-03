import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter/src/monkey/monkey_router_adapter.dart';
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
    print("Disposing deleted items guard");
    _itemsSubscription?.cancel();
    super.dispose();
  }

  void _onItemsChanged(LdPaginatorItem<T> item) {
    final selection = context.read<LdMonkeySelection<T, IdType>?>();

    if (item.state == LdPaginatorItemState.deleted && item.value?.id != null) {
      if (selection != null) {
        if (selection.viewing.contains(item.value?.id!)) {
          MonkeyRouterAdapter.updateViewingItems<T, IdType>(
            context,
            selection.viewing.difference({item.value?.id!}),
          );
        }
        if (selection.selection.contains(item.value?.id!)) {
          MonkeyRouterAdapter.updateSelection<T, IdType>(
            context,
            selection.selection.difference({item.value?.id!}),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LdRepository<T, IdType>>();
    return widget.child;
  }
}
