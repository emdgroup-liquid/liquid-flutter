import 'dart:convert';

import 'package:liquid_flutter_ai_shared/src/tool_allow_schema.dart';

/// Wildcard sentinel for argument pattern fields.
const ldToolAllowWildcard = '*';

/// How a field is pinned when creating a rule from the approval picker.
enum LdToolAllowPinMode {
  /// Emit a concrete value (or list OR of values) into the pattern.
  exact,

  /// Emit [ldToolAllowWildcard] (any value, or key absent).
  wildcard,

  /// UI-only: omit the path from the pattern (must stay absent for auto-approve).
  notAllowed,
}

/// Pin state for one argument path.
class LdToolAllowFieldPin {
  const LdToolAllowFieldPin({
    required this.mode,
    this.values = const [],
  });

  final LdToolAllowPinMode mode;

  /// Allowed values when [mode] is [LdToolAllowPinMode.exact] (leaf OR).
  final List<Object?> values;

  LdToolAllowFieldPin copyWith({
    LdToolAllowPinMode? mode,
    List<Object?>? values,
  }) =>
      LdToolAllowFieldPin(
        mode: mode ?? this.mode,
        values: values ?? this.values,
      );

  String get summaryLabel {
    return switch (mode) {
      LdToolAllowPinMode.wildcard => 'Any',
      LdToolAllowPinMode.notAllowed => 'Not allowed',
      LdToolAllowPinMode.exact => values.isEmpty
          ? '—'
          : values.map(_formatPinValue).join(' | '),
    };
  }

