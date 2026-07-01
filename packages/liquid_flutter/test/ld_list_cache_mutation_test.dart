import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class _MutationItem with Identifiable<int> {
  @override
  final int id;
  final String title;
  final DateTime updatedAt;

  _MutationItem(this.id, this.title, this.updatedAt);

  _MutationItem copyWith({String? title, DateTime? updatedAt}) {
    return _MutationItem(
      id,
      title ?? this.title,
      updatedAt ?? this.updatedAt,
    );
  }
}

Widget _icon(BuildContext context) => const SizedBox.shrink();

String _label(BuildContext context) => 'label';

Widget _wrapWithSortFilter({
  required Widget child,
  LdMonkeySortAndFilterState<_MutationItem, int>? sortAndFilterState,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      LiquidLocalizations.delegate,
    ],
    home: LdThemeProvider(
      child: sortAndFilterState == null
          ? Scaffold(body: child)
          : Provider<LdMonkeySortAndFilterState<_MutationItem, int>>.value(
              value: sortAndFilterState,
              child: Scaffold(body: child),
            ),
    ),
  );
}

Future<BuildContext> _pumpContext(
  WidgetTester tester, {
  LdMonkeySortAndFilterState<_MutationItem, int>? sortAndFilterState,
}) async {
  late BuildContext context;
  await tester.pumpWidget(
    _wrapWithSortFilter(
      sortAndFilterState: sortAndFilterState,
      child: Builder(
        builder: (ctx) {
          context = ctx;
          return const SizedBox();
        },
      ),
    ),
  );
  await tester.pump();
  return context;
}

LdMonkeySortAndFilterState<_MutationItem, int> _sortFilterState({
  List<LdSortOption<_MutationItem, int>>? sortOptions,
  Set<LdFilterOption<_MutationItem, int>>? filters,
}) {
  return LdMonkeySortAndFilterState<_MutationItem, int>(
    filters: filters ?? {},
    sortOptions: sortOptions ??
        [
          LdSortOption<_MutationItem, int>(
            name: 'title',
            label: _label,
            icon: _icon,
          ),
          LdSortOption<_MutationItem, int>(
            name: 'updated',
            label: _label,
            icon: _icon,
          ),
        ],
  );
}

