import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/src/swagger/identifiable_swagger_builder.dart';

void main() {
  group('transformIdentifiableSwagger', () {
    final emptyOverrides = <String, String>{};

    // -----------------------------------------------------------------------
    // Basic id detection
    // -----------------------------------------------------------------------

    test('adds Identifiable<int> for class with int id field', () {
      final input = '''
import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable(explicitToJson: true)
class User {
  const User({required this.name, required this.id});

  @JsonKey(name: 'name')
  final String name;
  @JsonKey(name: 'id')
  final int id;
  static const fromJsonFactory = _\$UserFromJson;
}
''';

      final result = transformIdentifiableSwagger(input, emptyOverrides);
      expect(result, contains('class User with Identifiable<int> {'));
      expect(
        result,
        contains("import 'package:liquid_flutter/liquid_flutter.dart';"),
      );
      // No spurious forwarding getter when field is already named id.
      expect(result, isNot(contains('get id => id')));
    });

    test('adds Identifiable<String> for class with String id field', () {
      final input = '''
import 'dart:convert';

@JsonSerializable(explicitToJson: true)
class Product {
  const Product({required this.id});

  @JsonKey(name: 'id')
  final String id;
}
''';

      final result = transformIdentifiableSwagger(input, emptyOverrides);
      expect(result, contains('class Product with Identifiable<String> {'));
    });

    // -----------------------------------------------------------------------
    // Field overrides
    // -----------------------------------------------------------------------

    test('uses field override and inserts forwarding getter (int)', () {
      final input = '''
import 'dart:convert';

@JsonSerializable(explicitToJson: true)
class Order {
  const Order({required this.orderId});

  @JsonKey(name: 'orderId')
  final int orderId;
}
''';

      final result =
          transformIdentifiableSwagger(input, {'Order': 'orderId'});
      expect(result, contains('class Order with Identifiable<int> {'));
      expect(result, contains('int get id => orderId;'));
      expect(
        result,
        contains("import 'package:liquid_flutter/liquid_flutter.dart';"),
      );
    });

    test('uses field override and inserts forwarding getter (String)', () {
      final input = '''
import 'dart:convert';

@JsonSerializable(explicitToJson: true)
class Item {
  const Item({required this.uuid});

  @JsonKey(name: 'uuid')
  final String uuid;
}
''';

      final result =
          transformIdentifiableSwagger(input, {'Item': 'uuid'});
      expect(result, contains('class Item with Identifiable<String> {'));
      expect(result, contains('String get id => uuid;'));
    });

    test('forwarding getter is inserted right after the class opening brace',
        () {
      final input = '''
@JsonSerializable(explicitToJson: true)
class Item {
  const Item({required this.uuid});

  @JsonKey(name: 'uuid')
  final String uuid;
}
''';

      final result =
          transformIdentifiableSwagger(input, {'Item': 'uuid'});
      final lines = result.split('\n');
      final classLineIdx =
          lines.indexWhere((l) => l.contains('class Item with Identifiable'));
      expect(classLineIdx, isNot(-1));
      // The very next line should be the forwarding getter.
      expect(lines[classLineIdx + 1].trim(), equals('String get id => uuid;'));
    });

    // -----------------------------------------------------------------------
    // Idempotency
    // -----------------------------------------------------------------------

    test('skips class already having Identifiable', () {
      final input = '''
@JsonSerializable(explicitToJson: true)
class User with Identifiable<int> {
  const User({required this.id});

  @JsonKey(name: 'id')
  final int id;
}
''';

      final result = transformIdentifiableSwagger(input, emptyOverrides);
      expect(result, equals(input));
    });

    // -----------------------------------------------------------------------
    // Classes without id
    // -----------------------------------------------------------------------

    test('skips class without id field and without override', () {
      final input = '''
@JsonSerializable(explicitToJson: true)
class UserCreate {
  const UserCreate({required this.name});

  @JsonKey(name: 'name')
  final String name;
}
''';

      final result = transformIdentifiableSwagger(input, emptyOverrides);
      expect(result, equals(input));
    });

    test('does not add import when no classes are modified', () {
      final input = '''
@JsonSerializable(explicitToJson: true)
class UserCreate {
  const UserCreate({required this.name});

  @JsonKey(name: 'name')
  final String name;
}
''';

      final result = transformIdentifiableSwagger(input, emptyOverrides);
      expect(
        result,
        isNot(contains("import 'package:liquid_flutter/liquid_flutter.dart'")),
      );
    });

    // -----------------------------------------------------------------------
    // Duplicate import guard
    // -----------------------------------------------------------------------

    test('does not add duplicate import', () {
      final input = '''
import 'dart:convert';
import 'package:liquid_flutter/liquid_flutter.dart';

@JsonSerializable(explicitToJson: true)
class User {
  const User({required this.id});

  @JsonKey(name: 'id')
  final int id;
}
''';

      final result = transformIdentifiableSwagger(input, emptyOverrides);
      final importCount =
          RegExp(r"import 'package:liquid_flutter/liquid_flutter\.dart'")
              .allMatches(result)
              .length;
      expect(importCount, equals(1));
    });

    // -----------------------------------------------------------------------
    // Multiple classes in one file
    // -----------------------------------------------------------------------

    test('handles multiple classes — patches those with id, skips rest', () {
      final input = '''
import 'dart:convert';

@JsonSerializable(explicitToJson: true)
class User {
  const User({required this.id});

  @JsonKey(name: 'id')
  final int id;
}

@JsonSerializable(explicitToJson: true)
class Role {
  const Role({required this.id});

  @JsonKey(name: 'id')
  final String id;
}

@JsonSerializable(explicitToJson: true)
class UserCreate {
  const UserCreate({required this.name});

  @JsonKey(name: 'name')
  final String name;
}
''';

      final result = transformIdentifiableSwagger(input, emptyOverrides);
      expect(result, contains('class User with Identifiable<int> {'));
      expect(result, contains('class Role with Identifiable<String> {'));
      // UserCreate has no id field — should be untouched.
      expect(result, contains('class UserCreate {'));
      expect(result, isNot(contains('class UserCreate with')));
    });

    // -----------------------------------------------------------------------
    // Non-model classes (no @JsonSerializable annotation)
    // -----------------------------------------------------------------------

    test('ignores classes not preceded by @JsonSerializable', () {
      final input = '''
class MyService {
  final int id = 42;
}
''';

      final result = transformIdentifiableSwagger(input, emptyOverrides);
      expect(result, equals(input));
    });

    // -----------------------------------------------------------------------
    // Override maps to 'id' explicitly — no forwarding getter needed
    // -----------------------------------------------------------------------

    test('no forwarding getter when override field name is id', () {
      final input = '''
import 'dart:convert';

@JsonSerializable(explicitToJson: true)
class User {
  const User({required this.id});

  @JsonKey(name: 'id')
  final int id;
}
''';

      final result =
          transformIdentifiableSwagger(input, {'User': 'id'});
      expect(result, contains('with Identifiable<int>'));
      expect(result, isNot(contains('get id => id')));
    });
  });
}
