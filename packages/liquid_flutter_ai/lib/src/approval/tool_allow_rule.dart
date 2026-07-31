import 'dart:convert';

/// Wildcard sentinel for argument pattern fields.
const ldToolAllowWildcard = '*';

/// How a field is pinned when creating a rule from the approval picker.
enum LdToolAllowPinMode { exact, wildcard }

/// Auto-approve rule: tool name plus partial argument pattern.
class LdToolAllowRule {
  const LdToolAllowRule({
    required this.toolName,
    this.argumentPattern = const {},
    this.wildcard = false,
  });

  factory LdToolAllowRule.wildcardAll({required String toolName}) =>
      LdToolAllowRule(toolName: toolName, wildcard: true);

  final String toolName;
  final Map<String, dynamic> argumentPattern;
  final bool wildcard;

  LdToolAllowRule copyWith({
    String? toolName,
    Map<String, dynamic>? argumentPattern,
    bool? wildcard,
  }) =>
      LdToolAllowRule(
        toolName: toolName ?? this.toolName,
        argumentPattern: argumentPattern ?? this.argumentPattern,
        wildcard: wildcard ?? this.wildcard,
      );

  bool matches(String name, Map<String, dynamic> args) {
    if (toolName != name) {
      return false;
    }
    if (wildcard) {
      return true;
    }
    return LdToolAllowMatcher.matchesPattern(argumentPattern, args);
  }

  Map<String, dynamic> toJson() {
    if (wildcard) {
      return {'tool_name': toolName, 'argument_pattern': '*'};
    }
    return {
      'tool_name': toolName,
      'argument_pattern': argumentPattern,
    };
  }

  factory LdToolAllowRule.fromJson(Map<String, dynamic> json) {
    final toolName =
        json['tool_name'] as String? ?? json['toolName'] as String? ?? '';
    if (toolName.isEmpty) {
      throw FormatException(
        'LdToolAllowRule.fromJson: missing tool_name',
        json,
      );
    }
    final patternRaw = json['argument_pattern'] ?? json['argumentPattern'];
    if (patternRaw == '*') {
      return LdToolAllowRule.wildcardAll(toolName: toolName);
    }
    Map<String, dynamic> pattern = {};
    if (patternRaw is Map) {
      pattern = Map<String, dynamic>.from(patternRaw);
    } else if (patternRaw is String && patternRaw.isNotEmpty) {
      final decoded = jsonDecode(patternRaw);
      if (decoded is Map) {
        pattern = Map<String, dynamic>.from(decoded);
      }
    }
    return LdToolAllowRule(
      toolName: toolName,
      argumentPattern: pattern,
    );
  }

  factory LdToolAllowRule.fromPicker(
    String toolName,
    Map<String, dynamic> args,
    Map<String, LdToolAllowPinMode> pins,
  ) {
    final pattern = <String, dynamic>{};
    final sortedPins = pins.entries.toList()
      ..sort((a, b) => a.key.length.compareTo(b.key.length));
    for (final entry in sortedPins) {
      final parentPath = _parentPath(entry.key);
      if (parentPath.isNotEmpty &&
          pins[parentPath] == LdToolAllowPinMode.wildcard) {
        continue;
      }
      if (entry.value == LdToolAllowPinMode.wildcard) {
        _setAtPath(pattern, entry.key, ldToolAllowWildcard);
      } else {
        final value = _valueAtPath(args, entry.key);
        if (value != null) {
          _setAtPath(pattern, entry.key, value);
        }
      }
    }
    return LdToolAllowRule(toolName: toolName, argumentPattern: pattern);
  }

  /// Stable id for list/settings use (canonical base64 JSON).
  static String idFor(LdToolAllowRule rule) {
    final canonical = jsonEncode({
      if (rule.wildcard) 'wildcard': true,
      'tool_name': rule.toolName,
      'argument_pattern': _canonicalMap(rule.argumentPattern),
    });
    return base64Url.encode(utf8.encode(canonical));
  }

