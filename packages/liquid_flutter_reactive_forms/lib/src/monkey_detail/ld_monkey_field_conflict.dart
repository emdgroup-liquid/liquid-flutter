/// How to resolve a field-level conflict when the server value changed while
/// the control is dirty.
enum LdMonkeyFieldConflictPolicy {
  keepLocal,
  preferServer,
  prompt,
}

/// Resolution for a single conflicted field.
enum LdMonkeyFieldConflictResolution {
  keepLocal,
  preferServer,
}

/// A single field whose server value changed while the user was editing it.
class LdMonkeyFieldConflict {
  /// The control key of the conflicted field.
  final String fieldKey;

  /// Human-readable label for the field, when available.
  final String? label;

  /// The value the user currently has in the (dirty) control.
  final Object? localValue;

  /// The value the server reported.
  final Object? serverValue;

  const LdMonkeyFieldConflict({
    required this.fieldKey,
    required this.localValue,
    required this.serverValue,
    this.label,
  });
}

/// Resolves a single conflicted field without showing UI (programmatic
/// override for the [LdMonkeyFieldConflictPolicy.prompt] policy).
typedef LdMonkeyFieldConflictResolver = Future<LdMonkeyFieldConflictResolution> Function(
  LdMonkeyFieldConflict conflict,
);
