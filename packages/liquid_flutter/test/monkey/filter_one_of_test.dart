import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

enum _Category { categoryA, categoryB, categoryC }

void main() {
  group('LdFilterOneOf Tests', () {
    final allValues = {
      _Category.categoryA: (BuildContext context) => const Text('Category A'),
      _Category.categoryB: (BuildContext context) => const Text('Category B'),
      _Category.categoryC: (BuildContext context) => const Text('Category C'),
    };

    group('Serialization', () {
      test('serialize() returns selectedValue.toString() when on', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          isOn: true,
        );

        expect(filter.serialize(), equals('_Category.categoryA'));
      });

      test('serialize() returns empty string when off', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          isOn: false,
        );

        expect(filter.serialize(), isEmpty);
      });

      test('serialize() returns empty string when selectedValue is null', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          isOn: true,
        );

        expect(filter.serialize(), isEmpty);
      });

      test('marshalSerialized() parses comma-separated values correctly', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
        );

        final marshaled = filter.marshalSerialized('_Category.categoryB');
        expect(marshaled.selectedValue, equals(_Category.categoryB));
        expect(marshaled.isOn, isTrue);
      });

      test('marshalSerialized() keeps empty string as active All state', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          isOn: true,
        );

        final marshaled = filter.marshalSerialized('');

        expect(marshaled.isOn, isTrue);
        expect(marshaled.selectedValue, isNull);
        expect(marshaled.serialize(), isEmpty);
      });

      test('marshalSerialized() handles invalid value', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
          isOn: true,
        );

        final marshaled = filter.marshalSerialized('invalid');

        expect(marshaled.isOn, isFalse);
        expect(marshaled.selectedValue, isNull);
      });
    });

    group('Equality', () {
      test('differs when allValues keys change', () {
        final empty = LdFilterOneOf<TestItem, int, String>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: {},
        );
        final populated = empty.copyWith(
          allValues: {
            'Gold': (context) => const Text('Gold'),
          },
        );

        expect(empty, isNot(equals(populated)));
      });
    });

    group('CopyWith', () {
      test('copyWith() updates selectedValue correctly', () {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
        );

        final newFilter = filter.copyWith(
          selectedValue: _Category.categoryB,
          isOn: true,
        );

        expect(newFilter.selectedValue, equals(_Category.categoryB));
        expect(newFilter.isOn, isTrue);
        expect(filter.selectedValue, equals(_Category.categoryA));
      });
    });

    group('UI Rendering', () {
      testWidgets('renders selection widget', (WidgetTester tester) async {
        final filter = LdFilterOneOf<TestItem, int, _Category>(
          name: 'category',
          label: (context) => 'Category',
          icon: (context) => const Icon(Icons.category),
          allValues: allValues,
          initialSelected: _Category.categoryA,
        );

        final shellState = TestSortAndFilterState<TestItem, int>(filters: {filter});
        final repository = createTestRepository();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              home: Scaffold(
                body: ListenableProvider<LdRepository<TestItem, int>>.value(
                  value: repository,
                  child: ChangeNotifierProvider<TestSortAndFilterState<TestItem, int>>.value(
                    value: shellState,
                    child: Provider<LdMonkeyRouterController>.value(
                      value: shellState.controllerDelegate,
                      child: Provider<LdMonkeySortAndFilterState<TestItem, int>>.value(
                        value: LdMonkeySortAndFilterState<TestItem, int>(
                          filters: shellState.filtersMap.values.toSet(),
                          sortOptions: [],
                        ),
                        child: LdFilterOneOfWidget<TestItem, int, _Category>(
                          filter: filter,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Category'), findsOneWidget);
      });
    });
  });
}
