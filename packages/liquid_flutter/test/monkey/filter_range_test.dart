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
        );

        final marshaled = filter.marshalSerialized('');
        expect(marshaled.isOn, isFalse);
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
        );

        final shellState = _RangeShellState(filter);

        final repository = LdRepository<_RangeTestItem, int>(
          fetchListWithParameters: (parameters) async {
            return LdListPage<_RangeTestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _RangeTestItem(id, 'Test', 10.0),
        );

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: Scaffold(
                body: ListenableProvider<LdRepository<_RangeTestItem, int>>.value(
                  value: repository,
                  child: ListenableProvider<_RangeShellState>.value(
                    value: shellState,
                    child: Provider<LdMonkeyRouterController<_RangeTestItem, int>>.value(
                      value: shellState.controllerDelegate,
                      child: Builder(
                        builder: (context) {
                          context.watch<_RangeShellState>();
                          return Provider<LdMonkeySortAndFilterState<_RangeTestItem, int>>.value(
                            value: shellState.state,
                            child: const LdFilterModal<_RangeTestItem, int>(),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final priceFilterButton = find.widgetWithText(LdButton, 'Price');

        expect(shellState.filtersMap['priceRange']!.isOn, isFalse);
        expect(priceFilterButton, findsOneWidget);

        await tester.tap(priceFilterButton);
        await tester.pumpAndSettle();

        expect(shellState.filtersMap['priceRange']!.isOn, isTrue);

        // Find the RangeSlider and interact with it
        final rangeSlider = find.byType(RangeSlider);
        expect(rangeSlider, findsOneWidget);

        final sliderWidget = tester.widget<RangeSlider>(rangeSlider);
        final initialRange = sliderWidget.values;

        await tester.slideToValue(rangeSlider, 25);
        await tester.pumpAndSettle();

        final updatedFilter = shellState.filtersMap['priceRange'] as LdFilterRange<_RangeTestItem, int>;
        expect(updatedFilter.range.start, greaterThan(initialRange.start));

        await tester.slideToValue(rangeSlider, 75, fromRight: true);
        await tester.pumpAndSettle();

        final updatedFilter2 = shellState.filtersMap['priceRange'] as LdFilterRange<_RangeTestItem, int>;
        expect(updatedFilter2.range.end, lessThan(initialRange.end));

        final xIconButton = find.widgetWithIcon(LdButton, LucideIcons.x);
        expect(xIconButton, findsOneWidget);
        await tester.tap(xIconButton);
        await tester.pumpAndSettle();

        expect(shellState.filtersMap['priceRange']!.isOn, isFalse);
      });
    });
  });
}

/// Non-Listenable delegate used to provide [_RangeShellState] as
/// [LdMonkeyRouterController] without triggering Provider's debug assertion.
class _RangeControllerDelegate implements LdMonkeyRouterController<_RangeTestItem, int> {
  final _RangeShellState _delegate;
  _RangeControllerDelegate(this._delegate);

  @override
  void updateFilter(BuildContext context, LdFilterOption<_RangeTestItem, int> filter) =>
      _delegate.updateFilter(context, filter);

  @override
  void updateSortOptions(BuildContext context, List<LdSortOption<_RangeTestItem, int>> sortOptions) =>
      _delegate.updateSortOptions(context, sortOptions);

  @override
  void updateSelection(BuildContext context, Set<int> selection) =>
      _delegate.updateSelection(context, selection);

  @override
  void updateViewing(BuildContext context, Set<int> viewingItems) =>
      _delegate.updateViewing(context, viewingItems);

  @override
  void updateShowSelectionControls(BuildContext context, bool showSelectionControls) =>
      _delegate.updateShowSelectionControls(context, showSelectionControls);
}

/// A dedicated [TestSortAndFilterState] subclass for _RangeTestItem so the
/// type inference is correct in the widget test above.
class _RangeShellState extends ChangeNotifier
    implements LdMonkeyRouterController<_RangeTestItem, int> {
  Set<LdFilterOption<_RangeTestItem, int>> _filters;

  _RangeShellState(LdFilterOption<_RangeTestItem, int> initial) : _filters = {initial};

  /// Non-Listenable delegate for use with Provider<LdMonkeyRouterController>.value.
  LdMonkeyRouterController<_RangeTestItem, int> get controllerDelegate =>
      _RangeControllerDelegate(this);

  LdMonkeySortAndFilterState<_RangeTestItem, int> get state =>
      LdMonkeySortAndFilterState<_RangeTestItem, int>(
        filters: _filters,
        sortOptions: const [],
      );

  Map<String, LdFilterOption<_RangeTestItem, int>> get filtersMap =>
      {for (final f in _filters) f.name: f};

  @override
  void updateFilter(BuildContext context, LdFilterOption<_RangeTestItem, int> filter) {
    _filters = {
      for (final f in _filters)
        if (f.name == filter.name) filter else f,
    };
    notifyListeners();
  }

  @override
  void updateSortOptions(BuildContext context, List<LdSortOption<_RangeTestItem, int>> sortOptions) {}

  @override
  void updateSelection(BuildContext context, Set<int> selection) {}

  @override
  void updateViewing(BuildContext context, Set<int> viewingItems) {}

  @override
  void updateShowSelectionControls(BuildContext context, bool showSelectionControls) {}
}

extension SlideTo on WidgetTester {
  Future<void> slideToValue(Finder slider, double value,
      {double paddingOffset = 24.0, bool fromRight = false}) async {
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
