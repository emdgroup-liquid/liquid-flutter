import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

class _KeyItem with Identifiable<int> {
  @override
  final int id;

  _KeyItem(this.id);
}

Widget _icon(BuildContext context) => const SizedBox.shrink();

String _label(BuildContext context) => 'label';

void main() {
  group('ldRepositoryCacheKey', () {
    test('empty filters and sorts produce empty key', () {
      expect(
        ldRepositoryCacheKey<_KeyItem, int>(filters: {}, sortOptions: []),
        isEmpty,
      );
    });

    test('sorts filters and sorts by name deterministically', () {
      final filterB = LdFilterBool<_KeyItem, int>(
        name: 'b',
        label: _label,
        icon: _icon,
        isOn: true,
      );
      final filterA = LdFilterBool<_KeyItem, int>(
        name: 'a',
        label: _label,
        icon: _icon,
        isOn: true,
      );
      final sortB = LdSortOption<_KeyItem, int>(
        name: 'b',
        label: _label,
        icon: _icon,
        isOn: true,
        direction: LdSortOptionDirection.desc,
      );
      final sortA = LdSortOption<_KeyItem, int>(
        name: 'a',
        label: _label,
        icon: _icon,
        isOn: true,
        direction: LdSortOptionDirection.asc,
      );

      final keyOne = ldRepositoryCacheKey<_KeyItem, int>(
        filters: {filterB, filterA},
        sortOptions: [sortB, sortA],
      );
      final keyTwo = ldRepositoryCacheKey<_KeyItem, int>(
        filters: {filterA, filterB},
        sortOptions: [sortA, sortB],
      );

      expect(keyOne, equals(keyTwo));
      expect(keyOne, contains('filter:a=true'));
      expect(keyOne, contains('filter:b=true'));
      expect(keyOne, contains('sort:a=a-asc'));
      expect(keyOne, contains('sort:b=b-desc'));
    });

    test('appends pageToken when provided', () {
      final key = ldRepositoryCacheKey<_KeyItem, int>(
        filters: {},
        sortOptions: [],
        pageToken: 'next-page',
      );

      expect(key, equals('token:next-page'));
    });
  });

  group('parseLdRepositoryCacheKey', () {
    test('parses empty key', () {
      expect(parseLdRepositoryCacheKey(''), isEmpty);
    });

    test('parses filters sorts and token', () {
      final key = ldRepositoryCacheKey<_KeyItem, int>(
        filters: {
          LdFilterBool<_KeyItem, int>(
            name: 'active',
            label: _label,
            icon: _icon,
            isOn: true,
          ),
        },
        sortOptions: [
          LdSortOption<_KeyItem, int>(
            name: 'title',
            label: _label,
            icon: _icon,
            isOn: true,
          ),
        ],
        pageToken: 'next',
      );

      final parts = parseLdRepositoryCacheKey(key);
      expect(parts.length, equals(3));
      expect(parts[0].kind, equals('filter'));
      expect(parts[0].name, equals('active'));
      expect(parts[0].value, equals('true'));
      expect(parts[1].kind, equals('sort'));
      expect(parts[1].name, equals('title'));
      expect(parts[1].value, equals('title-asc'));
      expect(parts[2].kind, equals('token'));
      expect(parts[2].value, equals('next'));
    });

    test('parses serialized values containing equals characters', () {
      final key = 'filter:search=foo=bar|sort:name=name-asc';
      final parts = parseLdRepositoryCacheKey(key);

      expect(parts.length, equals(2));
      expect(parts[0].name, equals('search'));
      expect(parts[0].value, equals('foo=bar'));
      expect(parts[1].name, equals('name'));
      expect(parts[1].value, equals('name-asc'));
    });
  });
}
