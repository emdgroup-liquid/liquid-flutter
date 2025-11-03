import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

// Test item class
class _TestItem with Identifiable<int> {
  @override
  final int id;
  final String name;
  final int value;
  final bool active;

  _TestItem(this.id, this.name, this.value, [bool? active]) : active = active ?? true;

  @override
  String toString() => '_TestItem(id: $id, name: $name, value: $value, active: $active)';
}

void main() {
  group('Filter Modal Tests', () {
    LdMonkey<_TestItem, int> createMonkeyWithFilters({
      Set<LdFilterOption<_TestItem, int>>? filters,
      List<LdSortOption<_TestItem, int>>? sortOptions,
    }) {
      final repository = LdRepository<_TestItem, int>(
        fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
          return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
        },
        getById: (id) async => _TestItem(id, 'Test', 0),
        filters: filters,
        sortOptions: sortOptions,
      );

      return LdMonkey<_TestItem, int>(
        path: '/test',
        parseId: (id) => int.parse(id),
        detailPath: (ids) => '/test/${ids.join(",")}',
        buildRepository: (context) => repository,
        buildDetail: (context, item) => Text(item.value?.name ?? 'Loading'),
        listBuilder: (route, state, onSelectionChanged) => LdSelectableList<_TestItem, int>(
          paginator: route.repository,
          itemBuilder: (context, item, index) => LdListItem(
            title: Text(item.value?.name ?? ''),
          ),
          onSelectionChange: onSelectionChanged,
        ),
      );
    }

    group('LdFilterModal Widget', () {
      testWidgets('renders correctly with filters', (WidgetTester tester) async {
        final filter = LdFilterBoolOption<_TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) => item.active,
        );

        final monkey = createMonkeyWithFilters(filters: {filter});
        final context = MockBuildContext();
        await monkey.initRepository(context, {}, {});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: Scaffold(
                body: Provider<LdMonkey<_TestItem, int>>.value(
                  value: monkey,
                  child: LdFilterModal(route: monkey),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Active'), findsWidgets);
      });

      testWidgets('shows active and inactive filters separately', (WidgetTester tester) async {
        final activeFilter = LdFilterBoolOption<_TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: true,
          optimisticFilter: (item) => item.active,
        );

        final inactiveFilter = LdFilterBoolOption<_TestItem, int>(
          name: 'inactive',
          label: (context) => 'Inactive',
          icon: (context) => const Icon(Icons.close),
          isOn: false,
          optimisticFilter: (item) => !item.active,
        );

        final monkey = createMonkeyWithFilters(
          filters: {activeFilter, inactiveFilter},
        );

        final context = MockBuildContext();
        await monkey.initRepository(context, {}, {});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: Scaffold(
                body: Provider<LdMonkey<_TestItem, int>>.value(
                  value: monkey,
                  child: LdFilterModal(route: monkey),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Active'), findsWidgets);
        expect(find.text('Inactive'), findsWidgets);
      });

      testWidgets('updates when filter stream emits', (WidgetTester tester) async {
        final filter = LdFilterBoolOption<_TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          isOn: false,
          optimisticFilter: (item) => item.active,
        );

        final monkey = createMonkeyWithFilters(filters: {filter});
        final context = MockBuildContext();
        await monkey.initRepository(context, {}, {});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: Scaffold(
                body: Provider<LdMonkey<_TestItem, int>>.value(
                  value: monkey,
                  child: LdFilterModal(route: monkey),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Update filter
        monkey.repository.updateFilter('active', (f) => f!.copyWith(isOn: true));
        await tester.pumpAndSettle();

        // Modal should reflect the update
        expect(monkey.repository.filters['active']!.isOn, isTrue);
      });

      testWidgets('shows sort options', (WidgetTester tester) async {
        final sortOption = LdSortOption<_TestItem, int>(
          name: 'name',
          label: (context) => 'Name',
          icon: (context) => const Icon(Icons.sort),
          optimisticSort: (a, b) => a.name.compareTo(b.name),
        );

        final monkey = createMonkeyWithFilters(
          sortOptions: [sortOption],
        );

        final context = MockBuildContext();
        await monkey.initRepository(context, {}, {});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              home: Scaffold(
                body: Provider<LdMonkey<_TestItem, int>>.value(
                  value: monkey,
                  child: LdFilterModal(route: monkey),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Name'), findsOneWidget);
      });
    });

    group('LdFilterContextMenu Widget', () {
      testWidgets('renders filter button', (WidgetTester tester) async {
        final monkey = createMonkeyWithFilters();
        final context = MockBuildContext();
        await monkey.initRepository(context, {}, {});

        await tester.pumpWidget(
          LdThemeProvider(
            child: MaterialApp(
              localizationsDelegates: LiquidLocalizations.localizationsDelegates,
              locale: const Locale('en'),
              home: Scaffold(
                body: Provider<LdMonkey<_TestItem, int>>.value(
                  value: monkey,
                  child: const LdFilterContextMenu<_TestItem, int>(),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Filter'), findsOneWidget);
      });
    });
  });
}

// Mock BuildContext for testing
class MockBuildContext extends BuildContext {
  @override
  bool get debugDoingBuild => false;

  @override
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor, {Object? aspect}) {
    throw UnimplementedError();
  }

  @override
  T? getInheritedWidgetOfExactType<T extends InheritedWidget>() => null;

  @override
  bool get mounted => true;

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object? aspect}) => null;

  @override
  DiagnosticsNode describeElement(String name, {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor({required Type expectedAncestorType}) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeWidget(String name, {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  void dispatchNotification(Notification notification) {}

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() => null;

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() => null;

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() => null;

  @override
  RenderObject? findRenderObject() => null;

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() => null;

  @override
  InheritedElement? getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() => null;

  @override
  BuildOwner? get owner => null;

  @override
  Size? get size => null;

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {}

  @override
  void visitChildElements(ElementVisitor visitor) {}

  @override
  Widget get widget => throw UnimplementedError();
}
