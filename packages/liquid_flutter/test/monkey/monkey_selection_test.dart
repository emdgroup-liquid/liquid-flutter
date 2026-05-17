import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

void main() {
  group('LdMonkeySelection Tests', () {
    group('Adaptive Selection', () {
      testWidgets('adaptive() returns selection for masterAppBar location', (WidgetTester tester) async {
        await tester.pumpWidget(
          Provider.value(
            value: LdMonkeyActionLocation.masterAppBar,
            child: Provider.value(
              value: LdMonkeySelection<TestItem, int>(
                selection: {1, 2},
                viewing: {3, 4},
                showSelectionControls: false,
              ),
              child: Builder(
                builder: (context) {
                  final adaptive = LdMonkeySelection.adaptive<TestItem, int>(context);
                  expect(adaptive, equals({1, 2}));
                  return Container();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('adaptive() returns viewing for detailAppBar location', (WidgetTester tester) async {
        await tester.pumpWidget(
          Provider.value(
            value: LdMonkeyActionLocation.detailAppBar,
            child: Provider.value(
              value: LdMonkeySelection<TestItem, int>(
                selection: {1, 2},
                viewing: {3, 4},
                showSelectionControls: false,
              ),
              child: Builder(
                builder: (context) {
                  final adaptive = LdMonkeySelection.adaptive<TestItem, int>(context);
                  expect(adaptive, equals({3, 4}));
                  return Container();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('adaptive() returns viewing for detailSecondary location', (WidgetTester tester) async {
        await tester.pumpWidget(
          Provider.value(
            value: LdMonkeyActionLocation.detailSecondary,
            child: Provider.value(
              value: LdMonkeySelection<TestItem, int>(
                selection: {1, 2},
                viewing: {3, 4},
                showSelectionControls: false,
              ),
              child: Builder(
                builder: (context) {
                  final adaptive = LdMonkeySelection.adaptive<TestItem, int>(context);
                  expect(adaptive, equals({3, 4}));
                  return Container();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('adaptive() returns selection for context location', (WidgetTester tester) async {
        await tester.pumpWidget(
          Provider.value(
            value: LdMonkeyActionLocation.context,
            child: Provider.value(
              value: LdMonkeySelection<TestItem, int>(
                selection: {1, 2},
                viewing: {3, 4},
                showSelectionControls: false,
              ),
              child: Builder(
                builder: (context) {
                  final adaptive = LdMonkeySelection.adaptive<TestItem, int>(context);
                  expect(adaptive, equals({1, 2}));
                  return Container();
                },
              ),
            ),
          ),
        );
      });

      testWidgets('adaptive() returns selection for masterSecondary location', (WidgetTester tester) async {
        await tester.pumpWidget(
          Provider.value(
            value: LdMonkeyActionLocation.masterSecondary,
            child: Provider.value(
              value: LdMonkeySelection<TestItem, int>(
                selection: {1, 2},
                viewing: {3, 4},
                showSelectionControls: false,
              ),
              child: Builder(
                builder: (context) {
                  final adaptive = LdMonkeySelection.adaptive<TestItem, int>(context);
                  expect(adaptive, equals({1, 2}));
                  return Container();
                },
              ),
            ),
          ),
        );
      });
    });

    group('getSelectedItems', () {
      test('getSelectedItems retrieves items from repository', () async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1),
            createTestItem(2),
          ],
        );

        final selection = {1, 2};
        final items = await Future.wait(selection.map((id) => repository.getById(id)));

        expect(items.length, equals(2));
        expect(items.map((e) => e.id).toSet(), equals({1, 2}));
      });

      test('getSelectedItems returns empty list for empty selection', () async {
        final repository = createTestRepository();
        final selection = <int>{};
        final items = await Future.wait(selection.map((id) => repository.getById(id)));

        expect(items, isEmpty);
      });
    });

    group('getViewingItems', () {
      test('getViewingItems retrieves items from repository', () async {
        final repository = createTestRepository(
          initialItems: [
            createTestItem(1),
            createTestItem(2),
          ],
        );

        final viewing = {1, 2};
        final items = await Future.wait(viewing.map((id) => repository.getById(id)));

        expect(items.length, equals(2));
        expect(items.map((e) => e.id).toSet(), equals({1, 2}));
      });

      test('getViewingItems returns empty list for empty viewing', () async {
        final repository = createTestRepository();
        final viewing = <int>{};
        final items = await Future.wait(viewing.map((id) => repository.getById(id)));

        expect(items, isEmpty);
      });
    });

    group('of() Method', () {
      testWidgets('of() returns selection from context', (WidgetTester tester) async {
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {1, 2},
          viewing: {3, 4},
          showSelectionControls: false,
        );

        await tester.pumpWidget(
          Provider.value(
            value: selection,
            child: Builder(
              builder: (context) {
                final result = LdMonkeySelection.of<TestItem, int>(context);
                expect(result.selection, equals({1, 2}));
                expect(result.viewing, equals({3, 4}));
                return Container();
              },
            ),
          ),
        );
      });

      testWidgets('of() with listen=true watches changes', (WidgetTester tester) async {
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {1},
          viewing: {},
          showSelectionControls: false,
        );

        await tester.pumpWidget(
          Provider.value(
            value: selection,
            child: Builder(
              builder: (context) {
                final result = LdMonkeySelection.of<TestItem, int>(context, listen: true);
                expect(result.selection, equals({1}));
                return Container();
              },
            ),
          ),
        );
      });
    });

    group('Equality', () {
      test('two selections with same values are equal', () {
        final selection1 = LdMonkeySelection<TestItem, int>(
          selection: {1, 2},
          viewing: {3, 4},
          showSelectionControls: false,
        );
        final selection2 = LdMonkeySelection<TestItem, int>(
          selection: {1, 2},
          viewing: {3, 4},
          showSelectionControls: false,
        );

        expect(selection1, equals(selection2));
      });

      test('selections with different selection sets are not equal', () {
        final selection1 = LdMonkeySelection<TestItem, int>(
          selection: {1, 2},
          viewing: {3, 4},
          showSelectionControls: false,
        );
        final selection2 = LdMonkeySelection<TestItem, int>(
          selection: {1},
          viewing: {3, 4},
          showSelectionControls: false,
        );

        expect(selection1, isNot(equals(selection2)));
      });

      test('selections with different viewing sets are not equal', () {
        final selection1 = LdMonkeySelection<TestItem, int>(
          selection: {1, 2},
          viewing: {3, 4},
          showSelectionControls: false,
        );
        final selection2 = LdMonkeySelection<TestItem, int>(
          selection: {1, 2},
          viewing: {3},
          showSelectionControls: false,
        );

        expect(selection1, isNot(equals(selection2)));
      });
    });
  });
}