  static String _formatPinValue(Object? value) {
    if (value == null) {
      return 'null';
    }
    if (value is List) {
      return '[${value.map(_formatPinValue).join(', ')}]';
    }
    return '$value';
  }
}

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

  /// Builds a rule from legacy mode-only pins and a display [args] map.
  factory LdToolAllowRule.fromPicker(
    String toolName,
    Map<String, dynamic> args,
    Map<String, LdToolAllowPinMode> pins,
  ) {
    final fieldPins = <String, LdToolAllowFieldPin>{};
    for (final entry in pins.entries) {
      if (entry.value == LdToolAllowPinMode.exact) {
        final value = _valueAtPath(args, entry.key);
        fieldPins[entry.key] = LdToolAllowFieldPin(
          mode: LdToolAllowPinMode.exact,
          values: value == null ? const [] : [value],
        );
      } else {
        fieldPins[entry.key] = LdToolAllowFieldPin(mode: entry.value);
      }
    }
    return LdToolAllowRule.fromFieldPins(toolName, fieldPins);
  }

  /// Builds a rule from rich field pins (supports multi-value leaves).
  factory LdToolAllowRule.fromFieldPins(
    String toolName,
    Map<String, LdToolAllowFieldPin> pins, {
    Set<String>? objectPaths,
  }) {
    final pattern = ldBuildArgumentPattern(pins, objectPaths: objectPaths);
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

  /// Whether [value] permits the key to be missing from the call args.
  ///
  /// Field wildcards mean "don't care" (present with any value, or absent).
  /// Explicit `null` in an OR list also allows absence (see merge).
  static bool _allowsAbsent(dynamic value) {
    if (value == ldToolAllowWildcard) {
      return true;
    }
    if (value is List) {
      return value.any(
        (e) => e == null || e == ldToolAllowWildcard,
      );
    }
    return false;
  }

  static bool _valuesMatch(dynamic expected, dynamic actual) {
    if (expected == ldToolAllowWildcard) {
      return true;
    }
    if (expected is List) {
      // List in the pattern is always OR of alternatives.
      // Array-typed tool args are stored as nested lists: [["a","b"]].
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
    if (expected is List && actual is List) {
      return _listEquals(expected, actual);
    }
    return expected == actual;
  }

  static bool _listEquals(List expected, List actual) {
    if (expected.length != actual.length) {
      return false;
    }
    for (var i = 0; i < expected.length; i++) {
      if (!_valuesMatchSingle(expected[i], actual[i])) {
        return false;
      }
    }
    return true;
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

/// Emits an argument pattern from field pins.
Map<String, dynamic> ldBuildArgumentPattern(
  Map<String, LdToolAllowFieldPin> pins, {
  Set<String>? objectPaths,
}) {
  final pattern = <String, dynamic>{};
  final objects = objectPaths ??
      pins.entries
          .where(
            (e) =>
                e.value.mode == LdToolAllowPinMode.exact &&
                e.value.values.any((v) => v is Map),
          )
          .map((e) => e.key)
          .toSet();

  bool suppressed(String path) {
    var parent = _parentPathPublic(path);
    while (parent.isNotEmpty) {
      final parentPin = pins[parent];
      if (parentPin != null &&
          (parentPin.mode == LdToolAllowPinMode.wildcard ||
              parentPin.mode == LdToolAllowPinMode.notAllowed)) {
        return true;
      }
      parent = _parentPathPublic(parent);
    }
    return false;
  }

  final sortedPins = pins.entries.toList()
    ..sort((a, b) => a.key.length.compareTo(b.key.length));

  for (final entry in sortedPins) {
    if (suppressed(entry.key)) {
      continue;
    }
    final pin = entry.value;
    switch (pin.mode) {
      case LdToolAllowPinMode.notAllowed:
        continue;
      case LdToolAllowPinMode.wildcard:
        _setAtPathPublic(pattern, entry.key, ldToolAllowWildcard);
      case LdToolAllowPinMode.exact:
        final isObject = objects.contains(entry.key);
        if (isObject) {
          final existing = _valueAtPathPublic(pattern, entry.key);
          if (existing is! Map) {
            _setAtPathPublic(pattern, entry.key, <String, dynamic>{});
          }
        } else {
          final values = pin.values.where((v) => v is! Map).toList();
          if (values.isEmpty) {
            continue;
          }
          // Array-typed pins store each alternative as a List. Emit them as an
          // OR list even when there is only one, so the matcher can deep-compare
          // lists without confusing them with scalar OR alternatives.
          if (values.every((v) => v is List)) {
            _setAtPathPublic(pattern, entry.key, values);
          } else if (values.length == 1) {
            _setAtPathPublic(pattern, entry.key, values.first);
          } else {
            _setAtPathPublic(pattern, entry.key, values);
          }
        }
    }
  }
  return pattern;
}

String _parentPathPublic(String path) {
  final dot = path.lastIndexOf('.');
  return dot == -1 ? '' : path.substring(0, dot);
}

void _setAtPathPublic(Map<String, dynamic> root, String path, Object? value) {
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

dynamic _valueAtPathPublic(Map<String, dynamic> root, String path) {
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

/// Session model for picker/editor: schema meta + pins + root keys.
class LdToolAllowFieldSession {
  const LdToolAllowFieldSession({
    required this.schemaMeta,
    required this.pins,
    required this.rootKeys,
    required this.objectPaths,
    this.callArgs,
  });

  final Map<String, LdToolAllowSchemaMeta> schemaMeta;
  final Map<String, LdToolAllowFieldPin> pins;
  final List<String> rootKeys;
  final Set<String> objectPaths;

  /// When non-null, [toRule] treats this as an approval against a concrete call
  /// (picker). Exact pins on paths absent from the call include `null` so the
  /// current request still matches. Editor sessions leave this null.
  final Map<String, dynamic>? callArgs;

  LdToolAllowFieldSession copyWithPins(
    Map<String, LdToolAllowFieldPin> nextPins,
  ) =>
      LdToolAllowFieldSession(
        schemaMeta: schemaMeta,
        pins: nextPins,
        rootKeys: rootKeys,
        objectPaths: objectPaths,
        callArgs: callArgs,
      );

  LdToolAllowRule toRule(String toolName) {
    final args = callArgs;
    if (args == null) {
      return LdToolAllowRule.fromFieldPins(
        toolName,
        pins,
        objectPaths: objectPaths,
      );
    }

    // Broader Fixed pins on optional fields the call omitted: allow absence
    // (same as merge when combining a rule without the key and one with it).
    final adjusted = <String, LdToolAllowFieldPin>{};
    for (final entry in pins.entries) {
      final pin = entry.value;
      final path = entry.key;
      if (pin.mode == LdToolAllowPinMode.exact &&
          !objectPaths.contains(path) &&
          !_argumentPathExists(args, path) &&
          pin.values.isNotEmpty &&
          !pin.values.contains(null)) {
        adjusted[path] = pin.copyWith(values: [null, ...pin.values]);
      } else {
        adjusted[path] = pin;
      }
    }

    return LdToolAllowRule.fromFieldPins(
      toolName,
      adjusted,
      objectPaths: objectPaths,
    );
  }
}

bool _argumentPathExists(Map<String, dynamic> args, String path) {
  final parts = path.split('.');
  dynamic current = args;
  for (final part in parts) {
    if (current is! Map || !current.containsKey(part)) {
      return false;
    }
    current = current[part];
  }
  return true;
}

/// Builds picker/editor field state from schema, call args, and optional seed.
LdToolAllowFieldSession ldBuildToolAllowFieldSession({
  Object? inputSchema,
  Object? arguments,
  LdToolAllowRule? seedRule,
}) {
  // Null [arguments] means editor (no concrete call). Empty map is a real call.
  final hasCallContext = arguments != null;
  final callArgs = ldParseToolArguments(arguments);
  final schemaMeta = ldParseToolInputSchema(inputSchema);
  final seedPattern =
      seedRule != null && !seedRule.wildcard ? seedRule.argumentPattern : null;

  final paths = <String>{};
  paths.addAll(schemaMeta.keys);
  _collectArgPaths(callArgs, '', paths);
  if (seedPattern != null) {
    _collectPatternPaths(seedPattern, '', paths);
  }

  // Ensure parent object paths exist for every nested path.
  final allPaths = paths.toList()..sort((a, b) => a.length.compareTo(b.length));
  for (final path in allPaths) {
    var parent = _parentPathPublic(path);
    while (parent.isNotEmpty) {
      paths.add(parent);
      parent = _parentPathPublic(parent);
    }
  }

  final objectPaths = <String>{};
  for (final path in paths) {
    final meta = schemaMeta[path];
    if (meta?.isObject == true) {
      objectPaths.add(path);
      continue;
    }
    final callValue = ldValueAtArgumentPath(callArgs, path);
    if (callValue is Map) {
      objectPaths.add(path);
      continue;
    }
    final seedValue =
        seedPattern == null ? null : _valueAtPathInPattern(seedPattern, path);
    if (seedValue is Map) {
      objectPaths.add(path);
    }
  }

  // Infer object parents that have children in paths.
  for (final path in paths) {
    final parent = _parentPathPublic(path);
    if (parent.isNotEmpty) {
      objectPaths.add(parent);
    }
  }

  final pins = <String, LdToolAllowFieldPin>{};
  final sorted = paths.toList()..sort();
  for (final path in sorted) {
    pins[path] = _defaultPinForPath(
      path: path,
      callArgs: callArgs,
      seedPattern: seedPattern,
      schemaMeta: schemaMeta,
      isObject: objectPaths.contains(path),
    );
  }

  final rootKeys = <String>{};
  for (final path in sorted) {
    if (!path.contains('.')) {
      rootKeys.add(path);
    }
  }
  // Preserve schema order for roots when available.
  final orderedRoots = <String>[];
  final schemaRootOrder = schemaMeta.values
      .where((m) => m.parentPath.isEmpty)
      .map((m) => m.key)
      .toList();
  for (final key in schemaRootOrder) {
    if (rootKeys.contains(key)) {
      orderedRoots.add(key);
    }
  }
  for (final key in rootKeys) {
    if (!orderedRoots.contains(key)) {
      orderedRoots.add(key);
    }
  }

  return LdToolAllowFieldSession(
    schemaMeta: schemaMeta,
    pins: pins,
    rootKeys: orderedRoots,
    objectPaths: objectPaths,
    callArgs: hasCallContext ? callArgs : null,
  );
}

LdToolAllowFieldPin _defaultPinForPath({
  required String path,
  required Map<String, dynamic> callArgs,
  required Map<String, dynamic>? seedPattern,
  required Map<String, LdToolAllowSchemaMeta> schemaMeta,
  required bool isObject,
}) {
  final callValue = ldValueAtArgumentPath(callArgs, path);
  final seedValue =
      seedPattern == null ? null : _valueAtPathInPattern(seedPattern, path);
  final meta = schemaMeta[path];
  final hasCall = _pathExists(callArgs, path);
  final hasSeed = seedPattern != null && _patternPathExists(seedPattern, path);

  if (seedValue == ldToolAllowWildcard) {
    return const LdToolAllowFieldPin(mode: LdToolAllowPinMode.wildcard);
  }

  if (isObject) {
    if (hasCall || hasSeed) {
      return const LdToolAllowFieldPin(mode: LdToolAllowPinMode.exact);
    }
    if (meta != null && !meta.required) {
      return const LdToolAllowFieldPin(mode: LdToolAllowPinMode.notAllowed);
    }
    if (meta != null && meta.required) {
      return const LdToolAllowFieldPin(mode: LdToolAllowPinMode.exact);
    }
    // No schema: only show paths that exist in call/seed (already filtered).
    return const LdToolAllowFieldPin(mode: LdToolAllowPinMode.exact);
  }

  final values = <Object?>[];
  final isArray = meta?.kind == LdToolAllowValueKind.array || callValue is List;

  if (isArray) {
    _appendArrayAlternatives(values, seedValue);
    if (hasCall && callValue is List) {
      if (!_listContainsValue(values, callValue)) {
        values.add(List<Object?>.from(callValue));
      }
    }
  } else {
    if (seedValue is List) {
      for (final v in seedValue) {
        if (!_listContainsValue(values, v)) {
          values.add(v);
        }
      }
    } else if (seedValue != null && seedValue != ldToolAllowWildcard) {
      values.add(seedValue);
    }

    if (hasCall && callValue is! Map) {
      if (!_listContainsValue(values, callValue)) {
        values.add(callValue);
      }
    }
  }

  if (values.isNotEmpty) {
    return LdToolAllowFieldPin(
      mode: LdToolAllowPinMode.exact,
      values: values,
    );
  }

  if (meta != null && !meta.required) {
    return const LdToolAllowFieldPin(mode: LdToolAllowPinMode.notAllowed);
  }
  if (meta != null && meta.required) {
    return const LdToolAllowFieldPin(mode: LdToolAllowPinMode.exact);
  }
  return const LdToolAllowFieldPin(mode: LdToolAllowPinMode.notAllowed);
}

bool _listContainsValue(List<Object?> values, Object? value) {
  for (final v in values) {
    if (_pinValuesEqual(v, value)) {
      return true;
    }
  }
  return false;
}

bool _pinValuesEqual(Object? a, Object? b) {
  if (identical(a, b) || a == b) {
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (!_pinValuesEqual(a[i], b[i])) {
        return false;
      }
    }
    return true;
  }
  return false;
}

/// Normalizes seed/call array patterns into pin alternatives (each a List).
void _appendArrayAlternatives(List<Object?> values, Object? seedValue) {
  if (seedValue == null || seedValue == ldToolAllowWildcard) {
    return;
  }
  if (seedValue is! List) {
    if (!_listContainsValue(values, [seedValue])) {
      values.add([seedValue]);
    }
    return;
  }
  // Nested lists => OR of arrays. Flat list => one array alternative.
  if (seedValue.any((e) => e is List)) {
    for (final alt in seedValue) {
      if (alt is List) {
        if (!_listContainsValue(values, alt)) {
          values.add(List<Object?>.from(alt));
        }
      } else if (alt != null && !_listContainsValue(values, [alt])) {
        values.add([alt]);
      }
    }
  } else {
    if (!_listContainsValue(values, seedValue)) {
      values.add(List<Object?>.from(seedValue));
    }
  }
}

bool _pathExists(Map<String, dynamic> root, String path) {
  final parts = path.split('.');
  dynamic current = root;
  for (final part in parts) {
    if (current is! Map || !current.containsKey(part)) {
      return false;
    }
    current = current[part];
  }
  return true;
}

bool _patternPathExists(Map<String, dynamic> root, String path) {
  final parts = path.split('.');
  dynamic current = root;
  for (final part in parts) {
    if (current is! Map || !current.containsKey(part)) {
      return false;
    }
    current = current[part];
  }
  return true;
}

void _collectArgPaths(
  Map<String, dynamic> map,
  String prefix,
  Set<String> paths,
) {
  for (final entry in map.entries) {
    final path = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
    paths.add(path);
    if (entry.value is Map) {
      _collectArgPaths(
        Map<String, dynamic>.from(entry.value as Map),
        path,
        paths,
      );
    }
  }
}

void _collectPatternPaths(
  Map<String, dynamic> map,
  String prefix,
  Set<String> paths,
) {
  for (final entry in map.entries) {
    final path = prefix.isEmpty ? entry.key : '$prefix.${entry.key}';
    paths.add(path);
    if (entry.value is Map && entry.value != ldToolAllowWildcard) {
      _collectPatternPaths(
        Map<String, dynamic>.from(entry.value as Map),
        path,
        paths,
      );
    }
  }
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

/// Ordered child keys for [parentPath] (empty string = roots).
List<String> ldChildKeysForPath(
  LdToolAllowFieldSession session,
  String parentPath,
) {
  final meta = parentPath.isEmpty ? null : session.schemaMeta[parentPath];
  if (meta != null && meta.childKeys.isNotEmpty) {
    final keys = <String>[...meta.childKeys];
    for (final path in session.pins.keys) {
      if (_parentPathPublic(path) == parentPath) {
        final key = path.contains('.') ? path.split('.').last : path;
        if (!keys.contains(key)) {
          keys.add(key);
        }
      }
    }
    return keys;
  }

  final keys = <String>[];
  if (parentPath.isEmpty) {
    return session.rootKeys;
  }
  for (final path in session.pins.keys) {
    if (_parentPathPublic(path) == parentPath) {
      keys.add(path.split('.').last);
    }
  }
  keys.sort();
  return keys;
}
