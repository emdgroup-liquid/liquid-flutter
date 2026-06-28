import 'package:flutter/widgets.dart';

import '../reactive_form_item.dart';

/// Hooks for wiring blur/commit save in [LdMonkeyReactiveDetailForm.itemsBuilder].
class LdMonkeyDetailFormFieldHooks {
  final Future<void> Function()? onSave;

  const LdMonkeyDetailFormFieldHooks({this.onSave});

  void Function(String value)? onBlurred(String key) {
    final save = onSave;
    if (save == null) {
      return null;
    }
    return (_) => save();
  }

  void Function(T value)? onCommitted<T>(String key) {
    final save = onSave;
    if (save == null) {
      return null;
    }
    return (_) => save();
  }
}

typedef LdMonkeyDetailFormItemsBuilder = List<LdReactiveFormItem<dynamic, dynamic>> Function(
  BuildContext context,
  LdMonkeyDetailFormFieldHooks hooks,
);
