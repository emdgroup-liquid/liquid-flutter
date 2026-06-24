import 'package:reactive_forms/reactive_forms.dart';

import 'ld_monkey_field_conflict.dart';

/// Merges [serverValues] into [form] while respecting dirty controls.
///
/// [lastServerValues] holds the server snapshot from the previous merge; used to
/// detect whether the server changed a field the user is editing.
Future<void> ldMonkeyMergeFormFromServer({
  required FormGroup form,
  required Map<String, Object?> serverValues,
  required Map<String, Object?> lastServerValues,
  required LdMonkeyFieldConflictPolicy conflictPolicy,
  LdMonkeyFieldConflictResolver? onFieldConflict,
  required Future<LdMonkeyFieldConflictResolution> Function(
    String fieldKey,
    Object? localValue,
    Object? serverValue,
  ) promptConflict,
}) async {
  for (final entry in serverValues.entries) {
    final key = entry.key;
    if (!form.contains(key)) {
      continue;
    }

    final control = form.control(key);
    final serverValue = entry.value;

    if (!control.dirty) {
      control.value = serverValue;
      control.markAsPristine();
      lastServerValues[key] = serverValue;
      continue;
    }

    final previousServerValue = lastServerValues[key];
    if (serverValue == previousServerValue) {
      continue;
    }

    final resolution = switch (conflictPolicy) {
      LdMonkeyFieldConflictPolicy.keepLocal => LdMonkeyFieldConflictResolution.keepLocal,
      LdMonkeyFieldConflictPolicy.preferServer => LdMonkeyFieldConflictResolution.preferServer,
      LdMonkeyFieldConflictPolicy.prompt => onFieldConflict != null
          ? await onFieldConflict(key, control.value, serverValue)
          : await promptConflict(key, control.value, serverValue),
    };

    switch (resolution) {
      case LdMonkeyFieldConflictResolution.keepLocal:
        break;
      case LdMonkeyFieldConflictResolution.preferServer:
        control.value = serverValue;
        control.markAsPristine();
        lastServerValues[key] = serverValue;
    }
  }
}
