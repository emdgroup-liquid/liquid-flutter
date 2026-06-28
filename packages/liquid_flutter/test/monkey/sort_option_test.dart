import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'test_utils.dart';

void main() {
  group('LdSortOption Tests', () {
    LdSortOption<TestItem, int> buildSortOption({
      bool isOn = false,
      LdSortOptionDirection direction = LdSortOptionDirection.asc,
      bool supportsReorder = false,
      LdAffectedByUpdate<TestItem>? affectedByUpdate,
    }) {
      return LdSortOption<TestItem, int>(
        name: 'name',
        label: (context) => 'Name',
        icon: (context) => const Icon(Icons.sort),
        isOn: isOn,
        direction: direction,
        supportsReorder: supportsReorder,
        affectedByUpdate: affectedByUpdate,
      );
    }

    group('Serialization', () {
      test('serialize() returns name-direction format', () {
        final sort = buildSortOption(
          isOn: true,
          direction: LdSortOptionDirection.desc,
        );

        expect(sort.serialize(), equals('name-desc'));
      });

      test('marshalSerialized() parses asc direction', () {
        final sort = buildSortOption(isOn: false);

        final marshaled = sort.marshalSerialized('name-asc');
        expect(marshaled.isOn, isTrue);
        expect(marshaled.direction, equals(LdSortOptionDirection.asc));
      });

      test('marshalSerialized() parses desc direction', () {
        final sort = buildSortOption(isOn: false);

        final marshaled = sort.marshalSerialized('name-desc');
        expect(marshaled.isOn, isTrue);
        expect(marshaled.direction, equals(LdSortOptionDirection.desc));
      });

      test('marshalSerialized() defaults to asc for malformed input', () {
        final sort = buildSortOption(isOn: false);

        final marshaled = sort.marshalSerialized('invalid');
        expect(marshaled.isOn, isTrue);
        expect(marshaled.direction, equals(LdSortOptionDirection.asc));
      });
    });

    group('CopyWith', () {
      test('copyWith() updates isOn and direction', () {
        final sort = buildSortOption();

        final updated = sort.copyWith(
          isOn: true,
          direction: LdSortOptionDirection.desc,
        );

        expect(updated.isOn, isTrue);
        expect(updated.direction, equals(LdSortOptionDirection.desc));
        expect(updated.name, equals('name'));
      });

      test('copyWith() updates supportsReorder and affectedByUpdate', () {
        bool affected(TestItem? before, TestItem? after) => false;

        final sort = buildSortOption();
        final updated = sort.copyWith(
          supportsReorder: true,
          affectedByUpdate: affected,
        );

        expect(updated.supportsReorder, isTrue);
        expect(updated.affectedByUpdate, same(affected));
      });
    });

    group('Equality', () {
      test('equal options compare equal', () {
        final a = buildSortOption(isOn: true, supportsReorder: true);
        final b = buildSortOption(isOn: true, supportsReorder: true);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different direction compares unequal', () {
        final asc = buildSortOption(direction: LdSortOptionDirection.asc);
        final desc = buildSortOption(direction: LdSortOptionDirection.desc);

        expect(asc, isNot(equals(desc)));
      });
    });
  });
}