  static Map<String, dynamic> _canonicalMap(Map<String, dynamic> map) {
    final sorted = <String, dynamic>{};
    for (final key in map.keys.toList()..sort()) {
      final value = map[key];
      sorted[key] = value is Map<String, dynamic>
          ? _canonicalMap(value)
          : value is Map
          ? _canonicalMap(Map<String, dynamic>.from(value))
          : value;
    }
    return sorted;
  }

  static String _parentPath(String path) {
    final dot = path.lastIndexOf('.');
    return dot == -1 ? '' : path.substring(0, dot);
  }

  static void _setAtPath(Map<String, dynamic> root, String path, Object value) {
    final parts = path.split('.');
    var current = root;
    for (var i = 0; i < parts.length - 1; i++) {
      final key = parts[i];
      final next = current[key];
      if (next is! Map<String, dynamic>) {
        current[key] = <String, dynamic>{};
      }
      current = current[key]! as Map<String, dynamic>;
    }
    current[parts.last] = value;
  }

  static dynamic _valueAtPath(Map<String, dynamic> root, String path) {
    final parts = path.split('.');
    dynamic current = root;
    for (final part in parts) {
      if (current is! Map) {
        return null;
      }
      current = current[part];
    }
    return current;
  }

  @override
  bool operator ==(Object other) =>
      other is LdToolAllowRule &&
      toolName == other.toolName &&
      wildcard == other.wildcard &&
      _mapEquals(argumentPattern, other.argumentPattern);

  @override
  int get hashCode =>
      Object.hash(toolName, wildcard, Object.hashAll(argumentPattern.entries));

  static bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) {
      return false;
    }
    for (final key in a.keys) {
      if (!b.containsKey(key)) {
        return false;
      }
      if (!_deepEquals(a[key], b[key])) {
        return false;
      }
    }
    return true;
  }

  static bool _deepEquals(dynamic a, dynamic b) {
    if (a is Map && b is Map) {
      return _mapEquals(
        Map<String, dynamic>.from(a),
        Map<String, dynamic>.from(b),
      );
    }
    if (a is List && b is List) {
      if (a.length != b.length) {
        return false;
      }
      for (var i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) {
          return false;
        }
      }
      return true;
    }
    return a == b;
  }
}

bool ldIsToolAutoApproved(
  String toolName,
  Map<String, dynamic> args,
  List<LdToolAllowRule> rules,
) {
  return rules.any((r) => r.matches(toolName, args));
}

/// Merges a list of allow rules into a minimal deduplicated set.
/// Rules for the same tool are collapsed into a single rule with list-valued
/// fields (OR semantics). Wildcard rules override more specific ones.
List<LdToolAllowRule> ldMergeToolAllowRules(List<LdToolAllowRule> rules) {
  if (rules.isEmpty) {
    return [];
  }

  final byTool = <String, List<LdToolAllowRule>>{};
  for (final rule in rules) {
    byTool.putIfAbsent(rule.toolName, () => []).add(rule);
  }

  final result = <LdToolAllowRule>[];
  for (final entry in byTool.entries) {
    result.add(_mergeGroup(entry.key, entry.value));
  }
  return result;
}

LdToolAllowRule _mergeGroup(String toolName, List<LdToolAllowRule> group) {
  if (group.any((r) => r.wildcard)) {
    return LdToolAllowRule.wildcardAll(toolName: toolName);
  }

  final emptyPattern = group.any((r) => r.argumentPattern.isEmpty);
  if (emptyPattern) {
    return LdToolAllowRule.wildcardAll(toolName: toolName);
  }

  final allKeys = <String>{};
  for (final rule in group) {
    _collectKeys(rule.argumentPattern, '', allKeys);
  }

  final mergedPattern = <String, dynamic>{};
  for (final key in allKeys) {
    final values = <dynamic>{};
    for (final rule in group) {
      final v = _valueAtPathInPattern(rule.argumentPattern, key);
      if (v == null) {
        values.add(null);
      } else if (v == ldToolAllowWildcard) {
        values.add(ldToolAllowWildcard);
      } else {
        values.add(v);
      }
    }
    if (values.contains(ldToolAllowWildcard)) {
      _setAtPathInMerge(mergedPattern, key, ldToolAllowWildcard);
    } else if (values.length == 1) {
      _setAtPathInMerge(mergedPattern, key, values.first);
    } else {
      _setAtPathInMerge(mergedPattern, key, values.toList());
    }
  }

  return LdToolAllowRule(toolName: toolName, argumentPattern: mergedPattern);
}

