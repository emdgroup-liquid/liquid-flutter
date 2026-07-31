import 'dart:convert';

import 'package:json_schema/json_schema.dart';

/// Scalar / structure kind used for type-aware pin editors.
enum LdToolAllowValueKind {
  object,
  boolean,
  string,
  number,
  integer,
  array,
  unknown,
}

/// Schema metadata for one argument path (dot-separated).
class LdToolAllowSchemaMeta {
  const LdToolAllowSchemaMeta({
    required this.path,
    required this.key,
    required this.parentPath,
    required this.isObject,
    required this.required,
    required this.kind,
    this.itemKind = LdToolAllowValueKind.unknown,
    this.enumOptions = const [],
    this.childKeys = const [],
  });

  final String path;
  final String key;
  final String parentPath;
  final bool isObject;
  final bool required;
  final LdToolAllowValueKind kind;

  /// Element kind when [kind] is [LdToolAllowValueKind.array].
  final LdToolAllowValueKind itemKind;

  /// Const / enum alternatives when known (field or array-item enums).
  final List<Object?> enumOptions;

  /// Ordered child property names when [isObject].
  final List<String> childKeys;
}

/// Parses a tool input schema (map or JSON string) into a flat path→meta map.
///
/// Uses `json_schema` when possible; falls back to a shallow `properties` walk
/// if create fails or schema is malformed.
Map<String, LdToolAllowSchemaMeta> ldParseToolInputSchema(Object? raw) {
  final map = ldParseSchemaMap(raw);
  if (map.isEmpty) {
    return {};
  }

  try {
    final schema = JsonSchema.create(map);
    final result = <String, LdToolAllowSchemaMeta>{};
    _walkJsonSchema(schema, '', result);
    if (result.isNotEmpty) {
      return result;
    }
  } catch (_) {
    // Fall through to map walk.
  }

  final result = <String, LdToolAllowSchemaMeta>{};
  _walkSchemaMap(map, '', result);
  return result;
}

