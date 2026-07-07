import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'test_utils.dart';

void main() {
  group('LdMonkeyDeletedItemsGuard', () {
    testWidgets('removes deleted id from selection and viewing', (WidgetTester tester) async {
      final repository = createTestListController();
      final shellState = TestSortAndFilterState<TestItem, int>();
      final mockContext = MockBuildContext();

      shellState.updateSelection(mockContext, {1, 2});
      shellState.updateViewing(mockContext, {1});

      await tester.pumpWidget(
        MaterialApp(
          home: wrapMonkeyDeletedItemsGuard<TestItem, int>(
            repository: repository,
            shellState: shellState,
            child: const SizedBox(),
          ),
        ),
      );

      repository.notifyItemUpdated(
        LdPaginatorItem<TestItem>(
          value: createTestItem(1),
          state: LdPaginatorItemState.deleted,
        ),
      );

      await tester.pump(); // drain stream delivery microtasks
      await tester.pump(const Duration(milliseconds: 500)); // fire the debounce timer

      expect(shellState.currentSelection, equals({2}));
      expect(shellState.currentViewing, isEmpty);
    });

    testWidgets('rapid batch delete removes all ids without partial overwrites', (WidgetTester tester) async {
      final repository = createTestListController();
      final shellState = TestSortAndFilterState<TestItem, int>();
      final mockContext = MockBuildContext();

      shellState.updateSelection(mockContext, {1, 2, 3});
      shellState.updateViewing(mockContext, {1, 2, 3});

      await tester.pumpWidget(
        MaterialApp(
          home: wrapMonkeyDeletedItemsGuard<TestItem, int>(
            repository: repository,
            shellState: shellState,
            child: const SizedBox(),
          ),
        ),
      );

      for (final id in [1, 2, 3]) {
        repository.notifyItemUpdated(
          LdPaginatorItem<TestItem>(
            value: createTestItem(id),
            state: LdPaginatorItemState.deleted,
          ),
        );
      }

      await tester.pump(); // drain stream delivery microtasks
      await tester.pump(const Duration(milliseconds: 500)); // fire the debounce timer

      expect(shellState.currentSelection, isEmpty);
      expect(shellState.currentViewing, isEmpty);
    });

    testWidgets('ignores non-deleted item updates', (WidgetTester tester) async {
      final repository = createTestListController();
      final shellState = TestSortAndFilterState<TestItem, int>();
      final mockContext = MockBuildContext();

      shellState.updateSelection(mockContext, {1});
      shellState.updateViewing(mockContext, {1});

      await tester.pumpWidget(
        MaterialApp(
          home: wrapMonkeyDeletedItemsGuard<TestItem, int>(
            repository: repository,
            shellState: shellState,
            child: const SizedBox(),
          ),
        ),
      );

      repository.notifyItemUpdated(
        LdPaginatorItem<TestItem>(
          value: createTestItem(1),
          state: LdPaginatorItemState.loaded,
        ),
      );

      await tester.pump();

      expect(shellState.currentSelection, equals({1}));
      expect(shellState.currentViewing, equals({1}));
    });
  });
}
