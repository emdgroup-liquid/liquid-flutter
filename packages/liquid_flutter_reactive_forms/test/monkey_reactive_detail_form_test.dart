import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:liquid_flutter/liquid_flutter.dart';
import 'package:liquid_flutter_reactive_forms/liquid_flutter_reactive_forms.dart';
import 'package:provider/provider.dart';
import 'package:reactive_forms/reactive_forms.dart';

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
  void updateFilter(
    BuildContext context,
    LdFilterOption<_TestTask, int> filter,
  ) {}

  @override
  void updateSelection(BuildContext context, Set<int> selection) {}

  @override
  void updateShowSelectionControls(
    BuildContext context,
    bool showSelectionControls,
  ) {}

  @override
  void updateSortOptions(
    BuildContext context,
    List<LdSortOption<_TestTask, int>> sortOptions,
  ) {}

  @override
  void updateViewing(BuildContext context, Set<int> viewingItems) {}
}

Widget _wrapDetailForm({
  required LdCallbackModel<_TestTask, int, _TestTask, _TestTask> model,
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
                Provider<LdModel<_TestTask, int, Object?, Object?>>.value(
                  value: model,
                ),
                ListenableProvider<LdListController<_TestTask, int>>.value(
                  value: listController,
                ),
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

LdCallbackModel<_TestTask, int, _TestTask, _TestTask> _buildModel(
  List<_TestTask> tasks, {
  Future<_TestTask?> Function(BuildContext context, int id, _TestTask item)?
      updateItem,
}) {
  return LdCallbackModel<_TestTask, int, _TestTask, _TestTask>(
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

LdListController<_TestTask, int> _buildListController(
  LdCallbackModel<_TestTask, int, _TestTask, _TestTask> model,
) {
  return LdListController<_TestTask, int>(
    model,
    initialItems: model.initialItems,
  );
}

Widget _detailFormFor(List<_TestTask> tasks) {
  return LdForm<_TestTask, int, _TestTask, _TestTask, _TestTask>(
    item: LdPaginatorItem(
      value: tasks.first,
      state: LdPaginatorItemState.loaded,
    ),
    mode: LdFormMode.edit,
    saveMode: LdReactiveFormSaveMode.manualSubmit,
    detailToFormValues: (task) => {
      'title': task.title,
    },
    formToUpdatePayload: (form, task) => task.copyWith(
      title: form.control('title').value as String,
    ),
    itemToDetail: (context, entity) async => entity!,
    formGroup: (context) => FormGroup({
      'title': FormControl<String>(),
    }),
    child: Column(
      children: [
        LdFormInput<String>(
          formKey: 'title',
          label: 'Title',
          hint: 'Title',
        ),
        const LdFormSubmitButton(),
      ],
    ),
  );
}

void main() {
  setUp(() => ldDisableAnimations = true);
  tearDown(() => ldDisableAnimations = false);

  testWidgets('save marks form pristine', (tester) async {
    final tasks = [_TestTask(1, 'Original', false)];
    var updateCount = 0;
    final model = _buildModel(
      tasks,
      updateItem: (context, id, item) async {
        updateCount++;
        tasks[0] = item;
        return item;
      },
    );
    final listController = _buildListController(model);

    await tester.pumpWidget(
      _wrapDetailForm(
        model: model,
        listController: listController,
        child: LdForm<_TestTask, int, _TestTask, _TestTask, _TestTask>(
          item: LdPaginatorItem(
            value: tasks.first,
            state: LdPaginatorItemState.loaded,
          ),
          mode: LdFormMode.edit,
          saveMode: LdReactiveFormSaveMode.manualSubmit,
          detailToFormValues: (task) => {
            'title': task.title,
          },
          formToUpdatePayload: (form, task) => task.copyWith(
            title: form.control('title').value as String,
          ),
          itemToDetail: (context, entity) async => entity!,
          formGroup: (context) => FormGroup({
            'title': FormControl<String>(),
          }),
          child: Column(
            children: [
              LdFormInput<String>(
                formKey: 'title',
                label: 'Title',
                hint: 'Title',
              ),
              const LdFormSubmitButton(),
            ],
          ),
        ),
      ),
    );
    // Advance past LdSubmitDialogBuilder's 1500ms hide-delay timer.
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    await tester.enterText(find.byType(LdInput), 'Updated title');
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    final saveButton = find.byWidgetPredicate(
      (widget) =>
          widget is LdButton &&
          widget.child is Text &&
          (widget.child as Text).data == 'Save',
    );
    expect(saveButton, findsOneWidget);
    expect(tester.widget<LdButton>(saveButton).disabled, isFalse);

    await tester.tap(saveButton);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(updateCount, 1);
    expect(tasks.first.title, 'Updated title');
    // Drain any remaining hide-delay timers.
    await tester.pump(const Duration(seconds: 2));
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
            return LdForm<_TestTask, int, _TestTask, _TestTask, _TestTask>(
              item: LdPaginatorItem(
                value: tasks.first,
                state: LdPaginatorItemState.loaded,
              ),
              mode: LdFormMode.edit,
              saveMode: LdReactiveFormSaveMode.manualSubmit,
              detailToFormValues: (task) => {
                'title': task.title,
              },
              formToUpdatePayload: (form, task) => task.copyWith(
                title: form.control('title').value as String,
              ),
              itemToDetail: (context, entity) async => entity!,
              formGroup: (context) => FormGroup({
                'title': FormControl<String>(),
              }),
              child: Column(
                children: [
                  LdFormInput<String>(
                    formKey: 'title',
                    label: 'Title',
                    hint: 'Title',
                  ),
                  const LdFormSubmitButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
    // Advance past LdSubmitDialogBuilder's 1500ms hide-delay timer.
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    expect(lockRegistry!.isEmpty, isTrue);

    await tester.enterText(find.byType(LdInput), 'Updated title');
    await tester.pump();

    expect(lockRegistry!.isEmpty, isFalse);
    expect(lockRegistry!.locks.single.pathPrefix, '/task-demo/1');
    // Drain any remaining hide-delay timers.
    await tester.pump(const Duration(seconds: 2));
  });

  testWidgets('blocked back shows discard dialog and pops on confirm',
      (tester) async {
    final tasks = [_TestTask(1, 'Original', false)];
    final model = _buildModel(tasks);
    final listController = _buildListController(model);

    Widget detailRoute(BuildContext context) {
      return MultiProvider(
        providers: [
          Provider<LdModel<_TestTask, int, Object?, Object?>>.value(
            value: model,
          ),
          ListenableProvider<LdListController<_TestTask, int>>.value(
            value: listController,
          ),
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

  testWidgets('blocked back keeps the form when discard is cancelled',
      (tester) async {
    final tasks = [_TestTask(1, 'Original', false)];
    final model = _buildModel(tasks);
    final listController = _buildListController(model);

    Widget detailRoute(BuildContext context) {
      return MultiProvider(
        providers: [
          Provider<LdModel<_TestTask, int, Object?, Object?>>.value(
            value: model,
          ),
          ListenableProvider<LdListController<_TestTask, int>>.value(
            value: listController,
          ),
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

  testWidgets('arbitrary widgets can be mixed in child', (tester) async {
    final tasks = [_TestTask(1, 'Original', false)];
    final model = _buildModel(tasks);
    final listController = _buildListController(model);

    await tester.pumpWidget(
      _wrapDetailForm(
        model: model,
        listController: listController,
        child: LdForm<_TestTask, int, _TestTask, _TestTask, _TestTask>(
          item: LdPaginatorItem(
            value: tasks.first,
            state: LdPaginatorItemState.loaded,
          ),
          mode: LdFormMode.edit,
          saveMode: LdReactiveFormSaveMode.manualSubmit,
          detailToFormValues: (task) => {'title': task.title},
          formToUpdatePayload: (form, task) => task.copyWith(
            title: form.control('title').value as String,
          ),
          itemToDetail: (context, entity) async => entity!,
          formGroup: (context) => FormGroup({
            'title': FormControl<String>(),
            'note': FormControl<String>(),
          }),
          child: Column(
            children: [
              LdFormInput<String>(
                formKey: 'title',
                label: 'Title',
                hint: 'Title',
              ),
              const Text('extra widget'),
              LdFormInput<String>(
                formKey: 'note',
                label: 'Note',
                hint: 'Note',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Both fields and the injected widget are rendered.
    expect(find.byType(LdInput), findsNWidgets(2));
    expect(find.text('extra widget'), findsOneWidget);
  });

  testWidgets('widget can access LdFormState via Provider', (tester) async {
    final tasks = [_TestTask(1, 'Original', false)];
    final model = _buildModel(tasks);
    final listController = _buildListController(model);

    await tester.pumpWidget(
      _wrapDetailForm(
        model: model,
        listController: listController,
        child: LdForm<_TestTask, int, _TestTask, _TestTask, _TestTask>(
          item: LdPaginatorItem(
            value: tasks.first,
            state: LdPaginatorItemState.loaded,
          ),
          mode: LdFormMode.edit,
          saveMode: LdReactiveFormSaveMode.manualSubmit,
          detailToFormValues: (task) => {'title': task.title},
          formToUpdatePayload: (form, task) => task.copyWith(
            title: form.control('title').value as String,
          ),
          itemToDetail: (context, entity) async => entity!,
          formGroup: (context) => FormGroup({
            'title': FormControl<String>(),
          }),
          child: Column(
            children: [
              Builder(
                builder: (context) {
                  final form = ReactiveForm.of(context)!;
                  return Text(form.dirty ? 'dirty' : 'pristine');
                },
              ),
              LdFormInput<String>(
                formKey: 'title',
                label: 'Title',
                hint: 'Title',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially pristine.
    expect(find.text('pristine'), findsOneWidget);
    expect(find.text('dirty'), findsNothing);

    // Edit a field — the widget should now reflect dirty state.
    await tester.enterText(find.byType(LdInput), 'Changed');
    await tester.pump();

    expect(find.text('dirty'), findsOneWidget);
    expect(find.text('pristine'), findsNothing);
  });
}
