// ignore_for_file: lines_longer_than_80_chars
//
// The old `LdMonkeyShellState` public class was replaced by the private
// `_LdMonkeyShellState` and the router-driven `LdMonkeySelection` /
// `LdMonkeySortAndFilterState` value types.
//
// These tests exercise `LdMonkeySelection` (the public value-type equivalent)
// and the `TestSortAndFilterState` helper (which mimics the mutation API for
// unit tests without a real GoRouter).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'test_utils.dart';

void main() {
  group('LdMonkeySelection Tests', () {
    group('Initial State', () {
      test('initializes with empty selection and viewing', () {
        final selection = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );

        expect(selection.selection, isEmpty);
        expect(selection.viewing, isEmpty);
        expect(selection.showSelectionControls, isFalse);
      });
    });

    group('Equality and Hashing', () {
      test('two selections with same values are equal', () {
        final s1 = LdMonkeySelection<TestItem, int>(
          selection: {1, 2},
          viewing: {3},
          showSelectionControls: false,
        );
        final s2 = LdMonkeySelection<TestItem, int>(
          selection: {1, 2},
          viewing: {3},
          showSelectionControls: false,
        );
        expect(s1, equals(s2));
      });

      test('selections with different selection sets are not equal', () {
        final s1 = LdMonkeySelection<TestItem, int>(
          selection: {1},
          viewing: {},
          showSelectionControls: false,
        );
        final s2 = LdMonkeySelection<TestItem, int>(
          selection: {2},
          viewing: {},
          showSelectionControls: false,
        );
        expect(s1, isNot(equals(s2)));
      });

      test('selections with different viewing sets are not equal', () {
        final s1 = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {1},
          showSelectionControls: false,
        );
        final s2 = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {2},
          showSelectionControls: false,
        );
        expect(s1, isNot(equals(s2)));
      });

      test('selections with different showSelectionControls are not equal', () {
        final s1 = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: true,
        );
        final s2 = LdMonkeySelection<TestItem, int>(
          selection: {},
          viewing: {},
          showSelectionControls: false,
        );
        expect(s1, isNot(equals(s2)));
      });
    });
  });

  group('TestSortAndFilterState Tests', () {
    group('Filter Mutations', () {
      test('updateFilter replaces a filter by name', () {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (_) => 'Active',
          icon: (_) => const SizedBox(),
          isOn: false,
        );
        final state = TestSortAndFilterState<TestItem, int>(filters: {filter});

        state.updateFilter(MockBuildContext(), filter.copyWith(isOn: true));

        expect(state.filtersMap['active']!.isOn, isTrue);
      });

      test('updateFilter notifies listeners', () {
        final filter = LdFilterBool<TestItem, int>(
          name: 'active',
          label: (_) => 'Active',
          icon: (_) => const SizedBox(),
          isOn: false,
        );
        final state = TestSortAndFilterState<TestItem, int>(filters: {filter});
        var notified = false;
        state.addListener(() => notified = true);

        state.updateFilter(MockBuildContext(), filter.copyWith(isOn: true));

        expect(notified, isTrue);
      });
    });

    group('Selection Mutations', () {
      test('updateSelection changes currentSelection', () {
        final state = TestSortAndFilterState<TestItem, int>();
        state.updateSelection(MockBuildContext(), {1, 2, 3});
        expect(state.currentSelection, equals({1, 2, 3}));
      });

      test('updateViewing changes currentViewing', () {
        final state = TestSortAndFilterState<TestItem, int>();
        state.updateViewing(MockBuildContext(), {4, 5});
        expect(state.currentViewing, equals({4, 5}));
      });

      test('updateShowSelectionControls changes flag', () {
        final state = TestSortAndFilterState<TestItem, int>();
        expect(state.currentShowSelectionControls, isFalse);
        state.updateShowSelectionControls(MockBuildContext(), true);
        expect(state.currentShowSelectionControls, isTrue);
      });

      test('notifies listeners on selection change', () {
        final state = TestSortAndFilterState<TestItem, int>();
        var notified = false;
        state.addListener(() => notified = true);
        state.updateSelection(MockBuildContext(), {1});
        expect(notified, isTrue);
      });
    });

    group('selection getter', () {
      test('returns current selection value object', () {
        final state = TestSortAndFilterState<TestItem, int>();
        state.updateSelection(MockBuildContext(), {7});
        state.updateViewing(MockBuildContext(), {8});
        state.updateShowSelectionControls(MockBuildContext(), true);

        final sel = state.selection;
        expect(sel.selection, equals({7}));
        expect(sel.viewing, equals({8}));
        expect(sel.showSelectionControls, isTrue);
      });
    });
  });
}
