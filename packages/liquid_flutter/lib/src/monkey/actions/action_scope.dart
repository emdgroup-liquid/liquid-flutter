import 'package:flutter/material.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

/// Route-scoped state for monkey actions: [appContext] and submit controller registry.
class LdMonkeyActionScope<T extends Identifiable<IdType>, IdType> {
  BuildContext? appContext;

  final Map<Object, LdSubmitController<dynamic, LdMonkeyActionContext<T, IdType>>> _submitControllers = {};

  static LdMonkeyActionScope<T, IdType> of<T extends Identifiable<IdType>, IdType>(
    BuildContext context, {
    bool listen = false,
  }) {
    return listen
        ? context.watch<LdMonkeyActionScope<T, IdType>>()
        : context.read<LdMonkeyActionScope<T, IdType>>();
  }

  LdSubmitController<Result, LdMonkeyActionContext<T, IdType>>? submitController<Result>(Object actionId) {
    final controller = _submitControllers[actionId];
    if (controller == null) {
      return null;
    }
    return controller as LdSubmitController<Result, LdMonkeyActionContext<T, IdType>>;
  }

  void registerSubmit(Object actionId, LdSubmitController<dynamic, LdMonkeyActionContext<T, IdType>> controller) {
    _submitControllers[actionId] = controller;
  }

  void unregisterSubmit(Object actionId) {
    _submitControllers.remove(actionId);
  }
}