void _setAtPathInMerge(Map<String, dynamic> root, String path, Object value) {
  final parts = path.split('.');
  var current = root;
  for (var i = 0; i < parts.length - 1; i++) {
    final key = parts[i];
    final next = current[key];
    if (next is! Map<String, dynamic>) {
      current[key] = <String, dynamic>{};
    }
    current = current[key]! as Map<String, dynamic>;
  }
  current[parts.last] = value;
}

void _collectKeys(Map<String, dynamic> map, String prefix, Set<String> keys) {
  for (final entry in map.entries) {
    final path = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
    keys.add(path);
    if (entry.value is Map && entry.value != ldToolAllowWildcard) {
      _collectKeys(Map<String, dynamic>.from(entry.value as Map), path, keys);
    }
  }
}

dynamic _valueAtPathInPattern(Map<String, dynamic> root, String path) {
  final parts = path.split('.');
  dynamic current = root;
  for (final part in parts) {
    if (current is! Map) {
      return null;
    }
    current = current[part];
  }
  return current;
}

class LdToolAllowMatcher {
  static bool matchesPattern(
    Map<String, dynamic> pattern,
    Map<String, dynamic> actual,
  ) {
    for (final entry in actual.entries) {
      if (!pattern.containsKey(entry.key)) {
        return false;
      }
      if (!_valuesMatch(pattern[entry.key], entry.value)) {
        return false;
      }
    }
    for (final entry in pattern.entries) {
      final hasActual = actual.containsKey(entry.key);
      if (!hasActual) {
        if (_allowsAbsent(entry.value)) {
          continue;
        }
        return false;
      }
    }
    return true;
  }

  static bool _allowsAbsent(dynamic value) {
    if (value is List) {
      return value.any((e) => e == null);
    }
    return false;
  }

  static bool _valuesMatch(dynamic expected, dynamic actual) {
    if (expected == ldToolAllowWildcard) {
      return true;
    }
    if (expected is List) {
      for (final element in expected) {
        if (element == null) {
          continue;
        }
        if (_valuesMatchSingle(element, actual)) {
          return true;
        }
      }
      return false;
    }
    return _valuesMatchSingle(expected, actual);
  }

  static bool _valuesMatchSingle(dynamic expected, dynamic actual) {
    if (expected == ldToolAllowWildcard) {
      return true;
    }
    if (expected is Map && actual is Map) {
      return matchesPattern(
        Map<String, dynamic>.from(expected),
        Map<String, dynamic>.from(actual),
      );
    }
    return expected == actual;
  }
}

Map<String, dynamic> ldParseToolArguments(Object? raw) {
  if (raw == null) {
    return {};
  }
  if (raw is Map<String, dynamic>) {
    return raw;
  }
  if (raw is Map) {
    return Map<String, dynamic>.from(raw);
  }
  final str = raw is String ? raw : raw.toString();
  if (str.isEmpty) {
    return {};
  }
  try {
    dynamic decoded = jsonDecode(str);
    if (decoded is String) {
      decoded = jsonDecode(decoded);
    }
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
  } catch (_) {
    return {};
  }
  return {};
}

