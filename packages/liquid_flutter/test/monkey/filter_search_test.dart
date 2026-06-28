import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

void main() {
  group('LdFilterSearchOption Tests', () {
    group('Serialization', () {
      test('serialize() returns searchText when on and non-empty', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'test query',
          isOn: true,
        );

        expect(filter.serialize(), equals('test query'));
      });

      test('serialize() returns empty string when off', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'test query',
          isOn: false,
        );

        expect(filter.serialize(), isEmpty);
      });

      test('serialize() returns empty string when searchText is empty', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: '',
          isOn: true,
        );

        expect(filter.serialize(), isEmpty);
      });

      test('marshalSerialized() updates searchText and isOn state', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: '',
          isOn: false,
        );

        final marshaled = filter.marshalSerialized('new query');
        expect(marshaled.searchText, equals('new query'));
        expect(marshaled.isOn, isTrue);
      });

      test('marshalSerialized() sets isOn to false when empty', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'query',
          isOn: true,
        );

        final marshaled = filter.marshalSerialized('');
        expect(marshaled.searchText, isEmpty);
        expect(marshaled.isOn, isFalse);
      });
    });

    group('CopyWith', () {
      test('copyWith() preserves all properties', () {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'query',
          isOn: true,
          hint: 'Enter search',
          debounceDelay: const Duration(milliseconds: 500),
        );

        final newFilter = filter.copyWith(
          searchText: 'new query',
          isOn: false,
        );

        expect(newFilter.searchText, equals('new query'));
        expect(newFilter.isOn, isFalse);
        expect(newFilter.name, equals('search'));
        expect(newFilter.hint, equals('Enter search'));
        expect(newFilter.debounceDelay, equals(const Duration(milliseconds: 500)));
      });
    });

    group('UI Rendering', () {
      testWidgets('renders the real search input with initial query', (WidgetTester tester) async {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          searchText: 'test',
          isOn: true,
        );

        final shellState = TestSortAndFilterState<TestItem, int>(filters: {filter});
        final repository = createTestListController();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: Scaffold(
                body: ListenableProvider<LdListController<TestItem, int>>.value(
                  value: repository,
                  child: Provider<LdMonkeyRouterController<TestItem, int>>.value(
                    value: shellState.controllerDelegate,
                    child: Builder(builder: filter.build),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // The real filter widget renders an LdInput seeded with the search text.
        expect(find.byType(LdSearchInput), findsOneWidget);
        expect(find.byType(LdInput), findsOneWidget);
        expect(find.text('test'), findsOneWidget);
      });

      testWidgets('typing in the search input updates the filter state', (WidgetTester tester) async {
        final filter = LdFilterSearch<TestItem, int, String>(
          name: 'search',
          label: (context) => 'Search',
          icon: (context) => const Icon(Icons.search),
          isOn: false,
        );

        final shellState = TestSortAndFilterState<TestItem, int>(filters: {filter});
        final repository = createTestListController();

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: Scaffold(
                body: ListenableProvider<LdListController<TestItem, int>>.value(
                  value: repository,
                  child: Provider<LdMonkeyRouterController<TestItem, int>>.value(
                    value: shellState.controllerDelegate,
                    child: Builder(builder: filter.build),
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        await tester.enterText(find.byType(LdInput), 'hello');
        // The search filter commits on submit (TextInputAction.search).
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle();

        final updated = shellState.filtersMap['search'] as LdFilterSearch<TestItem, int, String>;
        expect(updated.searchText, equals('hello'));
        expect(updated.isOn, isTrue);
      });
    });
  });
}
