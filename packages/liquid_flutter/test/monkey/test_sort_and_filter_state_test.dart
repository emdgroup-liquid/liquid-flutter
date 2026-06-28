// Tests for the [TestSortAndFilterState] helper in [test_utils.dart].
//
// This helper mimics the router-driven mutation API (filters, sort, selection,
// viewing) without a real GoRouter so other monkey tests can simulate state
// changes. These tests verify the harness itself behaves correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'test_utils.dart';

void main() {
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