/// Decodes schema JSON similarly to tool arguments.
Map<String, dynamic> ldParseSchemaMap(Object? raw) {
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

void _walkJsonSchema(
  JsonSchema schema,
  String prefix,
  Map<String, LdToolAllowSchemaMeta> out,
) {
  final props = schema.properties;
  if (props.isEmpty) {
    return;
  }

  for (final entry in props.entries) {
    final key = entry.key;
    final child = entry.value;
    final path = prefix.isEmpty ? key : '$prefix.$key';
    final kind = _kindFromJsonSchema(child);
    final isObject = kind == LdToolAllowValueKind.object ||
        child.properties.isNotEmpty;
    final childKeys = child.properties.keys.toList(growable: false);
    final itemSchema = child.items;
    final itemKind = kind == LdToolAllowValueKind.array && itemSchema != null
        ? _kindFromJsonSchema(itemSchema)
        : LdToolAllowValueKind.unknown;
    final enumOptions = kind == LdToolAllowValueKind.array && itemSchema != null
        ? _enumOptionsFromJsonSchema(itemSchema)
        : _enumOptionsFromJsonSchema(child);
    out[path] = LdToolAllowSchemaMeta(
      path: path,
      key: key,
      parentPath: prefix,
      isObject: isObject,
      required: schema.propertyRequired(key),
      kind: isObject ? LdToolAllowValueKind.object : kind,
      itemKind: itemKind,
      enumOptions: enumOptions,
      childKeys: childKeys,
    );
    if (isObject) {
      _walkJsonSchema(child, path, out);
    }
  }
}

void _walkSchemaMap(
  Map<String, dynamic> schema,
  String prefix,
  Map<String, LdToolAllowSchemaMeta> out,
) {
  final props = schema['properties'];
  if (props is! Map) {
    return;
  }
  final requiredRaw = schema['required'];
  final required = <String>{};
  if (requiredRaw is List) {
    for (final item in requiredRaw) {
      if (item is String) {
        required.add(item);
      }
    }
  }

  for (final entry in props.entries) {
    final key = entry.key.toString();
    final path = prefix.isEmpty ? key : '$prefix.$key';
    final propMap = entry.value is Map
        ? Map<String, dynamic>.from(entry.value as Map)
        : <String, dynamic>{};
    final kind = _kindFromMap(propMap);
    final nestedProps = propMap['properties'];
    final isObject = kind == LdToolAllowValueKind.object || nestedProps is Map;
    final childKeys = nestedProps is Map
        ? nestedProps.keys.map((k) => k.toString()).toList(growable: false)
        : const <String>[];
    final itemsMap = propMap['items'] is Map
        ? Map<String, dynamic>.from(propMap['items'] as Map)
        : null;
    final itemKind = kind == LdToolAllowValueKind.array && itemsMap != null
        ? _kindFromMap(itemsMap)
        : LdToolAllowValueKind.unknown;
    final enumOptions = kind == LdToolAllowValueKind.array && itemsMap != null
        ? _enumOptionsFromMap(itemsMap)
        : _enumOptionsFromMap(propMap);
    out[path] = LdToolAllowSchemaMeta(
      path: path,
      key: key,
      parentPath: prefix,
      isObject: isObject,
      required: required.contains(key),
      kind: isObject ? LdToolAllowValueKind.object : kind,
      itemKind: itemKind,
      enumOptions: enumOptions,
      childKeys: childKeys,
    );
    if (isObject && nestedProps is Map) {
      _walkSchemaMap(propMap, path, out);
    }
  }
}

LdToolAllowValueKind _kindFromJsonSchema(JsonSchema schema) {
  final list = schema.typeList;
  if (list != null && list.isNotEmpty) {
    if (list.contains(SchemaType.object) || schema.properties.isNotEmpty) {
      return LdToolAllowValueKind.object;
    }
    if (list.contains(SchemaType.boolean)) {
      return LdToolAllowValueKind.boolean;
    }
    if (list.contains(SchemaType.integer)) {
      return LdToolAllowValueKind.integer;
    }
    if (list.contains(SchemaType.number)) {
      return LdToolAllowValueKind.number;
    }
    if (list.contains(SchemaType.array)) {
      return LdToolAllowValueKind.array;
    }
    if (list.contains(SchemaType.string)) {
      return LdToolAllowValueKind.string;
    }
  }
  if (schema.properties.isNotEmpty) {
    return LdToolAllowValueKind.object;
  }
  if ((schema.enumValues?.isNotEmpty ?? false) ||
      _enumOptionsFromJsonSchema(schema).isNotEmpty) {
    return LdToolAllowValueKind.string;
  }
  return LdToolAllowValueKind.unknown;
}

LdToolAllowValueKind _kindFromMap(Map<String, dynamic> prop) {
  final type = prop['type'];
  if (type is List) {
    final types = type.map((e) => e.toString()).toSet();
    if (types.contains('object') || prop['properties'] is Map) {
      return LdToolAllowValueKind.object;
    }
    if (types.contains('boolean')) {
      return LdToolAllowValueKind.boolean;
    }
    if (types.contains('integer')) {
      return LdToolAllowValueKind.integer;
    }
    if (types.contains('number')) {
      return LdToolAllowValueKind.number;
    }
    if (types.contains('array')) {
      return LdToolAllowValueKind.array;
    }
    if (types.contains('string')) {
      return LdToolAllowValueKind.string;
    }
  } else if (type is String) {
    return switch (type) {
      'object' => LdToolAllowValueKind.object,
      'boolean' => LdToolAllowValueKind.boolean,
      'integer' => LdToolAllowValueKind.integer,
      'number' => LdToolAllowValueKind.number,
      'array' => LdToolAllowValueKind.array,
      'string' => LdToolAllowValueKind.string,
      _ => LdToolAllowValueKind.unknown,
    };
  }
  if (prop['properties'] is Map) {
    return LdToolAllowValueKind.object;
  }
  return LdToolAllowValueKind.unknown;
}

List<Object?> _enumOptionsFromJsonSchema(JsonSchema schema) {
  final fromEnum = schema.enumValues;
  if (fromEnum != null && fromEnum.isNotEmpty) {
    return List<Object?>.from(fromEnum);
  }
  final options = <Object?>[];
  for (final branch in schema.oneOf) {
    final consts = branch.enumValues;
    if (consts != null && consts.length == 1) {
      options.add(consts.first);
    }
  }
  return options;
}

List<Object?> _enumOptionsFromMap(Map<String, dynamic> prop) {
  final enumRaw = prop['enum'];
  if (enumRaw is List && enumRaw.isNotEmpty) {
    return List<Object?>.from(enumRaw);
  }
  final oneOf = prop['oneOf'];
  if (oneOf is! List) {
    return const [];
  }
  final options = <Object?>[];
  for (final branch in oneOf) {
    if (branch is! Map) {
      continue;
    }
    if (branch.containsKey('const')) {
      options.add(branch['const']);
    } else if (branch['enum'] is List && (branch['enum'] as List).length == 1) {
      options.add((branch['enum'] as List).first);
    }
  }
  return options;
}
