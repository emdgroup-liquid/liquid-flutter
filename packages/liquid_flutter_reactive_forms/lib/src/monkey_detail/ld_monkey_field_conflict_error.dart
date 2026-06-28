/// Validation key for inline server field conflicts.
const kLdMonkeyServerConflictKey = 'serverConflict';

/// Error payload attached to a control when a server conflict is unresolved.
class LdMonkeyFieldConflictError {
  final Object? localValue;
  final Object? serverValue;

  const LdMonkeyFieldConflictError({
    required this.localValue,
    required this.serverValue,
  });
}
