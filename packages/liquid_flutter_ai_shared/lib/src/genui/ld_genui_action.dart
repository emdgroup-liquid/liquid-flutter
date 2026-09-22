import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:liquid_flutter_ai_shared/src/genui/ld_json.dart';

/// Schema for a user-initiated GenUI action (`name` + optional `context`).
final ldGenuiActionSchema = S.object(
  properties: {
    'name': S.string(),
    'context': S.object(properties: {}, additionalProperties: true),
  },
  required: ['name'],
);

/// Dispatched from a catalog widget (button, card tap, …).
class LdGenuiAction {
  const LdGenuiAction({required this.name, this.context = const {}});

  final String name;
  final Map<String, Object?> context;

  static LdGenuiAction? tryParse(Object? json) {
    final map = ldJsonMap(json);
    if (map == null) return null;
    final name = ldJsonString(map['name']);
    if (name == null || name.isEmpty) return null;
    return LdGenuiAction(
      name: name,
      context: ldJsonMap(map['context']) ?? const {},
    );
  }

  static LdGenuiAction parse(Object? json, {required String field}) {
    final action = tryParse(json);
    if (action == null) {
      throw FormatException('$field requires action{name}');
    }
    return action;
  }
}

/// Label + action pair used by confirm buttons and similar.
class LdLabeledAction {
  const LdLabeledAction({required this.label, required this.action});

  final String label;
  final LdGenuiAction action;

  static Schema schema() => S.object(
    properties: {'label': S.string(), 'action': ldGenuiActionSchema},
    required: ['label', 'action'],
  );

  static LdLabeledAction? tryParse(Object? json) {
    final map = ldJsonMap(json);
    if (map == null) return null;
    final label = ldJsonString(map['label']);
    final action = LdGenuiAction.tryParse(map['action']);
    if (label == null || label.isEmpty || action == null) return null;
    return LdLabeledAction(label: label, action: action);
  }

  static LdLabeledAction parse(Object? json, {required String field}) {
    final parsed = tryParse(json);
    if (parsed == null) {
      throw FormatException('$field requires {label, action}');
    }
    return parsed;
  }
}
