import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

LdFilterAnyOf<TestItem, int, String> _tagsFilter({
  Map<String, Widget Function(BuildContext)>? allValues,
  Set<String>? selected,
  bool isOn = false,
}) {
  return LdFilterAnyOf<TestItem, int, String>(
    name: 'tags',
    label: (context) => 'Tags',
    icon: (context) => const Icon(Icons.label),
    allValues: allValues ?? {
      'Gold': (context) => const Text('Gold'),
      'Silver': (context) => const Text('Silver'),
    },
    initialSelected: selected,
  ).copyWith(isOn: isOn);
}

LdFilterOneOf<TestItem, int, String> _categoryFilter({
  Map<String, Widget Function(BuildContext)>? allValues,
  String? selected,
  bool isOn = false,
}) {
  return LdFilterOneOf<TestItem, int, String>(
    name: 'category',
    label: (context) => 'Category',
    icon: (context) => const Icon(Icons.category),
    allValues: allValues ?? {
      'Gold': (context) => const Text('Gold'),
      'Silver': (context) => const Text('Silver'),
    },
  ).copyWith(
    selectedValue: selected,
    isOn: isOn,
    clearSelectedValue: selected == null,
  );
}

Widget _wrapChipsHarness({
  required TestSortAndFilterState<TestItem, int> shellState,
  required Widget child,
}) {
  return LdThemeProvider(
    child: MaterialApp(
      localizationsDelegates: LiquidLocalizations.localizationsDelegates,
      home: Scaffold(
        body: ListenableProvider<LdRepository<TestItem, int>>.value(
          value: createTestRepository(),
          child: ListenableProvider<TestSortAndFilterState<TestItem, int>>.value(
            value: shellState,
            child: Provider<LdMonkeyRouterController<TestItem, int>>.value(
              value: shellState.controllerDelegate,
              child: Builder(
                builder: (context) {
                  context.watch<TestSortAndFilterState<TestItem, int>>();
                  return Provider<LdMonkeySortAndFilterState<TestItem, int>>.value(
                    value: shellState.state,
                    child: child,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  group('LdFilterChipsBar', () {
    testWidgets('oneOf inline chip updates filter state', (WidgetTester tester) async {
      final filter = _categoryFilter();
      final shellState = TestSortAndFilterState<TestItem, int>(filters: {filter});

      await tester.pumpWidget(
        _wrapChipsHarness(
          shellState: shellState,
          child: LdFilterChipsBar<TestItem, int>(
            configs: [
              LdFilterChipConfig.oneOf(
                filterName: 'category',
                presentation: LdFilterChipPresentation.inline,
                showAllOption: true,
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Silver'));
      await tester.pumpAndSettle();

      final updated = shellState.filtersMap['category'] as LdFilterOneOf<TestItem, int, String>;
      expect(updated.isOn, isTrue);
      expect(updated.selectedValue, 'Silver');
    });

    testWidgets('groupLabel renders muted label before chips', (WidgetTester tester) async {
      final filter = _tagsFilter();
      final shellState = TestSortAndFilterState<TestItem, int>(filters: {filter});

      await tester.pumpWidget(
        _wrapChipsHarness(
          shellState: shellState,
          child: LdFilterChipsBar<TestItem, int>(
            configs: [
              LdFilterChipConfig.anyOf(
                filterName: 'tags',
                groupLabel: (context) => 'Tags',
                presentation: LdFilterChipPresentation.inline,
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tags'), findsOneWidget);
    });

    testWidgets('anyOf inline chips toggle selected values', (WidgetTester tester) async {
      final filter = _tagsFilter();
      final shellState = TestSortAndFilterState<TestItem, int>(filters: {filter});

      await tester.pumpWidget(
        _wrapChipsHarness(
          shellState: shellState,
          child: LdFilterChipsBar<TestItem, int>(
            configs: [
              LdFilterChipConfig.anyOf(
                filterName: 'tags',
                presentation: LdFilterChipPresentation.inline,
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Gold'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Silver'));
      await tester.pumpAndSettle();

      final updated = shellState.filtersMap['tags'] as LdFilterAnyOf<TestItem, int, String>;
      expect(updated.isOn, isTrue);
      expect(updated.selectedValues, {'Gold', 'Silver'});
    });

    testWidgets('bool chip toggles filter', (WidgetTester tester) async {
      final filter = LdFilterBool<TestItem, int>(
        name: 'done',
        label: (context) => 'Done',
        icon: (context) => const Icon(Icons.check),
      );
      final shellState = TestSortAndFilterState<TestItem, int>(filters: {filter});

      await tester.pumpWidget(
        _wrapChipsHarness(
          shellState: shellState,
          child: LdFilterChipsBar<TestItem, int>(
            configs: [
              LdFilterChipConfig.bool(filterName: 'done'),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      final updated = shellState.filtersMap['done'] as LdFilterBool<TestItem, int>;
      expect(updated.isOn, isTrue);
    });
  });
}
