/// Thrown when a save detects a version or field conflict with the server.
class LdFormConflictException<TDetail> implements Exception {
  final TDetail? serverDetail;
  final Map<String, Object?>? serverFieldValues;

  const LdFormConflictException.detail(this.serverDetail) : serverFieldValues = null;

  const LdFormConflictException.fields(this.serverFieldValues) : serverDetail = null;

  @override
  String toString() => 'LdMonkeyVersionConflictException';
}
