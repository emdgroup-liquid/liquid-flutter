/// Thrown when a save detects a version or field conflict with the server.
class LdMonkeyVersionConflictException<TDetail> implements Exception {
  final TDetail? serverDetail;
  final Map<String, Object?>? serverFieldValues;

  const LdMonkeyVersionConflictException.detail(this.serverDetail) : serverFieldValues = null;

  const LdMonkeyVersionConflictException.fields(this.serverFieldValues) : serverDetail = null;

  @override
  String toString() => 'LdMonkeyVersionConflictException';
}
