import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  required LdRepository<_TestTask, int> repository,
  required Widget child,
}) {
  return LdThemeProvider(
    child: MaterialApp(
      localizationsDelegates: LiquidLocalizations.localizationsDelegates,
      locale: const Locale('en'),
      home: ListenableProvider<LdRepository<_TestTask, int>>.value(
        value: repository,
        child: Provider<LdMonkeySelection<_TestTask, int>>.value(
          value: LdMonkeySelection<_TestTask, int>(
            selection: {},
            viewing: {1},
            showSelectionControls: false,
          ),
          child: Provider<LdMonkeyRouterController<_TestTask, int>>.value(
            value: _StubRouter(),
            child: child,
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() => ldDisableAnimations = true);
  tearDown(() => ldDisableAnimations = false);

  testWidgets('save marks form pristine', (tester) async {
    final tasks = [_TestTask(1, 'Original', false)];
    var updateCount = 0;
    final repository = LdRepository<_TestTask, int>(
      pageSize: 10,
      initialItems: tasks,
      getById: (id) async => tasks.firstWhere((t) => t.id == id),
      fetchListWithParameters: (_) async => LdListPage(
        newItems: tasks,
        hasMore: false,
        total: tasks.length,
      ),
      updateItem: (context, id, item) async {
        updateCount++;
        tasks[0] = item;
        return item;
      },
    );

    await tester.pumpWidget(
      _wrapDetailForm(
        repository: repository,
        child: LdMonkeyReactiveDetailForm<_TestTask, int, _TestTask>(
          item: LdPaginatorItem(
            value: tasks.first,
            state: LdPaginatorItemState.loaded,
          ),
          saveMode: LdMonkeyDetailSaveMode.manualSubmit,
          detailToFormValues: (task) => {
            'title': task.title,
          },
          mapToEntity: (form, task) => task.copyWith(
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
    await tester.pump();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(updateCount, 1);
    expect(tasks.first.title, 'Updated title');
  });
}
