import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

class _LayoutItem with Identifiable<int> {
  @override
  final int id;
  final String title;
  final int score;

  _LayoutItem(this.id, this.title, this.score);

  _LayoutItem copyWith({String? title, int? score}) {
    return _LayoutItem(id, title ?? this.title, score ?? this.score);
  }
}

String _label(BuildContext context) => 'label';

Widget _icon(BuildContext context) => const SizedBox.shrink();

void main() {
  group('ld_affected_by_update', () {
    test('evaluateAffectedByUpdate defaults to true when predicate is null', () {
      expect(
        evaluateAffectedByUpdate<_LayoutItem>(null, null, _LayoutItem(1, 'a', 1)),
        isTrue,
      );
    });

    testWidgets('isLayoutAffectedByUpdate is false without sort/filter state', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: LdThemeProvider(
            child: Builder(
              builder: (ctx) {
                context = ctx;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(
        isLayoutAffectedByUpdate<_LayoutItem, int>(
          context: context,
          before: _LayoutItem(1, 'a', 1),
          after: _LayoutItem(1, 'b', 1),
        ),
        isFalse,
      );
    });

    testWidgets('isLayoutAffectedByUpdate is conservative without predicates', (tester) async {
      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: LdThemeProvider(
            child: Provider<LdMonkeySortAndFilterState<_LayoutItem, int>>.value(
              value: LdMonkeySortAndFilterState<_LayoutItem, int>(
                filters: {},
                sortOptions: [],
              ),
              child: Builder(
                builder: (ctx) {
                  context = ctx;
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(
        isLayoutAffectedByUpdate<_LayoutItem, int>(
          context: context,
          before: _LayoutItem(1, 'a', 1),
          after: _LayoutItem(1, 'b', 1),
        ),
        isTrue,
      );
    });

    testWidgets('isLayoutAffectedByUpdate respects active sort predicate', (tester) async {
      late BuildContext context;
      final state = LdMonkeySortAndFilterState<_LayoutItem, int>(
        filters: {},
        sortOptions: [
          LdSortOption<_LayoutItem, int>(
            name: 'title',
            label: _label,
            icon: _icon,
            isOn: true,
            affectedByUpdate: (before, after) => before?.title != after?.title,
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [LiquidLocalizations.delegate],
          home: LdThemeProvider(
            child: Provider<LdMonkeySortAndFilterState<_LayoutItem, int>>.value(
              value: state,
              child: Builder(
                builder: (ctx) {
                  context = ctx;
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(
        isLayoutAffectedByUpdate<_LayoutItem, int>(
          context: context,
          before: _LayoutItem(1, 'a', 1),
          after: _LayoutItem(1, 'b', 1),
        ),
        isTrue,
      );
      expect(
        isLayoutAffectedByUpdate<_LayoutItem, int>(
          context: context,
          before: _LayoutItem(1, 'a', 1),
          after: _LayoutItem(1, 'a', 2),
        ),
        isFalse,
      );
    });

    test('isCacheKeyAffectedByUpdate only invalidates matching sort keys', () {
      final sorts = {
        'title': LdSortOption<_LayoutItem, int>(
          name: 'title',
          label: _label,
          icon: _icon,
          isOn: true,
          affectedByUpdate: (before, after) => before?.title != after?.title,
        ),
        'score': LdSortOption<_LayoutItem, int>(
          name: 'score',
          label: _label,
          icon: _icon,
          isOn: true,
          affectedByUpdate: (before, after) => before?.score != after?.score,
        ),
      };

      expect(
        isCacheKeyAffectedByUpdate<_LayoutItem, int>(
          cacheKey: 'sort:title=title-asc',
          before: _LayoutItem(1, 'a', 1),
          after: _LayoutItem(1, 'b', 1),
          filtersByName: {},
          sortsByName: sorts,
        ),
        isTrue,
      );
      expect(
        isCacheKeyAffectedByUpdate<_LayoutItem, int>(
          cacheKey: 'sort:score=score-asc',
          before: _LayoutItem(1, 'a', 1),
          after: _LayoutItem(1, 'b', 1),
          filtersByName: {},
          sortsByName: sorts,
        ),
        isFalse,
      );
    });
  });
}
