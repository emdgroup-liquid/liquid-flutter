import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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
    allValues: allValues ??
        {
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
    allValues: allValues ??
        {
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
  LdPlatform? platform,
}) {
  return LdThemeProvider(
    platform: platform,
    child: MaterialApp(
      localizationsDelegates: LiquidLocalizations.localizationsDelegates,
      home: Scaffold(
        body: ListenableProvider<LdListController<TestItem, int>>.value(
          value: createTestListController(),
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
                presentation: LdFilterChipChoicePresentation.inline,
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
                presentation: LdFilterChipChoicePresentation.inline,
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
                presentation: LdFilterChipChoicePresentation.inline,
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

    testWidgets('range chip opens context menu', (WidgetTester tester) async {
      final filter = LdFilterRange<TestItem, int>(
        name: 'rating',
        label: (context) => 'Rating',
        icon: (context) => const Icon(Icons.tune),
        min: 0,
        max: 5,
      );
      final shellState = TestSortAndFilterState<TestItem, int>(filters: {filter});

      await tester.pumpWidget(
        _wrapChipsHarness(
          shellState: shellState,
          child: LdFilterChipsBar<TestItem, int>(
            configs: [
              LdFilterChipConfig.range(
                filterName: 'rating',
                menuTitle: (context) => 'Rating range',
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Rating'));
      await tester.pumpAndSettle();

      expect(find.text('Rating range'), findsOneWidget);

      await tester.tap(find.widgetWithIcon(LdButton, LucideIcons.x));
      await tester.pumpAndSettle();

      final updated = shellState.filtersMap['rating'] as LdFilterRange<TestItem, int>;
      expect(updated.isOn, isFalse);
    });

    testWidgets('oneOf choose mode renders a trigger chip', (WidgetTester tester) async {
      final filter = _categoryFilter();
      final shellState = TestSortAndFilterState<TestItem, int>(filters: {filter});

      await tester.pumpWidget(
        _wrapChipsHarness(
          shellState: shellState,
          child: LdFilterChipsBar<TestItem, int>(
            configs: [
              LdFilterChipConfig.oneOf(
                filterName: 'category',
                presentation: LdFilterChipChoicePresentation.choose,
                showAllOption: true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Gold'), findsNothing);
      expect(find.text('Silver'), findsNothing);
    });

    testWidgets('anyOf choose mode renders a trigger chip', (WidgetTester tester) async {
      final filter = _tagsFilter();
      final shellState = TestSortAndFilterState<TestItem, int>(filters: {filter});

      await tester.pumpWidget(
        _wrapChipsHarness(
          shellState: shellState,
          child: LdFilterChipsBar<TestItem, int>(
            configs: [
              LdFilterChipConfig.anyOf(
                filterName: 'tags',
                presentation: LdFilterChipChoicePresentation.choose,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Tags'), findsOneWidget);
      expect(find.text('Gold'), findsNothing);
      expect(find.text('Silver'), findsNothing);
    });

    testWidgets('desktop wrap keeps groups on one line when they fit', (tester) async {
      final shellState = TestSortAndFilterState<TestItem, int>(
        filters: {
          LdFilterRange<TestItem, int>(
            name: 'rating',
            label: (context) => 'Rating',
            icon: (context) => const Icon(Icons.tune),
            min: 0,
            max: 5,
          ),
          LdFilterAnyOf<TestItem, int, String>(
            name: 'genre',
            label: (context) => 'Genre',
            icon: (context) => const Icon(Icons.movie),
            allValues: {
              'Action': (context) => const Text('Action'),
              'Drama': (context) => const Text('Drama'),
            },
          ),
        },
      );

      await tester.pumpWidget(
        LdThemeProvider(
          platform: LdPlatform.macos,
          child: MaterialApp(
            localizationsDelegates: LiquidLocalizations.localizationsDelegates,
            home: Center(
              child: SizedBox(
                width: 600,
                child: _wrapChipsHarness(
                  platform: LdPlatform.macos,
                  shellState: shellState,
                  child: LdFilterChipsBar<TestItem, int>(
                    configs: [
                      LdFilterChipConfig.range(filterName: 'rating'),
                      LdFilterChipConfig.anyOf(
                        filterName: 'genre',
                        groupLabel: (context) => 'Genre',
                        presentation: LdFilterChipChoicePresentation.inline,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final ratingY = tester.getTopLeft(find.text('Rating')).dy;
      final genreY = tester.getTopLeft(find.text('Genre')).dy;
      expect(ratingY, genreY);
    });

    testWidgets('desktop wrap breaks inline chips across lines when group overflows', (tester) async {
      final shellState = TestSortAndFilterState<TestItem, int>(
        filters: {
          LdFilterAnyOf<TestItem, int, String>(
            name: 'genre',
            label: (context) => 'Genre',
            icon: (context) => const Icon(Icons.movie),
            allValues: {
              'Action': (context) => const Text('Action'),
              'Adventure': (context) => const Text('Adventure'),
              'Crime': (context) => const Text('Crime'),
              'Drama': (context) => const Text('Drama'),
              'Fantasy': (context) => const Text('Fantasy'),
              'Sci-Fi': (context) => const Text('Sci-Fi'),
            },
          ),
        },
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          home: Center(
            child: SizedBox(
              width: 160,
              child: _wrapChipsHarness(
                platform: LdPlatform.macos,
                shellState: shellState,
                child: LdFilterChipsBar<TestItem, int>(
                  configs: [
                    LdFilterChipConfig.anyOf(
                      filterName: 'genre',
                      groupLabel: (context) => 'Genre',
                      presentation: LdFilterChipChoicePresentation.inline,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final yPositions = [
        tester.getTopLeft(find.text('Action')).dy,
        tester.getTopLeft(find.text('Adventure')).dy,
        tester.getTopLeft(find.text('Crime')).dy,
        tester.getTopLeft(find.text('Drama')).dy,
        tester.getTopLeft(find.text('Fantasy')).dy,
        tester.getTopLeft(find.text('Sci-Fi')).dy,
      ];
      expect(yPositions.toSet().length, greaterThan(1));
    });
  });
}
