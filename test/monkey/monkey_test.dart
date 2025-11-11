import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

// Test item class
class _TestItem with Identifiable<int> {
  @override
  final int id;
  final String name;
  final int value;
  final bool active;

  _TestItem(this.id, this.name, this.value, [this.active = true]);

  _TestItem copyWith({
    int? id,
    String? name,
    int? value,
    bool? active,
  }) {
    return _TestItem(
      id ?? this.id,
      name ?? this.name,
      value ?? this.value,
      active ?? this.active,
    );
  }

  @override
  String toString() => '_TestItem(id: $id, name: $name, value: $value, active: $active)';
}

void main() {
  group('LdMonkey Tests', () {
    // Helper function to create a monkey instance
    LdMonkey<_TestItem, int> createMonkey({
      required LdRepository<_TestItem, int> Function(BuildContext context) buildRepository,
      String? path,
      String Function(Set<int> ids)? detailPath,
      Widget Function(BuildContext context, LdPaginatorItem<_TestItem> item)? buildDetail,
      LdSelectableList<_TestItem, int> Function(
        LdMonkey<_TestItem, int> route,
        LdMonkeyDetailState<_TestItem, int> state,
        void Function(Set<int> selectedItems) onSelectionChanged,
      )? listBuilder,
      Set<int> Function(String selected)? parseSelected,
      double reflowBreakpoint = 600,
      LdMonkeyLayoutMode layoutMode = LdMonkeyLayoutMode.auto,
    }) {
      return LdMonkey<_TestItem, int>(
        path: path ?? '/test',
        parseId: (id) => int.parse(id),
        detailPath: detailPath ?? ((ids) => '/test/${ids.join(",")}'),
        buildRepository: buildRepository,
        buildDetail: buildDetail ?? (context, item) => Text(item.value?.name ?? 'Loading'),
        listBuilder: listBuilder ??
            (route, state, onSelectionChanged) => LdSelectableList<_TestItem, int>(
                  paginator: route.repository,
                  itemBuilder: (context, item, index) => LdListItem(
                    title: Text(item.value?.name ?? ''),
                  ),
                  onSelectionChange: onSelectionChanged,
                ),
        reflowBreakpoint: reflowBreakpoint,
        layoutMode: layoutMode,
        parseSelected: parseSelected,
      );
    }

    group('Initial State', () {
      test('initializes with default state', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        expect(monkey.state.showSelectionControls, isFalse);
        expect(monkey.state.selectedItems, isEmpty);
        expect(monkey.state.deletedItems, isEmpty);
        expect(monkey.state.repository, isNull);
      });
    });

    group('State Management', () {
      test('setSelectedItems updates state and emits to stream', () async {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        var streamEmitted = false;
        monkey.stateStream.listen((state) {
          debugPrint('$state state.selectedItems: ${state.selectedItems.join(",")}');
          if (state.selectedItems.isNotEmpty) {
            streamEmitted = true;
          }
        });

        monkey.setSelectedItems({1, 2});

        expect(monkey.state.selectedItems, equals({1, 2}));
        await Future.delayed(const Duration(milliseconds: 100));
        expect(streamEmitted, isTrue);
      });

      test('setSelectedItems handles duplicate selections', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        monkey.setSelectedItems({1, 2});

        // Setting the same items should not trigger update
        monkey.setSelectedItems({1, 2});

        // Note: This test verifies the logic, but since state comparison uses join(",")
        // the state object reference might be different but content is same
        expect(monkey.state.selectedItems, equals({1, 2}));
      });

      test('setShowSelectionControls shows controls and maintains selection', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        monkey.setSelectedItems({1, 2});
        monkey.setShowSelectionControls(true);

        expect(monkey.state.showSelectionControls, isTrue);
        expect(monkey.state.selectedItems, equals({1, 2}));
      });

      test('setShowSelectionControls hides controls and clears selection', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        monkey.setSelectedItems({1, 2});
        monkey.setShowSelectionControls(true);
        monkey.setShowSelectionControls(false);

        expect(monkey.state.showSelectionControls, isFalse);
        expect(monkey.state.selectedItems, isEmpty);
      });

      test('stateStream emits on state changes', () async {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        final states = <LdMonkeyDetailState<_TestItem, int>>[];
        monkey.stateStream.listen((state) {
          states.add(state);
        });

        monkey.setSelectedItems({1});
        monkey.setShowSelectionControls(true);

        // Wait a bit for async stream emissions
        await Future.delayed(const Duration(milliseconds: 10));

        expect(states.length, greaterThan(0));
        expect(states.last.selectedItems, contains(1));
        expect(states.last.showSelectionControls, isTrue);
      });

      test('state copyWith creates new instance correctly', () {
        const state1 = LdMonkeyDetailState<_TestItem, int>(
          showSelectionControls: false,
          selectedItems: {1, 2},
        );

        final state2 = state1.copyWith(
          showSelectionControls: true,
          selectedItems: {3},
        );

        expect(state2.showSelectionControls, isTrue);
        expect(state2.selectedItems, equals({3}));
        expect(state1.showSelectionControls, isFalse);
        expect(state1.selectedItems, equals({1, 2}));
      });
    });

    group('Repository Initialization', () {
      test('initRepository creates repository via buildRepository', () async {
        var repositoryCreated = false;
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            repositoryCreated = true;
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) {
            repositoryCreated = true;
            return repository;
          },
        );

        final context = MockBuildContext();
        await monkey.initRepository(context, {}, {});

        expect(monkey.state.repository, isNotNull);
        expect(repositoryCreated, isTrue);
      });

      test('initRepository with empty selection calls fetchItemsAtOffset', () async {
        var fetchCalled = false;
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            if (offset == 0) {
              fetchCalled = true;
            }
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        final context = MockBuildContext();
        await monkey.initRepository(context, {}, {});

        expect(fetchCalled, isTrue);
      });

      test('initRepository with initial selection calls initWithSelection', () async {
        var initWithSelectionCalled = false;
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
          getOffsetById: (id, {filters, sortOptions}) async {
            initWithSelectionCalled = true;
            return 0;
          },
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        final context = MockBuildContext();
        await monkey.initRepository(context, {1}, {});

        expect(initWithSelectionCalled, isTrue);
      });

      test('initRepository applies filters from query parameters', () async {
        final filter = LdFilterBoolOption<_TestItem, int>(
          name: 'active',
          label: (context) => 'Active',
          icon: (context) => const Icon(Icons.check),
          optimisticFilter: (item) => item.active,
        );

        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
          filters: {filter},
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        final context = MockBuildContext();
        await monkey.initRepository(context, {}, {'active': 'true'});

        expect(repository.filters['active']!.isOn, isTrue);
      });

      test('initRepository sets up deletion listener', () async {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(
              newItems: [_TestItem(1, 'Item 1', 10)],
              hasMore: false,
              total: 1,
            );
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        final context = MockBuildContext();
        await monkey.initRepository(context, {1}, {});
        monkey.setSelectedItems({1});

        // Simulate deletion by updating item state
        repository.replaceItems({
          0: LdPaginatorItem<_TestItem>(
            value: _TestItem(1, 'Item 1', 10),
            state: LdPaginatorItemState.deleted,
          ),
        });

        // Trigger the update stream
        repository.confirmItemDeletion(1);

        await Future.delayed(const Duration(milliseconds: 100));

        expect(monkey.state.deletedItems, contains(1));
        expect(monkey.state.selectedItems.contains(1), isFalse);
      });
    });

    group('URL Parsing', () {
      test('parseSelected with default comma-separated parsing', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        final result = monkey.parseSelected('1,2,3');
        expect(result, equals({1, 2, 3}));
      });

      test('parseSelected with empty string returns empty set', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        final result = monkey.parseSelected('');
        expect(result, isEmpty);
      });

      test('parseSelected with custom function', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
          parseSelected: (selected) => selected.split('-').map(int.parse).toSet(),
        );

        final result = monkey.parseSelected('1-2-3');
        expect(result, equals({1, 2, 3}));
      });

      test('parseSelected with single ID', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        final result = monkey.parseSelected('5');
        expect(result, equals({5}));
      });
    });

    group('Layout Logic', () {
      test('isSideBySide in auto mode with width > breakpoint', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
          layoutMode: LdMonkeyLayoutMode.auto,
          reflowBreakpoint: 600,
        );

        const size = Size(800, 600);
        expect(monkey.isSideBySide(size), isTrue);
      });

      test('isSideBySide in auto mode with width < breakpoint', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
          layoutMode: LdMonkeyLayoutMode.auto,
          reflowBreakpoint: 600,
        );

        const size = Size(400, 600);
        expect(monkey.isSideBySide(size), isFalse);
      });

      test('isSideBySide in sideBySide mode always returns true', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
          layoutMode: LdMonkeyLayoutMode.sideBySide,
        );

        const size = Size(400, 600);
        expect(monkey.isSideBySide(size), isTrue);
      });

      test('isSideBySide in neverSideBySide mode always returns false', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
          layoutMode: LdMonkeyLayoutMode.neverSideBySide,
        );

        const size = Size(800, 600);
        expect(monkey.isSideBySide(size), isFalse);
      });
    });

    group('Route Building', () {
      test('buildRoute creates master route', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
          path: '/items',
        );

        final routes = monkey.buildRoute();
        final masterRoute = routes.firstWhere((r) => r is ShellRoute) as ShellRoute;

        expect(masterRoute, isNotNull);
        expect(routes.length, greaterThan(0));
      });

      test('buildRoute creates filter route', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
          path: '/items',
        );

        final routes = monkey.buildRoute();
        final filterRoute = routes.firstWhere((r) => r is GoRoute && r.name == '/items-filters') as GoRoute?;

        expect(filterRoute, isNotNull);
      });
    });

    group('Integration Behaviors', () {
      test('repository getter throws when not initialized', () {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        expect(() => monkey.repository, throwsA(isA<TypeError>()));
      });

      test('repository getter returns correct instance after init', () async {
        final repository = LdRepository<_TestItem, int>(
          fetchListWithParameters: ({required offset, required pageSize, pageToken, filters, sortOptions}) async {
            return LdListPage<_TestItem>(newItems: [], hasMore: false, total: 0);
          },
          getById: (id) async => _TestItem(id, 'Test', 0),
        );

        final monkey = createMonkey(
          buildRepository: (context) => repository,
        );

        final context = MockBuildContext();
        await monkey.initRepository(context, {}, {});

        expect(monkey.repository, equals(repository));
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
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({Object? aspect}) => null;

  @override
  T? getInheritedWidgetOfExactType<T extends InheritedWidget>() => null;

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
  bool get mounted => true;

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
