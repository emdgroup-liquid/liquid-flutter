import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';

/// Non-generic scope used by form-field widgets to resolve conflicts without
/// needing to know [TDetail].
class LdFormConflicts {
  final void Function({
    required LdMonkeyFieldConflict conflict,
    required LdMonkeyFieldConflictResolution resolution,
  }) resolveConflict;

  final List<LdMonkeyFieldConflict> conflicts;

  const LdFormConflicts({
    required this.resolveConflict,
    required this.conflicts,
  });
}

/// Exposes detail-form state to custom layouts (e.g. save in an app bar) and
/// to form-field widgets that need to resolve server conflicts.
class LdFormState {
  final LdFormMode mode;
  final bool isSaving;

  /// The detail of [LdDetailForm] of type TDetail.
  final Object? detail;
  final LdFormConflicts conflicts;

  final bool isMergeInProgress;
  final void Function(String fieldKey) onFieldBlurred;
  final void Function(String fieldKey) onFieldCommitted;
  final Future<void> Function() onSubmit;
  final void Function() onReset;
  final void Function(String fieldKey) discardFieldChanges;

  const LdFormState({
    required this.mode,
    required this.isSaving,
    required this.detail,
    required this.onReset,
    required this.discardFieldChanges,
    required this.conflicts,
    required this.isMergeInProgress,
    required this.onFieldBlurred,
    required this.onSubmit,
    required this.onFieldCommitted,
  });

  bool get hasConflicts => conflicts.conflicts.isNotEmpty;
}
