import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:provider/provider.dart';

class _TestTask with Identifiable<int> {
  @override
  final int id;
  final String title;
  final bool done;

  _TestTask(this.id, this.title, this.done);

  _TestTask copyWith({String? title, bool? done}) => _TestTask(
        id,
        title ?? this.title,
        done ?? this.done,
      );
}

class _StubRouter implements LdMonkeyRouterController<_TestTask, int> {
  @override
  void updateFilter(BuildContext context, LdFilterOption<_TestTask, int> filter) {}

  @override
  void updateSelection(BuildContext context, Set<int> selection) {}

  @override
  void updateShowSelectionControls(BuildContext context, bool showSelectionControls) {}

  @override
  void updateSortOptions(BuildContext context, List<LdSortOption<_TestTask, int>> sortOptions) {}

  @override
  void updateViewing(BuildContext context, Set<int> viewingItems) {}
}

Widget _wrapDetailForm({
  required LdCallbackModel<_TestTask, int> model,
  required LdListController<_TestTask, int> listController,
  required Widget child,
}) {
  return LdThemeProvider(
    child: MaterialApp.router(
      localizationsDelegates: LiquidLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      routerConfig: GoRouter(
        initialLocation: '/task-demo/1',
        redirect: ldLocationLockRedirect,
        routes: [
          GoRoute(
            path: '/task-demo/1',
            builder: (context, state) => MultiProvider(
              providers: [
                Provider<LdModel<_TestTask, int, Object?, Object?>>.value(value: model),
                ListenableProvider<LdListController<_TestTask, int>>.value(value: listController),
              ],
              child: Provider<LdMonkeySelection<_TestTask, int>>.value(
                value: LdMonkeySelection<_TestTask, int>(
                  selection: {},
                  viewing: {1},
                  showSelectionControls: false,
                ),
              child: Provider<LdMonkeyRouterController<_TestTask, int>>.value(
                value: _StubRouter(),
                child: SingleChildScrollView(child: child),
              ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

LdCallbackModel<_TestTask, int> _buildModel(
  List<_TestTask> tasks, {
  Future<_TestTask?> Function(BuildContext context, int id, _TestTask item)? updateItem,
}) {
  return LdCallbackModel<_TestTask, int>(
    pageSize: 10,
    initialItems: tasks,
    getById: (context, id) async => tasks.firstWhere((t) => t.id == id),
    fetchListWithParameters: (_) async => LdListPage(
      newItems: tasks,
      hasMore: false,
      total: tasks.length,
    ),
    updateItem: updateItem ?? (context, id, item) async => item,
  );
}

LdListController<_TestTask, int> _buildListController(LdCallbackModel<_TestTask, int> model) {
  return LdListController<_TestTask, int>.fromModel(model, initialItems: model.initialItems);
}

Widget _detailFormFor(List<_TestTask> tasks) {
  return LdMonkeyReactiveDetailForm<_TestTask, int, _TestTask, _TestTask, _TestTask>.edit(
    item: LdPaginatorItem(
      value: tasks.first,
      state: LdPaginatorItemState.loaded,
    ),
    saveMode: LdMonkeyDetailSaveMode.manualSubmit,
    detailToFormValues: (task) => {
      'title': task.title,
    },
    formToUpdatePayload: (form, task) => task.copyWith(
      title: form.control('title').value as String,
    ),
    itemsBuilder: (context, hooks) => [
      LdReactiveFormItem.input<String>(
        key: 'title',
        inputFieldHint: 'Title',
        onBlurred: hooks.onBlurred('title'),
      ),
    ],
  );
}

void main() {
  setUp(() => ldDisableAnimations = true);
  tearDown(() => ldDisableAnimations = false);

  testWidgets('save marks form pristine', (tester) async {
    final tasks = [_TestTask(1, 'Original', false)];
    var updateCount = 0;
    final model = _buildModel(tasks, updateItem: (context, id, item) async {
        updateCount++;
        tasks[0] = item;
        return item;
      },);
    final listController = _buildListController(model);

    await tester.pumpWidget(
      _wrapDetailForm(
        model: model,
        listController: listController,
        child: LdMonkeyReactiveDetailForm<_TestTask, int, _TestTask, _TestTask, _TestTask>.edit(
          item: LdPaginatorItem(
            value: tasks.first,
            state: LdPaginatorItemState.loaded,
          ),
          saveMode: LdMonkeyDetailSaveMode.manualSubmit,
          detailToFormValues: (task) => {
            'title': task.title,
          },
          formToUpdatePayload: (form, task) => task.copyWith(
            title: form.control('title').value as String,
          ),
          itemsBuilder: (context, hooks) => [
            LdReactiveFormItem.input<String>(
              key: 'title',
              inputFieldHint: 'Title',
              onBlurred: hooks.onBlurred('title'),
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(LdInput), 'Updated title');
    await tester.pumpAndSettle();

    final saveButton = find.byWidgetPredicate(
      (widget) => widget is LdButton && widget.child is Text && (widget.child as Text).data == 'Save',
    );
    expect(saveButton, findsOneWidget);
    expect(tester.widget<LdButton>(saveButton).disabled, isFalse);

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(updateCount, 1);
    expect(tasks.first.title, 'Updated title');
  });

  testWidgets('registers a location lock while dirty', (tester) async {
    final tasks = [_TestTask(1, 'Original', false)];
    final model = _buildModel(tasks);
    final listController = _buildListController(model);

    LdLocationLockRegistry? lockRegistry;

    await tester.pumpWidget(
      _wrapDetailForm(
        model: model,
        listController: listController,
        child: Builder(
          builder: (context) {
            lockRegistry = LdLocationLockRegistry.of(context);
            return LdMonkeyReactiveDetailForm<_TestTask, int, _TestTask, _TestTask, _TestTask>.edit(
              item: LdPaginatorItem(
                value: tasks.first,
                state: LdPaginatorItemState.loaded,
              ),
              saveMode: LdMonkeyDetailSaveMode.manualSubmit,
              detailToFormValues: (task) => {
                'title': task.title,
              },
              formToUpdatePayload: (form, task) => task.copyWith(
                title: form.control('title').value as String,
              ),
              itemsBuilder: (context, hooks) => [
                LdReactiveFormItem.input<String>(
                  key: 'title',
                  inputFieldHint: 'Title',
                  onBlurred: hooks.onBlurred('title'),
                ),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(lockRegistry!.isEmpty, isTrue);

    await tester.enterText(find.byType(LdInput), 'Updated title');
    await tester.pump();

    expect(lockRegistry!.isEmpty, isFalse);
    expect(lockRegistry!.locks.single.pathPrefix, '/task-demo/1');
  });

  testWidgets('blocked back shows discard dialog and pops on confirm', (tester) async {
    final tasks = [_TestTask(1, 'Original', false)];
    final model = _buildModel(tasks);
    final listController = _buildListController(model);

    Widget detailRoute(BuildContext context) {
      return MultiProvider(
        providers: [
          Provider<LdModel<_TestTask, int, Object?, Object?>>.value(value: model),
          ListenableProvider<LdListController<_TestTask, int>>.value(value: listController),
        ],
        child: Provider<LdMonkeySelection<_TestTask, int>>.value(
          value: LdMonkeySelection<_TestTask, int>(
            selection: {},
            viewing: {1},
            showSelectionControls: false,
          ),
          child: Provider<LdMonkeyRouterController<_TestTask, int>>.value(
            value: _StubRouter(),
            child: Column(
              children: [
                LdButton(
                  child: const Text('back'),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: SingleChildScrollView(child: _detailFormFor(tasks)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp.router(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          routerConfig: GoRouter(
            initialLocation: '/list',
            redirect: ldLocationLockRedirect,
            routes: [
              GoRoute(
                path: '/list',
                builder: (context, state) => LdButton(
                  child: const Text('open'),
                  onPressed: () => context.push('/list/1'),
                ),
              ),
              GoRoute(
                path: '/list/1',
                builder: (context, state) => detailRoute(context),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(LdInput), 'Changed');
    await tester.pump();

    await tester.tap(find.text('back'));
    await tester.pumpAndSettle();

    // The pop is blocked and the discard dialog is shown instead.
    expect(find.text('Discard'), findsOneWidget);
    expect(find.byType(LdInput), findsOneWidget);

    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();

    // Confirming discard pops back to the list.
    expect(find.text('open'), findsOneWidget);
    expect(find.byType(LdInput), findsNothing);
  });

  testWidgets('blocked back keeps the form when discard is cancelled', (tester) async {
    final tasks = [_TestTask(1, 'Original', false)];
    final model = _buildModel(tasks);
    final listController = _buildListController(model);

    Widget detailRoute(BuildContext context) {
      return MultiProvider(
        providers: [
          Provider<LdModel<_TestTask, int, Object?, Object?>>.value(value: model),
          ListenableProvider<LdListController<_TestTask, int>>.value(value: listController),
        ],
        child: Provider<LdMonkeySelection<_TestTask, int>>.value(
          value: LdMonkeySelection<_TestTask, int>(
            selection: {},
            viewing: {1},
            showSelectionControls: false,
          ),
          child: Provider<LdMonkeyRouterController<_TestTask, int>>.value(
            value: _StubRouter(),
            child: Column(
              children: [
                LdButton(
                  child: const Text('back'),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                Expanded(
                  child: SingleChildScrollView(child: _detailFormFor(tasks)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    await tester.pumpWidget(
      LdThemeProvider(
        child: MaterialApp.router(
          localizationsDelegates: LiquidLocalizations.localizationsDelegates,
          locale: const Locale('en'),
          routerConfig: GoRouter(
            initialLocation: '/list',
            redirect: ldLocationLockRedirect,
            routes: [
              GoRoute(
                path: '/list',
                builder: (context, state) => LdButton(
                  child: const Text('open'),
                  onPressed: () => context.push('/list/1'),
                ),
              ),
              GoRoute(
                path: '/list/1',
                builder: (context, state) => detailRoute(context),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(LdInput), 'Changed');
    await tester.pump();

    await tester.tap(find.text('back'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();

    // Cancelling keeps the detail route open.
    expect(find.byType(LdInput), findsOneWidget);
    expect(find.text('open'), findsNothing);
  });
}
