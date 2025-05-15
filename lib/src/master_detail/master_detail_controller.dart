import 'package:flutter/foundation.dart';

/// A controller for managing the state of a master-detail view.
///
/// Right now, this controller provides methods to interact with the master-detail state,
/// allowing [LdMasterDetailBuilder]s to open, close, and query the currently open item.
class LdMasterDetailController<T> extends ChangeNotifier {
  /// Returns the currently open item, or null if no item is open.
  final T? Function() getOpenItem;

  /// Opens an item in the detail view.
  ///
  /// Returns a Future<bool> indicating whether the operation was successful.
  final Future<bool> Function(T item) _onOpenItem;

  /// Closes the currently open item.
  final void Function() _onCloseItem;

  /// Creates a new controller with the given callbacks.
  LdMasterDetailController({
    required this.getOpenItem,
    required Future<bool> Function(T) onOpenItem,
    required void Function() onCloseItem,
  })  : _onCloseItem = onCloseItem,
        _onOpenItem = onOpenItem;

  /// Returns true if an item is currently open.
  bool get isItemOpen => getOpenItem() != null;

  /// Opens an item and notifies listeners of the change.
  Future<bool> openItem(T item) async {
    final result = await _onOpenItem(item);
    if (result) {
      notifyListeners();
    }
    return result;
  }

  /// Closes the currently open item and notifies listeners of the change.
  void closeItem() {
    _onCloseItem();
    notifyListeners();
  }
}
