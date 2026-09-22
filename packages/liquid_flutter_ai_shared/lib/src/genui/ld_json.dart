/// Coerces JSON-decoded maps (`Map<dynamic, dynamic>` included) to
/// `Map<String, Object?>`.
Map<String, Object?>? ldJsonMap(Object? raw) {
  if (raw is Map<String, Object?>) return raw;
  if (raw is Map) return Map<String, Object?>.from(raw);
  return null;
}

String? ldJsonString(Object? raw) => raw is String ? raw : null;

bool? ldJsonBool(Object? raw) => raw is bool ? raw : null;

num? ldJsonNum(Object? raw) => raw is num ? raw : null;

/// Parses [raw] as a list of JSON objects, skipping entries that are not maps.
List<T> ldJsonObjectList<T>(
  Object? raw,
  T Function(Map<String, Object?> json) parse,
) {
  if (raw is! List) return const [];
  final out = <T>[];
  for (final item in raw) {
    final map = ldJsonMap(item);
    if (map == null) continue;
    out.add(parse(map));
  }
  return out;
}

/// Parses [raw] as a list of JSON objects, dropping entries that [tryParse]
/// rejects.
List<T> ldJsonObjectListWhere<T>(
  Object? raw,
  T? Function(Map<String, Object?> json) tryParse,
) {
  if (raw is! List) return const [];
  final out = <T>[];
  for (final item in raw) {
    final map = ldJsonMap(item);
    if (map == null) continue;
    final parsed = tryParse(map);
    if (parsed != null) out.add(parsed);
  }
  return out;
}

List<String> ldJsonStringList(Object? raw) {
  if (raw is! List) return const [];
  return [
    for (final item in raw)
      if (item is String && item.trim().isNotEmpty) item.trim(),
  ];
}

/// Requires [raw] to be a JSON object; throws [FormatException] otherwise.
Map<String, Object?> ldRequireJsonMap(Object? raw, String name) {
  final map = ldJsonMap(raw);
  if (map == null) {
    throw FormatException('$name expects a JSON object');
  }
  return map;
}

String ldRequireString(Object? raw, String field) {
  final value = ldJsonString(raw);
  if (value == null || value.isEmpty) {
    throw FormatException('$field is required');
  }
  return value;
}