void main() {
  group('LdListCache.invalidateOnMutation', () {
    testWidgets('create clears cache', (tester) async {
      final cache = LdListCache<_MutationItem, int>();
      final context = await _pumpContext(tester);
      cache.writePage(
        'sort:title=title-asc',
        offset: 0,
        items: [_MutationItem(1, 'A', DateTime(2024))],
        total: 1,
      );

      cache.invalidateOnMutation(
        context: context,
        kind: LdListMutationKind.create,
        after: _MutationItem(2, 'B', DateTime(2024)),
      );

      expect(cache.keys, isEmpty);
    });

    testWidgets('delete clears cache', (tester) async {
      final cache = LdListCache<_MutationItem, int>();
      final context = await _pumpContext(tester);
      cache.writePage(
        'sort:title=title-asc',
        offset: 0,
        items: [_MutationItem(1, 'A', DateTime(2024))],
        total: 1,
      );

      cache.invalidateOnMutation(
        context: context,
        kind: LdListMutationKind.delete,
        before: _MutationItem(1, 'A', DateTime(2024)),
      );

      expect(cache.keys, isEmpty);
    });

    testWidgets('update without predicates clears cache', (tester) async {
      final cache = LdListCache<_MutationItem, int>();
      final context = await _pumpContext(
        tester,
        sortAndFilterState: _sortFilterState(),
      );
      cache.writePage(
        'sort:title=title-asc',
        offset: 0,
        items: [_MutationItem(1, 'A', DateTime(2024))],
        total: 1,
      );

      cache.invalidateOnMutation(
        context: context,
        kind: LdListMutationKind.update,
        before: _MutationItem(1, 'A', DateTime(2024)),
        after: _MutationItem(1, 'B', DateTime(2024)),
      );

      expect(cache.keys, isEmpty);
    });

    testWidgets('update removes only keys affected by title sort predicate', (tester) async {
      final cache = LdListCache<_MutationItem, int>();
      final sortOptions = [
        LdSortOption<_MutationItem, int>(
          name: 'title',
          label: _label,
          icon: _icon,
          isOn: true,
          affectedByUpdate: (before, after) => before?.title != after?.title,
        ),
        LdSortOption<_MutationItem, int>(
          name: 'updated',
          label: _label,
          icon: _icon,
          isOn: true,
          affectedByUpdate: (before, after) => before?.updatedAt != after?.updatedAt,
        ),
      ];
      final context = await _pumpContext(
        tester,
        sortAndFilterState: _sortFilterState(sortOptions: sortOptions),
      );

      const titleKey = 'sort:title=title-asc';
      const updatedKey = 'sort:updated=updated-asc';
      cache.writePage(
        titleKey,
        offset: 0,
        items: [_MutationItem(1, 'A', DateTime(2024))],
        total: 1,
      );
      cache.writePage(
        updatedKey,
        offset: 0,
        items: [_MutationItem(1, 'A', DateTime(2024))],
        total: 1,
      );

      cache.invalidateOnMutation(
        context: context,
        kind: LdListMutationKind.update,
        before: _MutationItem(1, 'A', DateTime(2024)),
        after: _MutationItem(1, 'B', DateTime(2024)),
      );

      expect(cache.readPage(titleKey, 0), isNull);
      expect(cache.readPage(updatedKey, 0), isNotNull);
    });

    testWidgets('update retains key when predicate returns false', (tester) async {
      final cache = LdListCache<_MutationItem, int>();
      final sortOptions = [
        LdSortOption<_MutationItem, int>(
          name: 'title',
          label: _label,
          icon: _icon,
          isOn: true,
          affectedByUpdate: (before, after) => before?.title != after?.title,
        ),
      ];
      final context = await _pumpContext(
        tester,
        sortAndFilterState: _sortFilterState(sortOptions: sortOptions),
      );

      const titleKey = 'sort:title=title-asc';
      cache.writePage(
        titleKey,
        offset: 0,
        items: [_MutationItem(1, 'A', DateTime(2024))],
        total: 1,
      );

      cache.invalidateOnMutation(
        context: context,
        kind: LdListMutationKind.update,
        before: _MutationItem(1, 'A', DateTime(2024)),
        after: _MutationItem(1, 'A', DateTime(2025)),
      );

      expect(cache.readPage(titleKey, 0), isNotNull);
    });

    testWidgets('null predicate on key part removes key conservatively', (tester) async {
      final cache = LdListCache<_MutationItem, int>();
      final sortOptions = [
        LdSortOption<_MutationItem, int>(
          name: 'title',
          label: _label,
          icon: _icon,
          isOn: true,
        ),
        LdSortOption<_MutationItem, int>(
          name: 'updated',
          label: _label,
          icon: _icon,
          affectedByUpdate: (before, after) => before?.updatedAt != after?.updatedAt,
        ),
      ];
      final context = await _pumpContext(
        tester,
        sortAndFilterState: _sortFilterState(sortOptions: sortOptions),
      );

      const titleKey = 'sort:title=title-asc';
      cache.writePage(
        titleKey,
        offset: 0,
        items: [_MutationItem(1, 'A', DateTime(2024))],
        total: 1,
      );

      cache.invalidateOnMutation(
        context: context,
        kind: LdListMutationKind.update,
        before: _MutationItem(1, 'A', DateTime(2024)),
        after: _MutationItem(1, 'A', DateTime(2025)),
      );

      expect(cache.readPage(titleKey, 0), isNull);
    });

    testWidgets('update without sort filter state clears cache', (tester) async {
      final cache = LdListCache<_MutationItem, int>();
      final context = await _pumpContext(tester);
      cache.writePage(
        'sort:title=title-asc',
        offset: 0,
        items: [_MutationItem(1, 'A', DateTime(2024))],
        total: 1,
      );

      cache.invalidateOnMutation(
        context: context,
        kind: LdListMutationKind.update,
        before: _MutationItem(1, 'A', DateTime(2024)),
        after: _MutationItem(1, 'B', DateTime(2024)),
      );

      expect(cache.keys, isEmpty);
    });
  });
}
