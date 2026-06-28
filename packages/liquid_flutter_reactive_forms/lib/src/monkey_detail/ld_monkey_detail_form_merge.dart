import 'package:reactive_forms/reactive_forms.dart';

import 'ld_monkey_field_conflict.dart';
import 'ld_monkey_field_conflict_error.dart';

/// Merges [serverValues] into [form] while respecting dirty controls.
Future<void> ldMonkeyMergeFormFromServer({
  required FormGroup form,
  required Map<String, Object?> serverValues,
  required Map<String, Object?> lastServerValues,
  required LdMonkeyFieldConflictPolicy conflictPolicy,
  Map<String, String?> fieldLabels = const {},
  LdMonkeyFieldConflictResolver? onFieldConflict,
}) async {
  final conflicts = <LdMonkeyFieldConflict>[];

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

    if (control.value == serverValue) {
      control.markAsPristine();
      lastServerValues[key] = serverValue;
      continue;
    }

    final previousServerValue = lastServerValues[key];
    if (serverValue == previousServerValue) {
      continue;
    }

    conflicts.add(
      LdMonkeyFieldConflict(
        fieldKey: key,
        label: fieldLabels[key],
        localValue: control.value,
        serverValue: serverValue,
      ),
    );
  }

  if (conflicts.isEmpty) {
    return;
  }

  await _applyConflictResolutions(
    form: form,
    conflicts: conflicts,
    lastServerValues: lastServerValues,
    conflictPolicy: conflictPolicy,
    onFieldConflict: onFieldConflict,
  );
}

Future<void> _applyConflictResolutions({
  required FormGroup form,
  required List<LdMonkeyFieldConflict> conflicts,
  required Map<String, Object?> lastServerValues,
  required LdMonkeyFieldConflictPolicy conflictPolicy,
  required LdMonkeyFieldConflictResolver? onFieldConflict,
}) async {
  for (final conflict in conflicts) {
    final key = conflict.fieldKey;
    final serverValue = conflict.serverValue;
    final resolution = await _resolveConflict(
      conflict: conflict,
      conflictPolicy: conflictPolicy,
      onFieldConflict: onFieldConflict,
    );

    lastServerValues[key] = serverValue;
    final control = form.control(key);

    switch (resolution) {
      case LdMonkeyFieldConflictResolution.keepLocal:
        control.removeError(kLdMonkeyServerConflictKey);
        break;
      case LdMonkeyFieldConflictResolution.preferServer:
        control.value = serverValue;
        control.markAsPristine();
        control.removeError(kLdMonkeyServerConflictKey);
      case null:
        control.setErrors({
          kLdMonkeyServerConflictKey: LdMonkeyFieldConflictError(
            localValue: conflict.localValue,
            serverValue: serverValue,
          ),
        });
        control.markAsTouched();
    }
  }
}

Future<LdMonkeyFieldConflictResolution?> _resolveConflict({
  required LdMonkeyFieldConflict conflict,
  required LdMonkeyFieldConflictPolicy conflictPolicy,
  required LdMonkeyFieldConflictResolver? onFieldConflict,
}) async {
  return switch (conflictPolicy) {
    LdMonkeyFieldConflictPolicy.keepLocal => LdMonkeyFieldConflictResolution.keepLocal,
    LdMonkeyFieldConflictPolicy.preferServer => LdMonkeyFieldConflictResolution.preferServer,
    LdMonkeyFieldConflictPolicy.prompt => onFieldConflict != null
        ? await onFieldConflict(conflict)
        : null,
  };
}

/// Applies an explicit resolution for a single conflicted field (inline UI).
void ldMonkeyResolveFieldConflict({
  required FormGroup form,
  required LdMonkeyFieldConflict conflict,
  required LdMonkeyFieldConflictResolution resolution,
  required Map<String, Object?> lastServerValues,
}) {
  final control = form.control(conflict.fieldKey);
  lastServerValues[conflict.fieldKey] = conflict.serverValue;

  switch (resolution) {
    case LdMonkeyFieldConflictResolution.keepLocal:
      control.removeError(kLdMonkeyServerConflictKey);
    case LdMonkeyFieldConflictResolution.preferServer:
      control.value = conflict.serverValue;
      control.markAsPristine();
      control.removeError(kLdMonkeyServerConflictKey);
  }
}
