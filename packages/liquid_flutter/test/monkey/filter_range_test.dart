import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

// Test item class for range tests (needs price field)
class _RangeTestItem with Identifiable<int> {
  @override
  final int id;
  final String name;
  final double price;

  _RangeTestItem(this.id, this.name, this.price);

  @override
  String toString() => '_RangeTestItem(id: $id, name: $name, price: $price)';
}

void main() {
  group('LdFilterRange Tests', () {
    group('Serialization', () {
      test('serialize() formats range with correct precision based on step', () {
        final filter = LdFilterRange<_RangeTestItem, int>(
          name: 'price',
          label: (context) => 'Price',
          icon: (context) => const Icon(Icons.attach_money),
          min: 0,
          max: 100,
          step: 0.1,
          range: const RangeValues(10.5, 20.7),
          optimisticFilter: (item, range) => item.price >= range.start && item.price <= range.end,
        );

        final serialized = filter.serialize();
        expect(serialized, contains('10.5'));
        expect(serialized, contains('20.7'));
        expect(serialized.split(',').length, equals(2));
      });

      test('serialize() handles integer step', () {
        final filter = LdFilterRange<_RangeTestItem, int>(
          name: 'price',
          label: (context) => 'Price',
          icon: (context) => const Icon(Icons.attach_money),
          min: 0,
          max: 100,
          step: 1,
          range: const RangeValues(10, 20),
          optimisticFilter: (item, range) => item.price >= range.start && item.price <= range.end,
        );

        final serialized = filter.serialize();
        expect(serialized, contains('10.0'));
        expect(serialized, contains('20.0'));
      });

      test('marshalSerialized() parses comma-separated min,max', () {
        final filter = LdFilterRange<_RangeTestItem, int>(
          name: 'price',
          label: (context) => 'Price',
          icon: (context) => const Icon(Icons.attach_money),
          min: 0,
          max: 100,
          range: const RangeValues(0, 100),
          optimisticFilter: (item, range) => item.price >= range.start && item.price <= range.end,
        );

        final marshaled = filter.marshalSerialized('10.5,20.7');
        expect(marshaled.range.start, equals(10.5));
        expect(marshaled.range.end, equals(20.7));
        expect(marshaled.isOn, isTrue);
      });

      test('marshalSerialized() validates range bounds', () {
        final filter = LdFilterRange<_RangeTestItem, int>(
          name: 'price',
          label: (context) => 'Price',
          icon: (context) => const Icon(Icons.attach_money),
          min: 0,
          max: 100,
          range: const RangeValues(0, 100),
          optimisticFilter: (item, range) => item.price >= range.start && item.price <= range.end,
        );

        final marshaled = filter.marshalSerialized('150,200');
        expect(marshaled.isOn, isFalse);
      });

      test('marshalSerialized() handles invalid input', () {
        final filter = LdFilterRange<_RangeTestItem, int>(
          name: 'price',
          label: (context) => 'Price',
          icon: (context) => const Icon(Icons.attach_money),
          min: 0,
          max: 100,
          range: const RangeValues(0, 100),
          optimisticFilter: (item, range) => item.price >= range.start && item.price <= range.end,
        );

        final marshaled1 = filter.marshalSerialized('invalid');
        expect(marshaled1.isOn, isFalse);

        final marshaled2 = filter.marshalSerialized('10');
        expect(marshaled2.isOn, isFalse);

        final marshaled3 = filter.marshalSerialized('10,20,30');
        expect(marshaled3.isOn, isFalse);
      });

      test('marshalSerialized() handles empty string', () {
        final filter = LdFilterRange<_RangeTestItem, int>(
          name: 'price',
          label: (context) => 'Price',
          icon: (context) => const Icon(Icons.attach_money),
          min: 0,
          max: 100,
          range: const RangeValues(10, 20),
          isOn: true,
          optimisticFilter: (item, range) => item.price >= range.start && item.price <= range.end,
        );

        final marshaled = filter.marshalSerialized('');
        expect(marshaled.isOn, isFalse);
      });
    });

    group('Optimistic Filtering', () {
      test('optimisticFilter() uses range values', () {
        final filter = LdFilterRange<_RangeTestItem, int>(
          name: 'price',
          label: (context) => 'Price',
          icon: (context) => const Icon(Icons.attach_money),
          min: 0,
          max: 100,
          range: const RangeValues(10, 20),
          isOn: true,
          optimisticFilter: (item, range) => item.price >= range.start && item.price <= range.end,
        );

        final matchingItem = _RangeTestItem(1, 'Item 1', 15.0);
        final belowRangeItem = _RangeTestItem(2, 'Item 2', 5.0);
        final aboveRangeItem = _RangeTestItem(3, 'Item 3', 25.0);

        expect(filter.optimisticFilter(matchingItem), isTrue);
        expect(filter.optimisticFilter(belowRangeItem), isFalse);
        expect(filter.optimisticFilter(aboveRangeItem), isFalse);
      });
    });

    group('CopyWith', () {
      test('copyWith() updates range correctly', () {
        final filter = LdFilterRange<_RangeTestItem, int>(
          name: 'price',
          label: (context) => 'Price',
          icon: (context) => const Icon(Icons.attach_money),
          min: 0,
          max: 100,
          range: const RangeValues(10, 20),
          optimisticFilter: (item, range) => item.price >= range.start && item.price <= range.end,
        );

        final newFilter = filter.copyWith(
          range: const RangeValues(15, 25),
          isOn: true,
        );

        expect(newFilter.range.start, equals(15));
        expect(newFilter.range.end, equals(25));
        expect(newFilter.isOn, isTrue);
        expect(filter.range.start, equals(10));
        expect(filter.range.end, equals(20));
      });

      test('copyWith() preserves optimisticFilter function', () {
        final filter = LdFilterRange<_RangeTestItem, int>(
          name: 'price',
          label: (context) => 'Price',
          icon: (context) => const Icon(Icons.attach_money),
          min: 0,
          max: 100,
          range: const RangeValues(10, 20),
          isOn: true,
          optimisticFilter: (item, range) => item.price >= range.start && item.price <= range.end,
        );

        final newFilter = filter.copyWith(range: const RangeValues(15, 25));
        final item = _RangeTestItem(1, 'Item 1', 20.0);

        expect(newFilter.optimisticFilter(item), isTrue);
      });
    });

    group('InRange Extension', () {
      test('inRange() returns true for value in range', () {
        const range = RangeValues(10, 20);
        expect(range.inRange(15), isTrue);
        expect(range.inRange(10), isTrue);
        expect(range.inRange(20), isTrue);
      });

      test('inRange() returns false for value outside range', () {
        const range = RangeValues(10, 20);
        expect(range.inRange(5), isFalse);
        expect(range.inRange(25), isFalse);
        expect(range.inRange(9.99), isFalse);
        expect(range.inRange(20.01), isFalse);
      });

      test('inRange() works with double values', () {
        const range = RangeValues(10.5, 20.7);
        expect(range.inRange(15.5), isTrue);
        expect(range.inRange(10.5), isTrue);
        expect(range.inRange(20.7), isTrue);
        expect(range.inRange(10.49), isFalse);
        expect(range.inRange(20.71), isFalse);
      });
    });

    group('UI Rendering', () {
      testWidgets('renders in LdFilterModal and can be activated/deactivated and interacted with',
          (WidgetTester tester) async {
        final filter = LdFilterRange<_RangeTestItem, int>(
          name: 'priceRange',
          label: (context) => 'Price',
          icon: (context) => const Icon(Icons.attach_money),
          min: 0,
          max: 100,
          range: const RangeValues(0, 100),
          optimisticFilter: (item, range) => item.price >= range.start && item.price <= range.end,
        );

        final repository = LdRepository<_RangeTestItem, int>(
          filters: {filter},
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_RangeTestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _RangeTestItem(id, 'Test', 10.0),
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: Scaffold(
                body: ListenableProvider.value(
                  value: repository,
                  child: const LdFilterModal<_RangeTestItem, int>(),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final priceFilterButton = find.widgetWithText(LdButton, 'Price');

        expect(repository.filters['priceRange']!.isOn, isFalse);

        expect(priceFilterButton, findsOneWidget);
        await tester.tap(priceFilterButton);
        await tester.pumpAndSettle();

        // Check if the filter is now active in the repository's filters
        expect(repository.filters['priceRange']!.isOn, isTrue);

        // Find the RangeSlider and interact with it
        final rangeSlider = find.byType(RangeSlider);
        expect(rangeSlider, findsOneWidget);

        final sliderWidget = tester.widget<RangeSlider>(rangeSlider);
        final initialRange = sliderWidget.values;

        // Drag the slider horizontally to change range values
        // Drag from left side to right to increase start value

        await tester.slideToValue(rangeSlider, 25);
        await tester.pumpAndSettle();

        // Verify the range has been updated
        final updatedFilter = repository.filters['priceRange'] as LdFilterRange<_RangeTestItem, int>;

        expect(updatedFilter.range.start, greaterThan(initialRange.start));

        await tester.slideToValue(rangeSlider, 75, fromRight: true);

        await tester.pumpAndSettle();

        // Verify the end range has been updated
        final updatedFilter2 = repository.filters['priceRange'] as LdFilterRange<_RangeTestItem, int>;
        expect(updatedFilter2.range.end, lessThan(initialRange.end));

        // Find and tap the X button to deactivate
        final xIconButton = find.widgetWithIcon(LdButton, LucideIcons.x);
        expect(xIconButton, findsOneWidget);
        await tester.tap(xIconButton);
        await tester.pumpAndSettle();

        // Check if the filter is now inactive in the repository's filters
        expect(repository.filters['priceRange']!.isOn, isFalse);
      });
    });
  });
}

extension SlideTo on WidgetTester {
  Future<void> slideToValue(Finder slider, double value, {double paddingOffset = 24.0, bool fromRight = false}) async {
    final topRight = getTopRight(slider);
    final topLeft = getTopLeft(slider);
    final centerY = getSize(slider).height / 2 + topRight.dy;
    final startPoint = Offset(topLeft.dx + paddingOffset, centerY);
    final endPoint = Offset(topRight.dx - paddingOffset, centerY);
    final totalWidth = getSize(slider).width - (2 * paddingOffset);
    final calculatdOffset = value * (totalWidth / 100);
    if (fromRight) {
      await dragFrom(endPoint, Offset(-calculatdOffset, 0));
    } else {
      await dragFrom(startPoint, Offset(calculatdOffset, 0));
    }
  }
}
