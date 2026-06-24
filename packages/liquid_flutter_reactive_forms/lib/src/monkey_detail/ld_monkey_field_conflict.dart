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

typedef LdMonkeyFieldConflictResolver = Future<LdMonkeyFieldConflictResolution> Function(
  String fieldKey,
  Object? localValue,
  Object? serverValue,
);
