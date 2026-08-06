import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_genui_schemas.dart';

/// Builds the GenUI catalog section for Mo's system prompt (pure Dart).
String buildLdGenuiSystemPrompt() {
  final buf = StringBuffer()
    ..writeln(kLdGenuiCatalogPromptMarker)
    ..writeln(
      'You can render interactive UI alongside text using ```genui fenced '
      'blocks. Each line inside the fence is one JSON action.',
    )
    ..writeln()
    ..writeln('Actions (one JSON object per line):')
    ..writeln(
      '- createSurface: {"version":"v0.9","createSurface":{"surfaceId":"<id>"}}',
    )
    ..writeln(
      '- updateComponents: {"version":"v0.9","updateComponents":{"surfaceId":"<id>","components":[...]}}',
    )
    ..writeln(
      '- updateDataModel: {"version":"v0.9","updateDataModel":{"surfaceId":"<id>","path":"/","value":{...}}}',
    )
    ..writeln(
      '- deleteSurface: {"version":"v0.9","deleteSurface":{"surfaceId":"<id>"}}',
    )
    ..writeln()
    ..writeln('Rules:')
    ..writeln(
      '- After createSurface you MUST send updateComponents with a component '
      'whose id is "root".',
    )
    ..writeln(
      '- Use "component" (not "type") for the widget name. Put props at the '
      'top level (not under "properties").',
    )
    ..writeln(
      '- children / child / header / footer are component ids (strings), not '
      'nested widget objects.',
    )
    ..writeln(
      '- String/number/bool fields may be a literal or {"path":"/..."} data binding.',
    )
    ..writeln('- Catalog id (optional on createSurface): $kLdGenuiCatalogId')
    ..writeln();

  for (final fragment in kLdGenuiSystemPromptFragments) {
    buf.writeln('- $fragment');
  }
  buf
    ..writeln()
    ..writeln('Components (required fields marked *):');

  for (final entry in ldGenuiComponentSchemas) {
    buf.writeln(_formatComponent(entry.name, entry.schema));
  }

  buf
    ..writeln()
    ..writeln('Minimal example:')
    ..writeln('```genui')
    ..writeln(
      '{"version":"v0.9","createSurface":{"surfaceId":"greeting"}}',
    )
    ..writeln(
      '{"version":"v0.9","updateComponents":{"surfaceId":"greeting","components":['
      '{"id":"root","component":"LdCallout","type":"info","body":"Hello"}'
      ']}}',
    )
    ..writeln('```')
    ..writeln('Do not copy the example verbatim — adapt it to the task.')
    ..writeln(kLdGenuiCatalogPromptEndMarker);

  return buf.toString().trim();
}

String _formatComponent(String name, Schema schema) {
  final desc = schema.description ?? '';
  final required = (schema.value['required'] as List?)?.cast<String>() ??
      const <String>[];
  final rawProps = schema.value['properties'];
  final props = <String, Schema>{};
  if (rawProps is Map) {
    for (final entry in rawProps.entries) {
      final key = entry.key;
      final value = entry.value;
      if (key is! String) continue;
      if (value is Map<String, Object?>) {
        props[key] = Schema.fromMap(value);
      } else if (value is Map) {
        props[key] = Schema.fromMap(Map<String, Object?>.from(value));
      }
    }
  }
  final parts = <String>[];
  for (final MapEntry(:key, :value) in props.entries) {
    final star = required.contains(key) ? '*' : '';
    parts.add('$key$star (${_typeHint(value)})');
  }
  final propText = parts.isEmpty ? '(no properties)' : parts.join(', ');
  final descBit = desc.isEmpty ? '' : ' — $desc';
  return '- $name: $propText$descBit';
}

String _typeHint(Schema schema) {
  // Enums must win over type:"string" — otherwise allowed values never reach
  // the model and it invents Material TextTheme names (headlineSmall, etc.).
  final enumValues = schema.enumValues;
  if (enumValues != null && enumValues.isNotEmpty) {
    return 'enum ${enumValues.join('|')}';
  }
  if (schema.anyOf != null || schema.oneOf != null) {
    return 'literal|path-binding';
  }
  final type = schema.type;
  if (type is String) return type;
  if (type is List) return type.join('|');
  return 'object';
}