Map<String, LdToolAllowPinMode> ldDefaultPinsForArgs(
  Map<String, dynamic> args,
) {
  final pins = <String, LdToolAllowPinMode>{};
  void walk(Map<String, dynamic> map, String prefix) {
    for (final entry in map.entries) {
      final path = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      pins[path] = LdToolAllowPinMode.exact;
      if (entry.value is Map) {
        walk(Map<String, dynamic>.from(entry.value as Map), path);
      }
    }
  }

  walk(args, '');
  return pins;
}

/// Pins derived from an existing rule pattern (for the editor).
Map<String, LdToolAllowPinMode> ldPinsFromPattern(
  Map<String, dynamic> pattern,
) {
  final pins = <String, LdToolAllowPinMode>{};
  void walk(Map<String, dynamic> map, String prefix) {
    for (final entry in map.entries) {
      final path = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      if (entry.value == ldToolAllowWildcard) {
        pins[path] = LdToolAllowPinMode.wildcard;
      } else if (entry.value is Map) {
        pins[path] = LdToolAllowPinMode.exact;
        walk(Map<String, dynamic>.from(entry.value as Map), path);
      } else {
        pins[path] = LdToolAllowPinMode.exact;
      }
    }
  }

  walk(pattern, '');
  return pins;
}

/// Flattened argument map used as "exact" values when editing a saved pattern.
Map<String, dynamic> ldArgsFromPattern(Map<String, dynamic> pattern) {
  final args = <String, dynamic>{};
  void walk(Map<String, dynamic> map, String prefix) {
    for (final entry in map.entries) {
      final path = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      if (entry.value == ldToolAllowWildcard) {
        continue;
      }
      if (entry.value is Map) {
        walk(Map<String, dynamic>.from(entry.value as Map), path);
      } else if (entry.value is List) {
        // Prefer first non-null alternative as display/exact value.
        final list = entry.value as List;
        final first = list.cast<dynamic>().firstWhere(
          (v) => v != null,
          orElse: () => null,
        );
        if (first != null) {
          _setNested(args, path, first);
        }
      } else {
        _setNested(args, path, entry.value);
      }
    }
  }

  walk(pattern, '');
  return args;
}

void _setNested(Map<String, dynamic> root, String path, Object? value) {
  final parts = path.split('.');
  var current = root;
  for (var i = 0; i < parts.length - 1; i++) {
    final key = parts[i];
    final next = current[key];
    if (next is! Map<String, dynamic>) {
      current[key] = <String, dynamic>{};
    }
    current = current[key]! as Map<String, dynamic>;
  }
  current[parts.last] = value;
}

dynamic ldValueAtArgumentPath(Map<String, dynamic> root, String path) {
  final parts = path.split('.');
  dynamic current = root;
  for (final part in parts) {
    if (current is! Map) {
      return null;
    }
    current = current[part];
  }
  return current;
}

Set<String> ldComputeMapPaths(Map<String, dynamic> args) {
  final mapPaths = <String>{};
  void walk(Map<String, dynamic> map, String prefix) {
    for (final entry in map.entries) {
      final path = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      if (entry.value is Map) {
        mapPaths.add(path);
        walk(Map<String, dynamic>.from(entry.value as Map), path);
      }
    }
  }

  walk(args, '');
  return mapPaths;
}

String ldSummarizeArgumentPattern(Map<String, dynamic> pattern) {
  if (pattern.isEmpty) {
    return 'no arguments';
  }
  final parts = <String>[];
  void walk(Map<String, dynamic> map, String prefix) {
    for (final entry in map.entries) {
      final path = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
      if (entry.value == ldToolAllowWildcard) {
        parts.add('$path=*');
      } else if (entry.value is List) {
        final alternatives = <String>[];
        for (final v in entry.value as List) {
          if (v == null) {
            alternatives.add('(no $path)');
          } else {
            alternatives.add('$path=$v');
          }
        }
        parts.add(alternatives.join(' OR '));
      } else if (entry.value is Map) {
        walk(Map<String, dynamic>.from(entry.value as Map), path);
      } else {
        parts.add('$path=${entry.value}');
      }
    }
  }

  walk(pattern, '');
  return parts.join('\n');
}
