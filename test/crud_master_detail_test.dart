import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_flutter/liquid_flutter.dart';

import 'utils.dart';

class ExampleItem with CrudItemMixin<ExampleItem> {
  @override
  final int? id;
  final String name;

  ExampleItem(this.id, this.name);

  @override
  String toString() {
    return "ExampleItem($id, $name)";
  }
}

class ExampleRepository extends LdCrudOperations<ExampleItem> {
  final List<ExampleItem> _items = List.generate(10, (i) => ExampleItem(i, "Item $i"));

  ExampleRepository._privateConstructor();

  static final ExampleRepository _instance = ExampleRepository._privateConstructor();

  factory ExampleRepository.instance() {
    return _instance;
  }

  /// Find the next available ID
  int? _nextId;
  int get nextId {
    _nextId ??= _items.lastOrNull?.id;
    _nextId = (_nextId ?? -1) + 1;
    return _nextId!;
  }

  int get itemsCount => _items.length;

  @override
  Future<ExampleItem> create(ExampleItem item) async {
    if (!item.isNew) {
      throw LdException(message: "Item already exists");
    }
    final newItem = ExampleItem(nextId, item.name);
    await Future.delayed(const Duration(seconds: 1));

    _items.add(newItem);
    return Future.value(newItem);
  }

  @override
  Future<ExampleItem> update(ExampleItem item) async {
    await Future.delayed(const Duration(seconds: 1));

    final index = _items.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _items[index] = item;
      return Future.value(item);
    }
    throw LdException(message: "Item not found");
  }

  @override
  Future<void> delete(ExampleItem item) async {
    await Future.delayed(const Duration(seconds: 1));

    final index = _items.indexWhere((element) => element.id == item.id);
    if (index != -1) {
      _items.removeAt(index);
      return;
    }
    throw LdException(message: "Item not found");
  }

  ExampleItem? getItemById(int id) {
    return _items.firstWhereOrNull((element) => element.id == id);
  }

  @override
  FetchListFunction<ExampleItem> get fetchAll => ({
        required int offset,
        required int pageSize,
        String? pageToken,
      }) async {
        await Future.delayed(const Duration(seconds: 1));
        final endIndex = _min(offset + pageSize, _items.length);
        final pageItems = offset >= _items.length ? <ExampleItem>[] : _items.sublist(offset, endIndex);
        final hasMore = endIndex < _items.length;
        return LdListPage<ExampleItem>(
          newItems: pageItems,
          hasMore: hasMore,
          total: itemsCount,
        );
      };

  int _min(int a, int b) {
    return a < b ? a : b;
  }
}

void main() {
  Future<void> pumpSampleCrudMasterDetail(WidgetTester tester) async {
    await tester.pumpWidget(
      withLiquidTheme(
        MaterialApp(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          home: LdCrudMasterDetail<ExampleItem>(
            crud: ExampleRepository.instance(),
            buildMasterTitle: (context, openItem, optimisticOpenItem, isSeparatePage, controller, listState) =>
                const Text('CRUD Master View'),
            buildMasterActions: (context, openItem, optimisticOpenItem, isSeparatePage, controller, listState) => [
              LdCrudAction.createItem<ExampleItem>(getNewItem: () => ExampleItem(null, "Another New Item")),
            ],
            buildMaster: (context, openItem, optimisticOpenItem, isSeparatePage, controller, listState) =>
                LdCrudMasterList(
              controller: controller,
              titleBuilder: (context, item, optimisticItem) => Text(item.name),
              listState: listState,
            ),
            buildDetailTitle: (context, item, optimisticItem, isSeparatePage, controller, listState) =>
                const Text('CRUD Detail Title'),
            buildDetail: (context, item, optimisticItem, isSeparatePage, controller, listState) =>
                Text('CRUD Detail View: $item'),
            buildDetailActions: (context, item, optimisticItem, isSeparatePage, controller, listState) => [
              LdCrudAction.updateItem<ExampleItem>(
                getUpdatedItem: () => ExampleItem(item.id, "Updated ${item.name}"),
              ),
              LdCrudAction.deleteItem<ExampleItem>(),
            ],
            masterDetailBuilder: (context, masterDetailBuilders) =>
                LdMasterDetail.builders(builders: masterDetailBuilders),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  group('LdCrudMasterDetail Tests', () {
    testWidgets('renders CRUD master and detail views', (WidgetTester tester) async {
      await pumpSampleCrudMasterDetail(tester);
      expect(find.text('CRUD Master View'), findsOneWidget);

      expect(find.text('CRUD Detail Title'), findsNothing);
      await tester.tap(find.text('Item 5'));
      await tester.pumpAndSettle();

      expect(find.text('CRUD Detail Title'), findsOneWidget);
      expect(find.text('CRUD Detail View: ExampleItem(5, Item 5)'), findsOneWidget);
    });

    testWidgets('handles CRUD create operation', (WidgetTester tester) async {
      await pumpSampleCrudMasterDetail(tester);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(find.text('Another New Item'), findsOneWidget);
    });

    testWidgets('handles CRUD update operation', (WidgetTester tester) async {
      await pumpSampleCrudMasterDetail(tester);

      await tester.tap(find.text('Item 5'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('CRUD Detail View: ExampleItem(5, Updated Item 5)'), findsOneWidget);
    });

    testWidgets('handles CRUD delete operation', (WidgetTester tester) async {
      await pumpSampleCrudMasterDetail(tester);

      await tester.tap(find.text('Item 6'));
      await tester.pumpAndSettle();

      expect(find.text('CRUD Detail View: ExampleItem(6, Item 6)'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Assert that the item is deleted from the master view and the detail view is closed
      expect(find.text('CRUD Detail View: ExampleItem(6, Item 6)'), findsNothing);
      expect(find.text('Item 6'), findsNothing);
    });
  });
}
