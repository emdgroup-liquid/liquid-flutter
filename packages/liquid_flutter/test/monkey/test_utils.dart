import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:provider/provider.dart';

// Test item class
class TestItem with Identifiable<int> {
  @override
  final int id;
  final String name;
  final int value;
  final bool active;
  final String category;

  TestItem(this.id, this.name, this.value, [this.active = true, this.category = 'A']);

  TestItem copyWith({
    int? id,
    String? name,
    int? value,
    bool? active,
    String? category,
  }) {
    return TestItem(
      id ?? this.id,
      name ?? this.name,
      value ?? this.value,
      active ?? this.active,
      category ?? this.category,
    );
  }

  @override
  String toString() => 'TestItem(id: $id, name: $name, value: $value, active: $active, category: $category)';
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
  bool get mounted => true;

  @override
  DiagnosticsNode describeElement(String name, {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  T? getInheritedWidgetOfExactType<T extends InheritedWidget>() => null;

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

/// A thin non-Listenable wrapper around [TestSortAndFilterState] that
/// satisfies [LdMonkeyRouterController].
///
/// Using [TestSortAndFilterState] directly as `Provider<LdMonkeyRouterController>.value`
/// triggers a Provider debug assertion (because it IS a Listenable). This
/// delegate class is NOT a Listenable so it can be provided safely.
class _TestRouterControllerDelegate<T extends Identifiable<IdType>, IdType>
    implements LdMonkeyRouterController<T, IdType> {
  final TestSortAndFilterState<T, IdType> _delegate;
  _TestRouterControllerDelegate(this._delegate);

  @override
  void updateFilter(BuildContext context, LdFilterOption<T, IdType> filter) =>
      _delegate.updateFilter(context, filter);

  @override
  void updateSortOptions(BuildContext context, List<LdSortOption<T, IdType>> sortOptions) =>
      _delegate.updateSortOptions(context, sortOptions);

  @override
  void updateSelection(BuildContext context, Set<IdType> selection) =>
      _delegate.updateSelection(context, selection);

  @override
  void updateViewing(BuildContext context, Set<IdType> viewingItems) =>
      _delegate.updateViewing(context, viewingItems);

  @override
  void updateShowSelectionControls(BuildContext context, bool showSelectionControls) =>
      _delegate.updateShowSelectionControls(context, showSelectionControls);
}

/// A ChangeNotifier that holds mutable sort-and-filter state for tests.
/// Wraps [LdMonkeySortAndFilterState] and exposes mutation helpers so tests
/// can simulate filter/sort updates without a real GoRouter.
class TestSortAndFilterState<T extends Identifiable<IdType>, IdType> extends ChangeNotifier
    implements LdMonkeyRouterController<T, IdType> {
  Set<LdFilterOption<T, IdType>> _filters;
  List<LdSortOption<T, IdType>> _sortOptions;

  Set<IdType> _selection = {};
  Set<IdType> _viewing = {};
  bool _showSelectionControls = false;

  Set<IdType> get currentSelection => _selection;
  Set<IdType> get currentViewing => _viewing;
  bool get currentShowSelectionControls => _showSelectionControls;

  TestSortAndFilterState({
    Set<LdFilterOption<T, IdType>>? filters,
    List<LdSortOption<T, IdType>>? sortOptions,
  })  : _filters = filters ?? {},
        _sortOptions = sortOptions ?? [];

  /// Returns a non-Listenable delegate suitable for
  /// `Provider<LdMonkeyRouterController>.value(value: ...)`.
  LdMonkeyRouterController<T, IdType> get controllerDelegate =>
      _TestRouterControllerDelegate<T, IdType>(this);

  LdMonkeySortAndFilterState<T, IdType> get state => LdMonkeySortAndFilterState<T, IdType>(
        filters: _filters,
        sortOptions: _sortOptions,
      );

  LdMonkeySelection<T, IdType> get selection => LdMonkeySelection<T, IdType>(
        selection: _selection,
        viewing: _viewing,
        showSelectionControls: _showSelectionControls,
      );

  /// Direct access to current filter map by name (for test assertions).
  Map<String, LdFilterOption<T, IdType>> get filtersMap =>
      {for (final f in _filters) f.name: f};

  @override
  void updateFilter(BuildContext context, LdFilterOption<T, IdType> filter) {
    _filters = {
      for (final f in _filters)
        if (f.name == filter.name) filter else f,
    };
    notifyListeners();
  }

  @override
  void updateSortOptions(BuildContext context, List<LdSortOption<T, IdType>> sortOptions) {
    _sortOptions = sortOptions;
    notifyListeners();
  }

  @override
  void updateSelection(BuildContext context, Set<IdType> selection) {
    _selection = selection;
    notifyListeners();
  }

  @override
  void updateViewing(BuildContext context, Set<IdType> viewingItems) {
    _viewing = viewingItems;
    notifyListeners();
  }

  @override
  void updateShowSelectionControls(BuildContext context, bool showSelectionControls) {
    _showSelectionControls = showSelectionControls;
    notifyListeners();
  }
}

/// Creates a test repository with default implementations.
/// NOTE: filters and sort options are NOT stored in the repository; they live
/// in [LdMonkeySortAndFilterState]. Use [TestSortAndFilterState] + a
/// [Provider] in widget tests that need filter state.
LdRepository<TestItem, int> createTestRepository({
  List<TestItem>? initialItems,
  Future<int?> Function(int id,
          {Set<LdFilterOption<TestItem, int>>? filters, List<LdSortOption<TestItem, int>>? sortOptions})?
      getOffsetById,
  Future<void> Function(BuildContext context, int id)? deleteItem,
  Future<TestItem?> Function(BuildContext context, int id, TestItem newItem)? updateItem,
  Future<TestItem> Function(BuildContext context, TestItem? newItem)? createItem,
  Future<void> Function(BuildContext context, Set<int> ids)? deleteBatch,
  Future<void> Function(BuildContext context, Set<TestItem> items)? updateBatch,
}) {
  final items = initialItems ??
      [
        TestItem(1, 'Item 1', 10),
        TestItem(2, 'Item 2', 20),
        TestItem(3, 'Item 3', 30),
      ];

  return LdRepository<TestItem, int>(
    fetchListWithParameters: (parameters) async {
      // Simulate a server that returns all items (no server-side filtering in test helper)
      final paginated = items.skip(parameters.offset).take(parameters.pageSize).toList();
      return LdListPage<TestItem>(
        newItems: paginated,
        hasMore: parameters.offset + parameters.pageSize < items.length,
        total: items.length,
      );
    },
    // Pre-seed the paginator so watchListOfItems can find items immediately.
    initialItems: initialItems != null ? [...items] : null,
    getById: (id) async => items.firstWhere((item) => item.id == id),
    getOffsetById: getOffsetById == null
        ? null
        : (parameters) async => getOffsetById(
              parameters.id,
              filters: parameters.filters,
              sortOptions: parameters.sortOptions,
            ),
    deleteItem: deleteItem,
    updateItem: updateItem,
    createItem: createItem,
    deleteBatch: deleteBatch,
    updateBatch: updateBatch,
  );
}

/// Creates a test item
TestItem createTestItem(int id, {String? name, int? value, bool? active, String? category}) {
  return TestItem(
    id,
    name ?? 'Item $id',
    value ?? id * 10,
    active ?? true,
    category ?? 'A',
  );
}

/// Wraps filter modal / context menu widgets with GoRouter and monkey providers.
Widget wrapMonkeyFilterTestContext<T extends Identifiable<IdType>, IdType>({
  required Widget child,
  required LdRepository<T, IdType> repository,
  required TestSortAndFilterState<T, IdType> shellState,
  LdMonkeyRouteConfig<T, IdType>? routeConfig,
}) {
  final LdMonkeyRouteConfig<T, IdType> config;
  if (routeConfig != null) {
    config = routeConfig;
  } else if (T == TestItem && IdType == int) {
    config = LdMonkeyRouteConfig.identifiableInt<TestItem>(itemName: 'item')
        as LdMonkeyRouteConfig<T, IdType>;
  } else {
    throw ArgumentError(
      'wrapMonkeyFilterTestContext requires routeConfig for $T/$IdType',
    );
  }
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Provider<LdMonkeyRouteConfig<T, IdType>>.value(
          value: config,
          child: ListenableProvider<LdRepository<T, IdType>>.value(
            value: repository,
            child: ListenableProvider<TestSortAndFilterState<T, IdType>>.value(
              value: shellState,
              child: Provider<LdMonkeyRouterController<T, IdType>>.value(
                value: shellState.controllerDelegate,
                child: Builder(
                  builder: (context) {
                    context.watch<TestSortAndFilterState<T, IdType>>();
                    return Provider<LdMonkeySortAndFilterState<T, IdType>>.value(
                      value: shellState.state,
                      child: child,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  return LdThemeProvider(
    child: MaterialApp.router(
      localizationsDelegates: LiquidLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      routerConfig: router,
    ),
  );
}
