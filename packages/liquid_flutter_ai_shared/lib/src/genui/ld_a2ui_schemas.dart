import 'package:json_schema_builder/json_schema_builder.dart';

/// Minimal A2UI binding helpers (Flutter-free).
///
/// Mirrors the common cases of genui [A2uiSchemas] without function-call
/// variants so schemas can live in a pure-Dart package.
abstract final class LdA2uiSchemas {
  static Schema dataBindingSchema({String? description}) {
    return S.object(
      description: description,
      properties: {
        'path': S.string(
          description: 'A relative or absolute path in the data model.',
        ),
      },
      required: ['path'],
    );
  }

  static Schema stringReference({
    String? description,
    List<String>? enumValues,
  }) {
    return S.combined(
      description: description,
      oneOf: [
        S.string(
          description: 'A literal string value.',
          enumValues: enumValues,
        ),
        dataBindingSchema(description: 'A path to a string.'),
      ],
    );
  }

  static Schema numberReference({String? description}) {
    return S.combined(
      description: description,
      oneOf: [
        S.number(description: 'A literal number value.'),
        dataBindingSchema(description: 'A path to a number.'),
      ],
    );
  }

  static Schema booleanReference({String? description}) {
    return S.combined(
      description: description,
      oneOf: [
        S.boolean(description: 'A literal boolean value.'),
        dataBindingSchema(description: 'A path to a boolean.'),
      ],
    );
  }

  static Schema componentArrayReference({String? description}) {
    final idList = S.list(items: S.string(description: 'Component ID'));
    final template = S.object(
      properties: {
        'componentId': S.string(description: 'The ID of a component.'),
        'path': S.string(
          description: 'A relative or absolute path in the data model.',
        ),
      },
      required: ['componentId', 'path'],
    );
    return S.combined(oneOf: [idList, template], description: description);
  }
}
