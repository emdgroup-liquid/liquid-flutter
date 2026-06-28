import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

import 'test_utils.dart';

class _RouterAdapterHarness extends StatefulWidget {
  final LdMonkeyRouteConfig<TestItem, int> routeConfig;
  final LdListController<TestItem, int> repository;
  final List<String> initialOptions;

  const _RouterAdapterHarness({
    super.key,
    required this.routeConfig,
    required this.repository,
    required this.initialOptions,
  });

  @override
  State<_RouterAdapterHarness> createState() => _RouterAdapterHarnessState();
}

class _RouterAdapterHarnessState extends State<_RouterAdapterHarness> {
  late List<LdFilterOption<TestItem, int>> _filters;
  LdMonkeySortAndFilterState<TestItem, int>? latestState;

  @override
  void initState() {
    super.initState();
    _filters = [_buildCategoryFilter(widget.initialOptions)];
  }

  LdFilterOneOf<TestItem, int, String> _buildCategoryFilter(List<String> options) {
    return LdFilterOneOf<TestItem, int, String>(
      name: 'category',
      label: (context) => 'Category',
      icon: (context) => const Icon(Icons.category),
      allValues: {
        for (final option in options) option: (context) => Text(option),
      },
    );
  }

  void replaceOptions(List<String> options) {
    setState(() {
      _filters = [_buildCategoryFilter(options)];
    });
  }

  LdFilterOneOf<TestItem, int, String> get categoryFilter {
    final state = latestState;
    if (state == null) {
      throw StateError('categoryFilter requested before first build');
    }

    return state.filters.whereType<LdFilterOneOf<TestItem, int, String>>().first;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider<LdListController<TestItem, int>>.value(
      value: widget.repository,
      child: LdMonkeyRouterAdapter<TestItem, int>(
        routeConfig: widget.routeConfig,
        filters: _filters,
        sortOptions: const [],
        child: Builder(
          builder: (context) {
            final state = context.watch<LdMonkeySortAndFilterState<TestItem, int>>();
            latestState = state;

            final filter = state.filters.whereType<LdFilterOneOf<TestItem, int, String>>().first;
            return Text('selected=${filter.selectedValue ?? 'none'};isOn=${filter.isOn}');
          },
        ),
      ),
    );
  }
}

void main() {
  group('LdMonkeyRouterAdapter', () {
    testWidgets('keeps valid one-of values and clears removed values after definition updates',
        (WidgetTester tester) async {
      final routeConfig = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'item');
      final repository = createTestListController();
      final harnessKey = GlobalKey<_RouterAdapterHarnessState>();
      final categoryQueryKey = routeConfig.filterQueryKey('category');

      final router = GoRouter(
        initialLocation: '/?$categoryQueryKey=gold',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => _RouterAdapterHarness(
              key: harnessKey,
              routeConfig: routeConfig,
              repository: repository,
              initialOptions: const ['all', 'gold'],
            ),
          ),
        ],
      );

      Future<void> pumpFrames() async {
        for (var i = 0; i < 10; i++) {
          await tester.pump(const Duration(milliseconds: 100));
        }
      }

      await tester.pumpWidget(
        LdThemeProvider(
          child: MaterialApp.router(
            localizationsDelegates: const [
              ...LiquidLocalizations.localizationsDelegates,
            ],
            routerConfig: router,
          ),
        ),
      );

      await pumpFrames();

      var filter = harnessKey.currentState!.categoryFilter;
      expect(filter.selectedValue, equals('gold'));
      expect(filter.isOn, isTrue);

      // Simulate dynamic options arriving while the selected value is still valid.
      harnessKey.currentState!.replaceOptions(const ['all', 'gold', 'silver']);
      await pumpFrames();

      filter = harnessKey.currentState!.categoryFilter;
      expect(filter.selectedValue, equals('gold'));
      expect(filter.isOn, isTrue);
      expect(filter.allValues.keys, contains('silver'));

      // Now drop the selected option from definitions and ensure stale state is removed.
      harnessKey.currentState!.replaceOptions(const ['all', 'silver']);
      await pumpFrames();

      filter = harnessKey.currentState!.categoryFilter;
      expect(filter.selectedValue, isNull);
      expect(filter.isOn, isFalse);
      expect(filter.allValues.keys, isNot(contains('gold')));
    });
  });
}
